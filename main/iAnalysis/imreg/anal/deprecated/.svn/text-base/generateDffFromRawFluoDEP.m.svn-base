%
% SP 2010 June
%
% Computes df/f from raw fluorescence trace, returning a timeSeriesArray
%  object for dF/F.  Step-by-step:
%
%  1) filterType,Size dictate an initial filter that is applied to the 
%      data and whose result is used to DIVIDE the data
%  2) fzeroMethod is used to compute an Fzero value, which is then used to get
%      df/f ( = (F-Fzero/Fzero))
%  3) subtractMethod dictates what to subtract from the FINAL df/f
%
% Two general approaches seem to work quite well: either you perform the
%  high-pass filter at the outset, which allows you to work with a single
%  fzero for the entire trace, or you use a sliding-window/local fzero, 
%  which is basically equivalent but if you like that you can do it by 
%  disabling the initial filter and using sliding ksdensity.
%
% USAGE:
% 
% 	tsaObj = generateDffFromRawFluo(rawData, dffOpts)
%
% PARAMETERS:
%
%   rawData: can be a timeSeriesArray object, in which case each 
%            valueMatrix is used to compute most things.
%            Indexing is preserved in this case (of ids).
%            If it is a matrix, it is assumed to be of the form valueMatrix,
%            though IDs are simply assigned based on appearance in said matrix.
%            If it is a single timeSeries object, used as vector.
%            Finally, can be a vector.
%   dffOpts: Options for df/f computation; a structure with the following
%            parameters (if left out, default* for each param used):
%
%            roiIds: ids of rois to do, works only if rawData is calciumTimeSeriesArray
% 
%            prefiltering:
%
%            filterType - 0: none 1*: savitsky-golay 2D: median 3: minimum of low-freq
%                         4D: quantile (.1, .2, or .5, depending on cell activity)
%                         Filters with a D are temporally dense, meaning that if there
%                         are large jumps in time, these are filled in via interpolation
%                         (or nans, depending on the filter).  This prevents 
%                         temporally disparate data from being grouped.
%            filterSize - in seconds, size filter (60 default)
%
%            computing f-zero:
%
%            fzeroMethod - 1: sliding ksdensity; *2: entire trace ksdensity
%            fzeroSlidingWindowSize - in seconds, size of sliding window (60 dflt)
%            fzeroMin - fzeros found below this value are set to this value, to
%                       avoid division by 0.  Default 1 (raw fluo usually 0-4096).
%
%            post-hoc subtraction method (after df/f computation is done):
%
%            subtractMethod - 0*: none
%                             1: will subtract *modal* dff for each time point 
%                                across ROIs from each ROI.  Good if activity
%                                is sparse.
%                             [2 x]: subtract roi x from all other rois
%                             3: anti-ROI [i.e., all pixels not in rOI]
%
%            SVD (basically another post-hoc subtraction to take out noise) - this
%            works when you pass a behavioral variable, like running speed, and it
%            finds cross-neuron correlates.  Obviously, can be dangerous and
%            take out signal:
%
%            svdIndicesVec: if passed, these are the indices of the singular 
%                           vectors, derived from rawData and hence indexed like
%                           it, against which svdCorrelationVec is correlated.
%            svdCorrelationVec: If passed, this vector is correlated against rawData
%                               and if correlation for any of first 10 singular 
%                               vectors is correlated > 0.2, it is RMSE fit to 
%                               rawData and subtracted from data.
%            svdCorrelationPeakOffs: If passed, how many *frames* away from 0 
%                                    can peak correlation be and still use that 
%                                    singular vector? [dflt = 2]
%
% RETURNS:
% 
%   tsaObj: timeSeriesArray object matched to rawData that contains the df/f
%
function tsaObj = generateDffFromRawFluoDEP(rawData, dffOpts)
  % -- debug flags
  debug = 0; % for debugging set to 1
	debugRoi = 1; % the ROI to use for debugging

  % -- parse inputs

  % rawData -- need ids, idStrs, trialIndices, time -- if possible!
	roiIds = [];
	roiIdx = [];
	trialIndices = [];
	time = [];
	dtime = [];
	ids = [];
	roiFOVidx = [];
	idStrs = {};
	valueMatrix = [];
	antiRoiDffVec = {};
	svdIndicesVec = [];
	svdCorrelationVec = [];
	svdCorrelationPeakOffs = 2;
	rawDataIsObject = 0;

	if (isobject(rawData)) 
	  if (strcmp(class(rawData),'session.timeSeries')) % timeSeries object (use as vector)
			time = rawData.time;
		  valueMatrix = rawData.value;
    elseif (strcmp(class(rawData), 'session.calciumTimeSeriesArray')) % best situation -- calciumTimeSeriesArray
			time = rawData.time;
			trialIndices = rawData.trialIndices;
			ids = rawData.ids;
			roiFOVidx = rawData.roiFOVidx;;
			idStrs = rawData.idStrs;
			valueMatrix = rawData.valueMatrix;

			% anti-ROI for each FOV
			for f=1:rawData.numFOVs
		    if (length(rawData.antiRoiDffTS{f}) > 0) ; antiRoiDffVec{f} = rawData.antiRoiDffTS{f}.value ; end
			end
			rawDataIsObject = 1;

			% roiIds implemented here (and only here)
		  if (nargin > 1 && isfield(dffOpts,'roiIds'))  
			  roiIds = dffOpts.roiIds; 
			end

			if (length(roiIds) > 0)
			  roiIdx = 0*roiIds;
				for r=1:length(roiIds)
					roiIdx(r) = find(ids == roiIds(r));
				end
				
				% reduce all data elements accordingly
				valueMatrix = valueMatrix(roiIdx,:);
				roiFOVidx = roiFOVidx (roiIdx);
      else
        roiIdx = 1:size(valueMatrix,1);
      end
		else
		  disp(['generateDffFromRawFluoe::I do not support objects of class ' class(rawData)]);
		end
	elseif (size(rawData,1) > 1) % more than 1 element
	  disp('generateDffFromRawFluo::matrix not supported.  CalciumTimeSeriesArray objects must be used instead.');
		return;
	  valueMatrix = rawData;
	else % vector ...popopo
	  valueMatrix = rawData;
	end
	dffMatrix = zeros(size(valueMatrix));

	% dffOpts 
	fzeroMethod = 2;
	fzeroSlidingWindowSize = 60; % if method 1
	fzeroMin = 1;
	filterType = 1; % 1: savitsky golay ; 2: median
	filterSize = 60;
	subtractMethod = 0;
	subtractRoiIdx = -1;
	if (nargin > 1)
		if(isfield(dffOpts,'fzeroMethod')) ; fzeroMethod = dffOpts.fzeroMethod; end
		if(isfield(dffOpts,'fzeroSlidingWindowSize')) ; fzeroSlidingWindowSize = dffOpts.fzeroSlidingWindowSize; end
		if(isfield(dffOpts,'subtractMethod'))
		  subtractMethod = dffOpts.subtractMethod;
			if (length(subtractMethod) > 1) % roi
			  subtractRoiIdx = subtractMethod(2);
			  subtractMethod = subtractMethod(1);
			end
		end
		if(isfield(dffOpts,'filterType')) ; filterType = dffOpts.filterType; end
		if(isfield(dffOpts,'filterSize')) ; filterSize = dffOpts.filterSize; end
		if(isfield(dffOpts,'fzeroMin')) ; fzeroMin = dffOpts.fzeroMin; end
		if(isfield(dffOpts,'svdCorrelationVec')) ; svdCorrelationVec = dffOpts.svdCorrelationVec; end
		if(isfield(dffOpts,'svdCorrelationPeakOffs')) ; svdCorrelationPeakOffs = dffOpts.svdCorrelationPeakOffs; end
		if(isfield(dffOpts,'svdIndicesVec')) ; svdIndicesVec = dffOpts.svdIndicesVec; end
	end


  % -- time-sensitive variables
	if (length(time) > 0)
	  dtime = diff(time);
	  dtMS = mode(dtime);
    if(rawData.timeUnit ~= 1) ; disp('generateDffFromRawFluo::not in ms ; fix this.'); end
    filtSize = round(filterSize*1000/dtMS);
		fzswSize = round(fzeroSlidingWindowSize*1000/dtMS);

		% create a filltime vector that fills large jumps in time with dtMS spaced timepoints
		bdti = find(dtime > dtMS);
		bigdt = dtime(bdti) - dtMS; % don't include last one
		i1=1;
		fillTimes = zeros(1,ceil(sum(bigdt)/dtMS));
		for i=1:length(bigdt)
			ntime = dtMS+time(bdti(i)):dtMS:bigdt(i)+time(bdti(i));
			i2 = length(ntime) + i1 - 1;
			fillTimes(i1:i2) = ntime;
			i1 = i2 + 1;
		end
		filledTime = sort(union(time,fillTimes)); % a time vector that is temporally dense -- no time points more than dtMS apart
		oTimeIdx = find(ismember(filledTime, time)); % indices of filledTime that are also in time -- i.e., in actual data

	else
	  disp('generateDffFromRawFluo::warning - no time vector exists, and so filter window sizes are assumed to be in units of vector size.');
	  filtSize = filterSize;
		fzswSize = fzeroSlidingWindowSize;
		filledTime = 1:size(valueMatrix,2);
		oTimeIdx = filledTime;
	end

  % -- apply any initial filter
  switch filterType
	  case 0 % NONE
		  disp('generateDffFromRawFluo::skipping initial filter per request.');
			dffMatrix = valueMatrix;

	  case 1 % Savitsky-Golay
		  fs = round(filtSize);
			for t=1:size(valueMatrix,1)
				tmpVec = smooth(valueMatrix(t,:),fs,'sgolay',3);
				dffMatrix(t,:) = valueMatrix(t,:)./tmpVec';

				% debug plot of the filter results
				if (debug & t == debugRoi)
				  figure;
					plot(valueMatrix(t,:),'k-');
					hold on;
					plot(tmpVec, 'r-');
				end
      end
      
      % inf values from /0 above
      dffMatrix(find(isinf(dffMatrix))) = nan;


	  case 2 % median 
		  fs = round(filtSize);
			fs2 = ceil(fs/2);
			for t=1:size(valueMatrix,1)
			  % generate filled vector with nans
				tmpVec = nan*filledTime;
				tmpVec(oTimeIdx) = valueMatrix(t,:);

				vidx = find(~isnan(valueMatrix(t,:)));
				if (length(vidx) > 0)
					% filter
					tmpVec = nanmedfilt1(tmpVec,fs);
					dffMatrix(t,vidx) = valueMatrix(t,vidx)./tmpVec(oTimeIdx(vidx));

					% debug plot of the filter results
					if (debug & t == debugRoi)
						figure;
						plot(valueMatrix(t,:),'k-');
						hold on;
						plot(tmpVec, 'r-');
					end
				end
      end

      % inf values from /0 above
      dffMatrix(find(isinf(dffMatrix))) = nan;
      
	  case 3 % sliding minimum
		  fs = round(filtSize);
      disp('WARNING: fix this to accomodate NaN!');
			fs2 = ceil(fs/2);
			L = size(valueMatrix,2);
			for t=1:size(valueMatrix,1)
        % pad the ends for initial median filter
				valueVec = [valueMatrix(t,1)*ones(1,3) valueMatrix(t,:) valueMatrix(t,end)*ones(1,3)];
			  
        % filter initially to get rid of high freq components
				preVec = medfilt1(valueVec,7);
				preVec = preVec(4:end-3);

				% now do minimum
				for i=1:L
				  tmpVec(i) = min(preVec(max(1,i-fs2):min(L,i+fs2)));
				end
				dffMatrix(t,:) = valueMatrix(t,:)./tmpVec;

				% debug plot of the filter results
				if (debug & t == debugRoi)
				  figure;
					plot(valueMatrix(t,:),'k-');
					hold on;
					plot(preVec, 'b-');
					plot(tmpVec, 'r-');
				end
      end
      
	  case 4 % bottom quantile
		  disp('generateDffFromRawFlow::quantile estimation is slow ... be patient.');
		  fs = round(filtSize);
			fs2 = ceil(fs/2);

      % do we have prior stats? if so, break them down into active, hyperactive, and inactive
			quantileThresh = 0.2*ones(1,size(valueMatrix,1));
			if (rawDataIsObject && length(rawData.dffTimeSeriesArray) > 0)
				if (~ isobject(obj.roiActivityStatsHash()))
					obj.getRoiActivityStatistics();
				end
				hyperactiveIdx = obj.roiActivityStatsHash.get('hyperactiveIdx');
				activeIdx = obj.roiActivityStatsHash.get('activeIdx');
				inactiveIdx = obj.roiActivityStatsHash.get('inactiveIdx');

        hyperactiveIdx = find(ismember(roiIdx, hyperactiveIdx));
        activeIdx = find(ismember(roiIdx, activeIdx));
        inactiveIdx = find(ismember(roiIdx, inactiveIdx));        
        
				quantileThresh(inactiveIdx) = 0.5;
				quantileThresh(hyperactiveIdx) = 0.1;
      end

      % main loop
			for t=1:size(valueMatrix,1)
			  % generate filled vector with nans
				tmpVec = nan*filledTime;
				tmpVec(oTimeIdx) = valueMatrix(t,:);
				
        vidx = find(~isnan(valueMatrix(t,:)));
        if (length(vidx) > 0)
          if (quantileThresh(t) == 0.5) % median
            % filter
            tmpVec = nanmedfilt1(tmpVec,fs);
          else
            disp(['generateDffFromRawFluo::' num2str(t) ' of ' num2str(size(valueMatrix,1))]);
            % filter initially to get rid of high freq components
            preVec = nanmedfilt1(tmpVec,7);
            L = max(oTimeIdx);

            % do quantile estimation
            for i=1:length(oTimeIdx)
              tmpVec(oTimeIdx(i)) = quantile(preVec(max(1,oTimeIdx(i)-fs2):min(L,oTimeIdx(i)+fs2)),quantileThresh(t));
            end
          end

					% reconvert to undense and put into dffMatrix
					dffMatrix(t,vidx) = valueMatrix(t,vidx)./tmpVec(oTimeIdx(vidx));
        end
			end
	      
      % inf values from /0 above
      dffMatrix(find(isinf(dffMatrix))) = nan;
    
    otherwise 
		  disp('generateDffFromRawFluo::invalid filterType specified.');
	end

	% -- compute f-zero based on fzeroMethod
	fzeroMatrix = fzeroMin*ones(size(valueMatrix));
	switch fzeroMethod
	  case 1 % sliding window
			disp('generateDffFromRawFluo::fzeroMethod sliding window takes a long time; please wait ...');
			fzeroMatrix = getSlidingWindowFzero(dffMatrix, fzswSize);

		case 2 % full trace
			modes = getFullTraceModes(dffMatrix);
			for t=1:size(dffMatrix,1)
				fzeroMatrix(t,:) = ones(size(fzeroMatrix(t,:)))*modes(t);
			end

		case 3 % event detect + linear interp over event-free regions [must be object, more than 1 tsa]
			modes = getFullTraceModes(dffMatrix);
			for t=1:size(dffMatrix,1)
				fzeroMatrix(t,:) = ones(size(fzeroMatrix(t,:)))*modes(t);
			end

      % do we have prior stats? if so, break them down into active, hyperactive, and inactive
			if (~exist('hyperactiveIdx','var'))
				quantileThresh = 0.2*ones(1,size(valueMatrix,1));
				if (rawDataIsObject && length(rawData.dffTimeSeriesArray) > 0)
					if (~ isobject(obj.roiActivityStatsHash()))
						obj.getRoiActivityStatistics();
					end
					hyperactiveIdx = obj.roiActivityStatsHash.get('hyperactiveIdx');
					activeIdx = obj.roiActivityStatsHash.get('activeIdx');
					inactiveIdx = obj.roiActivityStatsHash.get('inactiveIdx');

          [hyperactiveIdx activeIdx inactiveIdx ] = rawData.getRoiActivityStatistics();

          hyperactiveIdx = find(ismember(roiIdx, hyperactiveIdx));
          activeIdx = find(ismember(roiIdx, activeIdx));
          inactiveIdx = find(ismember(roiIdx, inactiveIdx));        
        
				
					quantileThresh(inactiveIdx) = 0.5;
					quantileThresh(hyperactiveIdx) = 0.1;
				end
			end

			if (rawDataIsObject && rawData.length() > 0) 
			  % make sure user already ran event detection
				if (length(rawData.caPeakEventSeriesArray.esa) == length(rawData.ids))
				%	dt = mode(diff(rawData.time));

          % time window for event exclusion
					tws = session.timeSeries.convertTime(1, 2, rawData.timeUnit); % convert to whatever timunit it is
			%		timeWindow = [-4*tws 15*tws]; % pad with 2 s pre, 5 post
					timeWindow = [-2*tws 5*tws]; % pad with 2 s pre, 5 post
					aidx = 1:size(dffMatrix,2);

					% window for post-filtering fzero
					sfs = session.timeSeries.convertTime(60, 2, rawData.timeUnit); % convert to whatever timunit it is
					sfs = ceil(sfs/dtMS);
					sfs2 =ceil(sfs/2);


					% go roi-by-roi ; if it has multiple events you will want to use event-excluded periods
					ntp = size(dffMatrix,2);
					for r=1:size(dffMatrix,1)
					  ies = rawData.caPeakEventSeriesArray.esa{roiIdx(r)};
						if (~isempty(ies.eventTimes)) % do only if it is worth it ...


              %% prepare a vector for quantile estimation -- zero values are nan'd, as are vlaues during temporal jumps.  
              % Values around events are also nan'd.  All nan values are then interpolated, yielding a reasonable estimate 
              % of INSTANTANEOUS fzero for median/quantile filtering
              
							fzeroTraceQ = dffMatrix(r,:);
              
              % remove zero values
              fzeroTraceQ(find(fzeroTraceQ == 0)) = nan;
              							
              % get indices around events nan these
							[idxMat timeMat timeVec] = session.timeSeries.getIndexWindowsAroundEventsS(rawData.time, ...
							  rawData.timeUnit, timeWindow, rawData.timeUnit, ies.eventTimes, ies.timeUnit, [], [], [], 1);
							evidx = unique(reshape(idxMat,[],1)); % vectorize
              evidx = evidx(find(~isnan(evidx)));
            
              % skip if only 10% r less of poitns left
              if (length(evidx) >= .9*size(fzeroMatrix,2)) ; disp('generateDffFromRawFluo::skipping roi with too many events') ; continue ; end
              
              % apply nan
              fzeroTraceQ(evidx) = nan;
              
              % build filled vec to prevent time jumps
              fzeroTraceQFilled = nan*filledTime;
              fzeroTraceQFilled(oTimeIdx) = fzeroTraceQ;
              
              nanIdx = find(isnan(fzeroTraceQFilled));
              valIdx = find(~isnan(fzeroTraceQFilled));
              
              if (length(valIdx) < 0.05 * length(filledTime)) ; disp('generateDffFromRawFluo::skipping roi where > 95% of time would have to be interpolated') ; continue ; end
              
              interpVec = interp1(valIdx, fzeroTraceQFilled(valIdx), nanIdx, 'nearest');
              fzeroTraceQFilled(nanIdx) = interpVec;

