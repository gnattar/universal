%
% SP Jun 2011
%
% This will plot mutiple lines, connected by : or -, with big solid faces of
%  a specified color and a line denoting some error (if desired).  Mutliple
%  lines on one plot, and labels along x axis can be assigned.  Fancy.
%
%  Preselect the axes before calling.
%
% USAGE:
%
%   plot_multilines_with_error(x, y, y_err, line_colors, line_labels, x_labels, 
%                              x_label_pos, line_style, ax_bounds)
%
%     x, y: cell arrays, where x{i} and y{i} must be of same size and define a line
%     y_err: cell array of errrors ; can be 2xn or 1xn.  If 1xn, it is AMPLITUDE,
%            if 2xn, it is EXACT.
%     line_colors: n x 3 matrix with a color for each line
%     line_labels: n cell array with labels for each line
%     x_labels: on x axis, labels given to each datapoint (blank = just use axes)
%     x_label_pos: where to put it?
%     line_style: default is ':', but you can pass '-'
%     ax_bounds: if passed, will use this as axis bounds
%
function plot_multilines_with_error(x, y, y_err, line_colors, line_labels, x_labels, x_label_pos, line_style, ax_bounds)
  % --- input args
	if (nargin < 3) ; y_err = {} ; end
	if (nargin < 4) ; line_colors = jet(length(x)); end
	if (nargin < 5) ; line_labels = {} ; end
	if (nargin < 6) ; x_labels = {} ; end
	if (nargin < 7) ; x_label_pos = [] ; end
	if (nargin < 8) ; line_style = ':'; end
	if (nargin < 9) ; ax_bounds = []; end

  if (length(x_label_pos) == 0) ; x_label_pos = x{1}; end % assumes  x's are asame

	% --- do it!
	cla;
	for v=1:length(x)
	  hold on;
	  plot(x{v},y{v}, 'o', 'Color', line_colors(v,:), 'MarkerFaceColor', line_colors(v,:));
		if (length(line_style) > 0) ; plot(x{v},y{v}, line_style, 'Color', line_colors(v,:)); end
		if (~isempty(y_err))
			if (size(y_err{v},1) == 1)
			  for i = 1:length(x{v})
					plot([1 1]*x{v}(i),[y{v}(i)-y_err{v}(i) y{v}(i)+y_err{v}(i)], '-', 'Color', line_colors(v,:));
				end
			else % predefined even easier ...
			  for i = 1:length(x{v})
					plot([1 1]*x{v}(i),[y_err{v}(1,i) y_err{v}(2,i)], '-', 'Color', line_colors(v,:));
				end
			end
		end
	end

  % apply axis bounds
	if (~isempty(ax_bounds))
	  axis(ax_bounds); 
	end
 
  % label-age
	if (~isempty(line_labels))
	  A = axis;
		rX = diff(A(1:2));
		rY = diff(A(3:4));
		for l=1:length(line_labels)
		  text(A(1)+0.2*rX, A(3)+0.25*rY + 0.5*(l/length(line_labels))*rY, line_labels{l}, 'Color', line_colors(l,:));
		end
	end

  % x-labels
	if (~isempty(x_labels) )
	  set(gca,'XTick',[]);
	  A = axis;
		rY = diff(A(3:4));
		for x=1:length(x_labels)
			text(x_label_pos(x), A(3)+0.025*rY , x_labels{x} , 'Rotation', 90);
		end
	end

	% finishing touches
	set (gca, 'TickDir', 'out');

