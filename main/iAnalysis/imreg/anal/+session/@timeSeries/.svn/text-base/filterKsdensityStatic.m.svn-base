%
% SP Feb 2011
%
% Applies a slidnig Ksdensity filter.  That is, it moves along the passed timeSeries,
%  in steps of dt, and takes all values within timeWindow, then computes the ksdensity
%  peak at that time point.  Values not touched due to dt are interpolated linearly.
%
%  Basically this is a sliding mode filter.
%
% USAGE:
%
%		newValue = filterKsdensityStatic(time, value, timeWindow, dt)
%
%     newValue: new value vector
%     time, value: time and value of timeSeries; if time is blank, assumed to 
%       be 1:length(value) and dt must be in units of index.
%     timeWindow: how large is timeWindow, in same units as time.
%     dt: again, same units as time, how large of a step should you compute?
%
function newValue = filterKsdensityStatic(time, value, timeWindow, dt)
  newValue = [];

  % --- input checks and processing
	if (nargin < 4) 
	  disp('filterKsdensityStatic requires 4 arguments');
		help session.timeSeries.filterKsdensityStatic;
		return;
	end


  % --- prelims

	% blank time?
	if (length(time) == 0)
	  time = 1:length(value);
	end

	% convert dt to index step size
	dataDt = mode(diff(time));
	didx = ceil(dt/dataDt);

	% convert timeWindow to index
	twidx = ceil(timeWindow/dataDt);
	tw2 = timeWindow/2;

	% --- get ditty

	% compile the vectors of timepoints visited
	visitedTimes = min(time)+tw2:dt:max(time)-tw2;
	preInterpValueVec = nan*visitedTimes;
	windowCenterIdx = nan*visitedTimes;
	windowValues = nan*visitedTimes;
  for t=1:length(visitedTimes)
	  % time points in window -- are there any?
	  inWindow = find (time > visitedTimes(t)-tw2 & time < visitedTimes(t)+tw2);
    inWindow = inWindow(find(~isnan(value(inWindow))));
		if (~isempty(inWindow))
      % store windowCenterIdx -- this will be for interp later
			[irr wci(1)] = min(abs(time-visitedTimes(t)));
			windowCenterIdx(t) = wci(1);

      % and calculate
      [pdf, v] = ksdensity(value(inWindow));
			[irr idx] = max(pdf);
      windowValues(t) = v(idx);
		end
	end

	% start & end
  windowCenterIdx = [1 windowCenterIdx length(time)];
  windowValues = [nan windowValues nan];

	inWindow = find (time >= time(1) & time < time(1) + tw2);
	inWindow = inWindow(find(~isnan(value(inWindow))));
  if (~isempty(inWindow))
	  [pdf, v] = ksdensity(value(inWindow));
    [irr idx] = max(pdf);
    windowValues(1) = v(idx);
  end

	inWindow = find (time > time(end)-tw2 & time <= time(end));
	inWindow = inWindow(find(~isnan(value(inWindow))));
  if (~isempty(inWindow))
    [pdf, v] = ksdensity(value(inWindow));
    [irr idx] = max(pdf);
    windowValues(end) = v(idx);
  end

	% interpolate for remaining points
	vwi = find(~isnan(windowCenterIdx) & ~isnan(windowValues));
	knownIdx = windowCenterIdx(vwi);
  newValue = interp1(time(knownIdx), windowValues(vwi), time, 'linear');

	% size check
	if (size(newValue,1) ~= size(value,1)) ; newValue = newValue'; end


  
