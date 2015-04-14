function cftoolDeleteOutlier(name)
%CFTOOLDELETEOUTLIER   Delete an exclusion rule from the outlier database
%
%   CFTOOLDELETEOUTLIER(NAME)

%   Copyright 2007 The MathWorks, Inc.

outdb = getoutlierdb;
h = find( outdb, 'name', name );
delete( h );
