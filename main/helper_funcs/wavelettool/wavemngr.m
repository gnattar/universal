function [out1,out2,out3,out4] = wavemngr(option,in2,in3,in4,in5,in6,in7)
%WAVEMNGR Wavelet manager.
%       WAVEMNGR is a type of wavelets manager. It allows to create,
%       add, delete, restore, or read wavelets.
%
%       WAVEMNGR('create')
%               creates wavelets.inf MAT-file
%               using wavelets.asc ASCII-file.
%
%       WAVEMNGR('add',FN,FSN,WT,NUMS,FILE) or
%       WAVEMNGR('add',FN,FSN,WT,NUMS,FILE,B), adds a new wavelet
%       family.
%               FN         = Family Name (string).
%               FSN        = Family Short Name (string).
%               WT         = Wavelet type : 1 , 2 , 3 , 4.
%                       WT = 1 , orthogonal wavelets.
%                       WT = 2 , biorthogonal wavelets.                
%                       WT = 3 , wavelet with scale function.
%                       WT = 4 , wavelet without scale function.
%               NUMS       = String of numbers.
%               FILE       = MAT-file or M-file.
%               B          = [lb ub] lower and upper bounds of
%                     effective support for wavelets of type = 3 or 4.
%
%       WAVEMNGR('del',N), deletes a wavelet family,
%               N = Family Short Name or Wavelet Name (in the family).
%
%       WAVEMNGR('restore') or WAVEMNGR('restore',IN2)
%               if nargin = 1 , the previous wavelets.asc is restored
%               otherwise the initial wavelets.asc is restored.
%
%       OUT1 = WAVEMNGR('read')
%               OUT1 gives all wavelets families.
% 
%       OUT1 = WAVEMNGR('read',IN2)
%               out1 gives all wavelets.
%
%       OUT1 = WAVEMNGR('read_asc')
%               reads wavelets.asc ASCII-file and
%               OUT1 gives all wavelets informations.

%       INTERNAL OPTIONS.
%-------------------------------
%       out1 = wavemngr('load')
%               loads Wavelets_Info from wavelets.inf matfile,
%               and puts it in memory fig_buffer
%               out1 = Wavelets_Info.
%
%       [out1,out2,out3] = wavemngr('indw',W) or
%               returns family indice, table of number indice
%               and wavelet indice for wavelet W.
%
%       out1 = wavemngr('indw',W,in3) returns wavelet indice.
%
%       out1 = wavemngr('indf',F) returns family indice
%               for family F (short name).
%
%       out1 = wavemngr('tnum',F)
%               returns num-table for wavelet family F (short name).
%
%       [out1,out2,out3] = wavemngr('snnu',W)
%               returns family shortname, number and
%               family indice for wavelet W.
%
%       [out1,out2,out3,out4] = wavemngr('ftnu',F)
%               returns family shortname, associate table of
%               number, family indice and number indice
%               for wavelet W.
% 
%       out1 = wavemngr('tfsn') or out1 = wavemngr('tfsn',T)
%               returns shortname-table (of type = T : 'dwt' or 'cwt' or 'owt')
%
%       out1 = wavemngr('tfln') or out1 = wavemngr('tfln',T)
%               returns longname-table (of type = T : 'dwt' or 'cwt' or 'owt').
%
%       out1 = wavemngr('file',W)
%               returns filename for wavelet family W (short name).
%               or for the wavelet W.
%
%       out1 = wavemngr('type',W)
%
%       out1 = wavemngr('info',W)
%
%       out1 = wavemngr('wfln',W)
%
%       out1 = wavemngr('user',W)

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:19:34 $

%       Uses WAVEMNGR, WMEMUTIL.

global Wavelets_Info

% Files Names.
%--------------
bin_ini_file    = 'wavelets.bin';
asc_ini_file    = 'wavelets.ini';
bin_file        = 'wavelets.inf';
asc_file        = 'wavelets.asc';
sav_file        = 'wavelets.prv';

