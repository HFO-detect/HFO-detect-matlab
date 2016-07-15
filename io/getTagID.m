function [TagIDList] = getTagID(dFileName)
%+---------------------------------------------------------------------------+
%   [TagIDList] = getTagID(dFileName)
%
%   This function tells which tag-ID are stored in D-file
%
%   TagIDList ... list of tag-ID
%   dFileName ... name of d-file containing tags
%+---------------------------------------------------------------------------+

% Author :   Jiri Svoboda <Freedomek>
% e-mail :   jiri.svoboda@post.lf3.cuni.cz
%
% History:   1st  version   21.01.2002
%            last revision  21.01.2002
%            this revision  21.01.2002

%=============================================================================
%=============================================================================
%=============================================================================
  % Structure of D-file
  %
  %  char   sign[15];      /* program signature               0  15  */
  %  char   ftype;         /* file type ID                   15   1  */
  %  uchar  nchan;         /* number of(all)channels         16   1  */
  %  uchar  naux;          /* number of aux channels         17   1  */
  %  ushort fsamp;         /* sampling frequency             18   2  */
  %  ulong  nsamp;         /* number of samples              20   4  */
  %  uchar  d_val;         /* data validation mark           24   1  */
  %  uchar  unit;          /* uV/bin                         25   1  */
  %  short  zero;          /* value ÷ 0 uV                   26   2  */
  %  ushort data_org;      /* data sect offset (paragraphs)  28   2  */
  %  ushort xhdr_org;      /* extheader offset (paragraphs)  30   2  */

  if ((nargin~=1) | (nargout~=1))
      error('Bad usage of getTagID. Type <HELP getTagID> !');
  end

  fr_d=fopen(dFileName,'r');
  if (fr_d == -1)
      error(['Unable to open ' dFileName]);
  end

  [D_sign,     Cnt] = fread(fr_d, 15, 'char'  );
  [D_ftype,    Cnt] = fread(fr_d, 1,  'char'  );
  [D_nchan,    Cnt] = fread(fr_d, 1,  'uchar' );
  [D_naux,     Cnt] = fread(fr_d, 1,  'uchar' );
  [D_fsamp,    Cnt] = fread(fr_d, 1,  'ushort');
  [D_nsamp,    Cnt] = fread(fr_d, 1,  'ulong' );
  [D_d_val,    Cnt] = fread(fr_d, 1,  'uchar' );
  [D_unit,     Cnt] = fread(fr_d, 1,  'uchar' );
  [D_zero,     Cnt] = fread(fr_d, 1,  'short' );
  [D_data_org, Cnt] = fread(fr_d, 1,  'ushort');
  [D_xhdr_org, Cnt] = fread(fr_d, 1,  'ushort');


  fseek(fr_d, (D_xhdr_org*16), 'bof');  
  ID = fread(fr_d, 1, 'ushort');
  TT_flg=0;

  while (ID ~= 0)
      if (ID == 21588)   %  21588 == 0x5454 == 'TT' -- tag table
          IDs_len = fread(fr_d, 1, 'ushort');   % skip IDs_len -- it's always 12 bytes
          % read TT structure
          % struct {
	  %     ushort def_len;
	  %     ushort list_len;
	  %     ulong  def_off;
	  %     ulong  list_off;
          %     } TT;              /* Total size 12 bytes */

          TT_def_len  = fread(fr_d, 1, 'ushort');
          TT_list_len = fread(fr_d, 1, 'ushort');
          TT_def_off  = fread(fr_d, 1, 'ulong');
          TT_list_off = fread(fr_d, 1, 'ulong');

          TT_flg=1;
          break
      end
      
      % if not TT record, skip this record
      IDs_len = fread(fr_d, 1, 'ushort');
      fseek(fr_d, IDs_len, 'cof');  % 'cof' -- current position in file
      ID = fread(fr_d, 1, 'ushort');
  end


  if (TT_flg == 0)
      error(['No tag table found in file ' dFileName]);
  end



  % read Tag Table
  % TT_list_len -- total length of Tag Table in bytes
  %             -- number of tags = TT_list_len / sizeof(TagCell)
  %
  % TagCell   == unsigned long:  Byte3 Byte2 Byte1 Byte0
  %   . TagType   == Byte3
  %   . TagOffset == Byte2 Byte1 Byte0
  %
  % Total  4 bytes of TagCell

  TagsNum = TT_list_len / 4;      % sizeof( TagCell ) == 4
  % WARNING: TagsNum contains tags of all types, but I want to use only
  %          specific Tags -- number of them can be different (smaller)
  if (TagsNum == 0)
     error(['No tags available']);
  end

  fseek(fr_d, TT_list_off, 'bof');     % go to start of Tag Table
  j=0;
  for (i=0:(TagsNum-1))                % go through whole Tag Table and find user def. TagType
      TagCell = fread(fr_d, 1, 'ulong');
      TagType = fix(TagCell / (2^24));
      j = j + 1;
      TagIDList(j) = TagType;
  end

  TagIDList = unique(TagIDList);       % cancel repetition
  fclose(fr_d);

return
%================================================================================================
%that's all folks
