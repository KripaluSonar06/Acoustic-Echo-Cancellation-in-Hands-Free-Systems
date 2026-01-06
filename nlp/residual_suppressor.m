function gain = residual_suppressor(E_f, Y_hat_f, min_gain)
%RESIDUAL_SUPPRESSOR  Compute NLP gain (no smoothing)
%
% Inputs:
%   E_f      : error spectrum [numBins x 1]
%   Y_hat_f  : estimated echo spectrum [numBins x 1]
%   min_gain : minimum allowed gain (linear)
%
% Output:
%   gain     : instantaneous suppression gain [1 x numBins]

    magnitude_E = abs(E_f(:)).';
    magnitude_Y = abs(Y_hat_f(:)).';

    aggressiveness = 0.6;
    est_residual = magnitude_Y * aggressiveness;

    epsilon = 1e-10;
    gain = (magnitude_E - est_residual) ./ (magnitude_E + epsilon);

    gain = min(max(gain, min_gain), 1.0);
end
