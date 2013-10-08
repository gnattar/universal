%
% SP Dec 2010
% 
% Brings up GUI for browsing timeSeriesArray objects, 2 viewers side-by-side.
%
% USAGE: 
%
%   s.guiTSBrowser(subFunction, subFunctionParams)
%
% subFunction: if blank, just start the gui (startGui), otherwise will do 
%              eval('subFunction(obj, subFunctionParams)')
% subFunctionParams: parameters passed to subFunction ; can be blank, in 
%              which case eval is off of subFunction(obj)
%
% For subFunction "startGui", you can pass the following params:
%   leftListTSA -- cell array of TSA objects for left panel
%   righListTSA -- same but for right panel
%
% So if you want to invoke guiTSBrowser with a DIFFERENT set of right/left
% TSA's, you would
%   1) params.leftListTSA = {myTSA}
%   2) s.guiTSBrowser('startGui', params)
%
% Note that myTSA is surrounded by {}.  This is because you can pass a cell
%  array of TSA objects, e.g., {myTSA1, myTSA2, ...}
%  
%
% NOTES:
%
% Internally, guiTSBrowser has a guiData structure with the following fields.
%  They can be updated explicitly, though this does not ensure they will be 
%  instantly enforced.
%
%  leftColorMap: which colormap to use on left TSA ; can either be a string,
%                in which case eval is used and it is assumed to be a function,
%                or an actual colormap.
%  rightColorMap: as above, but for right data.
%  leftImageValueRange: value range that colormap will span on left image.
%                       Note that the passed value is 'eval'ed, and that it
%                       is done in a context where m means minimum value and
%                       M means maximal value while mu and sd mean mean and 
%                       sd, so you can do something like [0 1], [m M], or
%                       [mu-2*sd mu+2*sd].  Eval'd only if string ; otherwise 
%                       must be #s.
%  rightImageValueRange: same for right
%  leftPlotValueRange: if a plot is used, this is the range for the left one
%  rightPlotValueRange: again, if plot is used, for right one
%
function guiTSBrowser(obj, subFunction, subFunctionParams)
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
  if (isfield(obj.guiData, 'TSBrowser'))
	  if (~ishandle(obj.guiData.TSBrowser.figH) | ~ishandle(obj.guiData.TSBrowser.rightAxisH))
		  alreadyPresent = 0;
		end
	else
		alreadyPresent = 0;
	end

  % --- prelims --> process inputs
  if (length(obj.caTSA) > 0 && length(obj.caTSA.dffTimeSeriesArray) > 0)
  	leftListTSA = {obj.caTSA.dffTimeSeriesArray};
	else
	  leftListTSA = {};
	end

	rightListTSA = {};
	rli = 1;
	if (length(obj.derivedDataTSA) > 0)
		rightListTSA{rli} = obj.derivedDataTSA;
		rli = rli + 1;
	end
	if (length(obj.whiskerCurvatureChangeTSA) > 0)
		rightListTSA{rli} = obj.whiskerCurvatureChangeTSA;
		rli = rli + 1;
	end
	if (length(obj.whiskerCurvatureTSA)>0)
		rightListTSA{rli} = obj.whiskerCurvatureTSA;
		rli = rli + 1;
	end
	if (length(obj.whiskerAngleTSA) > 0)
		rightListTSA{rli} = obj.whiskerAngleTSA;
		rli = rli+1;
	end

	if (nargin >= 2 && isstruct(params))
	  if (isfield(params,'leftListTSA')) leftListTSA = params.leftListTSA; end
	  if (isfield(params,'rightListTSA')) rightListTSA = params.rightListTSA; end
	end

	% --- gui setup
	if (~alreadyPresent)

		% ========================================================================
	  % --- DATA THAT IS SHOWN STUFF

    % ---
		% setup LEFT timeseries list
    leftList = {};
		leftListIdStr = {};
		for lli=1:length(leftListTSA)
      leftList{lli} = leftListTSA{lli};
			for l=1:leftList{lli}.length() ; leftListIdStr{length(leftListIdStr)+1} = leftList{lli}.idStrs{l} ; end
    end

    % ---
		% setup RiGHT timeseries list
		rightList = {};
		rightListIdStr = {};
		for rli=1:length(rightListTSA)
			rightList{rli} = rightListTSA{rli};
			for r=1:rightList{rli}.length() ; rightListIdStr{length(rightListIdStr)+1} = rightList{rli}.idStrs{r} ; end
		end

    % ---
    % event series
		eli = 1;
    wbiri = 0; % whisker bar in reach index -- we want this on by default
    if (length(obj.behavESA) > 0)
      for b=1:length(obj.behavESA.esa)
        ESList{eli} = obj.behavESA.esa{b};
        eli = eli+1;
      end
    end
    if (length(obj.whiskerBarContactESA) > 0)
			for c=1:length(obj.whiskerBarContactESA.esa)
				if (iscell(	obj.whiskerBarContactESA.esa{c}.idStr))
					obj.whiskerBarContactESA.esa{c}.idStr= [char(obj.whiskerBarContactESA.esa{c}.idStr{1}) ' ' char(obj.whiskerBarContactESA.esa{c}.idStr{2})];
				end
				ESList{eli} = obj.whiskerBarContactESA.esa{c};
				eli = eli+1;
			end
		end
		if (length(obj.whiskerBarContactClassifiedESA) > 0)
			for c=1:length(obj.whiskerBarContactClassifiedESA.esa)
				ESList{eli} = obj.whiskerBarContactClassifiedESA.esa{c};
				eli = eli+1;
			end
		end
		if (length(obj.whiskerBarInReachES) > 0)
			wbiri = eli;
    	ESList{eli} = obj.whiskerBarInReachES; eli = eli+1;
		end
    if (length(obj.caTSA.caPeakEventSeriesArray) > 0)
			for c=1:length(obj.caTSA.caPeakEventSeriesArray.esa)
				ESList{eli} = obj.caTSA.caPeakEventSeriesArray.esa{c};
				eli = eli+1;
			end
		end
    ESListOn = zeros(1,length(ESList));
		if (wbiri > 0) ; ESListOn (wbiri) = 1; end% bar in reach only

		% ========================================================================
		% --- GUI STUFF

		% figure
		figH = figure('Position',[10 10 1010 1010],'DockControls', 'off', 'Menubar', 'none',   'Name', ['Timeseries Browser ' obj.mouseId ' ' obj.dateStr], 'NumberTitle','off');

		% left plot image
		leftAxisH = axes('Position',[0.01 .01 .48 .9]);
		rightAxisH = axes('Position',[0.51 .01 .48 .9]);

		% action buttons
		bh = 0.025; % button height
		th = 0.025; % text height
		gy = 0.95; % gui y
		sx = 0.01;
		x = sx;
		w = 0.03 ; prevLeftButtonXH = uicontrol(figH,'Style','PushButton','Units','normalized','String','<<','Position',[x gy w bh], 'Callback', {@chgLeft, obj, -10});
		x = x+sx+w; w=.03; prevLeftButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','<','Position',[x gy w bh], 'Callback', {@chgLeft, obj, -1});
		x = x+sx+w; w=.2; leftTitleH = uicontrol(figH,'Style','Popup','Units','normalized','String',leftListIdStr,'Value',1,'Position',[x gy w th], 'Callback', {@chgLeft, obj, 0});
