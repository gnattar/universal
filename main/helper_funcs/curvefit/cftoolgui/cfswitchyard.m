function varargout = cfswitchyard(action,varargin)
% CFSWITCHYARD is a helper function for CFTOOL

% CFSWITCHYARD switchyard for Curve Fitting.

%   Copyright 2001-2007 The MathWorks, Inc.

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
