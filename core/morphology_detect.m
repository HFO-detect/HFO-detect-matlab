function [df_out]=morphology_detect(data, fs, low_fc, high_fc)

    %% Load custom filter
    load('morphology_filter.m')

    %% Create output dataframe 
    [df_out] = create_output_df(struct('peak','double','peak_amp','double')); 

    %% Default values

    bl_mu = .9;
    cdf_rms = .95;
    cdf_filt = .99;
    bs_dur = 30;
    dur_th = .99;
    time_th = .02;
    max_noise_uv = 10.;
    max_amp = 30.;
    max_gap = .02;
    min_N_osc = 6;

    %% Define additional parameters



    smooth_window = 1 / high_fc;

    %% 1) filtering
    if low_fc == 80
        b = FilterCoeff.Rb;
        a = FilterCoeff.Ra;
    elseif low_fc == 250
        b = FilterCoeff.FRb;
        a = FilterCoeff.FRa;
    end

    filt_data = filtfilt(b, a, data);

    %% 2) envelope

    env = smooth(abs(hilbert(filt_data)), smooth_window*fs);


    %% 3) thredhold

    res = baselinethreshold(data, filt_data, env,bs_dur, bl_mu, bl_border, bl_mindist, max_noise_uv, cdf_rms, cdf_filt, fs, low_fc, high_fc);
    thr = res(1);
    thr_filt = res(2);
    indHighEntr = res(3);

    if (lenght(indHighEntr) < 2*fs)
        disp('!!! Shor baseline !!!')
    end

    %% 4) Stage I

    env(1)=0; env(length(env))=0; % assign the first and last positions at 0 point

    pred_env(2:length(env))=env(1:length(env)-1);
    pred_env(1)=pred_env(2);
    if size(pred_env,1)~=size(env,1) % check the size if it's not been transposed
        pred_env=pred_env';
    end

    t1=find(pred_env<(thr*dur_th) & env>=(thr*dur_th));    % find zero crossings rising
    t2=find(pred_env>(thr*dur_th) & env<=(thr*dur_th));    % find zero crossings falling

    trig=find(pred_env<thr & env>=thr); % check if envelope crosses the THR level rising
    trig_end=find(pred_env>=thr & env<thr); % check if envelope crosses the THR level falling

    % initialize struct

    % check every trigger point, where envelope crosses the threshold,
    % find start and end points (t1 and t2), t2-t1 = duration of event;
    % start and end points defined as the envelope crosses half of the
    % threshold for each EoIs

    det_cnt = 0;

    for i=1:numel(trig)

        % check for time threshold duration, all times are in pt
        if trig_end(i)-trig(i) >= time_th

            det_cnt = det_cnt + 1;
            k=find(t1<=trig(i) & t2>=trig(i)); % find the starting and end points of envelope

            % check if it does not start before 0 moment
            if t1(k)>0
                event_start = t1(k);
            else
                event_start = 1;
            end

            % check if it does not end after last moment
            if t2(k) <= length(env)
                event_stop = t2(k);
            else
                event_stop = length(env);
            end

            [ peakAmplitude , ind_peak ]   = max(env(t1(k):t2(k)));

            peak_ind = (ind_peak + t1(k));
            peak_amp = peakAmplitude;

            % check if the peak Amplitude below the maximum
            if peak_amp>max_amp
                continue
            end          

            df_out.event_start =[df_out.event_start event_start];
            df_out.event_stop = [df_out.event_stop event_stop];
            df_out.peak =[df_out.peak peak_ind];
            df_out.peak_amp = [df_out.peak_amp peak_amp];

        end
    end

    if det_cnt > 0

        %% 5) Check number of oscillations

        df_out = check_oscillations(df_out, filt_data, thr_filt, min_N_osc);


        %% 6) Merge detections
        df_out = join_detections(df_out, max_gap, fs);

    end

end


% =========================================================================
function [joined_df_out] = join_detections(df_out, max_gap, fs)

N_det_c = 0;
max_gap = max_gap * fs;

joined_df_out = df_out(1);

for n = 2 : length(df_out)
    
    % join detection
    if df_out(n).event_start > joined_df_out(N_det_c).event_stop
        
        n_diff = df_out(n).event_start - joined_df_out(N_det_c).event_stop;
        
        if n_diff < max_gap
            
            joined_df_out(N_det_c).event_stop = df_out(n).event_stop;
            
            if joined_df_out(N_det_c).peak_amp < df_out(n).peak_amp
                
                joined_df_out(N_det_c).peak_amp = df_out(n).peak_amp;
                joined_df_out(N_det_c).peak = df_out(n).peak;
                
            end
            
        else
            
            % initialize struct
            N_det_c = N_det_c + 1;
            joined_df_out(N_det_c) = df_out(n);
            
        end
    end
end

end



% =========================================================================
function [df_out] = check_oscillations(df_out, filt_data, thr_filt, min_N_osc)

% Reject events not having a minimum of 8 peaks above threshold
% ---------------------------------------------------------------------
% set parameters

rejected_idcs = [];

