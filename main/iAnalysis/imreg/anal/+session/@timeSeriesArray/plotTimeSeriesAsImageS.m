%
% SP Nov 2010
%
% Plots a single timeSeries  (across trials) as an im with pixel intensity
%  denoting the value.  Note that this resides in timeSeriesArray because
%  it depends on trial #, etc.
%
% USAGE:
%
%  session.timeSeriesArray.plotTimeSeriesAsImageS(tsa, tsIdx, trialStartTimeMat, ESs, trialsPlotted, typeMatrix,
%     typesPlotted, sortByType, colorMap, xAxisBounds, valueRange, plotAxes, mouseClickCallback)
%
% PARAMS (* MUST PASS):
% 
%     *tsa - timeSeriesArray object
%     *tsIdx - idx of timeSeries within timeSeriesArray to plot
%     *trialStartTimeMat - start times of trials, with first column being trial #
%     ESs - the eventSeries objects you want to plot with this
%     trialsPlotted - which trials to plot?  Note that you can use this to sort
%                     the trials in a non-ascending order -- trials will be 
%                     plotted according to ordering of this vector.
%     typeMatrix - first column is trial # ; second is type
%     typesPlotted - indicate which types to plot ; otherwise all types
%     sortByType - 1(default IF you pass typeMatrix): sort by type 0: don't
%     colorMap - colormap to use ; must be 256 long [actual 256x3 matrix, not the name!]
%     xAxisBounds - bounds on x axis ; nan means use default
%     valueRange - range to use for image values -- data is compressed to this range
%                  if not specified, max-min is used ; nan in either one means use [max/min] for it.
%     plotAxes - pass axes to plot onto ; optional.  If blank, new figure.
%     mouseClickCallback - called if you click the mouse.  This should be a cellarray.  Note that
%                          this function is called only AFTER the internal function determines the
%                          trial clicked on, passing it as the final variable.
%
function plotTimeSeriesAsImageS(tsa, tsIdx, trialStartTimeMat, pESs, pTrialsPlotted, pTypeMatrix, ...
                               pTypesPlotted, pSortByType, pColorMap, pXAxisBounds, pValueRange, ...
															 pPlotAxes, pMouseClickCallback)
  % --- input process
	if (nargin < 3) ; help('session.session.plotTimeSeriesAsImageS') ; return ; end

  ESs = {};
	trialsPlotted = unique(tsa.trialIndices);
	typeMatrix = [];
	typesPlotted = [];
	sortByType = 0;
	colorMap = jet(256);
	xAxisBounds = [nan nan];
	valueRange = [nan nan];
	plotAxes = [];
	mouseClickCallback = [];
   
  if (nargin >=4 && length(pESs) > 0) ; ESs = pESs ; end
	if (~iscell(ESs)) ; ESs = {ESs}; end
	if (nargin >= 5 && length(pTrialsPlotted) > 0) ; trialsPlotted = pTrialsPlotted ; end
  if (nargin >= 6 && size(pTypeMatrix,1) > 0) ; typeMatrix = pTypeMatrix ; sortByType = 1; end
	if (nargin >= 7 && length (pTypesPlotted) > 0) ; typesPlotted = pTypesPlotted ; end
	if (nargin >= 8 && length(pSortByType) > 0) ; sortByType = pSortByType ; end
	if (nargin >= 9 && length(pColorMap) > 0) ; colorMap = pColorMap ; end
	if (nargin >= 10 && length(pXAxisBounds) > 0) ; xAxisBounds = pXAxisBounds ; end
	if (nargin >= 11 && length(pValueRange) > 1) ; valueRange = pValueRange ; end
	if (nargin >= 12 && length(pPlotAxes) > 0) ; plotAxes = pPlotAxes ; end
	if (nargin >= 13 && length(pMouseClickCallback) > 0) ; mouseClickCallback = pMouseClickCallback; end

	if (length(plotAxes) == 0) ; figure; plotAxes =axes ; end

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

	% --- build matrix with data from all trials of a type -- also plot single-trial data here

	% gather trial types -- ASSUME ONE TYPE ONLY!
	uti = trialsPlotted;
	type = nan*trialsPlotted;
  if (size(typeMatrix,1) > 0)
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
  else
    type = 1 + 0*trialsPlotted;
  end
	ut = unique(type(find(~isnan(type))));

	% setup trial loop - either sequential or by type
	trialVec = [];
	yLabel = '';
	if (sortByType)
	  % loop 
		for t=1:length(ut)
			vals = uti(find(type == ut(t)));
			trialVec = [trialVec vals];
			if (t < length(ut)) % separator
				trialVec = [trialVec -2 -2 -2];
			end
		end
	else
	  trialVec = uti(find(~isnan(uti)));
		yLabel = 'trial #';
	end

  % instantiate the im
	im = -1*double(ones(length(trialVec), ntp));

	% loop through trials
	for t=1:length(trialVec)
	  if (trialVec(t) > 0)
			idx = find(trialRow == trialVec(t));
			%im(length(trialVec)-t+1,1:length(idx)) = tsa.valueMatrix(tsIdx, idx);
      if (length(idx) > 0)
			  im(length(trialVec)-t+1,:) = dataMat(idx,:);
      end
		else
			im(length(trialVec)-t+1,:) = -2;
		end
	end
	im(find(isnan(im))) = -1; % treat nan as missing data

	% --- plot it
	axes(plotAxes);
	cla();
	set(gca,'visible','off');
	hold on;

	% set min/max etc
	m = min(min(tsa.valueMatrix));
	if (~isnan(valueRange(1))); m = valueRange(1); end
	M = max(max(tsa.valueMatrix));
	if (~isnan(valueRange(2))); M = valueRange(2); end
	lineIdx = find(im == -2);
	nodatIdx = find(im == -1);
	im = im - m; % make it so that min is 0
  im = im/(M-m); % now it will all be [0 1]
  im = round(im*253)+3;
	im(find(im < 3)) = 3;
	im(lineIdx) = 2;
	im(nodatIdx) = 1;
	dt = mode(diff(timeVec))/1000;
  % actual plot
	h = image(im, 'XData', (dt/2)+[min(timeVec)/1000 (max(timeVec)/1000)-dt-dt/4]);
  if (length(mouseClickCallback) > 0)
    set(h,'ButtonDownFcn', {@mouseClickProcessor, trialVec, mouseClickCallback});
	end

  A = axis;
	if (~isnan(xAxisBounds(1))); A(1) = xAxisBounds(1); end
	if (~isnan(xAxisBounds(2))); A(2) = xAxisBounds(2); end
  
  if (length(trialVec) == 0)
  	axis([A(1) A(2) 0.5 1.5]);
  else
  	axis([A(1) A(2) 0.5 0.5+length(trialVec)]);
  end
	set(gca, 'TickDir', 'out');
	colorMap(1,:) =  0.3*[1 0 0]; % grey for missing data
	colorMap(2,:) =  1*[1 1 1]; % white line for trial type separator
	colormap(colorMap);

	ylabel(yLabel);
	xlabel('time (s)');
	if (iscell(titleStr)) ; s = []; for t=1:length(titleStr) ; s = [s char(titleStr{t})] ; end ; titleStr = s; end
	title(titleStr);
	set(gca,'visible','on');

	% --- superimpose events
  plotEventSeriesInTSAI( ESs, trialVec);

	% --- lock colormap
	extern_freezeColors;

