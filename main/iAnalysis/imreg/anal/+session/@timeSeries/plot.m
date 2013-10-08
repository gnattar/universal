% 
% SP Jan 2011
%
% For plotting the time series in a very simple manner.  Will plot in current
%  axis.
%
% USAGE:
%
%   plot (obj, color, scalingFactor, offset)
%
%   color - if provided, use this to draw ; [0 0 0] default
%   scalingFactor - if provided, linear scaling applied to values
%   offset - if provided, additive offset applied to values
%
function plot (obj, color, scalingFactor, offset)

  % argument parsing
	if (nargin < 2 || isempty(color)) ; color = [0 0 0]; end
	if (nargin < 3 || isempty(scalingFactor)) ; scalingFactor = 1; end
	if (nargin < 4 || isempty(offset)) ; offset = 0; end

	% now plot (in seconds, 0 offset)
	sf = session.timeSeries.convertTime(1,obj.timeUnit,session.timeSeries.second);
%	plot (sf*(obj.time-min(obj.time)), (scalingFactor*obj.value) + offset, 'Color', color);
	plot (obj.time, (scalingFactor*obj.value) + offset, 'Color', color);

	% check for weird time and if weird correct for it
	a = axis;
	R = 2*(quantile(obj.time,0.75)-quantile(obj.time,0.25));
	if (a(2)-a(1) > 100*R) % no way you oculd see much of anything
		axis([quantile(obj.time,0.5)-1.1*(R/2) quantile(obj.time,0.5)+1.1*(R/2) a(3) a(4)]);
	end

	% labels etc.
	set (gca, 'TickDir', 'out');
%	xlabel('Time (s) - zero-aligned');
	xlabel('Time');
	ylabel(strrep(obj.idStr,'_','-'));



