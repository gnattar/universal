%
% A Wrapper to run what is currently "best practices" dff & event detection.
%
% USAGE:
%
%  caTSA.runBestPracticesDffAndEvdet(params)
%
% PARAMS:
%
%  params: Structure with optional fields 
%    params.settingSet: which settings to use? 641_354 default
%    params.trialTimes: trial times matrix for use by event detection
%
% (C) SPeron Jan 2011
%
function obj = runBestPracticesDffAndEvdet(obj, params)
 
  %% --- process inputs
	settingSet = '641_354';
	trialTimes = [];
	if (nargin >= 2 & isstruct(params))
	  eval(assign_vars_from_struct(params,'params'));
  end

  %% --- depending on settingSet ...
  switch settingSet
	  %% --- this is GCaMP 10.354 or 10.641, which are GCaMP5.5 and GCaMP6
	  case '641_354' 
			%% --- first do df/f computation
	 
	    % activity classifier settings
			actParams.cofThresh = 0.15;
			actParams.nabThresh = 0.005;
			actParams.forceRedo = 1;

      % actual df/f opts
			dffOpts.fZeroFilterParams.timeUnit = obj.timeUnit;
			dffOpts.fZeroFilterParams.filterType = 'quantile';
			dffOpts.fZeroFilterParams.filterSizeSeconds = 60;
			dffOpts.fZeroFilterParams.quantileThresh = [];

			dffOpts.actParams = actParams;

			obj.dffOpts = dffOpts;
			obj.updateDff();

			%% --- now template-based event detection
			evdetOpts.debug = 0;

			evdetOpts.hyperactiveIdx = obj.roiActivityStatsHash.get('hyperactiveIdx');
			evdetOpts.activeIdx = obj.roiActivityStatsHash.get('activeIdx');

			evdetOpts.timeUnit = obj.timeUnit;

			evdetOpts.tausInDt = 3:30;
			evdetOpts.tRiseInDt = 1:5;

			evdetOpts.initThreshSF = [1.5 2 2.5]; % hyperactive active and inactive thresholds
			evdetOpts.templateFitSF = 1; 

			evdetOpts.minFitRawCorr = 0.25;
			evdetOpts.fitResidualSDThresh = 2;

			if (length(trialTimes) > 0)
			  evdetOpts.trialTimes = trialTimes ; 
			end

			obj.evdetOpts = evdetOpts;
			obj.updateEvents();
	end