for n = 1 : length(df_out)
        
    %detrend data
    to_detrend = 0;
    
    % get EEG for interval
    intervalEEG = filt_data(df_out(n).event_start : df_out(n).event_stop)-to_detrend;
    
    % compute abs values for oscillation interval
    absEEG = abs(intervalEEG);
    
    % look for zeros
    zeroVec=find(intervalEEG(1:end-1).*intervalEEG(2:end)<0);
    nZeros=numel(zeroVec);
    
    N_MaxCounter = zeros(1,nZeros-1);
    
    if nZeros > 0
        
        % look for maxima with sufficient amplitude between zeros
        for iZeroCross = 1 : nZeros-1
            
            lStart = zeroVec(iZeroCross);
            lEnd   = zeroVec(iZeroCross+1);
            dMax = max(absEEG(lStart:lEnd));
            
            if dMax > thr_filt;
                
                N_MaxCounter(iZeroCross) = 1;
            else
                N_MaxCounter(iZeroCross) = 0;
                
            end
        end
        
    end
    
    % Inversed logic from the original code - more readable, less confusing
    
    
    N_MaxCounter = [0 N_MaxCounter 0]; %#ok<*AGROW>
    
    if ~any(diff(find(N_MaxCounter==0))>min_N_osc)
        rejected_idcs = [rejected_idcs n];
    end
    
    
    
end

    df_out = df_out(~rejected_idcs);

end


% ===================================================================================
function [thr,thr_filt,indHighEntr] = baselinethreshold(data, filt_data, env,bs_dur, bl_mu, bl_border, bl_mindist, max_noise_uv, cdf_rms, cdf_filt, fs, low_fc, high_fc)

% distinguish background activity from spikes-HFO-artifacts
% according to Stockwell entrophy
% ref: wavelet entrophy: a new tool for analysis...
% Osvaldo a. Rosso et al, journal of neuroscience methods, 2000

% -------------------------------------------------------------------------
% parameters
indHighEntr=[];
S(fs)=0;

% check duration
if bs_dur>length(sigfull)/fs
    bs_dur=floor(length(sigfull)/HFOobj.fs);
end

% -------------------------------------------------------------------------
for sec=1:floor(bs_dur) % calculate ST for every second
    
    signal = data(1+(sec-1)*fs:sec*fs); % read signal by one sec
    
    % ------------------------------------------------------------
    % S transform
    [STdata, ~ , ~] = st(signal, low_fc, high_fc, 1/fs, 1); % S-transform
    stda=abs(STdata(:,:)).^2;
    
    %     [STdata, t , f] = st(signal, HFOobj.BLst_freq, HFOobj.lp, 1/HFOobj.fs, 1); % S-transform
    %     Clim=[0 20];
    %     imagesc(t,f, stda, Clim)
    %     set(gca,'YDir','normal');
    % %
    
    % ------------------------------------------------------------
    % Stockwell entrophy
    % total energy
    std_total=sum(stda,1);
    
    % relative energy
    prob = bsxfun(@rdivide, stda, std_total);
    
    % total entropy
    for ifr=1:size(stda,2) % for all frequency from 81 to 500
        S(ifr)=-sum(prob(:, ifr).*log(prob(:, ifr)));
    end
    Smax=log(size(stda, 1)); % maximum entrophy = log(f_ST), /mu in mni,
    
    % ------------------------------------------------------------
    % threshold and baseline
    thr=bl_mu*Smax; % threshold at mu*Smax, in mni BLmu=0.67
    indAboveThr=find(S>thr); % find pt with high entrophy
    
    if isempty(indAboveThr)~=1
        
        % dont take border points because of stockwell transf
        indAboveThr(indAboveThr<fs*bl_border)=[];
        indAboveThr(indAboveThr>fs*(1-bl_border))=[];
        
        if isempty(indAboveThr)~=1
            
            % ------------------------------------------------------------
            % check for the length
            indAboveThrN=indAboveThr(2:end);
            indBrake=find(indAboveThrN(1:end)-indAboveThr(1:end-1)>1);
            % check if it starts already above or the last point is abover the threshold
            if indAboveThr(1)==fs*bl_border
                indBrake=[1 indBrake];
            end
            if indAboveThr(end)==fs*(1-bl_border)
                indBrake=[indBrake length(indAboveThr)];
            end
            
            if isempty(indBrake)==1
                indBrake=length(indAboveThr);
            end
%             per.baseline{1}=env(indAboveThr(1)+(sec-1)*HFOobj.fs:indAboveThr(indBrake(1))+(sec-1)*HFOobj.fs);
%             indHighEntr
%             per.baseline{1}=env(indAboveThr(1)+(sec-1)*HFOobj.fs:indAboveThr(indBrake(2))+(sec-1)*HFOobj.fs);
%             per.mean{1}  = mean(per.baseline{1});
%             per.sd{1}  = std(per.baseline{1});
            
            for iper=1:length(indBrake)-1             
                j=indBrake(iper)+1:indBrake(iper+1);
                if (length(j)>=bl_mindist) 
                    indAboveThr(j)= indAboveThr(j)+(sec-1)*fs;
                    if sum(abs(filt_data(indAboveThr(j)))>max_noise_uv)==0 % check that filtered signal is below max Noise level
                        indHighEntr   = [indHighEntr indAboveThr(j)]; 
                    end  
                end
            end
        end
    end
    clearvars -except  indHighEntr sigfull sec S env HFOobj sigfiltered
    
