% Library of functions for simulated data creation

function [wave, time] = wavelet_spike(varargin)

% Create a wavelet spike.
% 
% Parameters:
% ----------
% srate = 2000 (Default)
% f = None (Default) - Create a random Spike with central frequency between 60-600 Hz.
% numcycles = None (Default) - Create a random Spike with numcycles between 1 - 2.
% 
% Returns:
% ----------
% wave - numpy array with waveform.
% time - numpy array with the time vector.

%%
if length(varargin)>=3
    srate = varargin{1};
    f = varargin{2};
    numcycles = varargin{3};
elseif length(varargin)==2
    srate = varargin{1};
    f = varargin{2};
    numcycles = 0;
elseif length(varargin)==1
    srate = varargin{1};
    f = 0;
    numcycles = 0;
else
    srate = 2000;
    f = 0;
    numcycles = 0;
end

%%
if numcycles == 0
    numcycles = randi([1 3]);
end
if f == 0
    f = randi([60 600]);
end

[wave, time] = wavelet(numcycles,f,srate);
wave = -real(wave);