%
% SP Jan 2011
%
% Returns even times and trials for nth event in a trial.
%
% USAGE:
%
%  [nEventTimes nEventTrials nEventTimesRelTrialStart] = 
%     getNthEventByTrial(eventTimes, eventTrials, eventTimesRelTrialStart, eventNumber)
%
%  nEventTimes, nEventTrials: requested event times, with corresponding trials
%                             if an event of the requested criteria is not found,
%                             it does not populate returned vectors.
%  nEventTimesRelTrialStart: returned event time relative trial start
%
%  eventTimes, eventTrials: pool of events to pick from, and their trial #
%  eventTimesRelTrialStart: event times rel trial start
%  eventNumber: which event to return -- inf means last
%
function [nEventTimes nEventTrials nEventTimesRelTrialStart] = getNthEventByTrialS(eventTimes, eventTrials, eventTimesRelTrialStart, eventNumber)
  nEventTimes = [];
	nEventTrials = [];
	nEventTimesRelTrialStart = [];

  % --- input
	if (nargin < 4)
	  disp('getNthEventByTrial::must pass all arguments.');
		help session.eventSeries.getNthEventByTrialS;
    return;
	end

	% --- and the work
	ut = unique(eventTrials);
	keepIdx = 0*eventTimes;
	for t=1:length(ut)
	  % get all on this trial
	  T = ut(t);
		tei = find(eventTrials == T);

    % match number ...
		idx = [];
		if (eventNumber == inf)
		  idx = max(tei);
		elseif (length(tei) >= eventNumber) % have this event 
		  idx = tei(eventNumber);
		end

    % found match?
		if (length(idx) > 0)
		  keepIdx(idx) = 1;
		end
	end

	% --- reconstitute
	val = find(keepIdx);
	if (length(val) > 0)
	  nEventTimes = eventTimes(val);
		nEventTrials = eventTrials(val);
		if (length(eventTimesRelTrialStart) > 0)
			nEventTimesRelTrialStart = eventTimesRelTrialStart(val);
		end
	end
		  

