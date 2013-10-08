%
% SP May 2011
%
%
%  USAGE:
%
%    sA.plotCrosscorrCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    xTSAs: cell array of string representation of all TSAs used ; must pass
%           x/y are for rows/colums ; to do 'auto', just pass x alone.
%    xTSIds: cell array of numeric or string IDs of TS's for each TSA to get
%    yTSAs: cell array of string representation of all TSAs used ; must pass
%    yTSIds: cell array of numeric or string IDs of TS's for each TSA to get  
%
%    plotsShown: 1/0 means show/don't
%                (1): 'basic' plot where each timeseries pair is plotted
%    rangeR: [0 1] default 
%    corrShift: -20:20 default ; range of index shifts to do crosscorr on
%    sessions: which sessions to do?    
%
%  EXAMPLE: 
%
function plotCrosscorrCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotCrosscorrCrossDays');
		return;
	end

  % dflts
	plotsShown = [1];
	rangeR = [0 1];
	corrShift = -20:20;
	sessions = 1:length(obj.sessions);

  % pull required
  xTSAs = params.xTSAs;
  xTSIds = params.xTSIds;
	yTSAs = [];
	yTSIds = [];

  % pull optional
	if (isfield(params, 'yTSAs')) ; yTSAs = params.yTSAs; end
	if (isfield(params, 'yTSIds')) ; yTSIds = params.yTSIds; end
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'rangeR')) ; rangeR = params.rangeR; end
	if (isfield(params, 'corrShift')) ; corrShift = params.corrShift; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end

  % --- prelims

  if (length(yTSAs) == 0) ; yTSAs = xTSAs ; yTSIds = xTSIds; end
  if (~iscell(xTSAs)) ; xTSAs = {xTSAs} ; end
  if (~iscell(yTSAs)) ; yTSAs = {yTSAs} ; end

  if (length(xTSAs) == 1 && length(xTSIds) > 1)
	  tsBase = xTSAs{1};
	  for t=1:length(xTSIds) ; xTSAs{t} = tsBase; end
	end
  if (length(yTSAs) == 1 && length(yTSIds) > 1)
	  tsBase = yTSAs{1};
	  for t=1:length(yTSIds) ; yTSAs{t} = tsBase; end
	end

  % grab dem T's
	for si=1:length(sessions)
	  s = obj.sessions{si};
		for t=1:length(xTSAs)
			tsa = eval(['s.' xTSAs{t} ';']);
			if (isnumeric(xTSIds{t}))
				xts{si}{t} = eval(['tsa.getTimeSeriesById(' num2str(xTSIds{t}) ');']);
			else % string
				xts{si}{t} = eval(['tsa.getTimeSeriesByIdStr(' num2str(xTSIds{t}) ');']);
			end
		end
		for t=1:length(yTSAs)
			tsa = eval(['s.' yTSAs{t} ';']);
			if (isnumeric(yTSIds{t}))
				yts{si}{t} = eval(['tsa.getTimeSeriesById(' num2str(yTSIds{t}) ');']);
			else % string
				yts{si}{t} = eval(['tsa.getTimeSeriesByIdStr(' num2str(yTSIds{t}) ');']);
			end
		end
	end

	% --- meat
	for si=1:length(obj.sessions) ; sLabels{si} = obj.dateStr{si}(1:6); end
	sVec = nan*zeros(1,length(obj.sessions));

	% --- 1) 
	Sx = 1/(1.1*length(xTSAs));
	Sy = 1/(1.1*length(yTSAs));
	if (plotsShown(1))
	  figure('Position', [100 100 7.5*length(corrShift)*length(xTSAs) 7*length(sessions)*length(yTSAs)]);
	  for t1=1:length(xTSAs)
			px = (t1-1)/(1.1*length(xTSAs)) + 0.05;
			for t2=1:length(yTSAs)
		  	py = 1-(t2/length(yTSAs));
				ax = subplot('Position', [px py Sx Sy]);
				corrMat = nan*zeros(length(sessions),length(corrShift));
				for si=1:length(sessions); 
				  ts1 = xts{si}{t1};
				  ts2 = yts{si}{t2};
					if (isobject(ts1) && isobject(ts2))
						corrMat(si,:) = session.timeSeries.computeCorrelationS(ts1, ts2, corrShift);
					end
				end
				imshow(corrMat, rangeR, 'Parent', ax , 'Border', 'tight');
				if (t2 == 1) ; title(ts1.idStr) ; end
				if (t1 == 1) ; ylabel(ts2.idStr) ; end

				% line @ t=0
				xVal = find(corrShift == 0);
				if (length(xVal) == 1)
					hold on ; 
					A  = axis;
					plot([1 1]*xVal, [A(3) A(4)], 'k-', 'LineWidth', 3);
				end
			end
		end
		colormap (jet);
	end

