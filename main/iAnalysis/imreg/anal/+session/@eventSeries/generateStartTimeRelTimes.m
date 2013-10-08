%
% SP Dec 2010
%
% This will populate eventTimesRelTrialStart, to optimize speed.
%
% USAGE:
%
%  s.generateStartTimeRelTimes(startTimes, trialIndices)
%
function obj = generateStartTimeRelTimes(obj, startTimes, trialIndices)
  % --- sanity
	if (nargin < 3)
	  disp('generateStartTimeRelTimes::must provide trial start times, indices');
		return;
  end

	% --- loop
	obj.eventTimesRelTrialStart = nan*obj.eventTimes;
	for t=1:length(trialIndices)
	  idx = find(obj.eventTrials == trialIndices(t));
		if (length(idx) > 0)
      obj.eventTimesRelTrialStart(idx) = obj.eventTimes(idx)-startTimes(t);
		end
	end
