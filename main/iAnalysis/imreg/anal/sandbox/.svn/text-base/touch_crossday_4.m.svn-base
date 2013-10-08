function touch_crossday_4(obj, roiId, dffRange, sessions, printDir)
	if (nargin < 3) ; dffRange = []; end
	if (nargin < 4) ; sessions = 1:length(obj.dateStr); end
	if (nargin < 5) ; printDir = []; end


  showRFPlots = [1 0 0 0 0]; % 1) test plots of which contact to use, and stim mode 2) dkappa 3) theta 4) dtheta 5) duration
	showRFTestModes = [1 0 0 0]; % 1) kappa 2) theta 3) kappa exclusive 4) theta exlusive
	showRFModes = [1 1 1 1 1 1]; % 1) vanilla 2) combo 3) seq 4) lick 5) trial # 6) trial class
	showRFModes = [1 0 0 0 0 0]; % 1) vanilla 2) combo 3) seq 4) lick 5) trial # 6) trial class
  summarizeRF (obj, roiId, dffRange, sessions, showRFPlots, showRFModes, showRFTestModes, printDir);
return

	showETAPlots = [0 0 0]; % 1) isolated 2) combo 3) seq
  summarizeETA (obj, roiId, dffRange, sessions, showETAPlots);

  
function summarizeRF (obj, roiId, dffRange, sessions, showRFPlots, showRFModes, showRFTestModes, printDir)
  whiskers = {'c1', 'c2', 'c3'};

	kappaStimMode = 'sumabs';
	kappaValueRange = [-.025 1];
	kappaTrialEventNum = [];
	kappaTrialEventNumL = 'all';
kappaTrialEventNum = 'max';
kappaTrialEventNumL = 'max';
kappaStimMode = 'maxabs';
kappaValueRange = [-.005 .005];

