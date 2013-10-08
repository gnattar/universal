%
% SP Sept 2011
% 
% Wrapper for invoking various methods so you can do hooks.  Since you
%  are probably doing this only if you knwo what you are doing, read the
%  sub-functions to gain an understanding in detail.  
%
% USAGE: 
%
%   s.guiTSABrowser(subFunction, subFunctionParams)
%
% subFunction: if blank, just start the gui (startGui), otherwise will do 
%              eval('subFunction(obj, subFunctionParams)')
% subFunctionParams: parameters passed to subFunction ; can be blank, in 
%              which case eval is off of subFunction(obj)
%
function guiTSABrowser(obj, subFunction, subFunctionParams)
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
  % --- already active?
	alreadyPresent = 1;
  if (length(ishandle(obj.figH)) == 0)
	  alreadyPresent = 0;
  elseif(~ishandle(obj.figH) || ~ishandle(obj.rightAxisH))
	  alreadyPresent = 0;
	end

	if (~alreadyPresent)
		% ========================================================================
		% --- GUI STUFF

		% figure
		obj.figH = figure('Position',[10 10 1010 1010],'DockControls', 'off', 'Menubar', 'none',   'Name', ['Timeseries Browser'], 'NumberTitle','off');

		% left plot image
		obj.leftAxisH = axes('Position',[0.01 .01 .48 .9]);
		obj.rightAxisH = axes('Position',[0.51 .01 .48 .9]);

		% action buttons
		bh = 0.025; % button height
		th = 0.025; % text height
		gy = 0.95; % gui y
		sx = 0.01;
		x = sx;
		w = 0.03 ; prevLeftButtonXH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','<<','Position',[x gy w bh], 'Callback', {@chgLeft, obj, -10});
		x = x+sx+w; w=.03; prevLeftButtonH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','<','Position',[x gy w bh], 'Callback', {@chgLeft, obj, -1});
		x = x+sx+w; w=.2; leftTitleH = uicontrol(obj.figH,'Style','Popup','Units','normalized','String',obj.leftListIdStr,'Value',1,'Position',[x gy w th], 'Callback', {@chgLeft, obj, 0});
%		x = x+sx+w; w=.2; leftTitleH = uicontrol(obj.figH,'Style','Text','Units','normalized','String','','Position',[x gy w th]);
		x = x+sx+w; w=.03; nextLeftButtonH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','>','Position',[x gy w bh], 'Callback', {@chgLeft, obj, 1});
		x = x+sx+w; w=.03; nextLeftButtonXH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','>>','Position',[x gy w bh], 'Callback', {@chgLeft, obj, 10});
		x = x+sx+w; w=.05; showRoiGuiCheckH= uicontrol(obj.figH,'Style','CheckBox','Units','normalized','String','ROIs','Position',[x gy w bh], 'Callback', {@toggleRoiGui, obj});
		srgm = get(showRoiGuiCheckH, 'Min'); set(showRoiGuiCheckH, 'Value', srgm);
		x = x+sx+w; w=.05; showTrialGuiCheckH= uicontrol(obj.figH,'Style','CheckBox','Units','normalized','String','Trial','Position',[x gy w bh], 'Callback', {@toggleTrialGui, obj, 10});
		stgm = get(showTrialGuiCheckH, 'Min'); set(showTrialGuiCheckH, 'Value', stgm);

    % start @ ~middle
		x = 0.53; w=.09; showLineCheckH = uicontrol(obj.figH,'Style','CheckBox','Units','normalized','String','Line Plot', 'Position',[x gy w bh], 'Callback', {@toggleLinePlot, obj});
		slcm = get(showLineCheckH, 'Min'); set(showLineCheckH, 'Value', slcm);

		x = x+sx+w; w=.03; prevRightButtonH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','<','Position',[x gy w bh], 'Callback', {@chgRight, obj, -1});
