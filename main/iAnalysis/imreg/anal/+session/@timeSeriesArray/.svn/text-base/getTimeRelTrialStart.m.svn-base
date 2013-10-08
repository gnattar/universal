%
% SP Mar 2011
%
% Gets trial tiem relative trial start (which is 0)
%
% USAGE:
%
%   timeRelTrialStart = tsa.getTimeRelTrialStart(trialStartTimes, trialIds)
%
% PARAMS:
%
%    timeRelTrialStart: times in unit tsa.timeUnit where 0 is start time of trial
%                       and all other times are given relative that.  
%
%    trialStartTimes: a vector of trial start times -- make sure it has same 
%                     timeUnit as tsa!
%    trialIds: vector corresponding to trialStartTimes where trialStartTimes(x)
%              is the start time for trialIds(x)
%
function timeRelTrialStart = getTimeRelTrialStart(obj, trialStartTimes, trialIds)
  timeRelTrialStart = [];

	% --- inputs
	if (nargin < 3)
	  help session.timeSeriesArray.getTimeRelTrialStart;
		return;
	end

	% --- do it
	timeRelTrialStart = nan*obj.time;
	for t=1:length(trialIds)
	  ti = find(obj.trialIndices == trialIds(t));
		if (length(ti) > 0)
		  timeRelTrialStart(ti) = obj.time(ti) - trialStartTimes(t);
		end
	end
	  