if nargin==0 , option = 'create' ; end

if strcmp(option,'load')
        out1 = Wavelets_Info;
        if isempty(out1)
                err = 0;
                eval(['load ' bin_file ' -mat'],'err = 1;');
                if err
                        err = 0;
                        eval(['load ' bin_ini_file ' -mat'],'err = 1;');
                        if err
                                clc
                                disp(' ');
                                disp('---------------------------------------------');
                                disp(['*** File : ' bin_ini_file ' not found ! ***']);
                                disp('---------------------------------------------');
                                disp(' ');
                                error('****** STOP ******');
                        end 
                end
                out1 = Wavelets_Info;
        end
        return
end

% Stored values informations.
%----------------------------
ind_tab_fn       = 1;
ind_tab_fsn      = 2;
ind_tab_type     = 3;
ind_tab_file     = 4;
ind_tab_user     = 5;
ind_tab_beg      = 6;
ind_tab_end      = 7;
ind_tab_num      = 8;
nb_stored        = 8;
nb_InfoByWave    = 6;

% Miscellaneous Values.
%----------------------
NB_FamInWTB =  8;
% beg_fam   = 'Family Name : ';
% owt = 1;
% bwt = 2;
% swt = 3;
% nwt = 4; 

if      strcmp(option,'indw')
        % in2 : wavelet name
        %-------------------
        % out1 = i_fam;        out2 = i_num;        out3 = i_wav;
        %--------------------------------------------------------
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        in2             = deblankl(in2);
        lin2            = length(in2);
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        tab_beg         = wmemutil('get',Wavelets_Info,ind_tab_beg);
        tab_end         = wmemutil('get',Wavelets_Info,ind_tab_end);
        tab_num         = wmemutil('get',Wavelets_Info,ind_tab_num);
        out1 = [];        out2 = [];        out3 = [];
        nb_fam          = size(tab_fsn,1);
        for i_fam=1:nb_fam
                fam = wnoblank(tab_fsn(i_fam,:));
                len = length(fam);
                ok_wave = 0;
                if lin2>=len
                        if fam==in2(1:len)
                                num_ind = tab_beg(i_fam):tab_end(i_fam);
                                for i_wav = num_ind
                                        num_str = wnoblank(tab_num(i_wav,:));
                                        if strcmp(num_str,'no') , num_str = '' ; end
                                        wname = [fam num_str];
                                        if strcmp(wname,in2)
                                                ok_wave = 1; break; 
                                        end
                                end

                                % test for ** number
                                %------------------
                                if ok_wave==0 & strcmp(num_str,'**') & (lin2>len)
                                        num = str2num(in2(len+1:lin2));
                                        if ~isempty(num)
                                                if (num==fix(num)) & (0<num) 
                                                        ok_wave = 1;
                                                end
                                        end 
                                end
                        end
                end
                if ok_wave , break; end
        end
        if ok_wave
                out1 = i_fam;        out2 = i_wav-tab_beg(i_fam)+1;
                out3 = i_wav;
        else
                msg = ['Invalid wavelet name : ' in2];
                errargt('Wavelet test',msg,'msg');
                error(['***  ' msg '  ***']);
        end

elseif  strcmp(option,'indf')
        % in2 : family short name
        %------------------------
        % out1 = i_fam;
        %------------------------
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        in2             = deblankl(in2);
        lin2            = length(in2);
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        out1            = [];
        nb_fam          = size(tab_fsn,1);
        for i_fam=1:nb_fam
                fam     = wnoblank(tab_fsn(i_fam,:));
                len     = length(fam);
                ok_wave = 0;
                if lin2==len
                        if fam==in2 , out1 = i_fam; break; end
                end
                if ~isempty(out1) , break; end
        end

