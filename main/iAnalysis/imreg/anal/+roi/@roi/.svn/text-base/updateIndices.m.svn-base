%
% This updates indices, given bounds for the image
%
function obj = updateIndices (obj, imageBounds)

  if (imageBounds(1) ~= 0 & imageBounds(2) ~= 0)
		% First, get X and Y based on image bounds
		Y = obj.indices-imageBounds(1)*floor(obj.indices/imageBounds(1));
		X = ceil(obj.indices/imageBounds(1));

		% reject X and Y outside of bounds ...
		val = find (X > 0 & Y > 0 & X <= obj.imageBounds(2) & Y <= obj.imageBounds(1));
		obj.indices = round(Y(val) + obj.imageBounds(1)*(X(val)-1));
  end
