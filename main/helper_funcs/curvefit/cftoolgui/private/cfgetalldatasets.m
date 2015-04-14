function allds = cfgetalldatasets
%GETALLDATASETS Returns a cell array containing all datasets

%   Copyright 2001-2004 The MathWorks, Inc.

dsdb=getdsdb;
child=down(dsdb);
allds = {};
while ~isempty(child)
   allds{length(allds)+1} = child;
   child=right(child);
end
