%
% Assigns border indices based on image bounds 
%
function obj = assignBorderIndices(obj) 
  if (size(obj.corners,1) == 2 & length(obj.imageBounds) >= 2)
    % - skip if no valid corners ...
		cx = obj.corners(1,:);
		cy = obj.corners(2,:);
		val = find (cx > 0 & cy > 0 & cx <= obj.imageBounds(2) & cy <= obj.imageBounds(1));
		if (length(val) == 0) ; obj.borderIndices = []; return ; end

		l_indices = [];
		% - all but last point:
		for p=1:length(obj.corners)-1
			% call bresenham algorithm
			[lx ly] = extern_bresenham ( [obj.corners(1,p) obj.corners(2,p) ; obj.corners(1,p+1) obj.corners(2,p+1)]);

			% exclude points outside of image bounds
			val = find (lx > 0 & ly > 0 & lx <= obj.imageBounds(2) & ly <= obj.imageBounds(1));
			lx = lx(val);
			ly = ly(val);

			% convert x/y to indices [THIS SHOULD ONLY HAPPEN WHEN ROIs CHANGE]
			l_indices = [l_indices ly+obj.imageBounds(1)*(lx-1)];
		end
		% - last point connection -- reconnect to first point
		[lx ly] = extern_bresenham ( [obj.corners(1,p+1) obj.corners(2,p+1) ; obj.corners(1,1) obj.corners(2,1)]);
		% exclude points outside of image bounds
		val = find (lx > 0 & ly > 0 & lx <= obj.imageBounds(2) & ly <= obj.imageBounds(1));
		lx = lx(val);
		ly = ly(val);
		% line indices ..
		l_indices = [l_indices ly+obj.imageBounds(1)*(lx-1)];

		% - assign
		obj.borderIndices = round(l_indices);
	end

