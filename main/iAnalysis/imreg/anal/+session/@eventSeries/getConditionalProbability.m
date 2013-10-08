%
% SP FEb 2011
%
% Gives the conditional probability.  Given two event series, a and b, basically
%  gives you p(a|b) = p(a & b)/p(b) = length(intersect(a,b))/length(b).
%  This is done based on event times.  You can expand individual event sizes using
%  the time windows.  So if you give a time window of [-1 0] for aTimeWindow, it
%  will count any point where b occurs upto a second before a occurs.  
%
% USAGE:
%
%		condProb = getConditionalProbability(baseTimeSeries, aes, aTimeWindow, xaes, 
%     xaTimeWindow, bes, bTimeWindow, xbes, xbTimeWindow, timeWindowUnit, aAllowOverlap,
%     bAllowOverlap)
%
%     condProb: the conditional probability ; 0 < condProp < 1
%
%     baseTimeSeries: time series on which events are "based" -- note that 
%       baseTimeSeries.timeUnit is assumed to be the timeUnit of aes, xaes,
%       bes, xbes.
%     aes: the "a" probability eventSeries; either an object or a *vector* of 
%       event times.  For aes (but NOT bes), you can pass a CELL ARRAY of eventSeries
%       objects, in which case condProb is a vector of the same size as this array
%       giving conditional probabilities for each aes relative bes.
%     aTimeWindow: time window placed around the events; default is [0 0]
%     xaes: event exclusion applied to aes prior to performing conditonal computation.
%       Can be a cell-array of eventSeries, in which case all are used as
%       excluders.  Can also be a *vector* of event times.
%     xaTimeWindow: time window for exclusion ; default is [0 0]
%     bes, bTimeWindow, xbes, xbTimeWindow: same as above but for the b variable
%     timeWindowUnit: unit in which you gave *all* your timewindows ;default 
%       is seconds
%     aAllowOverlap, bAllowOverlap: default 0 for both ; allow overlaping, based on 
%       window size, events to count?
%     
function condProb = getConditionalProbability(baseTimeSeries, aes, aTimeWindow, xaes, ...
    xaTimeWindow, bes, bTimeWindow, xbes, xbTimeWindow, timeWindowUnit, aAllowOverlap, bAllowOverlap)

    condProb = -1;

    % --- argument parsing
		if (nargin < 6 || length(aes) == 0) 
		  disp('getConditionalProbability::Must at least provide a and b event series/time vectors and baseTimeSeries.');
			return;
		end

    % - a

    % pull event times
		if (isobject(aes))
		  aEventTimesArray{1} = aes.eventTimes;
		elseif (iscell(aes))
		  if (isobject(aes{1}))
				for a=1:length(aes)
					aEventTimesArray{a} = aes{a}.eventTimes;
				end
			else % cell array of time point VECTORS
				aEventTimesArray = aes;
			end
		else
		  aEventTimesArray{1} = aes;
		end

		% time window
		if (length(aTimeWindow) == 0)
		  aTimeWindow = [0 0 ];
		end

    % pull excluded event times
		if (isobject(xaes))
		  xaEventTimes = xaes.eventTimes;
		elseif (iscell(xaes))
		  if (isobject(xaes{1}))
  		  xaEventTimes = [];
	  	  for x=1:length(xaes)
		      xaEventTimes = [xaEventTimes xaes{x}.eventTimes];
			  end
			else % cell array of time point VECTORS
  		  xaEventTimes = [];
	  	  for x=1:length(xaes)
		      xaEventTimes = [xaEventTimes xaes{x}];
			  end
			end
		else % just a vector of #s
		  xaEventTimes = xaes;
		end

		% time window
		if (length(xaTimeWindow) == 0)
		  xaTimeWindow = [0 0 ];
		end

    % - b

    % pull event times
		if (isobject(bes))
		  bEventTimes = bes.eventTimes;
		else
		  bEventTimes = bes;
		end

		% time window
		if (nargin < 7 || length(bTimeWindow) == 0)
		  bTimeWindow = [0 0];
		end

    % pull excluded event times
		if (nargin < 8 || length(xbes) == 0)
		  xbEventTimes = [];
		else
			if (isobject(xbes))
				xbEventTimes = xbes.eventTimes;
			elseif (iscell(xbes))
				if (isobject(xbes{1}))
					xbEventTimes = [];
					for x=1:length(xbes)
						xbEventTimes = [xbEventTimes xbes{x}.eventTimes];
					end
				else % cell array of time point VECTORS
					xbEventTimes = [];
					for x=1:length(xbes)
						xbEventTimes = [xbEventTimes xbes{x}];
					end
				end
			else % just a vector of #s
				xbEventTimes = xbes;
			end
		end

		% time window
		if (nargin < 9 || length(xbTimeWindow) == 0)
		  xbTimeWindow = [0 0];
		end

		% time unit
		if (nargin < 10|| length(timeWindowUnit) == 0)
		  timeWindowUnit = 2; % seconds
		end

		% allow overlap
		if (nargin < 11 || length(aAllowOverlap) == 0)
		  aAllowOverlap = 0;
		end
		if (nargin < 12 || length(bAllowOverlap) == 0)
		  bAllowOverlap = 0;
		end

		% --- the dity

		% time unit quickie
		btstu = baseTimeSeries.timeUnit;
		twtu = timeWindowUnit;

    % in case the a/bTimeWindow spacing is BELOW dt , make it +/- baseTimeSeries.time dt/2
		%  otherwise, restriction in getIndexWindowAroundEventsS will return NO events
    baseDt = session.timeSeries.convertTime(mode(diff(baseTimeSeries.time)), btstu, twtu);
    if (abs(diff(bTimeWindow)) < baseDt)
      btwPadding = (baseDt - abs(diff(bTimeWindow)))/2;
      bTimeWindow = [bTimeWindow(1)-btwPadding bTimeWindow(2)+btwPadding];
    end
    if (abs(diff(aTimeWindow)) < baseDt)
      atwPadding = (baseDt - abs(diff(aTimeWindow)))/2;
      aTimeWindow = [aTimeWindow(1)-atwPadding aTimeWindow(2)+atwPadding];
    end
      
    
		% b event indices
		[bIdx irr ir2] = session.timeSeries.getIndexWindowsAroundEventsS(baseTimeSeries.time, baseTimeSeries.timeUnit, ...
			bTimeWindow, twtu, bEventTimes, btstu,xbTimeWindow,xbEventTimes,btstu,bAllowOverlap);
    labelMat = reshape(repmat(1:size(bIdx,1), 1, size(bIdx,2))',[],1);
		bIdx = reshape(bIdx,[],1);
		[bIdx idx]= unique(bIdx);
    keepIdx = find(~isnan(bIdx));
    bLabels = labelMat(idx(keepIdx));
		bIdx = bIdx(keepIdx);

		nB = length(unique(bLabels)); % this may be distinct from # of events due to overlap issues

    % loop over aEventTimes, which is a CELL ARRAY at this point
		for a=1:length(aEventTimesArray)
		  aEventTimes = aEventTimesArray{a};

      % a event indices
			[aIdx irr ir2] = session.timeSeries.getIndexWindowsAroundEventsS(baseTimeSeries.time, baseTimeSeries.timeUnit, ...
				aTimeWindow, twtu, aEventTimes, btstu,xaTimeWindow,xaEventTimes,btstu,aAllowOverlap);
			labelMat = reshape(repmat(1:size(aIdx,1), 1, size(aIdx,2))',[],1);
			aIdx = reshape(aIdx,[],1);
			aIdx = unique(aIdx);
			aIdx = aIdx(find(~isnan(aIdx)));

			% we have 'expanded' vectors -- that is, each event is multiple points.  fortunately, we
			%  can use the label vectors aLabels and bLabels to determine which UNIQUE b events have
			%  overlap with a and thereby get probability of intersection.  Note that here intersection
			%  is in terms of which fraction of b events are overlapping with an a event
			[irr iA iB] = intersect(aIdx,bIdx);
      PaIb = length(unique(bLabels(iB)));

			% how reliably does this cell encode the sensory variable (FOLLOW it)?
			condProb(a) = PaIb/nB;
		end
