function [out1,out2,out3,out4,out5,out6,out7,out8] = biorfilt(Df,Rf,in3)
%BIORFILT Biorthogonal wavelet filter set.
%       The BIORFILT command returns either four or eight filters
%       associated with biorthogonal wavelets.
%
%       [LO_D,HI_D,LO_R,HI_R] = BIORFILT(DF,RF) computes four
%       filters associated with biorthogonal wavelet specified
%       by decomposition filter DF and reconstruction filter RF.
%       These filters are:
%       LO_D  Decomposition low-pass filter
%       HI_D  Decomposition high-pass filter
%       LO_R  Reconstruction low-pass filter
%       HI_R  Reconstruction high-pass filter
%
%       [LO_D1,HI_D1,LO_R1,HI_R1,LO_D2,HI_D2,LO_R2,HI_R2] = 
%                               BIORFILT(DF,RF,'8')
%       returns eight filters, the first four associated with
%       the decomposition wavelet and the last four associated
%       with the reconstruction wavelet.
%
%       See also BIORWAVF, ORTHFILT.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:05:46 $

%       Uses ERRARGN, ORTHFILT.

% Check arguments.
if errargn('biorfilt',nargin,[2 3],nargout,[0 4 8]), error('*'); end

% The filters must be of the same even length.
lr = length(Rf);
ld = length(Df);
lmax = max(lr,ld);
if rem(lmax,2) , lmax = lmax+1; end
Rf = [zeros(1,floor((lmax-lr)/2)) Rf zeros(1,ceil((lmax-lr)/2))];
Df = [zeros(1,floor((lmax-ld)/2)) Df zeros(1,ceil((lmax-ld)/2))];

if      nargin==2
        [out1,hif_db,lof_ub,out4] = orthfilt(Df);
        [lof_db,out2,out3,hif_ub] = orthfilt(Rf);
elseif  nargin==3
        [out1,out2,out3,out4] = orthfilt(Df);
        [out5,out6,out7,out8] = orthfilt(Rf);
end