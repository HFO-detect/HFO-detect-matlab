% Module for threshold calculation.
function [ths_value]=th_percentile(signal,ths)
%%
% Calculate threshold bz Turkey method.
% 
% Parameters:
% -----------
%     signal - numpy array
%     ths - percentile
%     
% Returns:
% -----------
%     ths_value - value of the threshold
%%
ths_value = signal*(ths/100);