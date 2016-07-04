% Library of functions for feature extraction
% 
% Module for feature extraxtions. Usually short pieces of signal such as HFOs
% themselves or windows of signal.

function [energy] = extract_teager_energy(signal)
%%
% Extract the Teager energy
%
% Parameters:
% ----------
%   signal - numpy array
%%
sqr = signal(2:end-1).^2;
odd = signal(1:end-2);
even = signal(3:end); % This triplicates the signal not sure about memory here.
energy = sqr - odd .* even;
energy = [energy(1) energy energy(end)];
