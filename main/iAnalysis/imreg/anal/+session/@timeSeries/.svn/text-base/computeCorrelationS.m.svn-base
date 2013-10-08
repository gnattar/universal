%
% SP Mar 2011
%
% This will compute the correlation between two timeseries at timepoints
%  where they overlap.
%
% USAGE:
%
%  corr = session.timeSeries.computeCorrelationS(tsA, tsB, shiftB, corrType)
%
%  corr: correlation (Pearson's) of the two timeseries' values
%  
%  tsA, tsB: two timeseries considered; points with NaN values in either TS
%            are ignored, as are time points for which both don't have values.
%  shiftB: how much to shift tsB by, in terms of INDEX, not time ; dflt 0. +1 
%          means that A's index 1 is compared with B's index 2.  If your peak 
%          correlation is for a - shiftB, then tsB "predicts" tsA.
%  corrType: can be 'Pearson'*, 'Kendall', 'Spearman'
%
function corrab = computeCorrelationS(tsA, tsB, shiftB, corrType)
  % --- input process
	if (nargin < 2)
	  help session.timeSeries.computeCorrelationS;
		return;
	end

	if (nargin < 3 || length(shiftB) == 0)
	  shiftB = 0;
	end

  if (nargin < 4 || length(corrType) == 0)
	  corrType = 'Pearson';
	end

	% --- find overlapping points and do shift
	for s=1:length(shiftB)
	  corrab(s) = getShiftedCorr(tsA, tsB, shiftB(s), corrType);
	end

%
% single correlation
%
function corrab = getShiftedCorr(tsA, tsB, shiftB, corrType)
	% overlap
	intT = intersect(tsA.time, tsB.time);
	valA = find (ismember(tsA.time, intT) & ~isnan(tsA.value));
	valB = find (ismember(tsB.time, intT) & ~isnan(tsB.value));

  [irr, valAi, valBi]=intersect(tsA.time(valA), tsB.time(valB));

  valueA = tsA.value(valA(valAi));
  valueB = tsB.value(valB(valBi));

	% shift
	if (shiftB > 0)
	  valueA = valueA(1:end-shiftB);
	  valueB = valueB(1+shiftB:end);
  elseif (shiftB < 0)
	  valueB = valueB(1:end+shiftB);
	  valueA = valueA(-1*shiftB+1:end);
	end

	% correlation
  corrab = nan;
  if (length(valueA) > 0 & length(valueB) > 0)
	  corrab = corr(valueA', valueB', 'type', corrType);
  end
