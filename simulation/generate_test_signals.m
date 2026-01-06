function [far_end, mic_signal, clean_near_end, echo_component] = ...
         generate_test_signals(duration_sec, fs, rir_length_sec)
%GENERATE_TEST_SIGNALS  Generate synthetic signals for AEC testing

    if nargin < 3
        rir_length_sec = 0.1;
    end

    rng(42);   % Fixed seed for reproducibility
    total_samples = round(duration_sec * fs);

    % -------- Load far-end speech --------
    [speech, fs_speech] = audioread('simulation/speech_farend.wav');
    assert(fs_speech == fs, 'Speech file must be %d Hz', fs);

    if size(speech,2) > 1
        speech = speech(:,1);
    end

    % Loop speech if too short
    if length(speech) < total_samples
        reps = ceil(total_samples / length(speech));
        speech = repmat(speech, reps, 1);
    end

    far_end = single(speech(1:total_samples));
    far_end = far_end ./ (max(abs(far_end)) + 1e-10);

    % -------- Simulated room impulse response --------
    rir_samples = round(rir_length_sec * fs);
    t = linspace(0, rir_length_sec, rir_samples);

    envelope = exp(-30 * t);
    rir = envelope(:) .* randn(rir_samples, 1);
    rir = rir / norm(rir);

    % -------- Echo path --------
    echo_full = conv(far_end, rir, 'full');
    echo_component = single(echo_full(1:total_samples));

    % -------- Near-end & noise --------
    clean_near_end = zeros(total_samples, 1, 'single');

    dt_start = round(0.4 * total_samples);
    dt_end   = round(0.6 * total_samples);

    % Optional double-talk 
    % clean_near_end(dt_start:dt_end) = 0.3 * randn(dt_end-dt_start+1,1);

    background_noise = single(0.001 * randn(total_samples,1));

    mic_signal = echo_component + clean_near_end + background_noise;
end
