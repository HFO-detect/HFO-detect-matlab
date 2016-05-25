% ===================================================================================
% *** Function DETECTOR MCGILL

function [sig ] = func_prepareMorphologyDetector(data, p)
p.limitFrequencyST = p.lp;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% reading the signals
display(['%%%%%%%%%%%%% START ANALYSIS ' datestr(now,'dd-mm-yyyy HH-MM-SS') ' %%%%%%%%%%%%%%%%'])
display(' ')

%% read visual markings and filter data
sig=struct;

display(['Length Extracted Data = ' num2str(length(data))])

sig.signal = data;
sig.signalFilt = filtfilt(p.filter.Rb, p.filter.Ra, sig.signal);
sig.signalFiltFR = filtfilt(p.filter.FRb, p.filter.FRa, sig.signal);
sig.duration = p.duration;

%% %%%%%%%%---- AUTOMATIC DETECTION ----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% look for ripples %%%%%%%%%%%%%%%%%%%%%%%%
display('***** Start Ripple Detection *****')
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

sig.THRFR = HFOobj.THR;
sig.THRfilteredFR = HFOobj.THRfiltered;

% Find peaks of HFOs
if exist('results', 'var')==1
    for iDet=1:length(results)
        if iDet==1
            sig.autoFRSta = results(iDet).start/p.fs;
            sig.autoFREnd = results(iDet).stop/p.fs;
            
        else
            sig.autoFRSta = [sig.autoFRSta results(iDet).start/p.fs];
            sig.autoFREnd = [sig.autoFREnd results(iDet).stop/p.fs];
        end
    end
else
    sig.autoFRSta=0;
    sig.autoFREnd=0;
end
% check the 0 detection
ToDelete = find(sig.autoFRSta==0);
sig.autoFRSta(ToDelete)=[];sig.autoFREnd(ToDelete)=[];

display(['%%%%%%%%%%%%% END ANALYSIS ' datestr(now,'dd-mm-yyyy HH-MM-SS') ' %%%%%%%%%%%%%%%%'])

end

% % ===================================================================================
% % *** END of FUNCTION Morphology DETECTOR
% % ===================================================================================
