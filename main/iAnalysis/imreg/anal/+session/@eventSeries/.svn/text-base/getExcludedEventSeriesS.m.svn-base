%
% SP Jun 2011
%
% Given an event series as well as a cell array of event series to exclude, 
%  it will build a new eventSeries that contains the subset of the passed 
%  eventSeries that does not overlap with excluders.
%
%  Note that this ONLY deals with start tiems, so make your time window large
%  enough if you are using type 2 events. 
%
% USAGE:
%
%   es = session.eventSeries.getExcludedEventSeriesS(oes, excludedEvents, excludedEventsTimeUnit, excludeTimeWindow, allowOverlap)
%
% PARAMS:
%
%   es: oes, but with any overlap with excludeEvents stripped out
%   
%   oes: eventSeries object that is worked on
%   excludedEvents: eventSeries object, cell array of eventSeries objects, or 
%                   vector of event times.  Type 2 eventSeries will only have
%                   start times considered for now.
%   excludedEventsTimeUnit: if excludedEvents is a vector, you must give its
%                           time unit
%   excludeTimeWindow: in SECONDS, how big of a window around each excluded 
%                      event time to exclude by. 0 is event time, so [-1 2] 
%                      would exclude anything b/w 1 second before or 2 after.
%   allowOverlap: if 0, it will use excludeTimeWindow to prevent overlap of oes
%                 Default is 0.
function es = getExcludedEventSeriesS(oes, excludedEvents, excludedEventsTimeUnit, excludeTimeWindow, allowOverlap)

  % --- input process
	if (nargin < 4) 
	  help('session.eventSeries.getExcludedEventSeriesS');
		return;
	end
	if (nargin < 5) ; allowOverlap = 0 ; end

  excludedEventTimes = [];
  if (isobject(excludedEvents))
	  excludedEventTimes = excludedEvents.getStartTimes();
		excludedEventsTimeUnit = excludedEvents.timeUnit;
	elseif (iscell(excludedEvents))
		excludedEventsTimeUnit = excludedEvents{1}.timeUnit;
		for e=1:length(excludedEvents)
		  excludedEventTimes = [excludedEventTimes excludedEvents{e}.getStartTimes()];
		end
	else
	  excludedEventTimes = excludedEvents;
  end
  excludedEventTimes = sort(excludedEventTimes);

  includedEventTimes = oes.getStartTimes();

	% --- convert time to same [ms]
  excludedEventTimes = session.timeSeries.convertTime(excludedEventTimes, excludedEventsTimeUnit, 1);
  includedEventTimes = session.timeSeries.convertTime(includedEventTimes, oes.timeUnit, 1);
	excludeTimeWindow =  session.timeSeries.convertTime(excludeTimeWindow, 2,1);

	% --- main section -- apply exclusion and filter down includedEventTimes
  keep = ones(1,length(includedEventTimes));
	if (length(excludedEventTimes) > 0)
	  for i=1:length(includedEventTimes)
		  distVec = excludedEventTimes-includedEventTimes(i);
			if (length(find(distVec >= excludeTimeWindow(1) & distVec <= excludeTimeWindow(2))) > 0) ; keep(i) = 0; end
		end
	end
  keepIdx = find(keep);

  % overlap
	if (~allowOverlap)
		for i=1:length(includedEventTimes)
		  if (keep(i))
		    sdiff = setdiff(keepIdx, i);
		    distVec = includedEventTimes(i)-includedEventTimes(sdiff);
			  removeIdx = find(distVec >= excludeTimeWindow(1) & distVec <= excludeTimeWindow(2));
				if (length(removeIdx) > 0)
				  keep(sdiff(removeIdx)) = 0;
					keepIdx = find(keep);
				end
			end
		end
	end

	keptEventTimes = includedEventTimes(keepIdx);

	% --- build the final guy
  es = oes.restrictedCopy(keptEventTimes);
	es.idStr = ['Exclusive ' es.idStr];
