%
% SP Feb 2011
%
% Computes touch index across ROIs using specified method and parameters.
%  session.cellFeatures "touchIndex" element is assigned the results.
%
%  USAGE:
%
%  s.computeRoiTouchIndex (params)
%
%  PARAMS:
%
%    params: 
%
%      Params can either be a string, in which case it is just the method 
%       parameter below (all other parameters are default), or you can build
%       a structure with as many of the fields (method MUST be there) as
%       you want:
%
%      method: which method to use --
%        'P_cgt' - probability of calcium given touch
%        'P_tgc' - probability of touch given calcium event
%        'P_prod' - product of two conditional probabilities above
%        'SNR' - takes the peak mean/std ratio of df/f response
%        'AUC_Ca' - ROC area under curve of post-contact Ca vs. baseline
%        'MI' - mutual information between ca and kappI
%        'MI_norm' - mutual information between ca and kapp, normalized to kappa
%                    entropy
%        'Frac_RF' - fraction in none noise prtion of of ca vs. dff plot
%        'Frac_resp' - fraction with non-noise response to touch
%        'max_dff' - return mean of max dff around touches
%        'max_dff_mad' - return mean of max dff around touches, scaled by roi MAD
%        'max_dff_mean' - returns max of mean (note that this is DIFFERENT than 
%                         mean of maxes because only ONE timepoint is used).
%        'max_dff_median' - same as max_dff_mean, but for median.
%        'corr' - peak cross-correlation
%        'overlap' - uses overlap of events - very fast and roughly = to P_prod
%      directional: if 1, it will use whiskerBarContactClassifiedESA, and touchIndex
%                   will be TWICE as large ; default 0
%      caWindow: time window for calcium (in seconds) [-0.5 0] whn doing overlap
%                both ca and touchWindows are placed around ca/touch events and
%                used to allow overlap for P_cgt, P_tgc, and P_prod.  For fracRF,
%                the max of ca and touch is taken around the window.
%      touchWindow: time window for touch (in seconds) [0 2].  For max_dff and
%                   max_dff_dmat, this is the window in time around touch events
%                   from which calcium response is measured.
%      trialTouchNumber: which touch to use from trial? default is all; inf=last.
%      whiskerTags: which whiskers to use? (match to whiskerTag) ; default all
%      useExclusiveWhiskers: [default = 0] ; if 1, will only look for events that
%        are single-whisker touches
%      excludeWindow: How big is the exclude window for whisker exclusion (seconds)?
%      allowCaOverlap, allowTouchOverlap: set to 1 or 0 to allow/disallow overlap
%         of event windows
%      numCaEvMin: how many Ca events must an ROI have to be included?
%      caBurstDt: If > 0, will take BURST START TIMES with burstDt being this
%        see session.eventSeries.getBurstTimes for details.
%      caDffTSA: pointer to TSA object used for ca data; default is 
%                caTSA.dffTimeSeriesArray
%      barInReachOnly: sets ca responses outside of bar-in-reach epoch to nan;
%                      default is 0 (off);
%    
%  EXAMPLE 1: score exclusive nondirectional contacts when bar is in reach with 
%             max_dff_mean method.
%
%    clear tparams;
%    tparams.method = 'max_dff_mean';
%    tparams.barInReachOnly = 1;
%    tparams.touchWindow = [0 1];
%    tparams.useExclusiveWhiskers = 1;
%    tparams.directional = 0;
%    s.computeRoiTouchIndex(tparams);
%
%  EXAMPLE 2: Use product of conditional probabilities during in reach only epoch and
%             with non exclusive contacts
%
%    clear tparams;
%    tparams.method = 'P_prod';
%    tparams.barInReachOnly = 1;
%    tparams.touchWindow = [0 2];
%    tparams.caWindow = [-2 0];
%    tparams.useExclusiveWhiskers = 0;
%    tparams.directional= 0;
%    s.computeRoiTouchIndex(tparams);
%
%  EXAMPLE 3: AUC based off of Dff, but only event-based dff.
%
%    clear tparams;
%    tparams.method = 'AUC_Ca';
%    tparams.barInReachOnly = 1;
%    tparams.touchWindow = [0 2];
%    tparams.useExclusiveWhiskers = 0;
%    tparams.directional= 0;
%    tparams.caDffTSA = s.caTSA.eventBasedDffTimeSeriesArray;
%    s.computeRoiTouchIndex(tparams);
%

