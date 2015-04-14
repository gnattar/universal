function allfits = cfgetallfits
%GETALLFITS Returns a cell array containing all fits

%   Copyright 2001-2004 The MathWorks, Inc.

fitdb=getfitdb;
child=down(fitdb);
allfits = {};
while ~isempty(child)
   allfits{length(allfits)+1} = child;
   child=right(child);
end
