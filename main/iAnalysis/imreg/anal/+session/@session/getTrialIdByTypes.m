%
% SP Jan 2011
%
% Returns all trialIds for trials that have specified type(s).  
%
% USAGE:
%
%  trialIds = s.getTrialIdByTypes(types, subsetTrialIds)
%
%    trialIds: vector with trialIds matched
%    
%    types: the types, as in s.trialType - pass one or many
%    subsetTrialIds: if passed, restrict to only these trials (e.g., validTrialIds)
%                    blank means don't use.
%
function trialIds = getTrialIdByTypes(obj, types, subsetTrialIds)
  trialIds  = [];

  % --- arg check
  if (nargin < 2)
    disp('getTrialIdByTypes::Must give types you want.');
	  return;
 	end
	if (nargin < 3) % set subset to everything
	  subsetTrialIds = [];
	end

  % --- get them 
	valid = [];
  for t=1:length(types)
	  ti = find(obj.trialType == types(t));
    valid = union(valid, find(obj.trialTypeMat(ti,:)));
	end

  % mop up
	if (length(valid) > 0)
		trialIds = obj.trialIds(unique(valid));
		if (length(subsetTrialIds) ~= 0)
			trialIds = intersect(trialIds, subsetTrialIds);
		end
	end

