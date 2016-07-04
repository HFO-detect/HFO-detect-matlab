% Module for threshold calculation.

function [ths_value]=th_std(signal,ths)
%% 
% Calcule threshold by Standar Desviations above the mean 
%
% Parameters:
% ----------
    % signal - numpy arrray
    % ths - number of SD above the mean
%  
% Returns:
% ----------
    % ths_value - value of threshold
%%
signal=double(signal);
ths_value=mean(signal)+ths*std(signal);