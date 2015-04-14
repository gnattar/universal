function cfsaveanalysis(varnames, data)
%CFSAVEANALYSIS saves analysis information to the workspace
%This is a helper function for the Curve Fitting tool

%   Copyright 2001-2011 The MathWorks, Inc.

results = cfgetset('analysisresults');
if isempty(results) || ~isstruct(results) || ~isfield(results,'xi') ...
                    || isempty(results.xi)
   uiwait(warndlg(getString(message('curvefit:cftoolgui:NoAnalysisResultsAvailable')),...
                  getString(message('curvefit:cftoolgui:SaveToWorkspace')),'modal'));
else
   assignin('base',varnames{1},results);
end


