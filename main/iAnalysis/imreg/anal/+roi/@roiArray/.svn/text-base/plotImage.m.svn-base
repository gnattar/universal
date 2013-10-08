%
% S PEron MAy 2010
%
% This will use workingImage and plot all rois on it, using borders and/or
%  indices.  Also draws numbers.  Everything is plotted on selected axis.
%
% parameters:
%  showBorders, showIndices, showNumbers: set to 1 to show ; 0 to not
%  selectedIds: plotted white instead of color ; selected, for instance
%  axRef: (optional): axis object to plot into ; otherwise makes new figure
%
% returns:
%  imRef: the handle to the image object
%  axRef: the handle to the axes object
%  figRef: the handle to the figure object
%
% usage: [imRef axRef figRef] = plotImage(obj, showBorders, showIndices, ...
%                                 showNumbers, selectedIds, axRef)
%
function [imRef axRef figRef] = plotImage(obj, showBorders, showIndices, ...
                                 showNumbers, selectedIds, axRef)
  % --- sanity checks
  if (nargin < 5)
	  selectedIds = -1;
	end
	if (nargin == 1)
	  showIndices = 1;
		showBorders = 1;
		showNumbers = 1;
		selectedIds = -1;
	end
	if (size(obj.workingImage,1) == 0 | size(obj.workingImage,2) == 0)
	  disp('roiArray.plotImage::must have a workingImage to do this.');
	  imRef = [];
		axRef = [];
		figRef = [];
		return;
	end

	% --- base image
  % call generateImage
  im = generateImage(obj, showBorders, showIndices, selectedIds);

	% display image
	if (nargin == 6) % axis specified
		imRef = imshow(im, [0 1],'Parent', axRef, 'Border', 'tight');
	else
		imRef = imshow(im, [0 1], 'Border', 'tight');
		axRef = gca;
	end
	figRef = gcf;

	% --- and now numbers if needve
	if (showNumbers)
	  for r=1:length(obj.rois)
		  roi = obj.rois{r};

			if (length(roi.borderIndices) > 0 ) % skip off-line ones
				% unfilled rois? white in middle
				Y = roi.borderIndices-roi.imageBounds(1)*floor(roi.borderIndices/roi.imageBounds(1));
				X = ceil(roi.borderIndices/roi.imageBounds(1));
				val = find (X > 0 & Y > 0 & X <= obj.imageBounds(2) & Y <= obj.imageBounds(1));

				if (length(val) > 0)
					text(mean(X(val)), mean(Y(val)), num2str(roi.id), 'Color', obj.settings.textColor);
				end
			end
		end
	end

  % --- aspect ratio
	if (length(obj.aspectRatio) == 1 & obj.aspectRatio == 1) % square
	  s1 = obj.imageBounds(2)/max(obj.imageBounds);
	  s2 = obj.imageBounds(1)/max(obj.imageBounds);
		set(axRef, 'DataAspectRatio', [s1 s2 1]);
	elseif (length(obj.aspectRatio) == 1 & obj.aspectRatio == 2) % based on image
		set(axRef, 'DataAspectRatio', [1 1 1]);
	elseif (length(obj.aspectRatio) == 2) % pix2um
		M = max(obj.aspectRatio);
		s1 = obj.aspectRatio(2)/M;
		s2 = obj.aspectRatio(1)/M;
		set(axRef, 'DataAspectRatio', [s1 s2 1]);

		% - draw the distance bar 
		ver_extent = obj.aspectRatio(2) * size(im,1);
		p = floor(log10(ver_extent));
		hold on ; 
		plot([10 10], [10 10+((10^p)/obj.aspectRatio(2))], ...
			'Color', obj.settings.scaleBarColor, 'LineWidth', 3);
	  text (15 , 10+0.5*((10^p)/obj.aspectRatio(2)),  ...
			[num2str(10^p) ' um'], 'Color' ,obj.settings.scaleBarColor);
  end

