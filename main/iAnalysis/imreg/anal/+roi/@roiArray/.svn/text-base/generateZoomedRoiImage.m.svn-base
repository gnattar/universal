%
% S PEron MAy 2010
%
% This will plot a zoomed image of workingImage looing at ROI with id roiId.
%
% USAGE:
%
%  im = generateZoomedRoiImage(obj, roiId, showBorders, showIndices, zoomFactor)
%     This syntax will returned a zoomed image that is RGB where ROIs are colored
%      based on the roi.color property.
%
%  [im roim] = generateZoomedRoiImage(obj, roiId, showBorders, showIndices, zoomFactor)
%     This will return both a BLACK AND WHITE base image and a black and white mask
%      (roim) that you can use to do transparecy for rois.
%  
%
% parameters:
%  roiId: ID of ROI to highlight
%  showBorders, showIndices: set to 1 to show ; 0 to not
%  zoomFactor -- how much to zoom by?
% 
% returns:
%  im: the image with ROIs on it; RGB or BW
%  roim: roi overlay image for using transparency
%
function [im roim] = generateZoomedRoiImage(obj, roiId, showBorders, showIndices, zoomFactor)
  % --- sanity checks
  if (nargin == 2)
		showIndices = 0;
		showBorders = 1;
		zoomFactor = 10;
	end
	if (zoomFactor <= 1)
	  disp('roiArray.generateZoomedRoiImage::zoom factor must be > 1');
		im = [];
		return;
	end
	if (length(find(obj.roiIds == roiId)) == 0)
	  disp('roiArray.generateZoomedRoiImage::must select valid ROI to zoom');
		im = [];
		return;
	end

  generateROim = 0;
	roim = [];
	if (nargout == 2)
	  generateROim = 1;
	end

  % --- get baseline image
%OLD kept it white; we want it color:  gim = obj.generateImage(showBorders, showIndices, roiId, roiId);
  if (generateROim)
		[gim groim] = obj.generateImage(showBorders, showIndices, [],roiId);
	else
		gim = obj.generateImage(showBorders, showIndices, [],roiId);
	end

	% --- create zoomed subset ... pad with 0 if on edge
	S = size(gim);
	nS = round(S/zoomFactor);
	roi = obj.getRoiById(roiId);
	Y = roi.borderIndices-obj.imageBounds(1)*floor(roi.borderIndices/obj.imageBounds(1));
	X = ceil(roi.borderIndices/obj.imageBounds(1));
	cx = round(mean(X));
	cy = round(mean(Y));

  rX = round(nS(2)/2);
	maxX = min(cx+rX,S(2));
	minX = max(cx-rX,1);

  rY = round(nS(1)/2);
	maxY = min(cy+rY,S(1));
	minY = max(cy-rY,1);

	% set part of image not on border
	imx = [1 rX+rX+1];
	if (cx+rX > maxX)
	  imx(2) = imx(2) - (rX-(maxX-cx));
	elseif (cx-rX < minX)
	  imx(1) = imx(1) - ((cx-rX)-1);
	end
	imy = [1 rY+rY+1];
	if (cy+rY > maxY)
	  imy(2) = imy(2) - (rY-(maxY-cy));
	elseif (cy-rY < minY)
	  imy(1) = imy(1) - ((cy-rY)-1);
	end

  % create image
	if (generateROim)
		im = zeros(rY+rY+1, rX+rX+1);
		roim = zeros(rY+rY+1, rX+rX+1);
		im(imy(1):imy(2),imx(1):imx(2)) = gim(minY:maxY,minX:maxX);
		roim(imy(1):imy(2),imx(1):imx(2)) = groim(minY:maxY,minX:maxX);
	else
		im = zeros(rY+rY+1, rX+rX+1, 3);
		im(imy(1):imy(2),imx(1):imx(2),:) = gim(minY:maxY,minX:maxX,:);
	end


