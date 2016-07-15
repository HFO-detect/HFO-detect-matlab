% Root mean square detection algorithm and its variants.

%% RMS detector
function [df_out] = rms_detect(data, fs, low_fc, high_fc, threshold, window_size, window_overlap)

% Toot mean square detection algorithm. (CITATIONS)
% 
% Parameters:
% -----------
% data(1-d numpy array) - raw data
% fs(int) - sampling frequency
% low_fc(float) - low cut-off frequency
% high_fc(float) - high cut-off frequency
% window_size(float) - sliding window size in secs
% window_overlap(float) - fraction of the window overlap (0 to 1)
% 
% Returns:
% --------
% df_out(pandas.DataFrame) - output dataframe with detections

%% Calculate window values for easier operation
samp_win_size = window_size * fs; %Window size in samples
samp_win_inc = samp_win_size * window_overlap; %Window increment in samples

%% Create output dataframe 
df_out = create_output_df(); 

%% Filter the signal
[b,a] = butter (3,[low_fc/(fs/2), high_fc/(fs/2)], 'bandpass');
filt_data = filtfilt(b, a, data);

%% Transform the signal - one sample window shift
% RMS = compute_rms(filt_data, window_size*fs);
% RMS = compute_hilbert_energy(filt_data);
% RMS = compute_hilbert_envelope(filt_data);
% RMS = compute_stenergy(filt_data, window_size * fs);
% RMS = compute_teager_energy(filt_data);
% RMS = compute_line_lenght(filt_data, window_size*fs);

%% Alternative approach - overlapping window
win_start = 1;
win_stop = window_size*fs;
RMS = [];
while win_start < length(filt_data)
    if win_stop > length(filt_data)
        win_stop = length(filt_data);
    end
    
    RMS = [RMS extract_rms(filt_data(win_start:win_stop))];
    % RMS = [RMS extract_line_lenght(filt_data(win_start:win_stop))];
    % RMS = [RMS extract_stenergy(filt_data(win_start:win_stop))];
    
    win_start = win_start + samp_win_inc;
    win_stop = win_stop + samp_win_inc;
end

%% Create threshold
det_th = th_std(RMS,threshold);
%det_th = th_percentile(RMS,threshold);
%det_th = th_quian(RMS,threshold);
%det_th = th_turkey(RMS,threshold);

%% Detect
RMS_idx=1;
while RMS_idx < length(RMS)
    if RMS(RMS_idx) >= det_th
        event_start = RMS_idx * samp_win_inc;
        while (RMS_idx <= length(RMS)) && (RMS(RMS_idx) >= det_th)
            RMS_idx = RMS_idx + 1;
        end
        
        event_stop = (RMS_idx * samp_win_inc)+samp_win_size;
        
        if event_stop > length(data)
            event_stop = length(data);
        end
        
        % Optional feature calculations can go here
        
        % Write into dataframe
        df_out.event_start = [df_out.event_start event_start];
        df_out.event_stop = [df_out.event_stop event_stop];
        
        RMS_idx = RMS_idx + 1;
    else
        RMS_idx = RMS_idx + 1;
    end
end