%
% SP MAy 2011
%
% This will return the indices of events that are overlapping based on user
%  specified criteria for two eventSEries.
%
% USAGE:
%  
%  [aIdx bIdx] = intersectEventsS(aES, bES, aTimeWindow, bTimeWindow)
% 
% PARAMS:
%
%   aIdx, bIdx: indices within eventSeries a and b that overlap.  If an event
%               series is of type 2, it will return the index of BOTH start AND
%               end time.
%
%   aES, bES: two eventSeries that are checked for overlap.  If events are of 
%             type 2, ANY overlap implies intersection.   
%   aTimeWindow: Padding added RELATIVE EVENT START TIME in seconds.  Event 
%                start time is 0.  So if this is, e.g., [0 2], 2 seconds of 
%                padding are added at the end, as though this were a type 2 
%                event of length 2.  Note that in case of type 2 events,
%                padding after the event will produce the longest event 
%                possible -- e.g., for a 3 second long event, [0 2] would
%                effectively do nothing as the 3 second event duration would
%                dominate.  IF the event were only 1 second long, however,
%                [0 2] would make it 2 seconds long.  [-1 2] would also move 
%                the start time back by 1 s.
%   bTimeWindow: same as a, but this is applied to bES.
%                
function  [aIdx bIdx] = intersectEventsS(aES, bES, aTimeWindow, bTimeWindow)

  % --- input check
	if (nargin < 2) 
	  help('session.eventSeries.intersectEventsS');
		return;
	end
	if (nargin < 3 || length(aTimeWindow) == 0) ; aTimeWindow = [0 0]; end
	if (nargin < 4 || length(bTimeWindow) == 0) ; bTimeWindow = [0 0 ] ;end

	% --- pre build windowed
	aSTimes = aES.getStartTimes();
	aETimes = aES.getEndTimes();

	bSTimes = bES.getStartTimes();
	bETimes = bES.getEndTimes();

	% convert all time units to aES's
	bSTimes = session.timeSeries.convertTime(bSTimes, bES.timeUnit, aES.timeUnit);
	bETimes = session.timeSeries.convertTime(bETimes, bES.timeUnit, aES.timeUnit);

  aTimeWindow = session.timeSeries.convertTime(aTimeWindow, 2, aES.timeUnit);
  bTimeWindow = session.timeSeries.convertTime(bTimeWindow, 2, aES.timeUnit);

	% pad with window
	aSTimes = aSTimes + aTimeWindow(1);
	taETimes = aSTimes + aTimeWindow(2);
	aETimes = max(aETimes, taETimes);

	bSTimes = bSTimes + bTimeWindow(1);
	tbETimes = bSTimes + bTimeWindow(2);
	bETimes = max(bETimes, tbETimes);

	% --- determine intersection
	aInt = 0*aSTimes;
	bInt = 0*bSTimes;

	aL = aETimes - aSTimes;
  for a=1:length(aSTimes)
	  dBs = bSTimes - aSTimes(a);
	  dBe = bETimes - aSTimes(a);
		vals = find(dBs >= 0 & dBs <= aL(a));
		vale = find(dBe >= 0 & dBe <= aL(a));
		val = union(vals,vale);
		if (length(val) > 0)
		  aInt(a) = 1;
		  bInt(val) = 1;
		end
	end

  % aIdx and bIdx
	if (aES.type == 2)
	  taInt = 0*[aInt aInt];
		taInt(1:2:end-1) = aInt;
		taInt(2:2:end) = aInt;
		aInt = taInt;
	end
  aIdx = find(aInt);
  
	if (bES.type == 2)
	  tbInt = 0*[bInt bInt];
		tbInt(1:2:end-1) = bInt;
		tbInt(2:2:end) = bInt;
		bInt = tbInt;
	end
  bIdx = find(bInt);
  

