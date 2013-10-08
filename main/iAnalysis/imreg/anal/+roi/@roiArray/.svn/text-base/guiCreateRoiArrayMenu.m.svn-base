%
% S Peron May 2010
%
% This connects the basic roiArray pulldown menu to the desired figure object.
%  The menu contains options for things such as coloring by group sets etc.
% 
% usage: obj.guiCreateRoiArrayMenu(figRef)
%
% params: figRef: the handle of the figure object to which menu is connected
%
function obj = guiCreateRoiArrayMenu(obj, figRef)
  % --- delete old
	if(ishandle(obj.guiRoiArrayMenu)) ; delete(obj.guiRoiArrayMenu) ; end


  % --- set it up
  obj.guiRoiArrayMenu = uimenu('Parent', figRef, 'HandleVisibility','callback', ...
                        'Label','roiArray');

	mi = 1;
	% === MENU ITEMS

	% files 
	flistMenu =   uimenu('Parent',obj.guiRoiArrayMenu, ...
											 'Label','Select File', 'HandleVisibility','callback');

  for s=0:length(obj.accessoryImagesRelPaths)
	  % master Image
	  if (s == 0) 
			menuItemText = [obj.masterImageRelPath];
			menuItem  =   uimenu('Parent',flistMenu, ...
													 'Label',menuItemText, 'HandleVisibility','callback', ...
													 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
			obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.useMasterImage};
			mi = mi+1;
		  
		% acessory Image
		else
			menuItemText = [obj.accessoryImagesRelPaths{s}];
			menuItem  =   uimenu('Parent',flistMenu, ...
													 'Label',menuItemText, 'HandleVisibility','callback', ...
													 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
			obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.useAccessoryImage,s};
			mi = mi+1;
		end
	end

  % --- IMAGE FILE STUFF
	% set master image
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, ...
												 'Label','Set master image', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.selectMasterImage};
	mi = mi+1;

	% add accessory image
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, ...
												 'Label','Add accessory image', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.addAccessoryImageViaGui};
	mi = mi+1;

	% --- ROITOOLS
	% image control
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, 'Separator', 'on', 'Accelerator', 'i', ...
												 'Label','Image Control', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.guiWorkingImageControl};
	mi = mi+1;

	% zoom
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, ...
												 'Label','Zoom', 'Accelerator', 'z', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.guiZoomToggle};
	mi = mi+1;

	% pan
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, ...
												 'Label','Pan', 'Accelerator', 'x', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.guiPanToggle};
	mi = mi+1;

  % --- COLORING 
	% base colorings
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, 'Separator', 'on', ...
												 'Label','Single color', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.colorByBaseScheme,2};
	mi = mi+1;
	menuItem  =   uimenu('Parent',obj.guiRoiArrayMenu, ...
												 'Label','Rainbow color', 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
	obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.colorByBaseScheme,1};
	mi = mi+1;

	% group sets
	groupColMenu  =   uimenu('Parent',obj.guiRoiArrayMenu, ...
											 'Label','Color by group ...', 'HandleVisibility','callback');

  for s=1:length(obj.roiGroupArray.setIds)
	  menuItemText = [obj.roiGroupArray.setDescrStrs{s}];
	  setId = obj.roiGroupArray.setIds(s);
		menuItem  =   uimenu('Parent',groupColMenu, ...
												 'Label',menuItemText, 'HandleVisibility','callback', ...
												 'Callback', {@roiArrayMenuCallbackWrapper, obj, mi});
		obj.guiRoiArrayMenuCallbackFunction{mi} =  {@obj.colorByGroupSet,setId};
		mi = mi+1;
	end

%
% Wrapper for menu callbacks ; most of what you do does not care about hObject
%  or eventdata, and you want to call object functions transparently; this allows
%  that. 
%
function roiArrayMenuCallbackWrapper(hObject, eventdata, obj, menuItemId)
	L = length(obj.guiRoiArrayMenuCallbackFunction{menuItemId});
	if (L == 1)
		feval(obj.guiRoiArrayMenuCallbackFunction{menuItemId}{1});
	else % params
		feval(obj.guiRoiArrayMenuCallbackFunction{menuItemId}{1}, obj.guiRoiArrayMenuCallbackFunction{menuItemId}{2:L});
	end
