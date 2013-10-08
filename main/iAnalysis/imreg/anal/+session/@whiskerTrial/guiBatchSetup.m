%
% SP Oct 2010
% 
% Brings up GUI for setting up batch processing of all movies in a directory.
%
% USAGE: 
%
%   wt.guiBatchSetup (obj, subFunction, subFunctionParams)
%
function guiBatchSetup (obj, subFunction, subFunctionParams)
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
  if (isfield(obj.guiData, 'batchSetup'))
	  if (~ishandle(obj.guiData.batchSetup.figH) | ~ishandle(obj.guiData.batchSetup.panelH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % figure
	if (~ alreadyPresent)
		figH = figure('Position',[900 150 400 500], 'DockControls', 'off', 'Menubar', 'none', 'Name', 'Batch Setup', 'NumberTitle', 'off');

		% GUI panel
		panelH = uipanel('Position',[.025 .025 .95 .95]);%, 'Title', 'Batch Setup', 'TitlePosition', 'centertop');

		% numWhiskers
		uicontrol(panelH,'Style','Text','Units','normalized','String','Number of Whiskers:','Position',[.025 .94 .35 .04], 'HorizontalAlignment','right');
		numWhiskersH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.numWhiskers),'Position',[.4 .94 .1 .06]);
		uicontrol(panelH,'Style','Text','Units','normalized','String','Tags:','Position',[.51 .94 .13 .04], 'HorizontalAlignment','right');
		if (length(obj.whiskerTag) > 1)
			tstr = char(obj.whiskerTag{1}); for t=2:length(obj.whiskerTag) ; tstr = [tstr ' ' char(obj.whiskerTag{t})]; end
		else 
		  tstr = '';
		end
		whiskerTagH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',tstr,'Position',[.71 .94 .25 .06], 'TooltipString', 'SPACE separated list of whisker names -- important once you build up sessions');

		% maxFollicleY
		uicontrol(panelH,'Style','Text','Units','normalized','String','Maximal Follicle Y:','Position',[.025 .86 .45 .04], 'HorizontalAlignment','right');
		maxFollicleYH= uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.maxFollicleY),'Position',[.55 .86 .2 .06]);
		maxFollicleYButtonH= uicontrol(panelH,'Style','PushButton','Units','normalized','String','Select Point','Position',[.77 .86 .22 .04], 'Callback', {@selectPoint, obj, 1});

		% minWhiskerLength
		uicontrol(panelH,'Style','Text','Units','normalized','String','Minimal Whisker Length:','Position',[.025 .78 .45 .04], 'HorizontalAlignment','right');
		minWhiskerLengthH= uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.minWhiskerLength),'Position',[.55 .78 .2 .06]);
		minWhiskerLengthButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Draw Line','Position',[.77 .78 .22 .04], 'Callback', {@drawLine, obj, 1});

		% positionDirection
		uicontrol(panelH,'Style','Text','Units','normalized','String','Whisker Numbering:','Position',[.025 .70 .45 .04], 'HorizontalAlignment','right');
		pd = 1; if (obj.positionDirection == -1) ; pd = 2; end
		positionDirectionH = uicontrol(panelH,'Style','popup', 'Units','normalized','String','Left-to-Right | Right-to-Left','Position',[.55 .70 .4 .06], 'Value', pd);

		% polynomialDistanceFromFace
		uicontrol(panelH,'Style','Text','Units','normalized','String','Parabola Dist from Follicle:','Position',[.025 .62 .45 .04], 'HorizontalAlignment','right');
		polyDFromFaceH= uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.polynomialDistanceFromFace),'Position',[.55 .62 .2 .06]);

		% polynomialFitMaxFollicleY
		uicontrol(panelH,'Style','Text','Units','normalized','String','Max Polynomial Follicle Y:','Position',[.025 .56 .45 .04], 'HorizontalAlignment','right');
		polyMaxFollYH= uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.polynomialFitMaxFollicleY),'Position',[.55 .56 .2 .05]);
		polyMaxFollYButtonH= uicontrol(panelH,'Style','PushButton','Units','normalized','String','Select Point','Position',[.77 .56 .22 .04], 'Callback', {@selectPoint, obj, 2});

		% polynomialFitMaxFollicleY
		uicontrol(panelH,'Style','Text','Units','normalized','String','Parabola Offset:','Position',[.025 .5 .45 .04], 'HorizontalAlignment','right');
		if(length(obj.polynomialOffset) >= 3)
  		polyOffsH= uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.polynomialOffset(3)),'Position',[.55 .5 .2 .05]);
		else
  		polyOffsH= uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String','0','Position',[.55 .5 .2 .05]);
		end

		uicontrol(panelH,'Style','Text','Units','normalized','String','Where to measure the following at:','Position',[.025 .44 .95 .04], 'HorizontalAlignment','center');
		% kappaPositionType
		uicontrol(panelH,'Style','Text','Units','normalized','String','Kappa:','Position',[.025 .38 .11 .04], 'HorizontalAlignment','center');
		if (length(obj.kappaPositionType) == 0) ; obj.kappaPositionType = 4 ; end
		kappaPosTypeH = uicontrol(panelH,'Style','popup', 'Units','normalized','String','Polynomial Intersect|Follicle|Distance from Follicle|Distance from poly int.|Fraction dist foll|Fraction dist poly int','Position',[.13 .37 .5 .06], 'Value', obj.kappaPositionType);
		% kappaPosition
		kappaPosH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.kappaPosition),'Position',[.65 .38 .1 .06]);
		kappaPosButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Draw Line','Position',[.77 .38 .22 .04], 'Callback', {@drawLine, obj, 2});

		% thetaPositionType
		uicontrol(panelH,'Style','Text','Units','normalized','String','Theta:','Position',[.025 .30 .11 .04], 'HorizontalAlignment','center');
		if (length(obj.thetaPositionType) == 0) ; obj.thetaPositionType = 1 ; end
		thetaPosTypeH = uicontrol(panelH,'Style','popup', 'Units','normalized','String','Polynomial Intersect|Follicle|Distance from Follicle|Distance from poly int.|Fraction dist foll|Fraction dist poly int','Position',[.13 .29 .5 .06], 'Value', obj.thetaPositionType);
		% thetaPosition
		thetaPosH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(obj.thetaPosition),'Position',[.65 .30 .1 .06]);
		thetaPosButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Draw Line','Position',[.77 .30 .22 .04], 'Callback', {@drawLine, obj, 3});

    % stuff for parallel processing
		uicontrol(panelH,'Style','Text','Units','normalized','String','Whiskers file source wc:','Position',[.01 .20 .45 .04], 'HorizontalAlignment','left');
		batchSourceH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String','','Position',[.46 .20 .4 .06], 'TooltipString', 'get_fluo_dirs_from_wc compatible path.');
		uicontrol(panelH,'Style','PushButton','Units', 'normalized', 'String','Select','Position',[.87 .21 .12 .04], 'Callback', {@selectSourceDir, obj});
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Select parfile*.mat dir:','Position',[.025 .10 .45 .06], 'Callback', {@selectParfileDir, obj});
		defaultOutput = ['~' filesep 'sci' filesep 'anal' filesep 'par' filesep];
		parOutputH = uicontrol(panelH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',defaultOutput,'Position',[.5 .10 .45 .06]);

		% save/apply buttons
		uicontrol(panelH,'Style','PushButton','Units', 'normalized', 'String','Apply to Current Object','Position',[.15 .055 .39 .04], 'Callback', {@applyBatchParams, obj});
		uicontrol(panelH,'Style','PushButton','Units', 'normalized', 'String','Generate Parfiles','Position',[.55 .055 .29 .04], 'Callback', {@generateParfiles, obj});
		uicontrol(panelH,'Style','PushButton','Units', 'normalized', 'String','Save Params','Position',[.2 .01 .28 .04], 'Callback', {@saveBatchParams, obj});
		uicontrol(panelH,'Style','PushButton','Units', 'normalized', 'String','Load Params','Position',[.5 .01 .28 .04], 'Callback', {@loadBatchParams, obj});

		% build uiElements
		uiElements.numWhiskersH = numWhiskersH;
		uiElements.whiskerTagH = whiskerTagH;
		uiElements.maxFollicleYH = maxFollicleYH;
		uiElements.maxFollicleYButtonH = maxFollicleYButtonH;
		uiElements.minWhiskerLengthH = minWhiskerLengthH;
		uiElements.minWhiskerLengthButtonH = minWhiskerLengthButtonH;
		uiElements.positionDirectionH = positionDirectionH;
		uiElements.polyDFromFaceH = polyDFromFaceH;
		uiElements.polyMaxFollYH = polyMaxFollYH;
		uiElements.polyMaxFollYButtonH = polyMaxFollYButtonH;
		uiElements.polyOffsH = polyOffsH;
		uiElements.kappaPosTypeH = kappaPosTypeH;
		uiElements.kappaPosH = kappaPosH;
		uiElements.kappaPosButtonH = kappaPosButtonH;
		uiElements.thetaPosTypeH = thetaPosTypeH;
		uiElements.thetaPosH = thetaPosH;
		uiElements.thetaPosButtonH = thetaPosButtonH;
		uiElements.batchSourceH = batchSourceH; 
		uiElements.parOutputH = parOutputH;

		% barFractionTrajectoryInReach
		% barInReachParameterUsed

		obj.guiData.batchSetup.panelH = panelH; % to allow check for existence

		% Assign gui data initially
		assignGuiData(obj, figH, '', uiElements);
	else
	  figure (obj.guiData.batchSetup.figH);
	end

%
% Pulls variables from obj.guiData.batchSetup
%
function [figH outputPath uiElements] = decomposeGuiData(obj)
  figH = obj.guiData.batchSetup.figH;
	outputPath = obj.guiData.batchSetup.outputPath;
	uiElements = obj.guiData.batchSetup.uiElements;

%
% ASsigns obj.guiData.batchSetup variables
%
function assignGuiData(obj, figH, outputPath, uiElements)
  obj.guiData.batchSetup.figH = figH;
	obj.guiData.batchSetup.outputPath = outputPath;
	obj.guiData.batchSetup.uiElements = uiElements;
	
%
% Generates parfile_xxx.mat files for par_exec to run . . . 
%
function generateParfiles(hObj, event, obj)
  [figH outputPath uiElements] = decomposeGuiData(obj);
	outputPath = get(uiElements.parOutputH, 'String');
	sourceString = get(uiElements.batchSourceH, 'String');
  obj.generateParFiles( sourceString, outputPath);

%
% Allows you to select par output dir
%
function selectParfileDir(hObj, event, obj)
	startDir = get(obj.guiData.batchSetup.uiElements.parOutputH, 'String');
  outputDir = uigetdir(startDir);

	% update in gui 
	set(obj.guiData.batchSetup.uiElements.parOutputH, 'String', outputDir);

	
%
% Allows you to select source directory
%
function selectSourceDir(hObj, event, obj)
  sourceDir = uigetdir();

	% append .whiskers
	sourcePath = [sourceDir filesep '*.whiskers'];

	% update in gui 
	set(obj.guiData.batchSetup.uiElements.batchSourceH, 'String', sourcePath);


%
% starts letting user draw a point definining various parameters depending on
%  mode:
%   1: maxFollicleY
%   2: polynomialFitMaxFollicleY
%
function selectPoint(hObj, event, obj, mode)
  % pull guiData.batchSetup
  [figH outputPath uiElements] = decomposeGuiData(obj);

	switch mode
	  case 1 % maxFollicleY
		  bh = uiElements.maxFollicleYButtonH;
		  th = uiElements.maxFollicleYH;
		case 2 % polynomialFitMaxFollicleY
		  bh = uiElements.polyMaxFollYButtonH;
		  th = uiElements.polyMaxFollYH;
	end

  % 1) give user message and start draw
	set(bh,'Value', get(bh,'Max'));
	disp('Select a point.');
	op = get(obj.guiData.frameBrowser.figH, 'Pointer');
	set(obj.guiData.frameBrowser.figH, 'Pointer', 'fullcrosshair');
	figure(obj.guiData.frameBrowser.figH);
	pointParams = ginput(1);
	set(obj.guiData.frameBrowser.figH, 'Pointer', op);

	% 2) process return results
	set (th, 'String', num2str(pointParams(2)));

	% 3) de-depress & redraw
	set(bh,'Value', get(bh, 'Min'));
	obj.guiFrameBrowser('drawImage');

	% assign again
  assignGuiData(obj, figH,  outputPath, uiElements);