%		x = x+sx+w; w=.2; rightTitleH = uicontrol(figH,'Style','Text','Units','normalized','String','','Position',[x gy w th]);
		x = x+sx+w; w=.2; rightTitleH = uicontrol(obj.figH,'Style','Popup','Units','normalized','String',obj.rightListIdStr,'Value',1,'Position',[x gy w th], 'Callback', {@chgRight, obj, 0});
		x = x+sx+w; w=.03; 	nextRightButtonH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','>','Position',[x gy w bh], 'Callback', {@chgRight, obj, 1});
		x = x+sx+w; w=.03; 	esControlButtonH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','ES','Position',[x gy w bh], 'Callback', {@invokeESGui, obj});
		x = x+sx+w; w=.03; 	plotControlButtonH = uicontrol(obj.figH,'Style','PushButton','Units','normalized','String','SU','Position',[x gy w bh], 'Callback', {@invokePlotSetupGui, obj});

		% Assign indices
		obj.leftIdx = [1 1];
		obj.rightIdx = [1 1];

		% gui objects
		obj.ui.leftTitleH = leftTitleH;
		obj.ui.rightTitleH = rightTitleH;
		obj.ui.showLineCheckH = showLineCheckH;
		obj.ui.showRoiGuiCheckH = showRoiGuiCheckH;
		obj.ui.showTrialGuiCheckH = showTrialGuiCheckH;

		% Roi stuff
		obj.lastRoiFOV = -1;

		% plotting parameters
		obj.leftColorMap = 'gray';
		obj.rightColorMap = 'gray';
		obj.leftImageValueRange = '[m M]';
		obj.rightImageValueRange = '[m M]';
		obj.leftPlotValueRange = '[m M]';
		obj.leftPlotValueRange = '[m M]';

    % image gui callback
		if (length( obj.imageMouseClickCallback) == 0) 
		  obj.imageMouseClickCallback = {@imageMouseClickCallback, obj};
		end

	else % just select it
	  figure(obj.figH);
	end

	% draw image
	updateLeftPanel(obj);
	updateRightPanel(obj);

%
% quick update
%
function updateGui(obj)
	% draw image
	updateLeftPanel(obj);
	updateRightPanel(obj);

%
% when user clicks mouse over image (default functino)
%
function imageMouseClickCallback (obj, trialNum)

	% display, set trial #
	disp(['Trial # Ca: ' num2str(trialNum)]);

	% if trial plot is enabled, update it
	stgM = get(obj.ui.showTrialGuiCheckH, 'Max'); 
	stgm = get(obj.ui.showTrialGuiCheckH, 'Min'); 
	stgV = get(obj.ui.showTrialGuiCheckH, 'Value');
	if (stgV == stgM)
    obj.trialPlotTrialNumber = trialNum;
    obj.updateSingleTrialPlot();
	end

%
% Draws everything on LEFT panel
%
function updateLeftPanelNoRoiCheck (obj)

	% sanity check
	if (length(obj.leftListTSA) == 0) ; return ; end

  % build ES shown list
	ESShown = find(obj.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.ESList{ESShown(e)};
	end

  % plot params
	if (ischar(obj.leftImageValueRange))
		M = nanmax(nanmax(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:)));
		m = nanmin(nanmin(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:)));
		sd = nanstd(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));
		mu = nanmean(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));
		med = nanmedian(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));

		livr = eval([obj.leftImageValueRange ';']);
	else
	  livr = obj.leftImageValueRange;
	end

	if (ischar(obj.leftColorMap)) 
	  lcm = eval([obj.leftColorMap '(256);']);
	else
	  lcm = obj.leftColorMap;
	end

	% call plotter
  if (length(obj.leftListTSA) > 0)
    session.timeSeriesArray.plotTimeSeriesAsImageS(obj.leftListTSA{obj.leftIdx(1)}, obj.leftIdx(2), ...
		   obj.trialStartTimeMat, ESShownList, obj.shownTrials, obj.trialTypeMat,[], 1, lcm,[0 10],livr, ...
			 obj.leftAxisH, obj.imageMouseClickCallback);
	  leftTitleList = get(obj.ui.leftTitleH,'String');
	  leftTitleIdx = find(strcmp(leftTitleList,  obj.leftListTSA{obj.leftIdx(1)}.idStrs{obj.leftIdx(2)}));
	  set(obj.ui.leftTitleH, 'Value', leftTitleIdx);
  
    % check for line plot
    if (length(obj.lineFigH) > 0)
      if (ishandle(obj.lineFigH))
        updateLeftLine(obj);
      else
        slcm = get(obj.ui.showLineCheckH, 'Min'); 
        set(obj.ui.showLineCheckH, 'Value', slcm);
        obj.lineFigH = [];
      end
    end
  end

