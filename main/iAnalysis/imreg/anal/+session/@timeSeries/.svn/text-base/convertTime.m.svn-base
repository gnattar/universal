%
% SP Jan 2011
%
% For keeping time units sane - will convert from one time unit to another.
%
%  USAGE: 
%    
%    convertedTime = convertTime(originalTime, originalTimeUnit, convertedTimeUnit)
%
%  Time units:
%    timeUnitId = [1 2 3 4 5]; 
%    timeUnitStr = {'ms', 's', 'm', 'h', 'd'} ;  
%
function convertedTime = convertTime(originalTime, originalTimeUnit, convertedTimeUnit)
  % --- argument check
	if (nargin < 3)
	  disp('convertTime::must specify orginal time, its unit, and new unit.');
    help('session.timeSeries.convertTime');
		return;
	end
	if (~ismember(originalTimeUnit,session.timeSeries.timeUnitId) || ...
	   (~ismember(convertedTimeUnit,session.timeSeries.timeUnitId) ))
		disp('convertTime::both time units must be valid (see session.timeSeries.timeUnitId)');
    help('session.timeSeries.convertTime');
		return;
	end

	% --- convert to ms 
	switch originalTimeUnit
	  case 1 % ms - nothing
		  tempTime = originalTime;
		case 2 % s - *1000
		  tempTime = originalTime*1000;
		case 3 % minutes *1000*60
		  tempTime = originalTime*1000*60;
		case 4 % hours *1000*60*60
		  tempTime = originalTime*1000*60*60;
		case 5 % days *1000*60*60*24
		  tempTime = originalTime*1000*60*60*24;
	end

	% --- from ms to whatever they desired
  switch convertedTimeUnit
	  case 1 % already there
		  convertedTime = tempTime;
		case 2 % s - /1000
		  convertedTime = tempTime/1000;
		case 3 % minutes /1000/60
		  convertedTime = tempTime/1000/60;
		case 4 % hours /1000/60/60
		  convertedTime = tempTime/1000/60/60;
		case 5 % days /1000/60/60/24
		  convertedTime = tempTime/1000/60/60/24;
	end


