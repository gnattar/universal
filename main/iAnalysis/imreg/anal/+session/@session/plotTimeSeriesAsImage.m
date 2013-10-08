%
% SP Nov 2010
%
% Plots a single timeSeriesArray (across trials) as an im with pixel intensity
%  denoting the value.
%
% USAGE:
%
%   s.plotTimeSeriesAsImage(tsa, tsIdx, ESs, typesPlotted, sortByType, colorMap, xAxisBounds, valueRange, plotAxes).  
%
%     You can control trials plotted by setting s.validTrialIds.  You can also
%       control sort this way -- this method will start with LOWEST validTrialIds
%       at top and go down, breaking into type blocks if desired.  This means you
%       can sort against some other variable by simply pre-sorting the 
%       validTrialIds vector.
%
%     tsa - timeSeriesArray object ; mostly this uses valueMatrix
%     tsIdx - idx of timeSeries within timeSeriesArray to plot
%     ESs - the eventSeries objects you want to plot with this
%     typesPlotted - indicate which types to plot ; otherwise all types
%     sortByType - 1(default): sort by type 0: don't
%     colorMap - colormap to use ; must be 256 long [actual 256x3 matrix, not the name!]
%     xAxisBounds - bounds on x axis ; nan means use default
%     valueRange - range to use for image values -- data is compressed to this range
%                  if not specified, max-min is used ; nan in either one means use [max/min] for it.
%     plotAxes - pass axes to plot onto ; optional.  If blank, new figure.
%
function plotTimeSeriesAsImage(obj, tsa, tsIdx, ESs, typesPlotted, sortByType, colorMap, xAxisBounds, valueRange, plotAxes)
  % --- input process
	if (nargin < 3) ; help('session.session.plotTimeSeriesAsImage') ; return ; end
	if (nargin < 4)
	  ESs = {};
	elseif (~iscell(ESs)) % just one?
	  ESs = {ESs};
	end
	if (nargin < 5)
	  typesPlotted = obj.trialType;
	end
	if (length(typesPlotted) == 0)
	  typesPlotted = obj.trialType;
	end
	if (nargin < 6)
	  sortByType = 1;
	elseif (length(sortByType) == 0)
	  sortByType = 1;
	end
	if (nargin < 7)
	  colorMap = jet(256);
	elseif (size(colorMap,1) ~= 256)
		if (length(colorMap) > 0)disp('plotTimeSeriesAsImage::your colormap must be length 256'); end
	  colorMap = jet(256);
	end
	if (nargin < 8) 
	  xAxisBounds = [nan nan];
	elseif (length(xAxisBounds) ~= 2)
	  xAxisBounds = [nan nan];
	end
	if (nargin < 9)
	  valueRange = [nan nan];
	elseif (length(valueRange) ~= 2)
	  valueRange = [nan nan];
	end
	if (nargin < 10) % generate new figure?
	  figure;
		plotAxes = axes;
	end

  % --- variables
  titleStr = [tsa.idStrs{tsIdx} ' ']; % desired addendums to title - e.g., when sorting by class
  
  % --- gather data

  % valid trials
	[irr1 irr2 ivt] = intersect(unique(tsa.trialIndices), obj.validTrialIds);
	vt = obj.validTrialIds(sort(ivt)); % retain ordering of validTrialIds
	%vt = intersect(unique(tsa.trialIndices), obj.validTrialIds);
	validTrialIds = nan*tsa.trialIndices;
	if(size(validTrialIds,2) == 1) ; validTrialIds = validTrialIds'; end
	trialStartTimes = nan*vt;
	trialRow = nan*vt;
	for t=1:length(vt)
	  idx = find(tsa.trialIndices== vt(t));
		validTrialIds(idx) = vt(t);
		idxTrialId = find(obj.trialIds == vt(t));
		trialStartTimes(t) = obj.trialStartTimes(idxTrialId);
		trialRow(t) = vt(t);
	end
  
	% get trial matrix centered on start times
	[timeMat dataMat timeVec] = tsa.getTrialMatrix(tsa.ids(tsIdx), vt, trialStartTimes, 1);
	ntp = length(timeVec);

	% --- build matrix with data from all trials of a type -- also plot single-trial data here

	% gather trial types -- ASSUME ONE TYPE ONLY!
	uti = obj.validTrialIds;
	type = nan*obj.validTrialIds;
	for t=1:length(uti)
	  tid = find(obj.trialIds == uti(t));
		if (length(tid) > 0)
			type(t) = obj.trial{tid}.typeIds(1);
			if (length(find(typesPlotted == type(t))) == 0)
			  type(t) = nan;
				uti(t) = nan;
			end
		end
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
			yLabel = [obj.trialTypeStr{ut(t)} ' ' yLabel];
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
  set(h,'ButtonDownFcn', {@mouseClickProcessor, obj, trialVec});

	%figure;hist(reshape(im,[],1),100); pause

  A = axis;
	if (~isnan(xAxisBounds(1))); A(1) = xAxisBounds(1); end
	if (~isnan(xAxisBounds(2))); A(2) = xAxisBounds(2); end
	axis([A(1) A(2) 0.5 0.5+length(trialVec)]);
	set(gca, 'TickDir', 'out');
	colorMap(1,:) =  0.15*[1 1 1]; % grey for missing data
	colorMap(2,:) =  1*[1 1 1]; % white line for trial type separator
	colormap(colorMap);

	ylabel(yLabel);
	xlabel('time (s)');
	if (iscell(titleStr)) ; s = []; for t=1:length(titleStr) ; s = [s char(titleStr{t})] ; end ; titleStr = s; end
	title(titleStr);
	set(gca,'visible','on');

	% --- superimpose events
  plotEventSeriesInTSAI(obj, ESs, trialVec)