%
% starts letting user draw a line definining various parameters depending on
%  mode:
%   1: minWhiskerLength
%   2: kappaPosition
%   3: thetaPosition
%
function drawLine(hObj, event, obj, mode)
  [figH outputPath uiElements] = decomposeGuiData(obj);

	switch mode
	  case 1 % minWhiskerLength 
		  bh = uiElements.minWhiskerLengthButtonH;
		  th = uiElements.minWhiskerLengthH;
		case 2 % kappa Position
		  bh = uiElements.kappaPosButtonH;
		  th = uiElements.kappaPosH;
		case 3 % theta Position
		  bh = uiElements.thetaPosButtonH;
		  th = uiElements.thetaPosH;
	end

	% 0) sanity check -- we only allow lines for kappa, theta if 
	%    appropriate type (3,4)
	if (mode == 2)
	  kt = get(uiElements.kappaPosTypeH, 'Value');
		if (kt ~= 3 & kt ~= 4)
		  disp('Must have a length-based kappa to use this.');
			return;
		end
	elseif (mode == 3)
	  tt = get(uiElements.thetaPosTypeH, 'Value');
		if (tt ~= 3 & tt ~= 4)
		  disp('Must have a length-based theta to use this.');
			return;
		end
	end

  % 1) give user message and start draw
	set(bh,'Value', get(bh,'Max'));
	disp('Draw a line; once you are done, double click it.');

  h = imline(obj.guiData.frameBrowser.axisH);

	% 2) depress the button & wait
	lineParms = wait(h);

	% 3) process return results
	length = sqrt(sum(diff(lineParms).^2));
	set (th, 'String', num2str(length));

	% 4) de-depress & redraw
	set(bh,'Value', get(bh,'Min'));
	obj.guiFrameBrowser('drawImage');

	 

