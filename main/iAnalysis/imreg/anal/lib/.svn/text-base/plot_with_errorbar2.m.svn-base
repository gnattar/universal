%
% S Peron Apr 2010
%
% Plots xvals and yvals as filled circles, and lines above at yperrs and below
%  to ynerrs.  This is to allow, e.g., interquartile rangse.  Note that yperrs are
%  RELATIVE yvals, and both are POSITIVE. Assumes figure is selected and hold is on.
%
% USAGE:
%  plot_with_errorbar2(xvals, yvals, yperrs, ynerrs, col)
%
% xvals, yvals, yerrs: vectors of same size 
% col: 3 element vector for color

function plot_with_errorbar2(xvals, yvals, yperrs, ynerrs, col)
  for i=1:length(xvals)
	  plot(xvals(i),yvals(i), 'o', 'Color', col, 'MarkerFaceColor', col);
	  plot([1 1]*xvals(i),[yvals(i)-ynerrs(i) yvals(i)+yperrs(i)], '-', 'Color', col);
	end