%kappaValueRange = [];

	thetaStimMode = 'mean';
	thetaTrialEventNum = [];
	thetaTrialEventNumL = 'all';

	durationTrialEventNum = 1;
	durationTrialEventNumL = 'first';


	% ====== PERI-EVENT RECEPTIVE FIELDS ========
  % 1) explore whish subset to use
	if (showRFPlots(1))
	 	for w=1:length(whiskers)
		  disp(['===============================================']);
			clear pparams;
			pparams.sessions = sessions;
			pparams.respTSA = 'caTSA.dffTimeSeriesArray';
			pparams.respTSId = roiId;
			pparams.respTimeWindow = [0 2];
			pparams.respMode = 'max';
			pparams.respValueRange = dffRange;
			pparams.stimTimeWindow = [-0.1 0.5];
			pparams.ESA = 'whiskerBarContactClassifiedESA';
			pparams.ESId = {['Protraction contacts for ' whiskers{w}],['Retraction contacts for ' whiskers{w}]};
			pparams.ESColor = [1 0 0 ; 0 0 1];

			pparams.stimTSA = 'whiskerCurvatureChangeTSA';
			pparams.stimTSId = ['Curvature change for ' whiskers{w}];
			if (showRFTestModes(1)) ; exploreParamsKappa (pparams, obj, 'all'); end

			pparams.stimTSA = 'whiskerAngleTSA';
			pparams.stimTSId = ['Angle for ' whiskers{w}];
			if (showRFTestModes(2)) ; exploreParamsTheta (pparams, obj, 'all');  end

			% exclusive
			pparams.excludeOthers = 1;
			pparams.xESTimeWindow = [-2 2];

			pparams.stimTSA = 'whiskerCurvatureChangeTSA';
			pparams.stimTSId = ['Curvature change for ' whiskers{w}];
			if (showRFTestModes(3)) ; exploreParamsKappa (pparams, obj, 'exclusive' ); end
			
			pparams.stimTSA = 'whiskerAngleTSA';
			pparams.stimTSId = ['Angle for ' whiskers{w}];
			if (showRFTestModes(4)) ; exploreParamsTheta (pparams, obj, 'exclusive' ); end

		end
	end

  % 2) dkappa
	if (showRFPlots(2))
	 	for w=1:length(whiskers)
		  disp(['===============================================']);
			clear pparams;

      % --- plain jane
      pparams.stimMode = kappaStimMode;
    	pparams.stimValueRange = kappaValueRange;
	    pparams.trialEventNumber = kappaTrialEventNum;

			pparams.sessions = sessions;
			pparams.respTSA = 'caTSA.dffTimeSeriesArray';
			pparams.respTSId = roiId;
			pparams.respTimeWindow = [0 2];
			pparams.respMode = 'max';
			pparams.respValueRange = dffRange;
			pparams.stimTimeWindow = [-0.1 0.5];
			pparams.ESA = 'whiskerBarContactClassifiedESA';
			pparams.ESId = {['Protraction contacts for ' whiskers{w}],['Retraction contacts for ' whiskers{w}]};
			pparams.ESColor = [1 0 0 ; 0 0 1];
			pparams.stimTSA = 'whiskerCurvatureChangeTSA';
			pparams.stimTSId = ['Curvature change for ' whiskers{w}];

      RFSubplot(obj, pparams, showRFModes, kappaTrialEventNumL, printDir, [whiskers{w} '_dkappa']);
		end
	end

  % 3) theta
	if (showRFPlots(3))
	 	for w=1:length(whiskers)
			clear pparams;

      % --- plain jane
      pparams.stimMode = thetaStimMode;
    	pparams.stimValueRange = [-50 50];
	    pparams.trialEventNumber = thetaTrialEventNum;

			pparams.sessions = sessions;
			pparams.respTSA = 'caTSA.dffTimeSeriesArray';
			pparams.respTSId = roiId;
			pparams.respTimeWindow = [0 2];
			pparams.respMode = 'max';
			pparams.respValueRange = dffRange;
			pparams.stimTimeWindow = [-0.1 0.5];
			pparams.ESA = 'whiskerBarContactClassifiedESA';
			pparams.ESId = {['Protraction contacts for ' whiskers{w}],['Retraction contacts for ' whiskers{w}]};
			pparams.ESColor = [1 0 0 ; 0 0 1];
			pparams.stimTSA = 'whiskerAngleTSA';
			pparams.stimTSId = ['Angle for ' whiskers{w}];
  
      RFSubplot(obj, pparams, showRFModes, thetaTrialEventNumL, printDir,[whiskers{w}  '_theta']);
		end
	end

  % 4) dtheta
	if (showRFPlots(4))
	 	for w=1:length(whiskers)
			clear pparams;

      % --- plain jane
      pparams.stimMode = 'deltasumabs';
    	pparams.stimValueRange = [-5 500];
	    pparams.trialEventNumber = thetaTrialEventNum;

			pparams.sessions = sessions;
			pparams.respTSA = 'caTSA.dffTimeSeriesArray';
			pparams.respTSId = roiId;
			pparams.respTimeWindow = [0 2];
			pparams.respMode = 'max';
			pparams.respValueRange = dffRange;
			pparams.stimTimeWindow = [-0.1 0.5];
			pparams.ESA = 'whiskerBarContactClassifiedESA';
			pparams.ESId = {['Protraction contacts for ' whiskers{w}],['Retraction contacts for ' whiskers{w}]};
			pparams.ESColor = [1 0 0 ; 0 0 1];
			pparams.stimTSA = 'whiskerAngleTSA';
			pparams.stimTSId = ['Angle for ' whiskers{w}];

      RFSubplot(obj, pparams, showRFModes, thetaTrialEventNumL, printDir,[whiskers{w}  '_dtheta']);
		end
	end

  % 5) duration of contact
	if (showRFPlots(5))
	 	for w=1:length(whiskers)
			clear pparams;

      % --- plain jane
      pparams.stimMode = 'duration';
    	pparams.stimValueRange = [-5 500];
	    pparams.trialEventNumber = durationTrialEventNum;

			pparams.sessions = sessions;
			pparams.respTSA = 'caTSA.dffTimeSeriesArray';
			pparams.respTSId = roiId;
			pparams.respTimeWindow = [0 2];
			pparams.respMode = 'max';
			pparams.respValueRange = dffRange;
			pparams.stimTimeWindow = [-0.1 0.5];
			pparams.ESA = 'whiskerBarContactClassifiedESA';
			pparams.ESId = {['Protraction contacts for ' whiskers{w}],['Retraction contacts for ' whiskers{w}]};
			pparams.ESColor = [1 0 0 ; 0 0 1];
			pparams.stimTSA = 'whiskerCurvatureChangeTSA';
			pparams.stimTSId = ['Curvature change for ' whiskers{w}];

      RFSubplot(obj, pparams, showRFModes, durationTrialEventNumL, printDir, [whiskers{w} '_duration']);
		end
	end

