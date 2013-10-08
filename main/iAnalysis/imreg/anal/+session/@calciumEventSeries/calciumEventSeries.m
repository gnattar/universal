%
% This defines a class for dealing with series of calcium-derived events.
%
% DESCRIPTION:
%
% This class is a subclass of session.eventSeries.  In addition to its fields,
%  it has the following:
%
%  	peakTimes: peak time (all time variables are in timeUnit)
%   endTimes: end of event ; generally not avaialbe
%   decayTimeConstants: decay time constant
%		riseTimeConstants: rise time constant
%		peakValues: generally dFF, but can be other things 
%
%  Note that "eventTimes" is the time of the event start.
%
% USAGE:
%
%  caES = session.calciumEventSeries(newEventTimes, newEventTrials, newPeakTimes, ...
%		        newEndTimes, newDecayTimeConstants, newRiseTimeConstants, newPeakValues, ...
%						newTimeUnit, newId, newIdStr, newLoadOnGet, newSourceFileRelPath)
%
% (C) Simon Peron June 2010
%
classdef calciumEventSeries < session.eventSeries
  % Properties
  properties 

		% data -- additional info ; eventTimes is START
		peakTimes; % peak time ; note all are assumed to use timeUnit
    endTimes; % end of event
    decayTimeConstants; % decay time constant
		riseTimeConstants; % rise time constant
		peakValues; % generally dFF, but can be other things (e.g., if you used
	              % vogelstein detection, it is his reported peak for THAT
								% event -- i.e., post-peel)

  end

	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = calciumEventSeries(newEventTimes, newEventTrials, newPeakTimes, ...
		        newEndTimes, newDecayTimeConstants, newRiseTimeConstants, newPeakValues, ...
						newTimeUnit, newId, newIdStr, newLoadOnGet, newSourceFileRelPath)

		  % defaults
			eventTimes = [];
			peakTimes = [];
			endTimes = [];
			decayTimeConstants = [];
			riseTimeConstants = [];
			peakValues = [];
			timeUnit = 1;
			id = -1;
			idStr = '';
			loadOnGet = 0;
			sourceFileRelPath = '';

			if(nargin >= 7) % base data
				eventTrials = newEventTrials;
			  peakTimes = newPeakTimes;
			  endTimes = newEndTimes;
			  decayTimeConstants = newDecayTimeConstants;
			  riseTimeConstants = newRiseTimeConstants;
			  peakValues = newPeakValues;
			  eventTimes = newEventTimes; 
      end
			if(nargin >= 8) % other things often passed
			  timeUnit = newTimeUnit;
				id = newId;
				idStr = newIdStr;
			end
			if (nargin >= 12) % rarities
			  loadOnGet = newLoadOnGet;
				sourceFileRelPath = newSourceFileRelPath;
			end

      % hitup superclass constructor 
      obj = obj@session.eventSeries(eventTimes, eventTrials, timeUnit, id, idStr, loadOnGet, '', sourceFileRelPath, [1 0 0], 1);

      % assign others
			obj.peakTimes = peakTimes;
			obj.endTimes = endTimes;
			obj.decayTimeConstants = decayTimeConstants;
			obj.riseTimeConstants = riseTimeConstants;
			obj.peakValues = peakValues;

			% sort
			obj.sortByTime();

		end

    % 
		% Merge with another object
		%
		function obj = mergeWith (obj, oCES)
	    % sanity checks 
			if (obj.id ~= oCES.id)
			  error('calciumEventSeries.mergeWith::must be same id to merge.');
			elseif (obj.timeUnit ~= oCES.timeUnit)
			  error('calciumEventSeries.mergeWith::must be same timeUnit to merge.');
			end

			% you may proceed - only need trialIndices, time, valueMatrix ; base off
      if (length(obj.eventTimes) == 0)
        obj.eventTimes = oCES.eventTimes;
        obj.eventTrials = oCES.eventTrials;
        obj.eventTimesRelTrialStart = oCES.eventTimesRelTrialStart;
        obj.peakTimes = oCES.peakTimes;
        obj.endTimes = oCES.endTimes;
        obj.decayTimeConstants = oCES.decayTimeConstants;
        obj.riseTimeConstants = oCES.eventTimes;
        obj.peakValues = oCES.peakValues;
      elseif (length(oCES.eventTimes) > 0)
        obj.eventTimes = [obj.eventTimes oCES.eventTimes];
        obj.eventTrials = [obj.eventTrials oCES.eventTrials];
        obj.eventTimesRelTrialStart = [obj.eventTimesRelTrialStart oCES.eventTimesRelTrialStart];
        obj.peakTimes = [obj.peakTimes oCES.peakTimes];
        obj.endTimes = [obj.endTimes oCES.endTimes];
        obj.decayTimeConstants = [obj.decayTimeConstants oCES.decayTimeConstants];
        obj.riseTimeConstants = [obj.eventTimes oCES.eventTimes];
        obj.peakValues = [obj.peakValues oCES.peakValues];
      end
	          
      obj.sortByTime(); % let him do the dirty work!
		end

		%
		% Returns a new copy of this ces
		%
		function newCES = copy(obj)
		  newCES = session.calciumEventSeries(obj.eventTimes, obj.eventTrials, ...
			  obj.peakTimes, obj.endTimes, obj.decayTimeConstants, ...
				obj.riseTimeConstants, obj.peakValues, obj.timeUnit, obj.id, ...
				obj.idStr, obj.loadOnGet, obj.sourceFileRelPath);
			newCES.eventTimesRelTrialStart = obj.eventTimesRelTrialStart;
		end

		% removes all components for a specific trial(s)
	  function obj = deleteTrials(obj, trialIds)
		  delIdx = find(ismember(obj.eventTrials, trialIds));
			keepIdx = setdiff(1:length(obj.eventTimes), delIdx); % logic needed in case trialIndices blank
			obj.eventTimes = obj.eventTimes(keepIdx);
			if (~isempty(obj.eventTrials)) ; obj.eventTrials = obj.eventTrials(keepIdx); end
			if (~isempty(obj.eventTimesRelTrialStart)) ; obj.eventTimesRelTrialStart = obj.eventTimesRelTrialStart(keepIdx); end
      if (~isempty(obj.peakTimes));	obj.peakTimes = obj.peakTimes(keepIdx); end
      if (~isempty(obj.endTimes));	obj.endTimes = obj.endTimes(keepIdx); end
      if (~isempty(obj.decayTimeConstants));	obj.decayTimeConstants = obj.decayTimeConstants(keepIdx); end
      if (~isempty(obj.riseTimeConstants));	obj.riseTimeConstants = obj.riseTimeConstants(keepIdx); end
      if (~isempty(obj.peakValues));	obj.peakValues = obj.peakValues(keepIdx); end
    end

		% Returns a timeseries representation of this event series
    function ts = deriveTimeSeries(obj, time, timeUnit)
		  ts = deriveTimeSeries@session.eventSeries(obj, time, timeUnit, obj.peakValues);
    end

		% returns a calcium dff vector based on the events in this array
		dffVec = getDffVectorFromEvents(obj, time, timeUnit)
  
  end
 
  % STATIC methods (load)
  methods (Static)	
		% this is called on load
	  function obj = loadobj(a) 
		  obj = a;
			obj.sortByTime();
		end


	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
		obj = sortByTime(obj)
   
		% --- ensure peakTimes is right size
		function obj = set.peakTimes(obj, newPeakTimes)
		  if (size(newPeakTimes,1) > size(newPeakTimes,2))
			  obj.peakTimes = newPeakTimes';
			else
			  obj.peakTimes = newPeakTimes;
			end
		end

		% --- ensure endTimes is right size
		function obj = set.endTimes(obj, newEndTimes)
		  if (size(newEndTimes,1) > size(newEndTimes,2))
			  obj.endTimes = newEndTimes';
			else
			  obj.endTimes = newEndTimes;
			end
		end

  
		% --- ensure decayTimeConstants is right size
		function obj = set.decayTimeConstants(obj, newDecayTimeConstants)
		  if (size(newDecayTimeConstants,1) > size(newDecayTimeConstants,2))
			  obj.decayTimeConstants = newDecayTimeConstants';
			else
			  obj.decayTimeConstants = newDecayTimeConstants;
			end
		end

		% --- ensure riseTimeConstants is right size
		function obj = set.riseTimeConstants(obj, newRiseTimeConstants)
		  if (size(newRiseTimeConstants,1) > size(newRiseTimeConstants,2))
			  obj.riseTimeConstants = newRiseTimeConstants';
			else
			  obj.riseTimeConstants = newRiseTimeConstants;
			end
		end

		% --- ensure peakValues is right size
		function obj = set.peakValues(obj, newPeakValues)
		  if (size(newPeakValues,1) > size(newPeakValues,2))
			  obj.peakValues = newPeakValues';
			else
			  obj.peakValues = newPeakValues;
			end
    end
  end
end
