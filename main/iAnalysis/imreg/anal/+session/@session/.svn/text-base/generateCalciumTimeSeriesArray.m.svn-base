%
% SP 2010 Aug
%
% Generates calciumTimeSeries array object, populating s.caTSA, s.caTSAArray.
%
% USAGE:
%
%   s.generateCalciumTimeSeriesArray(regenIdx)
%
% ARGUMENTS:
%
%  regenIdx: Optional ; if you want to regenerate just a subset of the 
%            caTSAArray members (obviously applies only if there are multiple)
%            pass the indices and only these will be redone.
%
% PARAMETERS FROM s.dataSourceParams:
%
%   scimFilePath: Where the scanimage files reside
%   scimFileWC: The wildcard in the directory to force match files to (*main*tif by default)
%   roiArrayPath: location of the roi file
%   scimFileList: cell array of file names if you want to EXPLICITLY list files; FULL PATH!
%   scimFileTrial: trial # vector for each of above cell array members.
%
function obj = generateCalciumTimeSeriesArray(obj, regenIdx)

  %% --- call calciumTimeSeriesArrag.generateCalciumTimeSeriesArray

	% multiple calls for multiple entries (pay attention to regenIdx)
	if (iscell(obj.dataSourceParams.roiArrayPath) && iscell(obj.dataSourceParams.scimFilePath) && ...
	    iscell(obj.dataSourceParams.roiArrayPath{1}) && iscell(obj.dataSourceParams.scimFilePath{1}))
   
	  oCaTSA = {};
	  oValidCaTrialIds = {};
	  if (nargin > 1) % regenIdx
		  noChangeIdx = setdiff(1:length(obj.caTSAArray.caTSA), regenIdx);
		  for v=noChangeIdx
			  oCaTSA{v} = obj.caTSAArray.caTSA{v};
			  oValidCaTrialIds{v} = obj.caTSAArray.validCaTrialIds{v};
			end
		end

		caTSAArrayIdx = [];
		fullTrialIndices = [];
		fullTime = [];
    
    % clear previous
    obj.caTSAArray.caTSA = {}; 
    obj.caTSAArray.validCaTrialIds = {}; 

		for v=1:length(obj.dataSourceParams.roiArrayPath)
      baseFileNameTag = sprintf('_%02d', v);

      if (length(oCaTSA) > 0 && isobject(oCaTSA{v})) % just insert extant stuff

				% after isntantiating a single one, pop it into the array and blank it
				obj.caTSAArray.caTSA{v} = oCaTSA{v};
				obj.caTSAArray.validCaTrialIds{v} = oValidCaTrialIds{v};

			else % do it
				% often this will be same so just string, but in case it is specified per vol
				if (iscell(obj.dataSourceParams.scimFileWC)) 
					generateSingleCalciumTimeSeriesArray(obj, obj.dataSourceParams.roiArrayPath{v}, ...
						obj.dataSourceParams.scimFilePath{v}, obj.dataSourceParams.scimFileWC{v}, ...
						obj.dataSourceParams.scimIgnoreSessionStats, baseFileNameTag);
				else
					generateSingleCalciumTimeSeriesArray(obj, obj.dataSourceParams.roiArrayPath{v}, ...
						obj.dataSourceParams.scimFilePath{v}, obj.dataSourceParams.scimFileWC, ...
						obj.dataSourceParams.scimIgnoreSessionStats, baseFileNameTag);
				end

				% after isntantiating a single one, pop it into the array and blank it
				obj.caTSAArray.caTSA{v} = obj.caTSA;
				obj.caTSAArray.validCaTrialIds{v} = obj.validCaTrialIds;
				obj.caTSA = [];
			end

			fullTime = [fullTime obj.caTSAArray.caTSA{v}.time];
			fullTrialIndices = [fullTrialIndices obj.caTSAArray.caTSA{v}.trialIndices];
			caTSAArrayIdx = [caTSAArrayIdx (0*obj.caTSAArray.caTSA{v}.time + v)];
		end

		% align the FULL time-value vector -- this ensures proper alignment because 
		%  short vectors sometimes fail due to multiple correct alignments
		tCaTSA = session.calciumTimeSeriesArray();
		tCaTSA.time = fullTime;
		tCaTSA.trialIndices = fullTrialIndices;
		obj.caTSA = tCaTSA;
    alignSingleCalciumTimeSeriesArray(obj);

		for c=1:length(obj.caTSAArray.caTSA)
			% now assign the *individual* caTSA's their new time and trialIndices from 
			%  alignment
			cidx = find(caTSAArrayIdx == c);
			obj.caTSAArray.caTSA{c}.time = obj.caTSA.time(cidx);
			obj.caTSAArray.caTSA{c}.trialIndices = obj.caTSA.trialIndices(cidx);

		  uct = unique(obj.caTSAArray.caTSA{c}.trialIndices);
			val = find(~isnan(uct) & ~isinf(uct));
			obj.caTSAArray.validCaTrialIds{c} = sort(uct(val));

			% and finally clean up individual caTSAs
			postAlignCleanupSingleCalciumTimeSeriesArray(obj, obj.caTSAArray.caTSA{c});
		end

		% load first caTSAArray into caTSA
		obj.caTSAArray.curIdx = 0;
		obj.useCaTSAArray(1);
	else % single call
    generateSingleCalciumTimeSeriesArray(obj, obj.dataSourceParams.roiArrayPath, ...
		  obj.dataSourceParams.scimFilePath, obj.dataSourceParams.scimFileWC, '', ...
			obj.dataSourceParams.scimIgnoreSessionStats);
    alignSingleCalciumTimeSeriesArray(obj);
    postAlignCleanupSingleCalciumTimeSeriesArray(obj, obj.caTSA);
	end


