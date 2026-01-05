function y = pre_emphasis(x, alpha)
%PRE_EMPHASIS  Apply pre-emphasis filter
%
% y[n] = x[n] - alpha*x[n-1]

    if nargin < 2
        alpha = 0.97;
    end

    y = zeros(size(x), 'single');
    y(1) = x(1);
    y(2:end) = x(2:end) - alpha * x(1:end-1);
end
