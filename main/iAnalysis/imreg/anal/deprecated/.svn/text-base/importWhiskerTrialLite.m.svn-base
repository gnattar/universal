%
% SP Feb 2011
%
% Method that allows importing of data from DHO's whiskerTrialLite class into 
%  session.
%
% USAGE
%
%  s.importWhiskerTrialLite(whiskerTrialLiteArray, trialMapping, whiskerTags, barInReachES)
%
%    whiskerTrialLiteArray: the whiskerTrialLiteArray that is to be imported; 
%      can also be the path of the file in which the object is stored.
%    trialMapping: if blank, assumption is that whiskerTrialLiteArray.trialNums
%      provides the mapping.  If passed or implied, it should be the same
%      length as the # of wtla trials, and each entry gives the trialId in session
%      of the wtla.  That is, whiskerTrialLiteArray.trial{x} has the session
%      trialId given in trialMapping(x).  NaN's are ok, and mean the trial is skipped.
%    whiskerTags: cell array of strings naming whiskers.  Mandatory, and must be
%      same size as WTLA's trajectory Id.  Note that the trajectory/whiskerIds 
%      0...n map onto whiskerTags{1} ... whiskerTags{n+1}
%    barInReachES: either the barInReach eventSeries, or time, in ms, when bar
%      is in reach (assumed same for all frames - 2 element vector).  Leave 
%      blank if you're not sure.  If passed, the benefit is that whisker 
%      contacts are detected and populated.  Otherwise, you have no contact
%      data and will have to build barInReachES, then invoke 
%      updateWhiskerDataUsingEntireSesssion.  Time unit is Milliseconds if vector!
%
function obj = importWhiskerTrialLite(obj, whiskerTrialLiteArray, trialMapping, whiskerTags, barInReachES)

  % --- settings
	wvOffsetTimeMs = obj.dataSourceParams.whiskerVideoTimeOffsetInMs; % how many milseconds from trial start to whisker video?
	 
	% --- passed params check
	if (nargin < 4)
		help session.session.importWhiskerTrialLite;
		disp(' ');
		disp('==========================================================================================');
	  disp('importWhiskerTrialLite::must provide first three parameters.');
		return;
	end

	% load from file?
	if (~isobject(whiskerTrialLiteArray))  
	  disp(['importWhiskerTrialLiteArray::Loading ' whiskerTrialLiteArray]); 
		load(whiskerTrialLiteArray) ; 
		whiskerTrialLiteArray = wl;
	end
  wtla = whiskerTrialLiteArray; % for convenience

  % bar in reach specified?
	if (nargin < 5)
	  disp('importWhiskerTrialLite::you did not specify a bar-in-reach times; you will need this to get contacts later.');
	end

  % trialMapping
	if (length(trialMapping) == 0)
	  disp('importWhiskerTrialLite::no trialMapping specified; will simply use whiskerTrialLiteArray.trialNums(t).');
    trialMapping = wtla.trialNums;
	end

	% whisker tag 
	if (~iscell(whiskerTags))
	  disp('importWhiskerTrialLite::whiskerTags must be a *cell* array of string names for whiskers.');
	  return;
	end

	% bar in reach
	birtt = [];
	birTimes = [];
	birTrials = [];
	if (nargin >= 5)
	  if (~isobject(barInReachES))
		  birtt = barInReachES;
			if (length(birtt) ~= 2)
			  disp('importWhiskerTrialLite::barInReachES should be a 2-element vector if it is not an object. FAIL!');
				return;
			end
		end
	end


	% --- loop thru and determine # of whiskers, time points 
	allTrajIds = [];
	ntp = 0; % # of time points
	for t=1:length(wtla.trials)
    % skip if nan
		if (isnan(trialMapping(t))) ; continue ; end

		% ALSO skip if the trial is NOT present in session.trial
		ti = find(obj.trialIds == trialMapping(t));
		if (length(ti) == 0) ; continue ;end

    % grab the trial
	  T = wtla.trials{t};
	  allTrajIds = sort(union(allTrajIds, T.trajectoryIDs));

    % build and measure master time vector
		masterTimeVec = [];
		for w=1:length(T.time)
		  masterTimeVec = union(masterTimeVec, T.time{w});
		end
		ntp = ntp+length(masterTimeVec);
	end
	nW = length(allTrajIds);
	if (length(allTrajIds) < length(whiskerTags))
		nW = length(allTrajIds);
	end

	% make sure # of whiskers matches whiskerTags
	if (length(allTrajIds) ~= length(whiskerTags))
	  disp(['importWhiskerTrialLite::detected ' num2str(length(allTrajIds)) ' unique trajectory IDs ; you only provided ' num2str(length(whiskerTags)) ' whiskerTag.  Rectify this!']);
		return;
	end

	% --- build & populate matrices -- USING TRIAL MAP VECTOR

  % initializes matrices w/ nan
	timevec = nan*zeros(1,ntp);
	trialidxvec = nan*zeros(1,ntp);
	kappas = nan*zeros(nW,ntp);
  deltakappas = nan*zeros(nW,ntp);
	thetas = nan*zeros(nW,ntp);
	dtobarctr = nan*zeros(nW,ntp);

	% second loop over whiskerTRiaLite objects
	i1 = 1;
	for t=1:length(wtla.trials)
    % skip if nan
		if (isnan(trialMapping(t))) ; continue ; end

		% ALSO skip if the trial is NOT present in session.trial
		ti = find(obj.trialIds == trialMapping(t));
		if (length(ti) == 0) ; continue ;end

    % grab the trial
	  T = wtla.trials{t};
	  allTrajIds = sort(union(allTrajIds, T.trajectoryIDs));

    % build master time vector -- everything else will be this long
		masterTimeVec = [];
		for w=1:length(T.time)
		  masterTimeVec = union(masterTimeVec, T.time{w});
		end
		i2 = i1+length(masterTimeVec)-1;

		% align time vector (trialStart + offest in Ms) -- i.e., assign FINAL values
		newtv = masterTimeVec*1000 + obj.trial{ti}.startTime + wvOffsetTimeMs;
		timeVec(i1:i2) = newtv;

    % whisker loop
		basevec = nan*masterTimeVec;
		for w=1:length(T.time)
		  % whisker index inside NEW matrix
			wi = find(allTrajIds == T.trajectoryIDs(w));

      % grab time vector
			tv = T.time{w};

			% unique it
			[irr1 uidx irr2] = unique(tv);
			uidx = intersect(uidx,1:length(masterTimeVec));

			% determine which time points are present both in this AND master time vector
			valid = intersect(uidx,find(ismember(tv, masterTimeVec)));

			% populate matrices
			basevec = nan*basevec;
			basevec(valid) = T.kappa{w}(uidx);
			kappas(wi,i1:i2) = basevec;

			basevec = nan*basevec;
			basevec(valid) = T.deltaKappa{w}(uidx);
			deltakappas(wi,i1:i2) = basevec;

			basevec = nan*basevec;
			basevec(valid) = T.theta{w}(uidx);
			thetas(wi,i1:i2) = basevec;

			basevec = nan*basevec;
			basevec(valid) = T.distanceToPoleCenter{w}(uidx);
			dtobarctr(wi,i1:i2) = basevec;
		end

		% barInReachES is vector? then make it  (in milliseconds)
		if (length(birtt) > 0) 
