%
% SP Dec 2010
% 
% Brings up GUI for controlling eventSeries plottd in guiTSBrowser as well as
%  invoking event-series averages.
%
% USAGE: 
%
%   wt.guiESControl(subFunction, subFunctionParams)
%
% subFunction: if blank, just start the gui (startGui), otherwise will do 
%              eval('subFunction(obj, subFunctionParams)')
% subFunctionParams: parameters passed to subFunction ; can be blank, in 
%              which case eval is off of subFunction(obj)
%
function guiESControl(obj, subFunction, subFunctionParams)
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
  % --- sanity
	if (~isfield(obj.guiData, 'TSBrowser'))
	  disp('TSBrowser required to do this.');
		return;
	end
	if (isempty(obj.guiData.TSBrowser.ESList))
	  disp('guiESControl::Makes no sense without eventSeries list!');
		return;
	end

  % --- already one?
	alreadyPresent = 1;
  if (isfield(obj.guiData, 'ESControl'))
	  if (~ishandle(obj.guiData.ESControl.figH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % --- prelims

	% build es list
	for e=1:length(obj.guiData.TSBrowser.ESList)
	  if (obj.guiData.TSBrowser.ESListOn(e))
			ESListStr{e} = ['<html><b>' obj.guiData.TSBrowser.ESList{e}.idStr '</b></html>'];
		else
			ESListStr{e} = obj.guiData.TSBrowser.ESList{e}.idStr;
		end
	end

	% --- gui setup
	if (~alreadyPresent)
    % figure
		figH = figure('Position',[500 500 300 600],'DockControls', 'off', 'Menubar', 'none',  'Name', 'EventSeries Control', 'NumberTitle','off');

		% gui elements
    sx = 0.05;
		sy = 0.01;
		y = 1-sy;
 
    bh = 0.05;
    th = 0.07;

		% - list box
		h = 0.4;
		w = 0.9;
		y = y-h; x = sx; 

		esListH = uicontrol(figH,'Style','ListBox','Units','normalized','String',ESListStr,'Position',[x y w h], 'Callback', {@changeSelected, obj});

		% - toggle on/off buttton
		w = 0.9; 
		y = y-bh-sy; x = sx; 
		prevLeftButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','Toggle Display Status','Position',[x y w bh], 'Callback', {@toggleList, obj});

		% - color text, assign text box
		w = 0.4; 
		y = y-th-sy; x = sx; 
		uicontrol(figH,'Style','Text','Units','normalized','String','Color:','Position',[x y w th]);
		x = x+w+sx; w = 0.4;
		esColorH = uicontrol(figH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String', ...
		  num2str(obj.guiData.TSBrowser.ESList{1}.color),'Position',[x y w th], 'CallBack' , {@updateColor, obj});

		% - plot event trig avg button, cell text box, cell select
		w = 0.9; 
		y = y-bh-sy; x = sx; 
		plotETAButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','Plot Event-Triggered Avg','Position',[x y w bh], 'Callback', {@plotETA, obj});
		w = 0.5; 
		y = y-th-sy; x = sx; 
		uicontrol(figH,'Style','Text','Units','normalized','String','Event # (Inf=last)','Position',[x y w th]);
		x = x+w+sx; w = 0.4;
		eventNumberH = uicontrol(figH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(1),'Position',[x y w th]);

		w = 0.9; 
		y = y-th-sy; x = sx; 
		uicontrol(figH,'Style','Text','Units','normalized','String','CELL SELECTOR PULLDOWN HERE','Position',[x y w th]);

%		prevLeftButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','<<','Position',[.02 gy .05 bh], 'Callback', {@chgLeft, obj, -10});
%		thetaPosTypeH = uicontrol(panelH,'Style','popup', 'Units','normalized','String','Polynomial Intersect|Follicle|Distance from Follicle|Distance from poly int.|Fraction dist foll|Fraction dist poly int','Position',[.13 .29 .5 .06], 'Value', obj.thetaPositionType);
%		leftTitleH = uicontrol(figH,'Style','Text','Units','normalized','String','','Position',[.155 gy .2 th]);

		% gui objects
		ui.esListH = esListH;
		ui.esColorH = esColorH;
		ui.eventNumberH = eventNumberH;
		ui.esListIdx = 1; % initial

		% set ui ESListIdx
		set(ui.esListH,'Value', ui.esListIdx);

		% Assign gui data initially
		assignGuiData(obj, figH, ui);
	else % just select it
	  figure(obj.guiData.ESControl.figH);
	end

%
% Pulls variables from obj.guiData.ESControl
%
function [figH ui ] = decomposeGuiData(obj)
  figH = obj.guiData.ESControl.figH;
  ui = obj.guiData.ESControl.ui;

%
% ASsigns obj.guiData.ESControl variables
%
function assignGuiData(obj, figH, ui)
  obj.guiData.ESControl.figH = figH;
  obj.guiData.ESControl.ui = ui;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% change list selection
%
function changeSelected(hObj, event, obj)
  % pull guiData.ESControl
  [figH ui] = decomposeGuiData(obj);

  % determine who is selected and grab 
  idx = get(ui.esListH, 'Value');
  es = obj.guiData.TSBrowser.ESList{idx};

	% update the color field
	set (ui.esColorH, 'String', num2str(es.color));

% 
% update color for selected ES
%
function updateColor(hObj, event, obj)
  % pull guiData.ESControl
  [figH ui] = decomposeGuiData(obj);

  % determine who is selected and grab 
  idx = get(ui.esListH, 'Value');
  es = obj.guiData.TSBrowser.ESList{idx};

	% pull the color
	newColor = str2num(get(ui.esColorH, 'String'));

	% assign
	es.color = newColor;

	% update graphix
	obj.guiTSBrowser('updateLeftPanelNoRoiCheck');
	obj.guiTSBrowser('updateRightPanel');

% 
% plot event-triggered average
%
function plotETA(hObj, event, obj)
  % pull guiData.ESControl
  [figH ui] = decomposeGuiData(obj);

	% get event #
	en = str2num(get(ui.eventNumberH, 'String'));

	% appropriate es ...
  idx = get(ui.esListH, 'Value');
  es = obj.guiData.TSBrowser.ESList{idx};

	% appropriate ts
	ts = obj.guiData.TSBrowser.leftList{obj.guiData.TSBrowser.leftIdx(1)};
	tsi = obj.guiData.TSBrowser.leftIdx(2);

  % and plot ...
	obj.plotEventTriggeredAverage(ts, tsi, es, en);

% 
% chg right time series
%
function toggleList(hObj, event, obj)
  % pull guiData.ESControl
  [figH ui] = decomposeGuiData(obj);

  % determine who got touched
  idx = get(ui.esListH, 'Value');

  % pop it
	obj.guiData.TSBrowser.ESListOn(idx) = ~obj.guiData.TSBrowser.ESListOn(idx) ;
	obj.guiTSBrowser('updateLeftPanelNoRoiCheck');
	obj.guiTSBrowser('updateRightPanel');

	% update the string
	for e=1:length(obj.guiData.TSBrowser.ESList)
	  if (obj.guiData.TSBrowser.ESListOn(e))
			ESListStr{e} = ['<html><b>' obj.guiData.TSBrowser.ESList{e}.idStr '</b></html>'];
		else
			ESListStr{e} = obj.guiData.TSBrowser.ESList{e}.idStr;
		end
	end
  set(ui.esListH, 'String',ESListStr);

	% make dominant again
	figure(figH);
  
	% assign guiData.ESControl


