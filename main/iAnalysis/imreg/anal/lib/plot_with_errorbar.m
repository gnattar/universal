%
% S Peron Apr 2010
%
% Plots xvals and yvals as filled circles, and lines to/down to
%  xerrs.  Assumes figure is selected and hold is on.
%
% USAGE:
%  plot_with_errorbar(xvals, yvals, yerrs, col)
%
% xvals, yvals, yerrs: vectors of same size 
% col: 3 element vector for color

function plot_with_errorbar(xvals, yvals, yerrs, col)
  for i=1:length(xvals)
	  plot(xvals(i),yvals(i), 'o', 'Color', col, 'MarkerFaceColor', col);
	  plot([1 1]*xvals(i),[yvals(i)-yerrs(i) yvals(i)+yerrs(i)], '-', 'Color', col);
	end
