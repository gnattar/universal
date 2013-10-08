function [c,l] = wavedec(x,n,arg3,arg4)
%WAVEDEC Multi-level 1-D wavelet decomposition.
%       WAVEDEC performs a multi-level 1-D wavelet analysis
%       using either a specific wavelet ('wname' see WFILTERS)
%       or specific wavelet decomposition filters.
%
%       [C,L] = WAVEDEC(X,N,'wname') returns the wavelet
%       decomposition of the signal X at level N, using 'wname'.
%
%       N must be a strictly positive integer (see WMAXLEV).
%       The ouput decomposition structure contains the wavelet
%       decomposition vector C and the bookkeeping vector L.
%
%       For [C,L] = WAVEDEC(X,N,Lo_D,Hi_D),
%       Lo_D is the decomposition low-pass filter and
%       Hi_D is the decomposition high-pass filter.
%
%       The structure is organized as:
%       C      = [app. coef.(N)|det. coef.(N)|... |det. coef.(1)]
%       L(1)   = length of app. coef.(N)
%       L(i)   = length of det. coef.(N-i+2) for i = 2,...,N+1
%       L(N+2) = length(X).
%
%       See also DWT, WAVEINFO, WFILTERS, WMAXLEV.

%       M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%       Copyright (c) 1995-96 by The Mathworks, Inc.
%       $Revision: 1.1 $  $Date: 1996/03/05 21:18:53 $

%       Uses DWT, WFILTERS.

% Check arguments.
if errargn('wavedec',nargin,[3:4],nargout,[0:2]), error('*'), end
if errargt('wavedec',n,'int'), error('*'), end
if nargin==3
        [LoF_D,HiF_D] = wfilters(arg3,'d');             
else
        LoF_D = arg3;   HiF_D = arg4;
end

% Initialization.
s = size(x);    x = x(:)';              % row vector
c = [];         l = [length(x)];

for k = 1:n
        [x,d] = dwt(x,LoF_D,HiF_D);     % decomposition
        c     = [d c];                  % store detail
        l     = [length(d) l];          % store length
end

% Last approximation.
c = [x c];
l = [length(x) l];

if s(1)>1, c = c'; l = l'; end