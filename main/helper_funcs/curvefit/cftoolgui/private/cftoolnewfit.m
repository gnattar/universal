function [hFit, name, isgood] = cftoolnewfit()
%CFCREATEFIT Create cftool fit

%   Copyright 2004 The MathWorks, Inc.

hFit = cftool.fit;
name = hFit.name;
isgood = hFit.isGood;
hFit = java(hFit);

