%
% SP Feb 2011
%
% For a given series of events, it will find 'bursts' -- if events are spaced
%  less than burstDt apart, they are considered members of the same 'burst'.
%
%  So far, this is useful when you want the first (or last or nth) 'spike' 
%   in the context of a spike train derived from Ca.  It is also useful for
%   deriving a particular contact in a set of whisker contacts.
%
% USAGE:
%
%  [burstTimes burstTrials] = getBurstTimes(obj, burstDt, options)
%
%    burstTimes: the start times of individual bursts
%    burstTrials: trials of burst starts
%
%    burstDt: inter-burst interval ; events with intervals greater than
%             this are considered to be part of separate bursts
%
%    options: structure with optional parameters:
%      eventNumber: default 1 (if not passed), meaning FIRST event of 
%             burst.  Inf will return last event of burst.  Obviously,
%             if there are not enough events in a burst, that burst is
%             excluded.  Inf will use 1st if only 1 event exists.
%      useStartOrEnd: for type 2 event series, should starts (1), ends (2),
%             or both (0 -- DEFAULT) be used when computing bursts?  Note that
%             if both are used, bursts are treated as dense.  That is, if 
%             burstDt is, say, 1 s, and an event A spans [0,0.5 s], event 2
%             spans [1,3] and event 3 spans [3.5, 4], they are part of a burst.
%      minBurstLength: how many events there must be, at least, to be burst?
%
function [burstTimes burstTrials] = getBurstTimes(obj, burstDt, options)
  burstTimes = [];
  burstTrials = [];

  % --- sanity / input checks
	if (nargin < 2) 
	  disp('getBurstTimes::must give burstDt');
	  return;
	end

	if (length(obj.eventTimes) == 0) ; return ; end % don't waste my time!

  % options structure
	eventNumber = 1;
	useStartOrEnd = 0;
	minBurstLength = 1;
	if (nargin >= 3)
	  if (isstruct(options))
		  if (isfield(options,'eventNumber'))
			  eventNumber = options.eventNumber;
			end
		  if (isfield(options,'useStartOrEnd'))
			  useStartOrEnd = options.useStartOrEnd;
			end
			if (isfield(options,'minBurstLength'))
			  minBurstLength = options.minBurstLength;
			end
		end
	end

	% --- build eventTimes, based on obj.type
	if (obj.type == 1) % conventional
	  eventTimes = obj.eventTimes;
	  eventTrials = obj.eventTrials;
	else
	  if (useStartOrEnd == 0)
		  eventTimes = obj.eventTimes;
	    eventTrials = obj.eventTrials;
		elseif (useStartOrEnd == 1)
		  eventTimes = obj.getStartTimes();
		  eventTrials = obj.getStartTrials();
		elseif (useStartOrEnd == 2)
		  eventTimes =obj.getEndTimes(); 
		  eventTrials = obj.getEndTrials();
		end
	end

  % --- determine where burst starts are

	% pass 1: look at diff and find > burstDt - these are candidate burst starts
	dET = diff(eventTimes);
  bsIdx = find(dET > burstDt);
	bsIdx = [1 bsIdx+1]; % reset indexing to match eventTimes instead of diff, and add 1st event as it is always start!
  

	% if useStartOrEnd is 0 and type is 2, exempt "gaps" that are during an event
	%  This is achieved by disallowing event ENDS to start bursts
	if (obj.type == 2 && useStartOrEnd == 0)
	  starts = find(rem(bsIdx,2) == 1);
		bsIdx = bsIdx(starts);
	end

  % --- build return vector
	burstIndices = [];
  if (isinf(eventNumber)) % last event
		for b=1:length(bsIdx)-1
			burstMembers = bsIdx(b):(bsIdx(b+1)-1);
			if (length(burstMembers) >= minBurstLength) ; burstIndices = [burstIndices burstMembers(end)]; end
		end
		burstMembers = bsIdx(end):length(eventTimes);
		if (length(burstMembers) >= minBurstLength) ; burstIndices = [burstIndices burstMembers(end)]; end
	else
		for b=1:length(bsIdx)-1
			burstMembers = bsIdx(b):(bsIdx(b+1)-1);
			if (length(burstMembers)>= eventNumber)
				if (length(burstMembers) >= minBurstLength) ; burstIndices = [burstIndices burstMembers(eventNumber)]; end
			end
		end
		burstMembers = bsIdx(end):length(eventTimes);
		if (length(burstMembers) >= eventNumber)
			if (length(burstMembers) >= minBurstLength) ; burstIndices = [burstIndices burstMembers(eventNumber)]; end
		end
	end
	burstTimes = eventTimes(burstIndices);
	if (length(eventTrials > 0))
  	burstTrials = eventTrials(burstIndices);
	end