elseif  strcmp(option,'tnum')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        tab_beg         = wmemutil('get',Wavelets_Info,ind_tab_beg);
        tab_end         = wmemutil('get',Wavelets_Info,ind_tab_end);
        tab_num         = wmemutil('get',Wavelets_Info,ind_tab_num);

        nbfam    = size(tab_fsn,1);
        k        = 1;
        out1     = [];
        in2      = wnoblank(in2);
        while (k<=nbfam)
                if strcmp(wnoblank(tab_fsn(k,:)),in2)
                        out1 = tab_num(tab_beg(k):tab_end(k),:);
                        if strcmp(wnoblank(out1(1,:)),'no') , out1 = ''; end
                        break;
                else
                        k = k+1;
                end
        end

elseif  strcmp(option,'tfsn')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        out1          = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        if nargin==2
                tab_type = wmemutil('get',Wavelets_Info,ind_tab_type);
                if      strcmp(lower(in2),'dwt')
                        ind  = find(tab_type==1 | tab_type==2);

                elseif  strcmp(lower(in2),'cwt')
                        ind  = find(...
                                        tab_type==1 | tab_type==2 |      ...
                                        tab_type==3 | tab_type==4        ...
                                        );

                elseif  strcmp(lower(in2),'owt')
                        ind  = find(tab_type==1);

                else
                        ind = size(out1,1);

                end
                out1 = out1(ind,:);
        end

elseif  strcmp(option,'snnu')
        % ONLY for GUI !! -- wavattrb.m
        % in2 = wavelet name
        % in3 (optional) research of tabwnum
        %-----------------------------------
        % out1 = fsn
        % out2 = num
        % out3 = i_fam
        %--------------------------------
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        in2             = deblankl(in2);
        lin2            = length(in2);
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        tab_beg         = wmemutil('get',Wavelets_Info,ind_tab_beg);
        tab_end         = wmemutil('get',Wavelets_Info,ind_tab_end);
        tab_num         = wmemutil('get',Wavelets_Info,ind_tab_num);
        out1 = [];        out2 = [];        out3 = [];
        nb_fam          = size(tab_fsn,1);
        for i_fam=1:nb_fam
                fam = wnoblank(tab_fsn(i_fam,:));
                len = length(fam);
                ok_wave = 0;
                if lin2>=len
                        if fam==in2(1:len)
                                num_ind = tab_beg(i_fam):tab_end(i_fam);
                                for i_wav = num_ind
                                        num_str = wnoblank(tab_num(i_wav,:));
                                        if strcmp(num_str,'no') , num_str = '' ; end
                                        wname = [fam num_str];
                                        if strcmp(wname,in2) , ok_wave = 1; break; end
                                end

                                % test for ** number
                                %------------------
                                if ok_wave==0 & strcmp(num_str,'**') & (lin2>len)
                                        num_str = in2(len+1:lin2);
                                        num = str2num(num_str);
                                        if ~isempty(num)
                                                if (num==fix(num)) & (0<num) 
                                                        ok_wave = 1;
                                                end
                                        end 
                                end

                        end
                        if ok_wave , break; end
                end
        end
        if ok_wave
                out1 = fam;        out2 = num_str;
                out3 = i_fam;
        end

