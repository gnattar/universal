%
% S Peron May 2010
%
% This is for finding an ROI given a point - to see if any ROI in the array is
%  on that point and, therefore, should be selected by the user when they
%  click there.
% 
% Usage:
%  roi = findRoiByPoint(x, y)
%
% Passed: x,y: x and y of clicked point
% Returned: roi: the roi object; [] if nothing
%
function roi = findRoiByPoint(obj, x, y)
	roi = [];

  % --- working image sanity
	if (size(obj.workingImage,1) == 0 | size(obj.workingImage,2) == 0)
	  disp('roiArray.findRoiByPoint::must have a workingImage to do this.');
		return;
	end

  % loop for match ; stop @ first match ; do it based on corner bounds
	for r=1:length(obj.rois)
	  x_c = obj.rois{r}.corners(1,:);
	  y_c = obj.rois{r}.corners(2,:);

    if (x > min(x_c) & x < max(x_c) & y > min(y_c) & y < max(y_c))
		  roi = obj.rois{r};
		  break;
		end
	end

