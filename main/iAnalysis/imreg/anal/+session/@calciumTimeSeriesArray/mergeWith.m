%
% Merge with another calciumTimeSeriesArray.
%
% USAGE:
%
%   caTSA.mergeWith(nCaTSA)
%
% ARGUMENTS:
%
%   nCaTSA: the object to merge to this one (typically, obj should be the 
%           'master' object and you can iteratively add nCaTSA)
%
% (C) 2012 July S Peron
%
function obj = mergeWith(obj, nObj)

	%% --- sanity checks 

	% reject criteria
	if (obj.timeUnit ~= nObj.timeUnit)
		error('calciumTimeSeriesArray.mergeWith::must be same timeUnit to merge.');
	end

  %% --- preprocessing

  % determine FOVs present (assumption is UNIQUE roi ids)
	FOVmap = zeros(1,nObj.numFOVs); % nObj.roiArray{f} maps to obj.roiArray{FOVMap(f)}
	missingFOVs = [];
  for nf=1:nObj.numFOVs
	  nRoiIds = nObj.roiArray{nf}.roiIds;
		for of=1:obj.numFOVs
			oRoiIds = obj.roiArray{of}.roiIds;
			if (length(find(ismember(nRoiIds,oRoiIds))) == length(nRoiIds))
			  FOVmap(nf) = of;
				break;
			end
    end
  end
  missingFOVs = setdiff(1:obj.numFOVs, FOVmap);
	newFOVs = find(FOVmap == 0);
  
  % for now . . . but later fix this:
	%  1) caTSA.numFOVs++ ...
	if (length(newFOVs) > 0) ; error('calciumTimeSeriesArray.mergeWith::cannot handle novel FOVs'); end

  % you will also need the valueMatrix map (i.e., id to id map)
  idMap = zeros(1,nObj.length);
  for ni=1:nObj.length
    oi = find(obj.ids == nObj.ids(ni));
    idMap(ni) = oi;
  end
  

  %% --- main 
	% you may proceed - only need trialIndices, time, valueMatrix ; base off time
	[irr keptIdx] = setdiff(nObj.time, obj.time);

	% FOV-based variables
  for f=1:length(FOVmap)
   	% antiRoi TSs
		obj.antiRoiFluoTS{FOVmap(f)}.value = [obj.antiRoiFluoTS{FOVmap(f)}.value nObj.antiRoiFluoTS{f}.value(keptIdx)];
		obj.antiRoiDffTS{FOVmap(f)}.value = [obj.antiRoiDffTS{FOVmap(f)}.value nObj.antiRoiDffTS{f}.value(keptIdx)];

		% fileList, fileFrameIdx
		nofl = length(obj.fileList{FOVmap(f)});
		obj.fileList{FOVmap(f)} = [obj.fileList{FOVmap(f)} nObj.fileList{f}];
		tfidx = nObj.fileFrameIdx{f};
		tfidx(1,:) = tfidx(1,:) + nofl;
		obj.fileFrameIdx{FOVmap(f)} = [obj.fileFrameIdx{FOVmap(f)} nObj.fileFrameIdx{f}(:,keptIdx)];
  end
  % missing? populate with blanX (nans)
  nanVec = nan*zeros(1,length(keptIdx));
  for f=missingFOVs
  	% antiRoi TSs
		obj.antiRoiFluoTS{f}.value = [obj.antiRoiFluoTS{f}.value nanVec];
		obj.antiRoiDffTS{f}.value = [obj.antiRoiDffTS{f}.value nanVec];

		% fileList, fileFrameIdx
		nofl = length(obj.fileList{f});
		obj.fileList{f} = [obj.fileList{f} 'NODATA'];
		obj.fileFrameIdx{f} = [obj.fileFrameIdx{f} nofl+1+zeros(2,length(keptIdx))];
  end
  
  % now do sub-TSAs
	obj.dffTimeSeriesArray.mergeWith(nObj.dffTimeSeriesArray);
	obj.caPeakTimeSeriesArray.mergeWith(nObj.caPeakTimeSeriesArray);
	obj.caPeakEventSeriesArray.mergeWith(nObj.caPeakEventSeriesArray);
	obj.eventBasedDffTimeSeriesArray.mergeWith(nObj.eventBasedDffTimeSeriesArray);

	% now do time, trialIndices
	obj.time = [obj.time nObj.time(keptIdx)];
	obj.trialIndices = [obj.trialIndices nObj.trialIndices(keptIdx)];
	obj.triggerOffsetForTrialInMS = [obj.triggerOffsetForTrialInMS nObj.triggerOffsetForTrialInMS(keptIdx)];
  
  % for valueMatrix, we first fill with nans then populate 
	i1 = size(obj.valueMatrix,2)+1;
	i2 = length(keptIdx) + i1 - 1;
  obj.valueMatrix(:,i1:i2) = nan*zeros(obj.length, length(keptIdx));
	obj.valueMatrix(idMap,i1:i2) = nObj.valueMatrix(:,keptIdx);

	obj.sortByTime(); % let him do the dirty work!

end

