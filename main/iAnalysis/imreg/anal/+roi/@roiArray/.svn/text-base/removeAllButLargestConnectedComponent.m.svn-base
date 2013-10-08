%
% S Peron May 2010
%
% This will break the indices of rois into connected components and leave only
%  the largest one of these.  Good for clearing stray pixels.
%
% usage: removeAllButLargestConnectedComponent(roiIds)
%
%   roiIds: ID(s) of ROI(s) this is done to
%
function obj = removeAllButLargestConnectedComponent(obj, roiIds)

  % --- needs workingImage
	if (size(obj.workingImage,1) == 0)
	  disp('roiArray.changeIndicesBasedOnLuminance requires valid workingImage');
		ceLumRatio = NaN;
		return;
	end

  
	% this is used for compnent detection
	bw_im = zeros(size(obj.workingImage));
  % --- loop over roiIds
	for r=1:length(roiIds)
	  idx = find(obj.roiIds == roiIds(r));
	  roi = obj.rois{idx};

	  % make a bw image where 1 = indices 0 = all else
		bw_im = 0*bw_im;
		bw_im(roi.indices) = 1;

		% bw label it to get components
		bw_lab = bwlabel(bw_im);

    % take largest
		ul = unique(bw_lab);
		nl = zeros(length(ul),1);
		for l=1:length(ul)
		  if(ul(l) > 0)
			  nl(l) = length(find(bw_lab == ul(l)));
			end
		end
    [val idx] = max(nl);
		roi.indices = find(bw_lab == ul(idx));
	end
  