%
% Loads existing file
%
function loadBatchParams(hObj, event, obj)
  % pull guiData.batchSetup
  [figH outputPath uiElements] = decomposeGuiData(obj);
 
  % invoke gui asking user for fname
  [filename, pathname] = uigetfile({'*.mat', '.MAT file'},'Pick batch parameters file');

  % if the user did something, implement it
	if (filename ~= 0)
		bp = load([pathname filename]);

		% set all parameters ...
		set(uiElements.numWhiskersH,'String',num2str(bp.numWhiskers));
		tstr = char(bp.whiskerTag{1}); for t=2:length(bp.whiskerTag) ; tstr = [tstr ' ' char(bp.whiskerTag{t})]; end
		set(uiElements.whiskerTagH,'String',tstr);
		set(uiElements.minWhiskerLengthH, 'String',num2str(bp.minWhiskerLength));
		set(uiElements.maxFollicleYH, 'String',num2str(bp.maxFollicleY));
		if (bp.positionDirection == 1) ; v = 1; else ; v = 2 ;end
		set(uiElements.positionDirectionH, 'Value', v);
		set(uiElements.polyDFromFaceH,'String',num2str(bp.polynomialDistanceFromFace));
		set(uiElements.polyMaxFollYH,'String',num2str(bp.polynomialFitMaxFollicleY));
		set(uiElements.kappaPosTypeH,'Value',bp.kappaPositionType );
		set(uiElements.kappaPosH,'String',num2str(bp.kappaPosition ));
		set(uiElements.thetaPosTypeH,'Value',bp.thetaPositionType );
		set(uiElements.thetaPosH,'String',num2str(bp.thetaPosition));
		if (isfield(bp, 'polynomialOffset')) ; set(uiElements.polyOffsH,'String',num2str(bp.polynomialOffset)); end

		% assign again
		outputPath = []; % clear it -- dont want to overwrite but also dont want to write weird
		assignGuiData(obj, figH,  outputPath, uiElements);
	end

