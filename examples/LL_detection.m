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

% Presets - metadat - suggested
met_dat = struct('channel_name', 'B''1','pat_id', '12' );

%% We have data call the core of the algorithm and get detections
LL_df = ll_detect(data, fs, 80, 600, 1, 0.1, 0.25);

%% Optional conversion to uUTC time or to absolute samples in the recording

%% Adding metadata
LL_df = add_metadata(LL_df,met_dat);

%% Optional rearange columns

%% Plot the detections in signal
figure
plot(data)
hold on
for i = 1:size(LL_df.event_start,2)
    det_size = LL_df.event_stop(i) - LL_df.event_start(i);
    plot(linspace(double(LL_df.event_start(i)),double(LL_df.event_stop(i)),double(det_size)),...
         data(LL_df.event_start(i)+1:LL_df.event_stop(i)),'r')
end
hold off

%% Optional insert into database

%% Optional machine learning