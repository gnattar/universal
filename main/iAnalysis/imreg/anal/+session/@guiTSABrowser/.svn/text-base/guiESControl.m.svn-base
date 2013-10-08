%
% SP Dec 2010
% 
% Brings up GUI for controlling eventSeries plottd in guiTSBrowser as well as
%  invoking event-series averages.
%
% USAGE: 
%
%   gt.guiESControl(subFunction, subFunctionParams)
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
	if (isempty(obj.ESList))
	  disp('guiESControl::Makes no sense without eventSeries list!');
		return;
	end

  % --- already one?
	alreadyPresent = 1;
  if (length(ishandle(obj.ESListFigH)) == 0) % is the handle of any length?
	  alreadyPresent = 0;
  elseif (~ishandle(obj.ESListFigH)) % is it a handle
	  alreadyPresent = 0;
	elseif (strcmp(get(obj.ESListFigH, 'Name'), 'EventSeries Control') == 0) % some other figure has this hadnle
	  alreadyPresent = 0;
	end

  % --- prelims

	% build es list
	for e=1:length(obj.ESList)
	  if (obj.ESListOn(e))
			ESListStr{e} = ['<html><b>' obj.ESList{e}.idStr '</b></html>'];
		else
			ESListStr{e} = obj.ESList{e}.idStr;
		end
	end

	% --- gui setup
	if (~alreadyPresent)
    % figure
		obj.ESListFigH = figure('Position',[500 500 300 600],'DockControls', 'off', 'Menubar', 'none',  'Name', 'EventSeries Control', 'NumberTitle','off');

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

		esListH = uicontrol(obj.ESListFigH,'Style','ListBox','Units','normalized','String',ESListStr,'Position',[x y w h], 'Callback', {@changeSelected, obj});

		% - toggle on/off buttton
		w = 0.9; 
		y = y-bh-sy; x = sx; 
		prevLeftButtonH = uicontrol(obj.ESListFigH,'Style','PushButton','Units','normalized','String','Toggle Display Status','Position',[x y w bh], 'Callback', {@toggleList, obj});

		% - color text, assign text box
		w = 0.4; 
		y = y-th-sy; x = sx; 
		uicontrol(obj.ESListFigH,'Style','Text','Units','normalized','String','Color:','Position',[x y w th]);
		x = x+w+sx; w = 0.4;
		esColorH = uicontrol(obj.ESListFigH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String', ...
		  num2str(obj.ESList{1}.color),'Position',[x y w th], 'CallBack' , {@updateColor, obj});

		% - plot event trig avg buttons, cell text box, cell select
		y = y-th-sy; x = sx; 
		w = 0.4; 
		uicontrol(obj.ESListFigH,'Style','Text','Units','normalized','String','Plot Event Trig''d Avg','Position',[x y w th]);
		x = x+w+.05;; 
		w = 0.15;
		plotETALButtonH = uicontrol(obj.ESListFigH,'Style','PushButton','Units','normalized','String','Left','Position',[x y w bh], 'Callback', {@plotETA, obj,1});
		x = x+w+.05;; 
		plotETARButtonH = uicontrol(obj.ESListFigH,'Style','PushButton','Units','normalized','String','Right','Position',[x y w bh], 'Callback', {@plotETA, obj,2});
		w = 0.5; 
		y = y-th-sy; x = sx; 
		uicontrol(obj.ESListFigH,'Style','Text','Units','normalized','String','Event # (Inf=last)','Position',[x y w th]);
		x = x+w+sx; w = 0.4;
		eventNumberH = uicontrol(obj.ESListFigH,'Style','Edit','BackgroundColor', [1 1 1], 'Units','normalized','String',num2str(1),'Position',[x y w th]);

		w = 0.9; 
		y = y-th-sy; x = sx; 
		uicontrol(obj.ESListFigH,'Style','Text','Units','normalized','String','CELL SELECTOR PULLDOWN HERE','Position',[x y w th]);

%		prevLeftButtonH = uicontrol(obj.ESListFigH,'Style','PushButton','Units','normalized','String','<<','Position',[.02 gy .05 bh], 'Callback', {@chgLeft, obj, -10});
%		thetaPosTypeH = uicontrol(panelH,'Style','popup', 'Units','normalized','String','Polynomial Intersect|Follicle|Distance from Follicle|Distance from poly int.|Fraction dist foll|Fraction dist poly int','Position',[.13 .29 .5 .06], 'Value', obj.thetaPositionType);
%		leftTitleH = uicontrol(obj.ESListFigH,'Style','Text','Units','normalized','String','','Position',[.155 gy .2 th]);

		% gui objects
		obj.ESui.esListH = esListH;
		obj.ESui.esColorH = esColorH;
		obj.ESui.eventNumberH = eventNumberH;
		obj.ESui.esListIdx = 1; % initial

		% set ui ESListIdx
		set(obj.ESui.esListH,'Value', obj.ESui.esListIdx);

	else % just select it
	  figure(obj.ESListFigH);
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% change list selection
%
function changeSelected(hObj, event, obj)
  % determine who is selected and grab 
  idx = get(obj.ESui.esListH, 'Value');
  es = obj.ESList{idx};

	% update the color field
	set (obj.ESui.esColorH, 'String', num2str(es.color));

% 
% update color for selected ES
%
function updateColor(hObj, event, obj)
  % determine who is selected and grab 
  idx = get(obj.ESui.esListH, 'Value');
  es = obj.ESList{idx};

	% pull the color
	newColor = str2num(get(obj.ESui.esColorH, 'String'));

	% assign
	es.color = newColor;

	% update graphix
	obj.guiWrapper('updateLeftPanelNoRoiCheck');
	obj.guiWrapper('updateRightPanel');

% 
% plot event-triggered average
%
function plotETA(hObj, event, obj, side)
	% get event #
	en = str2num(get(obj.ESui.eventNumberH, 'String'));

	% appropriate es ...
  idx = get(obj.ESui.esListH, 'Value');
  es = obj.ESList{idx};

	% appropriate ts
	if (side == 1)
		ts = obj.leftListTSA{obj.leftIdx(1)};
		tsi = obj.leftIdx(2);
	else
		ts = obj.rightListTSA{obj.rightIdx(1)};
		tsi = obj.rightIdx(2);
	end

  % and plot ...
	session.session.plotEventTriggeredAverageS(ts, tsi, es, en);

% 
% chg right time series
%
function toggleList(hObj, event, obj)
  % determine who got touched
  idx = get(obj.ESui.esListH, 'Value');

  % pop it
	obj.ESListOn(idx) = ~obj.ESListOn(idx) ;
	obj.guiWrapper('updateLeftPanelNoRoiCheck');
	obj.guiWrapper('updateRightPanel');

	% update the string
	for e=1:length(obj.ESList)
	  if (obj.ESListOn(e))
			ESListStr{e} = ['<html><b>' obj.ESList{e}.idStr '</b></html>'];
		else
			ESListStr{e} = obj.ESList{e}.idStr;
		end
	end
  set(obj.ESui.esListH, 'String',ESListStr);

	% make dominant again
	figure(obj.ESListFigH);
  
	% assign guiData.ESControl


