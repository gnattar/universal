%
% SP Nov 2010
%
% Plots a single timeSeriesArray (across trials) as a line.
%
% USAGE:
%
%  session.timeSeriesArray.plotTimeSeriesAsLineS(tsa, tsIdx, trialStartTimeMat, ESs, 
%     trialsPlotted, typeMatrix, typesPlotted, typeStr, typeColor, 
%     axisBounds, plotAxes, showLegend)
%
% PARAMS (* MUST PASS):
% 
%     *tsa - timeSeriesArray object
%     *tsIdx - idx of timeSeries within timeSeriesArray to plot
%     *trialStartTimeMat - start times of trials, with first column being trial #
%     ESs - the eventSeries objects you want to plot with this
%     trialsPlotted - which trials to plot?
%     typeMatrix - first column is trial # ; second is type
%     typesPlotted - indicate which types to plot ; otherwise all types
%     typeStr - corresponds to typePlotted, and is a cell array.  For legend.
%     typeColor - again, n x 3 matrix corresponding to typesPlotted with color
%     axisBounds - [xmin xmax ymin ymax] ; give nan to use plot's (i.e., auto).  
%     plotAxes - pass axes to plot onto ; optional.  (1) is for single-trial, (2)
%                is for mean.  Set either to nan and it will not be used.
%     showLegend - 0 means no legend ID'ing type of trial
%
function plotTimeSeriesAsLineS(tsa, tsIdx, trialStartTimeMat, pESs, pTrialsPlotted, pTypeMatrix, ...
     pTypesPlotted, pTypeStr, pTypeColor, pAxisBounds,pPlotAxes, pShowLegend)

  % --- input process
	if (nargin < 3) ; help('session.session.plotTimeSeriesAsLine') ; return ; end

  ESs = {};
	trialsPlotted = unique(tsa.trialIndices);
	typeMatrix = [];
	typesPlotted = [];
	typeStr = {};
	typeColor = [];
	axisBounds = [nan nan nan nan];
	plotAxes = [];
	showLegend = 0;
   
  if (nargin >=4 && length(pESs) > 0) ; ESs = pESs ; end
	if (~iscell(ESs)) ; ESs = {ESs}; end
	if (nargin >= 5 && length(pTrialsPlotted) > 0) ; trialsPlotted = pTrialsPlotted ; end
  if (nargin >= 6 && size(pTypeMatrix,1) > 0) ; typeMatrix = pTypeMatrix ; sortByType = 1; end
	if (nargin >= 7 && length (pTypesPlotted) > 0) ; typesPlotted = pTypesPlotted ; end
	if (nargin >= 8 && length (pTypeStr) > 0) ; typeStr = pTypeStr ; end
	if (nargin >= 9 && length (pTypeColor) > 0) ; typeColor = pTypeColor ; end
	if (nargin >= 10 && length(pAxisBounds) > 0) ; axisBounds = pAxisBounds ; end
	if (nargin >= 11 && length(pPlotAxes) > 0) ; plotAxes = pPlotAxes ; end
	if (nargin >= 12 && length(pShowLegend) > 0) ; showLegend= pShowLegend; end

	if (length(plotAxes) == 0) % generate new figure?
	  figure;
		plotAxes(1) = subplot(2,1,1);
		plotAxes(2) = subplot(2,1,2);
	end

  if (~iscell(typeStr)) ; typeStr = {typeStr} ; end
	if (length(typeColor) == 0) ; typeColor = jet(length(typesPlotted)) ; end
	if (length(typeStr) ~= length(typesPlotted)) ; showLegend = 0; end

	% --- single trial mode?
  singleTrialMode = 0;
	if (length(unique(trialsPlotted)) == 1)
	  singleTrialMode = 1;
	end

  % --- variables
  titleStr = [tsa.idStrs{tsIdx} ' ']; % desired addendums to title - e.g., when sorting by class
  
  % --- gather data

  % valid trials
	validTrialIds = nan*tsa.trialIndices;
	trialRow = nan*trialsPlotted;
	for t=1:length(trialsPlotted)
	  idx = find(tsa.trialIndices == trialsPlotted(t));

		tsti = find(trialStartTimeMat(:,1) == trialsPlotted(t));
	  trialStartTimes(t) = trialStartTimeMat(tsti,2);

		validTrialIds(idx) = trialsPlotted(t);
		trialRow(t) = trialsPlotted(t);
	end
  
	% get trial matrix centered on start times
	[timeMat dataMat timeVec] = tsa.getTrialMatrix(tsa.ids(tsIdx), trialsPlotted, trialStartTimes, 1);
	ntp = length(timeVec);

	% --- Plot individual trials on top
	if (~isnan(plotAxes(1)))
		axes(plotAxes(1));
		cla();
		hold on;
	end

	% --- build matrix with data from all trials of a type -- also plot single-trial data here

	% gather trial types -- ASSUME ONE TYPE ONLY!
	uti = trialsPlotted;
	type = nan*trialsPlotted;
	for t=1:length(uti)
	  tid = find(typeMatrix(:,1) == uti(t));
		if (length(tid) > 0)
			type(t) = typeMatrix(tid,2);
			if (length(typesPlotted) > 0 && length(find(typesPlotted == type(t))) == 0)
			  type(t) = nan;
				uti(t) = nan;
			end
		end
	end
	ut = unique(type(find(~isnan(type))));

  % where data will go based no class
	typeData = zeros(length(ut), ntp);
	typeErr = zeros(length(ut), ntp);

	% master loop over types
  legStr = {};
	for t=1:length(ut)
		vals = find(type == ut(t));
		tyi = find(typesPlotted == ut(t));
		typeCol = typeColor(tyi,:);
		dataCol(t,:) = typeCol;
		tTypeStr = '';

		for ti=1:ntp
		  svals = vals(find(~isnan(dataMat(vals,ti))));
			if (length(svals > 1))
				typeData(t,ti) = nanmean(dataMat(svals,ti));
				typeErr(t,ti) = nanstd(dataMat(svals,ti))/sqrt(length(svals)); % ERROR IS SE
			end
		end

		% plot raw
		if (~isnan(plotAxes(1)))
			for v=1:length(vals)
				plot(timeVec(1:ntp)/1000, dataMat(vals(v),1:ntp), 'Color', dataCol(t,:), 'LineWidth', 1);
			end
		end

		% if legend is on get legendary
		if (showLegend)
  		tTypeStr = typeStr{tyi};
	  	titleStr = [titleStr typeStr ' '];
		  legStr{t} = tTtypeStr;
		end
	end

  % --- plot averages
	% min, max from gui or default? ; also range 
  m = min(min(typeData));
	MM = mean(max(typeData));
	M = max(max(typeData));
	
	R = M-m;
