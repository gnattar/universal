%
% Computes bouding polygon for particular ROI's indices - tightest fit thereto,
%  attained via convex hull.  Returns the corners of this polygon, where
%  corners(1,:) is X.
%
function corners = computeBoundingPoly(obj)
  if (obj.imageBounds(1) > 0 & obj.imageBounds(2) > 0)
		% convert to X Y
		Y = obj.indices-obj.imageBounds(1)*floor(obj.indices/obj.imageBounds(1));
		X = ceil(obj.indices/obj.imageBounds(1));
		Y(find(Y == 0)) = obj.imageBounds(1);

    % colinear? -- not perfect however!
		if (sum(abs(diff(X))) == 0)
		  disp('roi.computeBoundingPoly::colinear points detected, meaning convex hull would fail.  Introducing jitter.'); 
			ridx = randperm(length(X));
			X(ridx(1:ceil(length(X)/2))) = 1+X(ridx(1:ceil(length(X)/2)));
		end
		if (sum(abs(diff(Y))) == 0)
		  disp('roi.computeBoundingPoly::colinear points detected, meaning convex hull would fail.  Introducing jitter.'); 
			ridx = randperm(length(Y));
			Y(ridx(1:ceil(length(Y)/2))) = 1+Y(ridx(1:ceil(length(Y)/2)));
		end
 
		% run convex hull
		corn_idx = convhull(X,Y);

		corner_x = X(corn_idx);
		corner_y = Y(corn_idx);

		% build corners -- but omit last since it repeats
		corners(1,:) = corner_x(1:length(corner_x)-1);
		corners(2,:) = corner_y(1:length(corner_x)-1);
	end