%		x = x+sx+w; w=.2; leftTitleH = uicontrol(figH,'Style','Text','Units','normalized','String','','Position',[x gy w th]);
		x = x+sx+w; w=.03; nextLeftButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','>','Position',[x gy w bh], 'Callback', {@chgLeft, obj, 1});
		x = x+sx+w; w=.03; nextLeftButtonXH = uicontrol(figH,'Style','PushButton','Units','normalized','String','>>','Position',[x gy w bh], 'Callback', {@chgLeft, obj, 10});
		x = x+sx+w; w=.05; showRoiGuiCheckH= uicontrol(figH,'Style','CheckBox','Units','normalized','String','ROIs','Position',[x gy w bh], 'Callback', {@toggleRoiGui, obj, 10});
		srgm = get(showRoiGuiCheckH, 'Min'); set(showRoiGuiCheckH, 'Value', srgm);
		x = x+sx+w; w=.05; showTrialGuiCheckH= uicontrol(figH,'Style','CheckBox','Units','normalized','String','Trial','Position',[x gy w bh], 'Callback', {@toggleTrialGui, obj, 10});
		stgm = get(showTrialGuiCheckH, 'Min'); set(showTrialGuiCheckH, 'Value', stgm);

    % start @ ~middle
		x = 0.53; w=.09; showLineCheckH = uicontrol(figH,'Style','CheckBox','Units','normalized','String','Line Plot', 'Position',[x gy w bh], 'Callback', {@toggleLinePlot, obj});
		slcm = get(showLineCheckH, 'Min'); set(showLineCheckH, 'Value', slcm);

		x = x+sx+w; w=.03; prevRightButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','<','Position',[x gy w bh], 'Callback', {@chgRight, obj, -1});
