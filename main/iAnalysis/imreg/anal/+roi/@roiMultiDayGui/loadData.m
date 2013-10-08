%
% SP Apr 2011
%
% Will load data from a directory with a sexy dialog.
%
% USAGE:
%
%  mdg.loadData(loadDir)
%
%    loadDir: directory to load from
% 
function loadData(obj, loadDir)

  % --- get filename(s) ...
  cwd = pwd();
	cd (loadDir);
  [fileName,sourceDir] = uigetfile('*.mat','Select the ROI files', 'MultiSelect', 'on');
	cd (cwd);
	if (~iscell(fileName) && fileName == 0) ; fileName = []; end

	% --- select
	if (length(fileName) ~= 0)
	  obj.roiArrayArray = {}; % clear previous if exists
    if (~iscell(fileName)) ; fileName = {fileName}; end
	 
	  % --- load em
		idList = {};
		for i=1:length(fileName)
	    rA = roi.roiArray.loadFromFile([sourceDir filesep fileName{i}]);
			obj.roiArrayArray{i} = rA;
      idList{i} = rA.idStr;
	  end
		rA = obj.roiArrayArray{1};
		obj.rAidx = 1;

		% --- clear gui variables and assign defaults
		rA.guiHandles = [];
		rA.guiMouseMode = 0;
		rA.guiSelectedRoiIds = []; 
		rA.guiShowFlags = [1 1 1 0];
		rA.guiPolyCorners = [];
		rA.updateImagePostFunction = @obj.updateGui;
		rA.updateImagePostFunctionParams = [];

		% --- initialize the gui
		obj.guiWrapper('startGui');

		% --- setup roiArrayAxesH
		if (length(obj.roiArrayArray) > 0)
			if (length(obj.roiArrayFigH) == 0 |  ~ishandle(obj.roiArrayFigH) )
				obj.roiArrayFigH = figure;
			end

			% prepare the axes
			if (length(obj.roiArrayAxesH) == 0 | ~ ishandle(obj.roiArrayAxesH))
				figure(obj.roiArrayFigH);
				obj.roiArrayAxesH = axes;
			else
				figure(obj.roiArrayFigH);
				delete(obj.roiArrayAxesH);
				obj.roiArrayAxesH = axes;
			end

			% connect to roiArrayArray
			rA = obj.roiArrayArray{1};
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
			rA.guiCreateRoiArrayMenu(figRef);

			% --- event hooks ...
			set(figRef, 'KeyPressFcn', {@roi.roiMultiDayGui.figKeyPressProcessor,obj});
			set(imRef,'ButtonDownFcn', {@roi.roiMultiDayGui.figMouseClickProcessor,obj}); 

			% --- connect to day list
			set(obj.dayMenuH,'String',idList);
			set(obj.dayMenuH,'Value', 1);

			% title figure
			set(obj.roiArrayFigH, 'name', rA.idStr);
		end
  end		

