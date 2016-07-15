% Script load file, detect and dump to pandas dataframe
close all

% Edf file
parent_dir = cd(cd('..'));
% file_path = [parent_dir '\test_data\ieeg_sample.edf']; % for win
% file_path = [parent_dir '\test_data\Easrec_ic_exp-036_150429-1346.d']; % for win
% file_path = [parent_dir '/test_data/ieeg_sample.edf']; % for ubuntu
% file_path = [parent_dir '/test_data/Easrec_ic_exp-036_150429-1346.d']; % for ubuntu
file_path = '/mnt/BME_shared/raw_data/SEEG/seeg-032-141008/Easrec_ic_exp-032_141008-0929.d';

% Get the data
[data,fs] = data_feeder(file_path, 0, 50000, 'B''1');
disp('Data loaded')
data = data(1:end-1);

%% Data
low_fc = 80;
high_fc = 600;
treshold = 1;
window_size = 0.1;
window_overlap = 0.25;

%% Calculate window values for easier operation
samp_win_size = window_size * fs; %Window size in samples
samp_win_inc = samp_win_size * window_overlap; %Window increment in samples

%% Filter the signal
[b,a] = butter (3,[low_fc/(fs/2), high_fc/(fs/2)], 'bandpass');
filt_data = filtfilt(b, a, data);

%% Transform the signal - one sample window shift
 Line_length = compute_line_lenght(filt_data, window_size*fs);
 Hilbert_energy = compute_hilbert_energy(filt_data);
 Hilbert_envelope = compute_hilbert_envelope(filt_data);
 Stenergy = compute_stenergy(filt_data, window_size * fs);
 Teager_energy = compute_teager_energy(filt_data);
 Rms = compute_rms(filt_data, window_size*fs);
 %% Plot
 figure(1)
 subplot(311)
 plot(Line_length)
 title('Line length')
 subplot(312)
 plot(Stenergy)
 title('Stenergy')
 subplot(313)
 plot(Rms)
 title('Rms')
 
 figure(2)
 subplot(311)
 plot(Hilbert_energy)
 title('Hilbert energy')
 subplot(312)
 plot(Hilbert_envelope)
 title('Hilbert envelope')
 subplot(313)
 plot(Teager_energy)
 title('Teager energy')
 
 figure(3)
 subplot(211)
 plot(data)
 title('Original data')
 subplot(212)
 plot(filt_data)
 title('Filtred data') 