function obj = computeRoiTouchIndex(obj, params)

  % --- process inputs
  caWindow = [-0.5 0];
	touchWindow = [0 2];
	whiskerTags = obj.whiskerTag;
	useExclusiveWhiskers = 0;
	caBurstDt = 1000; % ms
	excludeWindow = [-2 2];
	allowCaOverlap = 1;
	allowTouchOverlap = 0;
	numCaEvMin = 10;
	trialTouchNumber = [];
	caDffTSA = obj.caTSA.dffTimeSeriesArray;
	method = '';
	directional = 0;
	barInReachOnly = 0;

  % input
	if (nargin < 2)
	  help session.session.computeRoiTouchIndex;
		disp(' ');
		disp(' ');
		disp('computeRoiTouchIndex::you must provide at LEAST a method.');
		return;
	end

  % grab params
	if (isstruct(params))
	  if(isfield(params,'method')) ; method = params.method; end
	  if(isfield(params,'directional')) ; directional = params.directional; end
	  if(isfield(params,'caWindow')) ; caWindow = params.caWindow; end
	  if(isfield(params,'trialTouchNumber')) ; trialTouchNumber = params.trialTouchNumber; end
	  if(isfield(params,'touchWindow')) ; touchWindow = params.touchWindow; end
	  if(isfield(params,'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	  if(isfield(params,'useExclusiveWhiskers')) ; useExclusiveWhiskers = params.useExclusiveWhiskers; end
	  if(isfield(params,'caBurstDt')) ; caBurstDt = params.caBurstDt; end
	  if(isfield(params,'excludeWindow')) ; excludeWindow = params.excludeWindow; end
	  if(isfield(params,'allowCaOverlap')) ; allowCaOverlap = params.allowCaOverlap; end
	  if(isfield(params,'allowTouchOverlap')) ; allowTouchOverlap = params.allowTouchOverlap; end
	  if(isfield(params,'numCaEvMin')) ; numCaEvMin = params.numCaEvMin; end
	  if(isfield(params,'caDffTSA')) ; caDffTSA = params.caDffTSA; end
	  if(isfield(params,'barInReachOnly')) ; barInReachOnly = params.barInReachOnly; end
	elseif (isstr(params))
	  method = params;
	end

	% method provided?
	if (length(method) == 0)
	  help session.session.computeRoiTouchIndex;
		disp(' ');
		disp(' ');
		disp('computeRoiTouchIndex::you must provide a method.');
		return;
	end

  % method-specific default changse
  switch method
	  case {'Frac_RF','Frac_resp'} % caWindow and touchWindow now mean something dofferent -- 
		              % over what range is the ca/touch measurement taken, instead
									% of where it should be stretched to overlap
		  caWindow = [0 2];
			touchWindow = [-0.1 1.5];
	end

  % --- setup
  touchIndex = nan*ones(length(whiskerTags), length(caDffTSA.ids));
	if (directional) ; touchIndex = nan*ones(2*length(whiskerTags), length(caDffTSA.ids)); end

	% --- compute scores whisker-by-whisker
	for wi=1:length(whiskerTags)
	  disp(['Computing for ' whiskerTags{wi}]);

	  % curvature TS for whisker ...
		w = find(strcmp(obj.whiskerTag,whiskerTags{wi}));
		if (length(w) == 0) ; continue ; end % skip it@!
		dkTS = obj.whiskerCurvatureChangeTSA.getTimeSeriesByIdx(w);

		if (~directional) % nondirectional go
      wcES = obj.whiskerBarContactESA.esa{w};
			dtsIdx = find(strcmp(obj.derivedDataTSA.idStrs, [whiskerTags{wi} ' touch max abs delta kappa']));
	    touchIndex(wi,:) = computeTouchIndex(obj, wcES, obj.whiskerBarContactESA, caDffTSA, method, caBurstDt, useExclusiveWhiskers, ...
                        trialTouchNumber, caWindow, touchWindow, allowCaOverlap, allowTouchOverlap, ...
												excludeWindow, numCaEvMin, dtsIdx, dkTS, barInReachOnly);
		else % grab pro/re
			dtsIdx = find(strcmp(obj.derivedDataTSA.idStrs, [whiskerTags{wi} ' pro touch max delta kappa']));
      wcES = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Protraction contacts for ' whiskerTags{wi}]);
	    touchIndex(2*wi - 1,:) = computeTouchIndex(obj, wcES, obj.whiskerBarContactClassifiedESA, caDffTSA, method, caBurstDt, useExclusiveWhiskers, ...
                        trialTouchNumber, caWindow, touchWindow, allowCaOverlap, allowTouchOverlap, ...
												excludeWindow, numCaEvMin, dtsIdx, dkTS, barInReachOnly);
      wcES = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Retraction contacts for ' whiskerTags{wi}]);
			dtsIdx = find(strcmp(obj.derivedDataTSA.idStrs, [whiskerTags{wi} ' ret touch max delta kappa']));
	    touchIndex(2*wi,:) = computeTouchIndex(obj, wcES, obj.whiskerBarContactClassifiedESA, caDffTSA, method, caBurstDt, useExclusiveWhiskers, ...
                        trialTouchNumber, caWindow, touchWindow, allowCaOverlap, allowTouchOverlap, ...
												excludeWindow, numCaEvMin, dtsIdx, dkTS, barInReachOnly);
		end

	end

	% --- if we got to this point assign
	obj.cellFeatures.setOrAdd('touchIndex',touchIndex);

%
% main touch index computer
%
function touchIndex = computeTouchIndex(obj, wcES, wcESA, caDffTSA, method, caBurstDt, useExclusiveWhiskers, ...
                        trialTouchNumber, caWindow, touchWindow, allowCaOverlap, allowTouchOverlap, ...
												excludeWindow, numCaEvMin, dtsIdx, dkTS, barInReachOnly)
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

  % bar-in-reach restrictor?
	if (barInReachOnly)
  	barTS = session.eventSeries.deriveTimeSeriesS(obj.whiskerBarInReachES, obj.caTSA.time, obj.caTSA.timeUnit, [nan 1], 2);
	end

	% --- method-specific pre-processing
	switch method
		case {'P_cgt', 'P_tgc', 'P_prod'}
			for r=1:length(caDffTSA.ids)
				if (caBurstDt > 0)
					caES{r} = obj.caTSA.caPeakEventSeriesArray.esa{r}.getBurstTimes(caBurstDt);
				else
					caES{r} =  obj.caTSA.caPeakEventSeriesArray.esa{r}.eventTimes;
				end
				if (barInReachOnly) % apply bar-in-reach exclusion with some clever set operations
          [irr1 irr2 idxEvCaTSA] = intersect (caES{r},obj.caTSA.time);
					keepIdx = find(~isnan(barTS.value(idxEvCaTSA)));
%if(ismember(caDffTSA.ids(r), [1023 2318])) ;
%disp(['pre: ' num2str(length(caES{r})) ' post: ' num2str(length(keepIdx))]);
%end
					caES{r} = caES{r}(keepIdx);
				end
				nev(r) = length(find(~isnan(caES{r})));
			end

		case 'overlap'
		  caDffTSA = obj.caTSA.caPeakTimeSeriesArray;

		case 'corr'
		  caDffTSA = obj.caTSA.caPeakTimeSeriesArray;

    case {'Frac_RF','Frac_resp', 'MI', 'MI_norm'}
			% restrict dkTS to contacts only ...
			ests = wcES.deriveTimeSeries(dkTS.time, dkTS.timeUnit, [nan 1]);
			dkTSc = dkTS.copy();
			dkTSc.value = dkTS.value.*ests.value;

	    baseStim = nanmedian(dkTS.value);
			threshStim = baseStim + 1.4826*[-2*mad(dkTS.value) 2*mad(dkTS.value)];
	end

	
	% --- CORE CALCULATION
	switch method
		case 'P_cgt' % conditional probability
			% P(ca|single whisker touch)
			PcaGwh = session.eventSeries.getConditionalProbability(caDffTSA, caES, caWindow, [], ...
				[], wcES, [], xes, excludeWindow, [], allowCaOverlap, allowTouchOverlap);
			touchIndex = PcaGwh;

			% restrict by minev
			touchIndex(find(nev < numCaEvMin)) = 0;

		case 'P_tgc' % conditional probability
			% P(single whisker touch|ca)
			PwhGca = 0*nev;
			for r=1:length(caDffTSA.ids)
			  if(nev(r) >= numCaEvMin) % dont waste time
					PwhGca(r) = session.eventSeries.getConditionalProbability(caDffTSA, wcES, touchWindow, xes,  ...
						excludeWindow, caES{r}, [], [], [], [], allowTouchOverlap, allowCaOverlap);
				end
			end
			touchIndex = PwhGca;

		case 'P_prod' % conditional probability
			% P(ca|single whisker touch)
			PcaGwh = session.eventSeries.getConditionalProbability(caDffTSA, caES, caWindow, [], ...
				[], wcES, [], xes, excludeWindow, [], allowCaOverlap, allowTouchOverlap);
			% P(single whisker touch|ca)
			PwhGca = 0*nev;
			disp('000000');
			for r=1:length(caDffTSA.ids)
			  if(nev(r) >= numCaEvMin) % dont waste time
					PwhGca(r) = session.eventSeries.getConditionalProbability(caDffTSA, wcES, touchWindow, xes,  ...
						excludeWindow, caES{r}, [], [], [], [], allowTouchOverlap, allowCaOverlap);
				end
        disp([8 8 8 8 8 8 8 sprintf('%06d', r)]);
      end
			touchIndex = PwhGca.*PcaGwh;

		case 'SNR' % signal-to-noise ratio of post-touch response
			touchIndex = nan*(1:length(caDffTSA.ids)); 
			% make call to getValuesAroundEvents
			for r=1:length(caDffTSA.ids)
				[dataMat timeMat idxMat plotTimeVec] = caDffTSA.getTimeSeriesByIdx(r).getValuesAroundEvents(wcES, touchWindow, 2, ...
						0, xes, excludeWindow);
			  sd = nanstd(dataMat);
				mu = nanmean(dataMat);
				snr = mu./sd;
				[irr midx] = max(mu);
				if (~isnan(snr(midx)) & ~isinf(snr(midx)))
					touchIndex(r) = snr(midx);
				end
			end

		case 'MI' % mutual information between d-kappa (summaxabs, all contacts)
      % first, grab kappa
	  	[sValues respIrr irr1 irr2 irr3 sIdxMat irr4 rIdxMat rValMat sIeIdxVec rIeIdxVec] = ... 
		    session.timeSeries.computeReceptiveFieldAroundEvents (dkTSc, 'summaxabs', ...
		         caDffTSA.getTimeSeriesByIdx(1), 'max', wcES, [-0.1 0.5], [0 2], ...
				     2,0,xes,excludeWindow);
      [irr ia ib] = intersect(sIeIdxVec, rIeIdxVec);
      rIdxMat = rIdxMat(ib,:);
      inval = find(isnan(rIdxMat));
      rIdxMat(inval) = 1;
      
			% make call to getValuesAroundEvents
			touchIndex = nan*(1:length(caDffTSA.ids)); 
			for r=1:length(caDffTSA.ids)
			  caTS = caDffTSA.getTimeSeriesByIdx(r);
				rValueMat = caTS.value(rIdxMat);
        rValueMat(inval) = nan;
				rValues = nanmax(rValueMat');

        % determine valids ..
				val = find(~isnan(rValues));
				
				% compute info
				touchIndex(r) = mutual_info(rValues(val), sValues(val), 'entropy', 4);
			end

		case 'MI_norm' % mutual information between d-kappa (summaxabs, all contacts), normalized to entropy of dkappa
      % first, grab kappa
	  	[sValues respIrr irr1 irr2 irr3 sIdxMat irr4 rIdxMat rValMat sIeIdxVec rIeIdxVec] = ... 
		    session.timeSeries.computeReceptiveFieldAroundEvents (dkTSc, 'summaxabs', ...
		         caDffTSA.getTimeSeriesByIdx(1), 'max', wcES, [-0.1 0.5], [0 2], ...
				     2,0,xes,excludeWindow);
     

			[irr ia ib] = intersect(sIeIdxVec, rIeIdxVec);
      rIdxMat = rIdxMat(ib,:);
      inval = find(isnan(rIdxMat));
      rIdxMat(inval) = 1;
      dkappaEntropy = entropy_calc(sValues, 'ksd1');

			% make call to getValuesAroundEvents
			touchIndex = nan*(1:length(caDffTSA.ids)); 
			for r=1:length(caDffTSA.ids)
			  caTS = caDffTSA.getTimeSeriesByIdx(r);
        if (barInReachOnly) 
				  caTS = caTS.copy();
					caTS.value = caTS.value.*barTS.value ;
				end
				rValueMat = caTS.value(rIdxMat);
        rValueMat(inval) = nan;
				rValues = nanmax(rValueMat');

        % determine valids ..
				val = find(~isnan(rValues));
				
				% compute info
				touchIndex(r) = mutual_info(rValues(val), sValues(val), 'entropy', 4)/dkappaEntropy;
			end



		case 'AUC_Ca' % ROC area-under-curve of stimulus df/f vs. non-stimulus dff
			touchIndex = nan*(1:length(caDffTSA.ids)); 
			% make call to getValuesAroundEvents
			disp('000000');
			for r=1:length(caDffTSA.ids)

        if (length(obj.caTSA.caPeakEventSeriesArray.esa{r}.getStartTimes) >= numCaEvMin)
					caTS = caDffTSA.getTimeSeriesByIdx(r);
					if (barInReachOnly) 
						caTS = caTS.copy();
						caTS.value = caTS.value.*barTS.value ;
					end

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
						touchIndex(r) = roc_area_from_distro(dataVec',noiseVec);
					end
				end

				disp([8 8 8 8 8 8 8 sprintf('%06d', r)]);
			end
			dp5 = find(touchIndex < 0.5) ; 
			touchIndex(dp5) = 1-touchIndex(dp5);


		case 'Frac_RF' % compute receptive field, then look at fraction of points away from axes
			% grab the receptive feidl data
      [sValueMat sTimeMat sIdxMat sTimeVec sIeIdxVec] = dkTSc.getValuesAroundEvents(wcES, touchWindow, 2, ...
		    allowTouchOverlap, xes, excludeWindow);
			% get time mat for first roi ..
      [rValueMat rTimeMat rIdxMat rTimeVec rIeIdxVec] = caDffTSA.getTimeSeriesByIdx(1).getValuesAroundEvents(wcES, ...
			  caWindow, 2, allowTouchOverlap, xes, excludeWindow);
     
      % overlap window
	    overlapEvIdx = intersect(sIeIdxVec, rIeIdxVec);

		  % stim values are ALWAYS the same, so just get them ...
			stimVals = nan*ones(1,size(sValueMat,1));
			for r=1:size(sValueMat,1)
			  stimVals(r) = nanmax(sValueMat(r,:));
				if (abs(nanmin(sValueMat(r,:))) > stimVals(r))
				  stimVals(r) = nanmin(sValueMat(r,:));
				end
			end
			stimVals = stimVals(find(ismember(sIeIdxVec,overlapEvIdx)));

			% prepare subset of rTimeMat we want
			respRows = find(ismember(rIeIdxVec,overlapEvIdx));
			rTimeMat = rTimeMat(respRows,:);
			rIdxMat = rIdxMat(respRows,:);
			nCandi = 0;
			for r=1:size(rTimeMat,1)
			  vals = find(~isnan(rTimeMat(r,:)));
        if (length(vals) > 0) ; nCandi = nCandi + 1; end
			end
			valRs = find(~isnan(rIdxMat));
 
      if (nCandi < numCaEvMin)
			  touchIndex = nan*(1:length(caDffTSA.ids)); 
				disp('computeRoiTouchIndex::rejected by numCaEvMin.');
			else
				for r=1:length(caDffTSA.ids)
					respMat = nan*rIdxMat;

					% pull values
					respMat(valRs) = caDffTSA.valueMatrix(r,rIdxMat(valRs));
					respVals = nanmax(respMat');
		
					% compute thresholds
					baseResp = nanmedian(caDffTSA.valueMatrix(r,:));
					threshResp = baseResp + 1.4826*[-2*mad(caDffTSA.valueMatrix(r,:)) 2*mad(caDffTSA.valueMatrix(r,:))];

					% signal region means you are 2 MADs away from mode
					noiseStim = find(stimVals > threshStim(1) & stimVals< threshStim(2));
					noiseResp = find(respVals > threshResp(1) & respVals < threshResp(2));
					nidx = union(noiseStim, noiseResp);
					sidx = setdiff(1:length(stimVals), nidx);
	 
					touchIndex(r) = length(sidx)/(length(sidx)+length(nidx)); 
				end
			end

		case 'Frac_resp' % compute receptive field, then look at fraction of dff above noise dff
			% grab the receptive feidl data
      [sValueMat sTimeMat sIdxMat sTimeVec sIeIdxVec] = dkTSc.getValuesAroundEvents(wcES, touchWindow, 2, ...
		    allowTouchOverlap, xes, excludeWindow);
			% get time mat for first roi ..
      [rValueMat rTimeMat rIdxMat rTimeVec rIeIdxVec] = caDffTSA.getTimeSeriesByIdx(1).getValuesAroundEvents(...
			  wcES, caWindow, 2, allowTouchOverlap, xes, excludeWindow);
     
      % overlap window
	    overlapEvIdx = intersect(sIeIdxVec, rIeIdxVec);

		  % stim values are ALWAYS the same, so just get them ...
			stimVals = nan*ones(1,size(sValueMat,1));
			for r=1:size(sValueMat,1)
			  stimVals(r) = nanmax(sValueMat(r,:));
				if (abs(nanmin(sValueMat(r,:))) > stimVals(r))
				  stimVals(r) = nanmin(sValueMat(r,:));
				end
			end
			stimVals = stimVals(find(ismember(sIeIdxVec,overlapEvIdx)));

			% prepare subset of rTimeMat we want
			respRows = find(ismember(rIeIdxVec,overlapEvIdx));
			rTimeMat = rTimeMat(respRows,:);
			rIdxMat = rIdxMat(respRows,:);
			nCandi = 0;
			for r=1:size(rTimeMat,1)
			  vals = find(~isnan(rTimeMat(r,:)));
        if (length(vals) > 0) ; nCandi = nCandi + 1; end
			end
			valRs = find(~isnan(rIdxMat));
 
      if (nCandi < numCaEvMin)
			  touchIndex = nan*(1:length(caDffTSA.ids)); 
				disp('computeRoiTouchIndex::rejected by numCaEvMin.');
			else
				for r=1:length(caDffTSA.ids)
					respMat = nan*rIdxMat;

					% pull values
					respMat(valRs) = caDffTSA.valueMatrix(r,rIdxMat(valRs));
					respVals = nanmax(respMat');
		
					% compute thresholds
					baseResp = nanmedian(caDffTSA.valueMatrix(r,:));
					threshResp = baseResp + 1.4826*[-2*mad(caDffTSA.valueMatrix(r,:)) 2*mad(caDffTSA.valueMatrix(r,:))];

					% signal region means you are 2 MADs away from mode
					nidx = find(respVals > threshResp(1) & respVals < threshResp(2));
					sidx = setdiff(1:length(stimVals), nidx);
	 
					touchIndex(r) = length(sidx)/(length(sidx)+length(nidx)); 
				end
			end

		case 'max_dff' % return the maximal df/f following event 
			for r=1:length(caDffTSA.ids)
				[caRespVec sIeIdxVec] = caDffTSA.getTimeSeriesByIdx(r).getSingleValueAroundEvents('max', wcES, touchWindow, 2, ...
					allowTouchOverlap, xes, excludeWindow);
				touchIndex(r)= nanmedian(caRespVec);
			end

		case 'max_dff_mad' % return the maximal df/f following event, divided by MAD over entire session
			popVec = reshape(caDffTSA.valueMatrix,[],1);
			popmad = 1.4862*mad(popVec(find(~isnan(popVec) & ~isinf(popVec) & popVec ~= 0)));
			for r=1:length(caDffTSA.ids)
				[caRespVec sIeIdxVec] = caDffTSA.getTimeSeriesByIdx(r).getSingleValueAroundEvents('max', wcES, touchWindow, 2, ...
					allowTouchOverlap, xes, excludeWindow);
%					touchIndex(wi,r)= nanmedian(caRespVec)/max(popmad,1.4862*mad(caDffTSA.valueMatrix(r,:)));
				touchIndex(r)= nanmedian(caRespVec)/popmad;
			end

		case 'max_dff_mean' % Simply look at event-triggered peak DFF, but look at MEAN
			touchIndex = nan*(1:length(caDffTSA.ids)); 
			% make call to getValuesAroundEvents
			disp('000000');
			for r=1:length(caDffTSA.ids)
			  caTS = caDffTSA.getTimeSeriesByIdx(r);
        if (barInReachOnly) 
				  caTS = caTS.copy();
					caTS.value = caTS.value.*barTS.value ;
				end
				[dataMat timeMat idxMat plotTimeVec] = caTS.getValuesAroundEvents(wcES, touchWindow, 2, ...
						0, xes, excludeWindow);
     
		    meanVec = nanmean(dataMat);
				touchIndex(r) = max(meanVec);

				disp([8 8 8 8 8 8 8 sprintf('%06d', r)]);
			end

		case 'max_dff_median' % Simply look at event-triggered peak DFF, but look at MEDIAN
			touchIndex = nan*(1:length(caDffTSA.ids)); 
			% make call to getValuesAroundEvents
			disp('000000');
			for r=1:length(caDffTSA.ids)
			  caTS = caDffTSA.getTimeSeriesByIdx(r);
        if (barInReachOnly) 
				  caTS = caTS.copy();
					caTS.value = caTS.value.*barTS.value ;
				end
				[dataMat timeMat idxMat plotTimeVec] = caTS.getValuesAroundEvents(wcES, touchWindow, 2, ...
						0, xes, excludeWindow);
     
		    meanVec = nanmedian(dataMat);
				touchIndex(r) = max(meanVec);

				disp([8 8 8 8 8 8 8 sprintf('%06d', r)]);
			end

		case 'corr' % based on peak cross-correlation AFTER contact
		  if (length(dtsIdx) > 0)
			  % pull whisker TS from derived data
  		  dTS = obj.derivedDataTSA.getTimeSeriesByIdx(dtsIdx);
				ntp = 1+ceil(session.timeSeries.convertTime(touchWindow(2), 2, dTS.timeUnit)/mode(diff(dTS.time)));

				% run computing corr off offsets
				offsets = 0:ntp;
 			  for r=1:length(caDffTSA.ids)
				  crosscorr = nan*ntp;
					caTS = caDffTSA.getTimeSeriesByIdx(r);
					if (barInReachOnly) 
						caTS = caTS.copy();
						caTS.value = caTS.value.*barTS.value ;
					end
				  for o=1:length(offsets)
					  crosscorr(o) = session.timeSeries.computeCorrelationS(dTS, caTS, offsets(o),'Spearman');
					end
					touchIndex(r) = max(abs(crosscorr));
				end
			else
			  touchIndex = nan*ones(1,length(caDffTSA.ids));
			end

		case 'overlap' % overlap 
		  if (length(dtsIdx) > 0)
			  % pull whisker TS from derived data
  		  dTS = obj.derivedDataTSA.getTimeSeriesByIdx(dtsIdx);
				ntpTouch = ceil(session.timeSeries.convertTime(touchWindow(2), 2, dTS.timeUnit)/mode(diff(dTS.time)));
				touchConvVec = [zeros(1,ntpTouch) ones(1,ntpTouch+1)];

				% touch vector generate - boolean, expanded by touchWindow
				touchVec = 0*dTS.value;
				touchVec(find(dTS.value ~= 0)) = 1;
        touchVec = conv(touchVec,touchConvVec, 'same');
				touchVec(find(touchVec > 0)) = 1;
         
        % generate binary ca matrix - boolean, expanded by caWindow
				ntpCa = ceil(session.timeSeries.convertTime(-1*caWindow(1), 2, caDffTSA.timeUnit)/mode(diff(dTS.time)));
				caConvVec = [ones(1,ntpCa+1) zeros(1,ntpCa)];
				caMat = caDffTSA.valueMatrix;
				for r=1:size(caMat,1)
				  caMat(r,:) = conv(caMat(r,:), caConvVec, 'same');
				end
				caMat(find(caMat > 0))= 1;

				% exclusive? exclusion is done by REMOVING time points
				valTouchTime = dTS.time;
				if (length(xes) > 0)
				  excludeTimeVec = 0*dTS.time;
				  excludeTimes = [];
					xWindow = session.timeSeries.convertTime(excludeWindow, 2, dTS.timeUnit);
				  ntpExclude = ceil(abs(xWindow)/mode(diff(dTS.time)));
					xWindow = abs(xWindow);
					xConvVec = ones(1,2*max(ntpExclude)+1);
					if (xWindow(1) > xWindow(2))
					  xConvVec(ntpExclude(1)+ntpExclude(2)+1:end) = 0; 
					elseif (xWindow(1) < xWindow(2))
					  xConvVec(1:ntpExclude(2)-ntpExclude(1)) = 0; 
					end

          % grow it
					for x=1:length(xes)
					  ts = session.eventSeries.deriveTimeSeriesS(xes{x}, dTS.time, dTS.timeUnit, [0 1], 2);
            ts = conv(ts.value, xConvVec,'same');
						excludeTimeVec(find(ts)) = 1;
					end

          % apply exclusion ...
          valTouchTime = dTS.time(find(~excludeTimeVec));
				end

				% compute overlap index
				[irr iCa iTouch] = intersect(caDffTSA.time, valTouchTime);
				touchIndex = (touchVec(iTouch)*caMat(:,iCa)')/length(find(touchVec(iTouch)));
				if (length(valTouchTime) < 20) ; touchIndex =  nan*ones(1,length(caDffTSA.ids)); end
			else
			  touchIndex = nan*ones(1,length(caDffTSA.ids));
			end



		otherwise
			disp('computeRoiTouchIndex::unrecognized method.');

	end
