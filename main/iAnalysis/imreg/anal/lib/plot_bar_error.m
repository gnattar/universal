%
% SP MAy 2011
%
% Plots bar(s) with a little line for error
%
function plot_bar_error(x,y,err,width,color)
  w2 = width/2;
	neg = find(y < 0);
	err(neg) = -1*err(neg);
  for i=1:length(x)
	  patch(x(i)+[-1*w2 -1*w2 w2 w2 -1*w2], [0 y(i) y(i) 0 0], color, 'EdgeColor', color);
		if (err(i) ~= 0) ; plot(x(i)*[1 1], [y(i) y(i)+err(i)], 'Color', color); end
	end
  
