%
% Updates corners, borderIndices, and indices based on desired x,y move
%
function obj = moveBy (obj, dx, dy)
  % sanity checks
	if (obj.imageBounds(1) == 0 | obj.imageBounds(2) == 0)
	  disp('roi.moveBy::must define imageBounds to execute this function.');
	else
	  % --- update corners 
	  obj.corners(1,:) = obj.corners(1,:) + dx;
	  obj.corners(2,:) = obj.corners(2,:) + dy;

		% --- border indices
		obj.assignBorderIndices();

		% --- re-assign regular indices ...
		Y = obj.indices-obj.imageBounds(1)*floor(obj.indices/obj.imageBounds(1));
		X = ceil(obj.indices/obj.imageBounds(1));
		X = X + dx;
		Y = Y + dy;

		% reject X and Y outside of bounds ...
		val = find (X > 0 & Y > 0 & X <= obj.imageBounds(2) & Y <= obj.imageBounds(1));
		newIndices = round(Y(val) + obj.imageBounds(1)*(X(val)-1));

		% reject border
		obj.indices = newIndices;
	end
