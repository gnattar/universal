%
% Will use neighbor alignment to correct passed outliers for two days.
%
% USAGE:
%
%   rA.correctAlignmentOutliers(rB, outlierIds, params)
%
% ARGUMENTS:
%
%   rB: the reference ("correct") roiArray
%   outlierIds: if passed, it will do these ; otherwise, if you pass [] or not
%               at all, it will call getAlignmentOutliers ; roiIds
%   params: structure with additional fields (optional)
%     params.n_closest: how many nearest-neighbors to use to interpolate? 5 
%
% RETURNS:
%
%   outlierIds: ids (NOT indices) of rois that were outliers
%   redoThresh: if you are going to attempt redo use this as threshold
%
function correctAlignmentOutliers(obj,objB, outlierIds, params)

  %% --- sanity checks // input processing
	if (obj.length ~= objB.length)
	  error('roi.roiArray.correctAlignmentOutliers::must have equal length roiArrays.');
	end

  n_closest = 5;
  if (nargin >=4 && isstruct(params))
		eval(assign_vars_from_struct(params, 'params'));
	end


  %% --- outliers?
	if (nargin < 3 || length(outlierIds) == 0)
	  outlierIds = obj.getAlignmentOutliers(objB);
	end

  %% --- setup (get dx/dy)

	% compute dx/dy for everyone 
  dx_r (obj.length) = 0;
  dy_r = 0*dx_r;
  dx_r = 0*dx_r;
  for r=1:length(obj)
	  roi_b_com(:,r) = [mean(objB.rois{r}.corners(1,:)) mean(objB.rois{r}.corners(2,:))];
	  roi_a_com(:,r) = [mean(obj.rois{r}.corners(1,:)) mean(obj.rois{r}.corners(2,:))];
	end
	roi_b_com(find(isnan(roi_b_com))) = -1*size(obj.masterImage,1);
	roi_a_com(find(isnan(roi_a_com))) = -1*size(obj.masterImage,1);

	dx_r = roi_a_com(1,:) - roi_b_com(1,:);
	dy_r = roi_a_com(2,:) - roi_b_com(2,:);


	% precompute distance matrix for base roiArray
	roi_dist = zeros(objB.length,objB.length);
	for r1=1:objB.length
	  roi_dist(r1,r1) = 0;
	  for r2=r1+1:objB.length
		  D = sqrt(((roi_b_com(1,r1)-roi_b_com(1,r2))^2)+((roi_b_com(2,r1)-roi_b_com(2,r2))^2));
			roi_dist(r1,r2) = D;
			roi_dist(r2,r1) = D;
		end
	end

  %% --- execution

  outlier_idx = find(ismember(obj.roiIds, outlierIds));
	for r=outlier_idx
		% compute 5 closest UNFAILED neighbors
		dists = roi_dist(r,:);
		[irr closest_idx] = sort(dists);

		n = 2; % first is going to be the same roi since distance is 0!
		nc = 0;
		closest_good = [];
		while (nc < n_closest & n < length(closest_idx))
			if (~ismember(closest_idx(n), outlier_idx)) % if its good, use it
				closest_good = [closest_good closest_idx(n)];
				nc = nc+1;
			end
			n = n+1;
		end

		% average their dx/dy and use it
		dx = round(mean(dx_r(closest_good))) - dx_r(r);
		dy = round(mean(dy_r(closest_good))) - dy_r(r);

		obj.rois{r}.moveBy(dx,dy);
    disp(['Corrected ROI ' num2str(obj.rois{r}.id)]);
	end

