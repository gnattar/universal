%
% SP Dec 2010
%
% This will return a timeSeries object based on the eventSeries that convolves 
%  the ES with some kernel.
%
% USAGE:
%
%	ts = es.deriveTimeSeriesByConv(kernel, time, timeUnit, trials)
%  
%   kernel: convolution kernel employed; vector.  'dt' of the kernel
%           is assumed to be same as time.  You must construct it right.
%   time: time vector you want to use
%   timeUnit: unit of your time vector 
%
function ts = deriveTimeSeriesByConv(obj, kernel, time, timeUnit)
	% --- sanity
	if (nargin < 3) 
	  disp('deriveTimeSeriesByConv::must specify time vector & kernel & least');
	end
	if (nargin < 4)
	  timeUnit = obj.timeUnit;
	end
	if (timeUnit ~= obj.timeUnit)
	  disp('deriveTimeSeriesByConv::only supporting same-unit conversion.');
  end
	if (size(time,1) > size(time,2)) ; time = time' ; end

	% --- bin count
	dt = mode(diff(time));
	sparseTime = downsample(time,20);
	valueVec = 0*time;
	for e=1:length(obj.eventTimes)
	  si = find(sparseTime > obj.eventTimes(e)-(20*dt) & sparseTime < obj.eventTimes(e)+(20*dt));
	  tir = (min(si)*20-21:20*max(si)+21);
	  eIdx = tir(find(time(tir) > obj.eventTimes(e)-dt & time(tir) < obj.eventTimes(e)+dt));
		if (length(eIdx) > 0)
			valueVec(eIdx(1)) = valueVec(eIdx(1)) + 1;
		end
	end

	% --- convolve 
	convValue = conv(valueVec,kernel,'same');

	% --- generate returned object
  ts = session.timeSeries(time, timeUnit, convValue, obj.id, ['Convolved ' obj.idStr], 0, '');
  