%
% When pressed, saves to file.  
%
function saveBatchParams(hObj, event, obj)
  % pull guiData.batchSetup
  [figH outputPath uiElements] = decomposeGuiData(obj);

	% is there an output path?
	proceed = 0;
	if (length(outputPath) > 0)
	  proceed = 1;
	else
	  [filename, pathname] = uiputfile('batchParameters.mat', 'Give an output .MAT filename');
    if isequal(filename,0) || isequal(pathname,0)
      disp('Action canceled');
    else
		  outputPath = [pathname filename];
      proceed = 1;
    end
	end

	% and save
	if (proceed)
	  disp(['saveBatchParams::wrote batch parameters to ' outputPath]);

 [numWhiskers whiskerTag minWhiskerLength maxFollicleY positionDirection ...
    polynomialDistanceFromFace polynomialFitMaxFollicleY kappaPositionType ...
		kappaPosition thetaPositionType thetaPosition polynomialOffset] = getWhiskerTrialParametersFromGui(obj);
	barFractionTrajectoryInReach = obj.barFractionTrajectoryInReach;
	barInReachParameterUsed = obj.barInReachParameterUsed;
  save (outputPath, 'numWhiskers', 'minWhiskerLength', 'maxFollicleY', 'positionDirection',...
	  'polynomialDistanceFromFace', 'polynomialFitMaxFollicleY', 'kappaPositionType', ...
		'kappaPosition', 'thetaPositionType', 'thetaPosition', 'barFractionTrajectoryInReach', ...
    'barInReachParameterUsed', 'whiskerTag', 'polynomialOffset');
 
		% assign again
    assignGuiData(obj, figH,  outputPath, uiElements);
	end

