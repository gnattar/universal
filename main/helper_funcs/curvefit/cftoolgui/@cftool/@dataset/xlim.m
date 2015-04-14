function minmax = xlim(ds)
%XLIM Return the X data limits for this dataset

% Copyright 2001-2004 The MathWorks, Inc.


if isempty(ds.x)
   minmax = [];
else
   minmax = [min(ds.x), max(ds.x)];
end
