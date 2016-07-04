% Library of functions for feature extraction
%
% Module for feature extraxtions. Usually short pieces of signal such as HFOs
% themselves or windows of signal.
function [stenergy]= extract_line_lenght(signal)
%%
% Extract Short time line leght -
% Gardner er al, 2006.  Clinical Neurophysiology: 118 (5): 1134–43.
% Note:
% ----
    % There is a slight difference between extract LL and compute LL.
%
% Parameters:
% ----------
    % signal - numpy array
%
% Returns:
% -------
    % stenergy - float
%%
stenergy= sum(abs(diff(signal)));