%
% Draws everything on left, WITH roiArrayCheck
%
function updateLeftPanel (obj)
  updateLeftPanelNoRoiCheck(obj);

	% sanity check
	if (length(obj.leftListTSA) == 0) ; return ; end

	% check for roi
	srgM = get(obj.ui.showRoiGuiCheckH, 'Max'); 
	srgm = get(obj.ui.showRoiGuiCheckH, 'Min'); 
	srgV = get(obj.ui.showRoiGuiCheckH, 'Value');

  % start and initialize ROI gui appropriately
	if (srgV == srgM)
	  if (~isempty(obj.updateRoiGuiFunction))
		  feval(obj.updateRoiGuiFunction{1}, obj.updateRoiGuiFunction{2:end});
		end
	end
	
	% update single trial plot
	obj.updateSingleTrialPlot();

%
% updates left panel of the line plot [= left]
%
function updateLeftLine(obj)
  
  if (length(obj.leftListTSA) == 0) ; return ; end

  % build ES shown list
	ESShown = find(obj.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.ESList{ESShown(e)};
	end

	% plot value range
  lpvr = [nan nan];
	if (ischar(obj.leftPlotValueRange))
		M = nanmax(nanmax(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:)));
		m = nanmin(nanmin(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:)));
		sd = nanstd(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));
		mu = nanmean(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));
		med = nanmedian(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));

		lpvr = eval([obj.leftPlotValueRange ';']);
  elseif (length(obj.leftPlotValueRange) == 2)
		lpvr = obj.leftPlotValueRange;
	end

  % plotter call
   session.timeSeriesArray.plotTimeSeriesAsLineS(obj.leftListTSA{obj.leftIdx(1)}, obj.leftIdx(2), ...
       obj.trialStartTimeMat, ESShownList, obj.shownTrials, obj.trialTypeMat, ...
			 obj.trialType, obj.trialTypeStr, obj.trialTypeColor, ...
			 [0 10 lpvr(1) lpvr(2)], obj.lineFigH(2:3), 0);
	set(obj.lineFigH(2), 'XTick',[]);

%
% Draws everything on RIGHT panel
%
function updateRightPanel (obj)
	% sanity check
	if (length(obj.rightListTSA) == 0) ; return ; end

  % build ES shown list
	ESShown = find(obj.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.ESList{ESShown(e)};
	end

  % plot params
	if (ischar(obj.rightImageValueRange))
		M = nanmax(nanmax(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:)));
		m = nanmin(nanmin(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:)));
		sd = nanstd(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));
		mu = nanmean(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));
		med = nanmedian(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));

		rivr = eval([obj.rightImageValueRange ';']);
	else
	  rivr = obj.rightImageValueRange;
	end

	if (ischar(obj.rightColorMap)) 
	  rcm = eval([obj.rightColorMap '(256);']);
	else
	  rcm = obj.rightColorMap;
	end

	% call plotter
  session.timeSeriesArray.plotTimeSeriesAsImageS(obj.rightListTSA{obj.rightIdx(1)}, obj.rightIdx(2), ...
		   obj.trialStartTimeMat, ESShownList, obj.shownTrials, obj.trialTypeMat,[], 1, rcm,[0 10],rivr, ...
			 obj.rightAxisH, obj.imageMouseClickCallback);

	% update gui stuff
  rightTitleList = get(obj.ui.rightTitleH,'String');
  rightTitleIdx = find(strcmp(rightTitleList,  obj.rightListTSA{obj.rightIdx(1)}.idStrs{obj.rightIdx(2)}));
  set(obj.ui.rightTitleH, 'Value', rightTitleIdx);
	set(obj.rightAxisH, 'YTick',[]);
	set(obj.leftAxisH, 'YTick',[]);
	

  % check for line plot
	if (length(obj.lineFigH) > 0)
	  if (ishandle(obj.lineFigH))
			updateRightLine(obj);
	  else
			slcm = get(obj.ui.showLineCheckH, 'Min'); 
			set(obj.ui.showLineCheckH, 'Value', slcm);
		  obj.lineFigH = [];
		end
	end
	
	% check for trial plot
	obj.updateSingleTrialPlot();

