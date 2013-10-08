%
% SP Mar 2011
%
% Wrapper script for generating tree bagger execution on cluster
%
% Define treeBaggerParams here.  
%
%
function tree_matgen_dh
	% pull IP & assign machine dependent parameters
	[irr ipstr] = system('ifconfig | grep ''inet addr:'' | grep -v ''127.0.0.1'' | cut -d: -f2 | awk ''{print $1}''');
	if (strcmp(strtrim(ipstr),'10.102.10.187')) % local box
		baseOutDir = '/data/dhtree';
		sessDataPath = '/media/Copy_SP/DOM3_results_clean/';
		sessDataPath = '/groups/svoboda/wdbp/perons/tree/data/dh/';
	else % assume cluster
		baseOutDir = '/groups/svoboda/wdbp/perons/tree/par/';
		sessDataPath = '/groups/svoboda/wdbp/perons/tree/data/dh/';
	end

  fl = dir([sessDataPath '*sessSP.mat']);
  for f=1:length(fl)
	  sessFiles{f} = strrep(fl(f).name , '.mat','');
  end
  
	dffModes = [1 1 1]; % set to 1 to turn on a mode; mode 1: regular dF/F ; 2: vogelstein event-based "dF/F"

	% treeBaggerParams setup -- if you want to make a different one for each session, 
	%  do so manually ...
	treeBaggerParams.sensoryShift = 1:2;
	treeBaggerParams.motorShift = -2:-1;
%	treeBaggerParams.excludeStimulusFeaturesWC = {'pro touch', 'ret touch'};
%	treeBaggerParams.excludeStimulusFeaturesWC = {'beam', 'touch', 'airpuff', 'water', 'pole', 'kappa'};
	treeBaggerParams.outputFileTag = '';

	cd(sessDataPath); % guarantee that you can load everything no problem

	for f=1:length(sessFiles);

		di = 1;
    % make output directory
		mkdir([baseOutDir filesep sessFiles{f}]);
		subBaseOutDir = [baseOutDir filesep sessFiles{f}];

    % load
		load([sessDataPath filesep sessFiles{f}]);
		treeBaggerParams.optionsTree = getDefaultOptionsTreeSimon(s.mouseId);

		% make s.caTSA and s.derivedDataTSA restricted to CRs only
		if (0) % set to if(1) if you want just CRs
			trialTypeRestrict = 0*s.trialType;
			crIdx = find(strcmp(s.trialTypeStr, 'CR'));
			s.validTrialIds = intersect(s.validTrialIds, s.trialIds(find(s.trialTypeMat(crIdx,:))));
		end

    % ---- "modes"
		% encoder
		treeBaggerParams.runModes = [1 0 0 0 0 0 0];
    di = singleCall (dffModes, s, treeBaggerParams, di, subBaseOutDir);

		% encoder group
		treeBaggerParams.runModes = [0 1 0 0 0 0 0];
    di = singleCall (dffModes, s, treeBaggerParams, di, subBaseOutDir);

		% encoder cat
		treeBaggerParams.runModes = [0 0 1 0 0 0 0];
    di = singleCall (dffModes, s, treeBaggerParams, di, subBaseOutDir);

		% decoder multicell
		treeBaggerParams.runModes = [0 0 0 1 0 1 0];
    di = singleCall (dffModes, s, treeBaggerParams, di, subBaseOutDir);

		% decoder 1 cell
		treeBaggerParams.runModes = [0 0 0 0 1 0 1];
    di = singleCall (dffModes, s, treeBaggerParams, di, subBaseOutDir);
	end

function di = singleCall (dffModes, s, treeBaggerParams, di, subBaseOutDir)
	poleTimeDerivedDataTSA =  s.derivedDataTSA.getTrialTimeRestrictedTSA(s.trialStartTimes, s.trialIds, [0 2.5]);

	if (dffModes(1))
		% regular ca -- ALL rois
		treeBaggerParams.outputFileTag = 'allTime_rawDff_';
		s.setupTreeBaggerPar([subBaseOutDir filesep num2str(di)],treeBaggerParams);
		di = di+1;

		% restricted to pole time ..
		treeBaggerParams.outputFileTag = 'poleTime_rawDff_';
		cellResponseTSA =  s.caTSA.dffTimeSeriesArray.getTrialTimeRestrictedTSA(s.trialStartTimes, s.trialIds, [0 2.5]);
		s.setupTreeBaggerPar([subBaseOutDir filesep num2str(di)],treeBaggerParams, cellResponseTSA, poleTimeDerivedDataTSA);
		di = di+1;
	end

	if (dffModes(2))
		% run bagger with vogelstein based data -- ONLY on cells w/ events(!)
		treeBaggerParams.outputFileTag = 'allTime_eventDff_';
		treeBaggerParams.roiID = s.caTSA.ids(find(sum(s.caTSA.eventBasedDffTimeSeriesArray.valueMatrix') > 0)); % active cells
		s.setupTreeBaggerPar([subBaseOutDir filesep num2str(di)],treeBaggerParams, s.caTSA.eventBasedDffTimeSeriesArray);
		di = di+1;

		% restricted to pole time ..
		treeBaggerParams.outputFileTag = 'poleTime_eventDff_';
		cellResponseTSA =  s.caTSA.eventBasedDffTimeSeriesArray.getTrialTimeRestrictedTSA(s.trialStartTimes, s.trialIds, [0 2.5]);
		s.setupTreeBaggerPar([subBaseOutDir filesep num2str(di)],treeBaggerParams, cellResponseTSA, poleTimeDerivedDataTSA);
		di = di+1;
	end

	if (dffModes(3))
		% run bagger with vogelstein based data, peaks only -- AGAIN , only cells w/ events
		treeBaggerParams.outputFileTag = 'allTime_eventPeakDff_';
		treeBaggerParams.roiID = s.caTSA.ids(find(sum(s.caTSA.eventBasedDffTimeSeriesArray.valueMatrix') > 0)); % active cells
		if (isempty(s.caTSA.caPeakTimeSeriesArray))
			s.caTSA.caPeakTimeSeriesArray = s.caTSA.caPeakEventSeriesArray.deriveTimeSeriesArray(s.caTSA.time, s.caTSA.timeUnit, s.caTSA.trialIndices);
		end
		s.setupTreeBaggerPar([subBaseOutDir filesep num2str(di)],treeBaggerParams, s.caTSA.caPeakTimeSeriesArray);
		di = di+1;

		% restricted to pole time ..
		treeBaggerParams.outputFileTag = 'poleTime_eventPeakDff_';
		cellResponseTSA =  s.caTSA.caPeakTimeSeriesArray.getTrialTimeRestrictedTSA(s.trialStartTimes, s.trialIds, [0 2.5]);
		s.setupTreeBaggerPar([subBaseOutDir filesep num2str(di)],treeBaggerParams, cellResponseTSA, poleTimeDerivedDataTSA);
		di = di+1;
	end




