%
% SPeron Feb 2010
%
% Computes the bounding polygon for arbitrary set of indices - 
%
% mode: 1: rectangle
%       2: convex hull;
%
% returns corners structure, compatible with roi.corners, and n_corners
function [corners n_corners] = roi_compute_bounding_poly(indices, mode)
  global glovars;

	S = size(glovars.fluo_display.display_im);

  % convert to X Y
	Y = indices-S(1)*floor(indices/S(1));
	X = ceil(indices/S(1));

  % if single line of points and mode 2, set to mode 1
	if (mode == 2 & (length(unique(X)) == 1 | length(unique(Y)) == 1)) ; mode = 1 ; end

	% build a box around it
	if (mode == 1)
		corner_x = [max(min(X)-1,0) min(max(X)+1,S(2)) min(max(X)+1,S(2)) max(min(X)-1,0) max(min(X)-1,0)];
		corner_y = [max(min(Y)-1,0) max(min(Y)-1,0) min(max(Y)+1,S(1)) min(max(Y)+1,S(1)) max(min(Y)-1,0)];

		% build it ...
		n_corners = 4;
		corners(1,:) = corner_x;
		corners(2,:) = corner_y;
	elseif (mode == 2) % use matlab's convhull
    corn_idx = convhull(X,Y);

		corner_x = X(corn_idx);
		corner_y = Y(corn_idx);

		% build it ...
		n_corners = length(corn_idx);
		corners(1,:) = corner_x;
		corners(2,:) = corner_y;
	end