%
% updates rhgt panel of the line plot 
%
function updateRightLine(obj)
  if (length(obj.rightListTSA) == 0) ; return ; end
  
  % build ES shown list
	ESShown = find(obj.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.ESList{ESShown(e)};
	end

	% plot value range
	rpvr = [nan nan];
	if (ischar(obj.rightPlotValueRange))
		M = nanmax(nanmax(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:)));
		m = nanmin(nanmin(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:)));
		sd = nanstd(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));
		mu = nanmean(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));
		med = nanmedian(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));

		rpvr = eval([obj.rightPlotValueRange ';']);
	elseif (length(obj.rightPlotValueRange) == 2)
		rpvr = obj.rightPlotValueRange;
	end

	% plotter call
	session.timeSeriesArray.plotTimeSeriesAsLineS(obj.rightListTSA{obj.rightIdx(1)}, obj.rightIdx(2), ...
		 obj.trialStartTimeMat, ESShownList, obj.shownTrials, obj.trialTypeMat, ...
		 obj.trialType, obj.trialTypeStr, obj.trialTypeColor, ...
		 [0 10 rpvr(1) rpvr(2)], obj.lineFigH(4:5), 0);
	set(obj.lineFigH(4), 'XTick',[]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Enables/disables line plot
%
function toggleLinePlot (hObj, event, obj)
  % check check
	slcM = get(obj.ui.showLineCheckH, 'Max'); 
	slcm = get(obj.ui.showLineCheckH, 'Min'); 
	slcV = get(obj.ui.showLineCheckH, 'Value');

	% does it exist?
	redo = 0;
	if (slcV == slcm) % just got unchecked
	  if (length(obj.lineFigH) > 0)
		  if (ishandle(obj.lineFigH(1)))
				delete(obj.lineFigH(1));
			end
			obj.lineFigH = [];
		end
	else % just got checked ...
		if (length(obj.lineFigH) < 5)
			redo = 1;
		elseif (~ishandle(obj.lineFigH(2)))
			redo = 1;
	  end % weird, but just in case we dont recreate ...
	end

	% draw if needbe
	if (redo)
	  obj.lineFigH(1) = figure('Position',[100 100 800 400], 'Name', 'TimeSeries line Browser', 'NumberTitle','off');
		obj.lineFigH(3) = axes('Position',[0.05 .05 .45 .45]); % top left
		obj.lineFigH(2) = axes('Position',[0.05 .525 .45 .45]); % bottom left
		obj.lineFigH(5) = axes('Position',[0.5375 .05 .45 .45]); % top right
		obj.lineFigH(4) = axes('Position',[0.5375 .525 .45 .45]); % bottom right
	end

  if (redo)
		% draw BOTH
		updateLeftLine(obj);
		updateRightLine(obj);
	end


% 
% chg right time series ; dTS = 0 implies pulldown
%
function chgRight (hObj, event, obj, dTS)

	% get TS #
	if (dTS ~= 0)
		obj.rightIdx(2) = obj.rightIdx(2)+dTS;
		if (obj.rightIdx(2) > obj.rightListTSA{obj.rightIdx(1)}.length()) ; obj.rightIdx(2) = 1; obj.rightIdx(1) = obj.rightIdx(1)+1; end
		if (obj.rightIdx(2) < 1) ; obj.rightIdx(1) = obj.rightIdx(1)-1;	if (obj.rightIdx(1) < 1) ; obj.rightIdx(1) = length(obj.rightListTSA) ; end; obj.rightIdx(2)=obj.rightListTSA{obj.rightIdx(1)}.length() ; end
		if (obj.rightIdx(1) > length(obj.rightListTSA)) ; obj.rightIdx(1) = 1; end
	else
	  rightTitleList = get(obj.ui.rightTitleH,'String');
	  rightTitleIdx = get(obj.ui.rightTitleH,'Value');
		rightTitleStr = rightTitleList{rightTitleIdx};

		% loop thru right objects and find match -- cheap and effective ;)
		done = 0;
		for R1=1:length(obj.rightListTSA)
		  for R2=1:obj.rightListTSA{R1}.length()
			  if (strcmp(rightTitleStr, obj.rightListTSA{R1}.idStrs{R2}))
				  obj.rightIdx(1) = R1;
					obj.rightIdx(2) = R2;
					done = 1;
					break;
				end
			end
			if (done) ; break ; end
		end
	end

	% draw 
	updateRightPanel(obj);

