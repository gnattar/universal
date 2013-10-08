%
% S PEron May 2010
%
% Fills specified ROIs in roiArray to their border, reassigning indices.
%  If you pass no roiIds, it does them all.
%
function obj = fillToBorder(obj, roiIds)
  % --- sanity/arguments
	if (nargin == 1)
  	roiIds= obj.roiIds;
	end
	if (size(obj.workingImageYMat,1) == 0  || size(obj.workingImageXMat,1) == 0)
		obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
		obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
	end


	% --- the meat
	for r=1:length(roiIds)
	  idx = find(obj.roiIds == roiIds(r));
	  roi = obj.rois{idx};
		roi.fillToBorder(obj.workingImageXMat, obj.workingImageYMat);
	end

