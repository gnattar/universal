%
% SP JAn 2011
%
% Converts data/time vectors to a matrix where each row is a trial, based on
%  indexing vector trialIds
%
% USAGE:
%
%   [timeMat valueMat timeVec] = getTrialMatrix(time, value, trialIndices, trialIds, 
%                                       trialStartTimes, keepNanCols)
%
%    timeMat, valueMat: each row is a single trial ; row r is trial trialIds(r)
%    timeVec: if you include trialStartTimes, it will return a timeVec for you
%             where 0 is trialStart; in obj.timeUnit.
%    
%    time, value: the data and its time vector
%    trialIndices: same size as above 2, but with trial # of each datapoint
%    trialIds: which trials to pull out and in which order
%    trialStartTimes: same size as trialIds.  If you pass this, it will align
%                     the matrix so that the first column is trial start time
%                     and so on
%    keepNanCols: default is 0 if not passed; set 1 and it will keep nan cols
%                 when using trialStartTimes
%
function [timeMat valueMat timeVec] = getTrialMatrix(time, value, trialIndices, trialIds, trialStartTimes, keepNanCols)
  timeMat = [];
	valueMat = [];
	timeVec = [];

  % --- arguments
	if (nargin < 4)
	  help session.timeSeries.getTrialMatrix;
	  return;
	end

	if (nargin < 5) ; trialStartTimes = []; end
	if (nargin < 6) ; keepNanCols = 0 ; end
	if (length(trialStartTimes) > 0 & length(trialIds) ~= length(trialStartTimes))
	  disp('getTrialMatrix::to use trialStartTimes, must pass corresponding vector trialIds.');
		return;
	end

	% --- generate
  if (length(trialIds) > length(find(ismember(trialIds, trialIndices))));
    valTrialIdIdx = find(ismember(trialIds, trialIndices));
    trialIds = trialIds(valTrialIdIdx);
    trialStartTimes= trialStartTimes(valTrialIdIdx);
  end
	if (length(trialStartTimes) == 0) % easy but crappy
		% how many time points?
		ntp = 0*trialIds;
		for t=1:length(trialIds)
			ti = trialIds(t);
			ntp(t) = length(find(trialIndices == ti));
		end
		nonZero = find(ntp > 0);
		if (length(nonZero) > 1)
			ntp = ntp(nonZero);
		end
		sizeTime = mode(ntp);

		% prebuild matrix
		timeMat = nan*zeros(length(trialIds), sizeTime);
		valueMat = nan*zeros(length(trialIds), sizeTime);

		% populate
		for t=1:length(trialIds)
			ti = trialIds(t);
			tidx = find(trialIndices == ti);
			if (length(tidx) > 0)
				L = min(sizeTime, length(tidx));
				timeMat(t,1:L) = time(tidx(1:L));
				valueMat(t,1:L) = value(tidx(1:L));
			end
		end
  else % align to trial start ...
	  dt = mode(diff(time));
%		if (length(find(abs(diff(time)) > 1.0001*dt)) > 0.05*length(time))
%		  disp('getTrialMatrix::this method assumes dt is FIXED; at least 5% of your dt values are NOT same as modal dt.  Use at your own risk!');
%		end
    for t=1:length(trialIds)
		  ti = trialIds(t);
			tidx = find(trialIndices == ti);
			ntp(t) = ceil((max(time(tidx))-trialStartTimes(t))/dt);
		end
		sizeTime = mode(ntp);

		% prebuild matrix
		timeMat = nan*zeros(length(trialIds), sizeTime);
		valueMat = nan*zeros(length(trialIds), sizeTime);
		timeVec = 0:dt:(sizeTime-1)*dt;

		% populate, assuming fixed dt, with relevant poitns
		for t=1:length(trialIds);
			ti = trialIds(t);
			tidx = find(trialIndices == ti);

			if (length(tidx) > 0)
				% time rel trial start, and round it to nearest dt
				timeRelTrialStart = time(tidx) - trialStartTimes(t);
				timeRelTrialStart = round(timeRelTrialStart/dt)*dt;

				% dupe kill
				[timeRelTrialStart ui] = unique(timeRelTrialStart);
        tidx=tidx(ui);

				% determine which values we are interested in ...
				valTidx = find(ismember(timeRelTrialStart,timeVec));
				tvecFound = find(ismember(timeVec,timeRelTrialStart(valTidx)));

				timeMat(t,tvecFound) = time(tidx(valTidx));
				valueMat(t,tvecFound) = value(tidx(valTidx));
			end
		end

		% clear empty columns
		if (~keepNanCols)
			N = size(valueMat,1);
			keep = ones(1,size(valueMat,2));
			for c=1:size(valueMat,2)
				if(length(find(isnan(valueMat(:,c)))) == N)
					keep(c) = 0;
				end
			end
			timeMat = timeMat(:,find(keep));
			valueMat = valueMat(:,find(keep));
			timeVec = timeVec(find(keep));
		end
  end