elseif  strcmp(option,'ftnu')
        % ONLY for GUI !! -- wavattrb.m
        % in2 = wavelet name
        %--------------------------
        % out1 = fam
        % out3 = i_fam
        % out2 = tabwnum
        % out4 = i_wav
        %--------------------------------
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        in2             = deblankl(in2);
        lin2            = length(in2);
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        tab_beg         = wmemutil('get',Wavelets_Info,ind_tab_beg);
        tab_end         = wmemutil('get',Wavelets_Info,ind_tab_end);
        tab_num         = wmemutil('get',Wavelets_Info,ind_tab_num);
        out1 = [];        out2 = [];        out3 = [];        out4 = [];
        nb_fam          = size(tab_fsn,1);
        add_num         = 0;
        for i_fam=1:nb_fam
                fam = wnoblank(tab_fsn(i_fam,:));
                len = length(fam);
                ok_wave = 0;
                if lin2>=len
                        if fam==in2(1:len)
                                num_ind = tab_beg(i_fam):tab_end(i_fam);
                                for i_wav = num_ind
                                        num_str = wnoblank(tab_num(i_wav,:));
                                        if strcmp(num_str,'no') , num_str = '' ; end
                                        wname = [fam num_str];
                                        if strcmp(wname,in2) , ok_wave = 1; break; end
                                end

                                % test for ** number
                                %------------------
                                if ok_wave==0 & strcmp(num_str,'**') & (lin2>len)
                                        num_str = in2(len+1:lin2);
                                        num = str2num(num_str);
                                        if ~isempty(num)
                                                if (num==fix(num)) & (0<num)
                                                        add_num        = 1; 
                                                        ok_wave = 1;
                                                end
                                        end 
                                end

                        end
                end
                if ok_wave , break; end
        end
        if ok_wave
                out1 = fam;        out2 = tab_num(num_ind,:);
                out3 = i_fam;      out4 = i_wav-tab_beg(i_fam)+1;
                lnum = length(num_ind);
                if lnum==1 & isempty(num_str) , out2 = ''; end
                if add_num
                        if lnum==1 
                                out2 = num_str;
                        else
                                out2 = str2mat(out2(1:lnum-1,:),num_str,out2(lnum,:));
                        end                
                end
        end

elseif  strcmp(option,'tfln')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        out1          = wmemutil('get',Wavelets_Info,ind_tab_fn);
        if nargin==2
                tab_type = wmemutil('get',Wavelets_Info,ind_tab_type);
                if      strcmp(lower(in2),'dwt')
                        ind  = find(tab_type==1 | tab_type==2);

                elseif  strcmp(lower(in2),'cwt')
                        ind  = find(...
                                        tab_type==1 | tab_type==2 |      ...
                                        tab_type==3 | tab_type==4        ...
                                        );

                elseif  strcmp(lower(in2),'owt')
                        ind  = find(tab_type==1);

                else
                        ind = size(out1,1);

                end
                out1 = out1(ind,:);
        end

elseif  strcmp(option,'file')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_file      = wmemutil('get',Wavelets_Info,ind_tab_file);
        i_fam         = wavemngr('indw',in2);
        out1          = wnoblank(tab_file(i_fam,:));

elseif  strcmp(option,'type')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_type      = wmemutil('get',Wavelets_Info,ind_tab_type);
        i_fam         = wavemngr('indw',in2);
        out1          = tab_type(i_fam,:);

elseif  strcmp(option,'info')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_file      = wmemutil('get',Wavelets_Info,ind_tab_file);
        tab_type      = wmemutil('get',Wavelets_Info,ind_tab_type);
        i_fam         = wavemngr('indw',in2);
        out1          = tab_type(i_fam,:);
        out2          = wnoblank(tab_file(i_fam,:));

elseif  strcmp(option,'wfln')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_fn        = wmemutil('get',Wavelets_Info,ind_tab_fn);
        i_fam         = wavemngr('indw',in2);
        out1          = tab_fn(i_fam,:);

elseif  strcmp(option,'user')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_type      = wmemutil('get',Wavelets_Info,ind_tab_type);
        tab_user      = wmemutil('get',Wavelets_Info,ind_tab_user);
        i_fam         = wavemngr('indw',in2);
        out1          = tab_user(i_fam,:);
        if tab_type(i_fam)==3 | tab_type(i_fam)==4
                len   = length(out1);
                ind   = findstr(' ',out1);
                out2  = str2num(out1(ind+1:len));
                out1        = str2num(out1(1:ind-1));
        end