%		datamat(find(datamat > M)) = M;
%		datamat(find(datamat < m)) = m;
	M = M + 0.25*R;
	m = m - 0.25*R;

	% plotting average
	if (~isnan(plotAxes(2)))
		axes(plotAxes(2));
		cla();
		hold on;
		for t=1:size(typeData,1)
			patchCol = [1 1 1]*.4;
			patchCol(find(dataCol(t,:) > 0)) = 0.8;
			plot_error_poly(timeVec/1000, typeData(t,:), typeErr(t,:), dataCol(t,:), patchCol);
		end
		for t=1:size(typeData,1)
			plot(timeVec/1000, typeData(t,:), 'Color', dataCol(t,:), 'LineWidth', 2);
		%  plot(timeVec/1000, typeData(c,:)+typeErr(c,:), 'Color', data_col(c,:), 'LineWidth', 1);
		%  plot(timeVec/1000, typeData(c,:)-typeErr(c,:), 'Color', data_col(c,:), 'LineWidth', 1);
	  end
	end

	% final embellishments
  if (~isnan(plotAxes(1)))
		axes(plotAxes(1));
		set(gca, 'TickDir', 'out');
		if (iscell(titleStr)) ; s = []; for t=1:length(titleStr) ; s = [s char(titleStr{t})] ; end ; titleStr = s; end
		title(titleStr);
	%	plot_event_stuff_axis(m,M,R);
		A = axis;
		if (length(axisBounds) == 4) 
			vax = find(~isnan(axisBounds));
			A(vax) = axisBounds(vax);
		end
		axis([A(1) A(2) A(3) A(4)]);
	end

  if (~isnan(plotAxes(2)))
	  if (isnan(plotAxes(1)))
			A = axis;
			if (length(axisBounds) == 4) 
				vax = find(~isnan(axisBounds));
				A(vax) = axisBounds(vax);
			end
			axis([A(1) A(2) A(3) A(4)]);
		end

		axes(plotAxes(2));
		set(gca, 'TickDir', 'out');
	%	plot_event_stuff_axis(m,M,R);
		xlabel('time (s)');
		% don't go for axis again, just apply it -- we want same for both, after all
		axis([A(1) A(2) A(3) A(4)]);
		if (length(legStr) >0 & showLegend);legend(legStr);end
  end

	% plot event stuff
	plotEventSeriesInTSAL(ESs, validTrialIds, plotAxes, singleTrialMode);

