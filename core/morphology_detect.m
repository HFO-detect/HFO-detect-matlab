function [df_out]=morphology_detect(data, fs, low_fc_r, low_fc_fr, high_fc)

%% Load custom filter
load('morphology_filter.m')

input.BLmu = 0.90; % level for maximum entrophy, threshold for /mu

CDFlevelRMS = 0.95;
CDFlevelRMSFR = 0.7;

CDFlevelFiltR = 0.99;
CDFlevelFiltFR = 0.99;

input.DurThr = 0.99;
input.dur = 30; % in sec

input.CDFlevelRMS = CDFlevelRMS;
input.CDFlevelFilt = CDFlevelFiltR;

input.time_thr = 0.02;
input.maxNoisemuV = 10;

[HFOobj, results] = func_doMorphologyDetector(sig, p.hp, 'Ripple', p, input);
      
sig.THR = HFOobj.THR;
sig.THRfiltered = HFOobj.THRfiltered;

% Find peaks of HFOs
if exist('results', 'var')==1
    for iDet=1:length(results)
        if iDet==1
            sig.autoRipSta = results(iDet).start/p.fs;
            sig.autoRipEnd = results(iDet).stop/p.fs;
            
        else
            sig.autoRipSta = [sig.autoRipSta results(iDet).start/p.fs];
            sig.autoRipEnd = [sig.autoRipEnd results(iDet).stop/p.fs];
        end
    end
else
    sig.autoRipSta=0;
    sig.autoRipEnd=0;
end

% check the 0 detection
ToDelete = find(sig.autoRipSta==0);
sig.autoRipSta(ToDelete)=[];sig.autoRipEnd(ToDelete)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% look for FRs %%%%%%%%%%%%%%%%%%%%%%%%%%%%
display('***** Start Fast Ripple Detection *****')
input.time_thr = 0.01;
input.CDFlevelRMS = CDFlevelRMSFR;
input.CDFlevelFilt = CDFlevelFiltFR;

[HFOobj, results] = func_doMorphologyDetector(sig, p.hpFR, 'FastRipple', p, input);