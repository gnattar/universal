function cftoolDeleteDataSet(name)
%CFTOOLDELETEDATASET   Delete a data set from the data set database
%
%   CFTOOLDELETEDATASET(NAME)

%   Copyright 2007 The MathWorks, Inc.

dsdb = getdsdb;
h = find( dsdb, 'name', name );
delete( h );