% 
% plots event stuff, axis
%
function plotEventSeriesInTSAL(ESs, validTrialIds, plotAxes, singleTrialMode)
  if (length(ESs) == 0) ; return ; end
  if (length(ESs{1}) == 0) ; return ; end

	% --- determine axis constraints
  if (~isnan(plotAxes(1)))
		axes(plotAxes(1));
		ax = axis;
		m1 = ax(3);
		M1 = ax(4);
		R1 = M1-m1;
	end

  if (~isnan(plotAxes(2)))
	  axes(plotAxes(2));
		ax = axis;
		m2 = ax(3);
		M2 = ax(4);
		R2 = M2-m2;
	end
 
  % no NaN allowed!
	validTrialIds = validTrialIds(~isnan(validTrialIds));
	uvti = unique(validTrialIds);

  % --- loop over event series passed
	for e=1:length(ESs)
    es = ESs{e};

		% is this an eventSEries that is special? bar movement, pole movement, airpuff  in such a case,
		%  we will plot with big lines
		specialES = 0;
		if (length(strfind(lower(es.idStr), 'bar')) + length(strfind(lower(es.idStr), 'reach')) + ...
		    length(strfind(lower(es.idStr), 'pole')) + length(strfind(lower(es.idStr), 'move')) > 1)
		  specialES = 1;
		end
		if (length(strfind(lower(es.idStr), 'period')) | length(strfind(lower(es.idStr), 'water valve')) | ...
		    length(strfind(lower(es.idStr), 'airpuff')))
		  specialES = 1;
		end

    if (singleTrialMode) % plot it all!$A
			for t=1:length(uvti);
				vti = uvti(t);
				vtii = find(es.eventTrials == vti);

				% single trial mode plot ALL of them
				et = es.eventTimesRelTrialStart(vtii);
				poffs = 0.9*R1; if (specialES) ; poffs = 0; end
				poffs2 = 0.9*R1; if (specialES) ; poffs2 = 0; end
				for ei=1:length(et)
				  if (~isnan(plotAxes(1)))
						axes(plotAxes(1));
						plot([1 1]*et(ei)/1000, [m1+poffs M1], '-', 'Color', es.color);
						if (es.type == 2) % 2 pronged event with start/end
							if (mod(ei,2) == 0)
								plot([et(ei) et(ei-1)]./1000, [m1+poffs m1+poffs], '-', 'Color', es.color);
							end
						end
					end
					if (~isnan(plotAxes(2)))
						axes(plotAxes(2));
						plot([1 1]*et(ei)/1000, [m2+poffs2 M2], '-', 'Color', es.color);
					  plot([et(ei) et(ei-1)]./1000, [m2+poffs2 m2+poffs2], '-', 'Color', es.color);
					end
				end
			end
		else
			% get *mean* time if not single trial mode, depending on type
			if (es.type == 2) % 2 pronged event with start/end
				eTimes = nan*ones(length(validTrialIds),2);
				for t=1:length(uvti);
					vti = uvti(t);
					vtii = find(es.eventTrials == vti);
					if (specialES & ~isempty(vtii))
						et = es.eventTimesRelTrialStart(vtii);
						eTimes(t,:) = et;
					end
				end

				eTimes = nanmean(eTimes);

				% plot it
				if (~isnan(plotAxes(1)))
					axes(plotAxes(1));
					plot([1 1]*eTimes(1)/1000, [m1 M1], '-', 'Color', es.color);
					plot([1 1]*eTimes(2)/1000, [m1 M1], '-', 'Color', es.color);
				end
				if (~isnan(plotAxes(2)))
					axes(plotAxes(2));
					plot([1 1]*eTimes(1)/1000, [m2 M2], '-', 'Color', es.color);
					plot([1 1]*eTimes(2)/1000, [m2 M2], '-', 'Color', es.color);
				end
			else % nromal event with many instances / trial
				eTimes = nan*es.eventTimes;
				for t=1:length(validTrialIds);
					vti = validTrialIds(t);
					vtii = find(es.eventTrials == vti);
					eTimes(vtii) = es.eventTimesRelTrialStart(vtii);
				end

				eTimes = nanmean(eTimes);
				% plot it
				if (~isnan(plotAxes(1)))
					axes(plotAxes(1));
					plot([1 1]*eTimes/1000, [m1 M1], '-', 'Color', es.color);
				end
				if (~isnan(plotAxes(2)))
					axes(plotAxes(2));
					plot([1 1]*eTimes/1000, [m2 M2], '-', 'Color', es.color);
				end
			end
		end
  end
