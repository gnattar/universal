%
% SP Feb 2011
%
% Generic receptive field plotting method.  Generally used with
%  session.timeSeries.computeReceptiveFieldsAroundEvents()
%
%  USAGE:
%    
%    plotRF(stimulus, response, plotMethod, plotParams, color, axHandle);
%
%    stimulus,response: vectors containing x and y axis parameters; same size
%    plotMethod,plotParams: [you can override plotMethod with plotParams.method]
%      'raw': plotParams blank, just plots raw data
%      'binByStim': makes equally spaced bins of size plotParams.binSize along 
%        stimulus axis.  Will plot SD and mean. If plotParams.firstBin is provided,
%        this is the value of the first bin's left edge.  Otherwise, min(stimulus).
%      *'binByCount': makes bins, along stimulus axis, having fixed # of members
%        denoted by plotParams.binSize (default = 10)
%    color: color of the plot ; default [1 0 0].
%    axHandle: handle of axis to plot in ; blank means make new figure.
%    axRange: axes range
%
function plotRF(stimulus, response, plotMethod, plotParams, color, axHandle, axRange)
  % --- argument check
	if (nargin < 2)
	  help session.session.plotRF;
		return;
	end
	if (nargin < 3) ; plotMethod = []; end

  % plotmethod
	if (length(plotMethod) == 0)
	  plotMethod = 'binByCount';
		binSize = 10;
	end

	% color? default red
	if (nargin < 5 || length(color) == 0)
	  color = [1 0 0];
	end

	% new figure?
	if (nargin < 6 || length(axHandle) == 0)
	  figure;
		axHandle = axes;
	end

	% axRange?
	if (nargin < 7) 
	  axRange = [];
  end
  
  % plot params
  if (nargin >= 4 && isstruct(plotParams))
    if (isfield(plotParams, 'binSize')) ; binSize = plotParams.binSize; end
		if (isfield(plotParams, 'plotMethod')) ; plotMethod = plotParams.plotMethod ; end 
		if (isfield(plotParams, 'axRange')) ; axRange= plotParams.axRange; end 
		if (isfield(plotParams, 'color')) ; color= plotParams.color; end 
  end

	% --- go for it
	switch lower(plotMethod)
	  case 'raw'
		  plot(stimulus, response, 'o', 'MarkerEdgeColor', color, 'MarkerSize', 3, 'MarkerFaceColor', color);

		case 'binbystim'
			n=1;
			if (~isfield(plotParams, 'firstBin')) ; plotParams.firstBin = min(stimulus) ; end
      for s=plotParams.firstBin:binSize:max(stimulus)
			  idx = find(stimulus >= s & stimulus < s + binSize);
			  stimval(n) = s+(binSize/2); % center of the bin
			  respsd(n) = nanstd(response(idx));
			  respmean(n) = nanmean(response(idx));
				n=n+1;
			end
			hold on;
	    plot_with_errorbar(stimval, respmean, respsd, color);
	    plot(stimval,respmean, '-', 'Color', color, 'LineWidth', 2);

		case 'binbycount'
		  [irr sidx] = sort(stimulus);
			n=1;
      for s=1:binSize:length(sidx)
			  idx = sidx(s:min(s+binSize-1, length(sidx)));
			  stimval(n) = nanmean(stimulus(idx));
			  respsd(n) = nanstd(response(idx));
			  respmean(n) = nanmean(response(idx));
				n=n+1;
			end
			hold on;
	    plot_with_errorbar(stimval, respmean, respsd, color);
	    plot(stimval,respmean, '-', 'Color', color, 'LineWidth', 2);
	end

	if (length(axRange) > 0)
		axis(axRange);
	end
