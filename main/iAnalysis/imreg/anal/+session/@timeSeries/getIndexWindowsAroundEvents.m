%
% SP Feb 2011
%
% Basically an object-based wrapper for getIndexWindowsAroundEventsS.
%
% USAGE:
%
%		[idxMat timeMat timeVec ieIdxVec] = ts.getIndexWindowsAroundEvents(timeWindow, 
%      timeWindowUnit, ies, excludeTimeWindow, xes, allowOverlap)
%
%     idxMat: indices matching criteria ; each row has a size specified by timeWindow.
%       Note that data falling OUTSIDE of timeWindow will have idx=nan.
%     timeMat: the corresponding times, in case you need em.  Data outside of 
%       timeWindow will have nan's.
%     timeVec: reference time vector for each row of timeMat ; 0 of timeVec is 
%       event time.  This may differ from what you expect because if nan's are
%       found in ALL trials, they are trimmed.  Time unit will be same
%       timeWindowUnit.
%
%     timeWindow - 0 is time of event ; so [-5 5] would show +/- 5 time units
%     timeWindowUnit - in s ; 0 is time of event ; so [-5 5] would show +/- 5 secionds 
%     ies - event series around which windows are built
%     excludedTimeWindow - as with timeWindow (uses same units), but any time and 
%       INCLUDED event is within excludedTimeWindow of an excluded event, that 
%       included event is removed
%     xes - event series which must not appear in window or window is not included
%     allowOverlap - if 0, events are taken as they come, and each timeWindow
%                    will only have 1 event ; default 0 -- applies to INCLUDED events
%  
function [idxMat timeMat timeVec ieIdxVec] = getIndexWindowsAroundEvents(obj, timeWindow, timeWindowUnit, ies, ...
	excludeTimeWindow, xes, allowOverlap)

	% arguments ...
	if (nargin < 4) ; disp('getIndexWindowAroundEvents::insufficient arguments.'); return ; end
	if (nargin < 5) ; excludeTimeWindow = []; end
	if (nargin < 6) ; xes= []; end
	if (nargin < 7) ; allowOverlap = 0; end

	% build ies
	if (~iscell(ies)) ; ies = {ies} ; end
	iets = [];
	for i=1:length(ies)
		iets = [iets ies{i}.eventTimes];
	end

	% build xes
	xestu = ies{1}.timeUnit;
	xets = [];
	if (length(xes) > 0)
		if (~iscell(xes)) ; xes = {xes} ; end
		xestu = xes{1}.timeUnitl
		for x=1:length(xes)
			xets = [xets xes{x}.eventTimes];
		end
	end

	[idxMat timeMat, timeVec ieIdxVec] = session.timeSeries.getIndexWindowsAroundEventsS(obj.time, obj.timeUnit, ...
		 timeWindow, timeWindowUnit, iets, ies{1}.timeUnit, excludeTimeWindow, xets, xestu, allowOverlap) ;