%
% wrapper for single-caTSA generation
%
function generateSingleCalciumTimeSeriesArray(obj, roiArrayPath, scimFilePath, scimFileWC, ignoreSessionStats, baseFileNameTag)
	  
	obj.caTSA = session.calciumTimeSeriesArray.generateCalciumTimeSeriesArray( ...
	  roiArrayPath, scimFilePath, scimFileWC, ...
		ignoreSessionStats, obj.dataSourceParams.scimFileList, obj.dataSourceParams.scimFileTrial);

	% give the file name
	[dname fname] = fileparts(obj.baseFileName);
	obj.caTSA.baseFileName = [dname filesep fname '.caTSA' baseFileNameTag '.mat'];

%
% wrapper for single-caTSA alignment 
%
function alignSingleCalciumTimeSeriesArray(obj)

	%% --- collate ephus-scim -- iff no dataFileTrial
	if (length(obj.dataSourceParams.scimFileTrial) == 0)
		obj.alignScanimageWithEphus();
	else % we must explicitly set validCaTrials
		uct = unique(obj.caTSA.trialIndices);
		val = find(~isnan(uct) & ~isinf(uct));
		obj.validCaTrialIds = sort(uct(val));
	end

%
% cleanup post-alignment
%
function postAlignCleanupSingleCalciumTimeSeriesArray(obj, caTSA)

  %% --- update times to trial start times ...
	uct = unique(caTSA.trialIndices);
	uct = uct(find(~isnan(uct)));
	for t=1:length(uct)
    updatedVals = find(caTSA.trialIndices == uct(t));

		% update time vector
		if (~isempty(updatedVals))
			startTime = obj.trialStartTimes(find(obj.trialIds == uct(t)));
			startTimeOffset = caTSA.triggerOffsetForTrialInMS(updatedVals(1));
			tvec = caTSA.time(updatedVals);
			tvec = (tvec - min(tvec)) + startTime + startTimeOffset;
			caTSA.time(updatedVals) = tvec;
		end
	end

	%% --- final housekeeping on caTSA
	% remove nan trials from caTSA
	caTSA.stripNanTrials();

	% sort by time
	caTSA.sortByTime();

