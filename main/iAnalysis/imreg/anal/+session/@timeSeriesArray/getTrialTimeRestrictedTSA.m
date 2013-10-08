%
% SP Mar 2011
%
% Generates a subset of this TSA for timepoints confined to timeRange, where 
%   timeRange is relative trial start.
%
% USAGE:
%
%   newTSA = tsa.getTrialTimeRestrictedTSA(trialStartTimes, trialIds, timeRange, timeRangeUnit)
%
% PARAMS:
%
%    trialStartTimes: a vector of trial start times -- make sure it has same 
%                     timeUnit as tsa.time.
%    trialIds: vector corresponding to trialStartTimes where trialStartTimes(x)
%              is the start time for trialIds(x)
%    timeRange: the time range of points to include, where 0 is trial start
%    timeRangeUnit ; default is seconds (2)
%
function newTSA = getTrialTimeRestrictedTSA(obj, trialStartTimes, trialIds, timeRange, timeRangeUnit)
  % --- argument check
	if (nargin < 4)
	  help session.timeSeriesArray.getTrialTimeRestrictedTSA;
	  disp('getTrialTimeRestrictedTSA::must provide at least first 3 parameters.');
		return
	end
  if (nargin < 5 || isempty(timeRangeUnit))
	  timeRangeUnit = 2;
	end

  % we want timeRange in this object's units
	timeRange = session.timeSeries.convertTime(timeRange, timeRangeUnit, obj.timeUnit);

	% --- the ditty
  timeRelTrialStart = obj.getTimeRelTrialStart(trialStartTimes, trialIds);

	val = find (timeRelTrialStart >= timeRange(1) & timeRelTrialStart <= timeRange(2));
  newValueMatrix = obj.valueMatrix(:,val);
	newTime = obj.time(val);
	newTrialIndices = obj.trialIndices(val);

	% --- build returned object
  newTSA= session.timeSeriesArray({}, newTrialIndices, obj.ids, obj.idStrs, newTime, ...
		  obj.timeUnit, newValueMatrix, 1);


