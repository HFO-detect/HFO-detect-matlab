% Module with signal transformations. Usually used to transform bigger pieces
% of signal (>1s). Some methods might use feature extractions.
function [stenergy]=compute_stenergy(signal,varargin)
%%
% Calcule Short Time energy -
% Dümpelmann et al, 2012.  Clinical Neurophysiology: 123 (9): 1721–31.
%
% Parameters:
% ----------
    % signal - numpy array
    % window_size = 6 (Default) - number of the points of the window
%%
if length(varargin)>=1
    window_size = varargin{1};
else window_size = 6;
end

aux = signal.^2;
window = ones(1,window_size)/(window_size);
stenergy=conv(aux, window, 'same');