%
% Generates a figure with several image-ready subplots, returning axes array.
%  All axes get equal space.
%
% USAGE:
%
%   ax = figure_tight(n_ax, fig_dims)
%
% PARAMS:
%
%   n_ax: how many axes (default 4)
%   fig_dims: optional.  Pass 2 values to give x/y size, 4 to give x/y size AND
%             bottom left coords ([sx sy] or [lx by sx sy]).  Default is 
%             [0 0 800 800].
%
% S Peron Dec 2011
%
function ax = figure_tight(n_ax , fig_dims)

  % --- inputs
	if (nargin < 1) ; n_ax = 4 ; end
	ffig_dims = [0 0 800 800];
	if (nargin >= 2)
    if (length(fig_dims) == 2) 
		  ffig_dims = [0 0 fig_dims(1) fig_dims(2)];
    else
		  ffig_dims = fig_dims;
		end
	end

	% --- do it
	figure('Position', ffig_dims);
	ns = ceil(sqrt(n_ax));
	idx = 1;
	S = 1/ns;
	for y=(ns-1):-1:0
	  Y = y/ns;
	  for x=0:(ns-1)
		  X = x/ns; 
		  ax{idx} = subplot('Position', [X Y S S]);
			idx = idx+1;
		end
	end
