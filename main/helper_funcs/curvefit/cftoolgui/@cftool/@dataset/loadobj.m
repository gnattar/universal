function ds = loadobj(ds)
%LOADOBJ Load filter for cftoo.dataset objects
%
%   DS = LOADOBJ(DS)

%   Copyright 2009 The MathWorks, Inc.

NONE = cfswitchyard( 'cfGetNoneString' );

% If the weights are named NONE but there are actually weights, then we need to
% give the weights a name
if ~isempty( ds.weight ) && isequal( ds.weightname, NONE )
    ds.weightname = 'w';
end


end
