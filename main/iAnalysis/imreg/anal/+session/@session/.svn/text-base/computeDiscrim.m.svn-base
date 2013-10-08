%
% SP Feb 2011
%
% Computes discriminability for a given set of trial types.  The method dictates
%  how computation is done.  Generally, two types of stimuli are possible,
%  based on trial class.  aType, for convenience is hit/miss usually.  This will
%  tell you how well a given responder -- observer -- can discriminate the
%  two classes using various methods.  Note that aType is treated as the 
%  signal response given signal stimulus condition for ROC curve computation
%  while bType is signal-given-noise.
%
%  If the method is non-pool (i.e., 1 value per roi), it will also populate
%  s.discrimIndex.
%
%  USAGE:
%
%    discrim = s.computeDiscrim (params)
%
%  PARAMS:
%
%    discrim: discrimination score; 1 per timeSeries in responseTSA
%
%    params structure, consisting of fields:
%
%      method: 'psth' - use difference among PSTHs for trial classes, using
%                       Nicolelis distance metric.  Uses responseTSA.  This will
%                       return a value for each element in responseTSA,
%                       meaning that they are treated individually.  Uses
%                       continuous PSTH.  One per ROI.
%              'psth_pool' - use difference among PSTHs, but line up the 
%                            individual timeSeries one after the other 
%                            pooling across timeSeries for each trial.
%                            This tells you if the population as a whole,
%                            with each timeSEries representing, e.g., one 
%                            neuron, can discriminate (and how well).
%              'evcount' - use difference in event count in responseESA.
%                          Again, treats each eventSeries in ESA as a 
%                          separate observer and returns its score.
%              'evcount_pool' - as with above, but pool eventSeries to
%                               produce a SINGLE discrimination score. 
%                               Specify the indices to pool with 
%                               poolIds parameter ; default is all,
%                               which may produce poor results esp. if
%                               different event series give opposite signals.
%      statistic: 'dprime' - difference in means divided by pooled SD
%                 'roc' - area under ROC curve ("AUC")
%      responseTSA: pointer to TSA object with cell resposnes; default is 
%                   caTSA.dffTimeSeriesArray
%      responseESA: pointer to ESA object with cell responses; default is
%                   caTSA.caPeakEventSeriesArray
%      responseTimeWindow: in seconds, relative to trial start; so [0 2] will
%                          include the first 2 seconds of a trial.
%      aType: by default, uses trialTypeStr 'Hit'&'Miss', but you may want 
%               to restrict only to Hit trials.
%      bType: by default, uses trialTypeStr 'CR' & 'FA'
%      posOnly: if set to 1, discrim < 0.5 is set to 1-discrim
%      poolIds: ids, in terms of responseXSA.ids, of who you want to include
%               in a pool-method calculation
%
%  EXAMPLE:
%
%    params.method = 'psth';
%    params.statistic = 'roc';
%    params.responseTSA = s.caTSA.caPeakTimeSeriesArray;
%    params.responseTimeWindow = [1 2.5];
% 	 params.aType = [find(strcmp(s.trialTypeStr, 'Hit')) find(strcmp(s.trialTypeStr, 'Miss'))] ;
%    params.bType = [find(strcmp(s.trialTypeStr, 'FA')) find(strcmp(s.trialTypeStr, 'CR'))]; 
% 
%    discrim = s.computeDiscrim(params);
%
%    figure; 
%    ax=axes; 
%    s.plotColorRois([],[],[],[],discrim,[0.5 1],ax,1);
%
%  This will compute ROC area for all neurons using calcium peak with no decay
%   time series, with hit & miss constituting "signal" and false alarm and
%   correct rejection trials constituting "noise" stimulus.  Only events between
%   the 1000 and 2500 ms after trial onset are considered.  The results are then
%   plotted as a colorscale of ROIs.
%
function discrim = computeDiscrim(obj, params)
  discrim = [];

  % --- process inputs -- default values
	method = 'psth';
	statistic = 'roc';
	responseTSA = obj.caTSA.dffTimeSeriesArray;
	responseESA = obj.caTSA.caPeakEventSeriesArray;
	aType = [find(strcmp(obj.trialTypeStr, 'Hit')) find(strcmp(obj.trialTypeStr, 'Miss'))] ; % s
	bType = [find(strcmp(obj.trialTypeStr, 'FA')) find(strcmp(obj.trialTypeStr, 'CR'))]; % n
  responseTimeWindow = [1 2.5];
	posOnly = 0;
	poolIds = [];
  
  % grab params
	if (nargin >= 2 && isstruct(params))
	  if(isfield(params,'responseTimeWindow')) ; responseTimeWindow = params.responseTimeWindow; end
	  if(isfield(params,'method')) ; method = params.method; end
	  if(isfield(params,'statistic')) ; statistic = params.statistic; end
	  if(isfield(params,'bType')) ; bType = params.bType; end
	  if(isfield(params,'aType')) ; aType = params.aType; end
	  if(isfield(params,'posOnly')) ; posOnly = params.posOnly; end
	  if(isfield(params,'responseTSA')) ; responseTSA = params.responseTSA; end
	  if(isfield(params,'responseESA')) ; responseESA = params.responseESA; end
	  if(isfield(params,'poolIds')) ; poolIds = params.poolIds; end
	end
	method = lower (method);

  % method-specific default changse
  switch method
	end

  % get type #s ; trials of each type
	aTrials = [];
	for a=1:length(aType) ; aTrials = [aTrials obj.trialIds(find (obj.trialTypeMat(aType(a),:)))]; end
	bTrials = [];
	for b=1:length(bType) ; bTrials = [bTrials obj.trialIds(find (obj.trialTypeMat(bType(b),:)))]; end

	% restrict by valid trials(!)
	aTrials = intersect(aTrials, obj.validTrialIds);
	bTrials = intersect(bTrials, obj.validTrialIds);

	% --- gather the distributions (DVa, DVb) ; cells if not pooled
	switch method
		case 'psth'
			% loop over responseTSA
			for r=1:length(responseTSA)
				% get PSTHs by trial type from resposneTSA
				[timeMat psth] = responseTSA.getTrialMatrix(responseTSA.ids(r), obj.trialIds);
        
				% pull out time vector, convert to seconds, and determine responseTimeWindow bounds
				if (r == 1) % don't do this more than once -- TSA means time vectors are same
					tmi = min(find(~isnan(sum(timeMat,2))));
					timeVec = timeMat(tmi,:) - min(timeMat(tmi,:));
					timeVec = session.timeSeries.convertTime(timeVec, responseTSA.timeUnit, 2);
					i1 = min(find(timeVec >= responseTimeWindow(1)));
					i2 = max(find(timeVec < responseTimeWindow(2)));
				end
				psth = psth(:,i1:i2);

        [DVa{r} DVb{r}] = nicolelis_distance(psth, aTrials, bTrials);
		  end

		case 'psth_pool'
			% loop over responseTSA and build the pooled matrix
			for r=1:length(responseTSA)
				% get PSTHs by trial type from resposneTSA
				[timeMat psth] = responseTSA.getTrialMatrix(responseTSA.ids(r), obj.trialIds);
        
				% pull out time vector, convert to seconds, and determine responseTimeWindow bounds
				if (r == 1) % don't do this more than once -- TSA means time vectors are same
					tmi = min(find(~isnan(sum(timeMat,2))));
					timeVec = timeMat(tmi,:) - min(timeMat(tmi,:));
					timeVec = session.timeSeries.convertTime(timeVec, responseTSA.timeUnit, 2);
					i1 = min(find(timeVec >= responseTimeWindow(1)));
					i2 = max(find(timeVec < responseTimeWindow(2)));
					ntp = i2-i1 + 1;

					psth_pooled = nan*ones(size(psth,1), ntp*length(responseTSA));
				end
				ip1 = (r-1)*ntp + 1;
				psth_pooled(:,ip1:ip1+ntp-1) = psth(:,i1:i2);
		  end
      [DVa DVb] = nicolelis_distance(psth_pooled, aTrials, bTrials);

		case 'evcount'
			% loop over responseESA
			for r=1:length(responseESA)
			  % grab eventSeries
				es = responseESA.esa{r};

        % apply  eventTimesRelTrialStart to restrict to time window
        etrts = session.timeSeries.convertTime(es.eventTimesRelTrialStart, es.timeUnit, 2);
        val = find (etrts >= responseTimeWindow(1) & etrts<= responseTimeWindow(2));
        eventTrials = es.eventTrials(val);

				% mean psths
        bMuN = length(find(ismember(eventTrials,bTrials)))/length(bTrials);
        aMuN = length(find(ismember(eventTrials,aTrials)))/length(aTrials);

				% now compute CR decision variable for individual trials ...
				DVbt = [];
				for t=1:length(bTrials)
					nThis = length(find(ismember(eventTrials,bTrials(t))));
				  DVbt(t) = nThis;
				end

				% now compute Hit decision variable for individual trials ...
				DVat =[];
				for t=1:length(aTrials)
					nThis = length(find(ismember(eventTrials,aTrials(t))));
				  DVat(t) = nThis;
				end

				DVa{r} = DVat;
				DVb{r} = DVbt;
		  end

		case 'evcount_pool'
		  if (length(poolIds) == 0) ; poolIds = responseESA.ids;  end
			% loop over responseESA and build the bpool
			eventTrials = [];
			for i=poolIds
        r = find(responseESA.ids == poolIds(i));

			  % grab eventSeries
				es = responseESA.esa{r};

        % apply  eventTimesRelTrialStart to restrict to time window
        etrts = session.timeSeries.convertTime(es.eventTimesRelTrialStart, es.timeUnit, 2);
        val = find (etrts >= responseTimeWindow(1) & etrts<= responseTimeWindow(2));
        eventTrials = [eventTrials es.eventTrials(val)];
			end

			% mean psths
			bMuN = length(find(ismember(eventTrials,bTrials)))/length(bTrials);
			aMuN = length(find(ismember(eventTrials,aTrials)))/length(aTrials);

			% now compute CR decision variable for individual trials ...
			DVb = [];
			for t=1:length(bTrials)
				nThis = length(find(ismember(eventTrials,bTrials(t))));
				DVb(t) = nThis;
			end

			% now compute Hit decision variable for individual trials ...
			DVa =[];
			for t=1:length(aTrials)
				nThis = length(find(ismember(eventTrials,aTrials(t))));
				DVa(t) = nThis;
			end

    otherwise
			disp('computeDiscrim::invalid method.');
	end

	% --- use appropriate statistic
	switch statistic
	  case 'roc'
		  if (iscell(DVa))
			  for r=1:length(DVa)
  				discrim(r) = roc_area_from_distro(DVa{r}, DVb{r});
				end
			else
  			discrim = roc_area_from_distro(DVa, DVb);
			end

		case 'dprime'
		  if (iscell(DVa))
			  for r=1:length(DVa)
					discrim(r) = dprime_from_distro(DVa{r}, DVb{r});
				end
			else
  			discrim = dprime_from_distro(DVa, DVb);
			end

    otherwise
			disp('computeDiscrim::invalid statistic.');
	end

	% --- postprocessing
	if (posOnly) 
	  discrim(find(discrim < 0.5)) = 1-discrim(find(discrim < 0.5));
	end

  % --- Save data to class if it is not pooled and 1 value / ROI
	obj.discrimIndex = discrim ;
