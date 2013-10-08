%
% SP Jan 2011
%
% A Wrapper to run what is currently "best practices" dff & event detection.
%
% USAGE:
%
%  caTSA.runBestPracticesDffAndEvdet(params)
%
% PARAMS:
%
%  params: structure with following (optional) fields:
%          svdIndicesVec: param for updateDff
%          svdCorrelationVec: for updateDff
%          roiIds: if you want to only do a subset of ROIs
%
function obj = runBestPracticesDffAndEvdet(obj, params)
  % process inputs
	svdIndicesVec = [];
	svdCorrelationVec = [];
	svdCorrelationPeakOffs = [];
	roiIds = [];
	if (nargin >= 2 & isstruct(params))
    fn = fieldnames(params) ; for f = 1:length(fn) ; eval([fn{f} ' = params.' fn{f} ';']); end
  end
  disp(['runBestPracicesDffAndEvdet: first roi is ' num2str(min(obj.ids))]);

  % 1) 'classic' dff and event detection
	
	% assign the default dffOpts and run updateDff
	obj.dffOpts = [];
	obj.dffOpts.roiIds = roiIds;
  obj.dffOpts.filterType = 2; % median
	obj.dffOpts.filterSize = 10; % seconds
	obj.dffOpts.fzeroMethod = 2; % full-trace ksd, since we prenormalize trace
	obj.dffOpts.fzeroSlidingWindowSize = 0; % irrelevant since we use full trace ksd
	obj.dffOpts.fzeroMin = 1; % raw data with raw fluo value BELOW this are set to this
	obj.dffOpts.subtractMethod = 3; % anti-ROI [1 also works well for sparse brain regions]
	obj.dffOpts.svdIndicesVec = svdIndicesVec;
	obj.dffOpts.svdCorrelationVec = svdCorrelationVec;
	obj.dffOpts.svdCorrelationPeakOffs = svdCorrelationPeakOffs;
  tic;
	obj.updateDff();
  disp(['dff 1: ' num2str(toc)]);

	% defaults for event detection
	obj.evdetOpts = [];
	obj.evdetOpts.roiIds = roiIds;
	obj.evdetOpts.evdetMethod = 1; % SD thresh via MAD
	obj.evdetOpts.threshMult = 4; % event must be this much greater 
	obj.evdetOpts.threshStartMult =2;
	obj.evdetOpts.threshEndMult =2;
	obj.evdetOpts.minEvDur = 500; % ms
	obj.evdetOpts.minInterEvInterval = 500; 
	obj.evdetOpts.madPool = 2; % use inactive cells
	obj.evdetOpts.filterType = 2; % prefilter with median
	obj.evdetOpts.filterSize = 10; % in s
	obj.evdetOpts.riseDecayMethod = 2;  % goodness-of-fit based
	tic;
	obj.updateEvents();
  disp(['evdet 1: ' num2str(toc)]);

	% 2) redo dff computation w/ events included
	obj.dffOpts = [];
	obj.dffOpts.roiIds = roiIds;
  obj.dffOpts.filterType = 4; % slower but MUCH better quantile based
	obj.dffOpts.filterSize = 10; % seconds
	obj.dffOpts.fzeroMethod = 3; % EXCLUDE high-event regions from fzero estimation
	obj.dffOpts.fzeroSlidingWindowSize = 0; % irrelevant since we use full trace ksd
	obj.dffOpts.fzeroMin = 1; % raw data with raw fluo value BELOW this are set to this
	obj.dffOpts.subtractMethod = 3; % anti-ROI [1 also works well for sparse brain regions]
	obj.dffOpts.svdIndicesVec = svdIndicesVec;
	obj.dffOpts.svdCorrelationVec = svdCorrelationVec;
	obj.dffOpts.svdCorrelationPeakOffs = svdCorrelationPeakOffs;
	tic;
	obj.updateDff();
  disp(['dff 2: ' num2str(toc)]);

	% 3) Vogelstein event detection
	obj.evdetOpts = [];
	obj.evdetOpts.roiIds = roiIds;
	obj.evdetOpts.evdetMethod = 4;
	obj.evdetOpts.riseDecayMethod = 2; 
	obj.evdetOpts.eventBasedDffMethod = 2;
	obj.evdetOpts.threshMult = 4; % event must be this much greater 
	obj.evdetOpts.threshStartMult =2;
	obj.evdetOpts.threshEndMult =2;
	obj.evdetOpts.minEvDur = 500; % ms
	obj.evdetOpts.minInterEvInterval = 500; 
	obj.evdetOpts.madPool = 2; % use inactive cells
	obj.evdetOpts.filterType = 0;
	tic;
	obj.updateEvents();
  disp(['evdet 2: ' num2str(toc)]);

	% 4) detect active ROIs
	rasParams.forceRedo = 1;
	obj.getRoiActivityStatistics(rasParams);

