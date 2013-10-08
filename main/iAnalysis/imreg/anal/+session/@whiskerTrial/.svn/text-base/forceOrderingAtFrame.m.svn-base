%
% SP Sept 2010
%
% This will force the proper ordering for 1:numWhiskers based on positionDirection
%  for frame f. If mode 1 is used, it will force the ordering on the AVAILABLE
%  whiskers (id > 0).
%
% USAGE:
%
%   wt.forceOrderingsAtFrame(f, mode)
%
% f: frame at which to force ordering
% mode: 0/not passed: default mode ; uses 1:numWhiskers only; uses
%         swapIds, so works across frames.
%       1: force proper ordering on all available whiskers off of ID.
%          Uses swapIds so is cross-frame.
%       2: force proper ordering on all available whiskers off of Id,
%          with NO swapIds so it is NOT cross frame.
%       3: force proper ordering on all available whiskers off of Id, 
%          and 0 out all but numWhiskers longest whiskers.  Assign ID
%          1:numWhiskers.  Does NOT use swapIDs so not cross-frame.
%       4: same as 3, but uses assignNewId so entire chunks are affected.
%
function obj = forceOrderingAtFrame (obj, f, mode)
  % arguments
	if (nargin < 3)
	  mode = 0;
	end

	% prelims
	fpmi = find(obj.positionMatrix(:,1) == f);

	% one whisker case -- just use longest one (!)
	if (obj.numWhiskers == 1)
	  valIds = obj.positionMatrix(fpmi,2);
		lens = obj.lengthVector(fpmi);
		[slens lidx] = sort(lens,'descend');

	  obj.assignNewId(valIds(lidx(1)),1);
		obj.refreshWhiskerIds();
		return;
	end

  % get desired IDs, depending on mode
	if (mode == 0) % only numWhiskers
	  desiredIds = 1:obj.numWhiskers;
	else % get numWhiskers longest whiskers ...
		desiredIds = obj.positionMatrix(fpmi,2);
		desiredIds = desiredIds(find(desiredIds > 0));
	end

  % get the ordering of this frame 
	thisOrdering = obj.getWhiskerOrdering(f, desiredIds);
	thisOrdering = thisOrdering(find(thisOrdering > 0));

	% check for blank ordering - occurs if no whiskers qualify
	if (length(thisOrdering) == 0) ; return ; end

  % target ordering based on positionDirection
	if (obj.positionDirection == 1) % want increasing
		targetOrdering = sort(thisOrdering, 'ascend');
	else % want decreasing
		targetOrdering = sort(thisOrdering, 'descend');
	end

  if (mode == 0 | mode == 1)
		% check if ordering is messed up in anyway
		if (length(thisOrdering) > 1) % at least 2

			% force proper ordering
			if (sum(thisOrdering == targetOrdering) < length(thisOrdering))
				for w=1:length(thisOrdering)
					obj.swapIds(targetOrdering(w),thisOrdering(w));
					thisOrdering = obj.getWhiskerOrdering(f, 1:obj.numWhiskers);
					thisOrdering = thisOrdering(find(thisOrdering > 0));
				end
			end
		end
	elseif (mode == 2) % only assign locally
	  wi = [];
	  for w=1:length(thisOrdering)
		  wi(w) = find(obj.positionMatrix(fpmi,2) == thisOrdering(w));
		end
	  for w=1:length(thisOrdering)
			obj.positionMatrix(fpmi(1)+wi(w)-1,2) = targetOrdering(w);
		end
	elseif (mode == 3) % assign locally to numWhiskers longest ones
	  % length restriction
	  lens = obj.getWhiskerLength(thisOrdering,f);
		[slens lidx] = sort(lens,'descend');
		N = min(length(slens),obj.numWhiskers);
		val = find(lens >= slens(N));
		if (obj.positionDirection == 1) % want increasing
			targetOrdering = 1:N;
		else % want decreasing
			targetOrdering = N:-1:1;
		end
		thisOrdering = thisOrdering(val(1:N));

		% predetermine assignments
	  wi = [];
	  for w=1:length(thisOrdering)
		  wi(w) = find(obj.positionMatrix(fpmi,2) == thisOrdering(w));
		end

		% zero everyone out
		obj.positionMatrix(fpmi,2) = 0;

		% assign the rest
	  for w=1:length(thisOrdering)
			obj.positionMatrix(fpmi(1)+wi(w)-1,2) = targetOrdering(w);
		end
	elseif (mode == 4) % assign "globally" (assignNewId) to numWhiskers longest ones
	  % safety 1st
		obj.refreshWhiskerIds();

	  % length restriction
	  lens = obj.getWhiskerLength(thisOrdering,f);
		[slens lidx] = sort(lens,'descend');
		N = min(length(slens),obj.numWhiskers);
		val = find(lens >= slens(N));
		if (obj.positionDirection == 1) % want increasing
			targetOrdering = 1:N;
		else % want decreasing
			targetOrdering = N:-1:1;
		end
		thisOrdering = thisOrdering(val(1:N));

		% zero everyone bad
		allIds = unique(obj.positionMatrix(fpmi,2));
		allIds = allIds(find(allIds > 0));
		toZeroIds = setdiff(allIds, thisOrdering);
    for i=1:length(toZeroIds)
		  obj.deleteAllWithId(toZeroIds(i));
		end

		% assign the rest the proper id
		tmpIds = [1:length(thisOrdering)] + max(obj.whiskerIds);
	  for w=1:length(thisOrdering) % assign tmp ids -- this is to avoid prblems due to thisOrdering/targetOrdering overlap
		  obj.assignNewId(thisOrdering(w), tmpIds(w));
		end
	  for w=1:length(thisOrdering) % and the closer
		  obj.assignNewId(tmpIds(w), targetOrdering(w));
		end
		obj.refreshWhiskerIds();
	end 