%		x = x+sx+w; w=.2; rightTitleH = uicontrol(figH,'Style','Text','Units','normalized','String','','Position',[x gy w th]);
		x = x+sx+w; w=.2; rightTitleH = uicontrol(figH,'Style','Popup','Units','normalized','String',rightListIdStr,'Value',1,'Position',[x gy w th], 'Callback', {@chgRight, obj, 0});
		x = x+sx+w; w=.03; 	nextRightButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','>','Position',[x gy w bh], 'Callback', {@chgRight, obj, 1});
		x = x+sx+w; w=.03; 	esControlButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','ES','Position',[x gy w bh], 'Callback', {@invokeESGui, obj});
		x = x+sx+w; w=.03; 	plotControlButtonH = uicontrol(figH,'Style','PushButton','Units','normalized','String','SU','Position',[x gy w bh], 'Callback', {@invokePlotSetupGui, obj});

		% Assign gui data initially
		assignGuiData(obj, figH, [], leftAxisH,rightAxisH,[1 1],[1 1], leftList, rightList);

		% gui objects
		obj.guiData.TSBrowser.ui.leftTitleH = leftTitleH;
		obj.guiData.TSBrowser.ui.rightTitleH = rightTitleH;
		obj.guiData.TSBrowser.ui.showLineCheckH = showLineCheckH;
		obj.guiData.TSBrowser.ui.showRoiGuiCheckH = showRoiGuiCheckH;
		obj.guiData.TSBrowser.ui.showTrialGuiCheckH = showTrialGuiCheckH;
  
		% Assign EventSeries
		obj.guiData.TSBrowser.ESList = ESList;
		obj.guiData.TSBrowser.ESListOn = ESListOn;
		obj.guiData.TSBrowser.lastRoiFOV = -1;

		% plotting parameters
		obj.guiData.TSBrowser.leftColorMap = 'gray';
		obj.guiData.TSBrowser.rightColorMap = 'gray';
		obj.guiData.TSBrowser.leftImageValueRange = '[m M]';
		obj.guiData.TSBrowser.rightImageValueRange = '[m M]';
		obj.guiData.TSBrowser.leftPlotValueRange = '[m M]';
		obj.guiData.TSBrowser.leftPlotValueRange = '[m M]';

	else % just select it
	  figure(obj.guiData.TSBrowser.figH);
	end

	% draw image
	updateLeftPanel(obj);
	updateRightPanel(obj);

%
% Pulls variables from obj.guiData.TSBrowser
%
function [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj)
  figH = obj.guiData.TSBrowser.figH;
  lineFigH = obj.guiData.TSBrowser.lineFigH;
  rightAxisH = obj.guiData.TSBrowser.rightAxisH;
  leftAxisH = obj.guiData.TSBrowser.leftAxisH;
  leftIdx = obj.guiData.TSBrowser.leftIdx;
  rightIdx = obj.guiData.TSBrowser.rightIdx;
	leftList = obj.guiData.TSBrowser.leftList;
	rightList = obj.guiData.TSBrowser.rightList;

