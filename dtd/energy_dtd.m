classdef energy_dtd < handle
    %ENERGYDTD  Simple energy-based Double Talk Detector
    %
    % Detects double-talk based on ratio of error energy
    % to far-end reference energy

    properties
        threshold
        epsilon
    end

    methods
        function obj = energy_dtd(threshold, epsilon)
            % Constructor

            if nargin < 1
                threshold = 1.0;
            end
            if nargin < 2
                epsilon = 1e-10;
            end

            obj.threshold = threshold;
            obj.epsilon   = epsilon;
        end

        function is_double_talk = detect(obj, x_energy, e_energy)
            %DETECT  Detect double-talk based on energy ratio
            %
            % Inputs:
            %   x_energy : energy of far-end reference
            %   e_energy : energy of error / mic signal
            %
            % Output:
            %   is_double_talk : boolean flag

            % Guard against silence / division instability
            if x_energy < obj.epsilon
                is_double_talk = true;
                return;
            end

            is_double_talk = false;
            if e_energy > obj.threshold * x_energy
                is_double_talk = true;
            end
        end
    end
end
