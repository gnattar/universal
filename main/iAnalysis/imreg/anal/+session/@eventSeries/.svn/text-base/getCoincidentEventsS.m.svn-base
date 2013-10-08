%
% SP May 2011
%
% Will return an eventSeries that has events at times after which groups of
%  events occured together.  Only START times are considered.
%
%  USAGE:
%  
%    	es = getCoincidentEventsS(ies, coincidentDtMax, allowOverlap,
%              returnedTimeUnit, xes, xTimeWindow, timeUnit, returnType) 
%
% PARAMS:
%
%    es: returned eventSeries with either starts or starts and ends (depends on
%        returnType) of coincident epochs.
%
%    ies: event series that are to overlap ; cell array
%    coincidentDtMax: How much can the first and last events of the set be
%                     spaced by AT MOST?  In timeUnit unit.
%    allowOverlap: can epochs of coincidence overlap? Default NO.
%    returnedTimeUnit: default is ms (1)
%    xes: optional, if events from xes occur within a coincident window, then
%         that coincidence is not added to es.  xes is a cell array.
%    xTimeWindow: time window over which exclusion for xes is applied.
%    timeUnit: unit for time windows ; default seconds
%    returnType: what will the eventSeries.type variable be? 1 means instant
%                events, 2 means events with a start and an end.  Default is
%                to use the same type as the majority of ies (or pass 0 to 
%                force this behavior).
%
function es = getCoincidentEventsS(ies, coincidentDtMax, allowOverlap,  ...
                     returnedTimeUnit, xes, xTimeWindow, timeUnit, returnType) 

  % --- parse inputs
  if (nargin < 2) 
	  help('session.eventSeries.getCoincidentEventsS');
	  disp('getCoincidentEventsS::must specify at least first 2 parameters.');
		return;
	end

	if (nargin < 3 || length(allowOverlap) == 0) ; allowOverlap = 0 ; end
	if (nargin < 4 || length(returnedTimeUnit) == 0) ; returnedTimeUnit = 1 ; end
	if (nargin < 5 || length(xes) == 0) ; xes = []; end
	if (nargin < 6 || length(xTimeWindow) == 0) ; xTimeWindow = []; end
	if (nargin < 7 || length(timeUnit) == 0) ; timeUnit = 2 ; end
  if (nargin < 8 || length(returnType) == 0) ; returnType = 0; end

	% cell it
	if (~iscell(ies)) ; ies = {ies} ; end
	if (length(xes) > 0 & ~iscell(xes)) ; xes = {xes} ; end

  % time window of 0?
	if (length(coincidentDtMax) == 0) ; coincidentDtMax = 0 ; end

	% return type ...
	if (returnType == 0)
		nt1 = 0;
		nt2 = 0;
		for i=1:length(ies)
			if (ies{i}.type == 1) ; nt1 = nt1+1; else ; nt2 = nt2+1; end
		end
		if (nt2 > nt1) ; returnType = 2;  else ; returnType = 1; end
	end

  % convert time units (all to returnedTimeUnit)
	for i=1:length(ies)
	  ies{i} = ies{i}.copy();
		ies{i}.eventTimes = session.timeSeries.convertTime(ies{i}.eventTimes, ies{i}.timeUnit, returnedTimeUnit);
	end
	for x=1:length(xes)
	  xes{x} = xes{x}.copy();
		xes{x}.eventTimes = session.timeSeries.convertTime(xes{x}.eventTimes, xes{x}.timeUnit, returnedTimeUnit);
	end
	if (length(xTimeWindow) > 0) ; xTimeWindow = session.timeSeries.convertTime(xTimeWindow, timeUnit, returnedTimeUnit); end
	coincidentDtMax = session.timeSeries.convertTime(coincidentDtMax, timeUnit, returnedTimeUnit);

	% --- build up the candidate list

	% start by making a matrix where you have ALL events and their set membership, and it is sorted
	for i=1:length(ies) ; L(i) = length(ies{i}.getStartTimes()) ; end
	evMat = nan*ones(2,sum(L));
	si = 1;
	coList = [];
	for i=1:length(ies)
	  tes = ies{i};
		eTimes = tes.getStartTimes();
    if (length(eTimes) > 0)
      evMat(:,si:si+length(eTimes)-1) = [i*ones(1,L(i)) ; eTimes];
      si = si+length(eTimes);
      coList = [coList ' ' tes.idStr];
    end
	end
  [irr idx] = sort(evMat(2,:));
	evMat = evMat(:,idx);

	% now we simply look for periods of length coincidentDtMax that have all event types
	isValid = 0*size(evMat,2);
	maxValid = 0*size(evMat,2);
	for e=1:length(evMat)-1 
	  si = e;
		dt = evMat(2,si+1:end) - evMat(2,si);
		candi = find(dt <= coincidentDtMax);
		if (length(unique(evMat(1,candi+si))) == length(ies))
		  isValid(e) = 1;
			maxValid(e) = si+max(candi);
		end
	end
	if (isempty(find(isValid))) ; es = [] ; return ; end
	candiStartTimes = evMat(2,find(isValid));
	candiEndTimes = evMat(2,maxValid(find(isValid)));

  % --- remove overlappers
	if (~allowOverlap)
		isValid = ones(1,length(candiStartTimes));

		% find anyone AFTER this who is too close and nuke em
	  for c=1:length(candiStartTimes)-1
		  if (~isValid(c)) ; continue ; end
			dt = candiStartTimes(c+1:end)-candiEndTimes(c);
			invalid = find (dt <= 0);
			if (length(invalid) > 0 ) ; isValid(c+invalid) = 0; end
		end

		% still have candis?
		if (isempty(find(isValid))) ; es = [] ; return ; end
		candiStartTimes = candiStartTimes(find(isValid));
		candiEndTimes = candiEndTimes(find(isValid));
	end
		
	% --- apply exclusions
	excludeTimes = [];
	for x=1:length(xes)
    excludeTimes = [excludeTimes xes{x}.getStartTimes()];
	end
	isValid = ones(1,length(candiStartTimes));
	for c=1:length(candiStartTimes)
	  if (length(find(excludeTimes >= candiStartTimes(c) & excludeTimes <= candiEndTimes(c))) > 0 ) ; isValid(c) = 0 ; end
	end
	if (isempty(find(isValid))) ; es = [] ; return ; end
	candiStartTimes = candiStartTimes(find(isValid));
	candiEndTimes = candiEndTimes(find(isValid));

	eTimes = [0*candiStartTimes 0*candiEndTimes];
	eTimes(1:2:end-1) = candiStartTimes;
	eTimes(2:2:end) = candiEndTimes;

  es = session.eventSeries(eTimes, nan*eTimes, returnedTimeUnit, 1, ...
	       ['Coincidence of' coList], 0, '', 'generated by getCoincidentEventsS', ...
			   [1 0.5 0], returnType);




