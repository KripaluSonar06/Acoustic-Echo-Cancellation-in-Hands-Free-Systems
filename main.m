function main()
% MAIN  Acoustic Echo Cancellation using Pure DSP

    clc;
    fprintf("Generating Test Signals...\n");

    % -------------------------------------------------
    % Add all folders to MATLAB path
    % -------------------------------------------------
    addpath(genpath(pwd));

    % ---------------- LOAD CONFIG ----------------
    cfg = aec_config();

    % ---------------- TEST SIGNALS ----------------
    [far_end, mic_signal, clean_near_end, echo_component] = ...
        generate_test_signals(5.0, cfg.SAMPLE_RATE);

    far_end        = pre_emphasis(far_end, 0.97);
    mic_signal     = pre_emphasis(mic_signal, 0.97);
    echo_component = pre_emphasis(echo_component, 0.97);

    num_blocks = floor(length(far_end) / cfg.BLOCK_SIZE);
    fprintf("Total Blocks to process: %d\n", num_blocks);

    % ---------------- INITIALIZATION ----------------
    os_far = overlap_save(cfg.BLOCK_SIZE, cfg.FFT_SIZE);
    os_mic = overlap_save(cfg.BLOCK_SIZE, cfg.FFT_SIZE);

    pbfdaf_state = pbfdaf(cfg.NUM_PARTITIONS, cfg.FFT_SIZE);

    dtd_state = coherence_dtd(cfg.DTD_COHERENCE_THRESHOLD, ...
                              cfg.DTD_SMOOTHING_FACTOR);

    num_bins = cfg.FFT_SIZE/2 + 1;
    smooth_state = smoothing(num_bins, 0.7);

    output_signal = zeros(size(mic_signal));
    dtd_log = false(num_blocks,1);

    fprintf("Starting Offline Processing...\n");

    % ---------------- BLOCK LOOP ----------------
    for i = 1:num_blocks

        idx_start = (i-1)*cfg.BLOCK_SIZE + 1;
        idx_end   = idx_start + cfg.BLOCK_SIZE - 1;

        x_block = far_end(idx_start:idx_end);
        d_block = mic_signal(idx_start:idx_end);

        [x_buf, os_far] = overlap_save('process', os_far, x_block);
        [d_buf, os_mic] = overlap_save('process', os_mic, d_block);

        X_f = fft(x_buf, cfg.FFT_SIZE);
        X_f = X_f(1:num_bins);

        D_f = fft(d_buf, cfg.FFT_SIZE);
        D_f = D_f(1:num_bins);

        [is_double_talk, dtd_state] = ...
            coherence_dtd('detect', dtd_state, X_f, D_f);
        dtd_log(i) = is_double_talk;

        pbfdaf_state = pbfdaf('update_input', pbfdaf_state, X_f);
        Y_hat_f = pbfdaf('estimate', pbfdaf_state);

        % -------- IFFT echo estimate --------
        Y_hat_full = real(ifft([Y_hat_f; conj(Y_hat_f(end-1:-1:2))], ...
                                cfg.FFT_SIZE));

        valid_start = cfg.FFT_SIZE - cfg.BLOCK_SIZE + 1;
        e_full = d_buf - Y_hat_full;

        E_f = fft(e_full, cfg.FFT_SIZE);
        E_f = E_f(1:num_bins);

        % ---------------- STEP SIZE ----------------
        mu = cfg.STEP_SIZE;
        if i > 80 && mean(abs(E_f).^2) < 1e-3
            mu = 0.3 * mu;
        end

        % ---------------- NLMS UPDATE ----------------
        if ~is_double_talk
            pbfdaf_state = adaptive_update( ...
                pbfdaf_state, X_f, E_f, mu, cfg.EPSILON);
        end

        % ---------------- NLP ----------------
        [E_enhanced_f, smooth_state] = residual_suppressor( ...
            E_f, Y_hat_f, smooth_state, cfg);

        E_full = real(ifft([E_enhanced_f; conj(E_enhanced_f(end-1:-1:2))], ...
                           cfg.FFT_SIZE));

        output_signal(idx_start:idx_end) = E_full(valid_start:end);
    end

    fprintf("Processing Completed\n");

    % ---------------- ERLE ----------------
    block_energy = zeros(num_blocks,1);
    for i = 1:num_blocks
        idx = (i-1)*cfg.BLOCK_SIZE + (1:cfg.BLOCK_SIZE);
        block_energy(i) = mean(far_end(idx).^2);
    end

    active_blocks = block_energy > 0.1 * max(block_energy);
    active_blocks(1:floor(0.5*cfg.SAMPLE_RATE/cfg.BLOCK_SIZE)) = false;

    active_mask = repelem(active_blocks, cfg.BLOCK_SIZE);
    active_mask = active_mask(1:length(far_end));

    final_erle = erle(echo_component(active_mask), ...
                      output_signal(active_mask));

    % ---------------- RESULTS ----------------
    fprintf("\nResults Summary\n");
    fprintf("Sample Rate        : %d Hz\n", cfg.SAMPLE_RATE);
    fprintf("Block Size         : %d\n", cfg.BLOCK_SIZE);
    fprintf("Double Talk Blocks : %d\n", sum(dtd_log));
    fprintf("Global ERLE (ST)   : %.2f dB\n", final_erle);
end