% 
% plots event stuff, axis
%
function plotEventSeriesInTSAI(obj, ESs, trialVec)
  if (length(ESs) == 0) ; return ; end
  if (length(ESs{1}) == 0) ; return ; end

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

%
% tells you where you clicked (trial #)
%
function mouseClickProcessor (src, evt, obj, trialVec)
  % -- extract event data
  mousePos = get(get(src,'Parent'),'CurrentPoint');
	y = mousePos(1,2);
  y = length(trialVec)-y+1;
	tn = trialVec(round(y));
	wtn = 0;
	if (tn > 0)
		wtn = find(obj.ephusOriginalTrialBitcodes == tn);
	end
	disp(['Trial # Ca: ' num2str(tn) ' ephus/whisker: ' num2str(wtn)]);

	% --- plot trial singularly?
	if (isstruct(obj.guiData) && isfield(obj.guiData,'TSBrowser') && ...
	  isstruct(obj.guiData.TSBrowser) && isfield(obj.guiData.TSBrowser,'trialPlotOn') && ...
		obj.guiData.TSBrowser.trialPlotOn == 1)
    if (~isfield(obj.guiData.TSBrowser,'trialPlotHandle') || ...
        length(obj.guiData.TSBrowser.trialPlotHandle) == 0 || ...
		    ~ishandle(obj.guiData.TSBrowser.trialPlotHandle(1)))
			lineFigH(1) = figure('Position',[100 100 800 400], 'Name', 'Single Trial', 'NumberTitle','off');
			lineFigH(3) = nan; % no avg
			lineFigH(2) = axes('Position',[0.05 .05 .45 .9]); % left
			lineFigH(5) = nan; % no avg
			lineFigH(4) = axes('Position',[0.5375 .05 .45 .9]); % right
      obj.guiData.TSBrowser.trialPlotHandle = lineFigH;
    end

		% update
		obj.guiData.TSBrowser.trialPlotTrialNumber = tn;
    obj.guiTSBrowser('updateSingleTrialPlot');
	end
