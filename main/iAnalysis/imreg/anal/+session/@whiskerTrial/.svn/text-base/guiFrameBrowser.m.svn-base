%
% SP Oct 2010
% 
% Brings up GUI for browsing frames.
%
% USAGE: 
%
%   wt.guiFrameBrowser(subFunction, subFunctionParams)
%
% subFunction: if blank, just start the gui (startGui), otherwise will do 
%              eval('subFunction(obj, subFunctionParams)')
% subFunctionParams: parameters passed to subFunction ; can be blank, in 
%              which case eval is off of subFunction(obj)
%
function guiFrameBrowser(obj, subFunction, subFunctionParams)
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
  % --- already one?
	alreadyPresent = 1;
  if (isfield(obj.guiData, 'frameBrowser'))
	  if (~ishandle(obj.guiData.frameBrowser.figH) | ~ishandle(obj.guiData.frameBrowser.axisH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % --- prelims
	obj.assignRandomColors(); % make sure colors good

	% --- gui setup
	if (~alreadyPresent)
		figH = figure('Position',[100 100 800 500], 'Name', 'Frame Browser', 'NumberTitle','off');

		% Plot image
		axisH = axes('Position',[0.01 .1 .98 .85]);

		% GUI panel
		panelH = uipanel('Position',[.025 .025 .95 .05]);

		% action buttons
		firstFButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','[','Position',[.01 .1 .025 .8], 'Callback', {@setFrame, obj, 1});
		prevButton3H = uicontrol(panelH,'Style','PushButton','Units','normalized','String','<<<','Position',[.04 .1 .05 .8], 'Callback', {@chgFrame, obj, -100});
		prevButton2H = uicontrol(panelH,'Style','PushButton','Units','normalized','String','<<','Position',[.1 .1 .05 .8], 'Callback', {@chgFrame, obj, -10});
		prevButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','<','Position',[.16 .1 .05 .8], 'Callback', {@chgFrame, obj, -1});
		nextButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','>','Position',[.22 .1 .05 .8], 'Callback', {@chgFrame, obj, 1});
		nextButton2H = uicontrol(panelH,'Style','PushButton','Units','normalized','String','>>','Position',[.28 .1 .05 .8], 'Callback', {@chgFrame, obj, 10});
		nextButton3H = uicontrol(panelH,'Style','PushButton','Units','normalized','String','>>>','Position',[.34 .1 .05 .8], 'Callback', {@chgFrame, obj, 100});
		lastFButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String',']', 'Position',[.40 .1 .025 .8], ...
			'Callback', {@setFrame, obj, obj.numFrames});
		playButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','>','BackgroundColor', [0 1  0], 'Position',[.46 .1 .05 .8], 'Callback', {@play, obj});
		stopButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','[]','BackgroundColor', [1 0  0], 'Position',[.52 .1 .05 .8], 'Callback', {@stop, obj});
%		plotTrajectoryButtonH = uicontrol(panelH,'Style','PushButton','Units','normalized','String','Plot Trajectories',...
%			'Position',[.84 .1 .15 .8], 'Callback', {@plotTraj, obj});
		showPolyButtonH = uicontrol(panelH,'Style','CheckBox','Units','normalized','String','Show Polynomial', 'ToolTipString', 'Show the fitted polynomial instead of the raw trajectory from whisk', 'Position',[.6 .1 .19 .8], 'Callback', {@toggleShowPoly, obj});
		spbm = get(showPolyButtonH, 'Min'); set(showPolyButtonH, 'Value', spbm);
		showDerivedButtonH = uicontrol(panelH,'Style','CheckBox','Units','normalized','String','Show Derived Stuff', 'Position',[.8 .1 .19 .8], 'Callback', {@toggleShowDerived, obj});
		sdbm = get(showDerivedButtonH, 'Max'); set(showDerivedButtonH, 'Value', sdbm);

		% Assign gui data initially
		assignGuiData(obj, figH, axisH,  1, 0, 1, 0);
	else % just select it
	  figure(obj.guiData.frameBrowser.figH);
	end

	% draw image
	drawImage(obj);

%
% Pulls variables from obj.guiData.frameBrowser
%
function [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj)
  figH = obj.guiData.frameBrowser.figH;
  axisH = obj.guiData.frameBrowser.axisH;
  frameIdx = obj.guiData.frameBrowser.frameIdx;
  playMovie = obj.guiData.frameBrowser.playMovie;
  showDerived = obj.guiData.frameBrowser.showDerived;
  showPoly = obj.guiData.frameBrowser.showPoly;

%
% ASsigns obj.guiData.frameBrowser variables
%
function assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly)
  obj.guiData.frameBrowser.figH = figH;
  obj.guiData.frameBrowser.axisH = axisH;
  obj.guiData.frameBrowser.frameIdx = frameIdx;
	obj.guiData.frameBrowser.playMovie = playMovie;
	obj.guiData.frameBrowser.showDerived = showDerived;
	obj.guiData.frameBrowser.showPoly = showPoly;

