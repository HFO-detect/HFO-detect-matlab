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
hilbert_energy = abs(hilbert(detrend(signal)).^2);