elseif  strcmp(option,'create')
        clear global Wavelets_Info
        beg_fam       = 'Family Name : ';
        new_line      = setstr(10);
        Wavelets_Info = wmemutil('def',nb_stored);
        fid           = fopen(asc_file);
        if fid==-1
                fid   = fopen(asc_ini_file); 
                winfo = fread(fid);
                fclose(fid);
                fid   = fopen(asc_file,'w');
                fwrite(fid,winfo); 
                fclose(fid);
        else
                winfo = fread(fid);
                fclose(fid);
        end
        winfo = setstr(winfo');

        ind10 = find(winfo==10);
        ind13 = find(winfo==13);
        if      isempty(ind13)
                Chrline = 10;
        elseif  isempty(ind10)
                Chrline = 13;
        else
                Chrline = [13 10];
        end
        newline = setstr(Chrline);
        lennewl = length(newline);

        first     = findstr(beg_fam,winfo)+length(beg_fam);
        nb_fam    = length(first);
        ind_new_l = findstr(newline,winfo);

        tab_fn    = [];
        tab_fsn   = [];
        tab_num   = [];
        tab_file  = [];
        tab_type  = [];
        tab_user  = [];
        tab_beg   = zeros(nb_fam,1);
        tab_end   = zeros(nb_fam,1);

        i_beg = 1;
        for j = 1:nb_fam
                i_fam    = first(j);
                indexs   = find(ind_new_l>i_fam);
                indexs   = ind_new_l(indexs(1:nb_InfoByWave));
                fam      = winfo(i_fam:indexs(1)-1);
                sname    = winfo(indexs(1)+lennewl:indexs(2)-1);
                wtype    = winfo(indexs(2)+lennewl:indexs(3)-1);
                nums     = winfo(indexs(3)+lennewl:indexs(4)-1);
                fname    = winfo(indexs(4)+lennewl:indexs(5)-1);
                user     = winfo(indexs(5)+lennewl:indexs(6)-1);

                tab_fn   = str2mat(tab_fn,fam);
                tab_fsn  = str2mat(tab_fsn,sname);
                tab_type = str2mat(tab_type,wtype);
                tab_file = str2mat(tab_file,fname);
                tab_user = str2mat(tab_user,user);

                notspace = ~isspace(nums);
                lnot     = length(notspace);
                index1   = find(notspace==1);
                k0       = index1(1);
                k1       = index1(length(index1));
                indnum   = diff(notspace);
                fnum     = find(indnum==1)+1;
                lnum     = find(indnum==-1);
                if k0==1 ,     fnum = [1 fnum];   end
                if k1==lnot ,  lnum  = [lnum k1]; end
                nb_num   = length(fnum);
                for p = 1:nb_num
                        tab_num = str2mat(tab_num,nums(fnum(p):lnum(p)));
                end
                tab_beg(j) = i_beg;
                tab_end(j) = i_beg+nb_num-1;
                i_beg      = tab_end(j)+1;
        end
        tab_fn        = tab_fn(2:nb_fam+1,:);
        tab_fsn       = tab_fsn(2:nb_fam+1,:);
        tab_type      = str2num(tab_type(2:nb_fam+1,:));
        tab_num       = tab_num(2:size(tab_num,1),:);
        tab_file      = tab_file(2:nb_fam+1,:);
        tab_user      = tab_user(2:nb_fam+1,:);

        Wavelets_Info = wmemutil('def',nb_stored);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_beg,tab_beg);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_end,tab_end);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_file,tab_file);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_type,tab_type);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_user,tab_user);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_fsn,tab_fsn);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_fn,tab_fn);
        Wavelets_Info = wmemutil('set',Wavelets_Info,ind_tab_num,tab_num);

        err = 0;
        eval(['save ' bin_file ' Wavelets_Info'],'err = 1;');
        if err
                errargt('wavemngr','Changing Wavelets : Save FAILED !','msg');
        end

