%
% SP Mar 2011
%
% For plotting the cross correlation between two timeseries with a set of 
%  index-based offsets.  Uses session.timeSeries.computeCorrelationS to do 
%  work.
%
% USAGE:
%
%  session.session.plotTSCrossCorrelationS(tsaA, tsAId, tsaB, tsBId, ...
%    offsets, ax, corrType);
%
%  tsaA, tsaB: timeSeriesArray objects 
%  tsAId, tsBId: Id within the two timeSeries that is considered
%  offsets: offsets considered, in terms of INDEX shifts ; applied to tsaB
%  ax: axes to plot in ; leave out or [] to do new figure
%  corrType: Pearson is default, can be Spearman or Kendall
%  color: color of the line plotted
%
function plotTSCrossCorrelationS(tsaA, tsAId, tsaB, tsBId, offsets, ax, corrType, color);
  % --- arg check
	if (nargin < 5) 
	  help session.session.plotTSCrossCorrelationS;
		return;
	end

	if (nargin < 6 || length(ax) == 0)
	  figure;
		ax = axes;
	end

	if (nargin < 7 || length(corrType) == 0)
	  corrType = 'Pearson';
	end

	if (nargin < 8 || length(color) == 0)
	  color = [0 0 1];
	end

	% --- do it!
	if (isnumeric(tsAId))  
	  tsA = tsaA.getTimeSeriesById(tsAId);
	else
	  tsA = tsaA.getTimeSeriesByIdStr(tsAId);
	end
	if (isnumeric(tsBId))
	  tsB = tsaB.getTimeSeriesById(tsBId);
	else 
	  tsB = tsaB.getTimeSeriesByIdStr(tsBId);
	end

	cv = [];
	for o=1:length(offsets)
	  cv(o) = session.timeSeries.computeCorrelationS(tsA, tsB, offsets(o), corrType);
	end

	dt = mode(diff(tsA.time));
	offsetInTime = offsets*dt;

	axes(ax);
  plot(offsetInTime, cv, 'Color', color, 'LineWidth', 3);
	xlabel(['Shift (ms) for ' tsA.idStr] );
	ylabel(['Correlation ' tsA.idStr ' vs. ' tsB.idStr]);

	% max, who predicts who
	[maxCorr idx] = max(abs(cv));
	disp(['Maximal correlation is ' num2str(cv(idx))]);
  if (offsetInTime(idx) < 0) ; 
		disp([tsB.idStr ' predicts ' tsA.idStr ' by ' num2str(-1*offsetInTime(idx)) ' ms']);
  elseif (offsetInTime(idx) > 0)
		disp([tsA.idStr ' predicts ' tsB.idStr ' by ' num2str(-1*offsetInTime(idx)) ' ms']);
	end

	set(ax,'TickDir','out');
  
	if (0) % debug plot so you can see the two TS's
		figure
		tsA.value = tsA.value/max(tsA.value);
		tsA.plot;
		hold on;
		tsB.value = tsB.value/max(tsB.value);
		tsB.plot([1 0 0]);
		legend({tsA.idStr, tsB.idStr});
	end
			
