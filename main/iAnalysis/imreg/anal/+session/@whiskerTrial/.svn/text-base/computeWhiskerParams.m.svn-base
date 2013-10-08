%
% SP Nov 2010
%
% Method for running all post-linking steps: bar tracking, whisker polynomials, kappa and 
%   theta, and finally contact detection.
%
% USAGE:
%
%   wt.computeWhiskerParams(skipBarTrack)
%
% PARAMS:
%
%   skipBarTrack: default 0 ; if passed as 1, trackBar is not run.
%
function computeWhiskerParams(obj, skipBarTrack)
  if (nargin < 2) ; skipBarTrack = 0; end

  % all hinges on bar template ...
	baseDir = fileparts(obj.whiskerMoviePath);
	barTemplatePath = [baseDir filesep 'barTemplate.mat'];
	obj.computeWhiskerPolys();
	obj.computeKappas();
	obj.computeThetas();
	if (exist(barTemplatePath, 'file'))
		if (~skipBarTrack) ; obj.trackBar(barTemplatePath);end
		obj.computeDistanceToBar();
		obj.detectContactsWrapper();
		obj.computeDeltaKappasWrapper();
	else
	  disp(['computeWhiskerParams::' barTemplatePath ' does not exist -- a valid bar template is needed for bar, distance therto, contacts.']);
	end

