%
% For playing with cell-type classification
%

% gather actives
active = zeros(1,length(s.caTSA.ids));
for r=1:length(s.caTSA.ids)
  if (length(s.caTSA.caPeakEventSeriesArray.esa{r}.eventTimes) > length(s.caTSA.time)/2000)
	  active(r) = 1;
	end
end

% --- touch cell (v. whisk ; reward ; other) 



allTouchTimes = [];
allTouchTrials = [];
%for w=1:length(s.whiskerBarContactESA)
%	allTouchTimes = union(allTouchTimes, s.whiskerBarContactESA.esa{w}.getStartTimes());
%	allTouchTrials = union(allTouchTrials, s.whiskerBarContactESA.esa{w}.eventTrials);
%end
for w=2
%for w=1:length(s.whiskerBarContactClassifiedESA)
	allTouchTimes = union(allTouchTimes, s.whiskerBarContactClassifiedESA.esa{w}.getStartTimes());
	allTouchTrials = union(allTouchTrials, s.whiskerBarContactClassifiedESA.esa{w}.eventTrials);
end

% AUC based approach of Ca signal
if ( 1 == 0)
  
	% for pole-time-only restriction
  poleTS = session.eventSeries.deriveTimeSeriesS(s.whiskerBarInReachES, s.caTSA.time, s.caTSA.timeUnit, [nan 1], 2);
	invalTrialIdx = find(~ismember(s.caTSA.trialIndices,s.validTrialIds));
	poleTS.value(invalTrialIdx) = nan;

	% grab indexing based on first ...
	caTS = s.caTSA.caPeakTimeSeriesArray.getTimeSeriesByIdx(active(1));
	caTS.value = caTS.value.*poleTS.value;
 	[dataMat touchTimeMat idxMat plotTimeVec] = caTS.getValuesAroundEvents(allTouchTimes, [0 2], 2 , 0);
  valIdxMat = find(~isnan(idxMat) & ~isnan(dataMat));

	% now build random data vector from NON contact epoch
	timeVec = caTS.time;
  badIdx = find(ismember(s.caTSA.trialIndices, allTouchTrials));
  timeVec(badIdx) = nan;
	ti = find(~isnan(timeVec));
	rp = randperm(length(ti));
	rp = rp(1:min(length(ti),size(touchTimeMat,1)));
	randTimes = timeVec(ti(rp));
 	[randDataMat timeMat randIdxMat plotTimeVec] = caTS.getValuesAroundEvents(randTimes, [0 2], 2 , 0);
  valRandIdxMat = find(~isnan(randIdxMat) & ~isnan(randDataMat) & ~ismember(randIdxMat,badIdx));

  % and loop, computing AUC
	AUC_trigd = nan*zeros(1,length(s.caTSA.ids));
	disp ('000000');
%figure ; 
	for r=find(active)
	  disp([8 8 8 8 8 8 8 sprintf('%06d',r)]);
    ts =  s.caTSA.caPeakTimeSeriesArray.getTimeSeriesByIdx(r);
    
    dataMat = nan*idxMat;
    dataMat(valIdxMat) = ts.value(idxMat(valIdxMat));
    
    randMat = nan*randIdxMat;
    randMat(valRandIdxMat) = ts.value(randIdxMat(valRandIdxMat));

		% nicolelis distance
		while(size(randMat,2) < size(dataMat,2)) ; dataMat = dataMat(:,1:end-1) ; end
    fullMat = [dataMat ; randMat];
%figure ; imshow(dataMat, [0 2]) ; colormap jet;
%figure ; imshow(randMat, [0 2]) ; colormap jet;
%pause;  close ; close;

%close ; close

    idxA = 1:size(dataMat,1);
    idxB = size(dataMat,1)+1:size(dataMat,1)+size(randMat,1);
    [DVa DVb] = nicolelis_distance(fullMat, idxA, idxB);
 
    
    % AUC
