%
% For generating various colored ROI plots superimposed on the field of view.
%
% USAGE:
%
%  s.plotColorRois(plotMode, trialTypes, trialIds, colorMap, colorBasisVec, 
%                       colorBasisVecRange, axHandle, drawColorBar, fovIdx)
%
%  s.plotColorRois(plotMode) [if string]
%  s.plotColorRois(colorBasisVec) [if numerical vector]
%
% ARGUMENTS:
%
%   plotMode: "maxDff" - plot max deltaF/F across specified trials
%             "eventCount" - event count for ROI
%             "eventRate" - event rate for ROIs
%             "burstRate" - event rate modulated by only counting events spaced by
%                           1s or less as one event
%             "custom" - you must give colorBasisVec ; can leave blank if you want
%             If left blank, you must specify colorBasisVec - i.e., CUSTOM!
%   trialTypes: if specified, restrict to trials of given types (validTrialIds)
%               blank means no restriction (by blank, I always mean [])
%   trialIds: restrict to these trials; if BOTH this and trialTypes is passed,
%             considers the intersection of trials with trialTypes an trialIds.
%             Default is all trials.
%   colorMap: which colormap to use - default is 'human readable' (blank).  If
%             you pass a 3-element vector, it will go from black to that color.
%   colorBasisVec: a vector corresponding to s.caTSA.ids (must be same 
%                  size) that contains a range of values used for coloring. This
%                  parameter is optional if plotMode is 'custom' or blank.  If
%                  a ROI has value nan, it is set to color 0 0 0 (black).
%   colorBasisVecRange: by default, colormap spans min(colorBasisVec) to max.If
%                       you want to span a FIXED range, give it here (that is,
%                       if you want to make the max color of colormap corespodn
%                       to a value other than max(colorBasisVec)).
%   axHandle: if blank, will simply plot to s.caTSA.roiArray.guiHandles(2). 
%             If provided, will plot accordingly and then label the colorbar.
%             Note that for multiple FOVs, you must provide a cell array of 
%             handles.
%   drawColorBar: default is 1 ; if set to 0, will NOT plot the colorBar when
%                 axHandle provided
%   fovIdx: Which FOVs to use -- default is all.
%
% (C) Jul 2012 S Peron
% 
function plotColorRois(obj, plotMode, trialTypes, trialIds, colorMap, colorBasisVec, ...
                        colorBasisVecRange, axHandle, drawColorBar, fovIdx)
  % --- argument checking
	if (nargin < 2)
	  disp('plotColorRois::must at least pass plotMode.');
		help('session.session.plotColorRois');
	  return;
	elseif (length(plotMode) == 0)
	  plotMode = 'custom'; % 'default'
	end

	if (nargin < 4) % no trialIds
	  trialIds = obj.validTrialIds;
	elseif (length(trialIds) == 0)
		trialIds = obj.validTrialIds;
	end

	if (nargin >= 3) % restrict by trialTypes
	  if (length(trialTypes) > 0)
			valid = 0*trialIds;
			for t=1:length(trialIds)
				ti = find(obj.trialIds == trialIds(t));
				if (length(intersect(obj.trial{ti}.typeIds, trialTypes)) > 0)
					valid(t) = 1;
				end
			end
			trialIds = trialIds(find(valid));
		end
	end

	if (nargin < 5) % defualt colormap
	  colorMap = colormap_human(256);
	elseif (length(colorMap) == 0)
	  colorMap = colormap_human(256);
	elseif (size(colorMap,1) == 1)
	  colorMap = [linspace(0,colorMap(1),256)' linspace(0,colorMap(2),256)' linspace(0,colorMap(3),256)']; 
	end

	if (nargin < 6) % colorBasisVec NOT specified
	  colorBasisVec = [];
	end

	if (nargin < 7) % colorBasisVecRange NOT specified
	  colorBasisVecRange = [];
	end

	if (nargin < 8) % axis handle
	  axHandle = [];
	else
	  if (~iscell(axHandle)) ; axHandle = {axHandle} ; end % wrap it up son
	end

	if (nargin < 9) % draw coor bar?
	  drawColorBar = 1;
	end

	if (nargin < 10) % FOVs?
	  fovIdx = 1:obj.caTSA.numFOVs;
  end

  % user passed JUST data vector
  if (nargin == 2 && isnumeric(plotMode))
    colorBasisVec = plotMode;
    plotMode = 'custom';
  end
  
  % no figure but multiple FOVs?  One figure desired
  guiPresent = 0;
  if (length(obj.caTSA.roiArray{fovIdx(1)}.guiHandles) >= 2 && ...
      ishandle(obj.caTSA.roiArray{fovIdx(1)}.guiHandles(2)) )
    guiPresent = 1;
  end
  
  if (length(axHandle) == 0 && length(fovIdx) > 1 && ~guiPresent)
    axHandle = figure_tight(ceil(sqrt(length(fovIdx))));
  end

  
	% --- switch based on mode
  if (length(colorBasisVec) == length(obj.caTSA.ids)) 
	  passedBasisVec = colorBasisVec;
	else
	  passedBasisVec = [];
  end

	for f=1:length(fovIdx)
	  % did user pass basis vec?
		if (length(passedBasisVec) > 0)
		  fovRois = find(obj.caTSA.roiFOVidx == fovIdx(f));
			colorBasisVec = passedBasisVec(fovRois);
		end

	  % pull rA
		rA = obj.caTSA.roiArray{fovIdx(f)};
		if (length(colorBasisVec) == 0) ; colorBasisVec = 0*(1:length(rA.rois)); end % values from which color is derived
		roiColors = zeros(length(rA.rois), 3);
		switch lower(plotMode)
			case 'maxdff' % max DFF for each ROI in relevant trials ..
				maxdff = 0*(1:length(rA.rois));
				valPoints = find(ismember (obj.caTSA.dffTimeSeriesArray.trialIndices,trialIds)); 

				% compute maxdff
				for r=1:length(maxdff)
					ri = find(obj.caTSA.dffTimeSeriesArray.ids == rA.roiIds(r));
					if (length(ri) > 0)
						maxdff(r) = max(obj.caTSA.dffTimeSeriesArray.valueMatrix(ri,valPoints));
					end
				end

				% color assign
				colorBasisVec = maxdff;

			case 'eventcount'
				eventcount = 0*(1:length(rA.rois));

				% compute eventcount
				for r=1:length(eventcount)
					ri = find(obj.caTSA.caPeakEventSeriesArray.ids == rA.roiIds(r));
					if (length(ri) > 0)
						valEvents = find(ismember(obj.caTSA.caPeakEventSeriesArray.esa{ri}.eventTrials, trialIds));
						eventcount(r) = length(valEvents);
					end
				end
				
				% color assign
				colorBasisVec = eventcount;


			case 'eventrate'
				eventcount = 0*(1:length(rA.rois));

				% compute eventcount
				for r=1:length(eventcount)
					ri = find(obj.caTSA.caPeakEventSeriesArray.ids == rA.roiIds(r));
					if (length(ri) > 0)
						valEvents = find(ismember(obj.caTSA.caPeakEventSeriesArray.esa{ri}.eventTrials, trialIds));
						eventcount(r) = length(valEvents);
					end
				end

				% simply divide count by the net duration of trials ...
				netTrialTimeSec = 0;
				for t=1:length(trialIds)
					ti = find(obj.trialIds == trialIds(t));
					if ((obj.trial{ti}.endTime-obj.trial{ti}.startTime) > 0) % sanity check
						netTrialTimeSec = netTrialTimeSec + 0.001*(obj.trial{ti}.endTime-obj.trial{ti}.startTime);
					end
				end
				
				% color assign
				eventrate = eventcount/netTrialTimeSec;
				colorBasisVec = eventrate;

				disp(['MEAN event rate for ' obj.mouseId ' on ' obj.dateStr ': ' num2str(nanmean(eventrate))]);

			case 'burstrate'
				eventcount = 0*(1:length(rA.rois));

				% compute eventcount
				for r=1:length(eventcount)
					ri = find(obj.caTSA.caPeakEventSeriesArray.ids == rA.roiIds(r));
					if (length(ri) > 0)
						burstTimes = obj.caTSA.caPeakEventSeriesArray.esa{ri}.getBurstTimes(1000);
						idx = find(ismember(obj.caTSA.caPeakEventSeriesArray.esa{ri}.eventTimes, burstTimes));
						valEvents = find(ismember(obj.caTSA.caPeakEventSeriesArray.esa{ri}.eventTrials(idx), trialIds));
						eventcount(r) = length(valEvents);
					end
				end

				% simply divide count by the net duration of trials ...
				netTrialTimeSec = 0;
				for t=1:length(trialIds)
					ti = find(obj.trialIds == trialIds(t));
					if ((obj.trial{ti}.endTime-obj.trial{ti}.startTime) > 0) % sanity check
						netTrialTimeSec = netTrialTimeSec + 0.001*(obj.trial{ti}.endTime-obj.trial{ti}.startTime);
					end
				end
				
				% color assign
				eventrate = eventcount/netTrialTimeSec;
				colorBasisVec = eventrate;

				disp(['MEAN burst rate for ' obj.mouseId ' on ' obj.dateStr ': ' num2str(nanmean(eventrate))]);

			case 'custom' % user-specified colorBasisVec

			otherwise
				disp('plotColorRois::invalid mode specified.');
		end

		% --- apply colorBasisVec
		if (range(colorBasisVec) > 0)
			if(length(colorBasisVecRange) > 0)
				m = colorBasisVecRange(1);
				M = colorBasisVecRange(2);
				
				colorBasisVec(find(colorBasisVec < m)) = m; 
				colorBasisVec(find(colorBasisVec > M)) = M;
			else
				m = min(colorBasisVec);
				M = max(colorBasisVec);
			end

			colorBasisVec = colorBasisVec - m; % [0
			colorBasisVec = colorBasisVec/double(M-m); % [0 1]
			colorBasisVec = colorBasisVec*(size(colorMap,1)-1); % [0 size_colormap-1]
			colorBasisVec = colorBasisVec+1; % [1 size_colormap]
			% should be unnecessary ... but SAFETY FIRST
			colorBasisVec(find(colorBasisVec < 1)) = 1; 
			colorBasisVec(find(colorBasisVec > size(colorMap,1))) = size(colorMap,1); 
			for r=1:length(colorBasisVec)
				if (isnan(colorBasisVec(r)))
					roiColors(r,:) = [0 0 0];
				else
					i = round(colorBasisVec(r));
					roiColors(r,:) = colorMap(i,:);
				end
			end
		else
			m = 0 ; M = 0;
			disp('plotColorRois::no difference in any of the rois; all will be BLACK');
		end

		% --- plot
    
    % make working image brigher
    rA.workingImage = rA.masterImage;
    vmi = reshape(rA.workingImage,[],1);
    mm = quantile(vmi,.9975);
    rA.workingImage(find(rA.workingImage > mm)) = mm;
      
		if (length(rA.guiHandles) > 0 && ~ishandle(rA.guiHandles(2)))
			rA.guiHandles = [];
		end
		rA.colorById(rA.roiIds, roiColors);
		if (length(axHandle) == 0) % ONLY if one
			rA.startGui(); % soft touch thanks to checks in there		  
    else
			im = rA.plotImage(0, 1, 0, [], axHandle{f});
			if (drawColorBar)
				cb = colorbar;
				colormap(colorMap);
			
				set(cb,'YTick', [1 size(colorMap,1)]);
				set(cb, 'YTickLabel', {num2str(m) num2str(M)});
				set(cb, 'TickLength',[0 0]);
			end
		end
  end


