%
% S Peron May 2010
%
% This will take a region specified by a polygon's corners, polyCorners,
%  where (1,:) is x corners, and find any ROIs whose borders venture into
%  the polygon, returning a cell array of ROI objects.
% 
% Usage:
%  rois = findRoisByPoly(polyCorners)
%
% Passed: poly: polygon to look in
% Returned: rois: the roi objects; [] if nothing
%
function rois = findRoisByPoly(obj, polyCorners)
	rois = {};

  % --- working image sanity
	if (size(obj.workingImage,1) == 0 | size(obj.workingImage,2) == 0)
	  disp('roiArray.findRoisByPoly::must have a workingImage to do this.');
		return;
	end
	if (size(obj.workingImageYMat,1) == 0  || size(obj.workingImageXMat,1) == 0)
		obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
		obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
	end

	% polygon indices
	xv = polyCorners(1,:);
	xv = [xv xv(1)]';
	yv = polyCorners(2,:);
	yv = [yv yv(1)]';
  in = inpolygon(obj.workingImageXMat, ...
                  obj.workingImageYMat, ...
									 xv, yv);
	polyIndices = find(in == 1);

  % loop for match ; stop @ first match ; do it based on corner bounds
	for r=1:length(obj.rois)
	  nm = length(intersect(obj.rois{r}.indices, polyIndices));
		if (nm > 0)
			rois{length(rois)+1} = obj.rois{r};
		end
	end
