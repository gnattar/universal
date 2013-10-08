%
% SP June 2010
%
% This will generate a calcium timeseries array from RAW data, given a roiArray
%  object, as well as a data path and wildcard.  Initially, trial #s will simply
%  be based on the file's appearance in the list or ???_###.tif where # is a 
%  number.  Update this once you collate, or provide list of trial #s explcitly
%  via dataFileTrial and dataFileList.
%
%  obj.ids() will contain roiID ; idStr will be "roi ##" where ## is id
%
% USAGE:
%
%   obj = generateCalciumTimeSeriesArray(roiArray, dataPath, dataWC,  ...
%                         ignoreSessionStats, dataFileList, dataFileTrial)
%
% PARAMS:
%
%   roiArray: either a roiArray object OR a string specifying a file to load 
%             one from.  Pass a cell array of either strings or filenames if 
%             you are using multiple fields-of-view.
%   dataPath: where data is (directory); if you give dataFileList, you still 
%             need to give this if you want to use imreg_session_stats.mat, for
%             this is the directory in which it looks for that file.  For 
%             multi-FOV, you must pass a cell-array of directories, same order 
%             as roiArray.
%   dataWC: wildcared within dataPath; not necessary if you give dataFileList. 
%           For multiple fields-of-view, can be single (in which case it 
%           applies to each directory) or a cell array (1/roiArray).
%   ignoreSessionStats (optional): by default imreg_session_stats.mat's accept 
%     array is used to rule out motion or weird luminance contaminated trials.
%     Set this flag to 1 to ignore this.
%   dataFileList (optional): explicit list of files ; cell array with FULL 
%                            PATH.  If you are using multiple roiArrays (FOVs), 
%                            this should be a cell array of cell arrays, 1/FOV.
%   dataFileTrial (optional): list of trial #s for dataFileList.  As above, if
%                             you have mutliple roiArrays, this is a cell array
%                             of vectors.
%
function obj = generateCalciumTimeSeriesArray(roiArray, dataPath, dataWC, ignoreSessionStats, dataFileList, dataFileTrial)
  if (nargin < 3)
	  disp('generateCalciumTimeSeriesArray::must pass ALL 3 variables indicating path, wildcard & ROI array path.');
		help('session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray');
		return;
	end
	if (nargin < 4)
	  ignoreSessionStats = 0; % default is to use session statitsitcs
	end
	if (nargin < 5)
	  dataFileList = {} ;
	end
	if (nargin < 6) 
	  dataFileTrial = {} ;
	end
	if (length(dataFileList) > 0 & length(dataFileTrial) > 0 & length(dataFileTrial) < length(dataFileList))
	  disp('generateCalciumTimeSeriesArray::dataFileTrial must be @ least as long as dataFileList.');
		return;
	end

	% -- celery
	if (~iscell(roiArray)) ; roiArray = {roiArray}; end
	if (~iscell(dataPath)) ; dataPath = {dataPath}; end
	if (~iscell(dataWC)) ; dataWC = {dataWC}; end
	if (length(dataFileList) > 0 && ~iscell(dataFileList{1})) ; dataFileList = {dataFileList}; end
	if (~iscell(dataFileTrial)) ; dataFileTrial = {dataFileTrial}; end

  if (length(dataFileList) == 1 & length(dataFileList{1}) == 0) ; dataFileList = {} ; end
  if (length(dataFileTrial) == 1 & length(dataFileTrial{1}) == 0) ; dataFileTrial = {} ; end

  % -- roiArray
	numFOVs = length(roiArray);

  roiIds = [];
	for f=1:numFOVs
		if (~isobject(roiArray{f})) % load from file?
			rA = load(roiArray{f});
			roiArray{f} = rA.obj;
		end
		roiIds = [roiIds roiArray{f}.roiIds];
	end
	if (length(unique(roiIds)) ~= length(roiIds))
	  disp('generateCalciumTimeSeriesArray::some roiIDs get repeated among roiArray objects passed; this is not allowed.  Aborting.');
		return;
	end

	% -- ensure that we have right # of args 
	if (length(dataPath) > 0 & (length(dataPath) ~= numFOVs))
	  disp('generateCalciumTimeSeriesArray::must specify a dataPath for each field-of-view.');
    disp(' ');
    disp(' ');
		help('session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray');
		return;
	end
	if (length(dataFileList) > 0 & (length(dataFileList) ~= numFOVs))
	  disp('generateCalciumTimeSeriesArray::must specify a dataFileList for each field-of-view.');
    disp(' ');
    disp(' ');
		help('session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray');
		return;
	end
	if (length(dataFileTrial) > 0 & (length(dataFileTrial) ~= numFOVs))
	  disp('generateCalciumTimeSeriesArray::must specify a dataFileTrial for each field-of-view.');
    disp(' ');
    disp(' ');
		help('session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray');
		return;
	end
	if (length(dataWC) ~= length(dataPath))
	  for w=2:length(dataPath) 
		  dataWC{w} = dataWC{1};
		end
	end

	% --- process individual FOVs & gather 'temporary' data
	for f=1:numFOVs
	  if (length(dataFileList) > 0)
			[antiRoiFluoVecTemp{f} fileList{f} fileFrameIdxTemp{f} calciumTimeSeries{f} trialIndicesTemp{f} triggerOffsetTemp{f}] = ...
				processSingleRoiArray(roiArray{f}, dataPath{f}, [], dataFileList{f}, dataFileTrial{f}, ignoreSessionStats);
		else
			[antiRoiFluoVecTemp{f} fileList{f} fileFrameIdxTemp{f} calciumTimeSeries{f} trialIndicesTemp{f} triggerOffsetTemp{f}] = ...
				processSingleRoiArray(roiArray{f}, dataPath{f}, dataWC{f}, [], [], ignoreSessionStats);
	  end
	end

	% --- assemble the data 

	% master time vector
	allTime = [];
	for f=1:numFOVs
	  if (length(calciumTimeSeries{f}) > 0)
			allTime = union(allTime, calciumTimeSeries{f}{1}.time);
		end
  end
	allTime = sort(allTime);

	% new triggerOffset, trialIndices ; roi-fov map
	roiFOVidx = zeros(length(roiIds),1);
  triggerOffset=nan*allTime;
	trialIndices = nan*allTime;
  caTS = {};
	for f=1:numFOVs
	  antiRoiFluoVec{f} = nan*allTime;
		fileFrameIdx{f} = nan*zeros(2,length(allTime));
	  if (length(calciumTimeSeries{f}) > 0)
	    thisTime = calciumTimeSeries{f}{1}.time;
			uidx = find(ismember(allTime,thisTime));

			triggerOffset(uidx) = triggerOffsetTemp{f};
			trialIndices(uidx) = trialIndicesTemp{f};

			% populate antiRoiFluoVec, fileFrameIdx
      antiRoiFluoVec{f}(uidx) = antiRoiFluoVecTemp{f};
      fileFrameIdx{f}(:,uidx) = fileFrameIdxTemp{f};

			% build new calcium time series ... with appropriate time and value vector lengths
			for r=1:length(calciumTimeSeries{f})
			  ri = find(roiIds == roiArray{f}.rois{r}.id);
			  roiFOVidx(ri) = f;
			  value = nan*allTime;
			  value(uidx) = calciumTimeSeries{f}{r}.value;
	    	caTS{length(caTS)+1} = session.timeSeries(allTime, 1, value, roiArray{f}.rois{r}.id, ...
		      ['Ca TS for ' num2str(roiArray{f}.rois{r}.id)], 0, [dataPath{f} filesep dataWC{f}]);
			end
    end
	end

	% --- and build actual objects ...
	obj = session.calciumTimeSeriesArray(caTS, trialIndices, roiArray, 1);
	obj.triggerOffsetForTrialInMS = triggerOffset;
	obj.roiFOVidx = roiFOVidx;
	for f=1:numFOVs
		tmpTS = session.timeSeries(allTime, 1, antiRoiFluoVec{f}, 1,['dF/F anti-ROI FOV ' num2str(f)], 0, 'Generated by generateCalciumTimeSeriesArray');
		obj.antiRoiFluoTS{f} = tmpTS;
		obj.fileList{f} = fileList{f};
		obj.fileFrameIdx{f} = fileFrameIdx{f};
	end

	% sort by time
	obj.sortByTime();


