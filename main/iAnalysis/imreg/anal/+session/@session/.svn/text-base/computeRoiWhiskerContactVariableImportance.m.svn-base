%
% SP Jun 2011
%
% This will explore touch kappa, duration, theta, and dtheta to see if there is
%  any information in dF/F about any of these parameters. Tests a variety of 
%  combinations of each parameter (e.g., for kappa, sumabs and max dkappa for
%  1st, all, and max contact).  At the end, you should have a sense of which
%  apsect of touch a cell/ROI cares most about.
%
% USAGE:
%
%   retParams = s.computeRoiWhiskerContactVariableImportance(params)
%
% PARAMS: 
%
%   retParams: a structure with following fields:
%     bestParamsTheta: params structure, 1 per whisker, that you can call
%                      getPeriWhiskerContactRF with to get best parameter based
%                      on score for theta.  Blank if not enuff data.
%     bestParamsKappa: same but for curvatuer
%     theta/kappaDetails: cell array of structures, 1 per whisker, with all data
%     whiskerTags: whiskerTags used for Details arrays
%
% members of the strucure params:
%  
%   roiId: numeric Id of roi to do 
%   whiskerTags: which whiskers to test on ; blank -> all
%   directional: use directional (1) or all (0) contacts?
%   paramsTested: vector with 1/0, 1 meaning test
%                 (1) kappa* [default only this is tested]
%                 (2) theta
%                 (3) duration (of contact)
%   useExclusive: if 1 (dflt 0), will use exclusive contacts only
%
function retParams = computeRoiWhiskerContactVariableImportance(obj, params)
  % --- inputs
  if (nargin == 2 && ~isstruct (params))
	  roiId = params;
	elseif (nargin == 2)
		roiId = params.roiId; % required so
	else
	  help('session.session.computeRoiWhiskerContactVariableImportance');
		return;
	end

	whiskerTags = {'c1','c2','c3'};
	directional = 0;
	paramsTested = [1 1 0];
	useExclusive = 1;
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'directional')) ; directional = params.directional; end
	if (isfield(params, 'paramsTested')) ; paramsTested = params.paramsTested; end
	if (isfield(params, 'useExclusive')) ; useExclusive = params.useExclusive; end
	
	if (~iscell(whiskerTags)) ; whiskerTags = {whiskerTags} ; end
  
  % --- setup ES
	if (directional)
	  wESA = obj.whiskerBarContactClassifiedESA;
		wESATxt = 'whiskerBarContactClassifiedESA';
	else
	  wESA = obj.whiskerBarContactESA;
		wESATxt = 'whiskerBarContactESA';
	end

  % --- preset bestPArams
	for w=1:length(whiskerTags)
    bestParamsKappa{w} = [];
    kappaDetails{w} = [];
  	bestParamsTheta{w} = [];
  	thetaDetails{w} = [];
	end

	% --- hit it
	for w=1:wESA.length()
	  idStr = wESA.esa{w}.idStr;
  	wStr = idStr(strfind(idStr,'for')+4:end);
		if (sum(strcmp(wStr, whiskerTags)) > 0 )
			if (paramsTested(1)) ; [bestParamsKappa{w} kappaDetails{w}] = exploreParamsKappa(obj, roiId, useExclusive, wESATxt, wESA.esa{w}.idStr, wStr); end
			if (paramsTested(2)) ; [bestParamsTheta{w} thetaDetails{w}] = exploreParamsTheta(obj, roiId, useExclusive, wESATxt, wESA.esa{w}.idStr, wStr); end
			if (paramsTested(3)) ; exploreParamsDuration(obj, roiId, useExclusive, wESATxt, wESA.esa{w}.idStr, wStr); end
		end
	end

	% --- build for return
	retParams.whiskerTags = whiskerTags;
	retParams.bestParamsKappa = bestParamsKappa;
	retParams.bestParamsTheta = bestParamsKappa;
	retParams.kappaDetails = kappaDetails;
	retParams.thetaDetails = thetaDetails;

