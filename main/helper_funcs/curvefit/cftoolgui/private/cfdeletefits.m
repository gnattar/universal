function cfdeletefits(fits)
%CFDELETEFITS Helper function to delete Curve Fitting fits

%   Copyright 2001-2004 The MathWorks, Inc.


delete([fits{:}]);
cfupdatelegend(cfgetset('cffig'));