%
% print to file
%
function printFig(printDir, obj, printTag, pparams, eventNumL)
	if (length(printDir) > 0)
	  printFname = [printDir filesep obj.mouseId '_cell_' num2str(pparams.respTSId) '_RF_' printTag '_'  pparams.stimMode '_' eventNumL];
		set(gcf,'Position', [1 1 800 800]);
 		set(gcf,'PaperPositionMode','auto', 'PaperSize', [8 8], 'PaperUnits', 'inches');
    print('-dpdf', printFname, '-noui','-r300');
  	close;
	end
%
% subset plot of RFs
% 
function RFSubplot(obj, pparams, showRFModes, eventNumL, printDir, printTag)
	% --- plain jane
	if (showRFModes(1))
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch']);
		printFig(printDir, obj, printTag, pparams, eventNumL);

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch EXCLUSIVE ']);
		printFig(printDir, obj, [printTag '_exclusive'] , pparams, eventNumL);
	end

	% --- combo touch
	pparams.excludeOthers = 0;
	pparams.labelMode = 'ESA';
	pparams.labelClasses = 'getCoincidentWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3'', ''Pc1'', ''Pc2'', ''Pc3''}, 2)';
	pparams.labelClassId = [1 2 6 4 5 9];
	pparams.labelColors =  [1 0 1; 0 1 1 ; 0 0 0 ; 1 0.75 1 ; 0.75 1 1 ; 0.75 0.75 0.75];
	pparams.labelESOverlapWindow = [-0.2 0.2];

	if (showRFModes(2))
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch ']);

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch EXCLUSIVE ']);
	end

	% --- sequence touch
	pparams.excludeOthers = 0;
	pparams.labelMode = 'ESA';
	pparams.labelClasses = 'getSequentialWhiskerContactESA({''Rc1'',''Rc2'', ''Rc3'', ''Pc1'', ''Pc2'', ''Pc3''}, 2)';
	pparams.labelClassId = [1 3 11 8 10 18];
	pparams.labelColors =  [1 0 1; 0 1 1 ; 0 0 0 ; 1 0.75 1 ; 0.75 1 1 ; 0.75 0.75 0.75];
	pparams.labelESOverlapWindow = [-2 2];

	if (showRFModes(3))
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch ']);

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch EXCLUSIVE ']);
	end

	% --- lick rate
	pparams.excludeOthers = 0;
	pparams.labelMode = 'lickRate';
	pparams.labelClasses = {[0 .5], [.5 1.5], [1.5 3], [3 Inf]};
	pparams.labelColors = [0 0 0 ; 0.5 0 0.5 ; 0.75 0 0.75 ; 1 0 1];
	pparams.labelESOverlapWindow = [-2 2];

	if (showRFModes(4))
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch ']);

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch EXCLUSIVE ']);
	end


	% --- trial #
	pparams.excludeOthers = 0;
	pparams.labelMode = 'trialFrac';
	pparams.labelClasses = {[0 0.25], [0.25 0.5] , [0.5 0.75], [ 0.75 1]};
	pparams.labelColors = [0 0 0 ; 0.25 0.25 0.25 ; 0.5 0.5 0.5 ; 0.75 0.75 0.75]; 
	pparams.labelESOverlapWindow = [-2 2];

	if (showRFModes(5))
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch ']);

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch EXCLUSIVE ']);
	end

	% --- trial type
	pparams.excludeOthers = 0;
	pparams.labelMode = 'trialType';
	pparams.labelClasses = {'Hit', 'CR', 'Miss', 'FA'};
	pparams.labelColors = [0 0 1; 1 0 0 ; 0 0 0 ; 0 1 0];
	pparams.labelESOverlapWindow = [-2 2];

	if (showRFModes(6))
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch ']);

		% exclusive
		pparams.excludeOthers = 1;
		pparams.xESTimeWindow = [-2 2];
		obj.plotPeriEventRFCrossDays(pparams);
		set(gcf,'Name',[get(gcf,'Name') ' ' pparams.stimMode ' ' eventNumL ' touch EXCLUSIVE ']);
	end