%
% ASsigns obj.guiData.TSBrowser variables
%
function assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList)
  obj.guiData.TSBrowser.figH = figH;
  obj.guiData.TSBrowser.lineFigH = lineFigH;
  obj.guiData.TSBrowser.leftAxisH = leftAxisH;
  obj.guiData.TSBrowser.rightAxisH = rightAxisH;
  obj.guiData.TSBrowser.leftIdx = leftIdx;
  obj.guiData.TSBrowser.rightIdx = rightIdx;
  obj.guiData.TSBrowser.leftList = leftList;
  obj.guiData.TSBrowser.rightList = rightList;

%
% Draws everything on LEFT panel
%
function updateLeftPanelNoRoiCheck (obj)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

	% sanity check
	if (length(leftList) == 0) ; return ; end

  % build ES shown list
	ESShown = find(obj.guiData.TSBrowser.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.guiData.TSBrowser.ESList{ESShown(e)};
	end

  % plot params
	if (ischar(obj.guiData.TSBrowser.leftImageValueRange))
		M = nanmax(nanmax(leftList{leftIdx(1)}.valueMatrix(leftIdx(2),:)));
		m = nanmin(nanmin(leftList{leftIdx(1)}.valueMatrix(leftIdx(2),:)));
		sd = nanstd(reshape(leftList{leftIdx(1)}.valueMatrix(leftIdx(2),:),[],1));
		mu = nanmean(reshape(leftList{leftIdx(1)}.valueMatrix(leftIdx(2),:),[],1));

		livr = eval([obj.guiData.TSBrowser.leftImageValueRange ';']);
	else
	  livr = obj.guiData.TSBrowser.leftImageValueRange;
	end

	if (ischar(obj.guiData.TSBrowser.leftColorMap)) 
	  lcm = eval([obj.guiData.TSBrowser.leftColorMap '(256);']);
	else
	  lcm = obj.guiData.TSBrowser.leftColorMap;
	end

	% call plotter
  if (length(leftList) > 0)
    obj.plotTimeSeriesAsImage(leftList{leftIdx(1)}, leftIdx(2), ESShownList, [],[],lcm,[0 10],livr, leftAxisH);
	  leftTitleList = get(obj.guiData.TSBrowser.ui.leftTitleH,'String');
	  leftTitleIdx = find(strcmp(leftTitleList,  leftList{leftIdx(1)}.idStrs{leftIdx(2)}));
	  set(obj.guiData.TSBrowser.ui.leftTitleH, 'Value', leftTitleIdx);
  
    % check for line plot
    if (length(lineFigH) > 0)
      if (ishandle(lineFigH))
        updateLeftLine(obj);
      else
        slcm = get(obj.guiData.TSBrowser.ui.showLineCheckH, 'Min'); 
        set(obj.guiData.TSBrowser.ui.showLineCheckH, 'Value', slcm);
        lineFigH = [];
      end
    end
  end
  
	% assign guiData.TSBrowser
	assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList);

%
% Draws everything on left, WITH roiArrayCheck
%
function updateLeftPanel (obj)
  updateLeftPanelNoRoiCheck(obj);
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

	% sanity check
	if (length(leftList) == 0) ; return ; end

	% check for roi
	srgM = get(obj.guiData.TSBrowser.ui.showRoiGuiCheckH, 'Max'); 
	srgm = get(obj.guiData.TSBrowser.ui.showRoiGuiCheckH, 'Min'); 
	srgV = get(obj.guiData.TSBrowser.ui.showRoiGuiCheckH, 'Value');
  % start and initialize ROI gui appropriately
	if (srgV == srgM)
	  fovIdx = obj.caTSA.roiFOVidx(leftIdx(2));
	  lastFOV = obj.guiData.TSBrowser.lastRoiFOV;
		obj.caTSA.roiArray{fovIdx}.guiSelectedRoiIds = obj.caTSA.ids(leftIdx(2));

		% Need to instantiate roi gui? (and unselect last)
		if (fovIdx ~= lastFOV && lastFOV ~= -1)
      % assign guiSelectedRoiIds
      obj.caTSA.roiArray{lastFOV}.guiSelectedRoiIds = [];

      % cleanup previous
		  obj.caTSA.roiArray{lastFOV}.updateImage();
     	obj.caTSA.roiArray{lastFOV}.updateGui({});

      % setup new
			obj.caTSA.roiArray{fovIdx}.startGui();
	  	obj.caTSA.roiArray{fovIdx}.guiSelectedRoiIds = obj.caTSA.ids(leftIdx(2));
			obj.caTSA.roiArray{fovIdx}.guiShowFlags = [0 1 0];

			% hook up callback FROM roiAray
			obj.caTSA.roiArray{fovIdx}.updateImagePostFunction = @updateFromRoiGui;
			obj.caTSA.roiArray{fovIdx}.updateImagePostFunctionParams = {obj,fovIdx};

			% set last FOV
	    obj.guiData.TSBrowser.lastRoiFOV = fovIdx;
		end

		obj.caTSA.roiArray{fovIdx}.updateImage();
	end
	
	% check for trial plot
	if (isfield(obj.guiData.TSBrowser,'trialPlotHandle') &&  ...
	    ~isempty(obj.guiData.TSBrowser.trialPlotHandle) && ...
	   ishandle(obj.guiData.TSBrowser.trialPlotHandle(1)))
	  updateSingleTrialPlot(obj);
	end

