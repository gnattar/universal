%
% SPeron Aug 2010
%
% Will populate calling object's solo-pertinent data structures - namely,
%   session.session.trial and session.session.behavESA.
%
%   This assumes you are using Solo, and makes some critical assumptions.  For 
%   one, you need a field saved_history.RewardsSection_LastTrialEvents, which
%   stores a bunch of eventIds.  Event 40 is always trial start.
%
%   Protocol name is inferred from saved.XXX_prot_title.  That is, whatever your
%   solo file is, it loads it, and from its field saved.XXX_prot_title, XXX
%   is assumed to be protocol name.  This is then used to set the parent
%   session object's trialType, trialTypeStr, and trialTypeColor variables.
%
% PARAMS:
%
%   soloFilePath: The solo 'log' file that is used.
%   behavSoloParams: Which state matrix parameters to get? Cell array of cells,
%                    where behavSoloParams{x}{1} is mode, {x}{2} is code,
%                    {x}{3} is id string, {x}{4} is color, and {x}{5} is type.
%
%                    mode 1: use lastTrialEvents column 2, and match any time
%                            it equals code
%                    mode 2: use lastTrialEvents column 1 equal to code, and
%                            column 2 equal to 0 or 3 as start/end
%                    mode 3: use lastTrialEvents column 1 equal to either of
%                            the two code values for start/end, with 
%                            column 2 equal to 0 for both
%                    mode 4: use lastTrialEvents column 1 equal to either of
%                            the first code values for start and the first 
%                            exisiting of the following codes for end, with 
%                            column 2 equal to 0 for both
%
%                    type: 1: individual events (mode 1 usually)
%                          2: events with start/end (mode 2,3 usually) 
%  trialBehavParams: What to store in the trial.behavParams hash object.  Pass 
%               two cell arrays of equal length.  First cell array is string 
%               that is eval'ed, while second string is name of hash object.
%               So you can have something like behavParams{1}{1}
%               'saved_history.ValvesSection_LWaterValveTime' and 
%               behavParams{2}{1} be 'LeftWaterValveTime'.  Then, when you
%               do s.trials{x}.behavParams.get('LeftWaterValveTime'), you would
%               get saved_history. ValvesSection_LWaterValveTime.
%               As you can see, this is a CELL ARRAY of CELL ARRAYs of STRINGS.
%  trialTypeParams: Allows you to define trial typing: trialType 
%                   (session.session.trialType) ; trialTypeStr
%                   (session.session.trialTypeStr) and trialTypeColor, all of 
%                   which are fields of this structure (note that if any of the
%                   3 trialType variables is present, all must be).  Also, you
%                   can pass a field trialTypingFunc, which is the *name* of 
%                   a function that should take the loaded solo .mat file
%                   as a parameter and return trialType.  Must be in your path.
%                   Specifically, eval([trialTypingFunc '(soloDat,t);']) is 
%                   called and this should return the trial type # of trial t 
%                   where soloDat = load(soloFilePath).
%
% RETURNS:
% 
%   nothing; populates calling object
%
% FORMAT: 
%
%   s.generateBehavioralDataStructures(soloFilePath, behavSoloParams, trialBehavParams, trialTypeParams)
% 
function obj = generateBehavioralDataStructures(obj, soloFilePath, behavSoloParams, trialBehavParams, trialTypeParams)
  %% --- args?
	if (nargin < 4 && ~isstruct(obj.dataSourceParams))
	  help('session.session.generateBehavioralDataStructures');
		return;
	elseif (nargin < 4)
	  soloFilePath = obj.dataSourceParams.behavSoloFilePath;
	  behavSoloParams = obj.dataSourceParams.behavSoloParams;
	  trialBehavParams = obj.dataSourceParams.trialBehavParams;
	end

	if (nargin < 5)
	  if (isfield(obj.dataSourceParams, 'trialTypeParams')) 
		  trialTypeParams = obj.dataSourceParams.trialTypeParams;
		else
		  disp(['generateBehavioralStructures::trialTypeParams not defined ; will infer from protocol.']);
			trialTypeParams = [];
		end
  end
  
  %% --- recursive calls?
  if (iscell(soloFilePath))
    obj.generateBehavioralDataStructures(soloFilePath{1},  behavSoloParams, trialBehavParams, trialTypeParams);
    obj.dataSourceParams.soloSourceFileIdx = ones(1,length(obj.trialIds));
    for e=1:length(obj.behavESA)
      obj.dataSourceParams.behavESASoloSourceFileIdx{e} = ones(1,length(obj.behavESA.esa{e}));
    end
    
    % loop and tack on the rest
	  for s=2:length(soloFilePath)
		  tSess = session.session();
      tSess.generateBehavioralDataStructures(soloFilePath{s},  behavSoloParams, trialBehavParams, trialTypeParams);
      temporalOffsetInMs = 1000*60*60 + max(obj.trialStartTimes); % 1 hour beyond last trial START

      % first build a new trial cell array
      nIdx = length(obj.trialIds)+(1:length(tSess.trialIds));
      trialIdOffs = max(obj.trialIds);
      ttrial = tSess.trial;
      additionalTrialIds = zeros(1,length(ttrial));
      for t=1:length(ttrial)
        ttrial{t}.id = ttrial{t}.id+trialIdOffs;
        ttrial{t}.startTime = ttrial{t}.startTime + temporalOffsetInMs;
        ttrial{t}.endTime = ttrial{t}.endTime + temporalOffsetInMs;
        additionalTrialIds(t) = ttrial{t}.id;
      end
      
      % now append relevant things
      obj.trialIds = [obj.trialIds additionalTrialIds];
      obj.trial(nIdx) = ttrial;
      obj.validBehavTrialIds = union(obj.validBehavTrialIds, additionalTrialIds);

      % time stuff -- offset by 1 hour 
      obj.trialStartTimes = [obj.trialStartTimes tSess.trialStartTimes+temporalOffsetInMs];
      for e=1:length(obj.behavESA)
        obj.dataSourceParams.behavESASoloSourceFileIdx{e} = ...
          [obj.dataSourceParams.behavESASoloSourceFileIdx{e} s*ones(1,length(tSess.behavESA.esa{e}))];
        
        obj.behavESA.esa{e}.eventTimes = ...
          [obj.behavESA.esa{e}.eventTimes tSess.behavESA.esa{e}.eventTimes+temporalOffsetInMs];
      end
      
      % and so that ephus handler can process tihs
      obj.dataSourceParams.soloSourceFileIdx(nIdx) = s;
    end
    
    % rebuild trialTimes
		trialTimes = zeros(length(obj.trial),3);
		for t=1:length(obj.trial)
			trialTimes(t,:) = [t obj.trial{t}.startTime obj.trial{t}.endTime];
    end
    obj.behavESA.trialTimes = trialTimes;
   
	else

    %% - sanity checks -- is soloFilePath even valid
    if (~ exist(soloFilePath, 'file'))
      disp(['generateBehavioralDataStructure:: ' soloFilePath ' is not valid.']);
      return;
    end

    % trialBehavParams proper?
    if (length(trialBehavParams) > 0)
      if (length(trialBehavParams) ~= 2 || length(trialBehavParams{1}) ~= length(trialBehavParams{2}))
        disp('generateBehavioralDataStructures::improper trialBehavParams variable.  Both cells must be equal length.');
      end
    end

  
		%% --- and now begin ...

		% ---------------------------------------------------------------------------
		% 0) clear previous // setup cells for times
		obj.trial = {};
		obj.behavESA = '';

		% ---------------------------------------------------------------------------
		% 1) basics
		disp(['generateBehavioralDataStructure:: opening ' soloFilePath]);
		soloDat = load(soloFilePath);
		nTrials = min(length(soloDat.saved_history.SavingSection_MouseName));
		disp(['generateBehavioralDataStructure::found ' num2str(nTrials) ' trials.']);

		% mouse name, date
		obj.mouseId = soloDat.saved.SavingSection_MouseName;
		obj.dateStr = soloDat.saved.SavingSection_SaveTime;

		% pull protocol name
		fnSaved = fieldnames(soloDat.saved);
		obj.behavProtocolName = '';
		for i=1:length(fnSaved)
			if (length(strfind(fnSaved{i}, 'prot_title')) == 1)
				ie = strfind(fnSaved{i}, 'obj_prot_title');
				obj.behavProtocolName = fnSaved{i}(1:ie-1);
			end
		end
		if (length(obj.behavProtocolName) == 0)
			disp('generateBehavioralDataStructures::could not ID behavioral protocol name.  Aborting.');
			return;
		end

		% init soloTimes
		for p=1:length(behavSoloParams)
			soloTimes{p} = [];
		end

		% ---------------------------------------------------------------------------
		% 2) assign trialType
		if (isstruct(trialTypeParams) && isfield(trialTypeParams, 'trialType'))
			obj.trialType = trialTypeParams.trialType;
			obj.trialTypeStr = trialTypeParams.trialTypeStr;
			obj.trialTypeColor = trialTypeParams.trialTypeColor;
		else
			switch obj.behavProtocolName
				case 'pole_detect_twoport_sp' % two-port
					obj.trialType = [1 2 3 4 5 6];
					obj.trialTypeStr = {'HitL', 'HitR', 'ErrL', 'ErrR', 'NoLickL', 'NoLickR'};
					obj.trialTypeColor = [0 0 1 ; 0 1 1 ; 1 0 0 ; 1 0 1 ; 0 0 0 ; 0.5 0.5 0.5];

				case 'pole_detect_sp' % go/nogo
					obj.trialType = [1 2 3 4];
					obj.trialTypeStr = {'Hit', 'Miss', 'FA', 'CR'};
					obj.trialTypeColor = [0 0 1; 0 0 0 ; 0 1 0; 1 0 0];

				otherwise
					disp(['generateBehavioralDataStructures::Protocol ' obj.behavProtocolName ' not recognized; aborting']);
					return;
			end
		end

		% ---------------------------------------------------------------------------
		% 3) cycle thru the trials
		for t=1:nTrials
			events = soloDat.saved_history.RewardsSection_LastTrialEvents{t};

			% --- trial start
			tsti = find(events(:,1) == 40,1); % index
			if (length(tsti) == 0) 
				tst = 0; % actual start time
			else
				tst = events(tsti,3);
			end
			startTime = tst*1000; % s -> ms
			timeUnitId = 1; % ms

			% --- trial class
			if (isstruct(trialTypeParams) && isfield(trialTypeParams, 'trialTypingFunc'))
				trialType = eval ([trialTypingFunc '(soloDat, t);']); 
			else
				switch obj.behavProtocolName
					case 'pole_detect_sp'
						isgo = soloDat.saved.SidesSection_previous_sides(t) == 114; % 114 charcode for 'r' (thus 1 = GO) , 108 'l' 
						iscorrect = soloDat.saved.pole_detect_spobj_hit_history(t);        % 1 = correct ; 0 = not
								
						if (isgo & iscorrect) % HIT
							trialType = 1;
						elseif (isgo & iscorrect==0) % miss
							trialType = 2;
						elseif (isgo == 0 & iscorrect == 0) % FA
							trialType = 3;
						elseif (isgo == 0 & iscorrect) % CR
							trialType = 4;
						end

					case 'pole_detect_twoport_sp'
						isright = soloDat.saved.SidesSection_previous_sides(t) == 114; % 114 charcode for 'r' (thus 1 = GO) , 108 'l' 
						iscorrect = soloDat.saved.pole_detect_twoport_spobj_hit_history(t);        % 1 = correct ; 0 = not
								
						if (~isright) % left
							if (iscorrect == 1)
								trialType = 1;
							elseif (iscorrect == 0) % error
								trialType = 3; 
							else % no lick
								trialType = 5;
							end
						else % right
							if (iscorrect == 1)
								trialType = 2;
							elseif (iscorrect == 0) % error
								trialType = 4; 
							else % no lick
								trialType = 6;
							end
						end
				end
			end

			% --- behavParams
			if (length(trialBehavParams) == 2)
				behavParams = hash();
				for bpi=1:length(trialBehavParams{1})
					try
						val = eval(['soloDat.' trialBehavParams{1}{bpi}]);
					catch
						val{t} = 'FIELD NOT FOUND';
					end

					if (iscell(val))
						uval = val{t};
					else
						uval = val(t);
					end
					behavParams.setOrAdd(trialBehavParams{2}{bpi}, uval);
				end
			end

			% --- end time
			endTime = -1;
			if (t == nTrials) % last? endTime = start+1 minute
				endTime = startTime + 60000;
			elseif (t >= 2) % increment last -- the CURRENT will be fixed in next step
				tmpTrial{t-1}.endTime = startTime-1;   
			end

			% --- instantiate trial object
			tmpTrial{t} = session.trial(t, trialType, 1, startTime, endTime, behavParams);

			% --- behavSoloParams
			for p=1:length(behavSoloParams)
				switch behavSoloParams{p}{1} % mode
					case 1 % only match column 2
						tsti = find(events(:,2) == behavSoloParams{p}{2});
						if (length(tsti) == 0)
							eTimes = [];
						else
							eTimes = events(tsti,3)*1000; % conver to ms
						end
						% strays -- nonzero
						val = find(eTimes > 0);
						eTimes = eTimes(val);
						% strays -- doubles
						eTimes = unique(eTimes);
						if (size(eTimes,1)> size(eTimes,2))
							eTimes = eTimes';
						end
						soloTimes{p} = [soloTimes{p} eTimes];

					case 2
						tsti_s = find(events(:,1) == behavSoloParams{p}{2}(1) & events(:,2) == 0, 1, 'first');
						tsti_e = find(events(:,1) == behavSoloParams{p}{2}(1) & events(:,2) == 3, 1, 'first');
						if (length(tsti_s) == 0)
							eTimes = [];
						else
							eTimes = [(events(tsti_s,3)) (events(tsti_e,3))]*1000; % conver to ms
						end
						% strays -- doubles
						eTimes = unique(eTimes,'rows');
						if (size(eTimes,1)> size(eTimes,2))
							eTimes = eTimes';
						end
						soloTimes{p} = [soloTimes{p} eTimes];

					case 3
						tsti_s = find(events(:,1) == behavSoloParams{p}{2}(1) & events(:,2) == 0, 1, 'first');
						tsti_e = find(events(:,1) == behavSoloParams{p}{2}(2) & events(:,2) == 0, 1, 'first');
						if (length(tsti_s) == 0)
							eTimes = [];
						else
							eTimes = [(events(tsti_s,3)) (events(tsti_e,3))]*1000; % conver to ms
						end
						% strays -- doubles
						eTimes = unique(eTimes,'rows');
						if (size(eTimes,1)> size(eTimes,2))
							eTimes = eTimes';
						end
						soloTimes{p} = [soloTimes{p} eTimes];

					case 4
						tsti_s = find(events(:,1) == behavSoloParams{p}{2}(1) & events(:,2) == 0, 1, 'first');
						tsti_e=[];k=2;
						while isempty(tsti_e)&& k <length(behavSoloParams{p}{2})
							tsti_e = find(events(:,1) == behavSoloParams{p}{2}(k) & events(:,2) == 0, 1, 'first');
							k=k+1;
						end

						if (length(tsti_s) == 0)
							eTimes = [];
						else
							eTimes = [(events(tsti_s,3)) (events(tsti_e,3))]*1000; % conver to ms
						end
						% strays -- doubles
						eTimes = unique(eTimes,'rows');
						if (size(eTimes,1)> size(eTimes,2))
							eTimes = eTimes';
						end
						soloTimes{p} = [soloTimes{p} eTimes];

				end % switch
			end % for
		end % end trial loop

		% setup object trial (which in turn builds trialIds)
		obj.trial = tmpTrial;
		obj.validBehavTrialIds = obj.trialIds;

		% ---------------------------------------------------------------------------
		% 4) build the eventSeries objects, then eventSeriesArray

		% build the basic behavESA object
		trialTimes = zeros(length(obj.trial),3);
		for t=1:length(obj.trial)
			trialTimes(t,:) = [t obj.trial{t}.startTime obj.trial{t}.endTime];
		end
		obj.behavESA = session.eventSeriesArray({}, trialTimes);

		% grab start times
		obj.trialStartTimes = trialTimes(:,2)';

		% and add the eventSeries as you build them ...
		for p=1:length(behavSoloParams)
			evTimes = soloTimes{p};
			ES = session.eventSeries(evTimes, [], 1, p, behavSoloParams{p}{3}, 0, '', soloFilePath, ...
				behavSoloParams{p}{4}, behavSoloParams{p}{5});
			obj.behavESA.addEventSeriesToArray(ES);
		end

		% loop over behavioral ES's and execute generateStartTimeRelTimes
		for e=1:length(obj.behavESA.esa)
			obj.behavESA.esa{e}.generateStartTimeRelTimes(obj.trialStartTimes, obj.trialIds);
		end
  end
