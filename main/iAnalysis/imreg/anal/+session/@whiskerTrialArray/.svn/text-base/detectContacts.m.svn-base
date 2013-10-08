%
% Performs contact detection as well as pro/retraction classification.
%
% USAGE:
%
%   obj.detectContacts(params)
%
% ARGUMENTS:
%
%   params: a structure having the following (optional) fields:
%     params.inReachSteps: what steps of session.whiskerTrial.detectContacts to
%                          use for epoch when bar is *definitely* in reach
%     params.transitionSteps: what steps of session.whiskerTrial.detectContacts 
%                             to use during the bar movement period
%     params.distanceThreshold: in fraction of bar radius, what range to use as
%                               threshold to induce contact -- [0.7 1.1] dflt
%     params.dToBarBoundsAllowed: in fraction of bar radius ; after a looser
%                                 allowance of contacts from e.g., above, this 
%                                 is used to prune
%
% (C) March 2012 S Peron
%
function obj = detectContacts (obj, params)

  %% --- input processing
 
  % default params
	inReachSteps = [1 1 1];
	transitionSteps = [0 1 1];
	distanceThreshold = [0.5 1.2];
	dToBarBoundsAllowed = [0.5 1.4];

  % params 
  if (nargin >= 2 && isstruct(params))
	  pfields = fieldnames(params);
	  for p=1:length(pfields)
		  eval([pfields{p} ' = params.' pfields{p} ';']);
		end
	end

	% build detectContactParams structure 
	detectContactParams.inReachSteps = inReachSteps;
	detectContactParams.transitionSteps = transitionSteps;
	detectContactParams.distanceThreshold = distanceThreshold;
	detectContactParams.dToBarBoundsAllowed = dToBarBoundsAllowed;

	detectContactParams.barRadius = obj.barRadius;
  detectContactParams.trialIds = obj.whiskerCurvatureTSA.trialIndices;

  %% --- contact detection call
	whiskerContacts = session.whiskerTrial.detectContacts(obj.whiskerCurvatureChangeTSA.valueMatrix', ...
		 obj.whiskerDistanceToBarTSA.valueMatrix', obj.whiskerBarInReachTS.value', detectContactParams);

  %% --- build basal contact output

  % whisker loop
	timeVec = obj.time;
	trialVec = obj.trialIndices;
	for w=1:size(whiskerContacts,2)
		% now construct new eventSeries
		contactES{w} = getContactES(whiskerContacts(:,w), timeVec, trialVec, w,['Contacts for ' char(obj.whiskerTags{w})],[1 0 0] );
	end

	% generate the ESA
	obj.whiskerBarContactESA = session.eventSeriesArray(contactES);

	%% --- directional contact
	obj.whiskerBarContactClassifiedESA = session.eventSeriesArray({});

  % parameters for directional contact correction
 	fillSkipSize = 1;
	minTouchDuration = 2; 
  if (isstruct(obj.params) && isfield(obj.params, 'detectContactsParams') && isstruct(obj.params.detectContactsParams))
    if (isfield(obj.params.detectContactsParams, 'fillSkipSize')) ; fillSkipSize = obj.params.detectContactsParams.fillSkipSize; end
    if (isfield(obj.params.detectContactsParams, 'minTouchDuration')) ; minTouchDuration = obj.params.detectContactsParams.minTouchDuration; end
  end
  
	% loop over whiskers
	xa = obj.barCenterTSA.getTimeSeriesByIdx(1).value;
	ya = obj.barCenterTSA.getTimeSeriesByIdx(2).value;
	for w=1:length(obj.whiskerBarContactESA)
		% build a vector w/ 1 during contact epochs
		contactTS = obj.whiskerBarContactESA.esa{w}.deriveTimeSeries(obj.time, obj.timeUnit, [0 1]);
		contactVec = contactTS.value;

		% compute angle bw pole-follicle and contact point-follcile lines (theta)
		xb = obj.whiskerTrackPolyIntersectXYTSA.getTimeSeriesByIdx(w*2 - 1).value;
		yb = obj.whiskerTrackPolyIntersectXYTSA.getTimeSeriesByIdx(w*2).value;
		xc = obj.whiskerPointNearestBarXYTSA.getTimeSeriesByIdx(w*2 - 1).value;
		yc = obj.whiskerPointNearestBarXYTSA.getTimeSeriesByIdx(w*2).value;
		m2 = (yb-yc)./(xb-xc);
		m1 = (yb-ya)./(xb-xa);
		theta=atand((m2-m1)./(1+m2.*m1));

		% build pro & ret contact vectors
		proIdx = intersect(find(contactVec), find(theta < 0));
		proVec = 0*contactVec;
		proVec(proIdx) = 1;
		retIdx = intersect(find(contactVec), find(theta > 0));
		retVec = 0*contactVec;
		retVec(retIdx) = 1;
    
    % repair ...
    kappas = obj.whiskerCurvatureChangeTSA.getTimeSeriesByIdx(w).value;
    proVec(find(isnan(kappas))) = 0;
    retVec(find(isnan(kappas))) = 0;
    proVec = session.whiskerTrial.detectContactsCleanupS(proVec, kappas, fillSkipSize, minTouchDuration);
    retVec = session.whiskerTrial.detectContactsCleanupS(retVec, kappas, fillSkipSize, minTouchDuration);

		% build contact# vectors
		proVec = number_from_binary(proVec);
		retVec = number_from_binary(retVec);
