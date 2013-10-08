%
% SP May 2011
%
% For an event series with just eventTimes (or times & trial#s), given a matrix
%  specifying trial #, trial start and end times, it will assign eventTrials
%  and eventTimesRelTrialStart.
%
% USAGE:
%
%   es.updateEventSeriesFromTrialTimes(trialTimes)
%
% PARAMS:
%
%   trialTimes: matrix, where trialTimes(:,1) is trial #, (:,2) is trial start
%               time and (:,3) is trial end time.  Assumption is that you've 
%               made time unit of this matrix same as es.timeUnit.
%
% EXAMPLE:
%
%   In context of session, you can invoke the following to align with session's
%     behavioral data:
%
%    es.updateEventSeriesFromTrialTimes(s.behavESA.trialTimes);
%
function obj = updateEventSeriesFromTrialTimes(obj,trialTimes)
  % --- arg check
	if (nargin < 2); help('session.eventSeries.updateEventSeriesFromTrialTimes'); return ;end

  % --- meat
	nFailures = 0;

	% loop thru events, assigning each a trial
	for e=1:length(obj.eventTimes)
		tidx = find(trialTimes(:,2) <= obj.eventTimes(e) & trialTimes(:,3) >= obj.eventTimes(e));
		if (length(tidx) == 1) 
			obj.eventTrials(e) = trialTimes(tidx,1);
		else
			obj.eventTrials(e) = -1;
			nFailures = nFailures+1;
		end
	end
	if (nFailures > 0)
		disp(['updateEventSeriesFromTrialTimes::encountered ' num2str(nFailures) ' failures (could not find event trial) for ' obj.idStr]);
	end

	% start tiem rel trial start
	obj.generateStartTimeRelTimes(trialTimes(:,2), trialTimes(:,1));

