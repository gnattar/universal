%
% Draws an x at coordinate (x,y) in color col (vector or letter),
%  with size sz (i.e., x+/- sz and y+/- sz)
%
function draw_x(x, y, sz, col)
  hold on;
	if (length(col) == 1)
		plot([x-sz x+sz], [y-sz y+sz], col);
		plot([x-sz x+sz], [y+sz y-sz], col);
	else % triplet
		plot([x-sz x+sz], [y-sz y+sz], 'Color', col);
		plot([x-sz x+sz], [y+sz y-sz], 'Color', col);
	end
  hold off;