%
% updates left panel of the line plot [= left]
%
function updateLeftLine(obj)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);
  
  if (length(leftList) == 0) ; return ; end

  % build ES shown list
	ESShown = find(obj.guiData.TSBrowser.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.guiData.TSBrowser.ESList{ESShown(e)};
	end

	% call plotter
  obj.plotTimeSeriesAsLine(leftList{leftIdx(1)}, leftIdx(2), ESShownList, [], [],[0 10 -0.5 2],lineFigH(2:3));
	set(lineFigH(2), 'XTick',[]);

%
% Draws everything on RIGHT panel
%
function updateRightPanel (obj)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

	% sanity check
	if (length(rightList) == 0) ; return ; end

  % build ES shown list
	ESShown = find(obj.guiData.TSBrowser.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.guiData.TSBrowser.ESList{ESShown(e)};
	end

  % plot params
	if (ischar(obj.guiData.TSBrowser.rightImageValueRange))
		M = nanmax(nanmax(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:)));
		m = nanmin(nanmin(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:)));
		sd = nanstd(reshape(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:),[],1));
		mu = nanmean(reshape(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:),[],1));

		rivr = eval([obj.guiData.TSBrowser.rightImageValueRange ';']);
	else
	  rivr = obj.guiData.TSBrowser.rightImageValueRange;
	end

	if (ischar(obj.guiData.TSBrowser.rightColorMap)) 
	  rcm = eval([obj.guiData.TSBrowser.rightColorMap '(256);']);
	else
	  rcm = obj.guiData.TSBrowser.rightColorMap;
	end

	% call plotter
  obj.plotTimeSeriesAsImage(rightList{rightIdx(1)}, rightIdx(2), ESShownList, [],[],rcm,[0 10], rivr, rightAxisH);

	% update gui stuff
  rightTitleList = get(obj.guiData.TSBrowser.ui.rightTitleH,'String');
  rightTitleIdx = find(strcmp(rightTitleList,  rightList{rightIdx(1)}.idStrs{rightIdx(2)}));
  set(obj.guiData.TSBrowser.ui.rightTitleH, 'Value', rightTitleIdx);
	set(rightAxisH, 'YTick',[]);
	set(leftAxisH, 'YTick',[]);
	

  % check for line plot
	if (length(lineFigH) > 0)
	  if (ishandle(lineFigH))
			updateRightLine(obj);
	  else
			slcm = get(obj.guiData.TSBrowser.ui.showLineCheckH, 'Min'); 
			set(obj.guiData.TSBrowser.ui.showLineCheckH, 'Value', slcm);
		  lineFigH = [];
		end
	end
	
	% check for trial plot
	if (isfield(obj.guiData.TSBrowser,'trialPlotHandle') &&  ...
	    ~isempty(obj.guiData.TSBrowser.trialPlotHandle) && ...
	   ishandle(obj.guiData.TSBrowser.trialPlotHandle(1))&& ...
     obj.guiData.TSBrowser.trialPlotOn)
	  updateSingleTrialPlot(obj);
	end

