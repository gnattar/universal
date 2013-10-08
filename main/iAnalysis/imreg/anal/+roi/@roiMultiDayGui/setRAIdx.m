%
% SP Apr 2011
%
% IF you change the roiArray object from roiArrayArray that is selected, call 
%  this.  This will not only do the obvious, but also update guis etc.
%
% USAGE:
%
%  mdg.setRAIdx(rAidx)
%
%    rAidx: index that you want to use, within roiArrayArray cell array
%
function setRAIdx(obj, rAidx)
	oldRA = obj.roiArrayArray{obj.rAidx};
	obj.rAidx = rAidx;
	rA = obj.roiArrayArray{rAidx};

	% --- clear gui variables and assign defaults
	rA.guiHandles = []; % clear
	rA.guiMouseMode = 0; % always reset
	rA.guiSelectedRoiIds = intersect(rA.roiIds, oldRA.guiSelectedRoiIds); % work with same ones, if avail ...
	rA.guiShowFlags = oldRA.guiShowFlags;
	rA.guiPolyCorners = []; % always clear
	rA.updateImagePostFunction = @obj.updateGui;
	rA.updateImagePostFunctionParams = '';


	% --- initialize the gui
	if (~ ishandle(obj.roiArrayAxesH)) % broken?
		obj.roiArrayFigH = figure; % the main figure object
		obj.roiArrayAxesH = axes ; % the main figure object
	end
	figure(obj.roiArrayFigH);
	axes(obj.roiArrayAxesH);
	[imRef axRef figRef] = rA.plotImage(rA.guiShowFlags(1), rA.guiShowFlags(2), ... 
											 rA.guiShowFlags(3), rA.guiSelectedRoiIds);

	switch computer % computer-dependent renderer
		case {'MACI', 'MACI64'}
			renderer = 'opengl';
		case {'GLNXA64', 'GLNX86'}
			renderer = 'painters';
		otherwise
			renderer = 'painters';
	end

	set(obj.roiArrayFigH,'RendererMode', 'manual', 'Toolbar', 'none', 'DockControls', 'off', ...
		                           'Renderer', renderer, 'MenuBar', 'figure');
	hold on; % turn hold on
	rA.guiHandles = [imRef axRef figRef];
	if (ishandle(oldRA.guiRoiArrayMenu)) ;delete(oldRA.guiRoiArrayMenu); end
	rA.guiCreateRoiArrayMenu(figRef);

	% --- event hooks update
	set(figRef, 'KeyPressFcn', {@roi.roiMultiDayGui.figKeyPressProcessor,obj});
  set(imRef,'ButtonDownFcn', {@roi.roiMultiDayGui.figMouseClickProcessor, obj});

	% title figure
	set(figRef, 'name', rA.idStr);

	% pulldown menu
	set(obj.dayMenuH,'Value',rAidx);

	% zoom plot
  obj.updateZoomPlot();

	% multiday plot
  obj.updateCrossDayPlot();

