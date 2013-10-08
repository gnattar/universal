%
% returns a matrix with timeseries values for selected time range
%
% USAGE:
%
%   [valMat trialVec timeVec] = getValuesByTime(timeRange, tsIds) 
%
% PARAMETERS:
%
%   timeRange: [a b]: inclusive, get from time point a to b; blank: get all
%   tsIds: time series ID, within this timeSeriesArray, of time series you want  
%          blank means all
%
% RETURNS:
% 
%  valMat: matrix where valMat(x,:) is values for ids(x).  Trials are ordered
%          and sorted the way you pass them.
%  trialVec: trial index for valMat(:,y) is trialVec(y)
%  timeVec: time value for valMat(:,y) is timeVec(y) (if not assigned in this
%           timeSeries, will be returned empty)
%    
%
function [valMat trialVec timeVec] = getValuesByTime(obj, timeRange, tsIds) 
	valMat = [];
	timeVec = [];
	trialVec = [];

	% -- sanity check
	if (length(obj.time) == 0)
		disp('timeSeriesArray::getValuesByTime: time vector is NOT populated.  Aborting.');
		return;
	end

	% blank handling
	if (nargin == 1)
		tsIds = obj.ids;
		timeRange = [min(obj.time) max(obj.time)];
	elseif(nargin == 2)
		tsIds = obj.ids;
		if (length(timeRange) == 0)
			timeRange = [min(obj.time) max(obj.time)];
		end
	else
		if (length(tsIds) == 0)
			tsIds = obj.ids;
		end
		if (length(timeRange) == 0)
			timeRange = [min(obj.time) max(obj.time)];
		end
	end

	% find indices to use by time range
	vals = zeros(1,length(obj.trialIndices));
	usedIdx = find (obj.time >= timeRange(1) & obj.time  <= timeRange(2));

	% populate returned vectors (time, trial #)
	trialVec = obj.trialIndices(usedIdx);
	timeVec = obj.time(usedIdx);

	% populate returned value matrix
	valMat = zeros(length(tsIds), length(timeVec));
	for t=1:length(tsIds);
		vmi = find(obj.ids == tsIds(t));
		valMat(t,:) = obj.valueMatrix(vmi, usedIdx);
	end
end