%
% Gathers data for a *single* field-of-view (roiArray object).
%
function [antiRoiFluoVec fileList fileFrameIdx calciumTimeSeries trialIndicesTemp triggerOffsetTemp] = ...
		  processSingleRoiArray(roiArray, dataPath, dataWC, dataFileList, dataFileTrial, ignoreSessionStats);

  % -- build anti-roi
	antiRoiIndices =  roiArray.getAntiRoiIndices(2,5);

	% -- can we reject based on imreg_session_stats?
	if (~ignoreSessionStats & ~isempty(dataPath))
  	if (exist([dataPath filesep 'imreg_session_stats.mat']) == 2)
	    disp('generateCalciumTimeSeriesArray::found imreg_session_stats.mat; will use this to filter files.');
      iss = load([dataPath filesep 'imreg_session_stats.mat']);
			for f=1:length(iss.im_file_data) % populate map of filenames that corresponds to accept vector
			  [directory filename ext] = fileparts_crossplatform(iss.im_file_data(f).fullpath);
			  iss.fileList{f} = [filename ext];
			end
		else
		  ignoreSessionStats = 1;
	    disp('generateCalciumTimeSeriesArray::imreg_session_stats.mat not found -- files will NOT be discarded based on motion/luminance.');
		end
	end

	% -- and load file-by-file
	if (length(dataFileList) > 0)
	  flist = dataFileList;
	else
		flist = dir([dataPath filesep dataWC]);
		if (length(flist) == 0) 
			disp(['generateCalciumTimeSeriesArray:: ' dataPath filesep dataWC ' does not match any files.']);
			return;
		end
	end
	nFrames = 0;
	antiRoiFluoVec = [];
	F = 1;
  lastStartTime = -1;
	for f=1:length(flist)
		% Get file name
		if (length(dataFileList) > 0)
		  fname = flist{f};
		else
			fname = [dataPath filesep flist(f).name];
		end

    % apply rejection criteria -- seems silly to re-fileparts, but if dataFileList, makes sense
		if (~ignoreSessionStats)
			[directory filename ext] = fileparts_crossplatform(fname);
			subname = [filename ext];
		  idx = find(strcmp(subname, iss.fileList));
			if (length(idx) ~= 1) ; disp(['generateCalciumTimeSeriesArray::skipping ' subname '.  No session stats match.']); continue ; end
			if (~iss.accept(idx)) ; disp(['generateCalciumTimeSeriesArray::skipping ' subname '.  Session stats accept is 0.']) ;continue ; end
		end

		% load image
		disp(['generateCalciumTimeSeriesArray::processing ' fname '...']);
		try
  		[im improps] = load_image(fname);
		catch me
			disp(['session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray::imread failure.  Skipping file ' fname '.']);
		  disp(' '); disp('Detailed error message: '); disp(getReport(me, 'extended')); disp(' ');
			continue;
		end
    
    % -- Some additional sanity checks
    if (improps.frameRate <= 0) ; disp(['generateCalciumTimeSeriesArray::skipping ' subname '.  FrameRate is <= 0.']) ;continue ; end
    if (isinf(improps.startTimeMS)) ; disp(['generateCalciumTimeSeriesArray::skipping ' subname '.  Infinite start time.']) ;continue ; end


		P = size(im,1)*size(im,2);
    nFrames = nFrames + size(im,3);

		% -- frame loop
		antiRoiVal = [];
		for i=1:size(im,3)
			% -- loop thru rois
			for r=1:roiArray.length()
				indices = roiArray.rois{r}.indices;

				% populate pre-storage vector
				dataMatTemp(F).roi(r).values(i) = mean(im(indices + (i-1)*P));

			end

			% anti-roi
			antiRoiVal(i) = mean(im(antiRoiIndices + (i-1)*P));
		end
		antiRoiFluoVec = [antiRoiFluoVec antiRoiVal];

    % -- pull out time from scanimage data ... APPLY THE OFFSET so that your 
		%    time is as accurate as possible
		% startTimeMS: time when first frame of file started
		% startTimeOffsetMS: time in MS prior to first frame start that trigger came --
		%  + value means before ; it would be odd, but I guess possible, if trigger came
		%  AFTER frame start, in which case this would be negative
    absoluteStartTime = improps.startTimeMS;
    dtMS = 1000/improps.frameRate; % dt
    
    % If the start times of consecutive files are the same, give error message and 
    %  assume they are contiguous ; use frame count * dtMS + start time as next start 
    %  time (and pray this works!)
    if (lastStartTime > -1 && absoluteStartTime == lastStartTime && F > 1)
      disp('session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray::same start time detected in sequential files; something is wrong with the header.');
      disp('  Will make start time be last file''s last time + frameDt.  This may result in some temporal drift.');
      absoluteStartTime = dataMatTemp(F-1).timeVals(end) + dtMS;
    end
    
    % push to dataMatTemp structure
		dataMatTemp(F).timeVals = absoluteStartTime + (0:size(im,3)-1)*dtMS;
		dataMatTemp(F).triggerOffsetTimes = improps.startOffsetMS;
		dataMatTemp(F).fname = fname;

		% -- for now, trial # = file # - try final underscore if possible
		if (length(dataFileTrial) > 0)
		  trialIdx = dataFileTrial(f);
		else
			underscoreIdx = find(fname == '_');
			dotIdx = find(fname == '.');
			trialIdx = str2num(fname(underscoreIdx(end)+1:dotIdx(end)-1));
			if (length(trialIdx) == 0) ; trialIdx = f ; end
		end
    fileTrialIndex(F) = trialIdx;
		F = F + 1;
    lastStartTime = improps.startTimeMS;
  end

	% -- build trial indices vector -- for now, use file # as in blabla_###.tif where ### is numeric 
	%    if this is not the case just use the file's number in list 
	fi = 1;
	for f=1:length(dataMatTemp)
		L = length(dataMatTemp(f).roi(1).values);
    trialIndicesTemp(fi:fi+L-1) = fileTrialIndex(f);
    timeTemp(fi:fi+L-1) = dataMatTemp(f).timeVals;
    triggerOffsetTemp(fi:fi+L-1) = dataMatTemp(f).triggerOffsetTimes;
		fi = fi + L;
	end

	% -- convert to timeSeries objects -- one per ROI ; also generate  fileList, fileFrameIdx
	for r=1:roiArray.length()
		values = zeros(1,nFrames);
		fileFrameIdx = zeros(2,nFrames);
		fileList = {};
		fi = 1;
		for f=1:length(dataMatTemp)
			L = length(dataMatTemp(f).roi(1).values);

		  % fileList stuff
		  fileList{f} = dataMatTemp(f).fname;
			fileFrameIdx(1,fi:fi+L-1) = f;
			fileFrameIdx(2,fi:fi+L-1) = 1:L;

      % values
      values(fi:fi+L-1) = dataMatTemp(f).roi(r).values;
			fi = fi + L;
		end
		calciumTimeSeries{r} = session.timeSeries(timeTemp, 1, values, roiArray.rois{r}.id, ...
		  ['Ca TS for ' num2str(roiArray.rois{r}.id)], 0, [dataPath filesep dataWC]);
	end

