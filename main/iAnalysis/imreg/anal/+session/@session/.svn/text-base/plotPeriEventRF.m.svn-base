%
% SP Jan 2011
%
% Plots a stimulus versus response, drawn from timeSeries objects, around 
%  event occurences drawn from an eventSeries object.  This is a generic wrapper
%  from which things like plotting delta kappa versus dF/F should be made.
%
% USAGE:
% 
%   obj.plotPeriEventRF(stimTSA, stimTSId, stimTimeWindow, stimMode, 
%                       respTSA, respTSId, respTimeWindow, respMode,
%                       ESA, ESId, ESColor, trialEventNumber, xES, xESTimeWindow, 
%                       excludeOthers, plotRFParams, axHandle, 
%                       stimUseValueDuringEventOnly, respUseValueDuringEventOnly,
%    									  labeledESA, labeledESId, labeledESColor, labeledESOverlapWindow)
%                       
%    stimTSA: timeSeriesArray from which stimulus is drawn
%    stimTSId: ID of stimTSA timeSeries to use (can be # or string).  If you 
%              want a differnt TSId (resp or stim) for EACH ESId, the length
%              of this vector/cell array should be length(ESId).
%    stimTimeWindow: from when, aroudn events in ES, should stimulus data be
%                    drawn?  In units of seconds.  0 is event time, so [0 2]
%                    would mean from 0 to 2000 ms after event.
%    stimMode: what value to pull from the time window?  permitted values are
%              specified in session.timeSeries.getSingleValueAroundEvents
%              (e.g., 'mean', 'meanabs', 'median' ,'max', 'min', 'maxabs', 'sum', 
%               'sumabs')
% 
%    respTSA,respTSId, respTimeWindow, respMode: same as stimXXX but for
%              the response ("y axis")
%  
%    ESA: the event series array which determines data selection - can be an
%         actual eventSeriesArray or a cell array of eventSeries objects.
%    ESId: which event serie(s) within ES to do?  will make plot per ES.  If
%          ESA is an eventSeriesArray, this can be a set of numbers, in which case
%          getEventSeriesById is called or a cell array of string in which case
%          getEventSeriesByIdStr is called.  If ESA is a cell array of
%          eventSeries, this must be numbers.
%    ESColor: either blank, in which case plotRFParams dictates color, or a
%             matrix of size (n,3) where n is length(ESId).  plotRFParams.color 
%             will be set to ESColor(n,3) for that ES.
%    trialEventNumber: which event (in a trial) to use; default is [] which means 
%                      ALL.  Inf means last, and max means having largest stimTSA
%                      amplitude.
%    xES: (optional -- [] if not used) - cell array of time series to exclude
%         if an event in ES overlaps with xES
%    xESTimeWindow: how big the overlap window is to apply exclusion ; in 
%                   seconds
%    excludeOthers: if set to 1, in addition to xES, will exclude members of ESA
%                   aside from ESId(i) when plotting ESId(i)
%
%    plotRFParams: plotRFParams for session.plotRF
%    axHandle: axis handle for plot    
%
%    stim/respUseValueDuringEventOnly: for type 2 events, you can restrict the 
%                                      values during your time window that get 
%                                      sampled to those that occur during the 
%                                      event.
% 
%    labeledESA: eventSeriesArray object, or cell array of trial #s. If an eventSeries from ESA intersects 
%                with any of the labeledESs (via intersectEventsS) OR has a trial # that is 
%                passed, in addition to the regular x marker, it will be 
%                circled with labeledESColor.
%    labeledESId: cell array of strings OR Ids within the returend ESA to use
%                 If labeledESA is trial list cell array, leave blank.
%    labeledESColor: (n x 3) matrix with colors for markers
%    labeledESOverlapWindow: if lalbeledESA is indeed an eventSeriesArray, this 
%                            the window (in seconds) applied to both labeledESA
%                            and ESA within the intersectEventsS call
%
% EXAMPLE: plot dFF for ROI 42 RF for whisker 1 based off whisker 1 contacts
%
%   s.plotPeriEventRF(s.whiskerCurvatureChangeTSA, 1, [-0.1 0.5], 'sumabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactESA, ...
%                     1);
%   
%   Now let's exclude all other whisker contacts:
%
%   s.plotPeriEventRF(s.whiskerCurvatureChangeTSA, 1, [-0.1 0.5], 'sumabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactESA, ...
%                     1, [], [], s.whiskerBarContactESA.getExcludedCellArray(3), [-1 1]);
%
%   Let's restrict to protractions only, but exclude ALL other contacts
% 
%   s.plotPeriEventRF(s.whiskerCurvatureChangeTSA, 1, [-0.1 0.5], 'sumabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactClassifiedESA, ...
%                     101, [], [], s.whiskerBarContactESA.getExcludedCellArray(3), [-1 1]);
%
%   And now consider delta kappa ONLY during epoch where contact actually is made for first contact,
%    without excluding other whisker contacts.
%
%   s.plotPeriEventRF(s.whiskerCurvatureChangeTSA, 1, [-0.05 2], 'sumabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactClassifiedESA, ...
%                     101, [], 1, [], [], [], [], [], 1);
%
%   Let's only look at the strongest contact per trial, again measuring dKappa ONLY during contact:
%
%   s.plotPeriEventRF(s.whiskerCurvatureChangeTSA, 1, [-0.05 2], 'sumabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactClassifiedESA, ...
%                     101, [], 'max', [], [], [], [], [], 1);
%
%   And now let's consider ALL contact dKappa but ONLY during contact epoch:
%
%   s.plotPeriEventRF(s.whiskerCurvatureChangeTSA, 1, [-0.05 2], 'sumabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactClassifiedESA, ...
%                     101, [], [], [], [], [], [], [], 1);
%
%   Let's consider mean theta during contact:
%
%   s.plotPeriEventRF(s.whiskerAngleTSA, 1, [-0.05 2], 'meanabs', ...
%                     s.caTSA.dffTimeSeriesArray, 42, [0 2], 'max', s.whiskerBarContactClassifiedESA, ...
%                     101, [], [], [], [], [], [], [], 1);
%
function plotPeriEventRF(obj, stimTSA, stimTSId, stimTimeWindow, stimMode, ...
                         respTSA, respTSId, respTimeWindow, respMode, ESA, ...
												 ESId, ESColor, trialEventNumber, xES,  xESTimeWindow, ...
												 excludeOthers, plotRFParams, axHandle, stimUseValueDuringEventOnly, respUseValueDuringEventOnly, ...
												 labeledESA, labeledESId, labeledESColor,  labeledESOverlapWindow)
	% --- process user input
	if (nargin < 11)
	  help('session.session.plotPeriEventRF');
	  disp('plotPeriEventRF: parameters 1-10 are NOT optional.');
		return;
	end

	% process inputs
  if (nargin < 12) ; ESColor = []; end
	if (nargin < 13) ; trialEventNumber = []; end
	if (nargin < 14) ; xES = []; end
	if (nargin < 15) ; xESTimeWindow = []; end
	if (nargin < 16 || length(excludeOthers) == 0) ; excludeOthers = 0; end
	if (nargin < 17 || length(plotRFParams) == 0) ; plotRFParams.plotMethod = 'raw'; end
	if (nargin < 18) ; axHandle = []; end
	if (nargin < 19 || length(stimUseValueDuringEventOnly) == 0) ; stimUseValueDuringEventOnly = 0; end
	if (nargin < 20 || length(respUseValueDuringEventOnly) == 0) ; respUseValueDuringEventOnly = 0; end
	if (nargin < 21 || length(labeledESA) == 0) ; labeledESA = []; end
	if (nargin < 22 || length(labeledESId) == 0) ; labeledESId = []; end
	if (nargin < 23 || length(labeledESColor) == 0) ; labeledESColor = []; end
	if (nargin < 24 || length(labeledESOverlapWindow) == 0) ; labeledESOverlapWindow= [0 0]; end

	% --- sanity check user input

	% make sure time windows are not singular
	if (length(stimTimeWindow) == 1)
	  dtStim = mode(diff(stimTSA.time));
		dtStim = session.timeSeries.convertTime(dtStim, stimTSA.timeUnit, 2);
		stimTimeWindow = stimTimeWindow + 2*[-1*dtStim dtStim];
	end
	if (length(respTimeWindow) == 1)
	  dtResp = mode(diff(respTSA.time));
		dtResp = session.timeSeries.convertTime(dtResp, respTSA.timeUnit, 2);
		respTimeWindow = respTimeWindow + 2*[-1*dtResp dtResp];
	end

	if (length(xESTimeWindow) == 0 & (excludeOthers | length(xES) > 0))
	  disp('plotPeriEventRF::warning - you requested exclusion but did not specify an exclusion time window; will not exclude!');
	end
 
  % ESId
	if (~isnumeric(ESId) & ~iscell(ESId)) ; ESId = {ESId} ; end

	% labeledESId
	if (~isnumeric(labeledESId) & ~iscell(labeledESId)) ; labeledESId = {labeledESId} ; end

  % figure
	if (length(axHandle) == 0)
	  figure;
		N = ceil(sqrt(length(ESId)));
		for a=1:length(ESId)
		  axHandle(a) = subplot(N,N,a);
		end
	end

	% xES
	if (~iscell(xES) & length(xES) > 0) ; xES = {xES}; end
	oxES = xES;

	% stim and respTSIds
	if (length(stimTSId) == 0 | length(respTSId) == 0)
	  disp('plotPeriEventRF::must specify response and stimulus TS IDs');
		return;
	end

  % --- pull some stuff (response and stimulus TSA)
	if (length(respTSId) == 1 | ~iscell(respTSId))
		if (isnumeric(respTSId))
			rTS = respTSA.getTimeSeriesById(respTSId);
		else
			rTS = respTSA.getTimeSeriesByIdStr(respTSId,1,1);
		end
	end
	if (length(stimTSId) == 1 | ~iscell(stimTSId))
		if (isnumeric(stimTSId))
			sTS = stimTSA.getTimeSeriesById(stimTSId);
		else
			sTS = stimTSA.getTimeSeriesByIdStr(stimTSId, 1,1);
		end
	end

  % --- ESA loop
	for e=1:length(ESId)
	  if (isobject(ESA))
		  if (isnumeric(ESId))
    	  es = ESA.getEventSeriesById(ESId(e));
			elseif (iscell(ESId))
    	  es = ESA.getEventSeriesByIdStr(ESId{e});
			else
    	  es = ESA.getEventSeriesByIdStr(ESId);
			end
		else
		  es = ESA{ESId(e)};
    end
    
    % safe!
    if (~isobject(es)) ; continue ; end

		% pull stim/resp TSA if they are one-per-ESId
		if (length(ESId) > 1)
			if (length(respTSId) == length(ESId))
				if (isnumeric(respTSId))
					rTS = respTSA.getTimeSeriesById(respTSId(e));
				else
					rTS = respTSA.getTimeSeriesByIdStr(respTSId{e},1,1);
				end
			end
			if (length(stimTSId) == length(ESId))
				if (isnumeric(stimTSId))
					sTS = stimTSA.getTimeSeriesById(stimTSId(e));
				else
					sTS = stimTSA.getTimeSeriesByIdStr(stimTSId{e}, 1,1);
				end
			end
		end

		% in case type 2, restrict to start and end times
		sTrials = es.getStartTrials();
		sTimes = es.getStartTimes();
		eTimes = es.getEndTimes();

    % add others to xes?
		if (excludeOthers)
		  addXES = ESA.getExcludedCellArray(es.id);
			if (length(addXES) > 0)
			  if (length(oxES) > 0)
				  xES = oxES;
					xES(length(xES)+1:length(xES)+length(addXES)) = addXES;
				else
				  xES = addXES;
				end
			end
		end
 
		% restrict to particular event ?  
		if (isstr(trialEventNumber) && strcmp(trialEventNumber,'max')) % STRONGEST contact per trial, ABSOLUTE VALUE
		  
		  uet = unique(sTrials);

			strongest = 0*(1:length(uet));
		  for u=1:length(uet)
			  eti = find(sTrials == uet(u));
				edk = 0*eti;
        for ei=1:length(eti)
				  stidx = find(sTS.time == sTimes(eti(ei)));  
					if (es.type == 2) % grab range
            eidx = find(sTS.time == eTimes(eti(ei)));
            edk(ei) = max(abs(sTS.value(stidx:eidx)));
					else % grab single value
						edk(ei) = abs(sTS.value(stidx));
					end
				end
				[maxVal idx] = max(edk);
        strongest(u) = eti(idx);
      end
      strongest = strongest(find(strongest > 0));

			% build the new ES
      if (length(strongest) > 0) 
			  nes = es.restrictedCopy(sTimes(strongest));
			  es = nes;
      else
        es = [];
      end
		elseif (trialEventNumber > 0) % contact NUMBER
      es = es.getESBasedOnNthEventByTrial(trialEventNumber);
    end
    
    % has ES been blanked?
    if (~isobject(es)) ; continue ; end
      
		% setup generic pointers
	  sTSp = sTS;
		rTSp = rTS;

		% if necessary, restrict rTS or sTS to period where event is active by nan'ing
		%  other timepoints
		if (stimUseValueDuringEventOnly | respUseValueDuringEventOnly)
		  if (stimUseValueDuringEventOnly)
				ests = es.deriveTimeSeries(sTS.time, sTS.timeUnit, [nan 1]);
				sTSp = sTS.copy();
				sTSp.value = sTSp.value.*ests.value;
			end
 	    if (respUseValueDuringEventOnly)
				ests = es.deriveTimeSeries(rTS.time, rTS.timeUnit, [nan 1]);
				rTSp = rTS.copy();
				rTSp.value = rTSp.value.*ests.value;
			end
		end

		% now grab the receptive feidl data
	  [st re sidx nidx evIdx] = session.timeSeries.computeReceptiveFieldAroundEvents (sTSp, stimMode, rTSp, respMode, ...
		                    es, stimTimeWindow, respTimeWindow, 2,0,xES,xESTimeWindow);

%    disp([obj.dateStr ' ' sTS.idStr ' ' rTS.idStr ' ' es.idStr ' score: ' num2str( length(sidx)/(length(sidx)+length(nidx)))]);
		if (length(st) > 0)
			% --- compute some statistics

			% correlation
			[abscorr pval] = corr(abs(st)',re','type','Spearman');

			% fraction in "RF" index
  		if (stimUseValueDuringEventOnly | respUseValueDuringEventOnly) % recompute sidx/nidx sizes
		    baseStim = nanmedian(sTS.value);
				threshStim = baseStim + 1.4826*[-2*mad(sTS.value) 2*mad(sTS.value)];

				baseResp = nanmedian(rTS.value);
				threshResp = baseResp + 1.4826*[-2*mad(rTS.value) 2*mad(rTS.value)];

				% signal region means you are 2 MADs away from mode
				noiseStim = find(st > threshStim(1) & st < threshStim(2));
				noiseResp = find(re> threshResp(1) & re < threshResp(2));
				nidx = union(noiseStim, noiseResp);
				sidx = setdiff(1:length(st), nidx);
      end

			% AUC of response when stimulus is partitioned into top, bottom 25th
			if (length(st) > 1 & length(re) > 1)
			  [irr sidx] = sort(st);
				midx = floor(length(sidx)/4);
				iA = sidx(1:midx);
				iB = sidx(3*midx:end);

        AUC = roc_area_from_distro(re(iA), re(iB));
			  disp([obj.dateStr ' ' sTS.idStr ' ' rTS.idStr ' ' es.idStr ' AUC: ' num2str(AUC)]);
			end


			disp([obj.dateStr ' ' sTS.idStr ' ' rTS.idStr ' ' es.idStr ' cor: ' num2str(abscorr) ' p: ' num2str(pval) ' frac: ' num2str( length(sidx)/(length(sidx)+length(nidx))) ]);

			% --- plot
			if (length(ESColor) > 0)
			  plotRFParams.color = ESColor(e,:);
			end
			session.session.plotRF(st, re, [], plotRFParams, [1 0 0], axHandle(e));

			% labeledESA and tittle 
			subplot(axHandle(e)) ; 

			% labeledESA
			if (length(labeledESA) > 0 & length(evIdx) > 0)
			  % trial # list
				if (iscell(labeledESA))
				  evTrials = es.eventTrials(evIdx);
          for l=1:length(labeledESA) % loop over all
					  intersectIdx = find(ismember(evTrials, labeledESA{l}));
						if (length(intersectIdx) > 0)
              %plot(st(intersectIdx), re(intersectIdx), 'o', 'Color', labeledESColor(l,:));
              plot(st(intersectIdx), re(intersectIdx), 'o', 'Color', labeledESColor(l,:), 'MarkerSize', 7, 'LineWidth', 2);
						end
					end
				% actual ESA
				elseif(isobject(labeledESA))
				  % loop only over labeledESId
					for l=1:length(labeledESId)
					  if (iscell(labeledESId))
		    			lES = labeledESA.getEventSeriesByIdStr(labeledESId{l});
    				else
					    lES = labeledESA.getEventSeriesById(labeledESId(l));
						end

						if (length(lES.eventTimes) == 0) ; continue ; end % blank skip

						% get intersection of this and es
						[eidx lidx] = session.eventSeries.intersectEventsS(es, lES, labeledESOverlapWindow,labeledESOverlapWindow);

						% color appropriate events
						intersectIdx = find(ismember(evIdx,eidx));
						if (length(intersectIdx) > 0)
              plot(st(intersectIdx), re(intersectIdx), 'o', 'Color', labeledESColor(l,:), 'MarkerSize', 7, 'LineWidth', 2);
						end
					end
				end
			end
			title([rTS.idStr ' vs. ' sTS.idStr]);
		end
	end
