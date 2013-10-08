%
% Returns a timeSeries object based on calling eventSeries.
%
% This will return a timeSeries object based on the eventSeries by matching
%  EXACTLY the eventTimes to the provided time vector and then setting value
%  based on the provided value vector, which should be same size as your 
%  time vector.  If type is 2 (default 1), value(1) is during non-event
%  epochs and value(2) is during event epochs.  If type 1, you can also give
%  just two values and it will get value (1) during time periods that are 
%  within 1/2 dt of an event (where dt is mode(diff(time))).
%
% USAGE:
%
%  	ts = es.deriveTimeSeriesS(es, time, timeUnit, value, type)
%  
% ARGUMENTS:
% 
%   es: eventSeries object used
%   time: time vector you want to use 
%   timeUnit: unit of your time vector 
%   value: must be same length as time or 2 element
%   type: as in eventSeries.type ; default is 1
%
% (C) Simon Peron, Mar 2011
function ts = deriveTimeSeriesS(es, time, timeUnit, value, type)
  ts = [];

	% --- sanity
	if (nargin < 4) 
	  help session.eventSeries.deriveTimeSeriesS;
	  disp('deriveTimeSeriesS::must provide all parameters.');
		return;
	end
	if (nargin < 5 || length(type) == 0)
	  type = 1;
	end
	if (timeUnit ~= es.timeUnit)
	  disp('deriveTimeSeriesS::only supporting same-unit conversion.');
  end
	if (type == 1 && length(es.eventTimes) ~= length(value) && length(value) ~= 2)
	  disp('deriveTimeSeriesS::the provided value vector must be same length as eventTimes.');
		return;
	end

	% --- insert it accordingly ...
	nMissed = 0; % count how many you don't match
	valueVec = 0*time;
  modeDt2 = mode(diff(time))/2;
	if (type == 2)
	  valueVec = valueVec + value(1);
	  est = es.getStartTimes();
    eet = es.getEndTimes();
		for e=1:length(est)
      ti = find(time > est(e)-modeDt2 & time < eet(e)+modeDt2);
		  if (~isempty(ti))
				valueVec(ti) = value(2);
			else
				nMissed = nMissed + 1;
			end

		end
	elseif (length(value) == length(es.eventTimes)) % default is 1
		for e=1:length(es.eventTimes)
			ti = find(time > es.eventTimes(e)-modeDt2 & time < es.eventTimes(e)+modeDt2);
      if (~isempty(ti))
				valueVec(ti) = value(e);
			else
				nMissed = nMissed + 1;
			end
		end
	elseif (length(value) == 2) % 2 values
	  valueVec = valueVec + value(1);
		et = es.eventTimes;
		for e=1:length(et)
      ti = find(time > et(e)-modeDt2 & time < et(e)+modeDt2);
		  if (~isempty(ti))
				valueVec(ti) = value(2);
			else
				nMissed = nMissed + 1;
			end

		end
	end

	% --- generate returned object
	ts = session.timeSeries(time, timeUnit, valueVec, es.id, [es.idStr ' derived TS'], 0, '');

	% warn if missed some
	if (nMissed > 0)
%	  disp(['deriveTimeSeriesS::in generating ' es.idStr '-derived TS, ' num2str(nMissed) ' events were not matched to provided time vector.']);
	end
  
