%
% S PEron MAy 2010
%
% This will use workingImage and plot all rois on it, using borders and/or
%  indices.  Numbers cannot be drawn as those are plot objects; use plotImage
%  instead.  
%
% USAGE:
%
%  im = rA.generateImage(showBorders, showIndices, selectedIds, shownIds)
%         This syntax returns an RGB image with ROIs colored by their color    
%
%  [im roim] = rA.generateImage(showBorders, showIndices, selectedIds, shownIds)
%         This syntax returns a BW image with a second roim that is 0 for all
%           but the shownIds rois (which are 1).  Use this to do transparency.
% 
%
% parameters:
%  showBorders, showIndices: set to 1 to show ; 0 to not
%  selectedIds: plotted white instead of color ; selected, for instance
%  shownIds: if specified, only specified IDs are plotted ; otherwise all are
% 
% returns:
%  im: the image with ROIs on it; RGB if the user only requests im, OR black 
%      and white BASE image if user requests im AND roim
%  roim: ROI overlay image - binary image where 1 implies a roi of shownIds.
%  
%
function [im roim] = generateImage(obj, showBorders, showIndices, selectedIds, shownIds)

  % --- sanity checks
  if (nargin == 3)
	  selectedIds = -1;
	end
	if (nargin == 1)
	  showIndices = 1;
		showBorders = 1;
		selectedIds = -1;
	end
	if (nargin < 5)
	  shownIds = obj.roiIds;
	end
	if (size(obj.workingImage,1) == 0 | size(obj.workingImage,2) == 0)
	  disp('roiArray.generateImage::must have a workingImage to do this.');
	  im = [];
		return;
	end

  generateROim = 0;
	roim = [];
	if (nargout == 2)
	  generateROim = 1;
	end


  % --- preprocessing
  % normalize to 0, 1
	owim = obj.workingImage;
	owim = owim - min(min(owim));
	R = max(max(owim)) - min(min(owim));
	owim = double(owim)/double(R);

  % generate ROI image if this was requested (to do overlay w/ alpha)
  if (generateROim) 
		im = owim;
		roim = 0*owim;

		% --- indices
		if (showIndices)
			% loop over ROIs, assigning RGB accordingly ...
			for r=1:length(obj.rois)
				if (length(find(shownIds == obj.rois{r}.id)) == 0) ; continue ; end
				roi = obj.rois{r};
				roim(roi.indices) = 1;
			end
		end

		% --- borders
		if (showBorders)
			% loop over ROIs, assigning RGB accordingly ...
			for r=1:length(obj.rois)
				if (length(find(shownIds == obj.rois{r}.id)) == 0) ; continue ; end
				roi = obj.rois{r};

        roim(roi.borderIndices) = 1;
			end
		end
	else
		% convert to RGB
		R = owim;
		G = owim;
		B = owim;

		% apply colormap if not grey
		if (length(obj.workingImageColorMap) > 0)
		  idxVec = floor(owim*(size(obj.workingImageColorMap,1)-1))+1;
      R(1:end) = obj.workingImageColorMap(idxVec,1);
      G(1:end)= obj.workingImageColorMap(idxVec,2);
      B (1:end)= obj.workingImageColorMap(idxVec,3);
		end

    % put together the new image from R G B
		im = zeros(size(obj.workingImage,1), size(obj.workingImage,2), 3);
		im(:,:,1) = R;
		im(:,:,2) = G;
		im(:,:,3) = B;

		% --- indices
		if (showIndices)
			R = im(:,:,1);
			G = im(:,:,2);
			B = im(:,:,3);

			% loop over ROIs, assigning RGB accordingly ...
			for r=1:length(obj.rois)
				if (length(find(shownIds == obj.rois{r}.id)) == 0) ; continue ; end
				roi = obj.rois{r};

				R(roi.indices) = roi.color(1);
				G(roi.indices) = roi.color(2);
				B(roi.indices) = roi.color(3);
				
				% - selected - 
				if (length(find(obj.roiIds(r) == selectedIds)) > 0)
					R(roi.indices) = obj.settings.selectedColor(1);
					G(roi.indices) = obj.settings.selectedColor(2);
					B(roi.indices) = obj.settings.selectedColor(3);
				end 
			end

			% final assignment
			im(:,:,1) = R;
			im(:,:,2) = G;
			im(:,:,3) = B; 
		end

		% --- borders
		if (showBorders)
			R = im(:,:,1);
			G = im(:,:,2);
			B = im(:,:,3);

			% loop over ROIs, assigning RGB accordingly ...
			for r=1:length(obj.rois)
				if (length(find(shownIds == obj.rois{r}.id)) == 0) ; continue ; end
				roi = obj.rois{r};

				R(roi.borderIndices) = roi.color(1);
				G(roi.borderIndices) = roi.color(2);
				B(roi.borderIndices) = roi.color(3);
				
				% - selected - white
				if (length(find(obj.roiIds(r) == selectedIds)) > 0)
					R(roi.borderIndices) = obj.settings.selectedColor(1);
					G(roi.borderIndices) = obj.settings.selectedColor(2);
					B(roi.borderIndices) = obj.settings.selectedColor(3);
				end 
			end

			% final assignment
			im(:,:,1) = R;
			im(:,:,2) = G;
			im(:,:,3) = B; 
		end
  end