%
% This will apply the batch parametesrs to the CURRENT object obj
%
function applyBatchParams(hObj, event,obj)
  [numWhiskers whiskerTag minWhiskerLength maxFollicleY positionDirection ...
    polynomialDistanceFromFace polynomialFitMaxFollicleY kappaPositionType ...
		kappaPosition thetaPositionType thetaPosition polynomialOffset] = getWhiskerTrialParametersFromGui(obj);
  obj.numWhiskers = numWhiskers;
	obj.whiskerTag = whiskerTag;
	obj.minWhiskerLength = minWhiskerLength;
	obj.maxFollicleY = maxFollicleY;
	obj.positionDirection = positionDirection;
	obj.polynomialDistanceFromFace = polynomialDistanceFromFace;
	obj.polynomialFitMaxFollicleY = polynomialFitMaxFollicleY;
	obj.kappaPositionType = kappaPositionType;
	obj.kappaPosition = kappaPosition;
	obj.thetaPositionType = thetaPositionType;
	obj.thetaPosition = thetaPosition;
	obj.polynomialOffset = [0 0 polynomialOffset];

	disp('guiBatchSetup::applied batch parameters to current object.');

%
% Returns values from the gui that can be immediately assigned to a whiskerTrial
%  object
%
function [numWhiskers whiskerTag minWhiskerLength maxFollicleY positionDirection ...
    polynomialDistanceFromFace polynomialFitMaxFollicleY kappaPositionType ...
		kappaPosition thetaPositionType thetaPosition polynomialOffset] = getWhiskerTrialParametersFromGui(obj)
  % pull guiData.batchSetup
  [figH outputPath uiElements] = decomposeGuiData(obj);

  % build uiElements
	numWhiskers = str2num(get(uiElements.numWhiskersH,'String'));
	s = lower(get(uiElements.whiskerTagH,'String'));
	si = find(s == ' ');
	if (length(si) ~= numWhiskers-1) 
	  disp('guiBatchSetup::Use space as separator for whisker tags; specify a name for EACH!');
	else
	  if (numWhiskers == 1)
		  whiskerTag{1} = s;
		else
		  whiskerTag{1} = s(1:si(1)-1);
			for w=2:numWhiskers-1 
				whiskerTag{w} = s(si(w-1)+1:si(w)-1);
			end
			whiskerTag{numWhiskers} = s(si(numWhiskers-1)+1:length(s));
		end
	end
	minWhiskerLength = str2num(get(uiElements.minWhiskerLengthH, 'String'));
	maxFollicleY = str2num(get(uiElements.maxFollicleYH, 'String'));
	pd = get(uiElements.positionDirectionH, 'Value');
	if (pd == 1) ; positionDirection = 1; else ; positionDirection = -1; end
	polynomialDistanceFromFace = str2num(get(uiElements.polyDFromFaceH,'String'));
	polynomialFitMaxFollicleY = str2num(get(uiElements.polyMaxFollYH,'String'));
	kappaPositionType = get(uiElements.kappaPosTypeH,'Value');
	kappaPosition = str2num(get(uiElements.kappaPosH,'String'));
	thetaPositionType = get(uiElements.thetaPosTypeH,'Value');
	thetaPosition = str2num(get(uiElements.thetaPosH,'String'));
	polynomialOffset = str2num(get(uiElements.polyOffsH,'String'));


