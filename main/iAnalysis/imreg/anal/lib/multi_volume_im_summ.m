%
% Browser for multiple volumes.
%
% USAGE:
%
%  multi_volume_im_summ (ims, p0, pz, dz, im_bw_range, max_frame, offset, num_planes, fig_pos)
%
% PARAMS:
%
%   ims: cell array of images or file names, OR a directory name
%   p0: base power
%   pz: lamda for depth power estimates
%   dz: step between successive planes (for power estimates)
%   im_bw_range: image value range to use 
%   max_frame: max frame for averaging
%   offset: offset to use ; vector with one per image file
%   num_planes: how many planes? default 4
%   fig_pos: where to put up the figure
%
% SP Jan 2012
%
function multi_volume_im_summ (ims, p0, pz, dz, im_bw_range, max_frame, offset, num_planes, fig_pos)
  
	% --- inputs
	if (nargin < 2) ; help('multi_volume_im_summ') ; error('Must pass at least first 2 vars.'); end
	if (nargin < 3) ; pz = 250; end
	if (nargin < 4) ; dz = 45; end
	if (nargin < 5) ; im_bw_range = [0 2000]; end
  if (nargin < 6) ; max_frame = -1 ; end
	if (nargin < 7) ; offset = 0; end
	if (nargin < 8) ; num_planes = 4;end
	if (nargin < 9) ; fig_pos = [0 0 800 800]; end
  
  % --- load everything
	if (max_frame == -1) ; max_frame = 10*num_planes; end
	if (ischar(ims))
	  fl = dir([ims filesep '*tif']);
		nims = {};
		for f=1:length(fl) 
		  nims{f} = [ims filesep fl(f).name];
		end
		ims = nims;
	end
  for i=1:length(ims)
	  volims{i} = generate_averaged_ims(ims(i), max_frame, offset, num_planes);
	end

  % --- plot it
  guidata.ax = figure_tight(num_planes, fig_pos);
	guidata.volims = volims;
	guidata.vol = 1;
	guidata.num_planes  = num_planes;
	guidata.im_bw_range = im_bw_range;
	guidata.zoffs = dz*(0:length(volims)-1);
	guidata.powers = p0*exp(guidata.zoffs/pz);
  set(gcf,'KeyPressFcn', {@keypress_processor, guidata});
	plot_images(guidata);

% generates averaged images
function imset = generate_averaged_ims (im,  max_frame, offset, num_planes)
  if (ischar(im)) 
	  im = load_image(im);  
	elseif (iscell(im))
	  im = load_image(im{1}, 1:max_frame);
	end

  for f=1:num_planes
	  imset{f} = mean(im(:,:,f+offset:num_planes:max_frame),3);
	end


function keypress_processor (src, evnt, guidata)
  % --- get event data
	key = double(evnt.Character) ;

  switch key
	  case 91 % [
      guidata.vol = guidata.vol - 1;
			if(guidata.vol == 0) ; guidata.vol = length(guidata.volims) ; end
			plot_images(guidata);

		case 93 % ]
      guidata.vol = guidata.vol + 1;
			if(guidata.vol > length(guidata.volims)) ; guidata.vol = 1 ; end
			plot_images(guidata);
	end

function plot_images(guidata)
  curims = guidata.volims{guidata.vol};
  for f=1:guidata.num_planes
	  axes(guidata.ax{f});
		cla;
	  imshow(curims{f},guidata.im_bw_range, 'Border', 'tight', 'Parent', guidata.ax{f});
	  
		% BIG number!
    if (f == 1)
		  S = size(curims{f});
			hold on ;
      text(S(1)*.1, S(2)*.1, [num2str(guidata.vol) ' z: ' num2str(guidata.zoffs(guidata.vol)) ], ...
			  'Color', [1 0 0], 'FontSize', 24);
      text(S(1)*.1, S(2)*.2, ['pwr: ' num2str(round(guidata.powers(guidata.vol)))], ...
			  'Color', [1 0 0], 'FontSize', 24);
		end
	end
  set(gcf,'KeyPressFcn', {@keypress_processor, guidata});

  



