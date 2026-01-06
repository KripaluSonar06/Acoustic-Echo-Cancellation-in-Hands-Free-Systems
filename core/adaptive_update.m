function W = adaptive_update(W, X_history, E, step_size, epsilon, adapt)
%PBFDA_NLMS_UPDATE  NLMS update for Partitioned Block Frequency Domain AF
%
% Inputs:
%   W           : [numPartitions x numBins] adaptive filter weights
%   X_history   : [numPartitions x numBins] input history (frequency domain)
%   E           : [1 x numBins] error signal (frequency domain)
%   step_size   : NLMS step size (mu)
%   epsilon     : small constant for numerical stability
%   adapt       : boolean flag (disable update during double-talk)
%
% Output:
%   W           : updated weight matrix

    % ---------------- DOUBLE-TALK FREEZE ----------------
    if ~adapt
        return;
    end

    % ---------------- NORMALIZATION TERM ----------------
    % Sum input power across partitions (per frequency bin)
    input_power = sum(abs(X_history).^2, 1);     % [1 x numBins]
    normalization = step_size ./ (input_power + epsilon);

    % ---------------- NLMS UPDATE ----------------
    numPartitions = size(W, 1);
    for p = 1:numPartitions
        W(p, :) = W(p, :) + normalization .* conj(X_history(p, :)) .* E;
        
        % Leakage / weight decay (same as Python)
        W(p, :) = W(p, :) * (1.0 - 1e-4);
    end

    % ---------------- WEIGHT NORM CLIPPING ----------------
    W_norm = norm(W(:));
    W_MAX = 50.0;

    if W_norm > W_MAX
        W = W * (W_MAX / W_norm);
    end

end
