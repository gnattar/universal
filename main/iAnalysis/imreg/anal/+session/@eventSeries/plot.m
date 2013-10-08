% 
% SP Jan 2011
%
% For plotting the event series in a very simple manner.  Will plot in current
%  axis.
%
% USAGE:
%
%   plot (obj, color, yRange)
%
%   color - if provided, use this to draw tick [otherwise, es.color]
%   yRange - what to span ; not provided means [0 1]
%
function plot (obj, color, yRange)

  % argument parsing
	if (nargin < 2)
	  color = obj.color;
	elseif (length(color) == 0)
	  color = obj.color;
	end

	if (length(color) == 0) ; color = [0 0 0] ; end % no color set in class

	if (nargin < 3)
	  yRange = [0 1];
	end

	% now plot
	valVec = obj.eventTimes;
	plot ([valVec ; valVec], [ones(length(obj.eventTimes),1)*yRange]', 'Color', color);
	hold on;
	if (obj.type == 2) % join them 
    valVec1 = obj.eventTimes(1:2:length(obj.eventTimes));
    valVec2 = obj.eventTimes(2:2:length(obj.eventTimes));
    myR = max(yRange);
    plot ([valVec1 ; valVec2], ones(2, length(obj.eventTimes)/2)*myR , 'Color', color);
	  valVec = obj.eventTimes(1:2:length(obj.eventTimes));
  end
	




