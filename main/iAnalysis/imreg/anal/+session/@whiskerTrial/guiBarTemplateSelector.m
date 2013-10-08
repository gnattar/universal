%
% SP Oct 2010
% 
% Brings up GUI for selecting the bar template.  Basically just some buttons
%  and invoke guiFrameBrowser.
%
% USAGE: 
%
%   wt.guiBarTemplateSelector (obj, subFunction, subFunctionParams)
%
function guiBarTemplateSelector(obj, subFunction, subFunctionParams)
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
	% --- setup frameBrowser
  if (isfield(obj.guiData, 'frameBrowser'))
	  if (~ishandle(obj.guiData.frameBrowser.figH))
		  obj.guiFrameBrowser();
		end
	else
	  obj.guiFrameBrowser();
	end

	% --- gui setup 
	alreadyPresent = 1;
  if (isfield(obj.guiData, 'barTemplateSelector'))
	  if (~ishandle(obj.guiData.barTemplateSelector.figH) | ~ishandle(obj.guiData.barTemplateSelector.panelH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % figure
	if (~ alreadyPresent)
		figH = figure('Position',[900 550 200 100], 'DockControls', 'off', 'Menubar', 'none', 'Name', 'Bar Selector' ,'NumberTitle', 'off' );

		% GUI panel
		panelH = uipanel('Position',[.025 .025 .95 .95]); %, 'Title', 'Bar Selector', 'TitlePosition', 'centertop');

		% action buttons
		squareButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Select Square','Position',[.025 .76 .95 .23], 'Callback', {@drawSquare, obj});
		saveButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Save Square','Position',[.025 .51 .95 .23], 'Callback', {@saveSquare, obj});
		trackBarH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Track Bar','Position',[.025 .26 .95 .23], 'Callback', {@runTrackBar, obj});
		barInReachH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Bar is in Reach','Position',[.025 .01 .95 .23], 'Callback', {@designateBarInReach, obj});

		% Assign gui data initially
		assignGuiData(obj, figH, [], '', [], [], []);
		obj.guiData.barTemplateSelector.panelH = panelH; % to allow check for existence
	else
	  figure(obj.guiData.barTemplateSelector.figH);
	end

%
% Pulls variables from obj.guiData.barTemplateSelector
%
function [figH rectPos outputPath barCenter barRadius barTemplateIm] = decomposeGuiData(obj)
  figH = obj.guiData.barTemplateSelector.figH;
	rectPos = obj.guiData.barTemplateSelector.rectPos;
	outputPath = obj.guiData.barTemplateSelector.outputPath;
	barCenter = obj.guiData.barTemplateSelector.barCenter;
	barRadius = obj.guiData.barTemplateSelector.barRadius;
	barTemplateIm = obj.guiData.barTemplateSelector.barTemplateIm;

%
% ASsigns obj.guiData.barTemplateSelector variables
%
function assignGuiData(obj, figH, rectPos, outputPath, barCenter, barRadius, barTemplateIm)
  obj.guiData.barTemplateSelector.figH = figH;
	obj.guiData.barTemplateSelector.rectPos = rectPos;
	obj.guiData.barTemplateSelector.outputPath = outputPath;
	obj.guiData.barTemplateSelector.barCenter = barCenter;
	obj.guiData.barTemplateSelector.barRadius = barRadius;
	obj.guiData.barTemplateSelector.barTemplateIm = barTemplateIm;

%
% sets up bar-in-reach
% 
function designateBarInReach(hObj, event, obj)
  % --- is barCenter already defined?
	abort = 0;
	if(length(obj.barCenter) == 0)
	  abort = 1;
	elseif (length(find(isnan(obj.barCenter(:,1)))) == length(obj.barCenter(:,1)))
	  abort = 1;
	end
	if (abort)
	  disp('designateBarInReach::must first track bar!');
	% --- compute position
	else
	  valVec = obj.barCenter(:,1);
	  if (obj.barInReachParameterUsed == 2)
	    valVec = obj.barCenter(:,2);
		elseif (obj.barInReachParameterUsed == 3)
	    valVec = obj.barTemplateCorrelation;
		elseif (obj.barInReachParameterUsed == 4)
	    valVec = obj.barVoltageTrace;
		end
		  
	  % get value for in reach ...
		inReachVal = nanmean(valVec(find(obj.barInReach)));
		outReachVal = nanmean(valVec(find(~obj.barInReach)));
		selectedFrameVal = valVec(obj.guiData.frameBrowser.frameIdx);
	  obj.barFractionTrajectoryInReach = min(1,abs(selectedFrameVal-outReachVal) / abs(inReachVal-outReachVal));
	end

%
% starts bar tracker
%
function runTrackBar(hObj, event,obj)
  % pull guiData.barTemplateSelector
  [figH rectPos outputPath barCenter barRadius barTemplateIm] = decomposeGuiData(obj);

	% bar path
	if (length(outputPath) == 0)
	  disp('guiBarTemplateSelector::you have not assigned bar template path ; using barTemplate.mat in current directory.');
		outputPath = 'barTemplate.mat';
	end
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.trackBar(outputPath);
	obj.waitBar = owb;


%
% starts letting user draw the square ; after it is done, shows user bar
%
function drawSquare(hObj, event, obj)
  % pull guiData.barTemplateSelector
  [figH rectPos outputPath barCenter barRadius barTemplateIm] = decomposeGuiData(obj);
 
  % --- get rectangle
	frameIdx = obj.guiData.frameBrowser.frameIdx;
	disp('Draw your rectangle; when done, double click in/on it.  Your rectangle');
	disp('  minimal dimension shoudl be AT LEAST 150% of the bar diameter. Also,');
	disp('  be sure to select a time when the bar is IN RANGE as correlation of');
	disp('  the template and the image is used to determine in-rangedness.');
  h = imrect(obj.guiData.frameBrowser.axisH);
	rectPos = wait(h);
	rectPos = round(rectPos);
	if (mod(rectPos(3),2) == 0) ; rectPos(3) = rectPos(3) + 1; end % make sure it is odd so center is valdi
	if (mod(rectPos(4),2) == 0) ; rectPos(4) = rectPos(4) + 1; end % make sure it is odd so center is valdi

	% assign guiData.barTemplateSelector
  assignGuiData(obj, figH, rectPos, outputPath, barCenter, barRadius, barTemplateIm);

	% --- fit
	disp('Fitted template will now appear ; if the center/radius fit is off, redo your template.  Otherwise, save.');
 
  % cut out the template of the image
	rectPos = round(rectPos);
	monoIm = obj.whiskerMovieFrames{frameIdx}.cdata;
	barTemplateIm = monoIm(rectPos(2):rectPos(2)+rectPos(4), rectPos(1):rectPos(1)+rectPos(3));

  % detect the bar center and radius
	maxRad = floor(min(rectPos(3), rectPos(4))/1.5/2);
	disp(['selectBarTemplate::using radius range of 5 to ' num2str(maxRad) 'pixles.']);
  [barCenter barRadius] = session.whiskerTrial.determineBarCenterAndRadiusForTemplate([2 maxRad], barTemplateIm);
	disp(['selectBarTemplate::bar radius: ' num2str(barRadius) ' pixels ; center (x y): ' num2str(barCenter)]);

	% assign again
  assignGuiData(obj, figH, rectPos, outputPath, barCenter, barRadius, barTemplateIm);

%
% When pressed, saves to file.  Will either save to passed filename OR prompt for filename.
%
function saveSquare (hObj, event, obj)
  % pull guiData.barTemplateSelector
  [figH rectPos outputPath barCenter barRadius barTemplateIm] = decomposeGuiData(obj);

	% is there an output path?
	proceed = 0;
	if (length(outputPath) > 0)
	  proceed = 1;
	else
	  [filename, pathname] = uiputfile('barTemplate.mat', 'Give an output .MAT filename');
    if isequal(filename,0) || isequal(pathname,0)
      disp('Action canceled');
    else
		  outputPath = [pathname filename];
      proceed = 1;
    end
	end

	% and save
	if (proceed)
	  disp(['selectBarTemplate::wrote bar temlpate to ' outputPath]);

		save(outputPath, 'barCenter', 'barRadius', 'barTemplateIm');
 
		% assign again
    assignGuiData(obj, figH, rectPos, outputPath, barCenter, barRadius, barTemplateIm);
	end

