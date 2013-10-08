%
% SP Mar 2011
%
% Sorts the events by time.
%
% USAGE:
%
%  ces.sortByTime()
%
function obj = sortByTime(obj)
	% check that this is not a subclass -- subclasses sort themselves
	if (strcmp(class(obj), 'session.calciumEventSeries'))
		% alwas start by just sorting everything
		[irr sidx] = sort(obj.eventTimes, 'ascend');
		obj.eventTimes = obj.eventTimes(sidx);
		if (length(obj.eventTrials) > 0) ;obj.eventTrials = obj.eventTrials(sidx); end
		if (length(obj.eventTimesRelTrialStart) > 0) obj.eventTimesRelTrialStart= obj.eventTimesRelTrialStart(sidx); end
		if (length(obj.peakTimes) > 0) ; obj.peakTimes = obj.peakTimes(sidx); end
		if (length(obj.endTimes) > 0) ; obj.endTimes = obj.endTimes(sidx); end
		if (length(obj.decayTimeConstants) > 0) ; obj.decayTimeConstants = obj.decayTimeConstants(sidx); end
		if (length(obj.riseTimeConstants) > 0) ; obj.riseTimeConstants = obj.riseTimeConstants(sidx); end
		if (length(obj.peakValues) > 0) ; obj.peakValues = obj.peakValues(sidx); end

		% if type 2, verify even # and proper spacing
		if (obj.type == 2 & length(obj.eventTimes) > 0) 
			val = 1:length(obj.eventTimes); % default keep all
			% if odd number, must remove weirdos --> MINIMIZE length
			if (rem(length(obj.eventTimes),2) ~= 0)
				disp('calciumEventSeries::for a type 2 event, MUST have even number of events - starts and ends.');
				disp(' Will infer what to do by pairing events in a way that minimizes INTRA pair timespan.');
				disp(' If this is no good, provide an EVEN number of events!');
				if (length(obj.eventTimes) == 1)
					val = [];
				else
					% 2 possibilities: keep 1,2 3,4 5,6 ... n-2,n-1 OR 2,3 4,5 ... n-1,n as pairs
					d1 = mean(obj.eventTimes(3:2:end)-obj.eventTimes(2:2:end-1));
					d2 = mean(obj.eventTimes(2:2:end)-obj.eventTimes(1:2:end-1));
					if (d1 < d2)
						val = 2:length(obj.eventTimes);
					else
						val = 1:length(obj.eventTimes)-1;
					end
				end

				obj.eventTimes = obj.eventTimes(val);
				if (length(obj.eventTrials) > 0) ; obj.eventTrials = obj.eventTrials(val);  end
				if (length(obj.eventTimesRelTrialStart) > 0) ; obj.eventTimesRelTrialStart = obj.eventTimesRelTrialStart(val); end
				if (length(obj.peakTimes) > 0) ; obj.peakTimes = obj.peakTimes(val); end
				if (length(obj.endTimes) > 0) ; obj.endTimes = obj.endTimes(val); end
				if (length(obj.decayTimeConstants) > 0) ; obj.decayTimeConstants = obj.decayTimeConstants(val); end
				if (length(obj.riseTimeConstants) > 0) ; obj.riseTimeConstants = obj.riseTimeConstants(val); end
				if (length(obj.peakValues) > 0) ; obj.peakValues = obj.peakValues(val); end
			else % alternate test for length minimization -- keep or remove first & last
				if (length(obj.eventTimes) == 2) % sanity check
					val = 1:2;
				else
					% 2 possibilities: keep 1,2 3,4 5,6 ... n-1,n OR 2,3 4,5 ... n-2,n-1 as pairs
					d1 = mean(obj.eventTimes(2:2:end)-obj.eventTimes(1:2:end-1));
					d2 = mean(obj.eventTimes(3:2:end-1)-obj.eventTimes(2:2:end-2));
					if (d1 < d2) % simply keep original ordering
						val = 1:length(obj.eventTimes);
					elseif (d2 < 10*d1) % more dangerous so threshodl
						disp('eventSeries::for a type 2 event, detected very large temporal asymmetry.');
						disp(' Will infer what to do by pairing events in a way that minimizes INTRA pair timespan.');
						val = 2:length(obj.eventTimes)-1;
					end
				end

				obj.eventTimes = obj.eventTimes(val);
				if (length(obj.eventTrials) > 0) ; obj.eventTrials = obj.eventTrials(val);  end
				if (length(obj.eventTimesRelTrialStart) > 0) ; obj.eventTimesRelTrialStart = obj.eventTimesRelTrialStart(val); end
				if (length(obj.peakTimes) > 0) ; obj.peakTimes = obj.peakTimes(val); end
				if (length(obj.endTimes) > 0) ; obj.endTimes = obj.endTimes(val); end
				if (length(obj.decayTimeConstants) > 0) ; obj.decayTimeConstants = obj.decayTimeConstants(val); end
				if (length(obj.riseTimeConstants) > 0) ; obj.riseTimeConstants = obj.riseTimeConstants(val); end
				if (length(obj.peakValues) > 0) ; obj.peakValues = obj.peakValues(val); end

			end
		end
	end