%
% Draws everything
%
function drawImage (obj)
  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);
  curAx = axis(axisH);

	% show derived?
	if (~ showDerived) ; plotOpts.bareBones = 1; end
	plotOpts.whiskerWidth = 2;

	if (showPoly) ; plotOpts.plotWhisker = 2 ; end
%	obj.plotFrame(frameIdx,axisH);
	obj.plotFrame(frameIdx,axisH,plotOpts);

	% update axis to preserve zoom ?
	if (sum(curAx == [0 1 0 1]) ~= 4)
	  axis(curAx);
	end


% 
% frame changer
%
function changeFrame (obj, dFrames)

  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);

	% get frame #
	frameIdx = frameIdx+dFrames;
	if (frameIdx > max(obj.frames)) ; frameIdx = 1; end
	if (frameIdx < 1) ; frameIdx = max(obj.frames) ; end

	% assign guiData.frameBrowser
	assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly);

	% draw - rectangle if available
	drawImage(obj);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% toggles showing of derived things (whiskers etc)
%
function toggleShowDerived(hObj, event,obj)

  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);

  if (showDerived == 1) ; showDerived = 0 ; else ; showDerived = 1; end

	% assign guiData.frameBrowser
	assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly);

	% redraw
	drawImage(obj);

% 
% toggles showing of polynomial
%
function toggleShowPoly(hObj, event,obj)

  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);

  if (showPoly== 1) ; showPoly = 0 ; else ; showPoly = 1; end

	% assign guiData.frameBrowser
	assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly);

	% redraw
	drawImage(obj);


%
% Plasys movie
%
function play(hObj, event, obj)
  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);
	playMovie = playMovie + 1;
	assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly);

  while(playMovie > 0)
		% get frame #
		frameIdx = frameIdx+playMovie;
		if (frameIdx > max(obj.frames)) ; frameIdx = 1; end
		if (frameIdx < 1) ; frameIdx = max(obj.frames) ; end

		% assign ONLY frameIdx
		obj.guiData.frameBrowser.frameIdx = frameIdx;

		% draw - rectangle if available
		drawImage(obj);
		
		% pull anew in case of stop
    [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);
	end

%
% Stop playback
%
function stop (hObj, event, obj)
  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);
	playMovie = 0;
	assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly);

% 
% if user clicks any of the frame change buttons, implements change
%
function chgFrame (hObj, event, obj, dFrames)
  changeFrame(obj, dFrames);


% 
% if user clicks any of the frame set buttons
%
function setFrame (hObj, event, obj, nFrameIdx)
  % pull guiData.frameBrowser
  [figH axisH frameIdx playMovie showDerived showPoly] = decomposeGuiData(obj);

	% get frame #
	frameIdx = nFrameIdx;

	% assign guiData.frameBrowser
	assignGuiData(obj, figH, axisH, frameIdx, playMovie, showDerived, showPoly);

	% draw - rectangle if available
	drawImage(obj);


% 
% wrapper for obj.plotPositionTrajectories
%
function plotTraj (hObj, event, obj, dFrames)
  obj.plotPositionTrajectory(obj.whiskerIds);


