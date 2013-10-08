%
% load object from file
%
% sourceFilePath -- where to load from
% dataFormat -- 1: redundant -- use object model
%               2: roi structure
%               3: rtrk structure
%
function obj = loadFromFile(sourceFilePath, dataFormat)
	% --- prelims
  global rootDataPath;

  % --- invoke GUI if path is blank or directory ...
	if (strcmp(sourceFilePath,''))
			[filename, filepath]=uigetfile({'*.mat'}, ...
				'Select ROI file', rootDataPath);
			sourceFilePath = [filepath filesep filename];
	elseif (isdir(sourceFilePath))
			[filename, filepath]=uigetfile({'*.mat'}, ...
				'Select ROI file', sourceFilePath);
			sourceFilePath = [filepath filesep filename];
	end
	if (~exist(sourceFilePath,'file')) 
	  disp('Invalid filename.'); 
		obj = []; 
		return ; 
	end


	% --- loading ... -- either 1 or many arguments
	nobj = [];
  disp(['roiArray.loadFromFile::loading ' sourceFilePath '...']);
	if(nargin == 1) 
		tobj = load (sourceFilePath,'-mat');  
		if (~isfield(tobj, 'obj') & isfield(tobj,'roi'))
			obj = roi.roiArray();
			obj.loadFromStructFile(sourceFilePath);
		else
			nobj = tobj.obj;
		end
	elseif(nargin == 2) % load from file, but based on mode
		if (dataFormat == 1) % object
			tobj = load (sourceFilePath, '-mat');  
			nobj = tobj.obj;
		elseif (dataFormat == 2) % old fashioned roi structure
			obj = roi.roiArray();
			obj.loadFromStructFile(sourceFilePath);
		elseif (dataFormat == 3) % tim rtrk format
			obj = roi.roiArray();
			obj.loadFromRtrkFile(sourceFilePath);
		else
			disp('roi.roiArray::unrecognized load mode.');
		end
	end

  % --- object loading - easy breeze
	if (length(nobj) > 0)
		obj = roi.roiArray();
		obj.idStr = nobj.idStr;
		obj.rois = nobj.rois;
		obj.roiIds = nobj.roiIds;
		obj.imageBounds = nobj.imageBounds;
		obj.masterImage = nobj.masterImage;
		obj.masterImageRelPath = nobj.masterImageRelPath;
		obj.accessoryImagesRelPaths = nobj.accessoryImagesRelPaths;
		obj.aspectRatio = nobj.aspectRatio;
		obj.permanentAccessoryImages = nobj.permanentAccessoryImages;
  end

	% --- Default color mode
	obj.colorByBaseScheme();

  % --- make X,Y matrices for fast computation
	if (obj.imageBounds(1) > 0)
		obj.workingImageYMat = repmat(1:obj.imageBounds(1), obj.imageBounds(2),1)';
		obj.workingImageXMat = repmat(1:obj.imageBounds(2), obj.imageBounds(1),1);
	end
	
	% --- assign ID if none present
	if (strcmp(obj.idStr,''))
	  [pathstr name ext] = fileparts(sourceFilePath);
	  obj.idStr = name;
	end
	obj.roiFileName = sourceFilePath;

	% --- echo some stuff
  disp(['Number of rois: ' num2str(length(obj.rois))]);
