%
% SP Apr 2011
%
% Updates zoom plot.
%
% USAGE:
%
%   mdg.updateZoomPLot()
%
function updateZoomPlot(obj)

  % draw at all?
	if (~ obj.zoomOn) 
	  if (length(obj.zoomFigH ~= 0))
		  if (ishandle(obj.zoomFigH))
			  delete(obj.zoomFigH);
			end
		end
		return;
	end

  % generate figure or use existing?
	newFig = 0;
  if (length(obj.zoomFigH) == 0)
	  newFig = 1;
	elseif(~ishandle (obj.zoomFigH))
	  newFig = 1;
	end
  
	% draw new
	if (newFig)
	  obj.zoomFigH = figure ('Position', [150 150 550 400]);
		
		switch computer % computer-dependent renderer
			case {'MACI', 'MACI64'}
				renderer = 'opengl';
			case {'GLNXA64', 'GLNX86'}
				renderer = 'opengl';
			otherwise
				renderer = 'opengl';
		end

		set(obj.zoomFigH,'RendererMode', 'manual', 'Toolbar', 'none', 'DockControls', 'off', ...
		                           'Renderer', renderer, 'MenuBar', 'none');
	  obj.zoomAxesH(1) = subplot('Position', [0.0125 0.0125 .675 .975]);
	  obj.zoomAxesH(2) = subplot('Position', [0.695 0.665 .3 .3]);
	  obj.zoomAxesH(3) = subplot('Position', [0.695 0.345 .3 .3]);
	  obj.zoomAxesH(4) = subplot('Position', [0.695 0.025 .3 .3]);
%	  obj.zoomAxesH = axes;
	end

  % and now actualy do everything(!)
	rA = obj.roiArrayArray{obj.rAidx};
	if (length(rA.guiSelectedRoiIds) == 1)
	  s1 = rA.imageBounds(2)/max(rA.imageBounds);
	  s2 = rA.imageBounds(1)/max(rA.imageBounds);

		idx = find(rA.roiIds == rA.guiSelectedRoiIds);
		roi = rA.rois{idx};

		[zim rzim]= rA.generateZoomedRoiImage(rA.guiSelectedRoiIds, rA.guiShowFlags(1), rA.guiShowFlags(2), 10);
		lzim = reshape(zim,[],1);
    zim = 0.5*zim/median(lzim);

		midx = find(zim ~= 1);
		imshow(zim,'Parent', obj.zoomAxesH(1), 'Border','tight','InitialMagnification','fit'); 
		greenim = cat(3, roi.color(1)*ones(size(zim)), roi.color(2)*ones(size(zim)), roi.color(3)*ones(size(zim)));
		hold(obj.zoomAxesH(1), 'on'); 
		ih = imshow(greenim,'Parent', obj.zoomAxesH(1)); 
		hold(obj.zoomAxesH(1), 'off'); 
		set(ih, 'AlphaData',0.10*rzim); 
		set(obj.zoomAxesH(1), 'DataAspectRatio', [s1 s2 1]);

		zim = rA.generateZoomedRoiImage(rA.guiSelectedRoiIds, 0, 0, 10);
		lzim = reshape(zim,[],1);
    zim = 0.5*zim/median(lzim);
		midx = find(zim ~= 1);
		imshow(zim,'Parent', obj.zoomAxesH(2), 'Border','tight','InitialMagnification','fit'); 
		set(obj.zoomAxesH(2), 'DataAspectRatio', [s1 s2 1]);

		zim = rA.generateZoomedRoiImage(rA.guiSelectedRoiIds, 0, 1, 10);
		idx = find(zim(:,:,1) == roi.color(1) & ...
		           zim(:,:,2) == roi.color(2) & ...
		           zim(:,:,3) == roi.color(3));
  	lzim = reshape(zim,[],1);
    zim = 0.5*zim/median(lzim);
		adjimT = zim(:,:,1) ; adjimT(idx) = roi.color(1) ; zim(:,:,1) = adjimT;
		adjimT = zim(:,:,2) ; adjimT(idx) = roi.color(2) ; zim(:,:,2) = adjimT;
		adjimT = zim(:,:,3) ; adjimT(idx) = roi.color(3) ; zim(:,:,3) = adjimT;
		midx = find(zim ~= 1);
		imshow(zim,'Parent', obj.zoomAxesH(3), 'Border','tight','InitialMagnification','fit'); 
		set(obj.zoomAxesH(3), 'DataAspectRatio', [s1 s2 1]);

		zim = rA.generateZoomedRoiImage(rA.guiSelectedRoiIds, 1, 0, 10);
		idx = find(zim(:,:,1) == roi.color(1) & ...
		           zim(:,:,2) == roi.color(2) & ...
		           zim(:,:,3) == roi.color(3));
  	lzim = reshape(zim,[],1);
    zim = 0.5*zim/median(lzim);
		adjimT = zim(:,:,1) ; adjimT(idx) = roi.color(1) ; zim(:,:,1) = adjimT;
		adjimT = zim(:,:,2) ; adjimT(idx) = roi.color(2) ; zim(:,:,2) = adjimT;
		adjimT = zim(:,:,3) ; adjimT(idx) = roi.color(3) ; zim(:,:,3) = adjimT;
		midx = find(zim ~= 1);
		imshow(zim,'Parent', obj.zoomAxesH(4), 'Border','tight','InitialMagnification','fit'); 
		set(obj.zoomAxesH(4), 'DataAspectRatio', [s1 s2 1]);

		set(obj.zoomFigH, 'NumberTitle', 'off', 'name', ['ROI ID: ' num2str(rA.guiSelectedRoiIds) ' (count: ' num2str(length(rA.rois)) ')']);
	else
	  disp('Select a *single* ROI to do zoom');
	end


