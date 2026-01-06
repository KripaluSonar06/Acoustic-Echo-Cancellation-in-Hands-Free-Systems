classdef coherence_dtd < handle
    %COHERENCEDTD  Coherence-based Double Talk Detector
    %
    % Detects double-talk using magnitude-squared coherence
    % between far-end signal and microphone signal (frequency domain)

    properties
        threshold
        smoothing
        epsilon
        Pxx    % Smoothed power spectral density of X
        Pdd    % Smoothed power spectral density of D
        Pxd    % Smoothed cross power spectral density
    end

    methods
        function obj = coherence_dtd(threshold, smoothing, epsilon)
            % Constructor

            if nargin < 3
                epsilon = 1e-10;
            end

            obj.threshold = threshold;
            obj.smoothing = smoothing;
            obj.epsilon   = epsilon;

            obj.Pxx = [];
            obj.Pdd = [];
            obj.Pxd = [];
        end

        function is_double_talk = detect(obj, X_f, D_f)
            %DETECT  Detect double-talk using magnitude-squared coherence
            %
            % Inputs:
            %   X_f : [1 x numBins] far-end spectrum
            %   D_f : [1 x numBins] microphone spectrum
            %
            % Output:
            %   is_double_talk : boolean flag

            % Lazy initialization
            if isempty(obj.Pxx)
                obj.Pxx = zeros(size(X_f), 'single');
                obj.Pdd = zeros(size(D_f), 'single');
                obj.Pxd = complex( ...
                    zeros(size(X_f), 'single'), ...
                    zeros(size(X_f), 'single'));
            end

            % Power spectra
            abs_X2 = abs(X_f).^2;
            abs_D2 = abs(D_f).^2;

            % Cross power spectrum
            cross_XD = X_f .* conj(D_f);

            % Exponential smoothing
            obj.Pxx = obj.smoothing * obj.Pxx + ...
                      (1 - obj.smoothing) * abs_X2;

            obj.Pdd = obj.smoothing * obj.Pdd + ...
                      (1 - obj.smoothing) * abs_D2;

            obj.Pxd = obj.smoothing * obj.Pxd + ...
                      (1 - obj.smoothing) * cross_XD;

            % Magnitude-squared coherence
            coherence_numerator   = abs(obj.Pxd).^2;
            coherence_denominator = obj.Pxx .* obj.Pdd + obj.epsilon;

            coherence = coherence_numerator ./ coherence_denominator;

            avg_coherence = mean(coherence);

            % Decision logic
            is_double_talk = false;
            if avg_coherence < obj.threshold
                is_double_talk = true;
            end
        end
    end
end
