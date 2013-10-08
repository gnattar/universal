%
% SP May 2011
%
% This will compile statistics that are used to determine if a neuron is filled
%  or not.  Note that prior to ANY of the operations described below, the image
%  is normalized by 1) setting min to 0 2) dividing by IQR.  Thus, all metrics
%  described below are with respect to this luminance-normalized image.  Also,
%  all rois are first fillToBorder'ed before any calculations are performed.
%  As with most operations, work is done using workingImage.
%
% USAGE:
%
%   [isFilled ecRatio cmRatio pixValIQR borderVal centerVal] = 
%                                     rA.getRoiFillingStatistics(roiIds)
%
% PARAMS:
%
%   isFilled: 1/0 vector corresponding to roiIds with 1 if cell is considered
%             filled
%   ecRatio: ratio of (eroded) center pixel median value to (dilated) border 
%            median
%   cmRatio: ratio of non-border (inside) pixels to median image pixel value
%   pixValIQR: Interquartile range for that cell's pixels
%   borderVal: value of border intensity
%   centerVal: value of center intensity
%
%   roiIds: rois for which data is gathered
%
function [isFilled ecRatio cmRatio pixValIQR borderVal centerVal] = getRoiFillingStatistics(obj, roiIds)

  % --- argument parsing
	if (nargin < 2) 
	  roiIds = obj.roiIds;
	end
	warning('off','MATLAB:interp1:NaNinY');
	if (size(obj.workingImageYMat,1) == 0  || size(obj.workingImageXMat,1) == 0)
		obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
		obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
	end

	% --- normalize image to 2*IQR (middle)
	mi = obj.workingImage;
	mi = mi - nanmin(nanmin(mi)); % minimize
	mil = reshape(mi,[],1);
	miqr = quantile(mil,.75)-quantile(mil,.25);
	mi = mi/miqr;
	medmi = median(reshape(mi,[],1));

	imBounds = obj.imageBounds;
 
  % --- roi loop
	isFilled = nan*(1:length(roiIds));
	ecRatio=isFilled;
	cmRatio=isFilled;
	pixValIQR=isFilled;
	borderVal=isFilled;
	centerVal=isFilled;
	for r=1:length(roiIds)
	  roi = obj.getRoiById(roiIds(r));
		rc = roi.copy();

    % fill 2 border
		rc.fillToBorder(obj.workingImageXMat, obj.workingImageYMat);

    % get pixels for center (to do quantile)
		idx = rc.indices;
		bidx = rc.borderIndices;
		cidx = setdiff(idx,bidx);
		cpixels = mi(cidx);
		cpixels = reshape(cpixels,[],1);

		% get neighborhood median
%	  bX = ceil(bidx/imBounds(1));
%  	bY = bidx-(imBounds(1)*floor(bidx/imBounds(1)));
%		minX = max(1,min(bX)-20);
%		maxX = max(1,max(bX)+20);
%		minY = max(1,min(bY)-20);
%		maxY = max(1,max(bY)+20);
%		medSubIm = nanmedian(reshape(mi(minY:maxY,minX:maxX),[],1));

		% actual used #s
		center = quantile(cpixels,0.25);

		% assign returned values
    [ecRatio(r) borderVal(r) centerVal(r)] =  obj.computeEcRatio(roiIds(r), mi);

		cmRatio(r) = center/medmi;
%		cmRatio(r) = center/medSubIm;
    pixValIQR(r) = iqr(cpixels);
%		borderVal(r) = border;


	end

	% --- isFilled assignment -- CRUDE
	for r=1:length(roiIds)
	  isFilled(r) = 0;
		if (ecRatio(r) < 1.05 | cmRatio(r) > 3 | pixValIQR(r) > 1.5) ; isFilled(r) = 1; end
	end

	% --- wrapup
	warning('on','MATLAB:interp1:NaNinY');

		
