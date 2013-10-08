%
% SP 2010 Oct
% 
% Plots the transform from one day to the other
%
% USAGE:
%
%  rA.plotInterdayTransform(rB, axHandles)
%
%  rB: the other roiArray object; must have same # of ROIs
%  axHandles: axes to plot things to (1): raw image
%             (2): image with transform
%             if it is nan, will not be plotted; if not provided, it
%             makes its own figure.
%
function plotInterdayTransform(obj, objB, axHandles)
  border = 1;
	fill = 0;

  % --- sanity checks
	if (length(obj.rois) ~= length(objB.rois))
	  disp('plotInterdayTransform::both arrays must have same # of ROIs.');
		return;
	end

  % --- prenormalize both images
  mA = quantile(reshape(obj.workingImage,[],1), .9975);
  obj.workingImage(find(obj.workingImage > mA)) = mA;
  mB = quantile(reshape(objB.workingImage,[],1), .9975);
  objB.workingImage(find(objB.workingImage > mB)) = mB;

	% --- left panel -- easy
	if (nargin < 3 || length(axHandles) == 0)
		figure;
		axHandles(1) = subplot(1,2,1);
		axHandles(2) = subplot(1,2,2);
	end

	if (~isnan(axHandles(1)))
	  axes(axHandles(1));
		obj.plotImage(border,fill,0);
		title(strrep(obj.idStr,'_','-'));
		if (length(obj.idStr) == 0)
			title(strrep(obj.roiFileName,'_','-'));
		end
	end

	% --- right panel -- a bit trickier as we want to use colorscheme from here

	% grab old colorscheme, and get COM for new and old
	oColors = zeros(length(objB.rois),3);
	comA =  zeros(length(objB.rois),2);
	comB =  zeros(length(objB.rois),2);
	for r=1:length(objB.rois) % store original colors, assign new
	  oColors(r,:) = objB.rois{r}.color; 
		objB.rois{r}.color = obj.rois{r}.color;

		% com
	  comA(r,1) = mean(obj.rois{r}.corners(1,:)); 
	  comA(r,2) = mean(obj.rois{r}.corners(2,:)); 
	  comB(r,1) = mean(objB.rois{r}.corners(1,:)); 
	  comB(r,2) = mean(objB.rois{r}.corners(2,:)); 
	end

	% plot it ...
	if (~isnan(axHandles(2)))
	  axes(axHandles(2));
		objB.plotImage(border,fill,0);
		title(strrep(objB.idStr,'_','-'));
		if (length(objB.idStr) == 0)
			title(strrep(objB.roiFileName,'_','-'));
		end

		% and the displacement vectors ...
		dvCol = [1 1 0];
		hold on;
		for r=1:length(obj.rois) 
			plot([comA(r,1) comB(r,1)], [comA(r,2) comB(r,2)], '-', 'Color', dvCol, 'LineWidth', 1);
		end
	end

	% assign old colors back
	for r=1:length(objB.rois) 
		objB.rois{r}.color = oColors(r,:);
	end
	  