%
% mouse click callback wrapper
%
function mouseClickProcessor (src, evt, trialVec, mouseClickCallback)
  % -- extract trial #
  mousePos = get(get(src,'Parent'),'CurrentPoint');
	y = mousePos(1,2);
  y = length(trialVec)-y+1;
	tn = trialVec(round(y));

	% --- call secondary procesor
	mouseClickCallback{length(mouseClickCallback)+1} = tn;
	feval (mouseClickCallback{1}, mouseClickCallback{2:end});


% 
% plots event stuff, axis
%
function plotEventSeriesInTSAI( ESs, trialVec)
  if (length(ESs) == 0) ; return ; end
  %if (length(ESs{1}) == 0) ; return ; end

	% --- determine axis constraints
	ax = axis;
	m1 = ax(3);
	M1 = ax(4);

  % --- loop over event series passed
	L = length(trialVec);
	for e=1:length(ESs)
	  es = ESs{e};

    % loop over valid trials
		for t=1:length(trialVec)
		  if (trialVec(t) == -1) ; continue ; end % separator
			vti = find(es.eventTrials == trialVec(t));
			eTimes = es.eventTimesRelTrialStart(vti);
			for v=1:length(vti) % loop over matching events
				%plot([1 1]*eTimes(v)/1000, L-[t-1.5 t-0.5], '-', 'Color', es.color, 'LineWidth', 1);
				plot([1 1]*eTimes(v)/1000, L-[t-1.25 t-0.75], '-', 'Color', es.color, 'LineWidth', 2);
			end
		end
	end
