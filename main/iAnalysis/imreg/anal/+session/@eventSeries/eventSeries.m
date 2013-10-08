%
% SP June 2010
%
% This defines a class for dealing with series of events.  Specifically, it
%  should be used for temporally sparse data where events are few and far
%  between and time-stamp based storage is more efficient than continuous
%  sampling.  
%
%  Note that unlike timeSeries, where timeSeriesArray is the way to deal with
%  large data sets, since eventSeries are of different size, the 
%  eventSeriesArray is much more of a container and the eventSeries itself is
%  the core object.
%
% USAGE:
%
%  es = session.eventSeries(eventTimes, eventTrials, timeUnit, id, idStr,
%                           loadOnGet, loadOnGetRelPath, sourceFileRelPath,
%                           color, type)
%
%  The above invocation assigns values to relevant fields.  You can either 
%    invoke a blank constructor, a constructor w/ the first 3 variables, or
%    one with everything.  See below for meaning of fields.
%
% CLASS PROPERTIES:
%
% constructor-accessible:
%
%  eventTimes: the meat of the data ; times of each event
%  eventTrials: same length as event times; may or may not be populated with 
%               trial # for each event to allow quick sorting
%  timeUnit: in the standard format ; tells you what unit eventTimes are in
%
%  id: the unique numerical ID ; this can be, e.g., the ROI # ; used to sort
%  idStr: textual ID, not used for sorting just figures etc.
%  loadOnGet: [not yet in service] - keep the data in a file until requested
%  loadOnGetRelPath - where to load/save if loadOnGet is used
%  sourceFileRelPath: the source file used to build this data - this can
%                     be anything, such as a whiskerTrial object .mat file.
%
%  color: color in which ticks of this eventSeries are plotted
%  type: 1: regular series 2: start and end times - that is, each event has
%        two times, both of which are present.  Thus, if type is 2,
%        rem(length(eventTimes),2) = 0;
%
% not constructor-accessible:
%
%  eventTimesRelTrialStart: same size as eventTimes, stores each event's size
%                           relative start time of its trial.
%  eventPropertiesHash: hash object with presumably single-event associated
%                       properties.  
%
classdef eventSeries< handle
  % Properties
  properties 
	  % basic
    id = -1;
    idStr = '';
		loadOnGet = 0; % set to 1 and appropriate load is called on get
		loadOnGetRelPath = ''; % where loadOnget is, relative basePath
		sourceFileRelPath = ''; % source file path relative (global) basePath

		color = [0 0 0]; % color to plot ticks in
		type = 1; % 1: conventional 2: on/off

		timeUnit;

		% data -- same-sized, sorted arrays
		eventTimes;
		eventTrials;
		eventTimesRelTrialStart;
		eventPropertiesHash; 

		% internal
		loading; % flag used to avoid calling slow set methods during loading
  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = eventSeries(newEventTimes, newEventTrials, newTimeUnit, newId, ...
		                           newIdStr, newLoadOnGet, newLoadOnGetRelPath, ...
															 newSourceFileRelPath, newColor, newType, newEventPropertiesHash)
			% Type 'help session.eventSeries'

			obj.loading = 0;
       
			obj.eventPropertiesHash = hash();
		  % empty?
			if (nargin == 0)
			elseif(nargin == 3) % just data
			  obj.eventTrials = newEventTrials;
			  obj.eventTimes = newEventTimes; % eventTimes ALWAYS after trial since its set method SORTS
			  obj.timeUnit = newTimeUnit;

			else % everything
			  obj.eventTrials = newEventTrials;
			  obj.eventTimes = newEventTimes; % eventTimes ALWAYS after trial since its set method SORTS
			  obj.timeUnit = newTimeUnit;

			  obj.id = newId;
				obj.idStr = newIdStr;
				obj.loadOnGet = newLoadOnGet;
				obj.loadOnGetRelPath = newLoadOnGetRelPath;
				obj.sourceFileRelPath = newSourceFileRelPath;

				obj.color = newColor;
				obj.type = newType;
        if (nargin < 11)
          obj.eventPropertiesHash = hash();
        else
			    obj.eventPropertiesHash = newEventPropertiesHash;
        end
			end

			% sort
			obj.sortByTime();
		end

		%
		% Returns a new copy of this es
		%
		function newES = copy(obj)
		  newES = session.eventSeries(obj.eventTimes, obj.eventTrials, obj.timeUnit, obj.id, ...
			    obj.idStr, obj.loadOnGet, obj.loadOnGetRelPath, obj.sourceFileRelPath, ...
					obj.color, obj.type, obj.eventPropertiesHash);
			newES.eventTimesRelTrialStart = obj.eventTimesRelTrialStart;
		end

		%
		% Merge with another ES
		% 
    function obj = mergeWith(obj, oES)
     % sanity checks 
			if (obj.id ~= oES.id)
			  error('eventSeries.mergeWith::must be same id to merge.');
			elseif (obj.timeUnit ~= oES.timeUnit)
			  error('eventSeries.mergeWith::must be same timeUnit to merge.');
			end

			% you may proceed - only need trialIndices, time, valueMatrix ; base off
			obj.eventTimes = [obj.eventTimes oES.eventTimes];
			obj.eventTrials = [obj.eventTrials oES.eventTrials];
		  obj.eventTimesRelTrialStart = [obj.eventTimesRelTrialStart oES.eventTimesRelTrialStart];

      obj.sortByTime(); % let him do the dirty work!
		end

		%
		% Returns a copy of this ES restricted to specific events -- if type 1,
		%  pass ALL eventTimes yuo wish to copy, otherwise pass eventSTARTS
		%
    function newES = restrictedCopy(obj, keptEventTimes)
		  if (obj.type == 1)
			  keptIdx = find(ismember(obj.eventTimes,keptEventTimes));
			else
			  keptStartIdx = find(ismember(obj.getStartTimes(), keptEventTimes));
				keptIdx = sort([(2*keptStartIdx)-1 2*keptStartIdx]);
			end
			nEventTimes = obj.eventTimes(keptIdx);
			nEventTrials = obj.eventTrials(keptIdx);
			nEventTimesRelTrialStart = obj.eventTimesRelTrialStart(keptIdx);
		  newES = session.eventSeries(nEventTimes, nEventTrials, obj.timeUnit, obj.id, ...
			    obj.idStr, obj.loadOnGet, obj.loadOnGetRelPath, obj.sourceFileRelPath, ...
					obj.color, obj.type);
			newES.eventTimesRelTrialStart = nEventTimesRelTrialStart;

      % keep only wanted eventPropertiesHash members
      if (length(obj.eventPropertiesHash) > 0)
			  for h=1:length(obj.eventPropertiesHash)
				  vals = obj.eventPropertiesHash.get(obj.eventPropertiesHash.keys{h});
					if (length(vals) > 0)
            ki = keptIdx(find(keptIdx <= length(vals)));
						newES.eventPropertiesHash.setOrAdd(obj.eventPropertiesHash.keys{h}, vals(ki));
					end
				end
			end
		end

		% Returns start times of a type 2 event
		function startTimes = getStartTimes(obj)
		  if (obj.type == 2)
				valS = downsample(1:length(obj.eventTimes),2);
        if (length(valS) > 0 && valS(end)+1 > length(obj.eventTimes)) 
          valS = valS(1:end-1) ;
        end
				startTimes = obj.eventTimes(valS);
			else
			  startTimes = obj.eventTimes;
			end
		end

		% Returns start trials of a type 2 event
		function startTrials = getStartTrials(obj)
		  if (obj.type == 2)
				valS = downsample(1:length(obj.eventTrials),2);
        if (length(valS) > 0 && valS(end)+1 > length(obj.eventTrials)) 
          valS = valS(1:end-1) ;
        end
				startTrials = obj.eventTrials(valS);
			else
			  startTrials = obj.eventTrials;
			end
		end

		% Returns start times rel trial start for type 2
		function startTimesRelTrialStart = getStartTimesRelTrialStart(obj)
		  if (obj.type == 2)
				valS = downsample(1:length(obj.eventTimesRelTrialStart),2);
        if (length(valS) > 0 && valS(end)+1 > length(obj.eventTimesRelTrialStart)) 
          valS = valS(1:end-1) ;
        end
				startTimesRelTrialStart = obj.eventTimesRelTrialStart(valS);
			else
			  startTimesRelTrialStart = obj.eventTimesRelTrialStart;
			end
		end


		% Returns end times of a type 2 event
		function endTimes = getEndTimes(obj)
		  if (obj.type == 2)
				valE = downsample(2:length(obj.eventTimes),2);
				endTimes = obj.eventTimes(valE);
			else
			  endTimes = obj.eventTimes;
			end
		end

		% Returns end trials of a type 2 event
		function endTrials = getEndTrials(obj)
		  if (obj.type == 2)
				valE = downsample(2:length(obj.eventTrials),2);
				endTrials = obj.eventTrials(valE);
			else
			  endTrials = obj.eventTrials;
			end
		end

		% Returns end timesreltrialstart of a type 2 event
		function endTimesRelTrialStart = getEndTimesRelTrialStart(obj)
		  if (obj.type == 2)
				valE = downsample(2:length(obj.eventTimesRelTrialStart),2);
				endTimesRelTrialStart = obj.eventTimesRelTrialStart(valE);
			else
			  endTimesRelTrialStart = obj.eventTimesRelTrialStart;
			end
		end


		% removes all components for a specific trial(s)
	  function obj = deleteTrials(obj, trialIds)
		  delIdx = find(ismember(obj.eventTrials, trialIds));
			keepIdx = setdiff(1:length(obj.eventTimes), delIdx); % logic needed in case trialIndices blank
			obj.eventTimes = obj.eventTimes(keepIdx);
			obj.eventTrials = obj.eventTrials(keepIdx);

			if (length(obj.eventTimesRelTrialStart) > 0)
				obj.eventTimesRelTrialStart = obj.eventTimesRelTrialStart(keepIdx);
			end
	  end

		% length is # events
		function len = length(obj)
		  if (obj.type == 2)
				len = length(obj.eventTimes)/2;
			else
				len = length(obj.eventTimes);
			end
		end


    % sort events by time
    obj = sortByTime(obj)

		% wrapper for the same-named static method
		function [nEventTimes nEventTrials nEventTimesRelTrialStart] = getNthEventByTrial(obj, eventNumber)
		  [nEventTimes nEventTrials nEventTimesRelTrialStart] = session.eventSeries.getNthEventByTrialS( ...
			  obj.eventTimes, obj.eventTrials, obj.eventTimesRelTrialStart, eventNumber);
		end

		% returns an event series comprising only nth event of trial
		function es = getESBasedOnNthEventByTrial(obj, eventNumber)
		  [nEventTimes nEventTrials nEventTimesRelTrialStart] = session.eventSeries.getNthEventByTrialS( ...
			  obj.getStartTimes(), obj.getStartTrials(), obj.getStartTimesRelTrialStart(), eventNumber);
      es = obj.restrictedCopy(nEventTimes);
		end

		% wrapper for deriveTimeSeriesS
    function ts = deriveTimeSeries(obj, time, timeUnit, value) 
		  ts = session.eventSeries.deriveTimeSeriesS(obj, time, timeUnit, value, obj.type);
		end

    % assigns trial # and eventTimesRelTrialStart
    obj = updateEventSeriesFromTrialTimes(obj,trialTimes)

		% populates eventTimesRelTrialStart
		obj = generateStartTimeRelTimes(obj, startTimes, trialIndices)

    % very simple plot (raster style)
		plot(obj, color, yRange)

    % returns a timeSeries object based on this eventSeries convolved with some kernel
    ts = deriveTimeSeriesByConv(obj, kernel, time, timeUnit)

    % returns a timeSeries object based on this eventSeries' inter-event interval inverse
    ts = deriveRateTimeSeries(obj, time, timeUnit)

		% returns burst start times
    [burstTimes burstTrials] = getBurstTimes(obj, burstDt, options)

	end
  
  % STATIC methods (load)
  methods (Static)	
    % returns Nth event per trial given a series of time pionts, trial indices
    [nEventTimes nEventTrials nEventTimesRelTrialStart] = ...
		  getNthEventByTrialS(eventTimes, eventTrials, eventTimesRelTrialStart, eventNumber)
	  
		% returns trials including/excluding ies/xes
    trialsMatching = getTrialsByEvent(ies, xes, validTrialIds)

		% gives conditional probability p(a|b) = p(a & b)/p(b)
    condProb = getConditionalProbability(baseTimeSeries, aes, aTimeWindow, xaes, ...
		   xaTimeWindow, bes, bTimeWindow, xbes, xbTimeWindow, timeWindowUnit, aAllowOverlap, bAllowOverlap)

		% derives a simple time series provided values for each event
    ts = deriveTimeSeriesS(es, time, timeUnit, value, type)

		% detects coincident events, returning event series of where co-incident events occur
		es = getCoincidentEventsS(ies, coincidentDtMax, allowOverlap, returnedTimeUnit, ...
		                          xes, xTimeWindow, timeWindowUnit, returnType)
		
    % returns event series representing places where event sequences occur
		es = getEventSequenceS(ies, sequence, sequenceMaxDt, returnedTimeUnit, returnType, xes, xTimeWindow, ...
                   xTimeWindowUnit)
    
	  % returns an event series excluding some other event series
    es = getExcludedEventSeriesS(oes, excludedEvents, excludedEventsTimeUnit, excludeTimeWindow, allowOverlap)

    % returns list of event indices that comprise intersection of 2 ESs
    [aIdx bIdx] = intersectEventsS(aES, bES, aTimeWindow, bTimeWindow)

		% this is called on load
	  function obj = loadobj(a) 
		  a.loading = 1;
		  obj = a;
			obj.sortByTime();
			obj.loading = 0;
		end
	end


  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % -- ID ; nothing for now
	  function obj = set.id (obj, newId)
		  obj.id = newId;
		end
	  function value = get.id (obj)
		  value = obj.id;
		end

		% --- ensure eventTimes right size
		function obj = set.eventTimes(obj, newEventTimes)
		  if (size(newEventTimes,1) > size(newEventTimes,2))
			  obj.eventTimes = newEventTimes';
			else
			  obj.eventTimes = newEventTimes;
			end
		end

		% --- ensure eventTrials right size
		function obj = set.eventTrials(obj, newEventTrials)
		  if (size(newEventTrials,1) > size(newEventTrials,2))
			  obj.eventTrials = newEventTrials';
			else
			  obj.eventTrials = newEventTrials;
			end
		end

		% -- load on get path -- should be RELATIVE to global path
    function obj = set.loadOnGetRelPath (obj, newLoadOnGetRelPath)
		  rdp = get_root_data_path();
			if (strfind(newLoadOnGetRelPath, rdp) == 1)
				obj.loadOnGetRelPath = strrep(newLoadOnGetRelPath, rdp, '<%rootDataPath%>');
			else
			  obj.loadOnGetRelPath = newLoadOnGetRelPath;
			end
		end

		% -- returns the loadOnGetRelPath -- WITH global path !
		function value = get.loadOnGetRelPath(obj)
		  value = assign_root_data_path(obj.loadOnGetRelPath);
		end

		% -- source file path -- should be RELATIVE to global path
    function obj = set.sourceFileRelPath (obj, newSourceFileRelPath)
		  rdp = get_root_data_path();
			if (strfind(newSourceFileRelPath, rdp) == 1)
				obj.sourceFileRelPath = strrep(newSourceFileRelPath, rdp, '<%rootDataPath%>');
			else
			  obj.sourceFileRelPath = newSourceFileRelPath;
			end
		end

		% -- returns the sourceFileRelPath -- WITH global path !
		function value = get.sourceFileRelPath(obj)
		  value = assign_root_data_path(obj.sourceFileRelPath);
		end
  end
end