%		proVec = computeContactNumber(proVec);
%		retVec = computeContactNumber(retVec);

		% and finally ESs
		protractES = getContactES(proVec, timeVec, trialVec, 100+w,['Protraction contacts for ' char(obj.whiskerTags{w})],[0 1 1] );
		retractES = getContactES(retVec, timeVec, trialVec, 200+w,['Retraction contacts for ' char(obj.whiskerTags{w})],[1 0 1] );

    % pesky duplicatse ... should not be occuring so warn the user
		dupeIdx = find(diff(protractES.eventTimes) == 0);
		for d=1:length(dupeIdx)
			disp('detectContacts::protraction duplicate detected, which is unusual and means your detect contact parameters were bad.');
		  nIdx = min(find(obj.time > protractES.eventTimes(dupeIdx(d))));
			protractES.eventTimes(dupeIdx(d)) = obj.time(nIdx);
			protractES.eventTrials(dupeIdx(d)) = obj.trialIndices(nIdx);
		end
		dupeIdx = find(diff(retractES.eventTimes) == 0);
		for d=1:length(dupeIdx)
			disp('detectContacts::retraction duplicate detected, which is unusual and means your detect contact parameters were bad.');
		  nIdx = min(find(obj.time > retractES.eventTimes(dupeIdx(d))));
			retractES.eventTimes(dupeIdx(d)) = obj.time(nIdx);
			retractES.eventTrials(dupeIdx(d)) = obj.trialIndices(nIdx);
		end

		% add ES's
		obj.whiskerBarContactClassifiedESA.addEventSeriesToArray(protractES);
		obj.whiskerBarContactClassifiedESA.addEventSeriesToArray(retractES);
	end

  
%
% Returns a contact ES given a whiskerContacts vector where 0 is no contact and
%  all other #s are contact indices.  timeVec and trialVec are same size as 
%  the whiskerContacts vecrtor and indicate trial, time for each index.
%  id & idStr will be the ID and string for the ES.
%
function contactES = getContactES(whiskerContacts, timeVec, trialVec, id, idStr, EScolor)
		% gather start & end of each contact; find corresponding eventtimes, 
		%  trials and populate an event series / whisker
		uc = unique(whiskerContacts);
		eventTimes = nan*ones(1,2*length(uc));
		eventTrials = nan*ones(1,2*length(uc));
    uc = setdiff(uc,0);

		for c=1:length(uc)
		  si = min(find(whiskerContacts == uc(c)));
		  ei = max(find(whiskerContacts == uc(c)));
		  startTime = timeVec(si);
			startTrial = trialVec(si);
		  endTime = timeVec(ei);
		  endTrial = trialVec(ei);

      if (startTime == endTime) ; continue ; end % same time? this is not acceptable
			if (startTrial ~= endTrial) ; continue ;end % different trial? this is also not valid

      sei = 2*(c-1) + 1;

			eventTimes(sei:sei+1) = [startTime endTime];
			eventTrials(sei:sei+1) = [startTrial endTrial];
		end
		eventTimes = eventTimes(find(~isnan(eventTimes)));
		eventTrials = eventTrials(find(~isnan(eventTimes)));

		% now construct new eventSeries
	  contactES = session.eventSeries(eventTimes, eventTrials, 1, id, idStr, 0, '', '', EScolor,  2);
    
%
% to convert from a 000100101000 matrix to 000100203000 where the # is the 
%  contact number.  detectContacts does this, but we need it for pro/ret.
%
function whiskerContacts = computeContactNumber(whiskerContacts)
	% rebinarize
	whiskerContacts(find(whiskerContacts > 0) ) = 1;

  % loop thru
	for w=1:size(whiskerContacts,2)
	  contactVec = whiskerContacts(:,w);
		
		nc = 0;
		val = find(contactVec > 0);
		if (length(val) > 0)
		  contacting = 0;
			for c=1:length(contactVec)
			  if (~contacting && contactVec(c)) % establish contact
				  contacting = 1;
					nc = nc+1;
				  whiskerContacts(c,w) = nc;
				elseif (contacting & ~contactVec(c) ) % break contact -- but not if it is a place w/o whisker 
				  contacting = 0;
				elseif (contacting)
				  whiskerContacts(c,w) = nc;
				end
			end
		end
	end
