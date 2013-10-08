%
% returns a matrix with timeseries values for selected trial(s)
%
% USAGE:
%
%   [valMat trialVec timeVec] = getValuesByTrialIndices(trialIndices, tsIds) 
%
% PARAMETERS:
%
%   trialIndices: vector with all trials you want ; blank means all
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
function [valMat trialVec timeVec] = getValuesByTrialIndices(obj, trialIndices, tsIds) 
	valMat = [];
	timeVec = [];
	trialVec = [];

	% blank handling
	if (nargin == 1)
		tsIds = obj.ids;
		trialIndices = obj.trialIndices;
	elseif(nargin == 2)
		tsIds = obj.ids;
		if (length(trialIndices) == 0)
			trialIndices = obj.trialIndices;
		end
	else
		if (length(tsIds) == 0)
			tsIds = obj.ids;
		end
		if (length(trialIndices) == 0)
			trialIndices = obj.trialIndices;
		end
	end

	% find indices to use by obj.trialIndices
	vals = zeros(1,length(obj.trialIndices));
	for t=1:length(trialIndices);
		vals(find(obj.trialIndices == trialIndices(t))) = 1;
	end
	usedIdx = find(vals);

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

