% Module with signal transformations. Usually used to transform bigger pieces
% of signal (>1s). Some methods might use feature extractions.

function [data]=compute_line_lenght(signal)
%%
% Calcule Short time line leght -
% Dümpelmann et al, 2012.  Clinical Neurophysiology: 123 (9): 1721–31.
% 
% Parameters:
% ----------
%   signal - numpy array
%   window_size - number of the points of the window
%%
signal=double(signal);
window_size=6;  
aux = abs(diff(signal));
window = ones(1,window_size)/window_size;
data = conv(aux,window,'same');
data = [data data(end)];
