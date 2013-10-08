%
% S Peron May 2010
%
% This will add/subtract a number of indices based on the top/lowest luminance
%  pixels within ROI's borders.  Uses workingImage.
%
% usage: changeIndicesBasedOnLuminance(roiIds, dPixels)
%
%   roiIds: ID(s) of ROI(s) this is done to
%   dPixels: positive means add this many BRIGHTEST ; negative means remove
%            this many DARKEST
%
function obj = changeIndicesBasedOnLuminance(obj, roiIds, dPixels)

  % --- needs workingImage
	if (size(obj.workingImage,1) == 0)
	  disp('roiArray.changeIndicesBasedOnLuminance requires valid workingImage');
		ceLumRatio = NaN;
		return;
	end

  % --- loop over roiIds
	for r=1:length(roiIds)
	  idx = find(obj.roiIds == roiIds(r));
	  roi = obj.rois{idx};
    oldIndices = roi.indices;

		% fill it and grab all luminances
		obj.fillToBorder(roi.id);
		inIndices = roi.indices;

		% --- magic
    if (dPixels > 0) % grow ROI -- add brightest
			% get luminance of  candidates -- unselected points
			candidate_idx = setdiff(inIndices, oldIndices);

			% sort the luminance of candidates
			lums = obj.workingImage(candidate_idx);
			[val s_idx] = sort(lums, 'descend');

		  if (length(s_idx) > 0) % do we have anything to work with?
			  add_idx = candidate_idx(s_idx(1:min(dPixels, length(s_idx))));
				new_indices = [oldIndices' add_idx']';
			else 
				new_indices = oldIndices;
			  disp('No more points to add');
			end
		else % reduce ROI -- take away darkest
			% sort the luminance of candidates
			lums = obj.workingImage(oldIndices);
			[val s_idx] = sort(lums, 'ascend');

		  if (length(s_idx) > 0) % do we have anything to work with?
			  subst_idx = oldIndices(s_idx(1:min(-1*dPixels, length(s_idx))));
				new_indices = setdiff(oldIndices, subst_idx);
			else 
			  disp('No more points to remove');
			end
		end

		% --- set indices
		roi.indices = new_indices;
  end
