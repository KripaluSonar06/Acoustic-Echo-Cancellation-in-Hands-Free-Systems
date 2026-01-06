function E_enhanced = residual_suppressor(E_f, Y_hat_f, min_gain)
%RESIDUAL_NLP  Classical residual echo suppression (NLP) in frequency domain
%
% Inputs:
%   E_f      : error signal spectrum
%   Y_hat_f  : estimated echo spectrum
%   min_gain : minimum suppression gain (linear)
%
% Output:
%   E_enhanced : NLP-processed error spectrum

    magnitude_E = abs(E_f);
    magnitude_Y = abs(Y_hat_f);

    aggressiveness = 1.5;
    est_residual = magnitude_Y .* aggressiveness;

    epsilon = 1e-10;
    gain = (magnitude_E - est_residual) ./ (magnitude_E + epsilon);

    gain = max(min_gain, min(gain, 1.0));
    E_enhanced = E_f .* gain;
end