%
% Summary figure for event trig avgs
%
function summarizeETA (obj, roiId, dffRange, sessions, showETAPlots)
  avgType = 1; %1: mean ; 2: median

	% ====== EVENT TRIGGERED AVERAGES ===========
	% -------------------------------------------
	% 1) contact-triggered average, all whiskers
	if (showETAPlots(1))
		plotBarAxesAll = generateMultipanelFigure(obj, 'any contact', sessions);
		plotBarAxesExcl = generateMultipanelFigure(obj, 'any contact exclusive', sessions);
		clear eparams;
		eparams.displayedId = roiId;
		eparams.sessions = sessions;
		eparams.plotMode = [0 0 0 1];
		eparams.excludeOthers = 0;
		eparams.plotBar = 1;
		eparams.avgType = avgType;
	  eparams.plotAvg = 1;
		eparams.valueRange = dffRange;
		eparams.triggeringESA = 'whiskerBarContactESA';
		eparams.triggeringESAIds  = {'Contacts for c1', ...
																 'Contacts for c2', ...
																 'Contacts for c3'};
		eparams.triggeringESACols = [1 0 0 ; 0 1 0 ; 0 0 1];
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 1:3;
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact']);

		eparams.excludeOthers = 1;
		eparams.plotBarAxes = plotBarAxesExcl;
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact exclusive']);

		% 1b contact-triggered average, pro/re all whiskers
		clear eparams;
		eparams.displayedId = roiId;
		eparams.sessions = sessions;
		eparams.plotMode = [0 0 0 1];
		eparams.excludeOthers = 0;
		eparams.plotBar = 1;
		eparams.avgType = avgType;
	  eparams.plotAvg = 1;
		eparams.valueRange = dffRange;
		eparams.triggeringESA = 'whiskerBarContactClassifiedESA';
		eparams.triggeringESAIds  = {'Protraction contacts for c1', ...
																 'Retraction contacts for c1', ...
																 'Protraction contacts for c2', ...
																 'Retraction contacts for c2', ...
																 'Protraction contacts for c3', ...
																 'Retraction contacts for c3'};
		eparams.triggeringESACols = [1 0.5 0.5 ; 1 0 0 ; 0.5 1 0.5 ; 0 1 0 ; 0.5 0.5 1 ; 0 0 1];
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 4:9;
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact']);

		eparams.excludeOthers = 1;
		eparams.plotBarAxes = plotBarAxesExcl;
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact exclusive']);
	end

	% -------------------------------------------
	% 2) contact-triggered avg for COMBOs of whiskers:
	if (showETAPlots(2))
		%  bar: EXCLUSIVE c1, c2, c3, c1c2, c2c3 ; non-exclusive c1c2c3 (by def'n exclusive!)
		plotBarAxesAll = generateMultipanelFigure(obj, 'any contact exclusive', sessions);
		clear eparams;
		eparams.displayedId = roiId;
		eparams.sessions = sessions;
		eparams.plotMode = [0 0 0 1];
		eparams.excludeOthers = 1;
		eparams.plotBar = 1;
		eparams.avgType = avgType;
	  eparams.plotAvg = 0;
		eparams.valueRange = dffRange;
		eparams.triggeringESA = 'whiskerBarContactESA';
		eparams.triggeringESAIds  = {'Contacts for c1', ...
																 'Contacts for c2', ...
																 'Contacts for c3'};
		eparams.triggeringESACols = [1 0 0 ; 0 1 0 ; 0 0 1];
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 1:3;
		obj.plotEventTriggeredAverageCrossDays(eparams);

	  eparams.plotAvg = 0;
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 4:5;
    eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''c1'',''c2'',''c3''}, 2)';
    eparams.triggeringESAIds  = 1:2;
    eparams.triggeringESACols = [1 0 1 ; 0 1 1];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		eparams.excludeOthers = 0;
    eparams.triggeringESAIds  = 3;
		eparams.plotBarX = 6;
    eparams.triggeringESACols = [0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);
	  
		%  plot: NONEXCLUSIVE c1c2 c2c3 c1c2c3
		eparams.plotBar = 0;
		eparams.plotAvg = 1;
		eparams.excludeOthers = 0;
    eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''c1'',''c2'',''c3''}, 2)';
    eparams.triggeringESAIds  = 1:3;
    eparams.triggeringESACols = [1 0 1 ; 0 1 1 ; 0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact']);

		%  plot: EXCLUSIVE c1c2 c2c3 c1c2c3
		eparams.excludeOthers = 1;
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact exclusive']);

		% bar: [EXCL] Rc1 Pc1 Rc2 Pc2 Rc3 Pc3 vs Rc1c2 Rc2c3 Rc1c2c3 Pc1c2 Pc2c3 Pc1c2c3
		plotBarAxesAll = generateMultipanelFigure(obj, 'any contact exclusive', sessions);
		clear eparams;
		eparams.displayedId = roiId;
		eparams.sessions = sessions;
		eparams.plotMode = [0 0 0 1];
		eparams.excludeOthers = 1;
		eparams.plotBar = 1;
		eparams.avgType = avgType;
	  eparams.plotAvg = 0;
		eparams.valueRange = dffRange;
		eparams.triggeringESA = 'whiskerBarContactClassifiedESA';
		eparams.triggeringESAIds  = {'Protraction contacts for c1', ...
																 'Retraction contacts for c1', ...
																 'Protraction contacts for c2', ...
																 'Retraction contacts for c2', ...
																 'Protraction contacts for c3', ...
																 'Retraction contacts for c3'};
		eparams.triggeringESACols = [1 0.5 0.5 ; 1 0 0 ; 0.5 1 0.5 ; 0 1 0 ; 0.5 0.5 1 ; 0 0 1];
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 1:6;
		obj.plotEventTriggeredAverageCrossDays(eparams);

	  eparams.plotAvg = 0;
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 8:9;
    eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Pc1'',''Pc2'',''Pc3''}, 2)';
    eparams.triggeringESAIds  = 1:2;
    eparams.triggeringESACols = [1 0.5 1 ; 0.5 1 1];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		eparams.excludeOthers = 0;
    eparams.triggeringESAIds  = 3;
		eparams.plotBarX = 10;
    eparams.triggeringESACols = [0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
	  
		eparams.plotBarX = 12:13;
    eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Rc1'',''Rc2'',''Rc3''}, 2)';
    eparams.triggeringESAIds  = 1:2;
    eparams.triggeringESACols = [1 0 1 ;0 1 1];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		eparams.excludeOthers = 0;
    eparams.triggeringESAIds  = 3;
		eparams.plotBarX = 14;
    eparams.triggeringESACols = [0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		% plot: NONEXCLUSIVE Rc1c2 Rc2c3 Rc1c2c3
		eparams.plotAvg = 1;
		eparams.plotBar = 0;
		eparams.excludeOthers = 0;
    eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Rc1'',''Rc2'',''Rc3''}, 2)';
    eparams.triggeringESAIds  = 1:3;
    eparams.triggeringESACols = [1 0 1 ;0 1 1 ; 0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' coincident contact']);

		% plot: EXCLUSIVE Rc1c2 Rc2c3 Rc1c2c3
		eparams.excludeOthers = 1;
    eparams.triggeringESAIds  = 1:3;
    eparams.triggeringESACols = [1 0 1 ;0 1 1 ; 0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' coincident contact exclusive']);

		% plot: NONEXCLUSIVE Pc1c2 Pc2c3 Pc1c2c3
		eparams.plotAvg = 1;
		eparams.plotBar = 0;
		eparams.excludeOthers = 0;
    eparams.triggeringESA = 'getCoincidentWhiskerContactESA({''Pc1'',''Pc2'',''Pc3''}, 2)';
    eparams.triggeringESAIds  = 1:3;
    eparams.triggeringESACols = [1 0.5 1 ;0.5 1 1 ; 0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' coincident contact']);

		% plot: EXCLUSIVE Pc1c2 Pc2c3 Pc1c2c3
		eparams.excludeOthers = 1;
    eparams.triggeringESAIds  = 1:3;
    eparams.triggeringESACols = [1 0.5 1 ;0.5 1 1 ; 0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' coincident contact exclusive']);
	end


	% -------------------------------------------
	% 3) contact-triggered avg for SEQUENCES of whiskers:
	if (showETAPlots(3))
		%  bar: EXCLUSIVE c1, c2, c3, c1->c2, c2->c3 c3->c2 c2->c1; non-exclusive c1c2c3 c3c2c1(by def'n exclusive!)
		plotBarAxesAll = generateMultipanelFigure(obj, 'any contact exclusive', sessions);
		clear eparams;
		eparams.displayedId = roiId;
		eparams.sessions = sessions;
		eparams.plotMode = [0 0 0 1];
		eparams.excludeOthers = 1;
		eparams.plotBar = 1;
		eparams.avgType = avgType;
	  eparams.plotAvg = 0;
		eparams.valueRange = dffRange;
		eparams.triggeringESA = 'whiskerBarContactESA';
		eparams.triggeringESAIds  = {'Contacts for c1', ...
																 'Contacts for c2', ...
																 'Contacts for c3'};
		eparams.triggeringESACols = [1 0 0 ; 0 1 0 ; 0 0 1];
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 1:3;
		obj.plotEventTriggeredAverageCrossDays(eparams);

	  eparams.plotAvg = 0;
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 5:8;
    eparams.triggeringESA = 'getSequentialWhiskerContactESA({''c1'',''c2'',''c3''}, 2)';
    eparams.triggeringESAIds  = 1:4;
    eparams.triggeringESACols = [1 0 1 ; 0 1 1 ; 1 0.5 1 ; 0.5 1 1 ];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		eparams.excludeOthers = 0;
    eparams.triggeringESAIds  = 5:6;
		eparams.plotBarX = 10:11;
    eparams.triggeringESACols = [0 0 0; .5 .5 .5];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		%  plot: NONEXCLUSIVE c1c2 c2c3 c2c1 c3c2 c1c2c3 c3c2c1
		eparams.plotBar = 0;
		eparams.plotAvg = 1;
		eparams.excludeOthers = 0;
    eparams.triggeringESA = 'getSequentialWhiskerContactESA({''c1'',''c2'',''c3''}, 2)';
    eparams.triggeringESAIds  = 1:6;
    eparams.triggeringESACols = [1 0 1 ; 0 1 1 ; 1 0.5 1; 0.5 1 1 ; 0 0 0; 0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact']);

		%  plot: EXCLUSIVE c1c2 c2c3 c2c1 c3c2 c1c2c3 c3c2c1
		eparams.excludeOthers = 1;
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' any contact exclusive']);

		% bar: [EXCL] Rc1 Pc1 Rc2 Pc2 Rc3 Pc3 vs Rc1c2 Rc2c3 Rc1c2c3 Pc1c2 Pc2c3 Pc1c2c3
		plotBarAxesAll = generateMultipanelFigure(obj, 'any contact exclusive', sessions);
		clear eparams;
		eparams.displayedId = roiId;
		eparams.sessions = sessions;
		eparams.plotMode = [0 0 0 1];
		eparams.excludeOthers = 1;
		eparams.plotBar = 1;
		eparams.avgType = avgType;
	  eparams.plotAvg = 0;
		eparams.valueRange = dffRange;
		eparams.triggeringESA = 'whiskerBarContactClassifiedESA';
		eparams.triggeringESAIds  = {'Protraction contacts for c1', ...
																 'Retraction contacts for c1', ...
																 'Protraction contacts for c2', ...
																 'Retraction contacts for c2', ...
																 'Protraction contacts for c3', ...
																 'Retraction contacts for c3'};
		eparams.triggeringESACols = [1 0.5 0.5 ; 1 0 0 ; 0.5 1 0.5 ; 0 1 0 ; 0.5 0.5 1 ; 0 0 1];
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 1:6;
		obj.plotEventTriggeredAverageCrossDays(eparams);

	  eparams.plotAvg = 0;
		eparams.plotBarAxes = plotBarAxesAll;
		eparams.plotBarX = 8:9;
    eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Pc1'',''Pc2'',''Pc3''}, 2)';
    eparams.triggeringESAIds  = [2 4]
    eparams.triggeringESACols = [1 0.5 1 ; 0.5 1 1];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		eparams.excludeOthers = 0;
    eparams.triggeringESAIds  = 6;
		eparams.plotBarX = 10;
    eparams.triggeringESACols = [0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
	  
		eparams.plotBarX = 12:13;
    eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Rc1'',''Rc2'',''Rc3''}, 2)';
    eparams.triggeringESAIds  = [1 3];
    eparams.triggeringESACols = [1 0 1 ;0 1 1];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		eparams.excludeOthers = 0;
    eparams.triggeringESAIds  = 5;
		eparams.plotBarX = 14;
    eparams.triggeringESACols = [0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);

		% plot: NONEXCLUSIVE Rc1c2 Rc2c3 Rc1c2c3
		eparams.plotAvg = 1;
		eparams.plotBar = 0;
		eparams.excludeOthers = 0;
    eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Rc1'',''Rc2'',''Rc3''}, 2)';
    eparams.triggeringESAIds  = [1 3 5];
    eparams.triggeringESACols = [1 0 1 ;0 1 1 ; 0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' sequential contact']);

		% plot: EXCLUSIVE Rc1c2 Rc2c3 Rc1c2c3
		eparams.excludeOthers = 1;
    eparams.triggeringESAIds  = [1 3 5];
    eparams.triggeringESACols = [1 0 1 ;0 1 1 ; 0 0 0];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' sequential contact exclusive']);

		% plot: NONEXCLUSIVE Pc1c2 Pc2c3 Pc1c2c3
		eparams.plotAvg = 1;
		eparams.plotBar = 0;
		eparams.excludeOthers = 0;
    eparams.triggeringESA = 'getSequentialWhiskerContactESA({''Pc1'',''Pc2'',''Pc3''}, 2)';
    eparams.triggeringESAIds  = [2 4 6];
    eparams.triggeringESACols = [1 .5 1 ;0.5 1 1 ; 0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' sequential contact']);

		% plot: EXCLUSIVE Pc1c2 Pc2c3 Pc1c2c3
		eparams.excludeOthers = 1;
    eparams.triggeringESAIds  = [2 4 6];
    eparams.triggeringESACols = [1 0.5 1 ;0.5 1 1 ; 0.5 0.5 0.5];
		obj.plotEventTriggeredAverageCrossDays(eparams);
		set(gcf,'Name',[get(gcf,'Name') ' sequential contact exclusive']);
	end



