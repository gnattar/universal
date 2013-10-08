%
% SP Apr 2011
%
% This will plot kappa vs. dff across days.
%
% USAGE:
%
%  sA.plotKappaRFCrossDays(params)
%
%  params - structure with variables:
%
%    roiId: ID of ROI to plot for
%    whiskerTags: which whiskers to include (default all)
%    sessions: vector of session indices to use, within sessionArray
%    nPanels: [nCols nRows] ; by default, both are ceil(sqrt(length(sessions)))
%    dffRange: range of dff shown ; [-0.25 1] default
%    dKappaRange: range shown ; [-0.005 0.005] dflt
%
%    RF COMPUTATION SPECIFICS:
%
%    contactType: 3 el vector, [1 0 0]: all only [0 1 0] pro [0 0 1] ret
%    trialContactNumber: by default, uses all contacts in a trial; 
%                        if specified, it will use a particular one. 
%                        Inf: last.  'max' - strongest contact.
%    useStringentDKappa: default is 0 (not 2 use only contacts with large
%                        dKappa, computed here).  Otherwise, it will
%                        use s.whiskerBarContactESA
%    caTimeWindow: time window, in s, around the contact events used
%                  for calcium.  Default is [0 2] meaning from contact
%                  to 2 seconds out.  Specify a SINGLE value and it will
%                  do that value +/- dt/2.  IN SECONDS.
%    kappaTimeWindow: time window to compute kappa around the touch;
%                     default is [-0.1 1].  IN SECONDS.
%    caMode, kappaMode: what to compute for df/f or kappa: mean, max, 
%                       maxabs, meanabs.  Default is maxabs for kappa 
%                       and max for df/f
%    excludeOthers: default 0 ; if 1, will exclude, for a given ESA
%                   member, any other ESA members
%
%    RF PLOTTING RELATED:
%
%    plotMethod: (*=default)
%      *'raw': plotParams blank, just plots raw data
%      'binByStim': makes equally spaced bins of size plotParams.binSize along 
%        stimulus axis.  Will plot SD and mean. If plotParams.firstBin is provided,
%        this is the value of the first bin's left edge.  Otherwise, min(stimulus).
%      'binByCount': makes bins, along stimulus axis, having fixed # of members
%        denoted by plotParams.binSize (default = 10)
%    color: color of the plot ; default [0 0 0]. 
%
function plotKappaRFCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2)
		help ('session.sessionArray.plotKappaRFCrossDays');
	  disp('plotKappaRFCrossDays::must specify params');
		return;
	end

	% dflts
  whiskerTags = obj.whiskerTag;
	sessions=1:length(obj.sessions);
	nPanels = [];
	dffRange = [-0.25 2];
	dKappaRange = [-0.0025 0.0025];

	trialContactNumber = []; % use all contacts
  useStringentDKappa = 0;
	caTimeWindow = [0 1];
	kappaTimeWindow = [-0.1 1];
	caMode = 'max';
	kappaMode = 'maxabs';
	plotMethod = 'raw';
	color = [0 0 0 ];
	contactType = [1 0 0];
	excludeOthers = 0;

  roiId = params.roiId; % if this is not present you will get a message so you should add it!
	if (isfield(params,'whiskerTags')) ; whiskerTags = params.whiskerTags ; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'nPanels')) ; nPanels = params.nPanels; end
	if (isfield(params, 'dffRange')) ; dffRange = params.dffRange; end
	if (isfield(params, 'dKappaRange')) ; dKappaRange = params.dKappaRange; end
	if (isfield(params, 'contactType')) ; contactType = params.contactType; end
	if (isfield(params,'trialContactNumber')) ; trialContactNumber = params.trialContactNumber ; end
	if (isfield(params,'useStringentDKappa')) ; useStringentDKappa = params.useStringentDKappa ; end
	if (isfield(params,'caTimeWindow')) ; caTimeWindow = params.caTimeWindow ; end
	if (isfield(params,'kappaTimeWindow')) ; kappaTimeWindow = params.kappaTimeWindow ; end
	if (isfield(params,'caMode')) ; caMode = params.caMode ; end
	if (isfield(params,'kappaMode')) ; kappaMode = params.kappaMode ; end
	if (isfield(params,'plotMethod')) ; plotMethod = params.plotMethod ; end
	if (isfield(params,'color')) ; color = params.color ; end
	if (isfield(params,'excludeOthers')) ; excludeOthers = params.excludeOthers ; end

	% --- input sanity checks
	
	% cell whiskertags
	if (~iscell(whiskerTags)) ; whiskerTags = {whiskerTags} ; end

	% sessions?
	if (length(sessions) == 0) ; sessions = 1:length(obj.sessions) ; end

  % figure setup
	if (length(nPanels) == 0)
		nCols = ceil(sqrt(length(sessions)));
		nRows = ceil(sqrt(length(sessions)));
	else
	  nCols = nPanels(1);
		nRows = nPanels(2);
	end

	% assign structures used bty plotKappaRf
	compParams.contactType = find(contactType);
  compParams.trialContactNumber = trialContactNumber;
  compParams.useStringentDKappa = useStringentDKappa;
  compParams.caTimeWindow = caTimeWindow;
  compParams.kappaTimeWindow = kappaTimeWindow;
  compParams.caMode = caMode;
  compParams.kappaMode = kappaMode;
	compParams.excludeOthers = excludeOthers;

	plotParams.plotMethod = plotMethod;
	plotParams.color = color;
 
	% --- setup
	multiPlot = 0;
	if (sum(contactType) > 1)
	  multiPlot = 1;
	end

	% --- actual plotting
  for w=1:length(whiskerTags)
	  figure;
		for i=1:length(sessions)
		  % vars
			si = sessions(i);
			s = obj.sessions{si};
			whiskerIdx = find(strcmp(s.whiskerTag,whiskerTags{w}));

			% proceed if whisker exists
			if (length(whiskerIdx) > 0)
				% subplot
				axRef = subplot(nRows, nCols, i);
				hold on;

				% call plotKappaRF for all contact types
				if (contactType(1)) % all
				  compParams.contactType = 1;
					plotParams.color = color; % use passed color (blcak by default oo lala)
					obj.sessions{si}.plotKappaRF(whiskerIdx, roiId, compParams, plotParams, axRef);
					if (multiPlot) ; text(dKappaRange(1)+0.25*abs(diff(dKappaRange)), dffRange(1)+0.2*abs(diff(dffRange)), 'all', 'Color', plotParams.color) ; end
				end
				if (contactType(2)) % pro
				  compParams.contactType = 2;
					plotParams.color = [1 0 0];
					obj.sessions{si}.plotKappaRF(whiskerIdx, roiId, compParams, plotParams, axRef);
					if (multiPlot) ; text(dKappaRange(1)+0.25*abs(diff(dKappaRange)), dffRange(1)+0.4*abs(diff(dffRange)), 'pro', 'Color', plotParams.color) ; end
				end
				if (contactType(3)) % ret
				  compParams.contactType = 3;
					plotParams.color = [0 0 1]; 
					obj.sessions{si}.plotKappaRF(whiskerIdx, roiId, compParams, plotParams, axRef);
					if (multiPlot) ; text(dKappaRange(1)+0.25*abs(diff(dKappaRange)), dffRange(1)+0.6*abs(diff(dffRange)), 'ret', 'Color', plotParams.color) ; end
				end

				axis([dKappaRange(1) dKappaRange(2) dffRange(1) dffRange(2)]);
				title([whiskerTags{w} ' ' obj.dateStr{si}]);
			end
		end
	end