%
% kappa
% 
function [bestParamsKappa kappaDetails] = exploreParamsKappa (obj, roiId, useExclusive, wESA, wId, wStr)
	stimModes = {'summaxabs', 'abssummaxabs'};
  trialEventNumber = {[]};
	for s=1:length(stimModes)
	  [scores(s) rparams{s} kappaDetails{s}] = getRF(obj, roiId,  useExclusive, wESA, wId, stimModes{s}, 'whiskerCurvatureChangeTSA', ...
	                ['Curvature change for ' wStr], [], [-0.1 0.5]); 
	end

  trialEventNumber = {[], 1};
	for t=1:length(trialEventNumber)
	 [scores(t+2) rparams{t+2} kappaDetails{t+2}] = getRF(obj, roiId,  useExclusive, wESA, wId, 'maxabs', 'whiskerCurvatureChangeTSA', ...
											['Curvature change for ' wStr], trialEventNumber{t}, [-0.1 0.5]);
	end

  trialEventNumber = {'max', [], 1};
	for t=1:length(trialEventNumber)
	 [scores(t+4) rparams{t+4} kappaDetails{t+4}] = getRF(obj, roiId,  useExclusive, wESA, wId, 'sumabs', 'whiskerCurvatureChangeTSA', ...
											['Curvature change for ' wStr], trialEventNumber{t}, [-0.1 0.5]);
	end

	[bestScore bestScoreIdx] = max(scores);
	if (~isnan(bestScore) && length(bestScoreIdx) > 0)
    bestParamsKappa = rparams{bestScoreIdx};
	else 
	  bestParamsKappa = [];
	end

%
% duration
% 
function exploreParamsDuration (obj, roiId, useExclusive, wESA, wId, wStr)
  stimModes = {'duration'};
  trialEventNumber = {'max', [], 1};
	for s=1:length(stimModes)
		for t=1:length(trialEventNumber)
			getRF(obj, roiId,  useExclusive, wESA, wId, stimModes{s}, 'whiskerCurvatureChangeTSA', ...
											['Curvature change for ' wStr], trialEventNumber{t}, [-0.1 2]);
		end
	end


%
% angles
%
function [bestParamsTheta thetaDetails] = exploreParamsTheta(obj, roiId, useExclusive, wESA, wId, wStr)
  % theta RIGHT AT first touch 
	[scores(1) rparams{1} thetaDetails{1}] = getRF(obj, roiId,  useExclusive, wESA, wId, 'first', 'whiskerAngleTSA', ...
											['Angle for ' wStr], 1, [-0.1 0.5]);

  stimModes = {'mean'}; %, 'deltasumabs'};
	trialEventNumber = {[], 1};
	for s=1:length(stimModes)
		for t=1:length(trialEventNumber)
			[scores(1+length(scores)) rparams{1+length(rparams)} thetaDetails{1+length(thetaDetails)}] = getRF(obj, roiId,  ...
			          useExclusive, wESA, wId, stimModes{s}, 'whiskerAngleTSA', ...
											['Angle for ' wStr], trialEventNumber{t}, [-0.1 0.5]);
		end
	end

	[bestScore bestScoreIdx] = max(scores);
	if (~isnan(bestScore) && length(bestScoreIdx) > 0)
    bestParamsTheta = rparams{bestScoreIdx};
	else 
	  bestParamsTheta = [];
	end

