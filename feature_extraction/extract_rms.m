% Library of functions for feature extraction
%
% Module for feature extraxtions. Usually short pieces of signal such as HFOs
% themselves or windows of signal.
function [rms]=extract_rms(signal)% window_size = 6
%%
% Extract the Root Mean Square (RMS) energy
%
% Parameters:
% ----------
    % signal - numpy array
%
% Returns:
% -------
    % rms - float
rms=sqrt(mean((signal.^2)));

