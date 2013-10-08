function [LoF_D,HiF_D,LoF_R,HiF_R] = orthfilt(W)
%ORTHFILT Orthogonal wavelet filter set.
%       [LO_D,HI_D,LO_R,HI_R] = ORTHFILT(W) computes the
%       four filters associated with the scaling filter W 
%       corresponding to a wavelet:
%       LO_D = decomposition low-pass filter
%       HI_D = decomposition high-pass filter
%       LO_R = reconstruction low-pass filter
%       HI_R = reconstruction high-pass filter.
%
%       See also BIORFILT, QMF, WFILTERS.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:15:01 $

%       Uses ERRARGN, QMF, WREV.

% Check arguments.
if errargn('orthfilt',nargin,[1],nargout,[0:4]), error('*'); end

% Normalize filter sum.
W = W/sum(W);

% Associated filters.
LoF_R = sqrt(2)*W;
HiF_R = qmf(LoF_R);
HiF_D = wrev(HiF_R);
LoF_D = wrev(LoF_R);