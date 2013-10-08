%
% SP Sept 2010
%
% This will return the change(s) in position for the specified whisker(s).
%  Change is returned as *absolute value* as this is supposed to be used in
%  the context of error minimization.
%
% USAGE: 
%   
%   dp = wt.getDeltaPosition(f, whiskerIds)
%
% dp: change in position based on positionMatrix ; whiskers NOT present 
%     returned nan
% f: either a single frame, in which case the other frame considered is
%    inferred from correctionTemporalDirection, or a two-element vector, in 
%    which case the FIRST element is the frame being tested while the SECOND
%    element is the KNOWN frame.
% whiskerIds: the whiskers for which changse are returned ; if none specified
%             (blank or absent) 1:obj.numWhiskers are attempted.  If Inf is
%             specified, it will do all present whiskers in the two frames.
%             If whiskerIds is nx2, it will assume 2nd column is IDs in
%             PREVIOUS/FUTURE frame, while FIRST column is IDs in frame f.
% frameHorizon: default is 1 (if not specified), but if you give a #, it will
%               go this many frames back/forward to find a match to a whisker 
%
function dp = getDeltaPosition (obj, f, whiskerIds, frameHorizon)
  % frameHorizon
	if (nargin < 4)
	  frameHorizon = 1;
	end

  % frames
	if (length(f) == 1)
	  if (obj.correctionTemporalDirection == 1) % forward in time -- get f-1
		  f = [f f-1];
		else % backwards in time
		  f = [f f+1];
		end
	end

	% sanity
	if (f(2) > obj.numFrames | f(2) < 1)
	  dp = nan+0*whiskerIds;
	  return;
	end

	% this makes things faster ...
	fpmi1 = find(obj.positionMatrix(:,1) == f(1));
	fpmi2 = find(obj.positionMatrix(:,1) == f(2));

  % determine whiskers?
	if (nargin < 3) 
	  whiskerIds = [];
	end
	if (length(whiskerIds) == 0)
	  whiskerIds1 = 1:obj.numWhiskers;
	  whiskerIds2 = whiskerIds1;
	elseif (isinf(whiskerIds))
	  if (frameHorizon == 1)
			whiskerIds = intersect(obj.positionMatrix(fpmi1,2), obj.positionMatrix(fpmi2,2)) ;
		else
			whiskerIds = obj.positionMatrix(fpmi1,2);
		end
		whiskerIds1 = whiskerIds(find(whiskerIds > 0));
	  whiskerIds2 = whiskerIds1;
	elseif (size(whiskerIds,2) == 2) % two columns so all specified
	  whiskerIds1 = whiskerIds(:,1);
	  whiskerIds2 = whiskerIds(:,2);
	else 
	  whiskerIds1 = whiskerIds;
	  whiskerIds2 = whiskerIds;
	end

	% and calculate ...
	dp = nan+0*whiskerIds1;
	for w=1:length(whiskerIds1)
	  wpmi1 = fpmi1(find(obj.positionMatrix(fpmi1,2) == whiskerIds1(w)));
	  wpmi2 = fpmi2(find(obj.positionMatrix(fpmi2,2) == whiskerIds2(w)));

		if (length(wpmi1)+length(wpmi2) ~= 2) % one whisker is missing ...
			dp(w) = nan;
		  if (frameHorizon > 1)% travel back to find it?
			  if (obj.correctionTemporalDirection == 1) 
				  wpmi = find(obj.positionMatrix(1:fpmi2(1),2) == whiskerIds2(w));
					if (length(wpmi) > 1)
						wpmi = wpmi(find(obj.positionMatrix(wpmi,1) > f(1)-frameHorizon-1));
						wpmi = max(wpmi);
					end
				else % forward in time
				  wpmi = find(obj.positionMatrix(fpmi2(1):size(obj.positionMatrix,1),2) == whiskerIds2(w));
					wpmi = wpmi + fpmi2(1) - 1;
					if (length(wpmi) > 1)
						wpmi = wpmi(find(obj.positionMatrix(wpmi,1) < f(1)+frameHorizon+1));
						wpmi = min(wpmi);
					end
				end

				% assign?
				if (length(wpmi) + length(wpmi1) == 2)
					dp(w) = abs(obj.positionMatrix(wpmi1,3) - obj.positionMatrix(wpmi,3));
				end
			end
		else
		  dp(w) = abs(obj.positionMatrix(wpmi1,3) - obj.positionMatrix(wpmi2,3));
	  end
	end
