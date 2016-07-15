% Module with signal transformations. Usually used to transform bigger pieces
% of signal (>1s). Some methods might use feature extractions.

function [hilbert_envelope]=compute_hilbert_envelope(signal)
%%
% Calcule the Hilbert envelope
% 
% Parameters:
% ----------
%   signal - numpy array
%%
hilbert_envelope = abs(hilbert(detrend(signal)));