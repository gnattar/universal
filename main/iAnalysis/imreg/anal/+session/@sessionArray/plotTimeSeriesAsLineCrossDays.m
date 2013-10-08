%
% SP May 2011
%
% Wrapper for calling session.session.plotTimeSeriesAsLine for multiple sessions.
%
% USAGE:
%
%  sA.plotTimeSeriesAsLineCrossDays(params)
%
% PARAMS:
%
%  params: structure with following fields:
%
%    sessions: indices of sessions within sA to plot
%    displayedTSA: STRING name of TSA to show
%    displayedTSAId: NUMBER of ID to show
%    displayedESs: cell array of STRINGS with names of event series to show
%    timeRange: time range shown ([0 10])
%    valueRange: value range for colormap ([0 1])
%    nPanels: how to arrange plot [cols rows]
%
% EXAMPLE 1: plot dff time series for roi 42 across all days
%
%   params.displayedTSA = 'caTSA.dffTimeSeriesArray';
%   params.displayedTSAId = 42;
%   params.displayedESs = {'whiskerBarInReachES'};
%   sA.plotTimeSeriesAsLineCrossDays(params)
%   
function plotTimeSeriesAsLineCrossDays(obj, params)
  % --- params
	if (nargin < 2) 
	  help('session.sessionArray.plotTimeSeriesAsLineCrossDays');
		return;
	end

  % params structure
	sessions = 1:length(obj.sessions);
	displayedESs = [];
	timeRange = [0 10];
	valueRange = [0 1];
	nPanels = [];
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'displayedTSA')) ; displayedTSA = params.displayedTSA; end
	if (isfield(params, 'displayedTSAId')) ; displayedTSAId = params.displayedTSAId; end
	if (isfield(params, 'displayedESs')) ; displayedESs = params.displayedESs; end
	if (isfield(params, 'timeRange')) ; timeRange = params.timeRange; end
	if (isfield(params, 'valueRange')) ; valueRange = params.valueRange; end
	if (isfield(params, 'nPanels')) ; nPanels = params.nPanels; end

	% --- main loop thru sessions
	meanFig = figure('Name' , ['ID ' num2str(displayedTSAId)], 'NumberTitle', 'off');
	rawFig = figure('Name' , ['ID ' num2str(displayedTSAId)], 'NumberTitle', 'off');
	if (length(nPanels) == 0)
		nCols = ceil(sqrt(length(sessions)));
		nRows = ceil(sqrt(length(sessions)));
	else
	  nCols = nPanels(1);
		nRows = nPanels(2);
	end

	for i=1:length(sessions)
	  si = sessions(i);
		s = obj.sessions{si};

		% setup figures
		row = ceil(i/nCols);
		dr = 1/nRows;
		dc = 1/nCols;
		sx = 0.8/nCols;
		ox = 0.2/nCols;
		sy = 0.8/nRows;
		oy = 0.1/nRows;
		col = i-((row-1)*nCols);

    figure(meanFig);
		axRef(1) = subplot('Position', [(col-1)*dc+ox 1-(row*dr)+oy sx sy]);
    figure(rawFig);
		axRef(2) = subplot('Position', [(col-1)*dc+ox 1-(row*dr)+oy sx sy]);

		% pull data
		tsa = eval(['s.' displayedTSA]);
		esShown = {};
		for e=1:length(displayedESs)
		  esShown{1} = eval(['s.' displayedESs{e}]);
		end

		% call plotter
		tsIdx = find(tsa.ids == displayedTSAId);
		s.plotTimeSeriesAsLine(tsa, tsIdx, esShown, [],[],[timeRange(1:2) valueRange(1:2)], axRef, 0);

		% remove excess labeling
		axis(axRef(1));
		set(get(axRef(1),'Title'),'String', obj.dateStr{si});
		ylabel('');
		set(axRef(1),'YTick',[]);
		if (row < nRows) ; set(axRef(1),'XTick',[]); xlabel(''); end
		axis(axRef(2));
		set(get(axRef(2),'Title'),'String', obj.dateStr{si});
		ylabel('');
		set(axRef(2),'YTick',[]);
		if (row < nRows) ; set(axRef(2),'XTick',[]); xlabel(''); end
    
	end

 
