function d = getDRdata(h,ch,s1,s2)
% d = getDRdata(h)
% this function reads the data from BrainScope D-file
%
% input:    h .. header structure read by getDRheader
%           ch .. channel indices 
%           s1 .. begin of the data (in time points)
%           s2 .. end of the data (in time points)
% output:   d .. M x N matrix, m = length(ch), N = s2-s1+1

fid = fopen(h.filename,'r');
if fid<1
    fprintf('can''t open %s\n',h.filename);
    fclose(fid);
    return
end

[prec nb] = getPrec(h);

ds1 = h.datapos + (s1-1)*nb*h.sheader.nchan;
np = s2-s1+1;

%%% read data
try
    fseek(fid,ds1,'bof');
    dd = fread(fid,np*h.sheader.nchan,prec);
catch
    d = [];
    disp('error when reading data')
    fclose(fid);
    return
end

dd = reshape(dd,h.sheader.nchan,np);
if isempty(ch)
    d = dd;
else
    d = dd(ch,:);
end

fclose(fid);