% 
% starts the roi gui
%
function toggleRoiGui(hObj, event,obj)
  disp('toggleRoiGui::not hooked up to anything');

  % check check
	srgM = get(obj.ui.showRoiGuiCheckH, 'Max'); 
	srgm = get(obj.ui.showRoiGuiCheckH, 'Min'); 
	srgV = get(obj.ui.showRoiGuiCheckH, 'Value');

  % start and initialize ROI gui appropriately
	if (srgV == srgM)
	else % delete
	end


% 
% starts the trial gui
%
function toggleTrialGui(hObj, event,obj, dTS)

  % check check
	stgM = get(obj.ui.showTrialGuiCheckH, 'Max'); 
	stgm = get(obj.ui.showTrialGuiCheckH, 'Min'); 
	stgV = get(obj.ui.showTrialGuiCheckH, 'Value');


  % set flag and tell user to click
	if (stgV == stgM)
		obj.trialPlotH = [];
		disp('guiTSABrowser::Click on a time series image to select the trial to plot.');
	else % delete
		if ( ~isempty(obj.trialPlotH) && ...
        ishandle(obj.trialPlotH(1)))
			delete (obj.trialPlotH(1));
			obj.trialPlotTrialNumber = [];
		end
	end

% 
% chg lefttime series -- if dTS = 0, it means use popup index #
%
function chgLeft(hObj, event,obj, dTS)
	% get TS #
	if (dTS ~= 0)
		obj.leftIdx(2) = obj.leftIdx(2)+dTS;
		if (obj.leftIdx(2) > obj.leftListTSA{obj.leftIdx(1)}.length()) ; obj.leftIdx(2) = 1; obj.leftIdx(1) = obj.leftIdx(1)+1; end

		if (obj.leftIdx(2) < 1) ; obj.leftIdx(1) = obj.leftIdx(1)-1; if (obj.leftIdx(1) < 1) ; obj.leftIdx(1) = length(obj.leftListTSA) ; end ;obj.leftIdx(2)=obj.leftListTSA{obj.leftIdx(1)}.length() ; end
		if (obj.leftIdx(1) > length(obj.leftListTSA)) ; obj.leftIdx(1) = 1; end
	else
	  leftTitleList = get(obj.ui.leftTitleH,'String');
	  leftTitleIdx = get(obj.ui.leftTitleH,'Value');
		leftTitleStr = leftTitleList{leftTitleIdx};

		% loop thru left objects and find match -- cheap and effective ;)
		done = 0;
		for L1=1:length(obj.leftListTSA)
		  for L2=1:obj.leftListTSA{L1}.length()
			  if (strcmp(leftTitleStr, obj.leftListTSA{L1}.idStrs{L2}))
				  obj.leftIdx(1) = L1;
					obj.leftIdx(2) = L2;
					done = 1;
					break;
				end
			end
			if (done) ; break ; end
		end
	end

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