elseif  strcmp(option,'read')
        if isempty(Wavelets_Info) , Wavelets_Info = wavemngr('load'); end
        tab_fn          = wmemutil('get',Wavelets_Info,ind_tab_fn);
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        tab_beg         = wmemutil('get',Wavelets_Info,ind_tab_beg);
        tab_end         = wmemutil('get',Wavelets_Info,ind_tab_end);
        tab_num         = wmemutil('get',Wavelets_Info,ind_tab_num);
        nb_fam          = size(tab_fn,1);
        sep_fam         = '=';
        sep_fam         = sep_fam(:,ones(1,35));
        sep_num         = '-';
        sep_num         = sep_num(:,ones(1,30));
        out1            = sep_fam; 
        tab             = setstr(9);
        if      nargin==1
                for k =1:nb_fam
                        out1 = str2mat(out1,[tab_fn(k,:) tab tab tab_fsn(k,:)]);
                end
                out1 = str2mat(out1,sep_fam); 
        else
                for k =1:nb_fam
                        out1   = str2mat(out1,[tab_fn(k,:) tab tab tab_fsn(k,:)]);
                        sfname = wnoblank(tab_fsn(k,:));
                        nb     = 0;
                        wnames = [];
                        if tab_end(k)>tab_beg(k)
                                out1 = str2mat(out1,sep_num); 
                        end
                        for j = tab_beg(k):tab_end(k)
                                num_str = wnoblank(tab_num(j,:));
                                if ~strcmp(num_str,'no')
                                        wnames  = [wnames sfname wnoblank(tab_num(j,:)) tab];
                                end
                                if nb<3
                                        nb      = nb+1;
                                else
                                        if ~isempty(wnames)
                                                out1 = str2mat(out1,wnames);
                                        end
                                        nb      = 0;
                                        wnames  = [];        
                                end
                        end
                        if nb>0 &  ~isempty(wnames)
                                out1 = str2mat(out1,wnames);
                        end
                        out1 = str2mat(out1,sep_fam); 
                end
        end

