%
% SP Jan 2011
%
% Static method that usually works with timeSeries but can be used generically 
%  for pulling sets of points, given a time vector, around a set of events.
%
% USAGE:
%
%   [idxMat timeMat timeVec ieIdxVec] = 
%      getIndexWindowsAroundEventsS(time, timeUnit, timeWindow, timeWindowUnit, 
%    		  includeEventTimes, ieTimeUnit, excludeTimeWindow, excludeEventTimes, 
%         eeTimeUnit, allowOverlap) 
%
%     idxMat: indices matching criteria ; each row has a size specified by timeWindow.
%       Note that data falling OUTSIDE of timeWindow will have idx=nan.
%     timeMat: the corresponding times, in case you need em.  Data outside of 
%       timeWindow will have nan's.
%     timeVec: reference time vector for each row of timeMat ; 0 of timeVec is 
%       event time.  This may differ from what you expect because if nan's are
%       found in ALL trials, they are trimmed.  Time unit will be same
%       timeWindowUnit.
%     ieIdxVec: which event time from INCLUDED events did you use? i.e.,
%       tells you that row r in idxMat is for includeEventTimes(r)
%
%     time - timing vector
%     timeWindow - 0 is time of event ; so [-5 5] would show +/- 5 time units
%     timeWindowUnit - in s ; 0 is time of event ; so [-5 5] would show +/- 5 secionds 
%     includedEventTimes - for each includedEventTime, it will populate idxMat with
%       indices for which time >= includedEventTimes-timeWindow(1) and < iet+tw(2)
%     ieTimeUnit: time unit for inclusion
%     excludedEventTimes - these events, if they overlap with included events, force
%       the exclusion of that particular event [leave BLANK to not apply]
%     excludedTimeWindow - as with timeWindow (uses same units), but any time and 
%       INCLUDED event is within excludedTimeWindow of an excluded event, that 
%       included event is removed
%     eeTimeUnit: excluded event time unit 
%     allowOverlap - if 0, events are taken as they come, and all subsequent 
%                    events are not given their own row in idxMat, timeMat. 
%                    This ensures no timepoint duplication.  If 1, all events
%                    are included, and time duplication is permitted.
%
function [idxMat timeMat timeVec ieIdxVec] = getIndexWindowsAroundEventsS(time, timeUnit, timeWindow, timeWindowUnit, ...
		  includeEventTimes, ieTimeUnit, excludeTimeWindow, excludeEventTimes, eeTimeUnit, allowOverlap) 
  idxMat = [];
  timeMat = [];
	timeVec = [];
	ieIdxVec = [];
   
  % --- input process
	if (nargin < 6)  
	  disp('getIndexWindowsAroundEventsS::minimal argumenst are time, timeWindow, includedEventTimes, and units for all.');
		return ; 
	end
	if (nargin < 7) % no exclusion okay
	  excludeTimeWindow = [];
	end
	if (nargin < 8 || length(excludeEventTimes) == 0)
	  excludeEventTimes = [];
	end
	if (nargin == 8)
	  eeTimeUnit = ieTimeUnit;
	end
	if (nargin >= 9 && length(eeTimeUnit) == 0) % no eeTimeUnit
	  eeTimeUnit = ieTimeUnit;
	end
	if (nargin < 10 || length(allowOverlap) == 0) % allow overlap -- NO
	  allowOverlap = 0;
	end

	% --- time handling and other setup (convert all to timeUnit)
  includeEventTimes = session.timeSeries.convertTime(includeEventTimes, ieTimeUnit, timeUnit);
  oIncludeEventTimes = includeEventTimes;
  timeWindow = session.timeSeries.convertTime(timeWindow, timeWindowUnit, timeUnit);
	if (length(excludeEventTimes) > 0)
		excludeEventTimes = session.timeSeries.convertTime(excludeEventTimes, eeTimeUnit, timeUnit);
		excludeTimeWindow = session.timeSeries.convertTime(excludeTimeWindow, timeWindowUnit, timeUnit);
	end

  % dt based on mode of diff
	dt = mode(diff(time));

  % get # of data points after (pos) and b4 (neg)
	ntpP = round(timeWindow(2)/dt); % points after (positive)
	ntpN = round(timeWindow(1)/dt); % points prior (negative)  
	ntp = -1*ntpN + ntpP + 1; % total # time points includes event itself

  % --- see how many lines you will have
	if (allowOverlap)  
	  nEntries = length(includeEventTimes);
	else % trickier 
		% setup
		evVal = 0*includeEventTimes;
		netWindowSize = timeWindow(2)-timeWindow(1)+dt;
		lastEvTime = min(includeEventTimes)-2*netWindowSize; % seed value is nonevent

		% loop over events
		for e=1:length(includeEventTimes)
			% time since last event
			dLastEv = includeEventTimes(e) - lastEvTime;

			% take only if it exceeds window size -- this is quite conservative
			if (dLastEv > netWindowSize)
				evVal(e) = 1;
				lastEvTime = includeEventTimes(e);
			end
		end

		% keep valids only
		includeEventTimes = includeEventTimes(find(evVal));
    nEntries = length(includeEventTimes);
	end

	% --- apply exclusion
	if (length(excludeEventTimes) > 0)
		excludeVec = excludeTimeWindow(1):dt:excludeTimeWindow(2);
		Lx = length(excludeVec);
	  % build a vector of exclude times ...
		fullExcludeVec = nan*ones(1,Lx*length(excludeEventTimes));
	  for x=1:length(excludeEventTimes)
		  i1 = (x-1)*Lx+1;
			i2 = i1+Lx-1;
			if (~isnan(excludeEventTimes(x)))
				fullExcludeVec(i1:i2) = excludeEventTimes(x)+excludeVec;
			end
		end
		fullExcludeVec = fullExcludeVec(find(~isnan(fullExcludeVec)));
		fullExcludeVec = sort(unique(fullExcludeVec));

		% and kill intersections that are within dt/2
		evVal = 0*includeEventTimes + 1;
		for e=1:length(includeEventTimes)
		  [md irr] = min(abs(includeEventTimes(e)-fullExcludeVec));
			if (md <= (dt/2)) ; evVal(e) = 0; end
		end

		% keep valids only
		includeEventTimes = includeEventTimes(find(evVal));
    nEntries = length(includeEventTimes);
	end

	% --- build idxMat, timeMat
	idxMat = nan*zeros(nEntries, ntp);
	timeMat = nan*zeros(nEntries, ntp);
	L = length(time);
	cIdx = ntp - ntpP;
	for e=1:length(includeEventTimes)
	  [irr ie] = min(abs(time- includeEventTimes(e)));
   	i1 = min(L,max(1,ie+ntpN));
		nOffs = ie-i1;
		i2 = min(L,max(1,ie+ntpP));
		pOffs = i2-ie;
    if (cIdx-nOffs > 0 & cIdx+pOffs > 0) 
		  idxMat(e,cIdx-nOffs:cIdx+pOffs) = i1:i2;
    end
	end
	valIdx = find(~isnan(idxMat));
	if (length(valIdx) > 0)
		timeMat(valIdx) = time(idxMat(valIdx));
	end

	% --- now we can get a TEMPORARY ieIdxVec for use below
	ieIdxVec = find(ismember(includeEventTimes,oIncludeEventTimes));

	% --- reverify timeWindow compliance ...
	idxCen = -1*ntpN + 1;
	% loop over rows and nan any values that fall outside time bounds
  for r=1:size(timeMat,1)
	  tCen = includeEventTimes(ieIdxVec(r));
		tBounds = tCen + timeWindow;
		badIdx = find(timeMat(r,:) < tBounds(1) | timeMat(r,:) > tBounds(2) | isnan(timeMat(r,:)));
		timeMat(r,badIdx) = nan;
		idxMat(r,badIdx) = nan;
	end

  % --- timeVec
	timeVec = ntpN*dt:dt:ntpP*dt;
  % convert to timeVec to timeWindowUnit
  timeVec = session.timeSeries.convertTime(timeVec, timeUnit, timeWindowUnit);
  

  % --- trim columns & rows that are ALL nan 
  goodCols = ones(1,size(timeMat,2));
	for c=1:size(timeMat,2)
		if (isempty(find(~isnan(timeMat(:,c))))) ; goodCols(c) = 0 ; end
  end
  timeMat= timeMat(:,find(goodCols));
	idxMat= idxMat(:,find(goodCols));
	timeVec = timeVec(find(goodCols));

  goodRows = ones(1,size(timeMat,1));
	for r=1:size(timeMat,1)
		if (isempty(find(~isnan(timeMat(r,:))))) ; goodRows(r) = 0 ; end
  end
  timeMat= timeMat(find(goodRows),:);
	idxMat= idxMat(find(goodRows),:);
	ieIdxVec = ieIdxVec(find(goodRows));

	% and finally put ieIdxVec in terms of ORIGINAL indexing
	ieIdxVec = find(ismember(oIncludeEventTimes, includeEventTimes(ieIdxVec)));



