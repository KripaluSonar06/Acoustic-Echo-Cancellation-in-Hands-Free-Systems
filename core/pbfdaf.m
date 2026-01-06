classdef pbfdaf < handle
    %PBFDAF  Partitioned Block Frequency Domain Adaptive Filter
    %
    % Implements frequency-domain partitioned adaptive filtering
    % used for acoustic echo cancellation

    properties
        num_partitions
        num_bins
        W           % [num_partitions x num_bins] complex weights
        X_history   % [num_partitions x num_bins] input history (frequency domain)
    end

    methods
        function obj = pbfdaf(num_partitions, fft_size)
            % Constructor

            obj.num_partitions = num_partitions;
            obj.num_bins = fft_size/2 + 1;

            obj.W = complex( ...
                zeros(num_partitions, obj.num_bins, 'single'), ...
                zeros(num_partitions, obj.num_bins, 'single'));

            obj.X_history = complex( ...
                zeros(num_partitions, obj.num_bins, 'single'), ...
                zeros(num_partitions, obj.num_bins, 'single'));
        end

        function update_input_history(obj, X_f)
            %UPDATE_INPUT_HISTORY  Update frequency-domain delay line
            %
            % Input:
            %   X_f : [1 x num_bins] current input spectrum

            if length(X_f) ~= obj.num_bins
                error('Input spectrum size %d does not match expected %d', ...
                      length(X_f), obj.num_bins);
            end

            % Shift delay line down (older blocks move down)
            obj.X_history = circshift(obj.X_history, 1, 1);

            % Insert newest block at the top
            obj.X_history(1, :) = X_f;
        end

        function Y_f = estimate_echo(obj)
            %ESTIMATE_ECHO  Partitioned convolution in frequency domain
            %
            % Output:
            %   Y_f : [1 x num_bins] estimated echo spectrum

            Y_f = sum(obj.W .* obj.X_history, 1);
        end
    end
end
