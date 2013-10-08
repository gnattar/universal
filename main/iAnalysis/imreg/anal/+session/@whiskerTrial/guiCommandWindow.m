%
% SP Oct 2010
% 
% Brings up GUI with major command buttons.
%
% USAGE: 
%
%   wt.guiCommandWindow(subFunction ,subFunctionParams)
%   
%   usually go parameter-less; otherwise, lookup which function you want.
%
function guiCommandWindow(obj, subFunction, subFunctionParams)
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
  if (isfield(obj.guiData, 'commandWindow'))
	  if (~ishandle(obj.guiData.commandWindow.figH) | ~ishandle(obj.guiData.commandWindow.panelH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % figure
	if (~ alreadyPresent)
		figH = figure('Position',[900 450 200 200], 'DockControls', 'off', 'Menubar', 'none', 'Name', 'Command Window' ,'NumberTitle', 'off' );

		% GUI panel
		panelH = uipanel('Position',[.025 .025 .95 .95]); %, 'Title', 'Bar Selector', 'TitlePosition', 'centertop');

		% action buttons
		bh = 0.09; y = 0.01;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Plot Position Trajectories','Position',[.025 y .95 bh], 'Callback', {@plotTraj, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Plot Kappas','Position',[.025 y .95 bh], 'Callback', {@plotKappas, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Plot Thetas','Position',[.025 y .95 bh], 'Callback', {@plotThetas, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Run Linker','Position',[.025 y .95 bh], 'Callback', {@runLinker, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Get Whisker Params','Position',[.025 y .95 bh], 'Callback', {@runComputeWP, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Track Bar','Position',[.025 y .95 bh], 'Callback', {@runTrackBar, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Compute Kappas','Position',[.025 y .95 bh], 'Callback', {@runComputeKappas, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Compute Thetas','Position',[.025 y .95 bh], 'Callback', {@runComputeThetas, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Compute Distance to Bar','Position',[.025 y .95 bh], 'Callback', {@runComputeDistanceToBar, obj}); y = y+bh;
		uicontrol(panelH,'Style','PushButton','Units','normalized','String','Detect Contacts','Position',[.025 y .95 bh], 'Callback', {@runDetectContacts, obj}); y = y+bh;

		% Assign gui data initially
		assignGuiData(obj, figH);
		obj.guiData.commandWindow.panelH = panelH; % to allow check for existence
	else
	  figure(obj.guiData.commandWindow.figH);
	end

%
% Pulls variables from obj.guiData.commandWindow
%
function [figH] = decomposeGuiData(obj)
  figH = obj.guiData.commandWindow.figH;

%
% ASsigns obj.guiData.commandWindow variables
%
function assignGuiData(obj, figH)
  obj.guiData.commandWindow.figH = figH;

% 
% wrapper for obj.plotPositionTrajectories
%
function plotTraj (hObj, event, obj, dFrames)
  obj.plotPositionTrajectory(obj.whiskerIds);

% 
% wrapper for obj.plotPositionTrajectories
%
function plotKappas(hObj, event, obj, dFrames)
  obj.plotKappas();

% 
% wrapper for obj.plotPositionTrajectories
%
function plotThetas(hObj, event, obj, dFrames)
  obj.plotThetas();

%
% starts linker
%
function runLinker(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.link();
	obj.waitBar = owb;

%
% calculate kappas
%
function runComputeKappas(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.computeKappas();
	obj.waitBar = owb;

%
% calculate thetas 
%
function runComputeThetas(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.computeThetas();
	obj.waitBar = owb;

%
% starts linker
%
function runComputeWP(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.computeWhiskerParams();
	obj.waitBar = owb;

%
% starts bar tracker
%
function runTrackBar(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.trackBar('barTemplate.mat');
	obj.waitBar = owb;

%
% runs distance to bar computation
%
function runComputeDistanceToBar(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.computeDistanceToBar();
	obj.waitBar = owb;

%
% runs contact detection
%
function runDetectContacts(hObj, event,obj)
  % pull guiData.commandWindow
	owb = obj.waitBar;
	obj.waitBar = 1;
	obj.detectContactsWrapper();
	obj.waitBar = owb;

