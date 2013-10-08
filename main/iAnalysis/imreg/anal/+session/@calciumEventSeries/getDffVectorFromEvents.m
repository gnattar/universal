%
% Returns a vector based on this calciumTimeSeries that is the predicted dF/F
%
% This function will convolve with exponentials, using linear rise specified by
%  riseTimeConstants and exponential decayTimeConstants.  It employes peakTimes
%  as well as peakValues.  If those are not populated this will fail.
%
% USAGE:
%
%		dffVec = caESA.getDffVectorFromEvents(time, timeUnit)
%   
% ARGUMENTS:
%
%   time: time vector you want to use
%   timeUnit: unit of said vector
%
function dffVec = getDffVectorFromEvents (obj, time, timeUnit)

  %% --- input handling
	if (nargin < 3)
	  help('session.calciumEventSeries.getDffVectorFromEvents');
		error ('Must pass all arguments');
	end

	% convert time ...
	time = session.timeSeries.convertTime(time, timeUnit, obj.timeUnit);
  dt = mode(diff(time));
	tausInDt = round(obj.decayTimeConstants/dt);
	tRiseInDt = round(obj.riseTimeConstants/dt);


	% proceed ...
	val = find(ismember(obj.peakTimes, time));
  vPeakTimes = obj.peakTimes(val);
  vPeakValues = obj.peakValues(val);
  nDec = 5*tausInDt(val);;
	peakIdx = find(ismember(time,vPeakTimes));

	tRiseInDt = tRiseInDt(val);
	tausInDt = tausInDt(val);

	dffVec = 0*time;
	for v=1:length(peakIdx);
	 	% build vector
	  vec = [linspace(0,1,tRiseInDt(v)+1) exp(-1*(2:nDec(v))/tausInDt(v))];
    vPeakIdx = tRiseInDt(v)+1;
 
		% boundaries in case at start/end
		nPrePeak = min(1,peakIdx(v)-tRiseInDt(v));
		nPostPeak = min(nDec(v)-1, length(time)-peakIdx(v));
 
    % and populate ...
		vec = vec*vPeakValues(v);
    
    dffVec(peakIdx(v)-nPrePeak:peakIdx(v)+nPostPeak) = dffVec(peakIdx(v)-nPrePeak:peakIdx(v)+nPostPeak) + vec(vPeakIdx-nPrePeak:vPeakIdx+nPostPeak);
	end