%
% updates rhgt panel of the line plot 
%
function updateRightLine(obj)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

  if (length(rightList) == 0) ; return ; end
  
  % build ES shown list
	ESShown = find(obj.guiData.TSBrowser.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.guiData.TSBrowser.ESList{ESShown(e)};
	end

	% call plotter
  M = max(max(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:)));
  m = min(min(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:)));
	R = M-m;

  obj.plotTimeSeriesAsLine(rightList{rightIdx(1)}, rightIdx(2), ESShownList, [], [],[0 10 m-0.1*R M+0.1*R],lineFigH(4:5));

	set(lineFigH(4), 'XTick',[]);


%
% updates single trial plot
%
function updateSingleTrialPlot(obj)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

  % build ES shown list
	ESShown = find(obj.guiData.TSBrowser.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.guiData.TSBrowser.ESList{ESShown(e)};
	end

	% call plotter
  lineFigH = obj.guiData.TSBrowser.trialPlotHandle;
  
  if (length(leftList) > 0)
    obj.plotTimeSeriesAsLine(leftList{leftIdx(1)}, leftIdx(2), ESShownList, [], obj.guiData.TSBrowser.trialPlotTrialNumber,[0 10 -0.5 2],lineFigH(2:3));

    % add trial # to titles
    titleH = get(lineFigH(2),'Title');
    curTitle = get(titleH,'String');
    set(titleH, 'String', [curTitle ' (trial: ' num2str(obj.guiData.TSBrowser.trialPlotTrialNumber) ')']);
  end

	% call plotter
  if (length(rightList) > 0)
    M = max(max(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:)));
    m = min(min(rightList{rightIdx(1)}.valueMatrix(rightIdx(2),:)));
    R = M-m;

    obj.plotTimeSeriesAsLine(rightList{rightIdx(1)}, rightIdx(2), ESShownList, [],  obj.guiData.TSBrowser.trialPlotTrialNumber,[0 10 m-0.1*R M+0.1*R],lineFigH(4:5));
 
    % add trial # to titles
    titleH = get(lineFigH(4),'Title');
    curTitle = get(titleH,'String');
    set(titleH, 'String', [curTitle ' (trial: ' num2str(obj.guiData.TSBrowser.trialPlotTrialNumber) ')']);
  end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Enables/disables line plot
%
function toggleLinePlot (hObj, event, obj)

  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

  % check check
	slcM = get(obj.guiData.TSBrowser.ui.showLineCheckH, 'Max'); 
	slcm = get(obj.guiData.TSBrowser.ui.showLineCheckH, 'Min'); 
	slcV = get(obj.guiData.TSBrowser.ui.showLineCheckH, 'Value');

	% does it exist?
	redo = 0;
	if (slcV == slcm) % just got unchecked
	  if (length(lineFigH) > 0)
		  if (ishandle(lineFigH(1)))
				delete(lineFigH(1));
			end
			lineFigH = [];
		end
	else % just got checked ...
		if (length(lineFigH) < 5)
			redo = 1;
		elseif (~ishandle(lineFigH(2)))
			redo = 1;
	  end % weird, but just in case we dont recreate ...
	end

	% draw if needbe
	if (redo)
	  lineFigH(1) = figure('Position',[100 100 800 400], 'Name', 'TimeSeries line Browser', 'NumberTitle','off');
		lineFigH(3) = axes('Position',[0.05 .05 .45 .45]); % top left
		lineFigH(2) = axes('Position',[0.05 .525 .45 .45]); % bottom left
		lineFigH(5) = axes('Position',[0.5375 .05 .45 .45]); % top right
		lineFigH(4) = axes('Position',[0.5375 .525 .45 .45]); % bottom right
	end

	% assign guiData.TSBrowser
	assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList);

  if (redo)
		% draw BOTH
		updateLeftLine(obj);
		updateRightLine(obj);
	end


