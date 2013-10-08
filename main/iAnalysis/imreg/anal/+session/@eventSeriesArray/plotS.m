%
% SP May 2011
%
% Static method that allwos you to plot multiple eventSeries objects at once.
%
% USAGE:
%
%   session.eventSeriesArray.plotS(ESs, colors)
%
% PARAMS:
%
%   ESs: cell array of eventSeries objects to plot.
%   colors: if present, must be same size as ESs size = (n,3) where n is # ESs.
%           You can also pass a SINGLE color to color all with it.
%
function plotS(ESs, colors)
  % --- arg check
	if (nargin < 2) ; colors = []; end

  % cell
	if (~iscell(ESs)) ; ESs = {ESs}; end

	% color check
	if (length(colors) > 0)  
	  if ((size(colors,1) > 1 & size(colors,1) ~= length(ESs))...
		     || size(colors,2) ~= 3)
		  help ('session.eventSeriesArray.plotS') ;
			return;
		elseif (size(colors,1) == 1)
		  colors = repmat(colors,length(ESs),1);
		end
	end

	% --- plot
	for e=1:length(ESs)
	  es = ESs{e};
	  if (length(colors) > 0)
		  color = colors(e,:);
		else
		  color = es.color;
		end
	  es.plot(color, [e-1 e]);
	end

