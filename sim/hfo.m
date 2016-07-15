% Library of functions for simulated data creation

function [wave,time] = hfo(varargin)

% Create a HFO.
% 
% Parameters:
% ----------
% srate = 2000 (Default)
% f = None (Default) - Create a random HFO with central frequency between 60-600 Hz.
% numcycles = None (Default) - Create a random HFO with numcycles between 9 - 14.
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
    numcycles = randi([9 15]);
end
if f ==0
    f = randi([60 600]);
end

[wave, time] = wavelet(numcycles,f,srate);
wave = real(wave);