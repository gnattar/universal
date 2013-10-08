%
% Returns most recent overlap frame derived from framesPresent for two Ids; 
%  obeys correctionTemporalDirection.  Assumes framesPresent is updated.
%
% USAGE:
%   olf =  wt.getMostRecentOverlapFrame (id1, id2, f)
%
%  id1, id2: whisker Ids to look at ; must be <= numWhiskers
%  f: frame from which to start looking
%  olf: most recent overlap frame -- INCLUDING f ; nan = none
function olf = getMostRecentOverlapFrame (obj, id1, id2, f)
  olf = nan; % default
  overlapFrames = find (obj.framesPresent(id1,:) & obj.framesPresent (id2,:));

  if (length(overlapFrames) > 0)
		if (obj.correctionTemporalDirection == 1) % look for frames <= f
			overlapFrames = overlapFrames(find(overlapFrames <= f));
			if (length(overlapFrames) > 0)
				olf = max(overlapFrames);
			end
		else % look for frames >= f
			overlapFrames = overlapFrames(find(overlapFrames >= f));
			if (length(overlapFrames) > 0)
				olf = min(overlapFrames);
			end
		end
	end
  

