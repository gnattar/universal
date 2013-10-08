%
% This will return a *range* of positions in which a particular whisker is likely
%  to reside based on the position of the present whisker(s).
%
% missingIds and presentIds should, upon intersect, constitute 1:numWhiskers. 
%  If this assumption is violated, this will not work right -- no checks are
%  in place because checking would make this slower.
%
% USAGE:
%
%   positionRange = wt.getPositionRangeForMissingFromPresent(missingIds, presentIds, f)
%
%   missingIds: id(s) of missing whiskers ; 1:numWhiskers only.
%   presentIds: id(s) of present whiskers ; 1:numWhiskers only.
%   f: frame at which the range is estimated
%
%   positionRange: len(missing)+len(present)x3 matrix, where column 1 is whisker 
%                  id, and 2 and 3 represent the bounds on that whisker
%                  Note that ALL ids are returned, not just missing.
%
function positionRange = getPositionRangeForMissingFromPresent (obj, missingIds, presentIds, f)
  positionRange = zeros([length(presentIds) + length(missingIds)],3);
	minDp = 10; % applied to first and last whisker as range -- will add/subtract @ least this from the guessed position
	            %  important for whiskers that clump
 
	% for each missing ID, compute consensus position
	mp = nan*missingIds;
	for m=1:length(missingIds)
	  mp(m) = obj.getConsensusPositionForMissingFromPresent(missingIds(m),presentIds,f);
	end


  % construct id composite
  if (size(missingIds,1) > 1) ; missingIds = missingIds' ; end
  if (size(presentIds,1) > 1) ; presentIds = presentIds' ; end
	allIds = sort([missingIds presentIds]);
	p = nan*allIds;
	for a=1:length(allIds)
	  mi = find(missingIds == allIds(a));
		if (length(mi) > 0) % this is missing
		  p(a) = mp(mi);
		else % present - so just grab position
		  p(a) = obj.getWhiskerPosition(allIds(a),f); 
		end
	end

	% bound additions
	dp2 = floor(abs(diff(p)/2));
	
	% assign bounds, depending on order . . .
	if (obj.positionDirection == 1) % L to R
		positionRange(1,:) = [allIds(1) max(0,p(1)-max(minDp,dp2(1))) p(1)+dp2(1)];
	  for a=2:length(allIds)-1
		  positionRange(a,:) = [allIds(a) p(a)-dp2(a-1) p(a)+dp2(a)];
		end
		positionRange(a+1,:) = [allIds(a+1)  p(a+1)-dp2(a) p(a+1)+max(dp2(a), minDp)];
	elseif (obj.positionDirection == -1) % R to L
		positionRange(1,:) = [allIds(1)  p(1)-dp2(1) p(1)+max(minDp,dp2(1))];
	  for a=2:length(allIds)-1
		  positionRange(a,:) = [allIds(a) p(a)-dp2(a) p(a)+dp2(a-1)];
		end
		positionRange(a+1,:) = [allIds(a+1) max(0,p(a+1)-max(minDp,dp2(a))) p(a+1)+dp2(a)];
  end

