%
% SP May 2011
%
% Method to invoke plotColorRois for multiple days with similar functionality.
%  Specifically, you can use the 'custom' modes.
%
%  USAGE:
%
%    sA.plotColorRoisCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    sessions: vector of session indices to use, within sessionArray
% 
%    plotMode: this is 'maxDff', 'eventCount' ,'eventRate', 'burstRate'
%    trialTypes: if specified, restrict to trials of given types (validTrialIds)
%               blank means no restriction (by blank, I always mean [])
%    colorMap: which colormap to use - default is 'human readable' (blank)
%    colorBasisVecRange: by default, colormap spans min(colorBasisVec) to max.If
%                        you want to span a FIXED range, give it here (that is,
%                        if you want to make the max color of colormap corespodn
%                        to a value other than max(colorBasisVec)).
%    drawColorBar: default is 0 ; if set to 1, will make colorbars
%
function plotColorRoisCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotColorRoisCrossDays');
		return;
	end

	% dflts
	sessions=1:length(obj.sessions);
	plotMode = 'eventRate';
	trialTypes = [];
	colorMap = [linspace(0,1,256)' linspace(0,0,256)' linspace(0,0,256)'];
	colorMap = jet(256);
	colorBasisVecRange = [];
	drawColorBar = 0;


	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'plotMode')) ; plotMode = params.plotMode; end
	if (isfield(params, 'colorMap')) ; colorMap = params.colorMap; end
	if (isfield(params, 'colorBasisVecRange')) ; colorBasisVecRange = params.colorBasisVecRange; end
	if (isfield(params, 'drawColorBar')) ; drawColorBar = params.drawColorBar; end

	% --- session plotter for ALL rois

	% size constraints
	Ns = ceil(sqrt(length(sessions)));

	% session looop
	ci = 1;
	ri =1;
	for si=1:length(sessions)
		axRef = subplot('Position', [(ci-0.8)*(1/Ns) 1-((ri-0.1)*(1/Ns)) 0.8/Ns 0.8/Ns]);
		obj.sessions{sessions(si)}.plotColorRois(plotMode,trialTypes,[],colorMap,[],colorBasisVecRange, axRef, drawColorBar);

		% date?
		title(obj.dateStr{sessions(si)});
		
		% increment col
		ci = ci+1 ; if (ci > Ns) ; ci = 1; ri = ri + 1; end
	end

