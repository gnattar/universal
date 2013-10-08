%
% SP Jun 2011
%
% This will gather all the whisking summary data used by plotWhiskingSummary.
%
% USAGE:
%
%   wsData = s.getWhiskingSummaryData()
%
function wsData = getWhiskingSummaryData(obj)
  % --- presets
	whiskerTags = {'c1','c2','c3'};

	touchCount = zeros(3,6); 
	firstTouchCount = zeros(3,6); 
  for w=1:length(whiskerTags)
	  touches{w} = {};
		firstTouches{w} = {};
    % in this animal ...
		widx = find(strcmp(obj.whiskerTag,whiskerTags{w}));
		if (length(widx) == 0) ; continue ; end

		% touches
    touchES = obj.whiskerBarContactESA.esa{widx};
		touchFirstES = session.eventSeries.getExcludedEventSeriesS(touchES, [], 1, [-2 2]); % grab first touch

		% unique touches
		uTouchES = session.eventSeries.getExcludedEventSeriesS(touchES, obj.whiskerBarContactESA.getExcludedCellArray(touchES.id), [], [-2 2],1);
		uTouchFirstES = session.eventSeries.getExcludedEventSeriesS(touchES, obj.whiskerBarContactESA.getExcludedCellArray(touchES.id), [], [-2 2],0);

		% directional touches
		proTouchES = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Protraction contacts for ' whiskerTags{w}]);
		proTouchFirstES = session.eventSeries.getExcludedEventSeriesS(proTouchES, [], 1, [-2 2]); % grab first touch
		retTouchES = obj.whiskerBarContactClassifiedESA.getEventSeriesByIdStr(['Retraction contacts for ' whiskerTags{w}]);
		retTouchFirstES = session.eventSeries.getExcludedEventSeriesS(retTouchES, [], 1, [-2 2]); % grab first touch

		% unique directional touches
		uProTouchES = session.eventSeries.getExcludedEventSeriesS(proTouchES, obj.whiskerBarContactClassifiedESA.getExcludedCellArray(proTouchES.id), [], [-2 2],1);
		uProTouchFirstES = session.eventSeries.getExcludedEventSeriesS(proTouchES, obj.whiskerBarContactClassifiedESA.getExcludedCellArray(proTouchES.id), [], [-2 2],0);
		uRetTouchES = session.eventSeries.getExcludedEventSeriesS(retTouchES, obj.whiskerBarContactClassifiedESA.getExcludedCellArray(retTouchES.id), [], [-2 2],1);
		uRetTouchFirstES = session.eventSeries.getExcludedEventSeriesS(retTouchES, obj.whiskerBarContactClassifiedESA.getExcludedCellArray(retTouchES.id), [], [-2 2],0);

		% receptive field -- kappa [summaxabs , all touches]
		gpwcParams.roiId = 1; % irrelevant
	  gpwcParams.wcESA = touchES;
	  gpwcParams.wcESId = [];
		gpwcParams.stimTSA = 'whiskerCurvatureChangeTSA';
		gpwcParams.stimTSId = ['Curvature change for ' whiskerTags{w}];
		gpwcParams.stimMode = 'summaxabs';
%gpwcParams.stimMode = 'maxabs'
	  gpwcParams.trialEventNumber = [];
	  gpwcParams.stimTimeWindow = [-0.1 0.5];
		[touchKappa touchDff touchKappaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = uTouchES;
		[uTouchKappa uTouchDff uTouchKappaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = proTouchES;
		[proTouchKappa proTouchDff proTouchKappaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = retTouchES;
		[retTouchKappa retTouchDff retTouchKappaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = uProTouchES;
		[uProTouchKappa uProTouchDff uProTouchKappaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = uRetTouchES;
		[uRetTouchKappa uRetTouchDff uRetTouchKappaParams] = obj.getPeriWhiskerContactRF(gpwcParams);

	  gpwcParams.wcESA = touchES;
		gpwcParams.stimTSA = 'whiskerAngleTSA';
		gpwcParams.stimTSId = ['Angle for ' whiskerTags{w}];
		gpwcParams.stimMode = 'first';
	  gpwcParams.trialEventNumber =1; 
	  gpwcParams.stimTimeWindow = [-0.1 0.5];
		[touchTheta touchDff touchThetaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = uTouchES;
		[uTouchTheta uTouchDff uTouchThetaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = proTouchES;
		[proTouchTheta proTouchDff proTouchThetaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = retTouchES;
		[retTouchTheta retTouchDff retTouchThetaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = uProTouchES;
		[uProTouchTheta uProTouchDff uProTouchThetaParams] = obj.getPeriWhiskerContactRF(gpwcParams);
	  gpwcParams.wcESA = uRetTouchES;
		[uRetTouchTheta uRetTouchDff uRetTouchThetaParams] = obj.getPeriWhiskerContactRF(gpwcParams);

		% store          1         2          3          4         5               6
		touches{w} = {touchES, uTouchES, proTouchES, retTouchES, uProTouchES, uRetTouchES};
		firstTouches{w} = {touchFirstES, uTouchFirstES, proTouchFirstES, retTouchFirstES, uProTouchFirstES, uRetTouchFirstES};
		rfKappa{w} = {touchKappa, touchDff, touchKappaParams, uTouchKappa, uTouchDff, uTouchKappaParams, proTouchKappa, proTouchDff, ...
		  proTouchKappaParams, retTouchKappa, retTouchDff, retTouchKappaParams, uProTouchKappa, uProTouchDff, uProTouchKappaParams, ...
			uRetTouchKappa, uRetTouchDff, uRetTouchKappaParams};
		rfTheta{w} = {touchTheta, touchDff, touchThetaParams, uTouchTheta, uTouchDff, uTouchThetaParams, proTouchTheta, proTouchDff, ...
		  proTouchThetaParams, retTouchTheta, retTouchDff, retTouchThetaParams, uProTouchTheta, uProTouchDff, uProTouchThetaParams, ...
			uRetTouchTheta, uRetTouchDff, uRetTouchThetaParams};

		% compile event counts 
		touchCount(w,1) = length(touchES.getStartTimes());
		touchCount(w,2) = length(uTouchES.getStartTimes());
		touchCount(w,3) = length(proTouchES.getStartTimes());
		touchCount(w,4) = length(retTouchES.getStartTimes());
		touchCount(w,5) = length(uProTouchES.getStartTimes());
		touchCount(w,6) = length(uRetTouchES.getStartTimes());

		firstTouchCount(w,1) = length(touchFirstES.getStartTimes());
		firstTouchCount(w,2) = length(uTouchFirstES.getStartTimes());
		firstTouchCount(w,3) = length(proTouchFirstES.getStartTimes());
		firstTouchCount(w,4) = length(retTouchFirstES.getStartTimes());
		firstTouchCount(w,5) = length(uProTouchFirstES.getStartTimes());
		firstTouchCount(w,6) = length(uRetTouchFirstES.getStartTimes());
	end

  wsData.whiskerTags = whiskerTags;
	wsData.touchCount = touchCount;
	wsData.firstTouchCount = firstTouchCount;
	wsData.touches = touches;
	wsData.firstTouches =firstTouches;
	wsData.rfKappa = rfKappa;
	wsData.rfTheta = rfTheta;
