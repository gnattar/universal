function [X, Y, W] = cfviewdata(dataset)
% CFVIEWDATA Helper function for the Curve Fitting toolbox viewdata panel
%
%    [X, Y, W] = CFVIEWDATA(DATASET)
%    returns the x, y and w values for the given dataset
%	 (in a manner that the Java GUI can use)

%   Copyright 2001-2004 The MathWorks, Inc. 

ds = handle(dataset);
X = ds.x;
Y = ds.y;
W = ds.weight;
