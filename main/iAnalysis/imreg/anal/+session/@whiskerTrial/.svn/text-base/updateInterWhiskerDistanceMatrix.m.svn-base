%
% SP Oct 2010
%
% This will populate the interAdjacentWhiskerDistanceMatrix, whereby all
%  whiskers meething the length/maxFollY criteria are taken, and ones
%  that are adjacent have their distance measured.  Then, for each frame, you
%  get 4 numbers related to this distance: [mean median min max] ; this vector
%  constitutes the a row of the matrix, with each frame getting a row.
%
% USAGE:
%
%   wt.updateInterWhiskerDistanceMatrix()
%
function updateInterWhiskerDistanceMatrix(obj)
  % 1) select valid whiskers
	obj.applyLengthThreshold();
	obj.applyMaxFollicleY();

	% 2) go thru and get er done
	obj.interAdjacentWhiskerDistanceMatrix = nan*ones(obj.numFrames,4);
  for f=1:obj.numFrames
	  val = find(obj.positionMatrix(:,1) == f);
	  val = val(find(obj.positionMatrix(val,2) > 0));
    posVec = obj.positionMatrix(val,3);
		posVec = sort(posVec);
		distVec = diff(posVec);

		if(length(distVec)  > 0)
		  obj.interAdjacentWhiskerDistanceMatrix(f,:) = [mean(distVec) median(distVec) min(distVec) max(distVec)];
		end
	end

