%
% SP Sept 2011
% 
% Wrapper for session.guiTSABrowser that specifically passes typical params
%  and also hooks up to ROI stuff.
%
% USAGE: 
%
%   s.guiTSABrowser()
%
function guiTSABrowser(obj)
  % --- setup TSAs
	leftListTSA = {};
	rightListTSA = {};

  if (length(obj.caTSA) > 0 && length(obj.caTSA.dffTimeSeriesArray) > 0); leftListTSA = {obj.caTSA.dffTimeSeriesArray};end
  
	if (length(obj.derivedDataTSA) > 0) ; rightListTSA{length(rightListTSA)+1} = obj.derivedDataTSA; end
	if (length(obj.whiskerCurvatureChangeTSA) > 0); rightListTSA{length(rightListTSA)+1} = obj.whiskerCurvatureChangeTSA; end
	if (length(obj.whiskerCurvatureTSA)>0); rightListTSA{length(rightListTSA)+1} = obj.whiskerCurvatureTSA; end
	if (length(obj.whiskerAngleTSA) > 0); rightListTSA{length(rightListTSA)+1} = obj.whiskerAngleTSA; end
	if (length(obj.ephusTSA) > 0); rightListTSA{length(rightListTSA)+1} = obj.ephusTSA; end

  % --- event series
	ESList = {};
  wbiri = 0; % whisker bar in reach index -- we want this on by default
	if (length(obj.behavESA) > 0)
		for b=1:length(obj.behavESA.esa)
			ESList{length(ESList)+1} = obj.behavESA.esa{b};
		end
	end
	if (length(obj.whiskerBarContactESA) > 0)
		for c=1:length(obj.whiskerBarContactESA.esa)
			if (iscell(	obj.whiskerBarContactESA.esa{c}.idStr))
				obj.whiskerBarContactESA.esa{c}.idStr= [char(obj.whiskerBarContactESA.esa{c}.idStr{1}) ' ' char(obj.whiskerBarContactESA.esa{c}.idStr{2})];
			end
			ESList{length(ESList)+1} = obj.whiskerBarContactESA.esa{c};
		end
	end
	if (length(obj.whiskerBarContactClassifiedESA) > 0)
		for c=1:length(obj.whiskerBarContactClassifiedESA.esa)
			ESList{length(ESList)+1} = obj.whiskerBarContactClassifiedESA.esa{c};
		end
	end
	if (length(obj.whiskerBarInReachES) > 0)
		wbiri = length(ESList)+1;
		ESList{length(ESList)+1} = obj.whiskerBarInReachES; 
	end
	if (length(obj.caTSA) > 0 && length(obj.caTSA.caPeakEventSeriesArray) > 0)
		for c=1:length(obj.caTSA.caPeakEventSeriesArray.esa)
			ESList{length(ESList)+1} = obj.caTSA.caPeakEventSeriesArray.esa{c};
		end
	end
	ESListOn = zeros(1,length(ESList));
	if (wbiri > 0) ; ESListOn (wbiri) = 1; end% bar in reach

	% turn on touches if 1 whisker
	if (length(obj.whiskerTag) == 1)
	  wtag = lower(obj.whiskerTag{1});
		for e=1:length(ESList)
			if (strcmpi(ESList{e}.idStr, ['Protraction contacts for ' wtag])) 
				ESListOn(e) = 1;
			elseif (strcmpi(ESList{e}.idStr, ['Retraction contacts for ' wtag])) 
				ESListOn(e) = 1;
			end
		end
	end

  % --- start it
  params.leftListTSA = leftListTSA;
  params.rightListTSA = rightListTSA;
	params.ESList = ESList;
	params.ESListOn = ESListOn;

	TSABrowser = session.guiTSABrowser(obj.trialIds, obj.trialStartTimes, obj.trialTypeMat, ...
	              obj.validTrialIds,  obj.trialType, obj.trialTypeStr, obj.trialTypeColor, params);
	TSABrowser.leftColorMap = 'gray';
	TSABrowser.rightColorMap = 'gray';
  TSABrowser.leftImageValueRange = '[0 5*sd]';
  TSABrowser.rightImageValueRange = '[med-5*sd med+5*sd]';

  TSABrowser.leftPlotValueRange = '[-1*sd 8*sd]';
  TSABrowser.rightPlotValueRange = '[med-3*sd med+8*sd]';
   
 

  % --- roiArray hookups
	set(TSABrowser.ui.showRoiGuiCheckH, 'Callback', {@toggleRoiGuiCallback, obj});
	TSABrowser.updateRoiGuiFunction = {@updateRoiGuiFunction, obj};
	%% obj.guiData.TSBrowser.lastRoiFOV = -1;

	% --- and finally connect browser to guiData
	obj.guiData.TSABrowser = TSABrowser;
	TSABrowser.guiWrapper('updateGui');

