% Library of functions for feature extraction
%
% Module for feature extraxtions. Usually short pieces of signal such as HFOs
% themselves or windows of signal.
function [rms]=extract_rms(signal,varargin)
%%
% Extract the Root Mean Square (RMS) energy
%
% Parameters:
% ----------
% signal - numpy array
% window_size - 6 (Default)
%
% Returns:
% -------
% rms - float

if length(varargin)>=1
    window_size = varargin{1};
else window_size = 6;
end

rms=sqrt(mean((signal.^2)));