%
% computes a single receptive field
%
%  scores: for now just AUC
%  rparams: you can call getPeriWhiskerContactRF with this and it will return same
%  scoreDetails: structure with fields tag, auc, auc_mu, auc_ci, and mi, mi_mu, mi_ci
%
function [scores rparams scoreDetails] = getRF(obj, roiId,  useExclusive, wESA, wId, stimMode, stimTSA, stimTSId, trialEventNumber, stimTimeWindow)

  scores = nan;

	% --- get st/re
	params.roiId = roiId;
	
	params.useExclusive = useExclusive;
	params.trialEventNumber = trialEventNumber;
	params.stimTimeWindow = stimTimeWindow;

	params.wcESA = wESA;
	params.wcESId = wId;

	params.stimTSA = stimTSA;
	params.stimTSId = stimTSId;
	params.stimMode = stimMode;

	params.respTSA = 'caTSA.caPeakTimeSeriesArray';
  [st re rparams sTS rTS es rValMat] = obj.getPeriWhiskerContactRF(params);
  
  tnT = 'all';
	if (isstr(trialEventNumber) && strcmp(trialEventNumber,'max')) % STRONGEST contact per trial, ABSOLUTE VALUE
		tnT = 'max';
	elseif (trialEventNumber > 0) % contact NUMBER
		tnT = num2str(trialEventNumber);
  end

	scoreDetails.tag = [];
	scoreDetails.auc = nan;
	scoreDetails.auc_mu = nan;
	scoreDetails.auc_ci = nan;
	scoreDetails.maxauc = nan;
	scoreDetails.maxauc_mu = nan;
	scoreDetails.maxauc_ci = nan;
	scoreDetails.mi = nan;
	scoreDetails.mi_mu = nan;
	scoreDetails.mi_ci = nan;

	% --- now let's look @ the st/re curves and gather stats
	if (length(st) > 0)
    sTimes = es.getStartTimes();
    eTimes = es.getEndTimes();

		
 
		% what is our stimulus baseline?
		if (sum(find(strcmp(stimMode, {'max', 'maxabs','mean', 'first', 'summaxabs', 'abssummaxabs'})))) % use ALL of sTS
			stimVec = sTS.value;
		elseif (sum(find(strcmp(stimMode, {'duration'})))) % compile distro of durations, make symmetric [0 is middle]
			stimVec = 0*(1:length(sTimes));
			for e=1:length(sTimes)
				stimVec(e) = eTimes(e)-sTimes(e);
			end
			stimVec = [stimVec -1*stimVec];
		elseif (sum(find(strcmp(stimMode, {'sumabs', 'deltasumabs'})))) % make symmetric about 0, w/o exclusion
			[nxst nxre] = session.timeSeries.computeReceptiveFieldAroundEvents (sTS, stimMode, rTS, rparams.respMode, ...
													es, rparams.stimTimeWindow, rparams.respTimeWindow, 2,0,[],[]);
			stimVec = [nxst -1*nxst];
		else
			disp(['computeRoiWhiskerContactVariableImportance::invalid stim mode: ' stimMode]);
		end
		
		% tag prep
		tagStr = [es.idStr ' ' sTS.idStr ' ' stimMode ' excl: ' num2str(useExclusive) ' contact: ' tnT];
		disp(tagStr);

		% --- metrics

    % compute snr -- this is NOT stimMode/trialEventNumber dependent but instead applies to response
%		snr = nanmean(rValMat)./nanstd(rValMat);

    % my old fraction statistic YUK
%		frac = frac_usable_rf(st,re,stimVec, rTS.value,0);

    % AUC from ROC
%    [auc_mu auc_ci auc maxauc_mu maxauc_ci maxauc] = discrim_by_multibin_stim_boot(st, re, 2:8, 50);
    [auc_mu auc_ci auc maxauc_mu maxauc_ci maxauc] = discrim_by_multibin_stim_boot(st, re, 4, 50);

    % mutual information
		[mi_mu mi_ci mi] = mutual_info_boot(st,re,'entropy',[],50);

		% output
		disp([' mutual info: ' num2str(mi_mu) ' CI: ' num2str(mi_ci) '  auc: ' num2str(auc_mu) ...
		      '  CI : ' num2str(auc_ci)]);
    scores(1) = auc_mu*mi_mu;

    % --- scoreDetails
		scoreDetails.tag = [es.idStr ' ' sTS.idStr ' ' stimMode ' excl: ' num2str(useExclusive) ' contact: ' tnT];
		scoreDetails.auc = auc;
		scoreDetails.auc_mu = auc_mu;
		scoreDetails.auc_ci = auc_ci;
		scoreDetails.maxauc = maxauc;
		scoreDetails.maxauc_mu = maxauc_mu;
		scoreDetails.maxauc_ci = maxauc_ci;
		scoreDetails.mi = mi;
		scoreDetails.mi_mu = mi_mu;
		scoreDetails.mi_ci = mi_ci;

    % figure? for debug
    if (0)
			figure;
			plot(st,re,'rx');
			title([tnT ' ' stimMode ' ' es.idStr ' AUC: ' num2str(auc_mu) ' MI: ' num2str(mi_mu)]);
		end
  end







