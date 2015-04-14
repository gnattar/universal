function minmax=xlim(fit)
%XLIM Return the X data limits for this fit

%   Copyright 2001-2005 The MathWorks, Inc.


ds = fit.dshandle;
if ~isempty(ds) && ~isempty(ds.x)
   x = getxdata(ds,fit.outlier);
   minmax = [min(x) max(x)];
else
   minmax = [];
end