%
% genearates a figure with ndays panels, returning axes ref to each subplot
%
function axRefs = generateMultipanelFigure(obj, figureName, sessions)
	
	if (nargin < 2); figureName = ''; end

	f = figure('Name', figureName, 'NumberTitle','off');
	NDays = length(sessions);
	Np = ceil(sqrt(NDays));
	
	axRefs = [];
	for d=1:length(sessions)
		axRefs(d) = subplot(Np,Np,d);
	end


%
%    stimMode      trialEventNumber
% {maxabs, sumabs} x {[], 1, 'max'} 
%
% for a given set of pparams, loop thru above
%
function exploreParamsKappa (pparams, obj, ftit)
  pparams.stimMode = 'maxabs';
	pparams.stimValueRange = [-0.025 .025];

	disp('=== maxabs all touches');
	pparams.trialEventNumber = [];
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' maxabs all touches ' ftit]);

	disp('=== maxabs 1st touch');
	pparams.trialEventNumber = 1;
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' maxabs 1st touch ' ftit]);

	disp('=== maxabs max touch');
	pparams.trialEventNumber = 'max';
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' maxabs max touch ' ftit]);

  pparams.stimMode = 'sumabs';
	pparams.stimValueRange = [-0.05 1];

	disp('=== sumabs all touch');
	pparams.trialEventNumber = [];
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' sumabs all touches ' ftit]);

	disp('=== sumabs 1st touch');
	pparams.trialEventNumber = 1;
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' sumabs 1st touch ' ftit]);

	disp('=== sumabs max touch');
	pparams.trialEventNumber = 'max';
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' sumabs max touch ' ftit]);

  pparams.stimMode = 'duration';
	pparams.stimValueRange = [-10 500];

	disp('=== duration all touch');
	pparams.trialEventNumber = [];
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' duration all touches ' ftit]);

	disp('=== duration 1st touch');
	pparams.trialEventNumber = 1;
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' duration 1st touch ' ftit]);

	disp('=== duration max touch');
	pparams.trialEventNumber = 'max';
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' duration max touch ' ftit]);


%
%    stimMode      trialEventNumber
% {mean, deltasumabs} x {[], 1, 'max'} 
%
% for a given set of pparams, loop thru above
%
function exploreParamsTheta(pparams, obj, ftit)
  pparams.stimMode = 'mean';
	pparams.stimValueRange = [-50 50];

	pparams.trialEventNumber = [];
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' mean all touches ' ftit]);

	pparams.trialEventNumber = 1;
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' mean 1st touch ' ftit]);

	pparams.trialEventNumber = 'max';
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' mean max touch ' ftit]);

  pparams.stimMode = 'deltasumabs';
	pparams.stimValueRange = [-10 200];

	pparams.trialEventNumber = [];
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' dsumabs all touches ' ftit]);

	pparams.trialEventNumber = 1;
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' dsumabs 1st touch ' ftit]);

	pparams.trialEventNumber = 'max';
	obj.plotPeriEventRFCrossDays(pparams);
	set(gcf,'Name',[get(gcf,'Name') ' dsumabs max touch ' ftit]);




