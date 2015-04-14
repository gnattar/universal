function [array] = cfgetarray(uddobj, field)
% CFSETARRAY is a helper function for the cftool GUI. 
% It will set the FIELD of the UDDOBJ to ARRAY
% This function will be made obsolete when we are able to
% setPropertyValues of type Matlab array directly from JAVA 

% Copyright 2001-2004 The MathWorks, Inc.

o = handle(uddobj);
array = get(o, field);
