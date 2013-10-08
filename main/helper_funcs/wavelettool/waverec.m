function x = waverec(c,l,arg3,arg4)
%WAVEREC Multi-level 1-D wavelet reconstruction.
%       WAVEREC performs a multi-level 1-D wavelet reconstruction
%       using either a specific wavelet ('wname', see WFILTERS) or
%       specific reconstruction filters (Lo_R and Hi_R).
%
%       X = WAVEREC(C,L,'wname') reconstructs the signal X
%       based on the multi-level wavelet decomposition structure
%       [C,L] (see WAVEDEC).
%
%       For X = WAVEREC(C,L,Lo_R,Hi_R),
%       Lo_R is the reconstruction low-pass filter and
%       Hi_R is the reconstruction high-pass filter.
%
%       See also APPCOEF, IDWT, WAVEDEC.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:19:40 $

%       Uses APPCOEF.

% Check arguments.
if errargn('waverec',nargin,[3:4],nargout,[0:1]), error('*'), end

if nargin == 3
        x = appcoef(c,l,arg3,0);
else
        x = appcoef(c,l,arg3,arg4,0);
end