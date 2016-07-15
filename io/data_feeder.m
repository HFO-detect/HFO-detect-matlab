function [data,fs] = data_feeder(file_path,start_samp, stop_samp, channel_name) 
%%
% Function that specifies file opener based on extension and returns data.
%
% Parameters:
% -----------
    % file_path(str) - path to data file\n
    % start_samp(int) - start sample\n
    % stop_samp(int) - stop sample\n
    % channel_name(str) - requested channel\n
%
% Returns:
% --------
    % data - requested data\n
    % fs - sampling frequency\n
%% 

% Parse the file name to get extension
[~,~,ext] = fileparts(file_path);%[pathstr,name,ext] = fileparts(file_path);
% Decide which opener to use and get the data

    if strcmp(ext,'.d') == 1
        h = getDRheader(file_path);
       
        fs = h.sheader.fsamp;
        ch_idx = h.xheader.channel_names;
        ch_idxs = strmatch(channel_name,ch_idx);
        ch_idxs = ch_idxs(1,1);
       data = getDRdata(h, ch_idxs, start_samp, stop_samp);

     else
         if strcmp(ext,'.edf') == 1
             [hdr, record] = edfread(file_path);
%        else ext == '.bdf'
%             f = pyedflib.EdfReader(file_path,4)
%
        ch_idx = hdr.label;
        ch_idxs = strmatch(channel_name,ch_idx);
        ch_idxs = ch_idxs(1,1);
        
        fs = hdr.samples(ch_idxs);
        data = record(ch_idxs,:);
         end
    end