%    AUC_trigd(r) = roc_area_from_distro(DVa, DVb);
    AUC_trigd(r) = roc_area_from_distro(reshape(dataMat,[],1)',reshape(randMat,[],1)');
%cla; plot (nanmean(dataMat), 'r-') ; hold on ; plot (nanmean(randMat), 'b-') ; title(num2str(AUC_trigd(r))); pause(.05);
	end
	ni = find(AUC_trigd < 0.5);
	AUC_trigd(ni) = 1-AUC_trigd(ni);
end


% conditional probabilities
if ( 1 == 0)
	P_touchGca = nan*zeros(1,length(s.caTSA.ids));
	P_caGtouch = nan*zeros(1,length(s.caTSA.ids));
	for r=find(active)
		ri = s.caTSA.ids(r);
		cai = find(s.caTSA.ids == ri);
		options.minBurstLength = 3;
		caTimes = s.caTSA.caPeakEventSeriesArray.esa{cai}.getBurstTimes(1000, options);

		P_touchGca(r) = session.eventSeries.getConditionalProbability(s.caTSA.getTimeSeriesById(ri), ...
			allTouchTimes, [0 .5], [], [], ...
			caTimes, [-.5 0]);

		P_caGtouch(r) = session.eventSeries.getConditionalProbability(s.caTSA.getTimeSeriesById(ri), ...
			caTimes , [-.5 0], [], [], ...
			allTouchTimes, [0 .5]);

		disp (['processing ' num2str(r)]);
	end

	P_prod = P_caGtouch.*P_touchGca;
end

% --- preferred whisker

% conditional probabilities
clear exclusiveTouchTimes;
clear exclusiveTouchTrials;
for w=1:length(s.whiskerBarContactClassifiedESA)
	tes = s.whiskerBarContactClassifiedESA.getTrialBasedExcludedEventSeries(s.whiskerBarContactClassifiedESA.esa{w}.id);
%	tes = s.whiskerBarContactClassifiedESA.esa{w};
	exclusiveTouchTimes{w} = tes.eventTimes;
	exclusiveTouchTrials{w}= tes.eventTrials;
end

if ( 1 == 0)
	for w=1:length(s.whiskerTag)
		P_touchGca_W{w} = nan*zeros(1,length(s.caTSA.ids));
		P_caGtouch_W{w} = nan*zeros(1,length(s.caTSA.ids));
		for r=find(active)
			ri = s.caTSA.ids(r);
			cai = find(s.caTSA.ids == ri);
			options.minBurstLength = 3;
			caTimes = s.caTSA.caPeakEventSeriesArray.esa{cai}.getBurstTimes(1000, options);

			P_touchGca_W{w}(r) = session.eventSeries.getConditionalProbability(s.caTSA.getTimeSeriesById(ri), ...
				exclusiveTouchTimes{w}, [0 .5], [], [], ...
				caTimes, [-.5 0]);

			P_caGtouch_W{w}(r) = session.eventSeries.getConditionalProbability(s.caTSA.getTimeSeriesById(ri), ...
				caTimes , [-.5 0], [], [], ...
				exclusiveTouchTimes{w}, [0 .5]);

			disp (['processing ' num2str(r)]);
		end

		P_prod_W{w} = P_caGtouch_W{w}.*P_touchGca_W{w};
	end
end


% AUC based approach of Ca signal
if ( 1 == 0)
  tsa = s.caTSA.eventBasedDffTimeSeriesArray;
