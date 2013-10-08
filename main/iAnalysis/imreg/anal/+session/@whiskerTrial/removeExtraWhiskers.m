%
% This will remove whiskers that are not 1:numWhiskers in frames where all
%  desired whiskers ARE present.  Note that entire chunks are removed.
%  If cleanup is used, ALL non 1:numWhiskers are removed, regardless of 
%  principal presence.
%
% USAGE:
%
%  wt.removeExtraWhiskers(frames, cleanup)
%
%   frames: frame(s) to do this at ; blank means all
%   cleanup: set to 1 if you want to remove all non 1:numWhiskers whiskers
% 
function obj = removeExtraWhiskers(obj, frames, cleanup)
  if (nargin < 2)
	  frames = 1:obj.numFrames;
	end
	if (length(frames) == 0)
	  frames = 1:obj.numFrames;
	end

	if (nargin < 3) 
	  cleanup = 0;
	end
	  

	% construct ...
	desiredWhiskers = 1:obj.numWhiskers;
	for F=1:length(frames)
	  f = frames(F);
	  fpmi = find(obj.positionMatrix(:,1) == f);

		% unique
		uid = unique(obj.positionMatrix(fpmi,2));

    % all whiskers present (or cleanup mode)
		if (cleanup | length(intersect(desiredWhiskers, uid)) == length(desiredWhiskers)) 
			extraIds = setdiff(uid , desiredWhiskers);
			extraIds = extraIds(find(extraIds > 0));
			for e=1:length(extraIds)
				obj.deleteAllWithId (extraIds(e));
			end
		end
	end
