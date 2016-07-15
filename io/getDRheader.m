function h = getDRheader(fn)
% h = getDRheader(fn)
% this function reads the header of the BrainScope D-file (and partialy
% R-file)
% input:    fn .. fullpath filename
% output:   h .. header structure
h = [];

fid = fopen(fn,'r');
if fid<1
    fprintf('can''t open %s\n',fn);
    fclose(fid);
    return
end

% filename
h.filename = fn;


%%% READ STANDARD HEADER
% sign
h.sheader.sign = char(fread(fid,15,'char')');
% ftype
h.sheader.ftype = char(fread(fid,1,'char'));
if ~(strcmp(h.sheader.ftype,'D') || strcmp(h.sheader.ftype,'R') || h.sheader.ftype==0)
    fprintf('unknown file type %s\n',h.sheader.ftype);
    fclose(fid);
    return
end
% nchan
h.sheader.nchan = fread(fid,1,'uint8');
% naux
h.sheader.naux = fread(fid,1,'uint8');
% fsamp
h.sheader.fsamp = fread(fid,1,'uint16');
% nsamp
h.sheader.nsamp = fread(fid,1,'uint32');
% d_val
h.sheader.d_val.value = fread(fid,1,'uint8');
h.sheader.d_val.data_invalid = rem(floor(h.sheader.d_val.value/128),2);
h.sheader.d_val.data_packed = rem(floor(h.sheader.d_val.value/64),2);
h.sheader.d_val.block_structure = rem(floor(h.sheader.d_val.value/32),2);
h.sheader.d_val.polarity = rem(floor(h.sheader.d_val.value/16),2);
h.sheader.d_val.data_calib = rem(floor(h.sheader.d_val.value/8),2);
h.sheader.d_val.data_modified = rem(floor(h.sheader.d_val.value/4),2);
h.sheader.d_val.data_cell_size = rem(h.sheader.d_val.value,4);
% unit
h.sheader.unit = fread(fid,1,'uint8');
% zero
h.sheader.zero = fread(fid,1,'uint16');
% data_org
h.sheader.data_org = 16*fread(fid,1,'uint16');
% xhdr_org
h.sheader.data_xhdr_org = 16*fread(fid,1,'int16');

%%% READ EXTENDED HEADER
if h.sheader.data_xhdr_org  
    fseek(fid,h.sheader.data_xhdr_org,'bof');
    cont = 1;
    while cont
        mnemo = fread(fid,1,'uint16');
        len = fread(fid,1,'uint16');
        
        switch mnemo
        
            case 16725 % AU authentication key
                h.xheader.authentication_key = fread(fid,len,'uint8');
            
            case 22082 % BV block variable value list
                h.xheader.block_var_list = fread(fid,len,'uint8');
                %%%% unfinished
                
            case 16707 % CA channel attributes
                h.xheader.channel_attrib.val = fread(fid,len,'uint8');
                for ii = 1:len
                    bval = dec2bin(h.xheader.channel_attrib.val(ii),8);
                    h.xheader.channel_attrib.unsigned(ii) = bin2dec(bval(8));
                    h.xheader.channel_attrib.reversed_polarity(ii) = bin2dec(bval(7));
                    h.xheader.channel_attrib.reserved1(ii) = bin2dec(bval(6));
                    h.xheader.channel_attrib.reserved2(ii) = bin2dec(bval(3:5));
                    h.xheader.channel_attrib.calib(ii) = bin2dec(bval(2));
                    h.xheader.channel_attrib.reserved3(ii) = bin2dec(bval(1));
                end
                
            case 18755 % CI calibration info
                h.xheader.calib_info = fread(fid,len,'uint8');
                %%%% unfinished
                
            case 20035 % CN channel names
                h.xheader.channel_names = char(reshape(fread(fid,len,'uint8'),4,[])');
            
            case 17988 % DF dispose flags
                h.xheader.dispose_flags = fread(fid,len,'uint8');
            
            case 18756 % DI data info
                h.xheader.data_info = char(fread(fid,len,'char')');
            
            case 19526 % FL file links
                h.xheader.file_links = char(fread(fid,len,'char')');
            
            case 21318 % FS frequncy of sampling
                h.xheader.freq.val = fread(fid,2,'int16');
                h.xheader.freq.Fsamp = h.xheader.freq.val(1)/h.xheader.freq.val(2);
            
            case 17481 % ID patient ID
                h.xheader.patient_id.val = fread(fid,1,'uint32');
                bval = dec2bin(h.xheader.patient_id.val,32);
                psn = bin2dec(bval(19:32));
                day = bin2dec(bval(12:16));
                mon = bin2dec(bval(8:11));
                year = bin2dec(bval(1:7));
                h.xheader.patient_id.ismale = double(strcmp(bval(17),'0'));
                h.xheader.patient_id.bday = day;
                h.xheader.patient_id.bmonth = rem(mon,50);
                h.xheader.patient_id.byear = year  + 1900 + strcmp(bval(18),'1')*2000;
                h.xheader.patient_id.id = sprintf('%2.2d%2.2d%2.2d/%4.4d',year,mon,day,psn);
            
            case 19024 % PJ project name
                h.xheader.project_name = char(fread(fid,len,'char')');
            
            case 16978 % RB R-block structure
                h.xheader.rblock = fread(fid,len,'uint8');
                %%%% unfinished
            
            case 18003 % SF source file
                h.xheader.source_file = char(fread(fid,len,'char')');
            
            case 17748 % TE text record
                h.xheader.text_record = char(fread(fid,len,'char')');
            
            case 18772 % TI time info
                h.xheader.date.val = fread(fid,1,'uint32');
                [yy m1 dd hh m2 ss] = datevec(h.xheader.date.val/(60*60*24)+datenum('01.01.1970','dd.mm.yy'));
                h.xheader.date.yy = yy;
                h.xheader.date.mon = m1;
                h.xheader.date.dd = dd;
                h.xheader.date.hh = hh;
                h.xheader.date.min = m2;
                h.xheader.date.ss = ss;
            
            case 21588 % TT tag table
                h.xheader.tag_table.deflen = fread(fid,1,'uint16');
                h.xheader.tag_table.listlen = fread(fid,1,'uint16');
                h.xheader.tag_table.defoff = fread(fid,1,'uint32');
                h.xheader.tag_table.listoff = fread(fid,1,'uint32');
            
            case 22612 % TX text extension record
                h.xheader.text_extrec = char(fread(fid,len,'char')');
            
            case 0 % end of xheader
                cont = 0;
                h.datapos = ftell(fid);
            
            otherwise
                fseek(fid,len,'cof');
        end
    end
else
    h.xheader = [];
    h.datapos = ftell(fid);
end

%%% READ TAGS
if isfield(h.xheader,'tag_table')
    
    % fix the long datasets bug in D-file with defoff and listoff
    [pr nb] = getPrec(h);
    while h.xheader.tag_table.defoff<(h.sheader.nchan*h.sheader.nsamp*nb + h.sheader.data_org) && h.xheader.tag_table.defoff>h.datapos
        h.xheader.tag_table.defoff = h.xheader.tag_table.defoff + 16^8;
        h.xheader.tag_table.listoff = h.xheader.tag_table.listoff + 16^8;
    end
        
    % read tag list
    fseek(fid,h.xheader.tag_table.listoff,'bof');
    tlist = reshape(fread(fid,4*floor(h.xheader.tag_table.listlen/4),'uint8'),4,[]);
    tlist(3,:) = rem(tlist(3,:),128);
    h.xheader.tag_table.tagpos = tlist(1:3,:)'*[1 256 65536]';
    h.xheader.tag_table.tagclass = rem(tlist(4,:)',128);
    h.xheader.tag_table.tagselected = floor(tlist(4,:)'/128);
    
    % fix the long datasets bug in D-file (positions > 2^23-1
    if ~isempty(h.xheader.tag_table.tagpos)
        cont1 = 1;
        while cont1
            wh = find(diff(h.xheader.tag_table.tagpos)<0);
            if isempty(wh)
                cont1 = 0;
            else
                h.xheader.tag_table.tagpos((wh(1)+1):end) = h.xheader.tag_table.tagpos((wh(1)+1):end) + 2^23;
            end
        end
    end
    
    % read tag table
    currpos = h.xheader.tag_table.defoff;
    cont1 = 1;
    ind = 0;
    while cont1
        fseek(fid,currpos,'bof');
        ind = ind + 1;
        abrv = char(fread(fid,2,'char')');
        n = fread(fid,1,'uint16');
        txtlen = fread(fid,1,'uint16');
        txtoff = fread(fid,1,'uint16');
        %?? not sure why this happened
        if isempty(txtoff)
            break
        end
        currpos = currpos + 8;
        if floor(n/32768)
            cont1 = 0;
        end
        h.xheader.tag_table.classes(ind).abrv = abrv;
        h.xheader.tag_table.classes(ind).n = rem(n,32768);
        fseek(fid,txtoff+h.xheader.tag_table.defoff, 'bof');
        h.xheader.tag_table.classes(ind).text = char(fread(fid,txtlen,'char')');
    end
    
end

fclose(fid);