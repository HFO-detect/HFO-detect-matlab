% Module with signal transformations. Usually used to transform bigger pieces
% of signal (>1s). Some methods might use feature extractions.
function [hilbert_energy]=compute_hilbert_energy(signal)
%%
% Calcule the Hilbert energy
%
% Parameters:
% ----------
    % signal - numpy array
%%
sig=str2num(int2str(signal));
hilbert_energy = abs(hilbert(detrend(sig,'constant'))).^2
