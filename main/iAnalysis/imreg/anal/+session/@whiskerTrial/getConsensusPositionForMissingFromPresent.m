%
% Gives consensus position from last time missingId overlapped with the presentIds
%  at the last frame where any pairing of missing-present overlapped.  
%  consensusPosition is at frame f, adjusting for shifts in present Ids.
%
% USAGE:
% 
%  consensusPosition = wt.getConsensusPositionForMissingFromPresent (missingId, presentIds, f)
%  
%    missingId: id of missing whisker -- has to be one of the numWhiskers whiskers
%    presentIds: Ids of PRESENT whiskers ; again, only 1:numWhiskers
%    f: frame at which to get guessed position
%   
function consensusPosition = getConsensusPositionForMissingFromPresent (obj, missingId, presentIds, f)
	consensusPosition = nan;

  % loop thru present Ids 
	mp_f = nan*presentIds;
	pp_f = obj.getWhiskerPosition(presentIds, f);
	for p=1:length(presentIds)
    % find most recent overlap 
    olf = obj.getMostRecentOverlapFrame (missingId, presentIds(p), f);
	  
		% possible?
		if (olf > 0)
		  p_olf = obj.getWhiskerPosition([presentIds(p) missingId], olf);
      mp_f(p) = p_olf(2) + pp_f(p) - p_olf(1);  
		end
	end

  % consensus based on nanmean
	consensusPosition = nanmean(mp_f);