%  tsa = s.caTSA.dffTimeSeriesArray;

	for w=1:length(s.whiskerBarContactClassifiedESA)
		% for pole-time-only restriction
		poleTS = session.eventSeries.deriveTimeSeriesS(s.whiskerBarInReachES, s.caTSA.time, s.caTSA.timeUnit, [nan 1], 2);
		invalTrialIdx = find(~ismember(s.caTSA.trialIndices,s.validTrialIds));
		poleTS.value(invalTrialIdx) = nan;

		% grab indexing based on first ...
		caTS = tsa.getTimeSeriesByIdx(min(find(active)));
		caTSPoleOnly = caTS.copy();
		caTSPoleOnly.value = caTSPoleOnly.value.*poleTS.value;
		[dataMat touchTimeMat idxMat plotTimeVec] = caTSPoleOnly.getValuesAroundEvents(exclusiveTouchTimes{w}, [0 1], 2 , 0);
		valIdxMat = find(~isnan(idxMat) & ~isnan(dataMat));

		% now build random data vector from NON contact epoch
		timeVec = caTS.time;
		badIdx = find(ismember(s.caTSA.trialIndices, exclusiveTouchTrials{w}));
		timeVec(badIdx) = nan;
		ti = find(~isnan(timeVec));
		rp = randperm(length(ti));
		%rp = rp(1:min(length(ti),size(touchTimeMat,1)));
		rp = rp(1:min(length(ti),100));
		randTimes = timeVec(ti(rp));
		[randDataMat timeMat randIdxMat plotTimeVec] = caTS.getValuesAroundEvents(randTimes, [0 1], 2 , 0);
		valRandIdxMat = find(~isnan(randIdxMat) & ~isnan(randDataMat) & ~ismember(randIdxMat,badIdx));

		% and loop, computing AUC
		AUC_trigd_perwh{w} = nan*zeros(1,length(s.caTSA.ids));
		corr_mu_perwh{w} = nan*zeros(1,length(s.caTSA.ids));

		disp ('000000');
%	figure ; 
		for r=find(active)
			disp([8 8 8 8 8 8 8 sprintf('%06d',r)]);
			ts =  tsa.getTimeSeriesByIdx(r);
			
			dataMat = nan*idxMat;
			dataMat(valIdxMat) = ts.value(idxMat(valIdxMat));
			
			randMat = nan*randIdxMat;
			randMat(valRandIdxMat) = ts.value(randIdxMat(valRandIdxMat));

			% nicolelis distance
			while(size(randMat,2) < size(dataMat,2)) ; dataMat = dataMat(:,1:end-1) ; end
			fullMat = [dataMat ; randMat];
	if (0)% (s.caTSA.ids(r) == 1001)
	
	ax = subplot(1,2,1) ; cla;imshow(dataMat, [0 5], 'Parent', ax) ; colormap jet;
	title(num2str(size(dataMat)));
	ax = subplot(1,2,2) ; cla;imshow(randMat, [0 5], 'Parent', ax) ; colormap jet;
	title(num2str(size(randMat)));
	pause;  
	end

	%close ; close

			idxA = 1:size(dataMat,1);
			idxB = size(dataMat,1)+1:size(dataMat,1)+size(randMat,1);
%			[DVa DVb] = nicolelis_distance(fullMat, idxA, idxB);
	 
	
	    % corr-based
