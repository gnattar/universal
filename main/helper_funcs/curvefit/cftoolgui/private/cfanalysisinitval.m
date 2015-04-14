function initstr = cfanalysisinitval(fit)
% CFANALYSISINITVALS is a helper function for the cftool GUI. Given a FIT, 
% it returns INITSTR which will be the initial value displayed in the 
% Curve Fitting Tool Analysis Evaluate at Xi field

% Copyright 2001-2004 The MathWorks, Inc.

try
   fitobj = handle(fit);
   datasetname = get(fitobj, 'dataset');
   datasetobj = find(getdsdb,'name',datasetname);
   x = getxdata(datasetobj,fitobj.outlier);
   inc = ((max(x) - min(x))/10);
   initstr = sprintf('%g:%g:%g', min(x), inc, max(x));
catch
   initstr = '';
end

