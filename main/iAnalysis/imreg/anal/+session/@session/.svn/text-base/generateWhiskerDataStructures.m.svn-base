%
% SPeron Aug 2010
%
% Will populate calling object's whisker data structures.  Uses session.whiskerTrialArray.
%
% USAGE:
%   s.generateWhiskerDataStructures()
%
%   s.dataSourceParams used:		
%
%     whiskerFilePath: directories whisker tracking .mat files reside
%     whiskerFileWC: wildcard to apply therewithin ; if you are importing a 
%                    whiskerTrialLiteArray, this should be the filename of that file
%     whiskerTrialIncrement: How much to add to whisker file trial # to make it
%                            line up with ephus?  ALL TRIAL NUMBERS ARE BASED ON
%                            FILENAME ONLY.  THIS IS NOT VERY SMART!
%     whiskerTrialArrayBaseFileName: Where to store the whiskerTrialArray Object?
%     whiskerTrialArrayParams: see session.whiskerTrialArray.params -- this is
%                              that structure!
% 
function obj = generateWhiskerDataStructures(obj)

  % --- parameters
	maximalScore = [0.025 .05]; % scores above this imply too much error -- REJECT (2.5% of frames - ~100)

	% from dataSourceParams
	wvOffsetTimeMs = obj.dataSourceParams.whiskerVideoTimeOffsetInMs; % how many milseconds from trial start to whisker video?

  % - for ease, pull from dataSourceParams
	wfPath = obj.dataSourceParams.whiskerFilePath;
	wfWC = obj.dataSourceParams.whiskerFileWC;

  % - sanity check -- is whiskerFilePath even valid
	if (~ exist(wfPath, 'dir'))
	  disp(['generateWhiskerDataStructure:: ' wfPath ' is not a valid directory.']);
	end
	if (length(obj.trial) < 1)
	  disp('generateWhiskerDataStructure::must first populate trial array.');
	  return;
	end

  % --- and now begin ...

  %% --------------------------------------------------------------------------
	% 0) clear previous // setup cells for times
 	obj.whiskerCurvatureTSA = [];
 	obj.whiskerCurvatureChangeTSA = [];
	obj.whiskerAngleTSA = [];
	obj.whiskerBarContactESA = [];
	obj.whiskerBarContactClassifiedESA = [];
  obj.whiskerBarCenterXYTSA = [];
	obj.whiskerBarInReachES = [];


  %% --------------------------------------------------------------------------
  % 1) run whiskerTrialArray.generateUsingParams
	whiskerTrialArrayParams = [];
	if (isstruct(obj.dataSourceParams.whiskerTrialArrayParams))
	  whiskerTrialArrayParams = obj.dataSourceParams.whiskerTrialArrayParams;
	end
	whiskerTrialArrayParams.whiskerFilePath = obj.dataSourceParams.whiskerFilePath;
	whiskerTrialArrayParams.whiskerFileWC = obj.dataSourceParams.whiskerFileWC;
	whiskerTrialArrayParams.ephusPath = obj.dataSourceParams.ephusFilePath;
	whiskerTrialArrayParams.ephusWC = obj.dataSourceParams.ephusFileWC;
	whiskerTrialArrayParams.baseFileName = obj.dataSourceParams.whiskerTrialArrayBaseFileName;

	wta = session.whiskerTrialArray.generateUsingParams(whiskerTrialArrayParams);

  %% --------------------------------------------------------------------------
  % 2) determine ephus-whisker file map and update whiskerTrialArray data using
	%    new trial #s so it is aligned with session
  
  % ephus file # is implicit in the filename -- the last 4 digits of the file
  %  are treated as trial number, and extension xsg is assumed.  For whisker
  %  data, it is assumed that trial # is already present in whiskreTrialArray
  %  presumably also derived from file name, though that is not decided here
  %  and if changes are made in whiskerTrialArray, that will impact this method.
  %  Whisker trial #s are derived from whiskerTrialArray.trialIndices.

  efl = dir([obj.dataSourceParams.ephusFilePath filesep obj.dataSourceParams.ephusFileWC]);
	
	enum = zeros(1,length(efl));
	for e=1:length(efl)
	  dotXsgIdx = strfind(efl(e).name, '.xsg');
    enum(e) = str2num(efl(e).name(dotXsgIdx-4:dotXsgIdx-1));
	end
	
	wnum = zeros(1,wta.numTrials);
	for t=1:wta.numTrials
	  [irr whName] = fileparts(wta.wtArray{t}.matFilePath);
		undIdx = find(whName == '_');
    wnum(t) = str2num(whName(undIdx(end-1)+1:undIdx(end)-1));
	end
	
  % apply whiskerTrialIncrement to whisker trial # and line up to ephus; report 
	%  how many missing
	wta.trialIndices = wta.trialIndices + obj.dataSourceParams.whiskerTrialIncrement;

	% loop first time over whisker trials, and delete any whisker trials that
	%  do NOT have a corresponding ephus trial or where bit code is nan
  deleteTrials = [];
	for t=1:wta.numTrials
    ei = find(enum == wnum(t));
    idx = find(wta.fileIndices == t);
    wtn = wta.trialIndices(idx(1));

		if (length(ei) == 0) % no match? delete from wta
      deleteTrials = union(deleteTrials,wtn);
    else
      % ephus bitcode bad?
      oti = find(obj.trialIds == obj.ephusOriginalTrialBitcodes(ei));
      if (length(oti) == 0)
        deleteTrials = union(deleteTrials,wtn);
      end
    end
  end
  for d=1:length(deleteTrials)
    wta.deleteTrial(deleteTrials(d));
    disp(['generateWhiskerDataStructures::deleting whisker trial ' num2str(deleteTrials(d))]);
  end

	% loop over whisker trials again, building a new time and trial vector
	newTrialIndices = 0*wta.fileIndices;
	newTime = 0*wta.time;
	wnum = zeros(1,wta.numTrials);
	for t=1:wta.numTrials
	  [irr whName] = fileparts(wta.wtArray{t}.matFilePath);
		undIdx = find(whName == '_');
    wnum(t) = str2num(whName(undIdx(end-1)+1:undIdx(end)-1));
  end
	for t=1:wta.numTrials
    ei = find(enum == wnum(t));
    idx = find(wta.fileIndices == t);
    
		% use ephusOriginalTrialBitcodes to get trial # in session object
		oti = find(obj.trialIds == obj.ephusOriginalTrialBitcodes(ei));
		trialNum = obj.trialIds(oti);

	  % pull start time of that trial, and add wvOffsetTimeMs -- you now have the
	  %  start time. 
		startTimeMs = obj.trialStartTimes(oti) + wvOffsetTimeMs;

		% build time and trial vector
		dtVec = wta.time(idx) - wta.time(min(idx)); % zero'd
		newTime(idx) = startTimeMs + dtVec;
		newTrialIndices(idx) = trialNum;

% CONVERT TIME UNITS?
  end

	% Go ahead and 'push' session trial, time scheme onto whiskerTrialArray
	wta.trialIndices = newTrialIndices;
	wta.time = newTime;

	% update events by pushing trialTimes from behavESA
  wta.trialTimes = obj.behavESA.trialTimes;

  %% --------------------------------------------------------------------------
  % 3) pull data from whiskerTrialArray and populate the session object

  obj.whiskerTag = wta.whiskerTags;

  % TSAs and ESAs
	obj.whiskerAngleTSA = wta.whiskerAngleTSA;
 	obj.whiskerCurvatureTSA = wta.whiskerCurvatureTSA;
 	obj.whiskerCurvatureChangeTSA = wta.whiskerCurvatureChangeTSA;

	obj.whiskerBarContactESA = wta.whiskerBarContactESA; 
	obj.whiskerBarContactClassifiedESA = wta.whiskerBarContactClassifiedESA;

  obj.whiskerBarCenterXYTSA = wta.barCenterTSA;
	obj.whiskerBarInReachES = wta.whiskerBarInReachES;

	% valid trials
	obj.validWhiskerTrialIds = unique(wta.trialIndices);
