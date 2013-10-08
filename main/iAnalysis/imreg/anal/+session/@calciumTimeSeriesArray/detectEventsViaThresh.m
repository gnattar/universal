%
% This function will perform threshold-based event detection on a data matrix,
%  returning, for each row (which is a single timeseries), the time of the peak,
%  event start and end, and amplitude @ peak.  
%
% USAGE:
%
% [peakTimes peakValues startTimes endTimes] = 
%   detectEventsViaThresh(dataMatrix, timeVec, eventThresh, startThresh, endThresh, 
%                         minEvDur)
% 
% PARAMS:
% 
%  dataMatrix: the data; each row (x,:) is treated as an individual timeseries
%  timeVec: time vector of size(dataMatrix,2) with times for each point
%
%  [the next 3 are either 1 number or vector with one value per dataMatrix row]
%
%  eventThresh: threshold for event ; all points above this are part of the
%               event and at least some points must be above this to count
%               as event.  
%  startThresh: event start is at point AFTER first point below startThresh
%               preceding the time of the peak
%  endThresh: event end is at point BEFORE first point below endThresh following
%             peak
%
%  minEvDur: how many points long must an event be? (endIdx-startIdx -- NOT above
%            eventHresh; of course, if you want to do this, set end and start 
%            thresh to eventThresh).
%  
% RETURNS:
%  
%  All returned items are cells, with blabla{x} containing an array of values for
%   timeseries in row x of dataMatrix
%  peakTimes: times of the peaks of events
%  peakValues: actual value at time of peak
%  startTimes: when was event starting?
%  endTimes: when was event ending?
%
function [peakTimes peakValues startTimes endTimes] = detectEventsViaThresh(dataMatrix, ...
         timeVec, eventThresh, startThresh, endThresh, minEvDur)

	peakTimes = {};
	peakValues= {};
	startTimes = {};
	endTimes = {};

	% -- prelims
	if (length(eventThresh) == 1)
	  eventThresh = eventThresh*ones(size(dataMatrix,1));
	end
	if (length(startThresh) == 1)
	  startThresh = startThresh*ones(size(dataMatrix,1));
	end
	if (length(endThresh) == 1)
	  endThresh = endThresh*ones(size(dataMatrix,1));
	end

	% -- loop row-by-row and do detection
	for i=1:size(dataMatrix,1)
	  valids = find(dataMatrix(i,:) > eventThresh(i));
%dataMatrix(i,:)
%eventThresh(i)
%pause

		% loop over positive events
		lastIdx = 0;
		evIdx = 0;

		dur = []; % stores duration BUT ONLY ABOVE eventThresh
		startIdx = []; % start index of region ABOVE eventThresh

		while(length(valids) > 0)
			curIdx = valids(1); % always take first
			if (lastIdx > 0) % previous event
				if (curIdx-1 == lastIdx) % part of same event? increment amplitude and duration
					dur(evIdx) = dur(evIdx)+1;
				else % no - new event
					evIdx = evIdx+1;
					dur(evIdx) = 1;
					startIdx(evIdx) = curIdx;
				end
			else % new event
				evIdx = evIdx+1;
				dur(evIdx) = 1;
				startIdx(evIdx) = curIdx;
			end

			% trim 1st valids
			lastIdx = curIdx;
			valids = valids(2:length(valids));
		end

		% Loop through found events
		pTimes = [];
		pVals = [];
		sTimes = [];
		eTimes = [];
    for e=1:length(startIdx)
      % process good ones		   
		  evIndices = startIdx(e):startIdx(e)+dur(e)-1;

		  % peak
			[pkval pkidx] = max(dataMatrix(i,evIndices));

			% start time
			sidx = find(dataMatrix(i,1:evIndices(1)));
			sidx = max(find(dataMatrix(i,1:evIndices(1)) < startThresh(i)));
			if (length(sidx) == 0) ; sidx = evIndices(1) ; end
			if (sidx == 1) ; sidx = 2; end

			% end time
			eidx = min(find(dataMatrix(i,evIndices(end):size(dataMatrix,2)) < endThresh(i))) + evIndices(end) - 1;
			if (length(eidx) == 0) ; eidx = evIndices(end) ; end
			if (eidx == length(timeVec)) ; eidx = length(timeVec)-1; end

      % long enuff event?
			if (eidx-sidx > minEvDur)
				pTimes = [pTimes timeVec(evIndices(pkidx))];
				pVals = [pVals pkval];
				sTimes = [sTimes timeVec(sidx-1)];
				eTimes = [eTimes timeVec(eidx+1)];
			end
		end

		% ASsign
		peakTimes{i} = pTimes;
		peakValues{i} = pVals;
		startTimes{i} = sTimes;
		endTimes{i} = eTimes;
	end
  



