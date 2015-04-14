function thedsdb=getdsdb(varargin)
% GETDSDB is a helper function for CFTOOL

% GETDSDB Get the data set data base (singleton)

%   Copyright 2000-2007 The MathWorks, Inc.


thedsdb = cfgetset('thedsdb');

% Create a singleton class instance
if isempty(thedsdb)
   thedsdb = cftool.dsdb;
   cfgetset('thedsdb',thedsdb);
end


