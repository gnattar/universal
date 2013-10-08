%
% Wrapper function to generate an ROI based on a center point then finding a
%  surrounding luminance drop.  Filled roi is thereby gnerated.
%
% USAGE:
%
%   obj.roiGenSemiautoGradient(centerPoint)
%
% PARAMS:
%
%   centerPoint: [x y] coordinates of center point in workingImage
%
% SETTINGS USED:
%
%   obj.settings.semiAutoGrad.radiusRange: range of permitted radii
%
function obj = roiGenSemiautoGradient(obj, centerPoint)
  %% --- params handle
	if (nargin < 2)  
	  help('roi.roiArray.roiGenSemiautoGradient'); 
		error('roi.roiArray.roiGenSemiautoGradient::requires center coordinate.');
	end

	%% --- the call to the detector ...
	params.radRange =  obj.settings.semiAutoGrad.radiusRange;
	params.dPosMax = obj.settings.semiAutoGrad.dPosMax;
	params.edgeSign = obj.settings.semiAutoGrad.edgeSign;
	params.postDilateBy = obj.settings.semiAutoGrad.postDilateBy;
	params.postFracRemove = obj.settings.semiAutoGrad.postFracRemove;

	[borderXY borderIndices roiIndices] = roi.roiArray.cellDetGradient(obj, ...
	    obj.workingImage,[centerPoint(1) centerPoint(2)], params);

	%% --- handle the returned stuff: create roi and select it
	if (length(roiIndices) > 0)
		% build new roi, generating corners from border ...
		tRoi = roi.roi(-1, borderXY, roiIndices, [1 0 0.5], obj.imageBounds, []);
		tRoi.borderIndices = borderIndices;
	
		% add it
		obj.addRoi(tRoi);

		% select it & update gui
		obj.guiSelectedRoiIds = tRoi.id;
		obj.updateImage();
	end