%
% Updates roi view when something changed locally
%
function updateRoiGuiFunction (obj)
  % start and initialize ROI gui appropriately
	leftIdx = obj.guiData.TSABrowser.leftIdx;
	fovIdx = obj.caTSA.roiFOVidx(leftIdx(2));
	lastFOV = obj.guiData.TSABrowser.lastRoiFOV;
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
		obj.guiData.TSABrowser.lastRoiFOV = fovIdx;
	end

	obj.caTSA.roiArray{fovIdx}.updateImage();

% 
% called by TSABrowser whenever roi gui is turned toggled
%
function toggleRoiGuiCallback(irr1, irr2, obj)
  % check check
	srgM = get(obj.guiData.TSABrowser.ui.showRoiGuiCheckH, 'Max'); 
	srgm = get(obj.guiData.TSABrowser.ui.showRoiGuiCheckH, 'Min'); 
	srgV = get(obj.guiData.TSABrowser.ui.showRoiGuiCheckH, 'Value');

  % ghetto stuff
	xpos = [0 512 0 512];
	ypos = [512 512 0 0 ]; % 565
 
  % start and initialize ROI gui appropriately
	leftIdx = obj.guiData.TSABrowser.leftIdx;
	if (srgV == srgM)
		fovIdx = obj.caTSA.roiFOVidx(leftIdx(2));
	  for f=1:obj.caTSA.numFOVs

			obj.caTSA.roiArray{f}.startGui();
			set(obj.caTSA.roiArray{f}.guiHandles(3), 'Position', [xpos(f) ypos(f) 512 512]);
			if (f == fovIdx) ; obj.caTSA.roiArray{f}.guiSelectedRoiIds = obj.caTSA.ids(leftIdx(2)); end
			obj.caTSA.roiArray{f}.guiShowFlags = [0 1 0];
			obj.caTSA.roiArray{f}.updateImage();

			% hook up callback FROM roiAray
			obj.caTSA.roiArray{f}.updateImagePostFunction = @updateFromRoiGui;
			obj.caTSA.roiArray{f}.updateImagePostFunctionParams = {obj, f};

			% set lastRoiFOV
			obj.guiData.TSABrowser.lastRoiFOV = fovIdx;
		end
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


%
% callback that is invoked when image in roiArray is updated (e.g., user selected new Roi)
%
function updateFromRoiGui(params)
  % pull obj
	obj = params{1};
	callerFOVidx= params{2};
	lastFOV = obj.guiData.TSABrowser.lastRoiFOV;

	% update ... if user didnt do something screwy like select tons and tons of dude
 	if (length(obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds) == 1 && ...
	    length(find(obj.caTSA.ids == obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds)) == 1)
	  nli = find(obj.caTSA.ids == obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds);
 		if (nli ~= obj.guiData.TSABrowser.leftIdx(2)) % only if necessary -- i.e., i.d. changed
  		obj.guiData.TSABrowser.leftIdx(2) = find(obj.caTSA.ids == obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds);
	  	obj.guiData.TSABrowser.guiWrapper('updateLeftPanelNoRoiCheck');

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
			obj.caTSA.roiArray{callerFOVidx}.guiSelectedRoiIds = obj.caTSA.ids(obj.guiData.TSABrowser.leftIdx(2));

      % cleanup previous
		  obj.caTSA.roiArray{lastFOV}.updateImage();
     	obj.caTSA.roiArray{lastFOV}.updateGui({});

			% set last FOV
	    obj.guiData.TSABrowser.lastRoiFOV = callerFOVidx;

			% update image 
  		obj.caTSA.roiArray{callerFOVidx}.updateImage();
			obj.caTSA.roiArray{callerFOVidx}.updateGui({});
		end
	else % be safe - update your gui!
		obj.caTSA.roiArray{callerFOVidx}.updateGui({});
	end



