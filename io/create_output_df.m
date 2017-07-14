function [out_df]= create_output_df(varargin)
%%
%  Function to create a structure depending on the algorithm needs. 
%  Fields: event_start,event_stop preset.
%     
% Parameters:
% -----------
    % fields(struct) - optional fields struct e.g. - struct('frequency','int64')
%     
% Returns:
% --------
    % dataframe - pandas dataframe for deteciton insertion\n
%%    
if length(varargin)==1
     dtypes = varargin{1};
else dtypes = [];
end

% Preset dtypes
dtype_dict = struct('channel_name','str','event_start','int64','event_stop','int64');
                  
if isempty(dtypes) == 1
    dtypes_fields = fieldnames(dtypes);
    for i = 1:numel(dtypes_fields)
        dtype_dict.(dtypes_fields{i})=dtypes.(dtypes_fields{i});
    end
end

out_df = struct();

dtype_dict_fn = fieldnames(dtype_dict);

for i = 1:numel(dtype_dict_fn)
    if regexp(dtype_dict.(dtype_dict_fn{i}),'int*') 
        eval(['out_df.(dtype_dict_fn{i}) = ',dtype_dict.(dtype_dict_fn{i}),'([]);'])
    elseif regexp(dtype_dict.(dtype_dict_fn{i}),'single') 
        out_df.(dtype_dict_fn{i}) = single([]);
    elseif regexp(dtype_dict.(dtype_dict_fn{i}),'double') 
        out_df.(dtype_dict_fn{i}) = double([]);
    elseif regexp(dtype_dict.(dtype_dict_fn{i}),'str') 
        out_df.(dtype_dict_fn{i}) = {};
    end
    
end
    
  %  out_df=out_df().dtype_dict
    
%     for row = 1:length(fieldnames(out_df))
%         for col = 1:(size(out_df.event_start,2))
%             if out_df.event_start(row,col) == fieldnames(dtype_dict(row,col))
%                
%             end
%         end
%     end
