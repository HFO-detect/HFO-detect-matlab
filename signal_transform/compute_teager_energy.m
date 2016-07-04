% Module with signal transformations. Usually used to transform bigger pieces
% of signal (>1s). Some methods might use feature extractions.

function [energy]=compute_teager_energy(signal)
%%
% Calcule the Teager energy
% 
% Parameters:
% ----------
%   signal - numpy array
%%
sqr = signal(2:end-1).^2;
odd = signal(1:end-2);
even = signal(3:end); 
energy = sqr - odd .* even;
energy = [energy(1) energy energy(end)];