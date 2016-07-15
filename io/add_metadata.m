function [df]= add_metadata(df,metadata)
%%
% Convenience function to add metadata to the output dataframe.
%     
% Parameters:
% -----------
    % df(pandas.DataFrame) - dataframe with original data\n
    % metadata(dict) - dictionary with column_name:value\n
%     
% Returns:
% --------
    % new_df(pandas.DataFrame) - updated dataframe
%%
    
   keys = fieldnames(metadata)';
   for i = 1:numel(keys)
        df.(keys{i}) = cell(1,length(df.event_start));
        df.(keys{i})(:) = {metadata.(keys{i})};
   end  