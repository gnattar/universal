%
% SP Nov 2010
%
% Plots a single timeSeriesArray across trials aligned to a particular event.  
%  If multiple events take place per trial will align to evNum, if passed,
%  or 1.
%
% USAGE:
%
%   [mumax semumax medmax iqrmedmax nev] = s.plotEventTriggeredAverageS (tsa, tsIdx, es, ...
%     eventNum, axisBounds, plotAxes, ...
%     col, timeWindow, esExclude, esExcludeTimeWindow, showN, allowOverlap)
%
%     You can control trials plotted by setting s.validTrialIds.
%
%     mumax: max mean value FOLLOWING event within timeWindow (i.e., [0 timeWindow(2)])
%     semumax: standard error @ this point
%     medmax: maximum median value following event
%     iqrmedmax: IQR (0.5 * range 25-75%iles) at this point
%     nev: # events included
%
%     tsa - timeSeriesArray object used ; alternatively, pass JUST a timeSeries,
%           and leave tsIdx blank
%     tsIdx - idx of timeSeries within timeSeriesArray to plot
%     es - eventSeries object used
%     eventNum - event number plotted ; Inf -> last / trial ; blank/0 means 
%       don't worry about trial (default) and plot 'freeform' ; negative value 
%       means use BURST TIME (e.g., -1000 means getBurstTimes(1000))
%     axisBounds - [xmin xmax ymin ymax] ; give nan to use plot's ; xmin, xmax are 
%       relative to 0 - the event time
%     plotAxes - axes object to plot to ; set to nan to suppress that particular plot
%                1: raw
%                2: mean
%     col - color of the line
%     timeWindow - in s ; 0 is time of event ; so [-5 5] would show +/- 5 secionds 
%     esExclude - cell array of eventSeries that, if they have an event in the
%       time of esExcludedWindow, the es event is excluded
%     esExcludeTimeWindow - time window over which exclusion is applied to esExclude
%     showN - if 1, shows # of trials included in average ; 0 default ; if 2 element
%             vector, will put the text at that coordinate [x y]
%     avgType - 1 (default): mean +/-SE ; 2 median +/0 IQR
%     allowOverlap - 0 default
%
function [mumax semumax medmax iqrmedmax nev] = plotEventTriggeredAverageS(tsa, tsIdx, ...
  es, eventNum, axisBounds, plotAxes, col, timeWindow, esExclude, esExcludeTimeWindow, showN, ...
	avgType, allowOverlap)
  % --- definitions
	windowTimeUnit = 2; % s

  % --- input process
	if (nargin < 3)  
	  help session.session.plotEventTriggeredAverageS;
		disp('========================================================================================================================');
	  disp('plotEventTriggeredAverageS::at minimum, must specify a timeSeries object to show and the eventSeries.'); 
		return ; 
	end
	if (nargin < 4 || length(eventNum) == 0)
	  eventNum = 0;
	end
	if (nargin < 5 || length(axisBounds) == 0 ) 
	  axisBounds = [nan nan nan nan];
	end
	if (nargin < 6 || length(plotAxes) == 0) % generate new figure?
	  figure;
		plotAxes(1) = subplot(2,1,1);
		plotAxes(2) = subplot(2,1,2);
	end
	if (nargin < 7 || length(col) == 0) % color
	  col = [0 0 0];
	end
	if (nargin < 8 || length(timeWindow) == 0) % time window
    timeWindow = [-5 5];
  end
	if (nargin < 9) % eventSEries excluded
	  esExclude = {};
	end
	if (nargin < 10 || length(esExcludeTimeWindow) == 0) % exclusion time window
	  esExcludeTimeWindow = timeWindow;
	end
	if (nargin < 11 || length(showN) == 0) % show # of trials
	  showN = 0;
	end
	if (nargin < 12 || length(avgType) == 0) % median or mean?
	  avgType = 1;
	end
	if (nargin < 13 || length(allowOverlap) == 0)
	  allowOverlap = 0;
	end

	% TS prepare -- either pull if timeSeriesArray, or just use 
	if (strcmp(class(tsa), 'session.timeSeriesArray'))
	  ts = tsa.getTimeSeriesByIdx(tsIdx);
	elseif (strcmp(class(tsa), 'session.timeSeries'))
	  ts = tsa;
	else
	  help session.session.plotEventTriggeredAverageS;
		disp('========================================================================================================================');
	  disp('plotEventTriggeredAverageS::tsa must be either a timeSeriesArray or timeSeries.'); 
		return ; 
	end


  % --- variables
	mumax = [];
	semumax = [];
	medmax = [];
	iqrmedmax = [];
  titleStr = [ts.idStr ' aligned to ' es.idStr]; % desired addendums to title - e.g., when sorting by class

	% convert time to proper unit (ms)
	timeUnit = 1; % ALWAYS
  timeWindow = timeWindow * 1000;
	esExcludeTimeWindow = esExcludeTimeWindow * 1000;

  excludeEventTimes = [];
  for e=1:length(esExclude)
  	excludeEventTimes = [excludeEventTimes esExclude{e}.eventTimes];
	end

  % --- grab data
	if (eventNum < 0)
		[nEventTimes nEventTrials] = es.getBurstTimes(-1*eventNum);	
	else
		[nEventTimes nEventTrials] = es.getNthEventByTrial(eventNum);	
	end
  nES = session.eventSeries(nEventTimes,nEventTrials,timeUnit);

	% returns indices with specified properties
	[dataMat timeMat idxMat plotTimeVec] = ts.getValuesAroundEvents(nES, timeWindow, timeUnit, ...
		  allowOverlap, esExclude, timeWindow);


	% --- now take nanmean across trials -- this is your output
	plotTimeVec = plotTimeVec/1000; % ms -> s
	nev = size(dataMat,1);
	if (min(size(dataMat)) > 1)
		plotMeanData = nanmean(dataMat);
		plotMedianData = nanmedian(dataMat);
		plotSEData = nanstd(dataMat)/sqrt(size(dataMat,1));
		plotIQRData = 0.5*iqr(dataMat);

	else
	  plotMedianData = dataMat;
	  plotMeanData = dataMat;
		plotSEData = 0*dataMat;
		plotIQRData = 0*dataMat;
	end

  % --- plot -- singulars, mean
	patchCol = [1 1 1]*.4;
	patchCol(find(col > 0)) = 0.8;

  % if possible, plot the event-indicating line NOW
	evLinePlotted = 0;
	if (length(axisBounds) == 4 & sum(isnan(axisBounds)) == 0)
	  evLinePlotted =1;
  	if (~isnan(plotAxes(1)))
		  axes(plotAxes(1));
			hold on;
	  	plot([0 0], [axisBounds(3) axisBounds(4)], '-', 'Color', [1 0.5 0.5],  'LineWidth', 2);
		end

		if (~isnan(plotAxes(2)))
		  axes(plotAxes(2));
			hold on;
	  	plot([0 0], [axisBounds(3) axisBounds(4)], '-', 'Color', [1 0.5 0.5],  'LineWidth', 2);
		end
	end

  % main plot
  if (~isnan(plotAxes(1)))
		axes(plotAxes(1));
		for t=1:size(dataMat,1)
			hold on;
   		plot(plotTimeVec,dataMat(t,:), 'Color', col);
		end
	end

  if (~isnan(plotAxes(2)))
		axes(plotAxes(2));
		if (avgType == 1)
			plot_error_poly(plotTimeVec, plotMeanData, plotSEData, col, patchCol);
			hold on;
			if (length(plotTimeVec) == length(plotMeanData))
				plot(plotTimeVec,plotMeanData, 'Color', col, 'LineWidth', 2);
			end
		elseif (avgType == 2)
			plot_error_poly(plotTimeVec, plotMedianData, plotIQRData, col, patchCol);
			hold on;
			if (length(plotTimeVec) == length(plotMedianData))
				plot(plotTimeVec,plotMedianData, 'Color', col, 'LineWidth', 2);
			end
    end
	end

	% compute mumax, semumax
	val = find(plotTimeVec >= 0);
	if (length(val) > 0)
	  [irr idx] = max(plotMeanData(val));
		mumax = plotMeanData(val(idx));
		semumax = plotSEData(val(idx));
	  [irr idx] = max(plotMedianData(val));
		medmax = plotMedianData(val(idx));
		iqrmedmax = plotIQRData(val(idx));
	end

  % --- plot cleanup
  if (~isnan(plotAxes(1)))
		axes(plotAxes(1));
		if (iscell(titleStr)) ; s = []; for t=1:length(titleStr) ; s = [s char(titleStr{t})] ; end ; titleStr = s; end
		title([titleStr '; ' num2str(size(dataMat,1)) ' events.']);
		A = axis;
	end

	for i=1:2
		if (~isnan(plotAxes(i)))
			axes(plotAxes(i));
			set(gca, 'TickDir', 'out');
			if (length(axisBounds) == 4) 
				vax = find(~isnan(axisBounds));
				A(vax) = axisBounds(vax);
			end
			axis([A(1) A(2) A(3) A(4)]);

			% plot a line @ t =  0 -- the event
			if (~evLinePlotted)
  			hold on;
	  		plot([0 0], [A(3) A(4)], '-', 'Color', [1 0.5 0.5], 'LineWidth', 2);
			end
		end
  end

  if (~isnan(plotAxes(2)))
		axes(plotAxes(2));
		A = axis;
	  if (length(showN) ==1 & showN) 
		  text(0,0,['n=' num2str(size(dataMat,1))], 'Color', col); 
		elseif (length(showN) ==2)
		  text(showN(1),showN(2),['n=' num2str(size(dataMat,1))], 'Color', col); 
		end
		xlabel('Time (s)');
	end


