function erle_db = erle(echo_signal, error_signal)
%COMPUTE_ERLE  Compute Echo Return Loss Enhancement (ERLE)
%
% Inputs:
%   echo_signal  : reference echo signal
%   error_signal : residual error after echo cancellation
%
% Output:
%   erle_db      : ERLE in dB

    epsilon = 1e-10;

    power_echo  = mean(echo_signal .^ 2);
    power_error = mean(error_signal .^ 2);

    erle_db = 10 * log10((power_echo + epsilon) / ...
                         (power_error + epsilon));
end
