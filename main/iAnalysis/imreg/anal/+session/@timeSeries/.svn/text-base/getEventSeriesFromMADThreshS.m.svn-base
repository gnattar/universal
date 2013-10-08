%
% S Peron Feb 2011
%
% Returns event series based on an MAD threshold applied to a time series object.
%
% USAGE:
%  
%   es = session.timeSeries.getEventSeriesFromMADThreshS (ts, thresh, options)
%
%   ts: timeSeries object to operate on
%   thresh: Threshold ; 2 element vector (- and +) with scalings of 1.4826*MAD ; 
%     set to nan to only use one side (e.g., [-2 nan] would only accept BELOW
%     -2*1.4826*MAD while [nan 2] would accept ABOVE 2 SDs).
%
%   options: 
%     trialIndices: if specified, you will actually get trial #s in event series(!).  
%       This is the trialIndices vector corresponding to ts.values/ts.time.
%     trialIds: allows you to map from trialId to trial index
%     trialStartTimes: time for each trial's start
%     trialStartOffsetWindow: window in time from trial start (0) to consider
%     trialStartOffsetWindowTimeUnit: time unit for above ; default = 2 (seconds)
%
function es = getEventSeriesFromMADThreshS(ts, thresh, options)
  % --- params check
	if (nargin < 2)
	  help session.timeSeries.getEventSeriesFromMADThreshS;
	  return;
	end

	% options process
	trialIndices = [];
	trialIds = [];
	trialStartTimes = [];
	trialStartOffsetWindow = [];
  
	trialStartOffsetWindowTimeUnit = 2;
	if (nargin >= 3)
	  if (isstruct(options))
		  if (isfield(options, 'trialIndices')) ; trialIndices = options.trialIndices ; end
		  if (isfield(options, 'trialIds')) ; trialIds = options.trialIds ; end
		  if (isfield(options, 'trialStartTimes')) ; trialStartTimes = options.trialStartTimes; end
		  if (isfield(options, 'trialStartOffsetWindow')) ; trialStartOffsetWindow = options.trialStartOffsetWindow; end
		  if (isfield(options, 'trialStartOffsetWindowTimeUnit')) ; trialStartOffsetWindowTimeUnit = options.trialStartOffsetWindowTimeUnit; end
		end
	end

  % setup
	valVec = ts.value;
	timeVec = ts.time;

	% --- get the events
	sd = 1.4826*mad(valVec);
	valids = [];
  if (~isnan(thresh(1))) ; valids = find(valVec > thresh(2)*sd) ; end
  if (~isnan(thresh(2))) ; valids = [valids find(valVec < thresh(1)*sd)] ; end

	% limit to starts
	valids = unique(valids);
	dvalids = diff(valids);
	valids = [valids(1) valids(find(dvalids > 1) +1)];

	% build ES
	if (length(trialIndices) == length(ts.value))
		es = session.eventSeries(timeVec(valids), trialIndices(valids), ts.timeUnit);
	else
		es = session.eventSeries(timeVec(valids), [], ts.timeUnit);
	end

  % --- limit by trialStartOffsetWindow if requested
	if (length(trialStartOffsetWindow) == 2 && length(trialStartTimes) > 0 && length(trialIndices) == length(ts.value) && length(trialIds) > 0)
	  tsow = session.timeSeries.convertTime(trialStartOffsetWindow, trialStartOffsetWindowTimeUnit, ts.timeUnit);
    es.generateStartTimeRelTimes(trialStartTimes, trialIds);

    valid = ones(1,length(es.eventTimes));
		for e=1:length(es.eventTimesRelTrialStart)
		  if (es.eventTimesRelTrialStart(e) < tsow(1) | es.eventTimesRelTrialStart(e) > tsow(2))
			  valid(e) = 0;
			end
		end
	  es = session.eventSeries(es.eventTimes(find(valid)), es.eventTrials(find(valid)), ts.timeUnit);
    es.generateStartTimeRelTimes(trialStartTimes, trialIds);
  end
