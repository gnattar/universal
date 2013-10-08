%
% SP Mar 2011
%
% Generic plotter for a series of bars with labels.
%
% USAGE:
%
%  session.session.plotBarRF(barValues, barLabels, plotParams)
%
%  barValues: values that bar will take
%  barLabels: string labels (if any) for bars ; cell array
%  plotParams: struct with:
%    axRef: figure to plot to ; make new if blank
%    valueRange: set bar range to this
%    showLabels: set to 0 to suppress printing of labels for bars; defautl 1
%
function plotBarRF(barValues, barLabels, plotParams)
  % --- input chekz
	if (nargin < 1 || length(barValues) == 0) % roi
	  disp('plotBarRF::must provide barvalues.');
		return;
	end

	if (nargin < 2)
	  barLabels = {};
	end

  % plotParams
	axRef = [];
	valueRange = [0 1];
	showLabels = 1;

	if (nargin >= 3 && isstruct(plotParams))
	  if(isfield(plotParams,'axRef')) ; axRef = plotParams.axRef; end
	  if(isfield(plotParams,'valueRange')) ; valueRange = plotParams.valueRange; end
	  if(isfield(plotParams,'showLabels')) ; showLabels = plotParams.showLabels; end
	end

  % generate figure if not provided axRef
	if (isempty(axRef))
	  figure;
  	axRef = axes;
	end

  % --- plot em yo!
  axes(axRef);
	cla;
	bar(barValues);
	A = axis;
	axis([A(1) A(2) valueRange(1) valueRange(2)]);
	set(axRef, 'TickDir', 'out');
	set(axRef, 'XTick',[]);

	% --- label
	if (showLabels && length(barLabels) >= length(barValues))
		valRange = range(barValues);
		for b=1:length(barValues)
			text(b,barValues(b)+0.1*valRange, strrep(barLabels{b},'_','-'), 'Rotation', 90);
		end
	end


