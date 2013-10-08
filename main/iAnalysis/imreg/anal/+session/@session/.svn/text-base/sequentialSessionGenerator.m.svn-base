%
% SP Feb 2011
%
% This uses stepCompleted and dataSourceParams to generate // continue generation
%  of a session.  It is called by sessionGenerate, and can be used thereafter if
%  you want to rerun a step (set its stepCompleted to 0) or to recover an 
%  interrupted session generation episode.
%
% USAGE:
%
%  s.sequentialSessionGenerator(forceRedo)
%
%    forceRedo: if set to 1, this is equivalent to setting all stepCompleted 
%      flags to 0.  To force redo if a SINGLE step, set its stepCompleted flag to 0.
%
function obj = sequentialSessionGenerator(obj, forceRedo)

  %% --- inputs?
	if (nargin >= 2)
	  if (forceRedo) 
		  obj.stepCompleted = zeros(1,length(session.session.stepName));
		end
	end

  %% --- pull stuff from dataSourceParams
	behavSoloFilePath = obj.dataSourceParams.behavSoloFilePath;
	ephusFilePath = obj.dataSourceParams.ephusFilePath;
  ephusFileWC = obj.dataSourceParams.ephusFileWC;
  ephusChanIdent = obj.dataSourceParams.ephusChanIdent;
  ephusDownsample = obj.dataSourceParams.ephusDownsample;

	%% --- in case you are re-calling this and something broke validTrialIds
	if (~isempty(obj.validBehavTrialIds))
	  obj.validTrialIds = obj.validBehavTrialIds;
		if (~isempty(obj.validCaTrialIds)) ; obj.validTrialIds = intersect(obj.validCaTrialIds, obj.validTrialIds); end
		if (~isempty(obj.validWhiskerTrialIds)) ; obj.validTrialIds = intersect(obj.validWhiskerTrialIds, obj.validTrialIds); end
		if (~isempty(obj.validEphusTrialIds)) ; obj.validTrialIds = intersect(obj.validEphusTrialIds, obj.validTrialIds); end
		if (~isempty(obj.validDerivedTrialIds)) ; obj.validTrialIds = intersect(obj.validDerivedTrialIds, obj.validTrialIds); end
	end


  %% ===========================================================================
	% behav data - this must work, at this point, to get a valid session object.
	%              Since trial info is stored here, it makes no sense to have 
	%              object without this data.  Of course, one could design a blank
	%              'behavior' object with only trial info ... 
	if ( obj.stepCompleted(find(strcmp(obj.stepName, 'generateBaseData'))) == 0)

		% get trials, behavESA from solo
		obj.generateBehavioralDataStructures(behavSoloFilePath, obj.dataSourceParams.behavSoloParams, ...
		   obj.dataSourceParams.trialBehavParams);

		% at this point we do first pass restriction on validTrialIds
		validBehavTrials = [];
		for t=1:length(obj.trial)
			if (obj.trial{t}.id > -1)
				validBehavTrials = [validBehavTrials obj.trial{t}.id];
			end
		end
		obj.validTrialIds = validBehavTrials;

		% --- save this step
		obj.stepCompleted(find(strcmp(obj.stepName, 'generateBaseData'))) = 1;
		obj.saveToFile();
	end
	
  %% ===========================================================================
  % --- from here on, steps are "optional" -- failure will just set a flag, but 
	%     object is still generated.  A series of try-catch statements, nested.

  %% --- ephus data
	if ( obj.stepCompleted(find(strcmp(obj.stepName, 'generateEphusData'))) == 0)
		try
			% get ephusTSA appropriately downsampled ; this also gets bitcodes, thereby
			%  aligning ephus with behavior.  Timestamps in ephus are changed to match
			%  behavior.
			disp(['sequentialSessionGeneratior::generating data from ' ephusFilePath filesep ephusFileWC]);
			obj.generateEphusTimeSeriesArray(ephusFilePath, ephusFileWC, ephusDownsample);

			% at this point we do first pass restriction on validTrialIds
			validEphusTrials = unique(obj.ephusTSA.trialIndices);
			obj.validTrialIds = intersect(obj.validTrialIds, validEphusTrials);

			obj.stepCompleted(find(strcmp(obj.stepName, 'generateEphusData'))) = 1;
			obj.saveToFile();
		catch me
			disp(['sequentialSessionGeneratior::' obj.mouseId ' ' obj.dateStr ' - generateEphusTimeSeriesArray failed.']);
		  disp(' '); disp('Detailed error message: '); disp(getReport(me, 'extended')); disp(' ');
		end
	end

	%% --- calcium data
	if ( obj.stepCompleted(find(strcmp(obj.stepName, 'generateCalciumData'))) == 0)
		try
			% get caTSA object -- note this contains the roiArray
			obj.generateCalciumTimeSeriesArray();
			obj.saveToFile();

			% dff & ca event detection
			% this was postponed in generateCalciumTimeSeriesArray so that events could be 
			%  appropriately assigned to trials based on alignment w/ ephus

			% multiple ca arrays?
			if (isstruct(obj.caTSAArray))
			  for ci=1:length(obj.caTSAArray.caTSA)
				  rbpParams.trialTimes = obj.behavESA.trialTimes;
					obj.caTSAArray.caTSA{ci}.runBestPracticesDffAndEvdet(rbpParams);
			  end
				obj.caTSA = obj.caTSAArray.caTSA{1};
			else % single caTSA
				rbpParams.trialTimes = obj.behavESA.trialTimes;
				obj.caTSA.runBestPracticesDffAndEvdet(rbpParams);
			end
		 
			obj.validTrialIds = intersect(intersect(obj.validCaTrialIds,  obj.validBehavTrialIds), ...
																			obj.validEphusTrialIds);
			obj.stepCompleted(find(strcmp(obj.stepName, 'generateCalciumData'))) = 1;
			obj.saveToFile();
		catch me
			disp(['sequentialSessionGeneratior::' obj.mouseId ' ' obj.dateStr ' - generateCalciumTimeSeriesArray failed.']);
		  disp(' '); disp('Detailed error message: '); disp(getReport(me, 'extended')); disp(' ');
		end
	end

	%% --- whisker data; collation with ephus and all else done here
	if ( obj.stepCompleted(find(strcmp(obj.stepName, 'generateWhiskerData'))) == 0)
		try
  		obj.generateWhiskerDataStructures();
      if (length(obj.validWhiskerTrialIds) > 0)
			  obj.validTrialIds = intersect(obj.validTrialIds, obj.validWhiskerTrialIds);
  			obj.stepCompleted(find(strcmp(obj.stepName, 'generateWhiskerData'))) = 1;
    		obj.saveToFile();
	    end
		catch me
			disp(['sequentialSessionGeneratior::' obj.mouseId ' ' obj.dateStr ' - generateWhiskerDataStructure failed.']);
		  disp(' '); disp('Detailed error message: '); disp(getReport(me, 'extended')); disp(' ');
		end
	end

	%% --- generate derived data structures -- stuff used for meta-analysis
	if ( obj.stepCompleted(find(strcmp(obj.stepName, 'generateDerivedData'))) == 0)
		try
      obj.generateDerivedDataStructures();
      obj.stepCompleted(find(strcmp(obj.stepName, 'generateDerivedData'))) = 1;
      obj.validTrialIds = intersect(obj.validTrialIds, obj.validDerivedTrialIds);
      obj.saveToFile();
		catch me
			disp(['sequentialSessionGeneratior::' obj.mouseId ' ' obj.dateStr ' - generateDerivedDataStructures failed.']);
		  disp(' '); disp('Detailed error message: '); disp(getReport(me, 'extended')); disp(' ');
		end
	end
