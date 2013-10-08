%
% Wrapper function to generate an ROI based on a center point then finding a
%  surrounding luminance 'donut'.  Uses method written by Tsai-Wen Chen.
%
%  Uses obj.settings.semiAutoTW.expectedRadius to constrain radius.
%
% USAGE:
%
%   obj.roiGenSemiautoTsaiWen(centerPoint, debug)
%
% PARAMS:
%
%   centerPoint: [x y] coordinates of center point in workingImage
%   debug: if passed and 1, it will show some extra stuff
%
function obj = roiGenSemiautoTsaiWen(obj, centerPoint, debug)
  % --- presets - eventually do somewhere
	aspRatio = []; %%% FIX

  % --- params handle
	if (nargin < 2)  
	  help('roi.roiArray.roiGenSemiautoTsaiWen'); 
		error('roi.roiArray.roiGenSemiautoTsaiWen::requires at least center coordinate.');
	end

	if (nargin < 3 || length(debug) == 0) ; debug = 0; end

	% --- call the method
	[roiIndices, nucIndices , innerBoundIndices, borderIndices] = ...
		extern_donut_roi(obj.workingImage,[centerPoint(2) centerPoint(1)], ...
		  obj.settings.semiAutoTW.expectedRadius,aspRatio,debug);

	% --- handle the returned stuff: create roi and select it
	if (length(roiIndices) > 0)

		% build new roi, generating corners from border ...
		tRoi = roi.roi(-1, [], round(roiIndices), [1 0 0.5], obj.imageBounds, []);
		tRoi.corners = tRoi.computeBoundingPoly();
	
		% add it
		obj.addRoi(tRoi);

		% select it & update gui
		obj.guiSelectedRoiIds = tRoi.id;
		obj.updateImage();
	end

