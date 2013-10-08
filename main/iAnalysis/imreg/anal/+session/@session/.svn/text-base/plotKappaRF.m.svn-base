%
% SP Jan 2011
%
% Plots a cell's df/f receptive field in terms of whisker kappa.  Looks for 
%  contacts and uses these as events.
%
% USAGE:
% 
%   obj.plotKappaRF(whiskerIdx, roiId, params, plotRFParams,axHandle)
%
%    whiskerIdx: index within whiskerTag structure ; assumed to be consistent
%                with all the whiskerCurvatureChangeTSA stuff etc.  If you pass
%                a NEGATIVE number, it will use the positive value AND exclude
%                contacts by other whiskers.
%    roiId: id of ROI to hit
%    params: additional params if you want something more compleX
%            contactType: 1 (default): all ; 2: pro 3: retraction
%            trialContactNumber: by default, uses all contacts in a trial; 
%                                if specified, it will use a particular one. 
%                                Inf: last.  'max' - strongest contact.
%            useStringentDKappa: default is 0 (not 2 use only contacts with large
%                                dKappa, computed here).  Otherwise, it will
%                                use s.whiskerBarContactESA
%            caTimeWindow: time window, in s, around the contact events used
%                          for calcium.  Default is [0 2] meaning from contact
%                          to 2 seconds out.  Specify a SINGLE value and it will
%                          do that value +/- dt/2.  IN SECONDS.
%            kappaTimeWindow: time window to compute kappa around the touch;
%                             default is [-2 2].  IN SECONDS.
%            caMode, kappaMode: what to compute for df/f or kappa: mean, max, 
%                               maxabs, meanabs.  Default is maxabs for kappa 
%                               and max for df/f
%            excludeOthers: default 0 ; if 1, will exclude, for a given ESA
%                           member, any other ESA members
%    plotRFParams: plotRFParams for session.plotRF
%    axHandle: axis handle for plot    
%
function plotKappaRF (obj, whiskerIdx, roiId, params, plotRFParams, axHandle)
	% --- process user input
	if (nargin < 3)
	  disp('plotKappaRF::must at least specify whisker index, roiId.');
		return;
	end

	% process params -- start w/ defaults
	trialContactNumber = 0; % don't use contact #
  useStringentDKappa = 0;
	caTimeWindow = [0 2];
	kappaTimeWindow = [-2 2];
	caMode = 'max';
	kappaMode = 'maxabs';
	contactType = 1;
	excludeOthers = 0;
	if (nargin >= 4 && isstruct(params)) % pull values in this case
	  if (isfield(params,'contactType')) ; contactType = params.contactType; end
	  if (isfield(params,'trialContactNumber')) ; trialContactNumber = params.trialContactNumber; end
	  if (isfield(params,'useStringentDKappa')) ; useStringentDKappa = params.useStringentDKappa; end
	  if (isfield(params,'caTimeWindow')) ; caTimeWindow = params.caTimeWindow; end
	  if (isfield(params,'kappaTimeWindow')) ; kappaTimeWindow = params.kappaTimeWindow; end
	  if (isfield(params,'kappaMode')) ; kappaMode = params.kappaMode; end
	  if (isfield(params,'caMode')) ; caMode = params.caMode; end
	  if (isfield(params,'excludeOthers')) ; excludeOthers = params.excludeOthers; end
  end

  % build plotRFParams
	if (nargin < 5 || ~isstruct(plotRFParams)) % assign all defaults
		plotRFParams.binSize = 5;
	end
	if (~isfield(plotRFParams, 'binSize')) ; plotRFParams.binSize = 5 ; end

  % figure
	if (nargin < 6 || length(axHandle) == 0)
	  figure;
		N = ceil(sqrt(length(whiskerIdx)));
		for a=1:length(whiskerIdx)
		  axHandle(a) = subplot(N,N,a);
		end
	end

  % adjust whiskerIdx for pro/ret
	if (contactType == 2)
	  whiskerIdx = 2*whiskerIdx - 1;
		baseESA=obj.whiskerBarContactClassifiedESA;
	elseif (contactType == 3)
	  whiskerIdx = 2*whiskerIdx;
		baseESA=obj.whiskerBarContactClassifiedESA;
	else
	  baseESA = obj.whiskerBarContactESA;
	end

	% negative whiskerIdx? (exclude)
	exclude = 0*whiskerIdx;
	negIdx = find(whiskerIdx<0);
	exclude(negIdx) = 1;
	whiskerIdx = abs(whiskerIdx);

  r = find(obj.caTSA.ids == roiId);
  % --- whisker loop
	for wi=1:length(whiskerIdx)
	  ew = whiskerIdx(wi);
		if (contactType == 3 | contactType == 2)
			w = ceil(whiskerIdx(wi)/2);
		else % 1
		  w = whiskerIdx(wi);
		end

    % --- get the data

    % more stringent 'contact' criteria -- large dkappa
		if (useStringentDKappa)
			mtoptions.trialIndices = obj.whiskerCurvatureChangeTSA.trialIndices;
			mtoptions.trialIds = obj.trialIds;
			mtoptions.trialStartTimes = obj.trialStartTimes;
			mtoptions.trialStartOffsetWindow = [1 3];
			es = session.timeSeries.getEventSeriesFromMADThreshS(obj.whiskerCurvatureChangeTSA.getTimeSeriesByIdx(w), [-5 5], mtoptions);
		else
		  es = baseESA.esa{ew};
		end

    % exclude events
		if (exclude(wi))
			xes = baseESA.getExcludedCellArray(ew);
		else
			xes = [];
		end

    ESA = session.eventSeriesArray({es},baseESA.trialTimes, 1);

		% restrict force calculation to actual contact epoch
    obj.plotPeriEventRF(obj.whiskerCurvatureChangeTSA, obj.whiskerCurvatureChangeTSA.ids(w), kappaTimeWindow, kappaMode, ...
                        obj.caTSA.dffTimeSeriesArray, r, caTimeWindow, caMode, ...
												ESA, 1, [], trialContactNumber, xes, [-3 3], excludeOthers, ...
  											plotRFParams, axHandle(wi), 1, 0);
	end
