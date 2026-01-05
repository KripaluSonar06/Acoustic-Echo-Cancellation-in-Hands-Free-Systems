function main()

    fprintf("Generating Test Signals...\n");

    [far_end, mic_signal, clean_near_end, echo_component] = ...
        generate_test_signals(5.0, cfg.SAMPLE_RATE);

    far_end        = pre_emphasis(far_end, 0.97);
    mic_signal     = pre_emphasis(mic_signal, 0.97);
    echo_component = pre_emphasis(echo_component, 0.97);

    num_blocks = floor(length(far_end) / cfg.BLOCK_SIZE);
    fprintf("Total Blocks to process: %d\n", num_blocks);

    % ---------------- INITIALIZATION ----------------

    os_far_end = OverlapSave(cfg.BLOCK_SIZE, cfg.FFT_SIZE);
    os_mic     = OverlapSave(cfg.BLOCK_SIZE, cfg.FFT_SIZE);

    pbfdaf = PBFDAF(cfg.NUM_PARTITIONS, cfg.FFT_SIZE);

    dtd = CoherenceDTD(cfg.DTD_COHERENCE_THRESHOLD, ...
                       cfg.DTD_SMOOTHING_FACTOR);

    num_bins = cfg.FFT_SIZE/2 + 1;
    gain_smoother = GainSmoother(num_bins, 0.7);

    output_signal = zeros(size(mic_signal));
    dtd_log = false(num_blocks,1);

    fprintf("Starting Offline Processing...\n");

    % ---------------- BLOCK PROCESSING LOOP ----------------
    for i = 1:num_blocks

        idx_start = (i-1)*cfg.BLOCK_SIZE + 1;
        idx_end   = idx_start + cfg.BLOCK_SIZE - 1;

        x_block = far_end(idx_start:idx_end);
        d_block = mic_signal(idx_start:idx_end);

        x_time_buf = os_far_end.process(x_block);
        d_time_buf = os_mic.process(d_block);

        X_f = fft(x_time_buf, cfg.FFT_SIZE);
        X_f = X_f(1:num_bins);

        D_f = fft(d_time_buf, cfg.FFT_SIZE);
        D_f = D_f(1:num_bins);

        is_double_talk = dtd.detect(X_f, D_f);
        dtd_log(i) = is_double_talk;

        pbfdaf.update_input_history(X_f);
        Y_hat_f = pbfdaf.estimate_echo();

        % IFFT (full spectrum reconstruction)
        Y_hat_full = real(ifft([Y_hat_f; conj(Y_hat_f(end-1:-1:2))], ...
                                cfg.FFT_SIZE));

        valid_start = cfg.FFT_SIZE - cfg.BLOCK_SIZE + 1;
        y_hat_block = Y_hat_full(valid_start:end);

        e_full = d_time_buf - Y_hat_full;

        E_f = fft(e_full, cfg.FFT_SIZE);
        E_f = E_f(1:num_bins);

        % ---------------- STEP SIZE CONTROL ----------------
        mu = cfg.STEP_SIZE;

        if i > 80
            error_power = mean(abs(E_f).^2);
            if error_power < 1e-3
                mu = 0.3 * mu;
            end
        end

        % ---------------- NLMS UPDATE ----------------
        pbfda_nlms_update( ...
            pbfdaf.W, ...
            pbfdaf.X_history, ...
            E_f, ...
            mu, ...
            cfg.EPSILON, ...
            ~is_double_talk ...
        );

        % ---------------- NLP ----------------
        epsilon = 1e-10;

        mag_E = abs(E_f);
        mag_Y = abs(Y_hat_f);

        est_residual = cfg.NLP_AGGRESSIVENESS .* mag_Y;
        raw_gain = (mag_E - est_residual) ./ (mag_E + epsilon);
        raw_gain = max(cfg.NLP_MIN_GAIN_LINEAR, min(raw_gain, 1.0));

        smoothed_gain = gain_smoother.smooth(raw_gain);

        E_enhanced_f = E_f .* smoothed_gain;

        E_full = real(ifft([E_enhanced_f; conj(E_enhanced_f(end-1:-1:2))], ...
                           cfg.FFT_SIZE));

        e_final_block = E_full(valid_start:end);

        output_signal(idx_start:idx_end) = e_final_block;
    end

    fprintf("Processing Completed\n");

    % ---------------- ERLE COMPUTATION ----------------

    block_energy = zeros(num_blocks,1);
    for i = 1:num_blocks
        idx_start = (i-1)*cfg.BLOCK_SIZE + 1;
        idx_end   = idx_start + cfg.BLOCK_SIZE - 1;
        block_energy(i) = mean(far_end(idx_start:idx_end).^2);
    end

    energy_threshold = 0.1 * max(block_energy);
    active_blocks = block_energy > energy_threshold;

    conv_blocks = floor(0.5 * cfg.SAMPLE_RATE / cfg.BLOCK_SIZE);
    active_blocks(1:conv_blocks) = false;

    active_mask = repelem(active_blocks, cfg.BLOCK_SIZE);

    if length(active_mask) < length(far_end)
        active_mask(end+1:length(far_end)) = false;
    end

    echo_ref_st = echo_component(active_mask);
    residual_st = output_signal(active_mask);

    final_erle = compute_erle(echo_ref_st, residual_st);

    % ---------------- RESULTS ----------------
    fprintf("\nResults Summary\n");
    fprintf("Sample Rate          : %d Hz\n", cfg.SAMPLE_RATE);
    fprintf("Block Size           : %d\n", cfg.BLOCK_SIZE);
    fprintf("Double-Talk Blocks   : %d\n", sum(dtd_log));
    fprintf("Global ERLE (ST)     : %.2f dB\n", final_erle);

end
