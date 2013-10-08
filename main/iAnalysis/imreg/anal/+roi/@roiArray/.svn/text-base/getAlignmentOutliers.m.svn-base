%
% Will return inter-day alignment outliers from two days' of data.
%
% USAGE:
%
%   [outlierIds redoThresh] = rA.getAlignmentOutliers(rB)
%
% ARGUMENTS:
%
%   rB: flag rois in rA that deviate from the spatial ordering in rB
%
% RETURNS:
%
%   outlierIds: ids (NOT indices) of rois that were outliers
%   redoThresh: if you are going to attempt redo use this as threshold
%
function [outlierIds redoThresh] = getAlignmentOutliers(obj,objB)

  % --- sanity checks
	if (obj.length ~= objB.length)
	  error('roi.roiArray.getAlignmentOutliers::must have equal length roiArrays.');
	end

  % --- setup
  dx_r (obj.length) = 0;
  dy_r = 0*dx_r;
  dx_r = 0*dx_r;
  for r=1:length(obj)
	  roi_b_com(:,r) = [mean(objB.rois{r}.corners(1,:)) mean(objB.rois{r}.corners(2,:))];
	  roi_a_com(:,r) = [mean(obj.rois{r}.corners(1,:)) mean(obj.rois{r}.corners(2,:))];
	end

	roi_b_com(find(isnan(roi_b_com))) = -1*size(obj.masterImage,1);
	roi_a_com(find(isnan(roi_a_com))) = -1*size(obj.masterImage,1);

	dx_r = roi_b_com(1,:) - roi_a_com(1,:);
	dy_r = roi_b_com(2,:) - roi_a_com(2,:);


  % --- execution
  gdo_params.n_closest = 5;
	gdo_params.median_difference_thresh = 0; % basically go until 7 x median criteria met
	dX = [dx_r' dy_r'];
	[outlier_idx redoThresh]= get_displacement_outliers(roi_b_com', dX, gdo_params);
	outlierIds = obj.roiIds(outlier_idx);

