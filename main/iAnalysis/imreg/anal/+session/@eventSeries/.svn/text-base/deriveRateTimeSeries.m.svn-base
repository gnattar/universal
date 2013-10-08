%
% SP Dec 2010
%
% This will return a timeSeries object based on the eventSeries that gives the
%  inverse inter-event itnerval.  Rate is in units of 1/timeUnit.
%
% USAGE:
%
%	ts = es.deriveRateTimeSeries(time, timeUnit)
%  
%   time: time vector you want to use ; ts.values will correspond to this
%         leave blank and time will simply be min and max event times. 
%   timeUnit: unit of your time vector 
%
function ts = deriveRateTimeSeries(obj, time, timeUnit)
	%% --- sanity
	if (nargin < 2) 
	  time = []; 
	end
	if (nargin < 3)
	  timeUnit = obj.timeUnit;
  end
  eventTimes = obj.eventTimes;
	if (timeUnit ~= obj.timeUnit)
    eventTimes = session.timeSeries.convertTime(obj.eventTimes, obj.timeUnit, timeUnit);
  end

  %% --- generate the data
	if (length(time) == 0)
	  time = eTimeVec;
		values = valueVec;
	  ts = session.timeSeries(time, timeUnit, values, obj.id, [obj.idStr ' Rate'], 0, '');
  else % compute rate explicitly
    rate = 0*time;
    dt = mode(diff(time));

    for t=1:length(time)-1
      nev = length(find(obj.eventTimes >= time(t) & obj.eventTimes < time(t+1)));
      rate(t+1) = nev/dt;
    end
    
    ts = session.timeSeries(time, timeUnit, rate, obj.id, [obj.idStr ' Rate'], 0, '');
  end
  

	