% 
% chg right time series ; dTS = 0 implies pulldown
%
function chgRight (hObj, event, obj, dTS)

  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

	% get TS #
	if (dTS ~= 0)
		rightIdx(2) = rightIdx(2)+dTS;
		if (rightIdx(2) > rightList{rightIdx(1)}.length()) ; rightIdx(2) = 1; rightIdx(1) = rightIdx(1)+1; end
		if (rightIdx(2) < 1) ; rightIdx(1) = rightIdx(1)-1;	if (rightIdx(1) < 1) ; rightIdx(1) = length(rightList) ; end; rightIdx(2)=rightList{rightIdx(1)}.length() ; end
		if (rightIdx(1) > length(rightList)) ; rightIdx(1) = 1; end
	else
	  rightTitleList = get(obj.guiData.TSBrowser.ui.rightTitleH,'String');
	  rightTitleIdx = get(obj.guiData.TSBrowser.ui.rightTitleH,'Value');
		rightTitleStr = rightTitleList{rightTitleIdx};

		% loop thru right objects and find match -- cheap and effective ;)
		done = 0;
		for R1=1:length(rightList)
		  for R2=1:rightList{R1}.length()
			  if (strcmp(rightTitleStr, rightList{R1}.idStrs{R2}))
				  rightIdx(1) = R1;
					rightIdx(2) = R2;
					done = 1;
					break;
				end
			end
			if (done) ; break ; end
		end
	end

	% assign guiData.TSBrowser
	assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList);

	% draw 
	updateRightPanel(obj);

% 
% starts the roi gui
%
function toggleRoiGui(hObj, event,obj, dTS)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

  % check check
	srgM = get(obj.guiData.TSBrowser.ui.showRoiGuiCheckH, 'Max'); 
	srgm = get(obj.guiData.TSBrowser.ui.showRoiGuiCheckH, 'Min'); 
	srgV = get(obj.guiData.TSBrowser.ui.showRoiGuiCheckH, 'Value');


  % start and initialize ROI gui appropriately
	if (srgV == srgM)
	  fovIdx = obj.caTSA.roiFOVidx(leftIdx(2));

		obj.caTSA.roiArray{fovIdx}.startGui();
		obj.caTSA.roiArray{fovIdx}.guiSelectedRoiIds = obj.caTSA.ids(leftIdx(2));
		obj.caTSA.roiArray{fovIdx}.guiShowFlags = [0 1 0];
		obj.caTSA.roiArray{fovIdx}.updateImage();

		% hook up callback FROM roiAray
		obj.caTSA.roiArray{fovIdx}.updateImagePostFunction = @updateFromRoiGui;
		obj.caTSA.roiArray{fovIdx}.updateImagePostFunctionParams = {obj, fovIdx};

		% set lastRoiFOV
		obj.guiData.TSBrowser.lastRoiFOV = fovIdx;
	else % delete
	  for f=1:obj.caTSA.numFOVs
		  if (length(obj.caTSA.roiArray{f}.guiHandles) >= 3 && ishandle(obj.caTSA.roiArray{f}.guiHandles(3)))
				delete (obj.caTSA.roiArray{f}.guiHandles(3));
			end
			if (length(obj.caTSA.roiArray{f}.guiHandles) >= 0)
				obj.caTSA.roiArray{f}.guiHandles = [];
			end
		end
	end

	% assign guiData.TSBrowser
	assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList);
	obj.guiData.TSBrowser.roiGuiOn = 1;


% 
% starts the trial gui
%
function toggleTrialGui(hObj, event,obj, dTS)
  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

  % check check
	stgM = get(obj.guiData.TSBrowser.ui.showTrialGuiCheckH, 'Max'); 
	stgm = get(obj.guiData.TSBrowser.ui.showTrialGuiCheckH, 'Min'); 
	stgV = get(obj.guiData.TSBrowser.ui.showTrialGuiCheckH, 'Value');


  % set flag and tell user to click
	if (stgV == stgM)
		obj.guiData.TSBrowser.trialPlotOn = 1;
		obj.guiData.TSBrowser.trialPlotHandle = [];
		disp('guiTSBrowser::Click on a time series image to select the trial to plot.');
	else % delete
		obj.guiData.TSBrowser.trialPlotOn = 0;
		if (isfield(obj.guiData.TSBrowser,'trialPlotHandle') && ...
        ~isempty(obj.guiData.TSBrowser.trialPlotHandle) && ...
        ishandle(obj.guiData.TSBrowser.trialPlotHandle(1)))
			delete (obj.guiData.TSBrowser.trialPlotHandle(1));
		end
	end

	% assign guiData.TSBrowser
	assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList);

