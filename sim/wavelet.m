% Library of functions for simulated data creation

function [wave, time] = wavelet(numcycles,f,srate)

% Create a wavelet
% 
% Parameters:
% ----------
% numcycles - number of cycles (gaussian window)
% f - central frequency
% srate - signal sample rate
% 
% Returns:
% ----------
% wave - numpy array with waveform.
% time - numpy array with the time vector.

N = (2*srate*numcycles)/f; % number of points
time = linspace(-numcycles/f,numcycles/f,N); % time vector
std = numcycles/(2*pi*f);
wave = exp(2*1j*pi*f*time).*exp(-(time.^2)/(2*(std.^2))); % waveform