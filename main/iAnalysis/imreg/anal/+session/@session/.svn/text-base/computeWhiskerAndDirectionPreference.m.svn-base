%
% SP Feb 2011
%
% Computes whisker and direction preference by computing the AUC (area under 
%  ROC curve) and confidence intervals.   This is
%  done using bootstrapping and for each ROI.  In each case, the touch
%  triggered dF/F is compared against the ROI's 'baseline' dF/F.
%
%  USAGE:
%
%  retParams = s.computeWhiskerAndDirectionPreference(params)
%
%  PARAMS:
%
%    retParams: structure with following fields:
%      whiskerTags: which whiskers were used
%      nonDirectionalScores: (w,r,1): score for roi r, whisker w (AUC)
%                         (w,r,2:3): AUC confidence intervals
%      directionalScores: (2*w - 1,r,:): score,CI for protraction of whisker w 
%                         (2*w,r,:): score,CI for retraction of whisker w 
%      dirAUC: for EACH ROI, directional AUC -- structure 
%      
%
%    params: structure with following fields:
%     
%      whiskerTags: which whiskers to consider? dictates ordering in the
%                   rParams.
%      useExclusiveWhiskers: exclusive contacts? default yes (1)
%
function retParams = computeWhiskerAndDirectionPreference(obj, params)

  % --- process inputs
  caWindow = [-0.5 0];
	touchWindow = [0 2];
	useExclusiveWhiskers = 1;
	caBurstDt = 1000; % ms
	excludeWindow = [-2 2];
	allowCaOverlap = 1;
	allowTouchOverlap = 0;
	numCaEvMin = length(obj.caTSA.time)/1000;
	trialTouchNumber = [];
