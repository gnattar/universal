%
% SP 2010 June
%
% Performs event detection on a provided timeSeriesArray using the options
%  specified in evdetOpts.  Returns an calciumEventSeriesArray that contains
%  peak time, start time, end time, and peak value.
%
% USAGE:
%
%   cesaObj = detectEventsFromDff(obj, evdetOpts)
%
% PARAMETERS:
%
%   obj: the object whose obj.dffTimeSeriesArray is used
%   evdetOpts: Series of options ; omitted fields are set to default* (omit
%              all to use default event detection configuration).  The 
%              following fields are included:
%  
%                roiIds: IDs of rois to perform operation on ; if blank/not
%                        passed, will simply do them all.
%
%                evdetMethod: 1: SD threshold; SD is derived via median absolute 
%                                deviation (MAD); and is used as threshold
%                             2: same as 1, but only + df/F are used for MAD
%                                computation
%                             3: diff(df/f) based; in this case, threshMult applies
%                                to the threshold that is applied to diff(df/f), while
%                                threshEndMult is used post-hoc on df/f to decide
%                                event end time (start IS the diff(df/f) ; peak is 
%                                max between start/end).  
%                             4: Joshua Vogelstein's deconvolution method from 
%                                "Fast nonnegative deconvolution for spike train 
%                                 inference from population calcium imaging."
%                                Vogelstein JT Et al., J Neurophysiol. 
%                                2010 Dec;104(6):3691-704. 
%                            [?: template based ; DO THIS with diff(df/f) first-pass, then template]
%
%              [a filter can be applied to the dff trace so as to, e.g., 
%               more aggressively high-pass the data]
%                filterType - 0: none 1*: savitsky-golay 2: median
%                filterSize - in seconds (10 default) 
%
%              [for threshold-based methods:]
%                threshMult: must be > this x thresh to be detected event (*4); 
%                threshStartMult: event starts point after last point < this 
%                                (*2)
%                threshEndMult: event ends point before first point < this 
%                                (*2)
%                minEvDur: minimum number of points between start and end to 
%                          count an event (*500 ; in miliseconds)
%
%              [method-specific]
%                madPool: 0: no pooling of MAD across ROIs [method 1,2,3]
%                         1: pool MAD and use mean as base for all
%                         2: use pooled MAD of inactive cells for active cells,
%                            as defined by getRoiActivityStatistics
%
%              [general]
%                minInterEvInterval: in ms ; minimal separation for events (*500)
%                minInterTimeUsed: 1: startTime *2: peakTime 3: endTime
%                eventBasedDffMethod: 0: don't make
%                                     1: use Vogelstein's raw trace (evdetMethod must b 4)
%                                     2: use thresholded Vogelstein (evdetMethod must b 4)
%                                     3: use convolution of *median* decay tau with peak values/times
%
%              [rise/decay time parameters]
%                riseDecayMethod: 0: skip this step (some methods take LONG time)
%                                 1: DH method where you look at first,last peak
%                                    and the time to start/end time, then get the
%                                    time at which half of peak-baselien is reached.
%                                    Convert to equivalent exponential time constant
%                                    by scaling with 1.4428.
%                        	       *2: exponential fit for decay, with goodness-of-fit;
%                                    (rise unasigned)
%                  
%
% RETURNS:
%
%   cesaObj: calciumEventSeriesArray with all the event info
%
%
function cesaObj = detectEventsFromDff(obj, evdetOpts)
  cesaObj = [];
	tsaObj = obj.dffTimeSeriesArray;

  % -- process evdetOpts   
	% defaults of passed arguments
	roiIds = []; % this means do all
	evdetMethod = 1; 
	threshMult = 4;
	threshStartMult = 0.5*threshMult;
	threshEndMult = 0.5*threshMult;
	minEvDur = 500; % in ms
	minInterEvInterval = 500; % in ms
	minInterTimeUsed = 2;
	madPool = 2;
	filterType = 2;
	filterSize = 10;
	riseDecayMethod = 2;
	eventBasedDffMethod = 0;

	% read args
	if (nargin == 0)
	  disp('calciumTimeSeriesArray.detectEventsFromDff::Must specify at least the TSA object to detect on.');
	 return;
	end
	if (nargin > 1 & isstruct(evdetOpts))
	  if (isfield(evdetOpts, 'roiIds')) ; roiIds = evdetOpts.roiIds; end
	  if (isfield(evdetOpts, 'evdetMethod')) ; evdetMethod = evdetOpts.evdetMethod; end
	  if (isfield(evdetOpts, 'filterType')) ; filterType = evdetOpts.filterType; end
	  if (isfield(evdetOpts, 'filterSize')) ; filterSize = evdetOpts.filterSize; end
	  if (isfield(evdetOpts, 'threshMult')) ; threshMult = evdetOpts.threshMult; end
	  if (isfield(evdetOpts, 'threshStartMult')) ; threshStartMult = evdetOpts.threshStartMult; end
	  if (isfield(evdetOpts, 'threshEndMult')); threshEndMult = evdetOpts.threshEndMult; end
	  if (isfield(evdetOpts, 'madPool')); madPool = evdetOpts.madPool; end
	  if (isfield(evdetOpts, 'minEvDur')); minEvDur = evdetOpts.minEvDur; end
	  if (isfield(evdetOpts, 'minInterEvInterval')) ; minInterEvInterval = evdetOpts.minInterEvInterval; end
	  if (isfield(evdetOpts, 'minInterTimeUsed')) ; minInterTimeUsed = evdetOpts.minInterTimeUsed; end
	  if (isfield(evdetOpts, 'riseDecayMethod')) ; riseDecayMethod = evdetOpts.riseDecayMethod; end
		if (isfield(evdetOpts, 'eventBasedDffMethod')) ; eventBasedDffMethod = evdetOpts.eventBasedDffMethod; end
  end

	% -- some methods require setting other variables to specific values -- do here
	%    also other sanity checks where various passed flags depend on others
	switch evdetMethod
	  case 4 % Vogelstein based detection -- bsaically turn some stuff off
		  filterType = 0; 
			if (minInterEvInterval > 0) ; minInterEvInterval = 0 ; end

			% check that other detector was ran prior
			if (length(obj.caPeakEventSeriesArray.esa) == 0)
				disp('detectEventsFromDff::to run Vogelstein detector, you must have run a simpler detector before to get approx. statistics.');
				return;
			end
	end

  % can only have event based dff method 1,2 if you do vogel
	if ((eventBasedDffMethod == 1 | eventBasedDffMethod == 2) && evdetMethod ~= 4)
	  disp('detectEventsFromDff::must have evdetMethod = 4 for your eventBasedDffMethod.');
		eventBasedDffMethod = 0;
	end

  % -- time-sensitive variables
	if (length(tsaObj.time) > 1)
	  dtMS = mode(diff(tsaObj.time)); % ASSUME in ms!!
    if(tsaObj.timeUnit ~= 1) ; disp('detectEventsFromDff::not in ms ; fix this.'); end
    filterSize = round(filterSize*1000/dtMS);
		minEvDur = round(minEvDur/dtMS);
	else
	  disp('detectEventsFromDff::warning - no time vector exists, and so filter window and event duration sizes are assumed to be in units of vector size.');
	end

	% -- pull & prefilter the valueMatrix

	% restrict to roiIds
	roiIdx = 1:size(tsaObj.valueMatrix,1);
	if (length(roiIds) > 0)
	  roiIdx = 0*roiIds;
	  for r=1:length(roiIds)
		  roiIdx(r) = find(obj.ids == roiIds(r));
		end
	else
	  roiIds = obj.ids;
	end

	valueMatrix = tsaObj.valueMatrix(roiIdx,:);
	valueMatrix(find(isnan(valueMatrix))) = 0;
	valueMatrix(find(isinf(valueMatrix))) = 0;

