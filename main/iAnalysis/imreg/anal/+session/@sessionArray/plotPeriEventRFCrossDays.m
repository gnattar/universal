%
% SP Apr 2011
%
% This will plot stimulus and response TSAs as a function around the time of an 
%   event, using session.session.plotPeriEventRF.
%
% USAGE:
%
%  sA.plotPeriEventRFCrossDays(params)
%
%  params - structure with variables: [*: required]
%
%    sessions: which sessinos to use? dflt = all
%    nPanels: [nCols nRows] ; by default, both are ceil(sqrt(length(sessions)))
%    
%    *stimTSA: timeSeriesArray from which stimulus is drawn; string.  Uses
%             eval(['sA.sessions{si}.' stimTSA]) as stimTSA.
%    *stimTSId: ID of stimTSA timeSeries to use
%    *stimTimeWindow: from when, aroudn events in ES, should stimulus data be
%                    drawn?  In units of seconds.  0 is event time, so [0 2]
%                    would mean from 0 to 2000 ms after event.
%    stimMode: what value to pull from the time window?  permitted values are
%              specified in session.timeSeries.getSingleValueAroundEvents
%              (e.g., 'mean', 'meanabs', 'median' ,'max', 'min', 'maxabs', 'sum', 
%               'sumabs') ; default maxabs
%    stimValueRange: plotted value range ; otherwise axes untouched.
% 
%    *respTSA, *respTSId, *respTimeWindow, respMode, respValueRange: same as 
%        stimXXX but for the response ("y axis")
%  
%    *ESA: the event series array which determines data selection - a string,
%         which is eval'd as with stimTSA.
%    *ESId: which event serie(s) within ES to do?  will make plot per ES.  If
%          ESA is an eventSeriesArray, this can be a set of numbers, in which case
%          getEventSeriesById is called or a cell array of string in which case
%          getEventSeriesByIdStr is called.  If ESA is a cell array of
%          eventSeries, this must be numbers.  Default is all.
%    ESColor: either blank, in which case plotRFParams dictates color, or a
%             matrix of size (n,3) where n is length(ESId).  plotRFParams.color 
%             will be set to ESColor(n,3) for that ES.
%    trialEventNumber: which event (in a trial) to use; default is [] which means 
%                      ALL.  Inf means last, and max means having largest stimTSA
%                      amplitude.
%    xES: (optional -- [] if not used) - cell array of time series to exclude
%         if an event in ES overlaps with xES
%    xESTimeWindow: how big the overlap window is to apply exclusion ; in 
%                   seconds
%    excludeOthers: if set to 1, in addition to xES, will exclude members of ESA
%                   aside from ESId(i) when plotting ESId(i)
%
%    plotRFParams: plotRFParams for session.plotRF ; fields:
%      plotMethod: (*=default)
%        *'raw': plotParams blank, just plots raw data
%        'binByStim': makes equally spaced bins of size plotParams.binSize along 
%          stimulus axis.  Will plot SD and mean. If plotParams.firstBin is provided,
%          this is the value of the first bin's left edge.  Otherwise, min(stimulus).
%        'binByCount': makes bins, along stimulus axis, having fixed # of members
%          denoted by plotParams.binSize (default = 10)
% 
%    stim/respUseValueDuringEventOnly: for type 2 events, you can restrict the 
%                                      values during your time window that get 
%                                      sampled to those that occur during the 
%                                      event.  Default 1 for stim, 0 for resp.
%
%    labelMode: supplementary labels of the plot (e.g., to mark hit trials, etc.)
%               "ESA", "trialType", "lickRate", "trialFrac"
%    labelClasses: if labelMode ESA, a string that is eval'd to produce ESAs.
%                  if trialType, cell array of strings corresponding to trial
%                  types.  If lickRate, cell array of 2 element vectors specifying
%                  lick rate ranges.  If trialFrac, this should be a fractional
%                  range -- [0 0.5] would mean first 50% of trials, e.g.
%    labelClassId: used only if labelMode ESA, # or cell array of strings
%                  restricting which of the eventSeries in the ESA are used
%    labelColors: (n x 3) matrix with color for each label set.
%    labelESOverlapWindow: if labelMode ESA, how much of an overal fudge factor
%                          in seconsd to apply
%
% EXAMPLE: plot dF/F for ROI 2 as a function of sum abs kappa during pro/re c3 
%          contacts.
%
%   clear pparams;
%   figure;
%   pparams.respTSA = 'caTSA.dffTimeSeriesArray';
%   pparams.respTSId = 2;
%   pparams.respTimeWindow = [0 2];
%   pparams.respMode = 'max';
%   pparams.respValueRange = [-0.25 3];
%   pparams.stimTSA = 'whiskerCurvatureChangeTSA';
%   pparams.stimTSId = 'Curvature change for c3';
%   pparams.stimTimeWindow = [-0.1 0.5];
%   pparams.stimValueRange = [-0.5 1];
%   pparams.stimMode = 'sumabs';
%   pparams.ESA = 'whiskerBarContactClassifiedESA';
%   pparams.ESId = {'Protraction contacts for c3','Retraction contacts for c3'};
%   pparams.ESColor = [1 0 0 ; 0 0 1];
%   pparams.trialEventNumber = [];
%   sA.plotPeriEventRFCrossDays(pparams);
%
% Add exclusion of other contacts:
%   pparams.excludeOthers = 1;
%   pparams.xESTimeWindow = [-2 2];
%
%
% EXAMPLE: plot dF/F for ROI 2 as a function of sum abs kappa during pro/re c1-3 
%          contacts.
%
%   clear pparams;
%   figure;
%   pparams.respTSA = 'caTSA.dffTimeSeriesArray';
%   pparams.respTSId = 2;
%   pparams.respTimeWindow = [0 2];
%   pparams.respMode = 'max';
%   pparams.respValueRange = [-0.25 3];
%   pparams.stimTSA = 'whiskerCurvatureChangeTSA';
%   pparams.stimTSId = {'Curvature change for c1','Curvature change for c1', ...
%                       'Curvature change for c2','Curvature change for c2', ...
%                       'Curvature change for c3','Curvature change for c3'};
%   pparams.stimTimeWindow = [-0.1 0.5];
%   pparams.stimValueRange = [-0.5 1];
%   pparams.stimMode = 'sumabs';
%   pparams.ESA = 'whiskerBarContactClassifiedESA';
%   pparams.ESId = {'Protraction contacts for c1','Retraction contacts for c1', ...
%                   'Protraction contacts for c2','Retraction contacts for c2', ...
%                   'Protraction contacts for c3','Retraction contacts for c3'};
%   pparams.ESColor = [1 0 0 ; 1 0 1 ; 0 0 1 ; 0 1 1 ; 0.5 0.5 0.5 ; 0 0 0];
%   pparams.trialEventNumber = [];
%   sA.plotPeriEventRFCrossDays(pparams);
%
%
% EXAMPLE: plot dF/F for ROI 2 as a function of theta during pro/re 
%          c3 contacts.
%
%   clear pparams;
%   figure;
%   pparams.respTSA = 'caTSA.dffTimeSeriesArray';
%   pparams.respTSId = 2;
%   pparams.respTimeWindow = [0 2];
%   pparams.respMode = 'max';
%   pparams.respValueRange = [-0.25 3];
%   pparams.stimTSA = 'whiskerAngleTSA';
%   pparams.stimTSId = 'Angle for c3';
%   pparams.stimTimeWindow = [-0.1 0.1];
%   pparams.stimValueRange = [-40 40];
%   pparams.stimMode = 'mean';
%   pparams.ESA = 'whiskerBarContactClassifiedESA';
%   pparams.ESId = {'Protraction contacts for c3','Retraction contacts for c3'};
%   pparams.ESColor = [1 0 0 ; 0 0 1];
%   pparams.trialEventNumber = [];
%   sA.plotPeriEventRFCrossDays(pparams);
%
%
function plotPeriEventRFCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2)
		help ('session.sessionArray.plotPeriEventRFCrossDays');
	  disp('plotPeriEventRFCrossDays::must specify params');
		return;
	end

  % pull mandatory variables
	stimTSA = params.stimTSA;
	stimTSId = params.stimTSId;
	stimTimeWindow = params.stimTimeWindow;

	respTSA = params.respTSA;
	respTSId = params.respTSId;
	respTimeWindow = params.respTimeWindow;

	ESA = params.ESA;
	ESId = params.ESId;
	 
  % nonmandatories defaults
	stimMode = 'maxabs';
	respMode = 'maxabs';
  ESColor = [];
	trialEventNumber = [];
	xES = [];
	xESTimeWindow = [];
	plotRFParams = [];
	stimUseValueDuringEventOnly = 1;
	respUseValueDuringEventOnly = 0;
	sessions = [];
	nPanels = [];
	stimValueRange = [];
	respValueRange = [];
	excludeOthers = 0;
	labelMode = '';
	labelClasses = [];
	labelClassId = [];
	labelColors = [];
	labelESOverlapWindow = [0 0.5];

	% pull nonmand
	if (isfield(params,'sessions')) ; sessions = params.sessions; end
	if (isfield(params,'nPanels')) ; nPanels = params.nPanels; end
	if (isfield(params,'stimMode')) ; stimMode = params.stimMode; end
	if (isfield(params,'stimValueRange')) ; stimValueRange = params.stimValueRange; end
	if (isfield(params,'respMode')) ; respMode = params.respMode; end
	if (isfield(params,'respValueRange')) ; respValueRange = params.respValueRange; end
	if (isfield(params,'ESColor')) ; ESColor = params.ESColor; end
	if (isfield(params,'trialEventNumber')) ; trialEventNumber = params.trialEventNumber; end
	if (isfield(params,'xES')) ; xES = params.xES; end
	if (isfield(params,'xESTimeWindow')) ; xESTimeWindow = params.xESTimeWindow; end
	if (isfield(params,'excludeOthers')) ; excludeOthers = params.excludeOthers; end
	if (isfield(params,'plotRFParams')) ; plotRFParams = params.plotRFParams; end
	if (isfield(params,'stimUseValueDuringEventsOnly')) ; stimUseValueDuringEventsOnly = params.stimUseValueDuringEventsOnly; end
	if (isfield(params,'respUseValueDuringEventsOnly')) ; respUseValueDuringEventsOnly = params.respUseValueDuringEventsOnly; end
	if (isfield(params,'labelMode')) ; labelMode = params.labelMode; end
	if (isfield(params,'labelClasses')) ; labelClasses = params.labelClasses; end
	if (isfield(params,'labelClassId')) ; labelClassId = params.labelClassId; end
	if (isfield(params,'labelColors')) ; labelColors = params.labelColors; end
	if (isfield(params,'labelESOverlapWindow')) ; labelESOverlapWindow = params.labelESOverlapWindow; end

	labelESA = [];
	labelESId = [];
	labelNames = {};

	% --- input sanity checks
	
	if (length(sessions) == 0) ; sessions = 1:length(obj.sessions) ; end

  if (~iscell(ESId) & ~isnumeric(ESId)) ; ESId = {ESId} ; end

  % figure setup
	if (length(nPanels) == 0)
		nCols = ceil(sqrt(length(sessions)));
		nRows = ceil(sqrt(length(sessions)));
	else
	  nCols = nPanels(1);
		nRows = nPanels(2);
	end

	% --- actual plotting
	figure;
	axRef = nan*(1:length(sessions));
	axLims = zeros(length(sessions),4);
	esLabels = {};
	esLabelCols = {};
	for i=1:length(sessions)
		% vars
		labelNames{i} = {};
		si = sessions(i);
		s = obj.sessions{si};
		sTSA = eval(['s.' stimTSA]);
		rTSA = eval(['s.' respTSA]);
		eESA = eval(['s.' ESA]);

		% subplot
		axRef(i) = subplot(nRows, nCols, i);
		hold on;

		% generate same # of axes to keep everyone in same place
		axRefVec = axRef(i)*ones(1,length(ESId));

		% supplementary labels ... can of WORMS!
		if (strcmp(labelMode, 'trialType'))
		  labelESA = {};
		  for lc=1:length(labelClasses)
			  lci = find(strcmp(s.trialTypeStr,labelClasses{lc}));
        trialList = find(s.trialTypeMat(lci,:));
				labelESA{lc} = trialList;
			end
			labelNames{i} = labelClasses;
		elseif (strcmp(labelMode, 'trialFrac'))
		  labelESA = {};
			nt = length(s.trial);
		  for lc=1:length(labelClasses)
			  ti1 = max(1,floor(labelClasses{lc}(1)*nt));
			  ti2 = min(nt,ceil(labelClasses{lc}(2)*nt));
        trialList = intersect(s.validTrialIds, ti1:ti2);
				labelESA{lc} = trialList;
				labelNames{i}{lc} = [sprintf('%0.2f', labelClasses{lc}(1)) '-' sprintf('%0.2f', labelClasses{lc}(2))];
			end
		elseif (strcmp(labelMode, 'ESA'))
		  labelESA = eval(['s.' labelClasses]);
			labelESId = labelClassId;
			if (~isnumeric(labelESId) & ~iscell(labeESId)) ; labelESId = {labelESId} ; end
			for lc=1:length(labelESId)
			  if (iscell(labelESId)) ; lES = labelESA.getEventSeriesByIdStr(labelESId{lc}); else ; lES = labelESA.getEventSeriesById(labelESId(lc)); end
			  labelNames{i}{lc} = lES.idStr;
			end
		elseif (strcmp(labelMode, 'lickRate'))
		  % compute per-trial lickrate
		  lts = s.derivedDataTSA.getTimeSeriesByIdStr('Beam Breaks Rate');
			tids = s.derivedDataTSA.trialIndices;
			uti = unique(tids);
			lickRate = 0*uti;
			for u=1:length(uti)
			  idx = find(tids == uti(u));
				lickRate(u) = nanmean(lts.value(idx));
			end
			lickRate(find(isnan(lickRate))) =0;

			% now assign ...
		  for lc=1:length(labelClasses)
			  lr1 = labelClasses{lc}(1);
			  lr2 =  labelClasses{lc}(2);
				val = find(lickRate >= lr1 & lickRate <= lr2);
        trialList = intersect(s.validTrialIds, uti(val));
				labelESA{lc} = trialList;
				labelNames{i}{lc} = [sprintf('LickR8 %2.1f', labelClasses{lc}(1)) '-' sprintf('%2.1f', labelClasses{lc}(2))];
			end
		end

		% call session.plotPeriEventRF
    s.plotPeriEventRF(sTSA, stimTSId, stimTimeWindow, stimMode, ...
                      rTSA, respTSId, respTimeWindow, respMode, ...
											eESA, ESId, ESColor, ...
											trialEventNumber, xES,  xESTimeWindow,excludeOthers,  ...
  										plotRFParams, axRefVec, stimUseValueDuringEventOnly, ...
                      respUseValueDuringEventOnly, labelESA, labelESId, ...
											labelColors, labelESOverlapWindow);

		% --- labels etc.
		axLims(i,:) = axis;
    
		% x, y label & title
		xl = ''; yl = '';
		if (isnumeric(stimTSId)) 
		  ts = sTSA.getTimeSeriesById(stimTSId(1));
			if (length(ts) > 0)
			  xl = ts.idStr;
			end
		else
		  if (iscell(stimTSId))
			  xl = stimTSId{1};
			else
				xl= stimTSId;
			end
		end
		if (isnumeric(respTSId)) 
		  ts= rTSA.getTimeSeriesById(respTSId);
			if (length(ts) > 0)
			  yl = ts.idStr;
			end
		else
		  yl= respTSId;
		end
		xlabel(xl);
		ylabel(yl);
		title([obj.dateStr{si}]);

		% color labels via text
    if (length(ESColor) > 0)
		  for e=1:length(ESId)
			  if (isnumeric(ESId))
				  es = eESA.getEventSeriesById(ESId(e));
				else
				  es = eESA.getEventSeriesByIdStr(ESId{e});
				end
				if (length(es) > 0)
					esLabels{i}{e} = es.idStr;
					esLabelCols{i}{e} = ESColor(e,:);
				end
			end
	  end
	end

	% --- axis rescaling & text positioning -- want same axis span x-session
	for i=1:length(sessions)
	  axes(axRef(i));

    % axis rescale
		A(1) = min(axLims(:,1));
		A(2) = max(axLims(:,2));
		A(3) = min(axLims(:,3));
		A(4) = max(axLims(:,4));
	
		if (length(stimValueRange) == 2) ; A(1:2) = stimValueRange(1:2) ; end
		if (length(respValueRange) == 2) ; A(3:4) = respValueRange(1:2) ; end
	  axis(A);

	  Ry = A(4)-A(3);
		Rx = A(2)-A(1);

		% color labels via text
    if (length(ESColor) > 0 & length(esLabels) >= i)
		  for e=1:length(esLabels{i})
			  idstr = esLabels{i}{e};
				idstr = strrep(idstr, 'contacts for ', '');
				idstr = strrep(idstr, 'Contacts for ', '');
				idstr = strrep(idstr, 'Protraction ', 'P');
				idstr = strrep(idstr, 'Retraction ', 'R');
				idstr = strrep(idstr, 'Coincidence of ', 'Co');
	  	  text(A(1)+0.75*Rx, A(3)+(e/length(esLabels{i}))*Ry, idstr, 'Color', esLabelCols{i}{e});
			end
	  end

		% extra labels ..
		if (length(labelNames{i})> 0)
			for l=1:length(labelNames{i})
				idstr = labelNames{i}{l};
				idstr = strrep(idstr, 'contacts for ', '');
				idstr = strrep(idstr, 'Contacts for ', '');
				idstr = strrep(idstr, 'Protraction ', 'P');
				idstr = strrep(idstr, 'Retraction ', 'R');
				idstr = strrep(idstr, 'Coincidence of ', 'Co');
			  text(A(1)+0.5*Rx, A(3)+ (l/length(labelNames))*Ry, idstr, 'Color', labelColors(l,:) );
			end
		end
	end






