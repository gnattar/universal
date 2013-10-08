%
% [im_c dx_r dy_r E] = imreg_normxcorr2(im_s, im_t, opt)
%
% Given two images, finds optimal x/y offset using matlab's normxcorr2;
%  returns the corrected image -- im_s is source image, im_t is 
%  target image (i.e., shifts source so it fits with target). Also returns
%  displacement in x (dx_r) and y (dy_r) that needs to be applied to source image
%  to match target.  dx_r > 0 and dy_r > 0 imply right and down movement, resp.
%  E is the error for each frame.
%
% Note that im_s can be a stack; in this case, so will im_c.
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.
%       opt.g_r - radius of gaussian for initial convolution -- MUST BE ODD
%       opt.t_thresh - [0,1] ; threshold of target image at which you cutoff;
%                      thresholding is done because when you do fft, you do it
%                      on a zero-padded version of the input image, and if
%                      you don't remove points below threshold by zeroing them,
%                      you simply align the image areas and not features, giving
%                      dx_r/dy_r of 0
%       opt.s_thresh - as with t_thresh, but for source image
%       opt.wb_on - if set to 0, no wb
%       opt.max_d - maximal displacementin terms of FRACTION of image size ; 
%                   set to -1 to disable (default is 0.2)
%
function [im_c dx_r dy_r E] = imreg_normxcorr2(im_s, im_t, opt)
	E = [];
 
	% --- variable defaults ; passable in opt eventually?
	g_r = 0.02; % MUST BE ODD
	s_thresh = 0.5; % threshold for prefilter src img, 0<v<1 ; see below
	t_thresh = 0.5; % threshold for prefilter target img, 0<v<1 ; see below
	wb_on = 0;
	max_d = 0.2;
	if (isstruct(opt))
		if (isfield(opt,'g_r'))
		  g_r = opt.g_r;
		end
    if (isfield(opt,'s_thresh'))
		  s_thresh= opt.s_thresh;
		end
    if (isfield(opt,'t_thresh'))
		  t_thresh = opt.t_thresh;
		end
    if (isfield(opt,'wb_on'))
		  wb_on = opt.wb_on;
		end
    if (isfield(opt,'max_d'))
		  max_d = opt.max_d;
		end
  end

	% --- sanity
	if ((size(im_s,1) == size(im_t,1)) + (size(im_s,2) == size(im_t,2)) < 2)
	  disp('imreg_normxcorr2::im_s and im_t are different sizes; aborting.');
	end

  % 0) setup
	im_c = zeros(size(im_s)); % corrected image
	S = size(im_s);
	if (length(S) == 3) ; F = S(3) ; else F = 1; end
	im_t = normalize_via_gaussconvdiv(im_t, g_r);
	sim_t = im_t(S(1)/4:3*S(1)/4, S(2)/4:3*S(2)/4); % only use middle *half* of the target image
	max_d1 = round(S(1)*max_d);
	max_d2 = round(S(2)*max_d);

	% 1) run algo
	if (wb_on) ; wb = waitbar(0, 'Normalized Cross-correlation Processing ...'); end
	for f=1:F
		% gaussian convolve, resize
		im_sc = normalize_via_gaussconvdiv(im_s(:,:,f), g_r);

		% compute normxcorr and trim borders
		nxc_im = normxcorr2(sim_t,im_sc);
		st = ceil((size(sim_t)-[1 1])/2); % size of template - i.e., target image
		nxc_im = nxc_im(st(1):size(nxc_im,1)-st(1)-1, st(2):size(nxc_im,2)-st(2)-1) ; % remove borders

		% compute dx, dy, accomodating maximal displacement
		c_y = S(1)/2;
		c_x = S(2)/2;
		lb1 = max(1,c_y-max_d1);
		ub1 = min(S(1),c_y+max_d1);
		lb2 = max(1,c_x-max_d2);
		ub2 = min(S(2),c_x+max_d2);
		d1 = ub1-lb1+1;
		d2 = ub2-lb2+1;

    % vectorize subregion...
		nxc_im_v = reshape(nxc_im(lb1:ub1,lb2:ub2),[],1);
		[corrval idx] = max(nxc_im_v);
		x_peak = ceil(idx/d1);
		y_peak = idx-d1*(x_peak-1);
		x_peak = x_peak + lb2;
		y_peak = y_peak + lb1;

		% 2 is the correction factor due to rounding issues above; final displacements:
		dx = x_peak-c_x-2;
		dy = y_peak-c_y-2;
		dx = -1*dx;
		dy = -1*dy;

		dx_r(f) = dx;
		dy_r(f) = dy;

	  if (wb_on) ; waitbar(f/F,wb); end
	end
	if (wb_on) ; delete(wb); end
  
	% send to imreg_wrapup
	wrap_opt.err_meth = 3; % correlation based
	wrap_opt.debug = 0;
	dx_r = dx_r'; % transpose to make right (size(dx,1) should be nframes)
	dy_r = dy_r';
  [im_c E] = imreg_wrapup (im_s, im_t, dx_r, dy_r, [], [], [], wrap_opt);

