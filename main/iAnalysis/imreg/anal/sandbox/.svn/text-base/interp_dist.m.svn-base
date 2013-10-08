% interpolation based on a weighted distance (linear? qudratic?)
% will work well on sparse . . . will not scale well with dense matrices

% alternative is to use a convolution, for speed have the convolution 
%  matrix ready ; do not use all points (finite radius)

A = nan*zeros(500,500);
S = size(A);
A(2,5) = 5;
A(2,2) = 1;
A(8,2) = 6;
A(8,5) = 11;

interp_points = find(isnan(A));
seed_points = find(~isnan(A));

% VERY SLOW
weight = 0*seed_points;
ns = length(seed_points);
for i=1:length(interp_points)
  [xi yi] = get_xy_from_idx(interp_points(i),S);
  % compute distance to each seed point
	for s=1:length(seed_points)
		[xs ys] = get_xy_from_idx(seed_points(s),S);
	  weight(s) = ((xs-xi)^2 + (ys-yi)^2);
	end



	% weighted mean
	sf = 1/sum(1./weight);
	guess = sf*sum(A(seed_points)./weight );
  A(interp_points(i)) = guess;
end
  
