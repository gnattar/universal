%
% SP May 2011
%
% Wrapper for calling session.session.plotTimeSeriesAsImage for multiple sessions.
%
% USAGE:
%
%  sA.plotTimeSeriesAsImageCrossDays(params)
%
% PARAMS:
%
%  params: structure with following fields:
%
%    sessions: indices of sessions within sA to plot
%    displayedTSA: STRING name of TSA to show
%    displayedTSAId: NUMBER of ID to show ; if vector, will make a figure for EACH
%    displayedESs: cell array of STRINGS with names of event series to show
%    timeRange: time range shown ([0 10])
%    valueRange: value range for colormap ([0 1])
%    nPanels: how to arrange plot [cols rows]
%    printDir: if specified, will print figure to this directory
%
% EXAMPLE 1: plot dff time series for roi 42 across all days
%
%   params.displayedTSA = 'caTSA.dffTimeSeriesArray';
%   params.displayedTSAId = 42;
%   params.displayedESs = {'whiskerBarInReachES'};
%   sA.plotTimeSeriesAsImageCrossDays(params)
%   
function plotTimeSeriesAsImageCrossDays(obj, params)
  % --- params
	if (nargin < 2) 
	  help('session.sessionArray.plotTimeSeriesAsImageCrossDays');
		return;
	end

  % params structure
	sessions = 1:length(obj.sessions);
	displayedESs = [];
	timeRange = [0 10];
	valueRange = [0 1];
	nPanels = [];
	printDir = [];
	printFname = [];
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'displayedTSA')) ; displayedTSA = params.displayedTSA; end
	if (isfield(params, 'displayedTSAId')) ; displayedTSAId = params.displayedTSAId; end
	if (isfield(params, 'displayedESs')) ; displayedESs = params.displayedESs; end
	if (isfield(params, 'timeRange')) ; timeRange = params.timeRange; end
	if (isfield(params, 'valueRange')) ; valueRange = params.valueRange; end
	if (isfield(params, 'nPanels')) ; nPanels = params.nPanels; end
	if (isfield(params, 'printDir')) ; printDir = params.printDir; end

	% --- main loop thru sessions
	for d=1:length(displayedTSAId)
		figure('Name' , ['ID ' num2str(displayedTSAId(d))], 'NumberTitle', 'off');
		printFname = [obj.mouseId '_cell_' num2str(displayedTSAId(d)) '_cross_days_image.pdf'];
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

			% setup figure
			row = ceil(i/nCols);
			dr = 1/nRows;
			dc = 1/nCols;
			sx = 0.8/nCols;
			ox = 0.2/nCols;
			sy = 0.8/nRows;
			oy = 0.1/nRows;
			col = i-((row-1)*nCols);
			axRef = subplot('Position', [(col-1)*dc+ox 1-(row*dr)+oy sx sy]);

			% pull data
			tsa = eval(['s.' displayedTSA]);
			esShown = {};
			for e=1:length(displayedESs)
				esShown{1} = eval(['s.' displayedESs{e}]);
			end

			% call plotter
			tsIdx = find(tsa.ids == displayedTSAId(d));
			s.plotTimeSeriesAsImage(tsa, tsIdx, esShown, [],[],[], timeRange, valueRange, axRef);

			% remove excess labeling
			set(get(axRef,'Title'),'String', obj.dateStr{si});
			ylabel('');
			set(axRef,'YTick',[]);
			if (row < nRows) ; set(axRef,'XTick',[]); xlabel(''); end
			
		end

		% print?
		if (length(printDir) > 0)
			printFname = [printDir filesep printFname];
		 
			set(gcf,'Position', [1 1 3840 1200]);
			set(gcf,'PaperPositionMode','auto', 'PaperSize', [22 15], 'PaperUnits', 'inches');
      print('-dpdf', printFname, '-noui','-zbuffer' , '-r300');
			close;
		end
	end