%%% FROM HERE ON, valueMatrix SHOULD BE RESTRICTED TO ONLY THE ROWS YOU CARE ABOUT

	% -- apply any filter to timeseries before proceeding
  switch filterType
	  case 0 % NONE
		  disp('detectEventsFromDff::skipping initial filter per request.');
	  case 1 % Savitsky-Golay
			for v=1:size(valueMatrix,1)
				tmpVec = smooth(valueMatrix(v,:),round(filterSize),'sgolay',3);
				valueMatrix(v,:) = valueMatrix(v,:)-tmpVec';
			end
	  case 2 % median 
			for v=1:size(valueMatrix,1)
				tmpVec = medfilt1(valueMatrix(v,:),round(filterSize));
				valueMatrix(v,:) = valueMatrix(v,:)-tmpVec;
			end
		otherwise 
		  disp('detectEventsFromDff::invalid filterType specified.');
	end

	% -- MASTER SWITCH FOR VARIOUS DETECTION METHODS
	switch evdetMethod
	  case 1 % MAD using FULL distro

			roiMADs = mad(valueMatrix',1);

			% pooling of MADs?
			switch madPool
				case 1 % pool all
					roiMADs = nanmean(roiMADs)*ones(size(roiMADs));
				case 2 % 'smart pool' - only pool inactive MAD for actives ; otherwise use individual
					if (length(obj.activeRoiIds) == 0) 
						obj.getRoiActivityStatistics();
					end
					activeIdx = find(ismember(roiIds,obj.activeRoiIds));
					inactiveIdx = setdiff(1:length(roiIds), activeIdx);

					if (length(inactiveIdx) > 0 & length(activeIdx) > 0)
						roiMADs(activeIdx) = nanmean(roiMADs(inactiveIdx));
					else
						roiMADs = nanmean(roiMADs)*ones(size(roiMADs));
					end
			end

			% convert MADs to SDs
			roiSDs = 1.4826*roiMADs;

			% generate a median-subtracted value matrix -- since you are using median absolute deviation based thresh
			medianSubdValueMatrix = valueMatrix-repmat(nanmedian(valueMatrix'),size(valueMatrix,2),1)';

			% call to detectEventsViaThresh
			[peakTimes peakValues startTimes endTimes] = session.calciumTimeSeriesArray.detectEventsViaThresh(medianSubdValueMatrix, ...
				 tsaObj.time, threshMult*roiSDs, threshStartMult*roiSDs, threshEndMult*roiSDs, minEvDur);

	  case 2 % MAD using + df/f only
		  posValueMatrix = valueMatrix;
			posValueMatrix(find(posValueMatrix <0)) = NaN;
			roiMADs = mad(posValueMatrix',1);

			% pooling of MADs?
			switch madPool
				case 1 % pool all
					roiMADs = nanmean(roiMADs)*ones(size(roiMADs));
				case 2 % 'smart pool' - only pool inactive MAD for actives ; otherwise use individual
					if (length(obj.activeRoiIds) == 0) 
						obj.getRoiActivityStatistics();
					end
					activeIdx = find(ismember(roiIds,obj.activeRoiIds));
					inactiveIdx = setdiff(1:length(roiIds), activeIdx);
					roiMADs(activeIdx) = nanmean(roiMADs(inactiveIdx));
			end

			% convert MADs to SDs
			roiSDs = 1.4826*roiMADs;

			% generate a median-subtracted value matrix -- since you are using median absolute deviation based thresh
			medianSubdValueMatrix = valueMatrix-repmat(nanmedian(valueMatrix'),size(valueMatrix,2),1)';

			% call to detectEventsViaThresh
			[peakTimes peakValues startTimes endTimes] = session.calciumTimeSeriesArray.detectEventsViaThresh(medianSubdValueMatrix, ...
				 tsaObj.time, threshMult*roiSDs, threshStartMult*roiSDs, threshEndMult*roiSDs, minEvDur);
 
    case 3 % diff dff based method

		  % --- compute diff
			diffValueMatrix = diff(valueMatrix')';

      % --- determine threshold statistics
			roidMADs = mad(diffValueMatrix',1);
			roiMADs = mad(valueMatrix',1);

			switch madPool
				case 1 % pool all
					roidMADs = nanmean(roidMADs)*ones(size(roidMADs));
					roiMADs = nanmean(roiMADs)*ones(size(roiMADs));
				case 2 % 'smart pool' - only pool inactive MAD for actives ; otherwise use individual
					if (length(obj.activeRoiIds) == 0) 
						obj.getRoiActivityStatistics();
					end
					activeIdx = find(ismember(roiIds,obj.activeRoiIds));
					inactiveIdx = setdiff(1:length(roiIds), activeIdx);
					roidMADs(activeIdx) = nanmean(roidMADs(inactiveIdx));
					roiMADs(activeIdx) = nanmean(roiMADs(inactiveIdx));
			end

			% convert MADs to SDs
			roidSDs = 1.4826*roidMADs;
			roiSDs = 1.4826*roiMADs;

      % the threshold is SD * threshold multiplier specified by user
			thresh = threshMult*roidSDs;

			% generate a median-subtracted value matrix -- since you are using median absolute deviation based thresh
			medianSubdDiffValueMatrix = diffValueMatrix-repmat(nanmedian(diffValueMatrix'),size(diffValueMatrix,2),1)';
			medianSubdValueMatrix = valueMatrix-repmat(nanmedian(valueMatrix'),size(valueMatrix,2),1)';

			% --- MAIN loop thru rois
			L = size(medianSubdDiffValueMatrix,2);
			L2 = size(medianSubdValueMatrix,2);
			for r=1:size(medianSubdDiffValueMatrix,1)
				% --- apply threshold to diff vector 
				prevalids = find(medianSubdDiffValueMatrix(r,:) > thresh(r));
%if (r == 42) ; figure ; plot(medianSubdValueMatrix(r,:)) ; hold on ; plot([1 L], [roiSDs(r) roiSDs(r)], 'k:') ;end	
				% --- discard events where the INCREASE is preceded or followed by a DECREASE 50% or more of its size
				valids = [];
				for v=1:length(prevalids)
				  value = medianSubdDiffValueMatrix(r,prevalids(v));
				  if ( (prevalids(v) > 1 & medianSubdDiffValueMatrix(r,prevalids(v)-1) < -0.5*value) | ...
				       (prevalids(v)+1 < L & medianSubdDiffValueMatrix(r,prevalids(v)+1) < -0.5*value)) 
						% REJECT condition
					else
					  valids = [valids prevalids(v)]; % ACCEPT condition
					end
				end

				% --- now use dff alone to:
				endIdx = [];
				peakIdx = [];
				validx = [];
				for v=1:length(valids)
					%     1) determine event END
					endThresh = threshEndMult*roiSDs(r);
					eidx = min(find(medianSubdValueMatrix(r,valids(v)+1:L2) < endThresh))+valids(v);
					if (length(eidx) == 0) ; eidx = L2 ; end % in case we're at end
					endIdx(v) = eidx;
			  
					%     2) determine peak (between moment of high derivative and end)
					[irr pidx]= max(medianSubdValueMatrix(r,valids(v):endIdx(v)));
					peakIdx(v) = pidx + valids(v)-1;

					%     3) check if event still qualifies -- must have minEvDur above secondary thresh
					if (endIdx(v) - valids(v) + 1 >= minEvDur)
					  validx = [validx v];
					end
				end
        valids = valids(validx);
				peakIdx = peakIdx(validx);
  			endIdx = endIdx(validx);

			  % --- assign output
				peakTimes{r} = tsaObj.time(peakIdx);
				peakValues{r} = valueMatrix(r,peakIdx);
				startTimes{r} = tsaObj.time(valids);
				endTimes{r} =  tsaObj.time(endIdx);
			end
		  disp('detectEventsFromDff::NEED TO CONVERT TO DF/F!!');

	  case 4 % Vogelstein method
		  disp('detectEventsFromDff::Vogelstein takes some time, so be patient...');

			% basic parameters for Vogelstein approach
      frameRate = 1/session.timeSeries.convertTime(mode(diff(tsaObj.time)), tsaObj.timeUnit, 2); % in Hz
			madThresh = 0.5; % thresh for MAD
			sdThresh = 0.5; % SD thresgh
			minDff = 0.025; % minimal dff
			minRate = 0.025; % event rate minmm

			% pick up statistics of ROIs
		  if (~ isobject(obj.roiActivityStatsHash()))
				obj.getRoiActivityStatistics();
			end
			hyperactiveIdx = obj.roiActivityStatsHash.get('hyperactiveIdx');
			activeIdx = obj.roiActivityStatsHash.get('activeIdx');
			inactiveIdx = obj.roiActivityStatsHash.get('inactiveIdx');
			evThresh = obj.roiActivityStatsHash.get('thresh');
			stats = obj.roiActivityStatsHash.get('stats');

			hyperactiveIds = obj.ids(hyperactiveIdx) ; hyperactiveIdx = find(ismember(roiIds, hyperactiveIdx));
			activeIds = obj.ids(activeIdx) ; activeIdx = find(ismember(roiIds, activeIdx));
			inactiveIds = obj.ids(inactiveIdx) ; inactiveIdx = find(ismember(roiIds, inactiveIdx));
			evThresh = evThresh(roiIdx);
			stats = stats(:,roiIdx);

      % for each ROI get predicted event rate -- this was derived EMPIRICALLY
			%  in S1 with GCaMP3.3 synapsin so it may not work for other situations
%			pNAB = polyval([3.5 0], stats(1,:));
%			pCOF = polyval([3.5 0], stats(2,:));

			% values for GCaMP5 
			pNAB = polyval([15 0], stats(1,:));
			pCOF = polyval([15 0], stats(2,:));

			predictedEvPerFrame = sqrt(pNAB.*pCOF)/frameRate; % prediction is in Hz, so scale by frame rate 
			predictedNev = floor(predictedEvPerFrame * length(tsaObj.time));
			
			% determine average event rate & tau for guessing [RATE IN TERMS OF EVENTS/FRAME]
			meanRate = nan*ones(1,size(valueMatrix,1));
			meanTau = nan*ones(1,size(valueMatrix,1));
		  for r=1:size(valueMatrix,1)
				if (length(obj.caPeakEventSeriesArray.esa) >= r)
				  % since negative taus are possible for bad/rejected taus, screen for tihs
				  tDTC = obj.caPeakEventSeriesArray.esa{roiIdx(r)}.decayTimeConstants;
					tDTC(find(tDTC <= 0)) = nan;

					% and now the guess...
				  guessTau = nanmedian(tDTC);
					guessTau = session.timeSeries.convertTime(guessTau, obj.caPeakEventSeriesArray.esa{roiIdx(r)}.timeUnit, 2);
					meanTau(r) = guessTau;
					meanRate(r) = length(obj.caPeakEventSeriesArray.esa{roiIdx(r)}.eventTimes)/length(tsaObj.time);
				end
			end
			medRate = nanmedian(meanRate);
			medTau = nanmedian(meanTau);
			if (isnan(medTau)) ; medTau = 0.5 ; end % default 500 ms
			if (isnan(medRate)) ; medRate = minRate ; end % default event rate

		  for r=1:size(valueMatrix,1)
				if (1) ; disp(['-------------------roi ' num2str(roiIds(r))]); end

			  % initial tau value
				if (length(obj.caPeakEventSeriesArray.esa) >= r &&  ...
				     length(find(obj.caPeakEventSeriesArray.esa{roiIdx(r)}.decayTimeConstants > 0)) > 10) % at least 10 values to guess

				  % since negative taus are possible for bad/rejected taus, screen for tihs
				  tDTC = obj.caPeakEventSeriesArray.esa{roiIdx(r)}.decayTimeConstants;
					tDTC(find(tDTC <= 0)) = nan;

					% geustau YO
				  guessTau = nanmedian(tDTC);
					guessTau = session.timeSeries.convertTime(guessTau, obj.caPeakEventSeriesArray.esa{roiIdx(r)}.timeUnit, 2);
				else % otherwise use median of distribution
				  guessTau = medTau;
				end
				if (isnan(guessTau)) ; guessTau = 0.5 ; end
        
        % make sure guessTau is not below 2*frame rate
        if (guessTau < 1/(2*frameRate))
          disp(['cutting off short tau']);
          guessTau = 1/(2*frameRate);
        end

				% initial expected firing rate based off of polyval fit model
        expRate = max(minRate, predictedEvPerFrame(r)) ;
% OLD way
				if (length(find(inactiveIdx == r)) > 0) % inactive cell
				  expRate = max(expRate, 20*meanRate(r));
				elseif (length(find(hyperactiveIdx == r)) > 0) % hyperactive cell
				  expRate = max(expRate,50*meanRate(r));
				else % simply active
				  expRate = max(expRate,30*meanRate(r));
				end
%				if (isnan(expRate)) ; expRate = minRate ; end
% disp(['ROI ' num2str(r) ' previous expected: ' num2str(expRate) ' new: ' num2str(predictedEvPerFrame(r))]);
       
			  % filter evThrseh for hyperarcives -- lower it
				if (length(find(hyperactiveIdx == r)) > 0) 
					evThresh(r) = evThresh(r)/2;
				end

        % Call Diego's wrapper to Vogelstein method
			  [n_best P_best V_best C_best X] = extern_oopsi_deconv (valueMatrix(r,:)',frameRate, ...
				  madThresh, guessTau, minRate, minDff, sdThresh, expRate);
				finalTau = V_best.tau; % in seconds

        % scale n_best by effective frame "tau" to get amplitude-scaled n_best
 				if (length(find(hyperactiveIdx == r)) == 0) 
 				  n_best = n_best/(finalTau*frameRate);
        end
%				n_best = n_best/(frameRate);
			
        % extract peak indices for peaks that are sufficiently large, based on dFF distro (from getRoiActivityStatistics)
				minEvSize = evThresh(r); %cutoff_val;
	      peakIdx = find(n_best > minEvSize);
      
	      % at most allow 10 X n_old (or 10 if n_old = 1), or 1/2 predicted or 5x predicted
				if (predictedNev(r) > 1)
				  if (length(peakIdx) < ceil(predictedNev(r)/2))
		  			[sv si] = sort(n_best,'descend');
			  		peakIdx = si(1:min(length(n_best), ceil(predictedNev(r)/2)));
					elseif (length(peakIdx) > predictedNev(r)*5)
	  			  values = n_best(peakIdx);
		  			[sv si] = sort(values,'descend');
						disp('xxx')
			  		peakIdx = peakIdx(si(1:predictedNev(r)*5));
					end
				end
				nOld = max(1,length(obj.caPeakEventSeriesArray.esa{roiIdx(r)}.eventTimes));
	  		if (length(peakIdx) > 10*nOld)
				  values = n_best(peakIdx);
					[sv si] = sort(values,'descend');
					peakIdx = peakIdx(si(1:floor(10*nOld)));
				end
				peakIdx = sort(peakIdx);

				disp([' OLD: ' num2str(length(obj.caPeakEventSeriesArray.esa{roiIdx(r)}.eventTimes)) ' ... NEW:' num2str(length(peakIdx))]);
  

				if (eventBasedDffMethod == 1) % raw vogelstein
				  eventBasedDffTrace{r} = C_best;
	      % build a new dff trace based on peaks meeting criteria
				elseif (eventBasedDffMethod == 2)
					mnb = 0*n_best ; mnb(peakIdx) = n_best(peakIdx);
					frTau = finalTau*frameRate; % in frames -- finalTau is s ; frameRate is f/s so product is f
					eventBasedDffTrace{r} = conv(mnb, exp(-1*(1:100)/frTau));
				end

        % debug Vogelstein plot
				if (0)
					hold off;
					plot(valueMatrix(r,:),'k-');
					hold on;
					axis([0 length(C_best) -.5 4]);
					plot(C_best, 'r-');
					plot(n_best, 'b-');
					plot(eventBasedDffTrace{r}, 'm-');
					plot([0 length(C_best)], [1 1]*minEvSize, 'r:');
					title(num2str(r));
					if (length(peakIdx)  > 0) ; for p=1:length(peakIdx) ; plot([1 1]*peakIdx(p), [0 -0.5], 'g-');end ; end
					pause;
				end

				% --- assign variables
				peakTimes{r} = tsaObj.time(peakIdx);
				peakValues{r} = n_best(peakIdx);
				startTimes{r} = [];
				endTimes{r} = [];
			end

		otherwise
		  disp('detectEventsFromDff::invalid evdetMethod specified ; this will be ugly ...');
	end

	% -- delete events that violate minInterEvInterval
	switch minInterTimeUsed % assign timesCell -- the time point used for minimal event interval application -- based on what the user wanted
	  case 1
			timesCell = startTimes; 
	  case 2
			timesCell = peakTimes; 
	  case 3
			timesCell = endTimes; 
	end
	if (minInterEvInterval > 0) % don't waste your time if you dont have to(!)
		for i=1:length(timesCell)
			valids = 1:length(timesCell{i});

			% determine good ones
			e=1;
			while (e+1 < length(timesCell{i}))
				for E=e+1:length(timesCell{i}) % loop over events
					if (timesCell{i}(E)-timesCell{i}(e) <= minInterEvInterval) % delete condition
						valids = setdiff(valids,E); % remove the offending event from valids
					end
				end
				e = valids(min(find(valids > e))); % go to the next still-valid event
			end

			% reassign
			peakTimes{i} = peakTimes{i}(valids);
			peakValues{i} = peakValues{i}(valids);
			startTimes{i} = startTimes{i}(valids);
			endTimes{i} = endTimes{i}(valids);
		end
	end

	% -- determine rise & decay time constants (or 1/2) 
	switch riseDecayMethod % [0 = skip ; blank]
	  case 0 % populated with []
      for r=1:size(valueMatrix,1)
			  riseTimes{r} = [];
			  decayTimes{r} = [];
			end

	  case 1 % DH style peak matching
		  ntp = 0;
		  for i=1:length(peakTimes)
			  if (length(startTimes{i}) == length(endTimes{i}) && length(startTimes{i}) == length(peakTimes{i}))
					ntp = ntp + length(startTimes{i});
					riseTimes{i} = nan;
					decayTimes{i} = nan;
				end
			end
		  if (ntp == 0)
			  disp('detectEventsFromDff::can only do rise/decay method of t_1/2 if it gives start/end times.');
			else
			  [riseTimes decayTimes] =  session.calciumTimeSeriesArray.getTHalfBasedTimeConstantsS(startTimes, endTimes, peakTimes, valueMatrix, tsaObj.time);
			end

	  case 2 % exponential fit for decay, with goodness-of-fit (rise unasigned)
		  if (length(peakTimes) < 1)
			  disp('detectEventsFromDff::can only do rise/decay method with exponential fit if peak times given.');
			else
			  [riseTimes decayTimes] = session.calciumTimeSeriesArray.getGOFRestrictedTimeConstantsS(peakTimes, valueMatrix, tsaObj.time, tsaObj.timeUnit);
		  end
	end

	% -- are we updating or regenerating?
	updateOnly = 0;
	if (length(roiIdx) > 0 && length(roiIdx) < tsaObj.length())
	  updateOnly = 1;
	  if (~isobject(obj.caPeakTimeSeriesArray) ||  ...
	    length(find(strcmp(fieldnames(obj.caPeakTimeSeriesArray),'valueMatrix'))) == 0)
			updateOnly = 0;
		end
	  if (~isobject(obj.eventBasedDffTimeSeriesArray) ||  ...
	    length(find(strcmp(fieldnames(obj.eventBasedDffTimeSeriesArray),'valueMatrix'))) == 0)
			updateOnly = 0;
		end
	  if (~isobject(obj.caPeakEventSeriesArray) ||  ...
	    length(find(strcmp(fieldnames(obj.caPeakEventSeriesArray),'ids'))) == 0)
			updateOnly = 0;
		end
	end

	% -- eventBaedDffTrace -> eventBasedDffTimeSeriesArray
	if (eventBasedDffMethod > 0) 
    switch eventBasedDffMethod % 1,2 are done above
		  case 3
			  % make sure we have taus, etc.
        frameRate = 1/session.timeSeries.convertTime(mode(diff(tsaObj.time)), tsaObj.timeUnit, 2); % in Hz
				if (length(decayTimes) == tsaObj.length())
					for r=1:tsaObj.length()
						trace = 0*obj.time; % parent object's time vector
						
						% pull POSITIVE decayTimes
						tDecayTimes = decayTimes{r};
						tDecayTimes(find(tDecayTimes<=0)) = nan;

						% rebuild dff trace from this ...
						if (length(peakTimes{r}) > 0)
							tauMed = nanmedian(tDecayTimes);
							if (~isnan(tauMed))
								trace(peakTimes{r}) = peakValues{r};
								frTau = tauMed*frameRate; % tau in frames
								eventBasedDffTrace{r} = conv(trace, exp(-1*(1:100)/frTau));
							end
						end
					end
				end
		end

    % -- construct eventBasedFffTimeSeriesArray
		for i=1:tsaObj.length()
		  % Update 
		  if (ismember(i, roiIdx))
			  ri = find(roiIdx == i);
				newIdStr = ['evnt based dff' char(tsaObj.idStrs{i})];
				newTsa{i} = session.timeSeries(tsaObj.time, tsaObj.timeUnit, eventBasedDffTrace{ri}, tsaObj.ids(i), ...
					newIdStr, 0, 'Generated by detectEventsViaThresh');
			  if (updateOnly)
				  obj.eventBasedDffTimeSeriesArray.replaceTimeSeriesById (tsaObj.ids(i), newTsa{i});
				end
			elseif (~updateOnly) % just copy
			  newTsa{i} = obj.eventBasedDffTimeSeriesArray.getTimeSeriesByIdx(i);
			end
		end
		if (~updateOnly); obj.eventBasedDffTimeSeriesArray = session.timeSeriesArray(newTsa); end
	end

  % -- construct output data
	cesObj = {};
	for i=1:tsaObj.length()
		if (ismember(i, roiIdx))
			ri = find(roiIdx == i);
			newIdStr = ['evnt ' char(tsaObj.idStrs{i})];
			cesObj{i} = session.calciumEventSeries(startTimes{ri}, [], peakTimes{ri}, endTimes{ri}, ...
			      decayTimes{ri}, riseTimes{ri}, peakValues{ri}, ...
		        tsaObj.timeUnit, tsaObj.ids(i), newIdStr, 0, 'generated by detectEventsViaThresh');
			if (updateOnly)
			  obj.caPeakEventSeriesArray.esa{i} = cesObj{i};
				if (eventBasedDffMethod > 0)
					ts = obj.caPeakEventSeriesArray.esa{i}.deriveTimeSeries(obj.time, obj.timeUnit);
					obj.caPeakTimeSeriesArray.replaceTimeSeriesById(tsaObj.ids(i), ts);
				end
			end
		elseif (~updateOnly) % just copy
		  cesObj{i} = obj.caPeakEventSeriesArray.esa{i};
		end
  end

  % peak eventSeries
	if (updateOnly)
		cesaObj = obj.caPeakEventSeriesArray;
	else
		cesaObj = session.calciumEventSeriesArray(cesObj);
	end

	% also generate caPeakTimeSeriesArray ...
	if (eventBasedDffMethod > 0)
	  if (~updateOnly)
			obj.caPeakTimeSeriesArray = cesaObj.deriveTimeSeriesArray(obj.time, obj.timeUnit, obj.trialIndices);
		end
	end

