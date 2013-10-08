%
% SP Dec 2010
% 
% GUI for manipulating workingImage properties (luminance etc.)
%
% USAGE: 
%
%   rA.guiWorkingImageControl (obj, subFunction, subFunctionParams)
%
function guiWorkingImageControl (obj, subFunction, subFunctionParams)
  if (nargin == 1)
	  startGui(obj);
	elseif (nargin == 2) % call eval w/ blank
	  eval([subFunction '(obj);']);
	else % call eval
	  eval([subFunction '(obj, subFunctionParams);']);
	end

%
% starts the gui
%
function startGui(obj)
	% --- gui setup 
	alreadyPresent = 1;
  if (isfield(obj.guiData, 'workingImageControl'))
	  if (~ishandle(obj.guiData.workingImageControl.figH) | ~ishandle(obj.guiData.workingImageControl.panelH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % figure
	if (~ alreadyPresent)
	  guiTitle = ['Img Ctrl for ' obj.idStr];
		figH = figure('Position',[700 150 400 150], 'DockControls', 'off', 'Menubar', 'none', ...
		  'Name', guiTitle, 'NumberTitle', 'off');

		% GUI panel
		panelH = uipanel('Position',[.025 .025 .95 .95]);%, 'Title', 'Batch Setup', 'TitlePosition', 'centertop');

		tbh = 30; % text, button height
		tfo = 10; % how much to push text down if it is with a field
		fh = 25; % text ENTRY field height
		sh = 5; % spacer height
		sw = 2; % spacer width

		y = 140;

		% min/maxpixel value 
    x = sw;
		y = y-fh-sh;
		w = 120;
		uicontrol(panelH,'Style','Text','Units','pixels','String','Min Pix Value:', ...
		  'Position',[x y-tfo w tbh], 'HorizontalAlignment','left');
		x = x+w+sw;
		w = 80;
		minPixValH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','pixels', ...
		  'String','0','Position',[x y w fh], 'Callback', {@implementGuiParameters, obj});

    x = sw;
		y = y-fh-sh;
		w = 120;
		uicontrol(panelH,'Style','Text','Units','pixels','String','Max Pix Value:','Position',...
		  [x y-tfo w tbh], 'HorizontalAlignment','left');
		x = x+w+sw;
		w = 80;
		maxPixValH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','pixels', ...
		  'String',num2str(roi.roiArray.maxImagePixelValue),'Position',[x y w fh], 'Callback', {@implementGuiParameters, obj});


    % normalization gaussian
    x = sw;
		y = y-fh-sh;
		w = 280;
		uicontrol(panelH,'Style','Text','Units','pixels','String','Divide by gauss-conv of size (fractional):', ...
		  'Position',[x y-tfo w tbh], 'HorizontalAlignment','left');%, 'VerticalAlignment', 'middle');
		x = x+w+sw;
		w = 40;
		gaussFracSizeH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','pixels', ...
		  'String',num2str(0),'Position',[x y w fh], 'Callback', {@implementGuiParameters, obj});

		% colormap selector
    x = sw;
		y = y-fh-sh;
		w = 80;
		uicontrol(panelH,'Style','Text','Units','pixels','String','Colormap:','Position',...
		  [x y-tfo w tbh], 'HorizontalAlignment','left');
	  x=x+w+sw;
		w= 260; 
		cmMenuH = uicontrol(panelH,'Style','Popup','Units','pixels', ...
		  'String',{'Greyscale', 'Jet', 'Red/Blue'},'Value',1,'Position',[x y-tfo/2 w tbh], 'Callback', {@implementGuiParameters,obj});

		% build uiElements
		uiElements.minPixValH = minPixValH;
		uiElements.maxPixValH = maxPixValH;
		uiElements.gaussFracSizeH = gaussFracSizeH;
		uiElements.cmMenuH = cmMenuH;

		obj.guiData.workingImageControl.panelH = panelH; % to allow check for existence

		% Assign gui data initially
		assignGuiData(obj, figH, uiElements);

		% settings? set position
		if (length(obj.settings.workingImageControlFigPos) > 0)
		  set(figH, 'Position', obj.settings.workingImageControlFigPos);
		end
	else
	  figure (obj.guiData.workingImageControl.figH);
	end

%
% Pulls variables from obj.guiData.workingImageControl
%
function [figH uiElements] = decomposeGuiData(obj)
  figH = obj.guiData.workingImageControl.figH;
	uiElements = obj.guiData.workingImageControl.uiElements;

%
% ASsigns obj.guiData.workingImageControl variables
%
function assignGuiData(obj, figH, uiElements)
  obj.guiData.workingImageControl.figH = figH;
	obj.guiData.workingImageControl.uiElements = uiElements;
	
% 
% Updates the image based on your requests
%
function implementGuiParameters(hObj, event,obj)
 obj.applyWorkingImageControl();
 obj.updateImage();

