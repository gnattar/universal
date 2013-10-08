%
% Summary image for a mutli-FOV imaging sessoffsetn to use as alignment check.
%  Takes an average of each plane.
%
% USAGE:
%
%   volume_im_summ(im, im_bw_range, max_frame, offset, num_planes, fig_pos)
%
% PARAMS:
%
%   im: image stack or path
%   im_bw_range: range of values to display ; default is [0 2048]
%   max_frame: which frame to use maximally? ; default 10*num_planes
%   offset: default 0 ; what order do planes appear in
%   num_planes: how many planes? default 4
%   fig_pos: [x y width height] ; [0 0 800 800] default
%
% SP Jan 2012
%
function volume_im_summ(im, im_bw_range, max_frame, offset, num_planes, fig_pos)
  
	% --- inputs  
	if (nargin < 1) ; help('volume_im_summ') ; end
	if (nargin < 2) ; im_bw_range = [0 2048]; end
  if (nargin < 3) ; max_frame = -1 ; end
	if (nargin < 4) ; offset = 0; end
	if (nargin < 5) ; num_planes = 4;end
	if (nargin < 6) ; fig_pos = [0 0 800 800]; end
  

  % --- load and draw
	if (ischar(im)) ; im = load_image(im); end
	if (max_frame == -1) ; max_frame = min(10*num_planes,size(im,3)); end
	
  ax = figure_tight(num_planes, fig_pos);
	for f=1:num_planes
	  imshow(mean(im(:,:,f+offset:num_planes:max_frame),3),im_bw_range, 'Border', 'tight', 'Parent', ax{f});
	end


