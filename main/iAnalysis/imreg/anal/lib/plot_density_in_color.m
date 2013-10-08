%
% SP Jun 2011
%
% This will plot density with a color scale with nice little color cubes.
%
% USAGE:
%
%  plot_density_in_color (data_vecs, data_range, labels, ax, n_bins)
%
% PARAMS:
%
%  data_vecs: cell array of (various length) data vectors
%  data_range: basically axes limits -- over what range to compute density?
%  labels: labels for individual data_vecs ; cell array
%  ax: axes to plot in
%  n_bins: how many bins to divide into? default 50
%  cmap_bounds: 3x2 matrix indicating range of colormap ; default [0 1; 0 0; 0 0],
%               meaning black -> red
%  show_n: set to 1 and it will show the count in addition to label
%
function plot_density_in_color(data_vecs, data_range, labels, ax, n_bins, cmap_bounds, show_n)

  % --- input processing
	if (nargin < 1)
	  help('plot_density_in_color');
		return;
	end

	if (nargin < 2 || length(data_range) == 0)
	  data_range = [nan nan];
	  for v=1:length(data_vecs)
		  if (length(data_vecs{v}) > 0)
				data_range(1) = nanmin(data_range(1), nanmin(data_vecs{v}));
				data_range(2) = nanmax(data_range(2), nanmax(data_vecs{v}));
			end
		end
	end

	if (nargin < 3) ; labels = {} ; end
	if (nargin < 4 || length(ax) == 0) ; ax = axes; end
	if (nargin < 5 || length(n_bins) == 0) ; n_bins = 50; end
	if (nargin < 6 || length(cmap_bounds) == 0) ; cmap_bounds = [0 1 ; 0 0 ; 0 0 ];end
	if (nargin < 7 || isempty(show_n)) ; show_n = 0 ; end

	% --- gather data
	data_mat = zeros(length(data_vecs), n_bins);
	data_range_vec = linspace(data_range(1),data_range(2),n_bins);
	N = length(data_vecs);
	for v=1:length(data_vecs)
	  if (length(data_vecs{v}) > 0)
			data_mat(N-v+1,:) = histc(data_vecs{v}, data_range_vec);
			
			% normalize to 1 for each row
			data_mat(N-v+1,:) = 256*(data_mat(N-v+1,:)/max(data_mat(N-v+1,:)));
		end
	end

	% --- and plot
	axes(ax);
	cla();
	set(gca,'visible','off');
	hold on;

	% cmap --> build image!
	cmap = [linspace(cmap_bounds(1,1),cmap_bounds(1,2),256)' ...
	        linspace(cmap_bounds(2,1),cmap_bounds(2,2),256)' ...
	        linspace(cmap_bounds(3,1),cmap_bounds(3,2),256)'];
	S = size(data_mat);
	im = zeros(S(1), S(2), 3);
	rim = round(data_mat);
	rim(find(data_mat == 0)) = 1;
	rim (find(data_mat > 256)) = 256;
	rim(find(isnan(rim))) = 1;
	rim(find(isinf(rim))) = 1;
	R = 0*data_mat;
	R = cmap(rim,1); R=reshape(R, S(1), S(2));
	G = cmap(rim,2);G=reshape(G, S(1), S(2));
	B = cmap(rim,3);B=reshape(B, S(1), S(2));
  im(:,:,1) = R ; 
  im(:,:,2) = G ; 
  im(:,:,3) = B ; 

	% set min/max etc
	m = data_range(1);
	M = data_range(2);
	dx = mode(diff(data_range_vec));
  % actual plot
	h = image(im, 'XData', (dx/2)+[data_range(1) data_range(2)-dx-dx/4]);
	set(gca,'visible','on');

	% labels
	R = diff(data_range);
  m = data_range(1);
	if (show_n && length(labels) == 0); for l=1:length(data_vecs) ; labels{l} = {} ; end; end
	for l=1:min(length(labels), length(data_vecs))
	  if (show_n)
	    text(m-0.4*R,N-l+1,[labels{l} ' (n=' num2str(length(data_vecs{l})) ')'] );
		else
	    text(m-0.4*R,N-l+1,labels{l});
	  end
	end

	% axis
	axis([m-0.4*R m+R 0 length(data_vecs)]);
	set(gca,'TickDir','out');


