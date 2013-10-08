%
% SP Dec 2010
% 
% Brings up GUI for controlling plot parameters in the TSBrowser context.
%
% USAGE: 
%
%   wt.guiPlotSetupControl(subFunction, subFunctionParams)
%
% subFunction: if blank, just start the gui (startGui), otherwise will do 
%              eval('subFunction(obj, subFunctionParams)')
% subFunctionParams: parameters passed to subFunction ; can be blank, in 
%              which case eval is off of subFunction(obj)
%
function guiPlotSetupControl(obj, subFunction, subFunctionParams)
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

  % --- already one?
	alreadyPresent = 1;
  if (isfield(obj.guiData, 'PlotSetupControl'))
	  if (~ishandle(obj.guiData.PlotSetupControl.figH))
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

		esListH = uicontrol(figH,'Style','ListBox','Units','normalized','String',ESListStr,'Position',[x y w h]);

		% - toggle on/off buttton
		w = 0.9; 
		y = y-bh-sy; x = sx; 
		prevLeftButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','Toggle Display Status','Position',[x y w bh], 'Callback', {@toggleList, obj});

		% - color text, text box
		w = 0.9; 
		y = y-th-sy; x = sx; 
		colorTextH = uicontrol(figH,'Style','Text','Units','normalized','String','COLOR GOES HERE','Position',[x y w th]);

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
		ui.eventNumberH = eventNumberH;

		% Assign gui data initially
		assignGuiData(obj, figH, ui);
	else % just select it
	  figure(obj.guiData.PlotSetupControl.figH);
	end

%
% Pulls variables from obj.guiData.PlotSetupControl
%
function [figH ui ] = decomposeGuiData(obj)
  figH = obj.guiData.PlotSetupControl.figH;
  ui = obj.guiData.PlotSetupControl.ui;

%
% ASsigns obj.guiData.PlotSetupControl variables
%
function assignGuiData(obj, figH, ui)
  obj.guiData.PlotSetupControl.figH = figH;
  obj.guiData.PlotSetupControl.ui = ui;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function plotETA(hObj, event, obj)