if (0)
			rm = randMat;
			rm(find(isnan(rm)))= 0;
      crm = reshape(triu(corr(rm')),[],1); 
			crm = abs(crm) ; 

			dm = dataMat;
			dm(find(isnan(dm)))= 0;
      cdm = reshape(triu(corr(dm')),[],1); 
			cdm = abs(cdm) ; 

      corr_mu_perwh{w}(r) = nanmean(cdm(find(cdm > .01)))/nanmean(crm(find(crm > .01)));
end
			% AUC
%      AUC_trigd_perwh{w}(r) = roc_area_from_distro(DVa, DVb);
			AUC_trigd_perwh{w}(r) = roc_area_from_distro(reshape(dataMat,[],1)',reshape(randMat,[],1)');
	%cla; plot (nanmean(dataMat), 'r-') ; hold on ; plot (nanmean(randMat), 'b-') ; title(num2str(AUC_trigd_perwh(r))); pause(.05);
		end
		ni = find(AUC_trigd_perwh{w} < 0.5);
		AUC_trigd_perwh{w}(ni) = 1-AUC_trigd_perwh{w}(ni);
	end
end


% --- preferred direction

% --- whisk cell
if ( 1 ==  1)

	% different variables [100 200 ; whiskerAngleTSA]
	whSetPointTS = s.derivedDataTSA.getTimeSeriesById(100);
	whAmplitudeTS = s.derivedDataTSA.getTimeSeriesById(200);
  whAngleTS = s.whiskerAngleTSA.getTimeSeriesByIdStr('Angle for c2').reSample(1, [], s.caTSA.time);

  % time points considered
	offsets = -8:8; % +/- 1 second


  % non-contact/lick EPOCHS

	% -- all touch epochs
	touchExcludeWindow = [-2 2];
	eTimes = [];
	for w=1:length(s.whiskerBarContactESA.esa)
		eTimes = union(eTimes, s.whiskerBarContactESA.esa{w}.eventTimes);
	end
	allContactES = session.eventSeries();
	allContactES.eventTimes = eTimes;
	allContactES.updateEventSeriesFromTrialTimes(s.whiskerBarContactESA.trialTimes);
  allContactES.timeUnit = s.whiskerBarContactESA.esa{1}.timeUnit;

  touchIdx = s.caTSA.getTimeSeriesById(1).getIndexWindowsAroundEvents(touchExcludeWindow, 2, allContactES);
	touchIdx = unique(reshape(touchIdx,[],1));
	touchIdx = touchIdx(find(~isnan(touchIdx)));

	touchTS = s.caTSA.getTimeSeriesByIdx(1);
	touchTS.value(:) = 1;
	touchTS.value(touchIdx) = nan;

  % -- all lick epochs
	lickExcludeWindow = [-2 2];

  lickIdx = s.caTSA.getTimeSeriesById(1).getIndexWindowsAroundEvents(lickExcludeWindow, 2, s.behavESA.getEventSeriesByIdStr('beam breaks'));
	lickIdx = unique(reshape(lickIdx,[],1));
	lickIdx = lickIdx(find(~isnan(lickIdx)));

	lickTS = s.caTSA.getTimeSeriesByIdx(1);
	lickTS.value(:) = 1;
	lickTS.value(lickIdx) = nan;

% CONSTRAIN TO NO-CONTACT // NO-LICK

	whAngleCorrMat = nan*zeros(length(offsets),length(s.caTSA.ids));
	whSetpointCorrMat = nan*zeros(length(offsets),length(s.caTSA.ids));
	whAmplitudeCorrMat = nan*zeros(length(offsets),length(s.caTSA.ids));
	disp ('000000');
	for r=1:length(s.caTSA.ids)
		disp([8 8 8 8 8 8 8 sprintf('%06d',r)]);
    dffTS = s.caTSA.dffTimeSeriesArray.getTimeSeriesByIdx(r);
    dffTS.value = dffTS.value.*touchTS.value.*lickTS.value;

	  whAngleCorrMat(:,r) = session.timeSeries.computeCorrelationS(dffTS, whAngleTS, offsets);
	  whSetpointCorrMat(:,r) = session.timeSeries.computeCorrelationS(dffTS, whSetPointTS, offsets);
 	  whAmplitudeCorrMat(:,r) = session.timeSeries.computeCorrelationS(dffTS, whAmplitudeTS, offsets);

% non-linear aspect of RF

% LICK!! [compare corr of whisk vs lick on lick trials ; no-lick trials ; pre-reward]

% reward signka cells
  end

	% assign cellFeatures
  s.cellFeatures.setOrAdd('whAngleCorrMat', whAngleCorrMat);
  s.cellFeatures.setOrAdd('whSetpointCorrMat', whSetpointCorrMat);
  s.cellFeatures.setOrAdd('whAmplitudeCorrMat', whAmplitudeCorrMat);
end

% --- reward cell
