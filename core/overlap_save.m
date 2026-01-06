classdef overlap_save < handle
    %OVERLAPSAVE  Overlap-Save buffering for block-based frequency-domain DSP
    %
    % Implements overlap-save buffering logic for block-based FFT processing

    properties
        block_size
        fft_size
        buffer
    end

    methods
        function obj = overlap_save(block_size, fft_size)
            % Constructor: initialize buffering system

            if fft_size < block_size
                error('FFT size %d must be >= block size %d', fft_size, block_size);
            end

            obj.block_size = block_size;
            obj.fft_size   = fft_size;
            obj.buffer     = zeros(fft_size, 1, 'single');  % column vector
        end

        function buf = process(obj, x_block)
            %PROCESS  Update buffer with new input block
            %
            % Input:
            %   x_block : [block_size x 1] input samples
            % Output:
            %   buf     : [fft_size x 1] updated overlap-save buffer

            if length(x_block) ~= obj.block_size
                error('Input block length %d does not match configured size %d', ...
                      length(x_block), obj.block_size);
            end

            % Shift buffer left by block_size (overlap-save)
            obj.buffer = circshift(obj.buffer, -obj.block_size);

            % Insert new block at the end
            obj.buffer(end - obj.block_size + 1 : end) = x_block;

            buf = obj.buffer;
        end
    end
end
