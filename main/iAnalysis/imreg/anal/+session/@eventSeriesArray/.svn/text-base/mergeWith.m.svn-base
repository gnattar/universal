%
% Merge with another ESA
%
% USAGE:
%
%  esa.mergeWith(nESA)
%
% ARGUMENTS:
%
%  nESA: the new eventSeriesArray you want to hitch to calling object
%
function obj = mergeWith (obj, nObj)
  %% --- sanity checks 
	if (length(obj.ids) < length(intersect(obj.ids,nObj.ids)))
		error('eventSeriesArray.mergeWith::the calling object must at least have all ids that added object does.');
	end

  %% --- the work ...

	% loop over eventSeries
	for e=1:length(obj.esa)
		ei = find(nObj.ids == obj.ids(e));
		if (length(ei) > 0)
			obj.esa{e}.mergeWith(nObj.esa{ei});
		end
	end

	% trialTimes
	obj.trialTimes = [obj.trialTimes ; nObj.trialTimes];

