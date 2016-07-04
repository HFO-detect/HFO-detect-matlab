% Module for threshold calculation.

function [ths_value]= th_quian(signal,ths)
%%
% Calcule threshold bz Quian
% Quian Quiroga, R. 2004. Neural Computation 16: 1661-87.
%
% Parameters:
% ---------
    % signal - numpy array
    % ths - number of estimated noise SD above the mean
% Returns:
% ----------
    % ths_value - value of the threshold
%%
ths_value=ths*median(abs(signal))/0.6745