function [out1,out2,out3,out4,out5,out6,out7,out8] = wfilters(wname,o)
%WFILTERS Wavelet filters.
%       [LO_D,HI_D,LO_R,HI_R] = WFILTERS('wname') computes four
%       filters associated with the orthogonal or biorthogonal
%       wavelet named in the string 'wname'. 
%       The four output filters are:
%               LO_D, the decomposition low-pass filter
%               HI_D, the decomposition high-pass filter
%               LO_R, the reconstruction low-pass filter
%               HI_R, the reconstruction high-pass filter
%       Available wavelet names 'wname' are:
%       Daubechies  : 'db1' or 'haar', 'db2', ... ,'db50'
%       Coiflets    : 'coif1', ... ,  'coif5'
%       Symlets     : 'sym2' , ... ,  'sym8'
%       Biorthogonal: 'bior1.1', 'bior1.3' , 'bior1.5'
%                     'bior2.2', 'bior2.4' , 'bior2.6', 'bior2.8'
%                     'bior3.1', 'bior3.3' , 'bior3.5', 'bior3.7' 
%                     'bior3.9', 'bior4.4' , 'bior5.5', 'bior6.8'.
%
%       [F1,F2] = WFILTERS('wname','type') returns the following
%       filters: 
%       LO_D and HI_D if 'type' = 'd' (Decomposition filters)
%       LO_R and HI_R if 'type' = 'r' (Reconstruction filters)
%       LO_D and LO_R if 'type' = 'l' (Low-pass filters)
%       HI_D and HI_R if 'type' = 'h' (High-pass filters)
%
%       See also BIORFILT, ORTHFILT, WAVEINFO.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:21:42 $

%       Uses BIORFILT, DEBLANKL, ORTHFILT, WAVEMNGR.

% Check arguments.
if errargn('wfilters',nargin,[1 2],nargout,[0 1 2 4 8]), error('*'); end
if errargt('wfilters',wname,'str') , error('*'), end

wname         = deblankl(wname);
[wtype,fname] = wavemngr('info',wname);
mat_f         = findstr('.mat',fname);
if mat_f
   err = 0;
   eval(['load ' fname],'err = 1;');
   if err
      msg = ['invalid wavelet file : ' fname];
      errargt('wfilters',msg,'msg');
      error('*');
      return;
   end
end

if      wtype==1                % orth. wavelet
        if ~isempty(mat_f)
                F = eval(wname);
        else
                F = feval(fname,wname);
        end
        [LoF_D,HiF_D,LoF_R,HiF_R] = orthfilt(F);

elseif  wtype==2                % biorth. wavelet
        if isempty(mat_f)
                [Rf,Df] = feval(fname,wname);
        else
                if exist('Rf')~=1 | exist('Df')~=1
                        msg = ['invalid biorthogonal wavelet file : ' fname];
                        errargt('wfilters',msg,'msg');
                        error('*');
                end
        end
        [LoF_D,HiF_D1,LoF_R1,HiF_R,LoF_D2,HiF_D,LoF_R,HiF_R2] = ...
                                biorfilt(Df,Rf,1);
        out5 = LoF_D2;        out6 = HiF_D1;
        out7 = LoF_R1;        out8 = HiF_R2;
end

if nargin==1
        out1 = LoF_D; out2 = HiF_D; out3 = LoF_R; out4 = HiF_R;
else
        o = lower(o(1));
        if      o=='d' , out1 = LoF_D; out2 = HiF_D;
        elseif  o=='r' , out1 = LoF_R; out2 = HiF_R;
        elseif  o=='l' , out1 = LoF_D; out2 = LoF_R;
        elseif  o=='h' , out1 = HiF_D; out2 = HiF_R;
        else    
                errargt('wfilters','invalid argument value','msg'); error('*');
        end
end