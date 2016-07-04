% Module with signal transformations. Usually used to transform bigger pieces
% of signal (>1s). Some methods might use feature extractions.
function [Rms]= compute_rms(signal)
%%
% Calcule the Root Mean Square (RMS) energy
%
% Parameters:
% ----------
    % signal - numpy array
    % window_size - number of the points of the window
%%

window_size=6;
signal=double(signal);
aux = signal.^2;
window = ones(1,window_size)/(window_size);
Rms=sqrt(conv(aux, window, 'same'));