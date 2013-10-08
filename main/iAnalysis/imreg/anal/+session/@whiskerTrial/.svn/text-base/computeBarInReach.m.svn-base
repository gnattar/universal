%
% SP Dec 2010
%
% This uses bar template or voltage data to determine when hte bar is in reach.
%
% USAGE:
%
%  wt.computeBarInReach()
%
function obj = computeBarInReach(obj)

	% --- determine barInReach
  % default is OUT of reach
	obj.barInReach = 0*obj.frameTimes;

	% pull valuevec
	if (obj.barInReachParameterUsed == 3)
	  valueVec = obj.barTemplateCorrelation;
	elseif (obj.barInReachParameterUsed == 4) % pole vm
	  valueVec = obj.barVoltageTrace;
	else
	  valueVec = obj.barCenter(:,obj.barInReachParameterUsed);
	end

  % get top two peaks in histogram -- these are your in/out of range poitns
	[count values] = hist(valueVec,10);
	dbin = abs(values(2)-values(1));

  % quick check that this was not messed up
	rangeMinMax = range(valueVec);
	[sortedCount idx] = sort(count, 'descend');
	dPeaks = values(idx(1))-values(idx(2));
  if (abs(dPeaks)/rangeMinMax < 0.25 & obj.barInReachParameterUsed ~= 3) % should span at LEAST quarter minmax!
	  disp('trackBar::dbin is less than 1/4 of range.');
	  maxV = max(valueVec);
	  minV = min(valueVec);
		if (length(find(valueVec > maxV-(1.5*dbin) & valueVec < maxV +(1.5*dbin))) > ...
		    length(find(valueVec > minV-(1.5*dbin) & valueVec < minV +(1.5*dbin)))) ...
			secV = minV;
		  domV = maxV;
		else
		  domV = minV;
			secV = maxV;
		end
		dominantPos = find(valueVec > domV-dbin & valueVec < domV+dbin);
		secondaryPos = find(valueVec > secV-dbin & valueVec < secV+dbin);
	elseif (abs(dPeaks)/rangeMinMax < 0.25 & obj.barInReachParameterUsed == 3) % special case with correlation
	  disp('trackBar::dbin is less than 1/4 of range.  Using correlation so assuming max correlation when IN REACH.');
	  % we KNOW here that MAX = in reach
	  maxV = max(values(idx(1:5))); % max value among top 5 on histogram
		secondaryPos = find(valueVec > maxV-2*dbin);
		dominantPos = setdiff(1:obj.numFrames,secondaryPos);
		if (obj.barDominantPosition == 1) % reverse in this case
		  tmp = dominantPos;
			dominantPos = secondaryPos;
			secondaryPos = tmp;
		end
	else % ok -- assign off histo
  	dominantPos = find(valueVec > values(idx(1))-dbin & valueVec < values(idx(1))+dbin);
		secondaryPos = find(valueVec > values(idx(2))-dbin & valueVec < values(idx(2))+dbin);
	end

  obj.barInReach(dominantPos) = obj.barDominantPosition;
  obj.barInReach(secondaryPos) = ~obj.barDominantPosition;

	% from first to last bar in reach is in reach ...
	if (obj.barDominantPosition) % dominant is IN REACH
		firstOutReach = min(find(~obj.barInReach));
		lastOutReach = max(find(~obj.barInReach));
		obj.barInReach(firstOutReach:lastOutReach) = 0;
	else % dominant OUT OF REACH -- default!!
		firstInReach = min(find(obj.barInReach));
		lastInReach = max(find(obj.barInReach));
		obj.barInReach(firstInReach:lastInReach) = 1;
	end

	% --- clear dependent arrays
	obj.distanceToBarCenter = [];
	obj.whiskerContacts = [];
	obj.whiskerBarContactESA = [];



