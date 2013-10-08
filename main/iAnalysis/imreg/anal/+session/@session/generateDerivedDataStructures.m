%
% Generates derivedDataTSA and derivedDataESA.  
%
% This method will generate derivedDataTSA and derivedDataESA.  These are 
%  used by subsequent methods to correlate things with caTSA and such. For 
%  derivedDataTSA, it generates timeSeries that have same time vector as caTSA
%  but represent downsampled/upsampled behavioral variables.  For the ESA and
%  TSA, it will generate appropriately restricted (by trial type, e.g.) ES and
%  TSs.
%
% USAGE:
%
%   s.generateDerivedDataStructures(params)
%
% PARAMS: An (optional) structure, params, with the following paramseters:
%
%   rewardExcludeWindow: in seconds, how much around a reward event to exclude
%   touchExcludeWindow: in seconds, how much around a touch event to exclude
%   lickExcludeWindow: in seconds, how much around a lickevent to exclude
%
%   angularRanges: what angular ranges to do ; [-Inf -10; -10 20 ; 20 Inf] e.g.
%   angularRangeLabels: labels to apply to angular ranges ;each par 1 label
%   baseTSA: what timeSeries to use as time basis -- default is obj.caTSA
%
% SP Jan 2012
%
function generateDerivedDataStructures(obj, params)
  %% --- process input arguments
	excludeWindowTimeUnit = session.timeSeries.second;
  rewardExcludeWindow = [-5 5]; 
  touchExcludeWindow = [-3 3]; 
  lickExcludeWindow = [-3 3]; 

	angularRanges = [-Inf -10; -10 Inf];
	angularRangeLabels = {'Post', 'Ant'};
  baseTSA = obj.caTSA;

	dtDelayMS = 500; % delay STARTS this many ms after pole-withdraw command

  % if they actually passed anything ...
  if (nargin > 1 && isstruct(params))
	  pfields = fieldnames(params);
	  for p=1:length(pfields)
		  eval([pfields{p} ' = params.' pfields{p} ';']);
		end
	end

	%% --- da basics
  baseTime = baseTSA.time;
	baseTimeUnit = baseTSA.timeUnit;
  baseTrialIndices = baseTSA.trialIndices;
	baseTS = baseTSA.getTimeSeriesByIdx(1).copy();
	frameDt = mode(diff(baseTime));

	% use best whisker (least nans)
	for w=1:length(obj.whiskerAngleTSA)
		nNan(w) = length(find(isnan(obj.whiskerAngleTSA.valueMatrix(w,:))));
	end
	[irr bestWhIdx] = min(nNan);
  whAngTS = obj.whiskerAngleTSA.getTimeSeriesByIdx(bestWhIdx(1));
	whNanVals = find(isnan(whAngTS.value));
 
  dTSA = {};
	dESA = {};

  %% --- verify that generateContactPropertiesHashes was run
	runGCPH = 0;
	for e=1:length(obj.whiskerBarContactESA)
	  if (length(obj.whiskerBarContactESA.esa{e}.eventPropertiesHash) < 1)
		  disp('generateCellFeaturesHash::must first run generateContactPropertiesHashes.');
			runGCPH = 1;
		end
	end
	for e=1:length(obj.whiskerBarContactClassifiedESA)
	  if (length(obj.whiskerBarContactClassifiedESA.esa{e}.eventPropertiesHash) < 1)
		  disp('generateCellFeaturesHash::must first run generateContactPropertiesHashes.');
			runGCPH = 1;
		end
	end
  if (runGCPH) ; obj.generateContactPropertiesHashes(); end

	%% --- variables used for epoch definition

  % whisker angular ranges (epoch is 1 if whisker was there during that time ; nan if not)a
	%  note that angular range epoch will be 1 if even a single frame at the angular
	%  range existed.
	for a=1:size(angularRanges,1)
    whTmpTS = whAngTS.copy();
		valIdx = find(whTmpTS.value >= angularRanges(a,1) & whTmpTS.value <= angularRanges(a,2));
		invalIdx = setdiff(1:whTmpTS.length(),valIdx);

		whTmpTS.value(invalIdx) = nan;
		whTmpTS.value(valIdx) = 1;

		whAngEpochTS{a} = whTmpTS.reSample(1,[],baseTime);
	end

  % bar-in-reach epoch 
	barInReachEpochTS = obj.whiskerBarInReachES.deriveTimeSeries(baseTime, baseTimeUnit, [nan 1]);

  % trial-by-trial for epoch setups -- NaN except during
	preStimEpochTS = barInReachEpochTS.copy();
	preStimEpochTS.idStr = 'PreStimulus Epoch';
	preStimEpochTS.value = nan*preStimEpochTS.time; 
	delayEpochTS = preStimEpochTS.copy();
	delayEpochTS.idStr = 'Delay Epoch';
	rewardEpochTS =  preStimEpochTS.copy();
	rewardEpochTS.idStr = 'Reward Epoch';
	uti = unique(baseTrialIndices);

	poleMoveTimes = obj.behavESA.getEventSeriesByIdStr('Pole Movement').eventTimes;
	poleMoveTrials = obj.behavESA.getEventSeriesByIdStr('Pole Movement').eventTrials;

	for t=1:length(uti)
	  trialId = uti(t);
		ti = find(obj.trialIds == trialId);

		% pole stuff
		poleIdx = find(poleMoveTrials == trialId);
		poleTimes = poleMoveTimes(poleIdx);

		if (length(poleTimes) == 0) ; continue ; end % weird!

		% - pre-stimulus epoch
		trialStarti = min(find(baseTrialIndices == trialId));
		pole1i = min(find(baseTime >= poleTimes(1)));
		if (length(pole1i) == 1 && length(trialStarti) == 1)
		  preStimEpochTS.value(trialStarti:pole1i) = 1;
		end

		if (length(poleTimes) < 2) ; continue ; end % weird!
    
		% - delay epoch (some minimal dt after bar leaves to negate final contacts)
    if (length(obj.behavESA.getEventSeriesByIdStr('Reward Cue')) > 0)
      cueTrials = obj.behavESA.getEventSeriesByIdStr('Reward Cue').eventTrials;
      tcti = find(cueTrials == trialId);
      if (length(tcti) < 1) ; continue ; end
      delayDurationMS = obj.behavESA.getEventSeriesByIdStr('Reward Cue').eventTimes(tcti(1))-poleTimes(2);
    else
      delayDurationMS = 1000*(obj.trial{ti}.behavParams.get('PoleRetractTime') + ...
                             obj.trial{ti}.behavParams.get('PreAnswerTime'));
    end
		pole2i = min(find(baseTime >= poleTimes(2)));

    delaySi = min(find(baseTime >= poleTimes(2)+dtDelayMS));
		delayEi = min(find(baseTime >= poleTimes(2)+delayDurationMS));
		if (delaySi < delayEi) % delay may be too short ... ah well!
		  delayEpochTS.value(delaySi:delayEi) = 1;
		end

		% - reward collection epoch
		trialEndi = max(find(baseTrialIndices == trialId));
		rewardEpochTS.value(delayEi+1:trialEndi) = 1;
	end

	% no reward epochs (either port) [old: 'Water Valve' ; new: 'Water Valve Left'/Right
	if ( length(obj.behavESA.getEventSeriesByIdStr('Water Valve Left',1)) > 0)
		rewardESL = obj.behavESA.getEventSeriesByIdStr('Water Valve Left',1);
		rewardESR = obj.behavESA.getEventSeriesByIdStr('Water Valve Right',1);
		rewardIdxL = baseTS.getIndexWindowsAroundEvents(rewardExcludeWindow, ...
			2, rewardESL);
		rewardIdxR = baseTS.getIndexWindowsAroundEvents(rewardExcludeWindow, ...
			2, rewardESR);

		rewardIdx = union(unique(reshape(rewardIdxL,[],1)), unique(reshape(rewardIdxR,[],1)));

		allRewardES = session.eventSeries();
	  allRewardES.eventTimes = sort(union(rewardESL.eventTimes, rewardESR.eventTimes));
		allRewardES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
		allRewardES.timeUnit = rewardESL.timeUnit;
		allRewardES.type = 2;
	else % assume at least one!
		allRewardES = obj.behavESA.getEventSeriesByIdStr('Water Valve',1);
		allRewardES.type = 2;
		rewardIdx = baseTS.getIndexWindowsAroundEvents(rewardExcludeWindow, ...
			2, allRewardES);
		rewardIdx = unique(reshape(rewardIdx,[],1));
	end
	rewardIdx = rewardIdx(find(~isnan(rewardIdx)));
	noRewardEpochTS = baseTS.copy();
	noRewardEpochTS.value(:) = 1;
	noRewardEpochTS.value(rewardIdx) = nan;

	% no touches epochs (any whiskers)
	eTimes = [];
	for w=1:length(obj.whiskerBarContactClassifiedESA.esa)
		eTimes = union(eTimes, obj.whiskerBarContactClassifiedESA.esa{w}.eventTimes);
	end
	allContactES = session.eventSeries();
	allContactES.eventTimes = eTimes;
	allContactES.updateEventSeriesFromTrialTimes(obj.whiskerBarContactClassifiedESA.trialTimes);
  allContactES.timeUnit = obj.whiskerBarContactESA.esa{1}.timeUnit;
  touchIdx = baseTS.getIndexWindowsAroundEvents(touchExcludeWindow, ...
	                 2, allContactES);
	touchIdx = unique(reshape(touchIdx,[],1));
	touchIdx = touchIdx(find(~isnan(touchIdx)));
	noTouchEpochTS = baseTS.copy();
	noTouchEpochTS.value(:) = 1;
	noTouchEpochTS.value(touchIdx) = nan;

	% no lick epoch (either lickport) [old: 'Beam Breaks' ; new 'Beam Breaks Left'/Right
	%  also all lick ES
	allLickTimes = [];
	allLickES = session.eventSeries();
	allLickES.id = 1; 
	allLickES.idStr = 'All Licks';
	allLickES.type = 1;
  % ideal: licklaser
	if (length(obj.behavESA.getEventSeriesByIdStr('Lick Laser') > 0))
		lickES = obj.behavESA.getEventSeriesByIdStr('Lick Laser',1);
		lickIdx = baseTS.getIndexWindowsAroundEvents(lickExcludeWindow, ...
			2, lickES);
		lickIdx = unique(reshape(lickIdx,[],1));
		allLickTimes = lickES.eventTimes;
		allLickES.timeUnit = lickES.timeUnit;
  % alternate: left and right beam break
	elseif ( length(obj.behavESA.getEventSeriesByIdStr('Beam Breaks Left',1)) > 0)
		lickESL = obj.behavESA.getEventSeriesByIdStr('Beam Breaks Left',1);
		lickESR = obj.behavESA.getEventSeriesByIdStr('Beam Breaks Right',1);
		lickIdxL = baseTS.getIndexWindowsAroundEvents(lickExcludeWindow, ...
			2, lickESL);
		lickIdxR = baseTS.getIndexWindowsAroundEvents(lickExcludeWindow, ...
			2, lickESR);

		lickIdx = union(unique(reshape(lickIdxR,[],1)), unique(reshape(lickIdxL,[],1)));

		allLickTimes = union(lickESL.eventTimes, lickESR.eventTimes);
		allLickES.timeUnit = lickESL.timeUnit;
  % assume at least one!
	else 
		lickES = obj.behavESA.getEventSeriesByIdStr('Beam Breaks',1);
		lickIdx = baseTS.getIndexWindowsAroundEvents(lickExcludeWindow, ...
			2, lickES);
		lickIdx = unique(reshape(lickIdx,[],1));
		allLickTimes = lickES.eventTimes;
		allLickES.timeUnit = lickES.timeUnit;
	end
	lickIdx = lickIdx(find(~isnan(lickIdx)));
	noLickEpochTS = baseTS.copy();
	noLickEpochTS.value(:) = 1;
	noLickEpochTS.value(lickIdx) = nan;

	allLickES.eventTimes = allLickTimes;
	allLickES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);

	%% --- whisking related variables 10000s
  whAngVec = whAngTS.value;
  whVelVec = diff(whAngVec);
	whVelVec(end+1) = nan;
	wVars = [];
	whDtSec = session.timeSeries.convertTime(mode(diff(whAngTS.time)), whAngTS.timeUnit, session.timeSeries.second);
  
	%% prelims

	% A foray into Hilbert transforms ....
	whAngVec(find(isnan(whAngVec))) = 0; % otherwise this breaks

	sampleRate=  1/whDtSec;
	BandPassCutOffsInHz = [6 30];  %%check filter parameters!!!
	W1 = BandPassCutOffsInHz(1) / (sampleRate/2);
	W2 = BandPassCutOffsInHz(2) / (sampleRate/2);
	[b,a]=butter(2,[W1 W2]);
	filteredSignal = filtfilt(b, a, whAngVec);

	[b,a]=butter(2, 6/ (sampleRate/2),'low');
	setpoint = filtfilt(b,a,whAngVec-filteredSignal);

	hh=hilbert(filteredSignal);
	amplitude = abs(hh);

	% restore nan's
	whAngVec(whNanVals) = nan;
	setpoint(whNanVals) = nan;
	amplitude(whNanVals) = nan;


  %% assignment

	% basic: setpoint
  dTS = session.timeSeries(whAngTS.time, whAngTS.timeUnit, setpoint, 10000, 'Whisker setpoint',0,[]);
	dTS.reSample (1, [], baseTime);
	dTSA{length(dTSA)+1} = dTS;
	wVars = [wVars length(dTSA)];

	% basic: mean amplitude
  dTS = session.timeSeries(whAngTS.time, whAngTS.timeUnit, amplitude, 10010, 'Mean whisker amplitude',0,[]);
	dTS.reSample (1, [], baseTime);
	dTSA{length(dTSA)+1} = dTS;
	wVars = [wVars length(dTSA)];

	% basic: max amplitude
  dTS = session.timeSeries(whAngTS.time, whAngTS.timeUnit, amplitude, 10011, 'Max whisker amplitude',0,[]);
	dTS.reSample (2, [], baseTime);
	dTSA{length(dTSA)+1} = dTS;
	wVars = [wVars length(dTSA)];

	% basic: mean velocity
  dTS = session.timeSeries(whAngTS.time, whAngTS.timeUnit, whVelVec, 10020, 'Mean whisker velocity',0,[]);
	dTS.reSample (1, [], baseTime);
	dTSA{length(dTSA)+1} = dTS;
	wVars = [wVars length(dTSA)];

	% basic: max velocity
  dTS = session.timeSeries(whAngTS.time, whAngTS.timeUnit, whVelVec, 10021, 'Max whisker velocity',0,[]);
	dTS.reSample (4, [], baseTime);
	dTSA{length(dTSA)+1} = dTS;
	wVars = [wVars length(dTSA)];

  % angular ranges loop
  nwVars = wVars;
  for a=1:size(angularRanges,1)
	  idOffs = a*1000;
	  for v=1:length(wVars)
			% basics x no lick
			dTS = dTSA{wVars(v)}.copy();
			dTS.id = dTS.id + idOffs;
			dTS.value = dTS.value .* whAngEpochTS{a}.value;
			dTS.idStr = [dTS.idStr ' ' angularRangeLabels{a}];
			dTSA{length(dTSA)+1} = dTS;
			
			nwVars = [nwVars length(dTSA)];
		end
	end
	wVars = nwVars;

  for v=1:length(wVars)
		% basics x no lick
		dTS = dTSA{wVars(v)}.copy();
		dTS.id = dTS.id + 100;
		dTS.value = dTS.value .* noLickEpochTS.value;
		dTS.idStr = [dTS.idStr ' no lick'];
		dTSA{length(dTSA)+1} = dTS;

		% basics x no touch 
		dTS = dTSA{wVars(v)}.copy();
		dTS.id = dTS.id + 200;
		dTS.value = dTS.value .* noTouchEpochTS.value;
		dTS.idStr = [dTS.idStr ' no touch'];
		dTSA{length(dTSA)+1} = dTS;

		% basics x no lick ; no touch
		dTS = dTSA{wVars(v)}.copy();
		dTS.id = dTS.id + 300;
		dTS.value = dTS.value .* noLickEpochTS.value .* noTouchEpochTS.value;
		dTS.idStr = [dTS.idStr ' no lick no touch'];
		dTSA{length(dTSA)+1} = dTS;
	end

	%% --- touch related variables 20000s
  
	tVars = [];
	etVars = [];
	for w=1:length(obj.whiskerTag)
		whKapTS = obj.whiskerCurvatureChangeTSA.getTimeSeriesByIdx(w);

    % - TS based 

		% max abs kappa (max of abs(dKappa) )
		dTS = whKapTS.copy();
		dTS.value = abs(dTS.value);
		dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20000+w, [obj.whiskerTag{w} ' max (abs(kappa))'],0,[]);
		dTS.reSample (2, [], baseTime);
		dTSA{length(dTSA)+1} = dTS;
		tVars = [tVars length(dTSA)];
		
		% abs max kappa (i.e., if largest amplitude is a neg #, this is a neg # ; pos if pos)
		dTS = whKapTS.copy();
		dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20010+w, [obj.whiskerTag{w} ' abs max kappa'],0,[]);
		dTS.reSample (4, [], baseTime);
		dTSA{length(dTSA)+1} = dTS;
		tVars = [tVars length(dTSA)];
		
		% max neg kappa
		dTS = whKapTS.copy();
		dTS.value(find(dTS.value > 0)) = 0;
		dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20020+w, [obj.whiskerTag{w} ' max neg kappa'],0,[]);
		dTS.reSample (4, [], baseTime);
		dTSA{length(dTSA)+1} = dTS;
		tVars = [tVars length(dTSA)];

		% max pos kappa
		dTS = whKapTS.copy();
		dTS.value(find(dTS.value < 0)) = 0;
		dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20030+w, [obj.whiskerTag{w} ' max pos kappa'],0,[]);
		dTS.reSample (2, [], baseTime);
		dTSA{length(dTSA)+1} = dTS;
		tVars = [tVars length(dTSA)];

		% - ES based: unclassified touches 
		if (length(obj.whiskerBarContactESA.esa{w}.eventPropertiesHash.get('kappaMaxAbsOverTouch')) > 0)
		  eVars = [];

		  touchIdx = obj.whiskerBarContactESA.esa{w}.eventPropertiesHash.get('whTSACorrespondingIndex');
		  kappaTouch = obj.whiskerBarContactESA.esa{w}.eventPropertiesHash.get('kappaMaxAbsOverTouch');
		  thetaTouch = obj.whiskerBarContactESA.esa{w}.eventPropertiesHash.get('thetaMeanOverTouch');

      % build a resampled timeseries where missing values are nan
			whKapNanTS = whKapTS.copy();
			whKapNanTS.reSample(1,[],baseTime);
			whKapNanIdx = find(isnan(whKapNanTS.value));


			% touches: kappaMaxAbsOverTouch 
			dTS = whKapTS.copy();
			dTS.value(:) = nan;
		  dTS.value(touchIdx) = kappaTouch;
			dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20040+w, [obj.whiskerTag{w} ' max sumabskappa at touch'],0,[]);
			dTS.reSample (4, [], baseTime, 'nearest');
			dTSA{length(dTSA)+1} = dTS;
			tVars = [tVars length(dTSA)];
			eVars = [eVars length(dTSA)];

			% touches: thetaMeanOverTouch
			dTS = whKapTS.copy();
			dTS.value(:) = nan;
		  dTS.value(touchIdx) = thetaTouch;
			dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20050+w, [obj.whiskerTag{w} ' mean thetamean at touch'],0,[]);
			dTS.reSample (1, [], baseTime, 'nearest');
			dTSA{length(dTSA)+1} = dTS;
			tVars = [tVars length(dTSA)];
			eVars = [eVars length(dTSA)];

		  % - ES based: pro & ret touches
		  for wi=[((2*w)-1) 2*w]
				touchIdx = obj.whiskerBarContactClassifiedESA.esa{wi}.eventPropertiesHash.get('whTSACorrespondingIndex');
				kappaTouch = obj.whiskerBarContactClassifiedESA.esa{wi}.eventPropertiesHash.get('kappaMaxAbsOverTouch');
				thetaTouch = obj.whiskerBarContactClassifiedESA.esa{wi}.eventPropertiesHash.get('thetaMeanOverTouch');

				preTag = obj.whiskerBarContactClassifiedESA.esa{wi}.idStr(1:3);

				% touches: kappaMaxAbsOverTouch 
				dTS = whKapTS.copy();
				dTS.value(:) = nan;
				dTS.value(touchIdx) = kappaTouch;
				dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20060+wi, [obj.whiskerTag{w} ' ' preTag ' max sumabskappa at touch'],0,[]);
				dTS.reSample (4, [], baseTime, 'nearest');
				dTSA{length(dTSA)+1} = dTS;
				tVars = [tVars length(dTSA)];
				eVars = [eVars length(dTSA)];

				% touches: thetaMeanOverTouch
				dTS = whKapTS.copy();
				dTS.value(:) = nan;
				dTS.value(touchIdx) = thetaTouch;
				dTS = session.timeSeries(dTS.time, dTS.timeUnit, dTS.value, 20070+wi, [obj.whiskerTag{w} ' ' preTag ' mean thetamean at touch'],0,[]);
				dTS.reSample (1, [], baseTime, 'nearest');
				dTSA{length(dTSA)+1} = dTS;
				tVars = [tVars length(dTSA)];
				eVars = [eVars length(dTSA)];
			end

			% for all event-based vars, build equivalent variables with zero values where no touch occured
			for e=1:length(eVars)
				% basics x no lick
				dTS = dTSA{eVars(e)}.copy();
				dTS.id = dTS.id + 100;
				dTS.value(find(isnan(dTS.value))) = 0;
				dTS.value(whKapNanIdx) = nan;
				dTS.idStr = [dTS.idStr ' zero notouch'];
				dTSA{length(dTSA)+1} = dTS;
				tVars = [tVars length(dTSA)];
			end
		end

		% - ESA stuff (and the derived variables)
		dES = obj.whiskerBarContactESA.esa{w}.copy();
		dES.id = 20000 + 10*w;
		dESA{length(dESA)+1} = dES;
	  etVars = [etVars length(dESA)];

		dTS = dES.deriveTimeSeries(baseTime,baseTimeUnit,[0 1]);
		dTS.id = 21000 + 10*w;
		dTSA{length(dTSA)+1} = dTS;
		tVars = [tVars length(dTSA)];

		for wi=[((2*w)-1) 2*w]
			dES = obj.whiskerBarContactClassifiedESA.esa{wi};
			dES.id = 20000 + 10*w + wi;
			dESA{length(dESA)+1} = dES;
			etVars = [etVars length(dESA)];

			dTS = dES.deriveTimeSeries(baseTime,baseTimeUnit,[0 1]);
			dTS.id = 21000 + 10*w  + wi;
			dTSA{length(dTSA)+1} = dTS;
			tVars = [tVars length(dTSA)];
    end
	end

  % angular ranges loop
  ntVars = tVars;
  for a=1:size(angularRanges,1)
	  idOffs = 3000+ a*1000;
	  for v=1:length(tVars)
			% basics x no lick
			dTS = dTSA{tVars(v)}.copy();
			dTS.id = dTS.id + idOffs;
			dTS.value = dTS.value .* whAngEpochTS{a}.value;
			dTS.idStr = [dTS.idStr ' ' angularRangeLabels{a}];
			dTSA{length(dTSA)+1} = dTS;
			
			ntVars = [ntVars length(dTSA)];
		end
	end
	tVars = ntVars;

	% all TSA above, x noLick
  for v=1:length(tVars)
		% base x no lick
		dTS = dTSA{tVars(v)}.copy();
		dTS.id = dTS.id + 500;
		dTS.value = dTS.value .* noLickEpochTS.value;
		dTS.idStr = [dTS.idStr ' no lick'];
		dTSA{length(dTSA)+1} = dTS;
	end

	% all ESA above, x noLick
	for v=1:length(etVars)
		% base x no lick
    dES = session.eventSeries.getExcludedEventSeriesS(dESA{etVars(v)}, allLickES, allLickES.timeUnit, lickExcludeWindow, 0);
		dES.id = dESA{etVars(v)}.id + 500;
		dES.idStr = [dESA{etVars(v)}.idStr ' no lick'];
		dESA{length(dESA)+1} = dES;
	end

	%% --- licking (all, L, R) 30000s
	
	lVars = [];
	elVars = [];
	% L/R lick rates
	if ( length(obj.behavESA.getEventSeriesByIdStr('Beam Breaks Left',1)) > 0)
		lickESL = obj.behavESA.getEventSeriesByIdStr('Beam Breaks Left',1);
		lickESR = obj.behavESA.getEventSeriesByIdStr('Beam Breaks Right',1);

    dTS = lickESL.deriveRateTimeSeries(baseTime);
		dTS.value = 1000*dTS.value; % hz
		dTS.id = 30001;
		dTSA{length(dTSA)+1} = dTS;
		lVars = [lVars length(dTSA)];

		dES = lickESL.copy();
		dES.id = 30001;
		dESA{length(dESA)+1} = dES;
		elVars = [elVars length(dESA)];

    dTS = lickESR.deriveRateTimeSeries(baseTime);
		dTS.value = 1000*dTS.value; % hz
		dTS.id = 30002;
		dTSA{length(dTSA)+1} = dTS;
		lVars = [lVars length(dTSA)];

		dES = lickESR.copy();
		dES.id = 30002;
		dESA{length(dESA)+1} = dES;
		elVars = [elVars length(dESA)];

		lickESAll = session.eventSeries();
	  lickESAll.eventTimes = sort(union(lickESL.eventTimes, lickESR.eventTimes));
		lickESAll.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
		lickESAll.timeUnit = lickESL.timeUnit;
	else
		lickESAll = obj.behavESA.getEventSeriesByIdStr('Beam Breaks',1);
	end
	lickESAll.id = 1; 
	lickESAll.idStr = 'Beam Breaks All';
	lickESAll.type = 1;

	% all lick rate
	dTS = lickESAll.deriveRateTimeSeries(baseTime);
	dTS.value = 1000*dTS.value; % hz
	dTS.id = 30000;
	dTSA{length(dTSA)+1} = dTS;
	lVars = [lVars length(dTSA)];

	dES = lickESAll.copy();
	dES.id = 30000;
	dESA{length(dESA)+1} = dES;
	elVars = [elVars length(dESA)];

	% lick laser
	if (length(obj.behavESA.getEventSeriesByIdStr('Lick Laser') > 0))
		lickLaserES = obj.behavESA.getEventSeriesByIdStr('Lick Laser',1);
		lickLaserTimes = lickLaserES.eventTimes;
		lickLaserES.timeUnit = lickLaserES.timeUnit;

		dTS = lickLaserES.deriveRateTimeSeries(baseTime);
		dTS.value = 1000*dTS.value; % hz
		dTS.id = 30003;
		dTSA{length(dTSA)+1} = dTS;
		lVars = [lVars length(dTSA)];

		dES = lickLaserES.copy();
		dES.id = 30003;
		dESA{length(dESA)+1} = dES;
		elVars = [elVars length(dESA)];
	end

	% above x no reward, no touch, no touch + no reward
	for l=1:length(lVars)
		% basics x no reward
		dTS = dTSA{lVars(l)}.copy();
		dTS.id = dTS.id + 100;
		dTS.value = dTS.value .* noRewardEpochTS.value;
		dTS.idStr = [dTS.idStr ' no reward'];
		dTSA{length(dTSA)+1} = dTS;

		% basics x no touch 
		dTS = dTSA{lVars(l)}.copy();
		dTS.id = dTS.id + 200;
		dTS.value = dTS.value .* noTouchEpochTS.value;
		dTS.idStr = [dTS.idStr ' no touch'];
		dTSA{length(dTSA)+1} = dTS;

		% basics x no touch or reward
		dTS = dTSA{lVars(l)}.copy();
		dTS.id = dTS.id + 300;
		dTS.value = dTS.value .* noTouchEpochTS.value .* noRewardEpochTS.value;
		dTS.idStr = [dTS.idStr ' no touch no reward'];
		dTSA{length(dTSA)+1} = dTS;
	end

  % above x no reward, no touch, no touch + no reward
	for l=1:length(elVars)
	  % basics x no reward
	  dES = session.eventSeries.getExcludedEventSeriesS(dESA{elVars(l)}, allRewardES, allRewardES.timeUnit, rewardExcludeWindow, 0);
		dES.id = dESA{elVars(l)}.id + 100;
		dES.idStr = [dESA{elVars(l)}.idStr ' no reward'];
		dESA{length(dESA)+1} = dES;

	  % basics x no touch
	  dES = session.eventSeries.getExcludedEventSeriesS(dESA{elVars(l)}, allContactES, allContactES.timeUnit, touchExcludeWindow, 0);
		dES.id = dESA{elVars(l)}.id + 200;
		dES.idStr = [dESA{elVars(l)}.idStr ' no touch'];
		dESA{length(dESA)+1} = dES;

	  % basics x no touch, reward
		dES = session.eventSeries();
		dES.eventTimes = intersect(dESA{length(dESA)}.eventTimes, dESA{length(dESA)-1}.eventTimes);
		dES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
		dES.timeUnit = dESA{length(dESA)}.timeUnit;
		dES.id = dESA{elVars(l)}.id + 300;
		dES.idStr = [dESA{elVars(l)}.idStr ' no touch no reward'];
		dESA{length(dESA)+1} = dES;
	end
	
	%% --- pole movement (all, in, out) 40000s

	barMoveES = session.eventSeries();
	barMove1ES = session.eventSeries();
	barMove2ES = session.eventSeries();
	barMoveES.eventTimes = obj.behavESA.getEventSeriesByIdStr('Pole Movement').eventTimes;
	barMove1ES.eventTimes = obj.behavESA.getEventSeriesByIdStr('Pole Movement').getStartTimes();
	barMove2ES.eventTimes = obj.behavESA.getEventSeriesByIdStr('Pole Movement').getEndTimes();
	barMoveES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
	barMove1ES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
	barMove2ES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
  barMoveES.timeUnit = obj.behavESA.getEventSeriesByIdStr('Pole Movement').timeUnit;
  barMove1ES.timeUnit = obj.behavESA.getEventSeriesByIdStr('Pole Movement').timeUnit;
  barMove2ES.timeUnit = obj.behavESA.getEventSeriesByIdStr('Pole Movement').timeUnit;

	% all
  dTS = barMoveES.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	dTS.id = 40000;
	dTS.idStr = 'Pole Move All';
	dTSA{length(dTSA)+1} = dTS;

	dES = barMoveES.copy();
	dES.id = 40000;
	dES.idStr = 'Pole Move All';
	dESA{length(dESA)+1} = dES;

	% in
  dTS = barMove1ES.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	dTS.id = 40001;
	dTS.idStr = 'Pole Move In';
	dTSA{length(dTSA)+1} = dTS;

	dES = barMove1ES.copy();
	dES.id = 40001;
	dES.idStr = 'Pole Move In';
	dESA{length(dESA)+1} = dES;

	% out
  dTS = barMove2ES.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	dTS.id = 40002;
	dTS.idStr = 'Pole Move Out';
	dTSA{length(dTSA)+1} = dTS;

	dES = barMove2ES.copy();
	dES.id = 40002;
	dES.idStr = 'Pole Move Out';
	dESA{length(dESA)+1} = dES;

	%% --- reward  (all, L, R) 50000s ; cue
	
	% left/right reward
	if ( length(obj.behavESA.getEventSeriesByIdStr('Water Valve Left',1)) > 0)
    dTS = rewardESL.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
		dTS.id = 50001;
	  dTS.idStr = 'Left Rewards';
		dTSA{length(dTSA)+1} = dTS;

    dTS = rewardESR.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
		dTS.id = 50002;
	  dTS.idStr = 'Right Rewards';
		dTSA{length(dTSA)+1} = dTS;

		dES = rewardESL.copy();
		dES.id = 50001;
		dES.idStr = 'Left Rewards';
		dESA{length(dESA)+1} = dES;

		dES = rewardESR.copy();
		dES.id = 50002;
		dES.idStr = 'Right Rewards';
		dESA{length(dESA)+1} = dES;
	end

	% all reward
  dTS = allRewardES.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	dTS.idStr = 'All Rewards';
	dTS.id = 50000;
	dTSA{length(dTSA)+1} = dTS;

	dES = allRewardES.copy();
	dES.id = 50000;
	dES.idStr = 'All Rewards';
	dESA{length(dESA)+1} = dES;

	% reward cue
	if (length(obj.behavESA.getEventSeriesByIdStr('Reward Cue',1)) > 0)
		dTS = obj.behavESA.getEventSeriesByIdStr('Reward Cue').deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
		dTS.idStr = 'Reward Cue';
		dTS.id = 50005;
		dTSA{length(dTSA)+1} = dTS;

		dES = obj.behavESA.getEventSeriesByIdStr('Reward Cue');
		dES.id = 50005;
		dES.idStr = 'Reward Cue';
		dESA{length(dESA)+1} = dES;
	end

	%% --- abstract varialbes (stimulus position, trial class, animal response) 60000s
  %      for these, regression trees should consider them to be discrete, and you
	%      should mark different epochs to determine if coding is epoch-specific

	if (length(obj.trial) > 0 & isobject(obj.trial{1}.behavParams))
		%% stimulus position
		stimPosTS = baseTS.copy();
		stimPosTS.id = 60000;
		stimPosTS.idStr = 'Stimulus Position';
		stimPosTS.value(:) = 0;
		for t=1:length(obj.trial)
		  stimPos = obj.trial{t}.behavParams.get('stimulus');
      bti = find(baseTrialIndices == obj.trial{t}.id);
			stimPosTS.value(bti) = stimPos;
		end
		dTS = stimPosTS;
	  dTSA{length(dTSA)+1} = dTS;
		stimPosIdx = length(dTSA);

		%% trial type
		trialTypeTS = baseTS.copy();
		trialTypeTS.id = 60100;
		trialTypeTS.idStr = 'Trial Type';
		trialTypeTS.value(:) = 0;
		anResponse = 0*obj.trialIds;
		corrResponse = 0*obj.trialIds;

    leftResponses = [find(strcmp(obj.trialTypeStr, 'HitL')) find(strcmp(obj.trialTypeStr, 'ErrR'))];
    rightResponses = [find(strcmp(obj.trialTypeStr, 'HitR')) find(strcmp(obj.trialTypeStr, 'ErrL'))];
    noResponses = [find(strcmp(obj.trialTypeStr, 'NoLickL')) find(strcmp(obj.trialTypeStr, 'NoLickR'))];

    leftTrial = [find(strcmp(obj.trialTypeStr, 'HitL')) find(strcmp(obj.trialTypeStr, 'ErrL')) find(strcmp(obj.trialTypeStr, 'NoLickL'))];
    rightTrial = [find(strcmp(obj.trialTypeStr, 'HitR')) find(strcmp(obj.trialTypeStr, 'ErrR')) find(strcmp(obj.trialTypeStr, 'NoLickR'))];

		for t=1:length(obj.trial)
		  trialType = obj.trial{t}.typeIds(1);
      bti = find(baseTrialIndices == obj.trial{t}.id);
			trialTypeTS.value(bti) = trialType;

			% record response
			if (ismember(trialType, leftResponses))
			  anResponse(t) = 1;
			elseif (ismember(trialType, rightResponses))
			  anResponse(t) = 2;
			else
			  anResponse(t) = 0; % no response
			end

			% record stimulus class (L/R)
			if (ismember(trialType, leftTrial))
			  corrResponse(t) = 1;
			else 
			  corrResponse(t) =2;
			end
		end
		dTS = trialTypeTS;
	  dTSA{length(dTSA)+1} = dTS;

    %% correct response(L/R)
  	correctResponseTS = baseTS.copy();
		correctResponseTS.id = 60200;
		correctResponseTS.idStr = 'Correct Response';
		correctResponseTS.value(:) = 0;
		for t=1:length(obj.trial)
      bti = find(baseTrialIndices == obj.trial{t}.id);
      if (length(bti) > 0); correctResponseTS.value(bti) = corrResponse(t); end
		end
		dTS = correctResponseTS;
	  dTSA{length(dTSA)+1} = dTS;

    %% animal response
  	animalResponseTS = baseTS.copy();
		animalResponseTS.id = 60300;
		animalResponseTS.idStr = 'Animal Response';
		animalResponseTS.value(:) = 0;
		for t=1:length(obj.trial)
      bti = find(baseTrialIndices == obj.trial{t}.id);
			if (length(bti) > 0); animalResponseTS.value(bti) = anResponse(t); end
		end
		dTS = animalResponseTS;
	  dTSA{length(dTSA)+1} = dTS;

		%% no response
  	noResponseTS = baseTS.copy();
		noResponseTS.id = 60400;
		noResponseTS.idStr = 'No Response';
		noResponseTS.value(:) = 0;
		for t=1:length(obj.trial)
      bti = find(baseTrialIndices == obj.trial{t}.id);
			if (anResponse(t) == 0 && length(bti) > 0 )
  			noResponseTS.value(bti) = 1;
			end
		end
		dTS = noResponseTS;
	  dTSA{length(dTSA)+1} = dTS;

		%% left response
  	leftResponseTS = baseTS.copy();
		leftResponseTS.id = 60500;
		leftResponseTS.idStr = 'Left Response';
		leftResponseTS.value(:) = 0;
		for t=1:length(obj.trial)
      bti = find(baseTrialIndices == obj.trial{t}.id);
			if (anResponse(t) == 1 && length(bti) > 0 )
  			leftResponseTS.value(bti) = 1;
			end
		end
		dTS = leftResponseTS;
	  dTSA{length(dTSA)+1} = dTS;

		%% right response
  	rightResponseTS = baseTS.copy();
		rightResponseTS.id = 60600;
		rightResponseTS.idStr = 'Right Response';
		rightResponseTS.value(:) = 0;
		for t=1:length(obj.trial)
      bti = find(baseTrialIndices == obj.trial{t}.id);
			if (anResponse(t) == 2 && length(bti) > 0  )
  			rightResponseTS.value(bti) = 1;
			end
		end
		dTS = rightResponseTS;
	  dTSA{length(dTSA)+1} = dTS;

    %% - for all 6000X classes, generate different time epoch restrictions
    for i=stimPosIdx:length(dTSA)
		  dTS = dTSA{i};
			idStr = dTS.idStr;
			id = dTS.id;
    
		  % pretrial
			dTS = dTSA{i}.copy();
			dTS.value = dTS.value .*  preStimEpochTS.value;
			dTS.id = id+1;
			dTS.idStr = [idStr ' Pre Stimulus'];
			dTSA{length(dTSA)+1} = dTS;

      % bar-in-reach only
			dTS = dTSA{i}.copy();
			dTS.value = dTS.value .* barInReachEpochTS.value;
			dTS.id = id+2;
			dTS.idStr = [idStr ' Bar In Reach'];
			dTSA{length(dTSA)+1} = dTS;
        
		  % delay
			dTS = dTSA{i}.copy();
			dTS.value = dTS.value .*  delayEpochTS.value;
			dTS.id = id+3;
			dTS.idStr = [idStr ' Delay'];
			dTSA{length(dTSA)+1} = dTS;


		  % reward/end
			dTS = dTSA{i}.copy();
			dTS.value = dTS.value .*  rewardEpochTS.value;
			dTS.id = id+4;
			dTS.idStr = [idStr ' Reward'];
			dTSA{length(dTSA)+1} = dTS;
		end
	end


	%% --- punishment 70000
	
	allPunTimes = [];
	% punishment sample, preans
	if ( length(obj.behavESA.getEventSeriesByIdStr('Punishment Sample',1)) > 0)
		allPunTimes = [allPunTimes obj.behavESA.getEventSeriesByIdStr('Punishment Sample',1).eventTimes];
	end
	if ( length(obj.behavESA.getEventSeriesByIdStr('Punishment Preans',1)) > 0)
		allPunTimes = [allPunTimes obj.behavESA.getEventSeriesByIdStr('Punishment Preans',1).eventTimes];
	end
	allPunES = session.eventSeries();
	allPunES.eventTimes = sort(unique(allPunTimes));
	allPunES.updateEventSeriesFromTrialTimes(obj.behavESA.trialTimes);
	allPunES.timeUnit = obj.behavESA.getEventSeriesByIdStr('Punishment Preans',1).timeUnit;
	allPunES.type = 1;

	dTS = allPunES.deriveTimeSeries(baseTime,baseTimeUnit, [0 1]);
	dTS.id = 70000;
	dTS.idStr = 'Punishment';
	dTSA{length(dTSA)+1} = dTS;

	dES = allPunES.copy();
	dES.id = 70000;
	dES.idStr = 'Punishment';
	dESA{length(dESA)+1} = dES;


  %% --- build the TSA, ESA

	disp('generateDerivedDataStructures::generating TSA & ESA objects.');

  % TSA
  obj.derivedDataTSA = session.timeSeriesArray(dTSA,baseTrialIndices);

	% ESA
	obj.derivedDataESA = session.eventSeriesArray(dESA, obj.behavESA.trialTimes);

	% valid trials
	obj.validDerivedTrialIds = unique(obj.derivedDataTSA.trialIndices);
	