end
display(['For ' num2str(floor(bl_dur)) ' sec, baseline length = ' num2str(length(indHighEntr)) ])


%%%%%%%%%%%%%%% check one more time if the lentgh of baseline is too small
if length(indHighEntr)<2*fs % then take all 5 minutes
    display('Baseline length < 2 sec, calculating for 5 min ')
    
    for sec=floor(bl_dur)+1:floor(length(sigfull)/fs) % calculate ST for every second
    
        signal = data(1+(sec-1)*fs:sec*fs); % read signal by one sec

        % ------------------------------------------------------------
        % S transform
        [STdata, ~ , ~] = st(signal, low_fc, high_fc, 1/fs, 1); % S-transform
        stda=abs(STdata(:,:)).^2;

%             [STdata, t , f] = st(signal, HFOobj.BLst_freq, HFOobj.lp, 1/HFOobj.fs, 1); % S-transform
%             Clim=[0 20];
%             imagesc(t,f, stda, Clim)
%             set(gca,'YDir','normal');
        % %

        % ------------------------------------------------------------
        % Stockwell entrophy
        % total energy
        std_total=sum(stda,1);

        % relative energy
        prob = bsxfun(@rdivide, stda, std_total);

        % total entropy
        for ifr=1:size(stda,2) % for all frequency from 81 to 500
            S(ifr)=-sum(prob(:, ifr).*log(prob(:, ifr)));
        end
        Smax=log(size(stda, 1)); % maximum entrophy = log(f_ST), /mu in mni,

        % ------------------------------------------------------------
        % threshold and baseline
        thr=bl_mu*Smax; % threshold at mu*Smax, in mni BLmu=0.67
        indAboveThr=find(S>thr); % find pt with high entrophy

        if isempty(indAboveThr)~=1

            % dont take border points because of stockwell transf
            indAboveThr(indAboveThr<fs*bl_border)=[];
            indAboveThr(indAboveThr>fs*(1-HFOobj.bl_border))=[];

            if isempty(indAboveThr)~=1

                % ------------------------------------------------------------
                % check for the length
                indAboveThrN=indAboveThr(2:end);
                indBrake=find(indAboveThrN(1:end)-indAboveThr(1:end-1)>1);
                % check if it starts already above or the last point is abover the threshold
                if indAboveThr(1)==fs*bl_border
                    indBrake=[1 indBrake];
                end
                if indAboveThr(end)==fs*(1-bl_border)
                    indBrake=[indBrake length(indAboveThr)];
                end

                if isempty(indBrake)==1
                    indBrake=length(indAboveThr);
                end
    %             per.baseline{1}=env(indAboveThr(1)+(sec-1)*HFOobj.fs:indAboveThr(indBrake(1))+(sec-1)*HFOobj.fs);
    %             indHighEntr
    %             per.baseline{1}=env(indAboveThr(1)+(sec-1)*HFOobj.fs:indAboveThr(indBrake(2))+(sec-1)*HFOobj.fs);
    %             per.mean{1}  = mean(per.baseline{1});
    %             per.sd{1}  = std(per.baseline{1});

                for iper=1:length(indBrake)-1

                    j=indBrake(iper)+1:indBrake(iper+1);
                    if length(j)>=bl_mindist
                        indAboveThr(j)= indAboveThr(j)+(sec-1)*fs;
                        if sum(abs(filt_data(indAboveThr(j)))>max_noise_uv)==0 % check that filtered signal is below max Noise level
                            indHighEntr   = [indHighEntr indAboveThr(j)]; 
                        end 
                    end
                end
            end
        end
        clearvars -except  indHighEntr sigfull sec S env HFOobj sigfiltered   
    end
    display(['For ' num2str(floor(length(data)/fs)) ' sec, baseline length = ' num2str(length(indHighEntr)/fs) ' sec'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% end checking additional

% save baseline
% baseline.IndR = indHighEntr;


% ------------------------------------------------------------
% save values
baseline   = env(indHighEntr);

% with CDF at CDFlevel level
if ~isempty(indHighEntr)
    [f,x] = ecdf(baseline);
    % stairs(x,f);
    thrCDF   = x(find(f>cdf_rms ,1));
else
    thrCDF = 1000;
end
thr = thrCDF;

baselineFiltered = filt_data(indHighEntr);
% with CDF at CDFlevel level
if ~isempty(indHighEntr)
    [f,x] = ecdf(baselineFiltered);
    % stairs(x,f);
    thrCDF   = x(find(f>cdf_filt ,1));
else
    thrCDF = 1000;
end
thr_filt = thrCDF;

% show thresholds

display(['ThrEnv = '  num2str(b.thr) ', ThrFiltSig = ' num2str(b.thrFilt) ])




end






