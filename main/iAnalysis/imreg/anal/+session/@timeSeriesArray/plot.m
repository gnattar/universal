%
% Plots timeSeriesArray.
%
% USAGE:
%
%  tsa.plot()
%
% (C) S Peron Mar 2012
%
function plot (obj)
  figure;
	hold on;
	if (size(obj.valueMatrix,1) > 1)
		cols = jet(size(obj.valueMatrix,1));
	else
	  cols = [0 0 0];
	end

	for t=1:size(obj.valueMatrix,1)
	  plot(obj.time,obj.valueMatrix(t,:), 'Color',cols(t,:));
	end