%		  birIdx(1) = 1000*masterTimeVec(max(find(masterTimeVec*1000 <= birtt(1))));
%		  birIdx(2) = 1000*masterTimeVec(min(find(masterTimeVec*1000 >= birtt(2))));

      birIdx(1) = max(find(masterTimeVec*1000 <= birtt(1)));
      birIdx(2) = min(find(masterTimeVec*1000 >= birtt(2)));

			birTimes = [birTimes newtv(birIdx(1)) newtv(birIdx(2))];
			birTrials = [birTrials trialMapping(t) trialMapping(t)];
		end

		% trial indices
		trialidxvec(i1:i2) = trialMapping(t);

		% index increment
		i1 = i2+1;
	end

	% --- generate timeSeriesArray objects & replace pertinent session objects

  % clear previous
	obj.whiskerCurvatureTSA = [];
 	obj.whiskerCurvatureChangeTSA = [];
	obj.whiskerAngleTSA = [];
 	obj.whiskerDistanceToBarCenterTSA = [];

	% clear contacts
	obj.whiskerBarContactESA = [];
	obj.whiskerBarContactClassifiedESA = [];

	% generate
	obj.whiskerTag = whiskerTags;
	timeUnit = 1; % ms
	for w=1:nW
	  wcTSs{w} = session.timeSeries(timeVec, timeUnit, kappas(w,:), w, ...
		  ['Curvature for ' char(obj.whiskerTag(w))], 0, 'import from whiskerTrialLiteArray.');
	  wccTSs{w} = session.timeSeries(timeVec, timeUnit, deltakappas(w,:), w, ...
		  ['Curvature change for ' char(obj.whiskerTag(w))], 0,  'import from whiskerTrialLiteArray.');
	  waTSs{w} = session.timeSeries(timeVec, timeUnit, thetas(w,:), w, ...
		  ['Angle for ' char(obj.whiskerTag(w))], 0,   'import from whiskerTrialLiteArray.');
	  wdtbTSs{w} = session.timeSeries(timeVec, timeUnit, dtobarctr(w,:), w, ...
		  ['Distance to bar ctr for ' char(obj.whiskerTag(w))], 0, 'import from whiskerTrialLiteArray.');
	end
  obj.whiskerCurvatureTSA = session.timeSeriesArray(wcTSs, trialidxvec);
  obj.whiskerCurvatureChangeTSA = session.timeSeriesArray(wccTSs, trialidxvec);
  obj.whiskerAngleTSA = session.timeSeriesArray(waTSs, trialidxvec);
	obj.whiskerDistanceToBarCenterTSA = session.timeSeriesArray(wdtbTSs, trialidxvec);

	% --- barInReachES
  obj.whiskerBarInReachES = [];
	if (isobject(barInReachES))
	  obj.whiskerBarInReachES = barInReachES;
	elseif (length(barInReachES) == 2) ; % 2 el vector
		obj.whiskerBarInReachES = session.eventSeries(birTimes, birTrials, timeUnit, 1, ...
				['Bar-in-reach times'], 0, '', 'import from whiskerTrialLiteArray.', [0.5 0.5 0.5], 2);
  end
 
	% ---valid whisker trials
	obj.validWhiskerTrialIds = unique(trialidxvec(find(trialidxvec > 0)));

  % --- if bar in reach is populated AND the user has already at some point
  %     called updateWhiskerDataUsingEntire session, do again
  if (length(obj.whiskerBarInReachES) > 0)
		obj.whiskerBarInReachES.generateStartTimeRelTimes(obj.trialStartTimes, obj.trialIds);
    if (obj.stepCompleted(find(strcmp(obj.stepName, 'updateWhiskerDataUsingSession'))))
		  obj.updateWhiskerDataUsingEntireSession();
    end
  end
  
  % --- finito!
	obj.stepCompleted(find(strcmp(obj.stepName, 'generateWhiskerData'))) = 1;