% Another idea would be to try quantile interpolation with windows that end, center at (current) and start at
%   the given time point.  Take minima across all 3

							% quantile or median filter on this temporally-filled fzero vector
							if (quantileThresh(r) == 0.5) % median
                % do we have data to work w/?
                if (length(valIdx) > 0)
                  % filter
                  tmpVec = nanmedfilt1(fzeroTraceQFilled,sfs);

									% regenerate fzeroTrace
                  fzeroTraceQFilled(oTimeIdx) = tmpVec(oTimeIdx);
                end
              else
                % do we have data to work w/?
                if (length(valIdx) > 0)
              
                  % filter initially to get rid of high freq components
                  tmpVec = nanmedfilt1(fzeroTraceQFilled,7);

                  % do quantile estimation
                  for i=1:length(oTimeIdx)
                    fzeroTraceQFilled(oTimeIdx(i)) = quantile(tmpVec(max(1,oTimeIdx(i)-sfs2):min(length(tmpVec),oTimeIdx(i)+sfs2)),quantileThresh(r));
                  end
                end
              end
                          
              % pad ends -- just take mean of endPad valid closest points
              endPad = ceil(.005*ntp);
              if (endPad > 0)
                sIdx = 1:endPad;
                fzeroTraceQFilled(sIdx) = median(fzeroTraceQFilled(sIdx+endPad));
                eIdx = length(fzeroTraceQFilled)-endPad:length(fzeroTraceQFilled);
                fzeroTraceQFilled(eIdx) = median(fzeroTraceQFilled(eIdx-endPad));
              end

              % pull out fzeroTrace only for original times
              fzeroTrace = fzeroTraceQFilled(oTimeIdx);

              % assign to fzero matrix
							fzeroMatrix(r,:) = fzeroTrace;
               
							if (debug)
								hold off;
								plot(rawData.time,dffMatrix(r,:),'k-');
								hold on;
								plot(rawData.time,fzeroTrace,'b-', 'LineWidth', 2);
								R = quantile(rawData.time,.99) - quantile(rawData.time,.01);
								axis([quantile(rawData.time,.01)-(0.1*R) quantile(rawData.time,0.99)+0.1*R -0.2 1.25*max(dffMatrix(r,:))]);
								title([num2str(roiIds(r)) ' quantile: ' num2str(quantileThresh(r))]);
								pause;
							end
						end
					end
				end
			end

		otherwise
			disp('generateDffFromRawFluo::selected fzeroMethod not supported.');
	end

	% -- fzeroMin
	fzeroMatrix(find(fzeroMatrix < fzeroMin)) = fzeroMin;

	% -- and compute dff
	dffMatrix = (dffMatrix-fzeroMatrix)./fzeroMatrix;

	% -- debug plot of fzero matrix prior subtraction
	if (debug & size(fzeroMatrix,1) >= debugRoi)
	  figure;
		plot(dffMatrix(debugRoi,:),'k-');
		hold on;
	end

  % -- subtracts something from all data
  switch subtractMethod
	  case 0 % NONE
		  disp('generateDffFromRawFluo::skipping subtraction as requested.');
	  case 1 %  subtract pooled modal df/f at each time point -- removes common noise
		  if (size(dffMatrix,1) > 1)
				for i=1:size(dffMatrix,2)
					modalDff = getModeKSDensity(dffMatrix(:,i));
					dffMatrix(:,i) = dffMatrix(:,i)-modalDff;
				end
			else
				disp('generateDffFromRawFluo::modal subtraction illogical with only one ROI.');
			end
	  case 2 %  subtract particular ROI
		  if (subtractRoiIdx < 0 | subtractRoiIdx > size(dffMatrix,1)) 
			  disp ('generateDffFromRawFluo::you did not specify a valid ROI for ROI subtraction.  Brace yourself...');
			end
			for i=1:size(dffMatrix,1)
				modalDff = getModeKSDensity(dffMatrix(i,:));
				dffMatrix(i,:) = dffMatrix(i,:)-dffMatrix(subtractRoiIdx,:);
			end
	  case 3 %  subtract dff of the 'anti-ROI'
		  if (length(antiRoiDffVec) > 0)
				for i=1:size(dffMatrix,1)
					dffMatrix(i,:) = dffMatrix(i,:)-antiRoiDffVec{roiFOVidx(i)};
				end
			end
	end
	if (debug & size(fzeroMatrix,1) >= debugRoi)
		plot(dffMatrix(debugRoi,:),'r-');
		legend('pre-sub dff', 'post-sub dff');
	end

	% -- SVD?
	if (length(svdIndicesVec) > 0 && length(svdCorrelationVec) > 0 && min(size(dffMatrix)) > 1)
	  tDffMatrix = dffMatrix;
		tDffMatrix(find(isnan(tDffMatrix))) = 0;
		tDffMatrix(find(isinf(tDffMatrix))) = 0;
		[U S V] = svd(tDffMatrix, 0);

		nDffMatrix = 0*tDffMatrix;

		% Test which singular vectors to use by correlatingfigure ; image(s.caTSA.dffTimeSeriesArray.valueMatrix(:,1:20000)*100); colormap gray
		cv = corr(svdCorrelationVec, V(svdIndicesVec,1:10));
		svvs = find(abs(cv) > 0.1);

    % any acceptable correaltions?
    if (length(svvs) > 0)
	  	% for candidates, make sure they are actually correlated to licking and not something else
		  %  by ensuring that the time of peak correlation is close to 0
			valsvvs = [];
			for svi=1:length(svvs)
			  offs = -9:9;
				subidx = (offs(end)+1):(length(svdCorrelationVec)+offs(1)-1);
				corrs = 0*offs;
				for o=1:length(offs)
				  corrs(o) = corr(svdCorrelationVec(subidx), V(svdIndicesVec(subidx+offs(o)),svvs(svi)));
				end
				[irr peakIdx] = max(abs(corrs));
        if (abs(offs(peakIdx)) <= svdCorrelationPeakOffs) ; valsvvs = [valsvvs svi]; end
			end
			svvs = svvs(valsvvs);
		end


		% anything left?
    if (length(svvs) > 0)
			% THIS SHOULD BE DONE WITH GRADIENT DESCENT OR NEWTON'S --> CONVERGENCE GUARANTEED!!
			for r=1:size(tDffMatrix,1)
				vec = tDffMatrix(r,:);

				% restrict to < some % df/f (in future, perhaps omit events .. or look directly @ fluo)
				valIdx = find(vec < 0.5);
				for p=1:length(svvs)
					sf = -20:.1:20 ; for i=1:length(sf); rmse(i) = mean((vec(valIdx)-(sf(i)*V(valIdx,svvs(p)))').^2) ; end
					[irr idx] = min(rmse);
					vec = vec - sf(idx)*V(:,svvs(p))';
				end
				nDffMatrix(r,:) = vec;
			end

			dffMatrix = nDffMatrix;
		end
	end

	% -- generate dff timeSeriesArray
	skipGenerate = 0;
	if (length(ids) > 0 && isobject(rawData) && strcmp(class(rawData), 'session.calciumTimeSeriesArray') && ...
	    length(roiIds) > 0 && length(roiIds) < length(ids)) % update
		for t=1:length(ids)
		  if (ismember(t, roiIdx))
			  ri = find(roiIdx == t);
				newTS = session.timeSeries(time, 1, dffMatrix(ri,:), ids(t), ['dF/F ' char(idStrs{t})], 0, 'Generated by generateDffFromRawFluo');
				rawData.dffTimeSeriesArray.replaceTimeSeriesById (ids(t), newTS);
			end
		end
		tsaObj = rawData.dffTimeSeriesArray;
		skipGenerate = 1;
	elseif (length(ids) > 0) % array
		for t=1:length(ids)
			newTSs{t} = session.timeSeries(time, 1, dffMatrix(t,:), ids(t), ['dF/F ' char(idStrs{t})], 0, 'Generated by generateDffFromRawFluo');
		end
	elseif (size(dffMatrix,1) > 1)
	  disp('generateDffFromRawFluo::matrix not supported.');
	else % vector
		newTSs{1} = session.timeSeries(time, 1, dffMatrix(1,:), 1, ['dF/F '], 0, 'Generated by generateDffFromRawFluo');
	end

	if (~skipGenerate) ; tsaObj = session.timeSeriesArray(newTSs, trialIndices); end
	
%
% Returns fzeroMatrix, where fzero is determined by taking the ksdensity peak 
%  (i.e., mode) for a window around a point.  All edges are set to edge val.
%
function fzeroMatrix = getSlidingWindowFzero(dataMatrix, windowSize)
  fzeroMatrix = zeros(size(dataMatrix));

  % sanity cheques
	if (~rem(windowSize,2)) ; windowSize = windowSize-1; end % make it odd

	% loop over each timeseries
  for t=1:size(dataMatrix,1)
	  vec = dataMatrix(t,:);
		% start part
		subvec = vec(1:windowSize);
    fzeroMatrix(t,1:windowSize) = getModeKSDensity(subvec);
		% middle part
		for i=windowSize+1:length(vec)-windowSize
		  subvec = vec(i-windowSize:i+windowSize);
			fzeroMatrix(t,i) = getModeKSDensity(subvec);
	  end
		% end of timeseries vector
		subvec = vec(end-windowSize:end);
    fzeroMatrix(t,end-windowSize:end) = getModeKSDensity(subvec);
	end
	  
  
%
% Returns all the NON-sliding modes for all ROIs, assuming first dimension is
%  index of roi.
%
function modes = getFullTraceModes(dataMatrix)
  modes = zeros(1,size(dataMatrix,1));
  for t=1:size(dataMatrix,1)
	  mksd = getModeKSDensity(dataMatrix(t,:)); 
	  if (length(mksd) == 1)
			modes(t) = mksd;
		else 
		  disp(['generateDffFromRawFluo.getFullTraceModes::problem with trace ' num2str(t)]);
		  modes(t) = 1;
		end
	end
	 
%
% Returns the 'mode' via ksdensity for the given vector of data
%
function ksmode = getModeKSDensity(vec)
  if (length(find(isnan(vec))) < length(vec))
		[f xi] = ksdensity(vec);
		ksmode = xi(find(f == max(f)));
	else
	  ksmode = 1;
	end

