%
% This will return a *range* of positions in which a particular whisker is likely
%  to reside based on the interpolation of whisker trajectories.
%
% missingIds and presentIds should, upon intersect, constitute 1:numWhiskers. 
%  If this assumption is violated, this will not work right -- no checks are
%  in place because checking would make this slower.
%
% USAGE:
%
%   [expectedPosition positionRange] = 
%          wt.getPositionRangeForMissingFromInterp(missingIds, presentIds, f)
%
%   missingIds: id(s) of missing whiskers ; 1:numWhiskers only.
%   presentIds: id(s) of present whiskers ; 1:numWhiskers only.
%   f: frame at which the range is estimated
%
%   expectedPosition: the exact position that is expected for each whisker
%   positionRange: len(missing)+len(present)x3 matrix, where column 1 is whisker 
%                  id, and 2 and 3 represent the bounds on that whisker
%                  Note that ALL ids are returned, not just missing.
%
function [expectedPosition positionRange] = getPositionRangeForMissingFromInterp (obj, missingIds, presentIds, f)
  positionRange = zeros([length(presentIds) + length(missingIds)],3);
	minDp = 10; % applied to first and last whisker as range -- will add/subtract @ least this from the guessed position
	            %  important for whiskers that clump
 
	% for each missing ID, compute consensus position
	expectedPosition = nan*missingIds;
	nfb = max(5,min(f-1,20)); % number of frames back in time -- ideally 20, at least 5
% NO!! USE MEAN MOTION TO EXTRACT, ESPECIALLY IF THE TIMING DIFFERENCE IS GREATER IN THE FUTURE [obey temporal direction]
	for m=1:length(missingIds)	  
	  expectedPosition(m) = obj.predictPositionFromInterp(missingIds(m), nfb, f, 'pchip', nfb);
	end

  % construct id composite
  if (size(missingIds,1) > 1) ; missingIds = missingIds' ; end
  if (size(presentIds,1) > 1) ; presentIds = presentIds' ; end
	allIds = sort([missingIds presentIds]);
	p = nan*allIds;
	for a=1:length(allIds)
	  mi = find(missingIds == allIds(a));
		if (length(mi) > 0) % this is missing
		  p(a) = expectedPosition(mi);
		else % present - so just grab position
		  p(a) = obj.getWhiskerPosition(allIds(a),f); 
		end
	end

	% bound additions
	dp2 = floor(abs(diff(p)/2));
	if (obj.numWhiskers < 2) ; dp2 = minDp ; end
	
	% assign bounds, depending on order . . .
	if (obj.positionDirection == 1) % L to R
		positionRange(1,:) = [allIds(1) max(0,p(1)-max(minDp,dp2(1))) p(1)+dp2(1)];
	  for a=2:length(allIds)-1
		  positionRange(a,:) = [allIds(a) p(a)-dp2(a-1) p(a)+dp2(a)];
		end
		if (obj.numWhiskers >= 2) ; positionRange(a+1,:) = [allIds(a+1)  p(a+1)-dp2(a) p(a+1)+max(dp2(a), minDp)]; end
	elseif (obj.positionDirection == -1) % R to L
		positionRange(1,:) = [allIds(1)  p(1)-dp2(1) p(1)+max(minDp,dp2(1))];
	  for a=2:length(allIds)-1
		  positionRange(a,:) = [allIds(a) p(a)-dp2(a) p(a)+dp2(a-1)];
		end
		if (obj.numWhiskers >= 2) ; positionRange(a+1,:) = [allIds(a+1) max(0,p(a+1)-max(minDp,dp2(a))) p(a+1)+dp2(a)]; end
  end


