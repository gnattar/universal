function [hFit, name, isgood, outlier, dataset] = cfcopyfit(sourcefit)
%CFCOPYFIT Copy cftool fit

%   Copyright 2004 The MathWorks, Inc.

hFit = copyfit(sourcefit);
name = hFit.name;
isgood = hFit.isGood;
outlier = hFit.outlier;
dataset = hFit.dataset;
hFit = java(hFit);