% 
% chg lefttime series -- if dTS = 0, it means use popup index #
%
function chgLeft(hObj, event,obj, dTS)

  % pull guiData.TSBrowser
  [figH lineFigH leftAxisH rightAxisH leftIdx rightIdx leftList rightList] = decomposeGuiData(obj);

	% get TS #
	if (dTS ~= 0)
		leftIdx(2) = leftIdx(2)+dTS;
		if (leftIdx(2) > leftList{leftIdx(1)}.length()) ; leftIdx(2) = 1; leftIdx(1) = leftIdx(1)+1; end

		if (leftIdx(2) < 1) ; leftIdx(1) = leftIdx(1)-1; if (leftIdx(1) < 1) ; leftIdx(1) = length(leftList) ; end ;leftIdx(2)=leftList{leftIdx(1)}.length() ; end
		if (leftIdx(1) > length(leftList)) ; leftIdx(1) = 1; end
	else
	  leftTitleList = get(obj.guiData.TSBrowser.ui.leftTitleH,'String');
	  leftTitleIdx = get(obj.guiData.TSBrowser.ui.leftTitleH,'Value');
		leftTitleStr = leftTitleList{leftTitleIdx};

		% loop thru left objects and find match -- cheap and effective ;)
		done = 0;
		for L1=1:length(leftList)
		  for L2=1:leftList{L1}.length()
			  if (strcmp(leftTitleStr, leftList{L1}.idStrs{L2}))
				  leftIdx(1) = L1;
					leftIdx(2) = L2;
					done = 1;
					break;
				end
			end
			if (done) ; break ; end
		end
	end

	% assign guiData.TSBrowser
	assignGuiData(obj, figH, lineFigH, leftAxisH, rightAxisH, leftIdx, rightIdx, leftList, rightList);

	% draw 
	updateLeftPanel(obj);

%
% invokes the ES Gui
%
function invokeESGui(hObj, event,obj)
  obj.guiESControl();

%
% invokes the plot setup Gui
%
function invokePlotSetupGui(hObj, event,obj)
  obj.guiPlotSetupControl();

%
% callback that is invoked when image in roiArray is updated (e.g., user selected new Roi)
%
function updateFromRoiGui(params)
  % pull obj
	obj = params{1};
	callerFOVidx= params{2};
	lastFOV = obj.guiData.TSBrowser.lastRoiFOV;

	% update ... if user didnt do something screwy like select tons and tons of dude
 	if (length(obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds) == 1 && ...
	    length(find(obj.caTSA.ids == obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds)) == 1)
	  nli = find(obj.caTSA.ids == obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds);
 		if (nli ~= obj.guiData.TSBrowser.leftIdx(2)) % only if necessary -- i.e., i.d. changed
  		obj.guiData.TSBrowser.leftIdx(2) = find(obj.caTSA.ids == obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds);
	  	obj.guiTSBrowser('updateLeftPanelNoRoiCheck');

 			% make roi array dominant
  		figure(obj.caTSA.roiArray{callerFOVidx}.guiHandles(3));
	  end
	
	  % same FOV?
		if (callerFOVidx == lastFOV)
			% let roiArray do his thing
			obj.caTSA.roiArray{callerFOVidx}.updateGui({});
		else % new? must change some other stuff.
      % assign guiSelectedRoiIds
      obj.caTSA.roiArray{lastFOV}.guiSelectedRoiIds = [];
			obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds = obj.caTSA.ids(obj.guiData.TSBrowser.leftIdx(2));

      % cleanup previous
		  obj.caTSA.roiArray{lastFOV}.updateImage();
     	obj.caTSA.roiArray{lastFOV}.updateGui({});

			% set last FOV
	    obj.guiData.TSBrowser.lastRoiFOV = callerFOVidx;

			% update image 
  		obj.caTSA.roiArray{callerFOVidx}.updateImage();
			obj.caTSA.roiArray{callerFOVidx}.updateGui({});
		end
	else % be safe - update your gui!
		obj.caTSA.roiArray{callerFOVidx}.updateGui({});
	end



