%
% SP Nov 2011
%
% This will populate eventPropertiesHash for whiskerBarContactClassifiedESA 
%  eventSeries with various properties of the contact events.
%
% USAGE:
% 
%   s.generateContactPropertiesHashes();
%
% PARAMS:
%
function generateContactPropertiesHashes(obj)

	% nondirectional contacts
	for e=1:length(obj.whiskerBarContactESA)
    disp(['generateContactPropertiesHashes::Processing ' ...
          obj.whiskerBarContactESA.esa{e}.idStr]);
	  generateSingleHash(obj, obj.whiskerBarContactESA.esa{e}, e);
	end

  % directional contacts
	for e=1:length(obj.whiskerBarContactClassifiedESA)
	  w = ceil(e/2);
    disp(['generateContactPropertiesHashes::Processing ' ...
          obj.whiskerBarContactClassifiedESA.esa{e}.idStr]);
	  generateSingleHash(obj, obj.whiskerBarContactClassifiedESA.esa{e}, w);
	end

% 
% computes properties for a SINGLE eventSeries
%
function generateSingleHash (obj, es, w)
  whBoutLengthMs = 500;

	wAngTS = obj.whiskerAngleTSA.getTimeSeriesById(w);
	wKapTS = obj.whiskerCurvatureChangeTSA.getTimeSeriesById(w);
	whAng = wAngTS.value; % somehow this improves speed
	whKap = wKapTS.value; % somehow this improves speed
	sTimes = es.getStartTimes();

  % sanity check ...
	if (~isobject(es.eventPropertiesHash))
	  es.eventPropertiesHash = hash();
	end

  % compile index matrix within whiskerAngle of touch events -- note that allowOverlap
	%  is critical because if you have 1-frame touches, those start and end at the
	%  same time and so startTime = endTime and so they overlap.
  [idxMat irr1 irr2 ieIdxVec]   = session.timeSeries.getIndexWindowsAroundEventsS( ...
	  obj.whiskerAngleTSA.time, obj.whiskerAngleTSA.timeUnit, ...
		[0 0], 1, es.eventTimes, es.timeUnit,[],[],[],1);
	sIdxMat = idxMat(1:2:end-1); % start indices
	eIdxMat = idxMat(2:2:end); % start indices

	% --- theta-at-touch onset
	thetaAtTouchOnset = nan*zeros(1,length(idxMat));
	thetaAtTouchOnset(1:2:end-1) = whAng(sIdxMat);
	thetaAtTouchOnset(2:2:end) = whAng(sIdxMat);

	es.eventPropertiesHash.setOrAdd('thetaAtTouchOnset', thetaAtTouchOnset);

	% --- mean theta during touch -- a bit trickier
	thetaMeanOverTouch = nan*zeros(1,length(idxMat));
	for e=2:2:2*length(sIdxMat)  
    thetaMeanOverTouch(e) = nanmean(whAng(sIdxMat(e/2):eIdxMat(e/2)));
    thetaMeanOverTouch(e-1) = thetaMeanOverTouch(e);
	end
	es.eventPropertiesHash.setOrAdd('thetaMeanOverTouch', thetaMeanOverTouch);

	% --- maxabs kappa during touch (can make summaxabs from this)
	kappaMaxAbsOverTouch = nan*zeros(1,length(idxMat));
	for e=2:2:2*length(sIdxMat)  
    dVec = whKap(sIdxMat(e/2):eIdxMat(e/2));
    [irr midx] =max(abs(dVec));
    kappaMaxAbsOverTouch(e) = dVec(midx);
    kappaMaxAbsOverTouch(e-1) = kappaMaxAbsOverTouch(e);
	end
	es.eventPropertiesHash.setOrAdd('kappaMaxAbsOverTouch', kappaMaxAbsOverTouch);

	% --- touch # within trial
	touchNumberWithinTrial = nan*zeros(1,length(es.eventTimes));
	sTrials = es.getStartTrials();
	for e=2:2:2*length(sTimes)
	  tt = find(sTrials == es.eventTrials(e));
    touchNumberWithinTrial(e) = 1 + length(find(tt < e/2));
    touchNumberWithinTrial(e-1) = touchNumberWithinTrial(e);
	end
	es.eventPropertiesHash.setOrAdd('touchNumberWithinTrial', touchNumberWithinTrial);

	% --- touch # within 'bout' (500 ms intertouch interval max)
  % separate by bout
	eTimes = es.getEndTimes();
	dt = sTimes(2:end) - eTimes(1:end-1);
	dt = session.timeSeries.convertTime(dt, es.timeUnit, session.timeSeries.millisecond);
	boutChangeIdx = find(dt > whBoutLengthMs);
	boutChangeIdx = (boutChangeIdx + 1)*2; % now it is in line with es.eventTimes

	% assign bout # for each EVENT ...
  boutNumber = ones(1,length(es.eventTimes));
	for b=1:length(boutChangeIdx)
	  boutNumber(boutChangeIdx(b)-1:end) = b+1; 	  
	end

	% and now compute touch # within bout
  numberWithinBout = ones(1,length(es.eventTimes));
	for e=2:2:length(es.eventTimes)
	  bt = find(boutNumber == boutNumber(e));
		numberWithinBout(e) =  length(find(bt <= e))/2;
		numberWithinBout(e-1) =  length(find(bt <= e))/2;
	end

	es.eventPropertiesHash.setOrAdd('touchBoutNumber', boutNumber);
	es.eventPropertiesHash.setOrAdd('touchNumberWithinBout', numberWithinBout);

	% --- whTSACorrespondingIndex
	es.eventPropertiesHash.setOrAdd('whTSACorrespondingIndex', idxMat');

	% --- caTSACorrespondingIndex -- fudge factor of dt
	if (isobject(obj.caTSA) & ~isstruct(obj.caTSAArray)) % don't do if we have a caTSAArray
		dtCaTSA = session.timeSeries.convertTime(mode(diff(obj.caTSA.time)), obj.caTSA.timeUnit, session.timeSeries.millisecond);
		[idxMat irr1 irr2 ieIdxVec]  = session.timeSeries.getIndexWindowsAroundEventsS( ...
			obj.caTSA.time, obj.caTSA.timeUnit, ...
			[-1*dtCaTSA dtCaTSA], 1, es.eventTimes, es.timeUnit, [],[],[],1);
		idxVec = nan*zeros(1,length(es.eventTimes));
		if (sum(size(idxMat)) > 0)  ; idxVec(ieIdxVec) = idxMat(:,2); end
		es.eventPropertiesHash.setOrAdd('caTSACorrespondingIndex', idxVec);
	end

	% --- derTSACorrespondingIndex
	if (isobject(obj.derivedDataTSA))
		dtDDTSA = session.timeSeries.convertTime(mode(diff(obj.derivedDataTSA.time)), obj.derivedDataTSA.timeUnit, session.timeSeries.millisecond);
		[idxMat irr1 irr2 ieIdxVec]  = session.timeSeries.getIndexWindowsAroundEventsS( ...
			obj.derivedDataTSA.time, obj.derivedDataTSA.timeUnit, ...
			dtDDTSA*[-1 1], 1, es.eventTimes, es.timeUnit, [],[],[],1);
		idxVec = nan*zeros(1,length(es.eventTimes));
		if (sum(size(idxMat)) > 0)  ; idxVec(ieIdxVec) = idxMat(:,2); end
		es.eventPropertiesHash.setOrAdd('derTSACorrespondingIndex', idxVec);
  end
