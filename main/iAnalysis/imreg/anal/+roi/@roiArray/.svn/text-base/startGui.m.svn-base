%
% Starts the internal GUI ; connects event hooks appropriately so that
%  the 'internal' functions are in charge.
%
function obj = startGui(obj)
	% --- working image!!
	if (size(obj.workingImage,1) == 0)
		disp('roiArray.startGui::requires valid workingImage.');
		return;
	end
	
  % relaunch if stale ... based off axes object
	if (length(obj.guiHandles) > 0)
	  if (~ ishandle(obj.guiHandles(2))) ; obj.guiHandles = []; end
	end

  if (sum(obj.guiHandles) == 0)
		% event hooks
		obj.workingImageMouseClickFunction = {@obj.guiMouseClickProcessor};
		obj.workingImageKeyPressFunction = {@obj.guiKeyStrokeProcessor};
		obj.updateImagePostFunction = @obj.updateGui;
		obj.updateImagePostFunctionParams = {};

		% clear gui variables and assign defaults -- but obey workingImageIndex,FrameIndex
		obj.guiHandles = [];
		obj.guiMouseMode = 0;
		obj.guiSelectedRoiIds = []; 
		obj.guiShowFlags = [1 1 0 0];
		obj.guiPolyCorners = [];

		% invoke figure FIRST time
		figRef = figure();
		[imRef axRef figRef] = obj.plotImage(obj.guiShowFlags(1), obj.guiShowFlags(2), ... 
												 obj.guiShowFlags(3), obj.guiSelectedRoiIds);
		hold on; % turn hold on
		obj.guiHandles = [imRef axRef figRef];
		obj.guiCreateRoiArrayMenu(figRef);

    % renderer
		switch computer 
			case {'MACI', 'MACI64'}
				renderer = 'opengl';
			case {'GLNXA64', 'GLNX86'}
				renderer = 'zbuffer';
			otherwise
				renderer = 'painters';
		end

		% connect hooks
		set(figRef,'KeyPressFcn', obj.workingImageKeyPressFunction);
		set(figRef,'RendererMode', 'manual', 'Toolbar', 'none', 'DockControls', 'off', ...
													 'Renderer', renderer, 'MenuBar', 'none');
%													 'Renderer', renderer, 'MenuBar', 'figure');
		set(imRef,'ButtonDownFcn', obj.workingImageMouseClickFunction);
		
		% title figure
		set(figRef, 'name', obj.idStr);

		% position it
		if (length(obj.settings.figRefPos) > 0)
		  set(figRef, 'Position', obj.settings.figRefPos);
		end
	else
	  disp('roiArray.startGui::already have a gui ; remove it or set obj.guiHandles = [].');
	end


