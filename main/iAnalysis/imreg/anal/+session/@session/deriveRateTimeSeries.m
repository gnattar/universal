%
% SP Dec 2010
%
% This will call eventSereis.deriveRateTimeSeries for the passed eventSeries object
%  over the specified trials.
%
% USAGE:
%		ts = deriveRateTimeSeries(obj, es, trials)
%
%    es: the eventSeries to do this to
%    trials: trials to go w/
%    
%    ts: returned timeSeries object
%
function ts = deriveRateTimeSeries(obj, es, trials)
  % --- sanity
	if (nargin < 2)
	  disp('deriveRateTimeSeries::must specify at least eventSeries & convolution kernel.');
		return;
	end
	if (nargin < 3) % all (valid) trials
	  trials = [];
	end	
	if (length(trials) == 0)
	  trials = obj.validTrialIds;
	end

  % build time vector
	ntp = 0;
	for t=1:length(trials)
	  ti = find(obj.trialIds == trials(t));
    if (length(ti) > 0)
		  % derive start/end time from obj.behavESA.trialTimes
	  	trialBounds = round(obj.behavESA.trialTimes(ti,2:3));

			% assume MS(!)
			if (diff(trialBounds) > 0)
				ntp = ntp + abs(diff(trialBounds))+1;
			end
		end
	end
	tvec = zeros(ntp,1);
	tvi = 1;
	for t=1:length(trials)
	  ti = find(obj.trialIds == trials(t));
    if (length(ti) > 0)
		  % derive start/end time from obj.behavESA.trialTimes
	  	trialBounds = round(obj.behavESA.trialTimes(ti,2:3));
	  	L = diff(trialBounds);
    
		  if (L > 0)
				tvec(tvi:tvi+L) = trialBounds(1):trialBounds(2);
				tvi = tvi+L+1;
			end
		end
	end

  % generate timeseries
  ts = es.deriveRateTimeSeries(tvec);