%	caDffTSA = obj.caTSA.dffTimeSeriesArray;
	caDffTSA = obj.caTSA.caPeakTimeSeriesArray;
	method = '';
	directional = 0;

  % input
	if (nargin < 2)
	  help ('session.session.computeWhiskerAndDirectionPreference');
		return;
	end

  % grab params
	if (isstruct(params))
	  if(isfield(params,'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	  if(isfield(params,'useExclusiveWhiskers')) ; useExclusiveWhiskers = params.useExclusiveWhiskers; end
	end

  % --- setup
	nonDirectionalScores = nan*ones(length(whiskerTags), length(caDffTSA.ids),3); 
	directionalScores = nan*ones(2*length(whiskerTags), length(caDffTSA.ids),3);
	dirAUC = {[],[],[]};

	% --- compute scores whisker-by-whisker
	for wi=1:length(whiskerTags)
	  disp(['computeWhiskerAndDirectionPreference::Computing for ' whiskerTags{wi}]);

	  % whiskertag
		w = find(strcmp(obj.whiskerTag,whiskerTags{wi}));
		if (length(w) == 0) ; continue ; end % skip it if not found

		% compute directionality index
    % setup kParams, tParams
		% common:
		cparams.useExclusive = 1;
		cparams.trialEventNumber = [];
		cparams.wcESA = 'whiskerBarContactESA';
		cparams.stimTimeWindow = [-0.1 0.5];
		cparams.respTimeWindow = [0 2];
		cparams.respMode = 'max';
		cparams.respTSA = 'caTSA.caPeakTimeSeriesArray';

		kParams = cparams;
		tParams = cparams;

		kParams.stimTSA = 'whiskerCurvatureChangeTSA';
		kParams.stimMode = 'maxabs';

		tParams.stimTSA = 'whiskerAngleTSA';
		tParams.stimMode = 'first';
		tParams.trialEventNumber = 1;

	  tParams.roiId = 1;
		kParams.roiId = 1;
    tParams.stimTSId = ['Angle for ' whiskerTags{wi}];
    kParams.stimTSId = ['Curvature change for ' whiskerTags{wi}];
    tParams.wcESId = ['Contacts for ' whiskerTags{wi}];
    kParams.wcESId = ['Contacts for ' whiskerTags{wi}];
    dirAUC{wi} = computeAUCDirection(obj, kParams, tParams);
if(1)
    % grab nondirectional
    wcES = obj.whiskerBarContactESA.esa{w};
    nonDirectionalScores(wi,:,:) = computeTouchIndex(obj, wcES, obj.whiskerBarContactESA, caDffTSA, method, caBurstDt,...
		                    useExclusiveWhiskers, trialTouchNumber, caWindow, touchWindow, allowCaOverlap, ...
												allowTouchOverlap, excludeWindow, numCaEvMin);

    % protraction
		wcES = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Protraction contacts for ' whiskerTags{wi}]);
		directionalScores(2*wi - 1,:,:) = computeTouchIndex(obj, wcES, obj.whiskerBarContactClassifiedESA, caDffTSA, method, ... 
		                  caBurstDt, useExclusiveWhiskers, trialTouchNumber, caWindow, touchWindow, allowCaOverlap, ...
											allowTouchOverlap, excludeWindow, numCaEvMin);

		% retraction
		wcES = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Retraction contacts for ' whiskerTags{wi}]);
		directionalScores(2*wi,:,:) = computeTouchIndex(obj, wcES, obj.whiskerBarContactClassifiedESA, caDffTSA, method, ...
		                  caBurstDt, useExclusiveWhiskers, trialTouchNumber, caWindow, touchWindow, allowCaOverlap, ...
											  allowTouchOverlap, excludeWindow, numCaEvMin);
end    
	end
  
	% --- build retParams
	retParams.whiskerTags = whiskerTags;
	retParams.nonDirectionalScores = nonDirectionalScores;
	retParams.directionalScores = directionalScores;
	retParams.dirAUC = dirAUC;

%
% main touch index computer
%
function touchIndex = computeTouchIndex(obj, wcES, wcESA, caDffTSA, method, caBurstDt, useExclusiveWhiskers, ...
                        trialTouchNumber, caWindow, touchWindow, allowCaOverlap, allowTouchOverlap, ...
												excludeWindow, numCaEvMin)
	% touch #?
	if (length(trialTouchNumber) > 0)
		 [nEventTimes nEventTrials nEventTimesRelTrialStart] = wcES.getNthEventByTrial(trialTouchNumber);
		 wcES = wcES.copy();
		 wcES.eventTimes = nEventTimes;
		 wcES.eventTimesRelTrialStart = nEventTimesRelTrialStart;
		 wcES.eventTrials = nEventTrials;
	end

	% exclusive?
	if (useExclusiveWhiskers)
		xes = wcESA.getExcludedCellArray(wcES.id);
	else 
		xes = [];
		excludeWindow = [];
	end

	
	% --- CORE CALCULATION
	touchIndex = nan*zeros(length(caDffTSA.ids),3); 
	% make call to getValuesAroundEvents
	for r=1:length(caDffTSA.ids)
    if (length(obj.caTSA.caPeakEventSeriesArray.esa{r}.getStartTimes) < numCaEvMin) ; continue ; end

		caTS = caDffTSA.getTimeSeriesByIdx(r);
		[dataMat timeMat idxMat plotTimeVec] = caTS.getValuesAroundEvents(wcES, touchWindow, 2, ...
				0, xes, excludeWindow);
		dataVec = reshape(dataMat,[],1);
		dataVec = dataVec(find(~isnan(dataVec)));
		
		idxVec = unique(reshape(idxMat,[],1));
		idxVec = idxVec(find(~isnan(idxVec)));
		noiseIdxVec = setdiff(1:length(caTS.value), idxVec);

		noiseVec = caTS.value(noiseIdxVec);
		noiseVec = noiseVec(find(~isnan(noiseVec)));
		if (length(dataVec) > 10 & length(noiseVec) > 10);
			[auc_mode auc_ci] = roc_area_from_distro_boot(dataVec',noiseVec,50);
			touchIndex(r,:) = [auc_mode auc_ci(1) auc_ci(2)];
		end
		disp(['done with ' num2str(r) ' of ' num2str(length(caDffTSA.ids))]); 
	end



%
% This will determine how much discrimination power remains for direction 
%  once theta, kappa, or both are controlled for. --> for ALL ROIs
%
function dirAUC = computeAUCDirection(obj, kParams, tParams)

  % --- get base data
	proKParams = kParams;
	proKParams.wcESA = 'whiskerBarContactClassifiedESA';
	proKParams.wcESId = strrep(proKParams.wcESId, 'Contacts', 'Protraction contacts');
  [stKP reKP parKP] = obj.getPeriWhiskerContactRF(proKParams);
	stKP = abs(stKP) ; % dont want signed kappa

	proTParams = tParams;
	proTParams.wcESA = 'whiskerBarContactClassifiedESA';
	proTParams.wcESId = strrep(proTParams.wcESId, 'Contacts', 'Protraction contacts');
  [stTP reTP parTP] = obj.getPeriWhiskerContactRF(proTParams);

	retKParams = kParams;
	retKParams.wcESA = 'whiskerBarContactClassifiedESA';
	retKParams.wcESId = strrep(retKParams.wcESId, 'Contacts', 'Retraction contacts');
  [stKR reKR parKR] = obj.getPeriWhiskerContactRF(retKParams);
	stKR = abs(stKR) ; % dont want signed kappa
	
	retTParams = tParams;
	retTParams.wcESA = 'whiskerBarContactClassifiedESA';
	retTParams.wcESId = strrep(retTParams.wcESId, 'Contacts', 'Retraction contacts');
  [stTR reTR parTR] = obj.getPeriWhiskerContactRF(retTParams);

  % indexing so you don't have to call getPeri anymore
  thetaTSA = eval(['obj.' tParams.stimTSA]);
  kappaTSA = eval(['obj.' kParams.stimTSA]);
	caDffTSA = eval(['obj.' kParams.respTSA]);

  [irr ia ib] = intersect(parTP.sIeIdxVec, parTP.rIeIdxVec);
  rIdxMatTP = parTP.rIdxMat(ib,:);
  invalTP = find(isnan(rIdxMatTP));
  rIdxMatTP(invalTP) = 1;

  [irr ia ib] = intersect(parKP.sIeIdxVec, parKP.rIeIdxVec);
  rIdxMatKP = parKP.rIdxMat(ib,:);
  invalKP = find(isnan(rIdxMatKP));
  rIdxMatKP(invalKP) = 1;

  [irr ia ib] = intersect(parTR.sIeIdxVec, parTR.rIeIdxVec);
  rIdxMatTR = parTR.rIdxMat(ib,:);
  invalTR = find(isnan(rIdxMatTR));
  rIdxMatTR(invalTR) = 1;

  [irr ia ib] = intersect(parKR.sIeIdxVec, parKR.rIeIdxVec);
  rIdxMatKR = parKR.rIdxMat(ib,:);
  invalKR = find(isnan(rIdxMatKR));
  rIdxMatKR(invalKR) = 1;

  % --- roi loop

  % for calls to discrim_of_classes_normd_for_stim
  dparams.ks_thresh = 0.2;
  dparams.rs_thresh = 0.2;
   
	sVec = nan*ones(1,length(obj.caTSA.ids));
	dirAUC.AUCBase = sVec; dirAUC.AUCBaseCI = [sVec; sVec];
	dirAUC.AUCKappaNorm = sVec; dirAUC.AUCKappaNormCI = [sVec; sVec];
	dirAUC.AUCThetaNorm = sVec; dirAUC.AUCThetaNormCI = [sVec; sVec];
	dirAUC.AUCKappaThetaNorm = sVec; dirAUC.AUCKappaThetaNormCI = [sVec; sVec];
	for r=1:length(obj.caTSA.ids)
    % pull data for this ROI
	  caTS = caDffTSA.getTimeSeriesByIdx(r);

		rValueMat = caTS.value(rIdxMatTP);
    rValueMat(invalTP) = nan;
		reTP = nanmax(rValueMat');

		rValueMat = caTS.value(rIdxMatKP);
    rValueMat(invalKP) = nan;
		reKP = nanmax(rValueMat');

		rValueMat = caTS.value(rIdxMatTR);
    rValueMat(invalTR) = nan;
		reTR = nanmax(rValueMat');

		rValueMat = caTS.value(rIdxMatKR);
    rValueMat(invalKR) = nan;
		reKR = nanmax(rValueMat');

		% --- 0) BASE AUC with no controls
		[AUCBase AUCBaseCI] = roc_area_from_distro_boot(reTR, reTP, 50);

		% --- 1) Control for kappa
		[AUCKappaNorm AUCKappaNormCI irr1 irr2 KNRidx KNPidx] = ...
			 discrim_of_classes_normd_for_stim(reTR, stKR, reTP, stKP, 'dmat_shrink', dparams);

		% --- 2) Control for theta
		[AUCThetaNorm AUCThetaNormCI irr1 irr2 TNRidx TNPidx] = ...
			 discrim_of_classes_normd_for_stim(reTR, stTR, reTP, stTP, 'dmat_shrink', dparams);

		% --- 3) Control for kappa & theta
		KappThetNormRetIdx = intersect(TNRidx, KNRidx);
		KappThetNormProIdx = intersect(TNPidx, KNPidx);
		[AUCKappaThetaNorm AUCKappaThetaNormCI] = roc_area_from_distro_boot(reTR(KappThetNormRetIdx), reTP(KappThetNormProIdx), 50);

		dirAUC.AUCBase(r) = AUCBase; dirAUC.AUCBaseCI(:,r) = AUCBaseCI;
		dirAUC.AUCKappaNorm(r)  = AUCKappaNorm; dirAUC.AUCKappaNormCI(:,r) = AUCKappaNormCI;
		dirAUC.AUCThetaNorm(r)  = AUCThetaNorm; dirAUC.AUCThetaNormCI(:,r) = AUCThetaNormCI;
		dirAUC.AUCKappaThetaNorm(r)  = AUCKappaThetaNorm; dirAUC.AUCKappaThetaNormCI(:,r) = AUCKappaThetaNormCI;
	end
