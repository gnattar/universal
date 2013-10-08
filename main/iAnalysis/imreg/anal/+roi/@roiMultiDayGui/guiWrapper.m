%
% SP Apr 2011
% 
% Brings up GUI for assigning cross-day ROIs.  Allows communication to this
%  GUI.
%
% USAGE: 
%
%   robj.guiWrapper(subFunction, subFunctionParams)
%
%   subFunction: if passed, will call that subfunction with
%                subFunctionParamss
%   subFunctionPArams:  passed to subFunction
%
function guiWrapper(obj, subFunction, subFunctionParams)
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
function startGui(obj, params)
  % --- already one?
	alreadyPresent = 1;
  if (length(obj.roiArrayFigH) == 0 | length(obj.mainControlH) == 0 | ~ishandle(obj.roiArrayFigH) | ~ishandle(obj.mainControlH))
	  alreadyPresent = 0;
	end

	% --- main control
	if (~alreadyPresent)
		% ========================================================================
		% --- GUI STUFF

		% button panel

		% figures
		obj.mainControlH = figure('Position',[10 10 450 100],'DockControls', 'off', 'Menubar', 'none',   'Name', 'Multiday ROI control', 'NumberTitle','off');

		% action buttons
		bh = 20; % button height
		th = 20; % text height
		sx = 5;
		sy = 5;

		y = 70;
		x = sx;
		w = 40 ;  uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','Load', 'Position',[x y w bh], 'Callback', {@loadRoisCallback, obj});
		x = x+sx+w; w=40; uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','Save','Position',[x y w bh], 'Callback', {@saveRoisCallback, obj});
		x = x+sx+w; w=60; uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','Refresh','Position',[x y w bh], 'Callback', {@refreshCallback, obj});
		x = x+sx+w; w=100; uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','Propagate new','Position',[x y w bh], 'Callback', {@propagateRoisCallback, obj});
		x = x+sx+w; w=60; uicontrol(obj.mainControlH,'Style','CheckBox','Units','pixels','String','Zoom', ...
		  'Position',[x y w bh], 'Callback', {@enableZoomCallback, obj});
		x = x+sx+w; w=90; uicontrol(obj.mainControlH,'Style','CheckBox','Units','pixels','String','Cross-day', ...
		  'Position',[x y w bh], 'Callback', {@enableMultidayCallback, obj});

    y=y-30;
		x=sx;
		w= 380; obj.dayMenuH = uicontrol(obj.mainControlH,'Style','Popup','Units','pixels', ...
		  'String',{''},'Value',1,'Position',[x y w th], 'Callback', {@daySelectCallback,obj});
		x = x+sx+w; w=20; uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','<','Position',[x y w bh], 'Callback', {@prevDayCallback, obj});
		x = x+sx+w; w=20; uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','>','Position',[x y w bh], 'Callback', {@nextDayCallback, obj});

		y = y-30;
		x = sx;
		w = 160 ;  uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','Color by displacement', 'Position',[x y w bh], 'Callback', {@colorByDispCallback, obj});
		x = x+sx+w; w=140; uicontrol(obj.mainControlH,'Style','PushButton','Units','pixels', ...
		  'String','Delete across days', 'Position',[x y w bh], 'Callback', {@deleteCrossDayCallback, obj});

	end

	% select control panel
  figure(obj.mainControlH);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% brings up loaded file list and allows user to select which ones to save
%
function saveRoisCallback(hObj, event, obj)

  % prompt which to save
	for r=1:length(obj.roiArrayArray)
		rA = obj.roiArrayArray{r};
		rA_str{r} = rA.idStr;
    disp(['Session ' rA.idStr ' will be saved to ' rA.roiFileName]);
	end
	[saved_idx,v] = listdlg('PromptString','Select roiArrays to save:',...
								'SelectionMode','multiple',...
								'ListSize', [300 500], ...
								'ListString',rA_str);

	% loop over the ones to save
	for si=1:length(saved_idx)
		rA = obj.roiArrayArray{saved_idx(si)};
    rA.saveToFile(rA.roiFileName);
	end

%
% brings up file list and allows user to select files
%
function loadRoisCallback(hObj, event, obj)
  % --- sanity
	if (~isempty(whos('global','rootDataPath')))
		global rootDataPath;
		rdp = rootDataPath;
		if (length(rdp) == 0)
			rootDataPath = '~/data/';
			rdp = '~/data/';
		end
	else
		global rootDataPath;
		rootDataPath = '~/data/';
	  rdp = '~/data/';
	end
	obj.loadData(rdp);


%
% select previous day's data
% 
function prevDayCallback (hObj, event, obj)
  rAidx = obj.rAidx - 1;
	if (rAidx < 1 ) ; rAidx =  length(obj.roiArrayArray) ; end
	obj.setRAIdx(rAidx); 


%
% select next day
% 
function nextDayCallback (hObj, event, obj)
  rAidx = obj.rAidx + 1;
	if (rAidx > length(obj.roiArrayArray)) ; rAidx = 1 ; end
	obj.setRAIdx(rAidx); 

%
% day list pulldown callback
%
function daySelectCallback(hObj, event, obj)
  oldRAidx = obj.rAidx;
	rAidx = get(hObj,'Value');
	if (oldRAidx ~= rAidx) ; obj.setRAIdx(rAidx); end % only if necessary

%
% Enables zoom plot
%
function enableZoomCallback(hObj, event, obj)
  obj.zoomOn = get(hObj,'Value');
  obj.updateZoomPlot();


%
% Enables multiday plot
%
function enableMultidayCallback(hObj, event, obj)
  obj.crossDayOn = get(hObj,'Value');
  obj.updateCrossDayPlot();

%
% Colors rois that had poor displacement (ie interpolated bc of bad corr)
%
function colorByDispCallback (hObj, event, obj)

  % loop over 
	for r=1:length(obj.roiArrayArray)
		rA = obj.roiArrayArray{r};
		rA.colorByGroupSet(9000);
	end


%
% delete this ROI for all days
%
function deleteCrossDayCallback(hObj, event, obj)

  % grab ID
	curRA = obj.roiArrayArray{obj.rAidx};
	selectedRoiIds = curRA.guiSelectedRoiIds;

  % loop over 
	for r=1:length(obj.roiArrayArray)
		rA = obj.roiArrayArray{r};
		rA.removeRois(selectedRoiIds);
	end

	% update
	curRA.updateImage();

%
% Propagate any new rois to all days
%
function propagateRoisCallback(hObj, event, obj)

  % loop over everything but "this"
	rA_t = obj.roiArrayArray{obj.rAidx};
	for r=1:length(obj.roiArrayArray)
	  disp(['multiDayGui::Processing ' num2str(r) ' of ' num2str(length(obj.roiArrayArray))]);
		if (r == obj.rAidx) ; continue ; end % skip self
		rA_s = obj.roiArrayArray{r};
		if (length(rA_t.roiIds) == length(rA_s.roiIds) & ... 
		    sum(rA_t.roiIds == rA_s.roiIds) == length(rA_t.roiIds)) % skip ones with same indices
			disp('multiDayGui::skipping ; all ROIs present.');
			continue;
		end
    roi.roiArray.findMatchingRoisInNewImage(rA_t, rA_s);
	end


%
% Restart the GUI -- sometimes it gets icky icky gooey gooey
%
function refreshCallback(hObj, event, obj)

