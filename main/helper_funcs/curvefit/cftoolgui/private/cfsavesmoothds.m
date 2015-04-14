function cfsavesmoothds(varnames,dataset)
%CFSAVESMOOTHDS

%   Copyright 2001-2004 The MathWorks, Inc.

% CFSAVESMOOTHDS(VARNAMES,DATASET)

% results = cfgetset('analysisresults');
% if isempty(results) | ~isstruct(results) | ~isfield(results,'x') ...
%                     | isempty(results.x)
%    uiwait(warndlg('No analysis results available.',...
%                   'Save to Workspace','modal'));
% else
%    assignin('base',varnames{1},results);
% end

ds = handle(dataset);
out.x = ds.x;
out.y = ds.y;
assignin('base',varnames{1},out);
