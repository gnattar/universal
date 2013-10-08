%
% This is a container for multiple +roi.roi objects.
%
% STARTING UP
%
% Call the constructor: 
%  
% rA = roiArray(newIdStr, newRoiGroupArray, newImageBounds, ...
%		    newMasterImage, newMasterImageRelPath, newAccesoryImagesRelPaths, ...
%				newAspectRatio).
%  
% Generally you can use the blank version, then set master image, and start 
%   the gui: 
%
% rA = roi.roiArray();
% rA.masterImage = 'somepath';
% rA.startGui();
%
% You could also select master image via a dialog:
%
% rA.selectMasterImage();
%
% And you can specify what path to start the file browser in:
%
% rA.selectMasterImage('/home/speron/myImages');
% 
% It is generally a good idea to select some accessory images to use for ROI 
%  selection. 
% 
% USING BUILT IN GUI IN OTHER PROGRAMS:
%
% Start by callign rA.startGui(), where rA is your roiArray class name.  Or,
% to connect this to an existing GUI, connect to your functions in the following
%  manner:
%
%			obj.workingImageMouseClickFunction = {@obj.guiMouseClickProcessor};
%			obj.workingImageKeyPressFunction = {@obj.guiKeyStrokeProcessor};
%
%  workingImageMouseClickFunction will be called whenever there is a mouseClick;
%  you should do what you need, then call roiArray.guiMouseClickProcessor; same
%  for key strokes.  Of course, you could just use startGui here, or put the
%  above two lines in your code replacing obj with whatever name you have for the
%  instance of roiArray you are working with.  Every time the image is updated,
%  via updateImage(), the KeyPressFcn property of the figure the image sits in is 
%  set to the workingImageKeyPressFunction; similarly, the ButtonDownFcn property
%  of the image is set to workingImageMouseClickFunction.
%
% (C) Simon Peron May 2010
%
classdef roiArray < handle
  % Properties
  properties 
	  % basics
		idStr = ''; % ID for this roiArray - e.g., mouse & date
		rois; % the rois themselves
		roiFileName = ''; % stores roi filename upon save/load
		roiIds = []; % vector with id of each roi -- CONTROLLED INTERNALLY
		roiGroupArray = []; % roiGroupArray object

    roiIdRange ;% If assigned, roiIds must abide by this constraint (min,max inclusive)
	
	  settings = []; % structure with assorted settings -- see get.settings for details

		% images/image properties
		imageBounds = [0 0]; % bounds of the image ; propagated down to all daughter ROIs
		masterImage = []; % the master image to which ROIs were fitted
		masterImageRelPath = ''; % relative to global rootDataPath (if absent, '~/data/' assumed root)
		accessoryImagesRelPaths = {}; % cell array of additional images used ; if it
	                                % is a permanentAccessoryImages, it should be
																	% permanentAccessoryImages#1 for, e.g., {1}
		permanentAccessoryImages = {}; % accessory images that are stored long-term
		                               % use sparingly or this gets HUGE
		aspectRatio = 1; % aspect ratio applied to workingImage ; 1: square 2: image based 
		                 %  (i.e., keep pixel x and y size same) ; 2 numbers: assumed to be
										 %  in um/pix, with first for x axis and 2nd for y axis
		refStackRelPath = ''; % (relative) path to the reference stack to which you map masterImage
		refStackMap = []; % structure with fields X Y & Z which are matrices of size
		                  % masterImage that contain mapping from masterImage to the 
											% reference stack.  Specifically, masterImage(i,j) maps to
											% stack coordinates (Y(i,j), X(i,j), Z(i,j))

    % internal
	  loading; % set to 1 during loads to avoid set meethod calls
  end
	
  properties(Transient = true) % not saved to file
	  % misc
		accessoryImages = {}; % cell array with accessory images -- loaded on the FLY ; NOT SAVED

	  % working image
		baseWorkingImage = []; % the initial working image (so that, e.g., image adjust
		                       % has one to go back to).
		workingImage = []; % the image currently employed for restriction etc
		workingImageXMat = []; % stores x value for each pixel
		workingImageYMat = []; % stores y value for each pixel
		workingImageColorMap = []; % rgb colormap to apply to working image; [] means greyscale

		workingImageIndex = 0; % 0: working image ; 1:n - accesory image ; INTERNAL
		workingImageFrameIndex = 1; % frame within working images ; INTERNAL
		workingImageMouseClickFunction = ''; % the pointer to the function called when mouse is clicked on image
		workingImageKeyPressFunction = ''; % the pointer to the function called when button is pressed while
		                              % working image parent figure is selected

		% gui-related stuff 
		guiSelectedRoiIds = []; % selected ROI(s) when in gui mode
    guiMouseMode = 0; % 0: off;  1: roi draw ; 2: select roi ; 3: select multiple ; 4: poly
		                  %   based selection 5: Tsai-wen auto-detector 6: gradient auto-detector
		guiPanZoomMode = 0; % 0: nothing 1: zoom on 2: pan on
		guiHandles = []; % (by index:) 1: the image handle from imshow 2: the axis handle 3: figure handle
		guiShowFlags = []; %  (by index): 1: show borders 2: show indices 3: show numbers
		guiPolyCorners = []; % corners of polygon being drawn in gui
		guiRoiArrayMenu = []; % handle to the pulldown menu off of the figure with roi array options
    guiRoiArrayMenuCallbackFunction = {}; % stores callbacks for roi array menu items
		guiData = []; % stores data for other-than-main gui things (button panels you may bring up etc.)
		updateImagePostFunction = ''; % This points to a function called at the *end* of updateImage; leave
		                             % blank for nothing
		updateImagePostFunctionParams = {}; % params passed to above function ; cell
  end

  % constants
  properties (Constant = true)
	  % maximal pixel value -- depends on your bit rate (12=4096)
	  maxImagePixelValue = 4096;
	end
		




	% Methods -- public
  methods (Access = public)
	  %
	  % Constructor
		%
    function obj = roiArray(newIdStr, newRoiGroupArray, newImageBounds, ...
		    newMasterImage, newMasterImageRelPath, newAccessoryImagesRelPaths, ...
				newAspectRatio)

			obj.loading = 0;

			if (nargin == 7) % assign iff patssed
				obj.idStr = newIdStr;
				obj.roiGroupArray = newRoiGroupArray;
				obj.imageBounds = newImageBounds;
				obj.masterImage = newMasterImage;
				obj.masterImageRelPath = newMasterImageRelPath;
				obj.accessoryImagesRelPaths = newAccessoryImagesRelPaths;
				obj.aspectRatio = newAspectRatio;
			end

			% global path
			if (isempty(whos('global', 'rootDataPath')));
			  disp(['roiArray::requires global rootDataPath ; setting to ~' filesep 'data' filesep]);
				global rootDataPath;
				rootDataPath = ['~' filesep 'data' filesep];
			else
			  global rootDataPath;
				if (length(rootDataPath) == 0)
					rootDataPath = ['~' filesep 'data' filesep];
				end
			end

			% no roiGroupArray? assign default
			if (length(obj.roiGroupArray) == 0)
			  obj.roiGroupArray = roi.roiGroupArray.generateDefaultGroupArray();
			end
		end

		% 
		% return a copy of the object w/ same key properties
		%
		function newRoiArray = copy (obj)
		  % instantiate
		  newRoiArray = roi.roiArray(obj.idStr, [], obj.imageBounds, obj.masterImage, ...
			  obj.masterImageRelPath, obj.accessoryImagesRelPaths, obj.aspectRatio);

			% clone subobjects
			for r=1:length(obj.rois)
			  newRoiArray.rois{r} = obj.rois{r}.copy();
			end
			newRoiArray.roiIds  = obj.roiIds; 
			newRoiArray.roiGroupArray = obj.roiGroupArray.copy();
		end

		% 
		% add ROI
		%
		function obj = addRoi(obj, roi)
      % idx 
			idx = length(obj.rois) + 1;
		 
		  % id?
			if (roi.id == -1)
			  if (length(obj.roiIds) == 0)
				  roi.id = 1;
				else
					roi.id = max(obj.roiIds)+1;
				end
			else
			  % check redundancy
			  if (length(find(obj.roiIds == roi.id)) > 0)
				  disp('roiArray.addRoi::roi ID already present; replacing roi ID of the ROI you are adding.');
          roi.id = max(obj.roiIds) + 1;
				end
			end

			% range obedience ...
      if (length(obj.roiIdRange) > 0)
			  % have we maxed out?
				avail = setdiff(obj.roiIdRange(1):obj.roiIdRange(2), obj.roiIds);
				if (length(avail) == 0)
				  disp('roiArray.addRoi::all roi IDs are used ; change roiIdRange.');
					return;
				elseif (~ ismember(roi.id, avail)) % not an allowed ID? force
				  disp(['roiArray.addRoi::roi ID ' num2str(roi.id) ' is not allowed; setting to ' num2str(min(avail))]);
				  roi.id = min(avail);
				end
			end

			% and add ...
			obj.roiIds(idx) = roi.id;
			obj.rois{idx} = roi;
			roi.imageBounds = obj.imageBounds;
		end

		%
		% Remove ROI(s)
		%
		function obj = removeRois(obj, roiIds)
		  remove_idx = [];
		  for r=1:length(roiIds)
		    remove_idx = [remove_idx find(obj.roiIds == roiIds(r))];
			end
			keep_idx = setdiff(1:length(obj.roiIds), remove_idx);

			% remove
			obj.rois= obj.rois(keep_idx);
			obj.roiIds = obj.roiIds(keep_idx);
		end

		%
		% Length -- # of rois
		%
		function value = length(obj)
		  value = length(obj.rois);
		end

		%
		% Merge ROIs by roiIds
		%
		function obj = mergeRois(obj, roiIds)
		  newRoi = obj.getRoiById(roiIds(1));

			% populate indices
		  for r=2:length(roiIds)
			  deadRoi = obj.getRoiById(roiIds(r));
				newRoi.indices = union(newRoi.indices, deadRoi.indices);
			end

			% remove rois 2 and up
			obj.removeRois(roiIds(2:length(roiIds)));

			% recompute border
			obj.fitRoiBordersToIndices(newRoi.id);
		end

		%
		% Changes a ROI's ID if allowed
		%
		function obj = changeRoiId(obj, oldId, newId)
		  % only if no newId
      if (length(find(obj.roiIds == newId)) == 0)
			  % now check roiIdRange constraint
				if (length(obj.roiIdRange) > 0)
				  if (obj.roiIdRange(1) > newId | obj.roiIdRange(2) < newId)
					  disp('changeRoiId::requested ID falls outsied roiIdRange.');
						return;
					end
				end
				idx = find(obj.roiIds == oldId);
				obj.rois{idx}.id = newId;
				obj.roiIds(idx) = newId;
			else
			  disp('changeRoiId::requested ID already used.');
			end
		end

		%
		% Sorts roi IDs
		%
		function obj = sortRoiIds(obj)
		  [newVals idx] = sort(obj.roiIds);
      obj.roiIds = newVals;
			obj.rois = obj.rois(idx);
		end

		% 
		% Forces roi ids to be 1:length(obj.rois) ; sorts prior to this move.
    % 
		% If roiIdRange defined, uses roiIdRange(1):length(obj.rois)+roiIdRange
		%
		function obj = useAscendingRoiIds(obj)
		  obj.sortRoiIds();
      
			minRoiId = 1;
			if (length(obj.roiIdRange) > 0) ; minRoiId = obj.roiIdRange(1) ; end

			obj.roiIds = minRoiId+(0:(length(obj.roiIds)-1));
			for r=1:length(obj.roiIds)
			  obj.rois{r}.id = obj.roiIds(r);
			end
		end

		%
		% Adds another roiArray's roi objects
		%
		function obj = addAnotherArraysRois(obj, otherRoiArray)
		  for r=1:length(otherRoiArray.rois)
			  nRoi = otherRoiArray.rois{r}.copy();
				obj.addRoi(nRoi);
			end
		end

    %
		% add ROI(s) to group, specified by group and roi ID(s)
		%
		function obj = addRoisToGroup(obj, roiIds, groupId)
		  for r=1:length(roiIds)
				idx = find(obj.roiIds == roiIds(r));
				if (length(idx) > 0) % found match?
				  obj.rois{idx}.addToGroup(groupId);
			  end
			end
		end

    %
		% remove ROI(s) from group, specified by group and roi ID(s)
		%
		function obj = removeRoisFromGroup(obj, roiIds, groupId)
		  for r=1:length(roiIds)
				idx = find(obj.roiIds == roiIds(r));
				if (length(idx) > 0) % found match?
				  obj.rois{idx}.removeFromGroup(groupId);
			  end
			end
		end

		% 
		% Gets ROI by its ID
		%
		function roi = getRoiById(obj, roiId)
			idx = find(obj.roiIds == roiId);
			if (length(idx) == 1)
			  roi = obj.rois{idx};
			else
			  roi = [];
			end
		end

		%
		% Returns the roi objects for members of a group
		%
		function rois = getRoisInGroup(obj, groupId)
		  rois = {};
		  for r=1:length(obj.rois)
			  if (obj.rois{r}.isInGroup(groupId))
				  rois{length(rois)+1} = obj.rois{r};
				end
			end
		end

		%
		% Returns the roi ids for members of a group
		%
		function ids = getIdsOfRoisInGroup(obj,groupId)
		  ids = [];
		  for r=1:length(obj.rois)
			  if (obj.rois{r}.isInGroup(groupId))
				  ids = [ids obj.roiIds(r)];
				end
			end
		end

    % 
		% add an accessory image -- give path to add in transient matter (loaded
		%   on the fly in the future) or pass actual image to store that permamenntly.
		%   imageName - only if permanent image
		function obj = addAccessoryImage(obj, accessoryImageFullPathOrImage, imageName)
		  if (nargin < 3) 
			  imageName = '';
			end
		  % numeric -- permanentAccessoryImages
			if (isnumeric(accessoryImageFullPathOrImage))
			  pidx = length(obj.permanentAccessoryImages)+ 1; % default is add
			  idx = length(obj.accessoryImagesRelPaths)+ 1; % default is add
			  % replace?
				for i=1:length(obj.accessoryImagesRelPaths)
			    pimIdx = strfind(obj.accessoryImagesRelPaths{i}, 'permanentAccessoryImage#');
					if (length(pimIdx) > 1)
			      poundIdx = find(obj.accessoryImagesRelPaths{i} == '#');
					  stripPath = obj.accessoryImagesRelPaths{i}(poundIdx(2)+1:end);
						if(strcmp(stripPath, imageName))
						  idx = i;
	        		pidx=str2num(obj.accessoryImagesRelPaths{accessoryImageIdx}(poundIdx(1)+1:poundIdx(2)-1));
						end
					end
				end
				% do it 
			  obj.permanentAccessoryImages{pidx} = accessoryImageFullPathOrImage;
				obj.accessoryImagesRelPaths{idx} = ['permanentAccessoryImage#' num2str(pidx) '#' imageName];
			else
				% path?
				global rootDataPath;
				% need to add?
				if (length(find(strcmp(obj.accessoryImagesRelPaths,accessoryImageFullPathOrImage) == 1)) == 0)
					accessoryImageRelPath = [strrep(accessoryImageFullPathOrImage, rootDataPath, '')];
					obj.accessoryImagesRelPaths{length(obj.accessoryImagesRelPaths)+1} = accessoryImageRelPath;
				end
			end
			% gui update?
			if (ishandle(obj.guiRoiArrayMenu) & sum(obj.guiHandles) > 0) ; obj.guiCreateRoiArrayMenu(obj.guiHandles(3)) ; end
		end
    
		%
		% remove an accessory image -- either by path str or id # --
		%  that is, accessoryImageId can be either numeric or string
		%
		function obj = removeAccessoryImage(obj, accessoryImageId)
		  removeId = [];

		  if (isnumeric(accessoryImageId))
			  removeId = accessoryImageId;
			else
				removeId = find(strcmp(obj.accessoryImagesRelPaths,accessoryImageId) == 1);
			end

      % remove permanent?
			if (length(strfind(obj.accessoryImagesRelPaths{removeId}, 'permanentAccessoryImage#')) > 0)
			  poundIdx = find(obj.accessoryImagesRelPaths{accessoryImageIdx} == '#');
				idx=str2num(obj.accessoryImagesRelPaths{accessoryImageIdx}(poundIdx(1)+1:poundIdx(2)-1));
				obj.permanentAccessoryImages{idx} = [];
			end

      % remove from path list
      vals = setdiff(1:length(obj.accessoryImagesRelPaths), removeId);
			obj.accessoryImagesRelPaths = obj.accessoryImagesRelPaths{vals};

			% gui update?
			if (ishandle(obj.guiRoiArrayMenu) & sum(obj.guiHandles) > 0) ; obj.guiCreateRoiArrayMenu(obj.guiHandles(3)) ; end
		end

		% 
		% select master image via gui
		%
		function obj = selectMasterImage(obj, startPath)
		  global rootDataPath;
			if (nargin < 2) % no startPath specified? pick
				if (length(obj.masterImageRelPath) > 0) % cue off of master image path
					startPath = fileparts(obj.masterImageRelPath);
					if (~ isdir(startPath)) ; startPath = [rootDataPath filesep startPath]; end
					if (~ isdir(startPath)) ; startPath = rootDataPath; end
				else 
					startPath = rootDataPath ; 
				end
			end
			[filename, filepath]=uigetfile({'*.tif'}, 'Select image', startPath);
			newMasterImagePath = [filepath filesep filename];

			% assign image by loading ; then assign path
			if (~ filepath)
			  disp('No file selected');
			else
				obj.masterImage= load_image(newMasterImagePath);
				obj.masterImageRelPath = [strrep(newMasterImagePath, rootDataPath, '')];
			end
		end

		% 
		% add accessory image via gui
		%
		function obj = addAccessoryImageViaGui(obj)
		  global rootDataPath;
		  if (length(obj.masterImageRelPath) > 0)% cue off of master image path
			  startPath = fileparts(obj.masterImageRelPath);
				if (~ isdir(startPath)) ; startPath = [rootDataPath filesep startPath]; end
				if (~ isdir(startPath)) ; startPath = rootDataPath; end
			else ; startPath = rootDataPath ; end
			[filename, filepath]=uigetfile({'*.tif'}, 'Select image', startPath);
			newAccessoryImagePath = [filepath filesep filename];
			if (~ filepath)
			  disp('No file selected.');
      else 
				obj.addAccessoryImage(newAccessoryImagePath);
			end
		end

    % 
		% sets working image to master image
		% 
		function obj = useMasterImage(obj)
		  obj.baseWorkingImage = obj.masterImage;
			obj.workingImageIndex = 0;
			obj.workingImageFrameIndex = 1;
			obj.updateImage();
			disp(['roiArray::using image file ' obj.masterImageRelPath]);
		end

    %
		% sets to FIRST matching accessory image
		% 
    function obj = useAccessoryImageMatching (obj, accessoryImageRelPathStr, updateImage)
      if (nargin < 3)
        updateImage = 1;
      end
      
		  foundIdx = -1;
		  for i=1:length(obj.accessoryImagesRelPaths)
	  		if (length(strfind(obj.accessoryImagesRelPaths{i}, accessoryImageRelPathStr)) > 0)
				  foundIdx = i;
					break
				end
			end
			if (foundIdx > 0)
			  obj.useAccessoryImage(foundIdx, [],updateImage);
			end
		end

    % 
		% sets accessory image specified by accesoryImageIdx to workingImage; since these 
		%  are never in memory, you must load it.
		% 
		function obj = useAccessoryImage(obj, accessoryImageIdx, accessoryImageFrameIdx, updateImage)
		  global rootDataPath;
			oldWorkingImageIndex = obj.workingImageIndex;

			% frame?
			if (nargin < 3 || length(accessoryImageFrameIdx) == 0)
			  accessoryImageFrameIdx = 1;
      end
      
      % image update
      if (nargin < 4 || length(updateImage) == 0)
        updateImage = 1;
      end

      % permament or load?
			if (length(strfind(obj.accessoryImagesRelPaths{accessoryImageIdx}, 'permanentAccessoryImage#')) > 0)
			  poundIdx = find(obj.accessoryImagesRelPaths{accessoryImageIdx} == '#');
				idx=str2num(obj.accessoryImagesRelPaths{accessoryImageIdx}(poundIdx(1)+1:poundIdx(2)-1));
				obj.accessoryImages{accessoryImageIdx} = obj.permanentAccessoryImages{idx};
				accessoryImageFullPath = ['permanent accessory image # ' num2str(idx)];
				if (length(obj.accessoryImagesRelPaths{accessoryImageIdx} > poundIdx(2)))
					imageName = obj.accessoryImagesRelPaths{accessoryImageIdx}(poundIdx(2)+1:end);
					accessoryImageFullPath = [accessoryImageFullPath ' ' imageName];
				end
			else % LOAD
				% try with and w/o rootDataPath
				accessoryImageFullPath = [rootDataPath filesep obj.accessoryImagesRelPaths{accessoryImageIdx}];
				if (~ exist(accessoryImageFullPath,'file'))
					accessoryImageFullPath =  obj.accessoryImagesRelPaths{accessoryImageIdx};
				end
				if (~ exist(accessoryImageFullPath,'file')) % FAIL
					disp(['roiArray.getAccessoryImage::' accessoryImageFullPath ' does not exist.']);
					return;
				else
					% load if necessary
					if (length(obj.accessoryImages) < accessoryImageIdx)
						obj.accessoryImages{accessoryImageIdx} = load_image(accessoryImageFullPath);
					elseif (length(obj.accessoryImages{accessoryImageIdx}) == 0)
						obj.accessoryImages{accessoryImageIdx} = load_image(accessoryImageFullPath);
					end
				end
				accessoryImageFullPath = ['image file ' accessoryImageFullPath];
			end

			% assign working image
			obj.workingImageIndex = accessoryImageIdx;
			obj.workingImageFrameIndex = accessoryImageFrameIdx;
			obj.baseWorkingImage = obj.accessoryImages{accessoryImageIdx}(:,:,accessoryImageFrameIdx);
			if (updateImage) ; obj.updateImage(); end
			if (oldWorkingImageIndex ~= obj.workingImageIndex)
				disp(['roiArray::using ' accessoryImageFullPath]);
			end
		end

		%
		% Increments workingImageIndex appropriately
		%
		function obj = nextWorkingImage(obj)
		  nextIndex = obj.workingImageIndex+1;
			if (nextIndex > length(obj.accessoryImagesRelPaths)) % loop back to master img
				obj.useMasterImage();
			else % you are obviously > 0 (!)
			  obj.useAccessoryImage(nextIndex);
		  end
		end

		%
		% Increments workingImageIndex appropriately
		%
		function obj = prevWorkingImage(obj)
		  prevIndex = obj.workingImageIndex-1;
			if (prevIndex < 0) % loop back to end
				prevIndex = length(obj.accessoryImagesRelPaths);
			end
			if (prevIndex == 0)
				obj.useMasterImage();
			else
				obj.useAccessoryImage(prevIndex);
			end
		end

		%
		% Increments workingImageFrameIndex appropriately
		%
		function obj = nextWorkingImageFrame(obj)
			if (obj.workingImageIndex == 0) ; return ; end % no frame #s for master image
		  nextFrameIndex = obj.workingImageFrameIndex+1;
			if (nextFrameIndex > size(obj.accessoryImages{obj.workingImageIndex},3))
				nextFrameIndex = 1;
			end
			obj.useAccessoryImage(obj.workingImageIndex, nextFrameIndex);
		end

		%
		% Increments workingImageFrameIndex appropriately
		%
		function obj = prevWorkingImageFrame(obj)
			if (obj.workingImageIndex == 0) ; return ; end % no frame #s for master image
		  prevFrameIndex = obj.workingImageFrameIndex-1;
			if (prevFrameIndex < 1) 
				prevFrameIndex = size(obj.accessoryImages{obj.workingImageIndex},3);
			end
			obj.useAccessoryImage(obj.workingImageIndex, prevFrameIndex);
		end

		% 
		% Enables zoom mode
		%
		function obj = guiZoomToggle(obj)
		  if (obj.guiPanZoomMode ~=1) % disable others then enable
				pan(obj.guiHandles(3),'off');
				zoom(obj.guiHandles(3),'on');
				obj.guiPanZoomMode = 1;
				disp('roi.roiArray::zoom mode on ; hit ctrl/apple-z to turn off.');
			else
				obj.guiPanZoomMode = 0;
				zoom(obj.guiHandles(3),'off');
			end
		end

		% 
		% Enables pan mode
		%
		function obj = guiPanToggle(obj)
		  if (obj.guiPanZoomMode ~=2) % disable others then enable
				pan(obj.guiHandles(3),'on');
				zoom(obj.guiHandles(3),'off');
				obj.guiPanZoomMode = 2;
				disp('roi.roiArray::pan mode on ; hit ctrl/apple-x to turn off.');
			else
				obj.guiPanZoomMode = 0;
				pan(obj.guiHandles(3),'off');
			end
		end

		% Wrapper for single call to registerToRefStackS
		function obj = registerToRefStack(obj, refStackPath, params)
		  roi.roiArray.registerToRefStackS(refStackPath, obj, params);
		end

		% returns the REAL refStackPath
		function refStackPath = getRefStackPath (obj)
		  refStackPath = strrep(obj.refStackRelPath, '<%rootDataPath%>', get_root_data_path);
		end

		% For saving
		saveToFile(obj, outputPath, dataFormat)

		% Returns indices that are not in any ROIs - for, e.g., background subtraction
		antiRoiIdx = getAntiRoiIndices(obj, useBorderOrIndices, dilateBy)

		% Gui for mainipulating workingImage
		guiWorkingImageControl(obj)

    % stats related to roi fillage (GECIs)
    [isFilled ecRatio cmRatio pixValIQR borderVal centerVal] = getRoiFillingStatistics(obj, roiIds)
		 
		% colors by fillage
    colorByFilled(obj, roiIds)

    %%%%%%%%%%%%%%%%%%%%%%% (SEMI) AUTO ROI GENERATION %%%%%%%%%%%%%%%%%%%%%%%%%

    % generate ROIs via intensity
		roiGenAutoIntensity(obj, roiIds, params)
 
		% generate ROI given a center point using TsaiWen donut algo
    roiGenSemiautoTsaiWen(obj, centerPoint, debug)

		% generate ROI given a center point using luminance gradient drop algo
    roiGenSemiautoGradient(obj, centerPoint)

    % method to resolve overlapping ROIS
    resolveOverlaps (obj, method, params)


    %%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERDAY MAPPING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% method for finding misaligned rois
    [outlierIds redoThresh] = getAlignmentOutliers(obj,objB)

		% Corrects outliers in mapping in calling object
		obj = correctAlignmentOutliers (obj, objB, outlierIdx, params)

		% plots interday transform
		plotInterdayTransform (obj, objB, axHandles)

		% computes the correlation between day images
		score = scoreInterdayTransform (obj, objB, method)

		% Generates new roiArray objects based off of this one for all directories
		%  that contain image registration post-processing info specified by wildcard
		generateDerivedRoiArrays(obj, dirList, idStr, outputPath)
	end

  % Static -- file loading
  methods (Static = true)
    % load object from file
    obj = loadFromFile(sourceFilePath, dataFormat)

    % Loads multiple files, and starts in multi-file mode
		obj = loadMultipleRoiArrays(sourceDir)

		% For matching ROIs to new image
		corrvals = findMatchingRoisInNewImage(rA_t, rA_s, params)

		% detects cells using a gradient approach
    [borderXY borderIndices roiIndices] = cellDetGradient(obj, im, center, params)

		% match to reference stack (multiple or single roiArray objects)
		registerToRefStackS(refStackPath, roiArrays, params)

		% assigns settings structure
		settings = assignSettings(settings);

		% loading from file -- flag that load is done for underlying rois
    function obj = loadobj(a)
	    a.loading = 1;
		  obj = a;
			obj.loading = 0;
		end
	end

  % Methods -- set/get/basic variable manipulation stuff
	methods 
	  % -- ID string ; nothing for now
	  function obj = set.idStr (obj, newIdStr)
		  obj.idStr = newIdStr;
		end
	  function value = get.idStr (obj)
		  value = obj.idStr;
		end

		% -- get call to settings -- assign any missing
		function value = get.settings(obj)
		  obj.settings = roi.roiArray.assignSettings(obj.settings);
			value = obj.settings;
		end

		% -- set ID range 
		function obj = set.roiIdRange (obj, newIdRange)
		  if (obj.loading) % just loading?
			  obj.roiIdRange = newIdRange; 
			else
				if (length(newIdRange) > 0 & length(newIdRange) ~= 2)
					disp('roiArray::roiIdRange must be two numbers -- inclusive min and max.');
					return;
				elseif (length(newIdRange) == 2)
					inval = find(obj.roiIds > newIdRange(2) | obj.roiIds < newIdRange(1));
					if (length(inval) > 0)
						disp(['roiArray::removing ' num2str(length(inval)) ' invalid rois.']);
						obj.removeRois(obj.roiIds(inval));
					end
					obj.roiIdRange = newIdRange;
				end
			end
		end

    % -- image bounds -- propagate to all child ROIs
		function obj = set.imageBounds(obj, newImageBounds)
		  if (obj.loading) % just loading?
				obj.imageBounds = newImageBounds;
				
				% since this *will* get called on the load, we only do workingImageX/Y assignment here 
				%  during load
				obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
				obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
			else
				if (newImageBounds(1) ~= 0 & newImageBounds(2) ~= 0)
					obj.imageBounds = newImageBounds;
					for r=1:length(obj.rois)
						obj.rois{r}.imageBounds = newImageBounds;   
					end
					obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
					obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
				end
			end
		end

		% --- set master image ; updates path if it is a path
		function obj = set.masterImage(obj, newMasterImage)
		  global rootDataPath;
		  % either load it or assign it -- if string, assume it is path
			if (isnumeric(newMasterImage))
				obj.masterImage = newMasterImage;
			else % assign image by loading ; then assign path
			  obj.masterImage= load_image(newMasterImage);
				obj.masterImageRelPath = [strrep(newMasterImage, rootDataPath, '')];
			end
			if (size(obj.masterImage,3) > 1)
			  obj.masterImage = mean(obj.masterImage,3);
				disp('roiArray.setMasterImage::masterImage must be single frame ; using mean of provided stack.  Use accessory images for multiframe support.');
			end
			% gui update?
			if (ishandle(obj.guiRoiArrayMenu) & sum(obj.guiHandles) > 0) ; obj.guiCreateRoiArrayMenu(obj.guiHandles(3)) ; end
		end

		% --- get master image -- not loaded but path specified? load.
		function value = get.masterImage(obj)
		  if (size(obj.masterImage,1) == 0 & length(obj.masterImageRelPath) > 0)
				global rootDataPath;
				masterImageFullPath = [rootDataPath filesep obj.masterImageRelPath];
				if (~ exist(masterImageFullPath,'file'))
				  masterImageFullPath = obj.masterImageRelPath;
				end
				if (~ exist(masterImageFullPath,'file'))
				  disp(['roiArray.getMasterImage::' masterImageFullPath ' does not exist.']);
				else
					obj.masterImage = load_image(masterImageFullPath);
				end
			end
			value = obj.masterImage;
		end

		% --- set working image ; this should update image bounds etc
		function obj = set.workingImage(obj, newWorkingImage)
		  if (obj.loading) % just load
				obj.workingImage = newWorkingImage;
			else  
				% bounds
				obj.imageBounds = [size(newWorkingImage,1) size(newWorkingImage,2)];

				% update wokringImageXMAT/YMAT
				obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
				obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);

				% and the image itself
				obj.workingImage = newWorkingImage;
			end
		end

		% --- get working image -- if there is a master but no working image, assign
    function value = get.workingImage(obj)
		  if (size(obj.workingImage,1) == 0 & size(obj.masterImage,1)> 0)
			  obj.baseWorkingImage = obj.masterImage; 
			end
			value = obj.workingImage;
		end

		% --- automatically assigns workingImage too
		function obj = set.baseWorkingImage(obj, newBaseWorkingImage)
		  % either load it or assign it -- if string, assume it is path
			if (isnumeric(newBaseWorkingImage))
				obj.baseWorkingImage = newBaseWorkingImage;
			else % assign image from path -- *temporarily*
			  obj.baseWorkingImage = load_image(newBaseWorkingImage);
				% must be 1 frame if this way . . . 
				if (size(obj.baseWorkingImage,3) > 1) ; obj.baseWorkingImage = mean(obj.baseWorkingImage,3); end
			end
			% assign workingImage
			obj.workingImage = obj.baseWorkingImage;

			% apply gui stuff if needbe
      obj.applyWorkingImageControl();
		end

		% --- set guiShowFlags -- this invokes updateImage ; assign newGuiShowFlags(4) any value to
		%     skip obj.updateImage (otherwise infinite recursion!)
    function obj = set.guiShowFlags(obj, newGuiShowFlags)
		  if (length(newGuiShowFlags) == 3)
				obj.guiShowFlags = newGuiShowFlags;
				obj.updateImage();
			elseif(length(newGuiShowFlags) == 4)
				obj.guiShowFlags = newGuiShowFlags(1:3);
			elseif(length(newGuiShowFlags) ~= 3)
				obj.guiShowFlags = newGuiShowFlags;
			else
				obj.guiShowFlags = newGuiShowFlags(1:3);
			end
    end
	end
end

