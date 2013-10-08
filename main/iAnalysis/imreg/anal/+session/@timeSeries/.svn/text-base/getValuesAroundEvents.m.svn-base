%
% SP Jan 2011
%
% Function for retrieving data from a timeSeries that is based on when events
%  occur -- basically event triggered average.
%
% USAGE:
%
%   [valueMat timeMat idxMat timeVec ieIdxVec] = 
%      getValuesAroundEvents (ies, iTimeWindow, windowTimeUnit, allowOverlap, xes, xTimeWindow)
%
%     valueMat and timeMat are the data and time at which it occured
%     idxMat: indices used (valueMat = obj.values(idxMat) ; timeMat same)
%     timeVec: time vector with event center at 0
%     ieIdxVec: which events, in ies, were used for each row
%
%     ies - eventSeries objects used as point of reference ("included").  Can 
%           be a cell array of event Series.
%     iTimeWindow - 0 is time of event ; so [-5 5] would show +/- 5 time units
%                   use "during" and ONLY values that take place during type 2
%                   events will be returned; all else will be NaN.
%     timeWindowUnit - in s ; 0 is time of event ; so [-5 5] would show +/- 5 secionds 
%     allowOverlap - if 0, events are taken as they come, and all subsequent 
%                    events are not given their own row in idxMat, timeMat. 
%                    This ensures no timepoint duplication.  If 1, all events
%                    are included, and time duplication is permitted.
%     xes - if provided, you will EXCLUDe if these events occur in the exclude time 
%           window.  Can be cell array.
%     xTimeWindow - same as iTimeWindow, but now if an excluded event occurs within xTimeWindow
%                   of an included event, that (included) event is dropped. Same
%                   timeUnit as timeWindowUnit
%
function [valueMat timeMat idxMat timeVec ieIdxVec] = getValuesAroundEvents(obj, ies, iTimeWindow, timeWindowUnit, allowOverlap, xes, xTimeWindow)
  valueMat = [];
  timeMat = [];
	idxMat = [];
  timeVec= [];
  ieIdxVec = [];

  % --- input process
	if (nargin < 3)  
		disp('getValuesAroundEvents::must provide event series, timeWindow.');
	return ; 
	end
	if (nargin < 4 || length(timeWindowUnit) == 0) % by default use same timeUnit as object
		timeWindowUnit = obj.timeUnit;
	end
	if (nargin < 5 || length(allowOverlap) == 0) % allow overlap
		allowOverlap = 0;
	end
	if (nargin == 6)
		disp('getValuesAroundEvents::must provide exclude window to exclude; ignoring exclude.');
		xes = {};
		xTimeWindow = [];
	end
	if (nargin < 7 || length(xTimeWindow) == 0)
		xes = {};
		xTimeWindow = [];
	end

  % convert solitary eventSeries objects to cells
	if (~iscell(ies) && isobject(ies)) ; ies = {ies}; end
	if (~iscell(xes) && isobject(xes)) ; xes = {xes}; end

	% --- time handling and other setup
	dataVec = obj.value;
  if (isnumeric (ies))
	  eTimeUnit = obj.timeUnit;
	else
  	eTimeUnit = ies{1}.timeUnit;
	end


  % --- during
  if (strcmp(iTimeWindow,'during'))
		% verify type 2
		if (ies{1}.type == 2)
      if (length(ies) > 1)
				disp('getValuesAroundEvents::during does not support multiple eventSeries objects.  Aborting');
				return;
			end

			% determine longest event and use this to set your time window
			ist = ies{1}.getStartTimes();
			ise = ies{1}.getEndTimes();
			eLen = ise - ist;
			maxEventLen = max(eLen);
			iTimeWindow = [0 maxEventLen];
			timeWindowUnit = ies{1}.timeUnit;

			% build a vector, based on obj.time, which has nan for all out-of-event epochs
		  duringTS = session.eventSeries.deriveTimeSeriesS(ies{1}, obj.time, obj.timeUnit, [nan 1], 2);
			dataVec = dataVec.*duringTS.value; % multiply to nan non-event overlapping values
		else
		  disp('getValuesAroundEvents::must use type 2 events to do during');
		end
	end

  % --- prebuild vectors
	iEventTimes = [];
	if (isnumeric(ies))
	  iEventTimes = sort(unique(ies));
	else
		for i=1:length(ies)
			ttime = session.timeSeries.convertTime(ies{i}.getStartTimes(), ies{i}.timeUnit, eTimeUnit);
			iEventTimes = sort(union(iEventTimes,ttime)); % in case it is 'ON/OFF' event
		end
	end

	xEventTimes = [];
	if (isnumeric(xes))
	  xEventTimes = sort(unique(xes));
	else
		for x=1:length(xes)
      if (length(xes{x}.getStartTimes()) > 0)
			  ttime = session.timeSeries.convertTime(xes{x}.getStartTimes(), xes{x}.timeUnit, eTimeUnit);
			  xEventTimes = sort(union(xEventTimes,ttime)); % in case it is 'ON/OFF' event
      end
		end
	end

  % call getIndexWindowsAroundEvents
  [idxMat timeMat timeVec ieIdxVec] = session.timeSeries.getIndexWindowsAroundEventsS(obj.time, ...
	                                            obj.timeUnit, iTimeWindow, timeWindowUnit, ...
                  iEventTimes, eTimeUnit, xTimeWindow, xEventTimes, eTimeUnit, allowOverlap); 

  valueMat = nan*idxMat;
  valIdx = find(~isnan(idxMat));
  valueMat(valIdx) = dataVec(idxMat(valIdx));

  % if we are doing during, we want to affect idxMat and timeMat too
  if (strcmp(iTimeWindow,'during'))
	  nanIdx = find(isnan(valueMat));
		idxMat (nanIdx) = nan;
		timeMat(nanIdx) = nan;
	end
