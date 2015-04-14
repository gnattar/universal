function [results] = cftoolgetresults(cftoolFit, newName)
%CFTOOLGETRESULTS Records new fit name and returns results.

%   Copyright 2004 The MathWorks, Inc.

cftoolFit=handle(cftoolFit);
cftoolFit.name=newName;
results = cftoolFit.results;

