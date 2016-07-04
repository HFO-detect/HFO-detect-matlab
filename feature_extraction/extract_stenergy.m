% Library of functions for feature extraction
% 
% Module for feature extraxtions. Usually short pieces of signal such as HFOs
% themselves or windows of signal.

function [stenergy] = extract_stenergy(signal)
%%
% Extract Short Time energy -
% Dümpelmann et al, 2012.  Clinical Neurophysiology: 123 (9): 1721–31.
% 
% Parameters:
% ----------
%   signal - numpy array
% 
% Returns:
% -------
%   stenergy - float
%%
stenergy = mean(signal.^2);