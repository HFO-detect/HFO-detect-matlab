% =========================================================================
% *** Function RUN_MorphologyDetector
% *** 
% *** the automatic time-frequency algorithm for detection of HFOs
% *** the parameters and detector are the same as in publication
% *** http://www.sciencedirect.com/science/article/pii/S1388245716000092
% *** 
% *** (c)  Sergey Burnos
% *** email: sergey.burnos@gmail.com
% ***
% *** ---------------------------------------------------------------------
% *** INPUT
% *** data - EEG signal for a single channel, format 1xN double
% *** p - struct with parameters:
% *** p.fs - sampling frequency
% *** p.duration - how many seconds of data to be analyzed
% *** p.filter.path - path for the filter parameters 
% *** p.hp - high pass ripple range
% *** p.hpFR - high pass Fast ripple range
% *** p.hpFR - high pass Fast ripple range
% *** p.lp - low pass
% ***
% *** ---------------------------------------------------------------------
% *** OUTPUT
% *** results - struct with automatically detected Ripples and FRs
% *** result.signal - raw signal
% *** result.signalFilt - ripple range filtered signal
% *** result.signalFiltFR - Fast ripple range filtered signal
% *** result.duration - how many seconds of data were analyzed
% *** result.THR - Ripple, threshhold for Hilbert envelope, detection stage
% *** result.THRfiltered - Ripple, threshhold for filtered data, N consecutive oscillations, validation stage
% *** result.autoRipStart - start time for detected Ripples
% *** result.autoRipEnd - end time for detected Ripples
% *** result.THRFR - FR, threshhold for Hilbert envelope, detection stage
% *** result.THRfilteredFR - FR, threshhold for filtered data, N consecutive oscillations, validation stage
% *** result.autoFRStart - start time for detected Ripples
% *** result.autoFREnd - end time for detected Ripples
% ***
% *** ---------------------------------------------------------------------
% *** Example:
% *** 5 min of recording from human ECoG, recording channel is HL1-HL2
% *** which corresponds to bipolar montage from two electrodes placed at
% *** hippocampus left, data taken from patient 1
% *** for more details, refer to publication 1 Burnos et al., 2014
% ***
% *** load data_example
% *** example = 1;
% *** [results] = RUN_MorphologyDetector(data,example);
% *** 
% *** or use example.m file for additional visuallization of detected events
% ***
% *** ---------------------------------------------------------------------
% *** Please, cite the following publications if using the Morphology detector
% *** 1.
% *** Burnos S., Frauscher B., Zelmann R., Haegelen C., Sarnthein J., Gotman J. (2016).
% *** The morphology of high frequency oscillations (HFO) does not improve delineating the epileptogenic zone.
% *** Clinical Neurophysiology, Volume 127, Issue 4, April 2016, Pages 2140-2148, ISSN 1388-2457, http://dx.doi.org/10.1016/j.clinph.2016.01.002.
% *** 2.
% *** Burnos S., Hilfiker P., Sürücü O., Scholkmann F., Krayenbühl N., Grunwald T., Sarnthein, J. (2014). 
% *** Human Intracranial High Frequency Oscillations (HFOs) Detected by Automatic Time-Frequency Analysis. 
% *** PLoS ONE, 9(4), e94381. http://doi.org/10.1371/journal.pone.0094381

function [results] = RUN_MorphologyDetector(data, example, p)

if example
%% PARAMETERS, example
p.fs = 2000; % SAMPLING Frequency
p.duration = 300; % HOW MANY SECONDS OF DATA TO ANALYZE
p.filter.path = 'Filter_AsBurnos2016'; %  FILTER PATH for loading filter, here same filters as in Burnos et al., 2016
p.channel_name = 'XXX'; % name of the channel
p.hp = 80; % high pass ripple
p.hpFR = 250; % high pass FR
p.lp = 500; % low pass FR
%% LOAD FILTER 
load (p.filter.path)
p.filter = FilterCoeff;
end

%% DETECTION
results = func_prepareMorphologyDetector(data, p);

end
% ===================================================================================
