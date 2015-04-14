function [fitname, goodnessname, outputname] = cffitsavenames(fitprefix, goodnessprefix, outputprefix)
% CFFITSAVENAMES Creates unique variable names for save fit.  

%   Copyright 2001-2004 The MathWorks, Inc.

fitname = cfgetuniquewsname(fitprefix);
goodnessname = cfgetuniquewsname(goodnessprefix);
outputname = cfgetuniquewsname(outputprefix);
