classdef smoothing < handle
    %GAINSMOOTHER  Temporal exponential smoothing for frequency-domain gains
    %
    % Applies exponential moving average (EMA) to NLP gain vectors

    properties
        num_bins
        alpha
        prev_gain
    end

    methods
        function obj = smoothing(num_bins, alpha)
            % Constructor

            if nargin < 2
                alpha = 0.6;
            end

            obj.num_bins  = num_bins;
            obj.alpha     = alpha;
            obj.prev_gain = ones(1, num_bins, 'single');
        end

        function smoothed_gain = smooth(obj, current_gain)
            %SMOOTH  Apply exponential smoothing to gain vector
            %
            % Input:
            %   current_gain : [1 x num_bins] instantaneous gain
            %
            % Output:
            %   smoothed_gain : [1 x num_bins] smoothed gain

            if length(current_gain) ~= obj.num_bins
                error('Input gain size %d does not match initialized size %d', ...
                      length(current_gain), obj.num_bins);
            end

            smoothed_gain = obj.alpha * obj.prev_gain + ...
                            (1 - obj.alpha) * current_gain;

            obj.prev_gain = smoothed_gain;
        end
    end
end