elseif  strcmp(option,'read_asc')
        fid   = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        out1  = setstr(winfo');

elseif  strcmp(option,'add')
        clear global Wavelets_Info
        Wavelets_Info   = wavemngr('load');
        tab_fn          = lower(wmemutil('get',Wavelets_Info,ind_tab_fn));
        tab_fsn         = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        nb_fam          = size(tab_fn,1);
        err = 0;
        if isempty(in2)
                err = 1; 
                msg = 'Wavelet Family Name is empty !';        
        else
                name = deblankl(in2);
                for k = 1:nb_fam
                        if strcmp(name,wnoblank(tab_fn(k,:)))
                                err = 1;
                                msg = 'Invalid Wavelet Family Name !';
                                break;
                        end
                end
        end
        if err==0
                if isempty(in3)
                        err = 1; 
                        msg = 'Wavelet Family Short Name is empty !';        
                else
                        in3  = deblankl(in3);
                        for k = 1:nb_fam
                                if strcmp(in3,wnoblank(tab_fsn(k,:)))
                                        err = 1;
                                        msg = 'Invalid Wavelet Family Short Name !';
                                        break;
                                end
                        end
                end
        end

        if err==0
                if isempty(find(in4==[1 2 3 4]))
                        err = 1;
                        msg = 'Invalid Wavelet Type !';
                end
        end

        if err==0
                if isempty(in5) , in5 = 'no'; end
                if      isempty(in6)
                        err = 1;
        
                elseif  findstr('.mat',in6)
                
                else 
                        in6 = deblankl(in6);
                        ind = findstr('.m',in6);
                        if ind>0 , in6 = in6(1:ind-1); end
                        if isempty(in6) , err = 1; end                
                end
                if err==1
                        msg = 'Invalid Wavelet File Name !';
                end
        end
        if err==0
                if     find(in4==[1 2])
                        if nargin==6 , in7 = ''; end
                elseif find(in4==[3 4])
                        if nargin==6
                                err = 1;
                                msg = 'Invalid number of arguments !';
                        else
                                if        length(in7)~=2, err = 1;
                                elseif    in7(1)>in7(2),  err = 1;
                                end
                                if err==1
                                        msg = 'in7 : Invalid type of argument !';
                                end
                        end
                end
        end
        if err
                msg = str2mat('Add New Wavelet FAILED !!',msg);
                errargt('wavemngr',msg,'msg');
                return                 
        end

        fid   = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        fid   = fopen(sav_file,'w');
        fwrite(fid,winfo);
        fclose(fid);

        ind10 = find(winfo==10);
        ind13 = find(winfo==13);
        if      isempty(ind13)
                Chrline = 10;
        elseif  isempty(ind10)
                Chrline = 13;
        else
                Chrline = [13;10];
        end

        beg_fam        = 'Family Name : ';
        sep_fam        = '------------------------';

        in4 = int2str(in4);
        if ~isempty(in7)
                in7 = [num2str(in7(1)) ' ' num2str(in7(2))];
        end

        winfo        = [winfo(1:length(winfo)-1);           Chrline;...
                        abs(beg_fam');  abs(in2(:));        Chrline;...
                        abs(in3(:));                        Chrline;...
                        abs(in4(:));                        Chrline;...
                        abs(in5(:));                        Chrline;...
                        abs(in6(:));                        Chrline;...
                        abs(in7(:));                        Chrline;...
                        abs(sep_fam');                      Chrline...
                        ];

        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');

elseif  strcmp(option,'del')
        clear global Wavelets_Info
        Wavelets_Info  = wavemngr('load');
        tab_fn         = lower(wmemutil('get',Wavelets_Info,ind_tab_fn));
        tab_fsn        = wmemutil('get',Wavelets_Info,ind_tab_fsn);
        nb_fam         = size(tab_fn,1);
        err            = 0;
        i_fam          = 0;
        if isempty(in2)
                err = 1; 
                msg = 'Wavelet Family (Short) Name is empty !';        
        else
                name = deblankl(in2);
                for k = 1:nb_fam
                        if strcmp(name,wnoblank(tab_fn(k,:)))
                                i_fam = k;
                                break;
                        end
                end
                if i_fam==0
                        for k = 1:nb_fam
                                if strcmp(name,wnoblank(tab_fsn(k,:)))
                                        i_fam = k;
                                        break;
                                end
                        end
                end
        end
        if err==0
                if      i_fam==0
                        err = 1;
                        msg = 'Invalid Wavelet Family (Short) Name !';
                elseif  i_fam<=NB_FamInWTB
                        err = 1;
                        msg = ['You can''t delete ' tab_fn(i_fam,:) ' Wavelet Family !'];        
                end
        end
        if err
                errargt('wavemngr',msg,'msg');
                return 
        end

        fid   = fopen(asc_file);
        if fid==-1 , fid = fopen(asc_ini_file); end
        winfo = fread(fid);
        fclose(fid);
        fid   = fopen(sav_file,'w');
        fwrite(fid,winfo);
        fclose(fid);

        ind10 = find(winfo==10);
        ind13 = find(winfo==13);
        if      isempty(ind13)
                Chrline = 10;
        elseif  isempty(ind10)
                Chrline = 13;
        else
                Chrline = [13 10];
        end
        newline     = setstr(Chrline);

        str_winfo   = setstr(winfo');
        beg_fam     = 'Family Name : ';
        first       = findstr(beg_fam,str_winfo);
        first       = first(i_fam);
        ind_new_l   = findstr(newline,str_winfo);
        indexs      = find(ind_new_l>first);
        indexs      = ind_new_l(indexs(1:nb_InfoByWave+1));
        last        = indexs(nb_InfoByWave+1)+length(Chrline)-1;

        winfo(first:last) = [];
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');

elseif  strcmp(option,'restore')
        clear global Wavelets_Info
        if nargin==1
                fid   = fopen(sav_file);
                if fid==-1 , fid = fopen(asc_ini_file); end
                winfo = fread(fid);
                fclose(fid);
        else
                fid   = fopen(asc_ini_file);
                winfo = fread(fid);
                fclose(fid);                
        end
        fid = fopen(asc_file,'w');
        fwrite(fid,winfo);
        fclose(fid);
        wavemngr('create');
        
%********************%
%** UNKNOWN OPTION **%
%********************%
else
        errargt('wavemngr','Unknown Option','msg');
        error('*');
end