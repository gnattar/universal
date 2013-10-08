%
% Merge another timeSeriesArray to the calling object.
%
% USAGE:
%
%   tsa.mergeWith(nTSA)
%
% ARGUMENTS:
%
%  nTSA: the new timeSeriesArray you wanna hitch to obj
%
function obj = mergeWith(obj, nObj)
	%% --- sanity checks 
	if (obj.timeUnit ~= nObj.timeUnit)
		error('timeSeriesArray.mergeWith::must be same timeUnit to merge.');
	end

	%% --- preprocess
	[irr keptIdx] = setdiff(nObj.time, obj.time);

  % you will also need the valueMatrix map (i.e., id to id map, in case not same )
  idMap = zeros(1,nObj.length);
  for ni=1:nObj.length
    oi = find(obj.ids == nObj.ids(ni));
    idMap(ni) = oi;
	end


	%% --- go
	obj.time = [obj.time nObj.time(keptIdx)];
	obj.trialIndices = [obj.trialIndices nObj.trialIndices(keptIdx)];
	i1 = size(obj.valueMatrix,2)+1;
	i2 = length(keptIdx) + i1 - 1;
  obj.valueMatrix(:,i1:i2) = nan*zeros(obj.length, length(keptIdx));
	obj.valueMatrix(idMap,i1:i2) = nObj.valueMatrix(:,keptIdx);

	obj.sortByTime(); % let him do the dirty work!

