%
% S Peron 2010 Mar (C)
%
% This will normalize an image by convolving it with a gaussian than dividing 
%  it by this 'mean luminance matrix'
% 
%  im: the image you wish to do this to -- ONE FRAME only
%  gauss_size: the sd of the gaussian, [0 1], in terms of FRACTION of image size -- respects aspect ratios.
%              if > 1, in pixels.
%
% USAGE:
%   normd_im = normalize_via_gaussconvdiv(im, gauss_size);
%
function	normd_im = normalize_via_gaussconvdiv(im, gauss_size);
  % compute gaussian size etc.
	sim = size(im);
	if (length(sim) > 2) ; disp('normalize_via_gaussconvdiv::can only deal with single frames; ABORT!') ; return ; end
	if (length(gauss_size) == 1) ; gauss_size = [gauss_size gauss_size] ; end
%  g_rf = min (2*gauss_size,1); 
	if (gauss_size(1) < 1) ; g_sd(1) = round(sim(1)*gauss_size(1)); else ; g_sd(1) = gauss_size(1) ; end
	if (gauss_size(2) < 1) ; g_sd(2) = round(sim(2)*gauss_size(2)); else ; g_sd(2) = gauss_size(2) ; end
	g_r = round(max(2*g_sd)); % the size of our convolution matrix -- this is BIGGER than the gaussian sd

 
  % perform the convolution
  gauss = customgauss([2*g_r+1 2*g_r+1], g_sd(1) , g_sd(2), 0, 0, 1, [1 1]*(g_r+1));
  cm = conv2(im,gauss);
  cm = cm(g_r+1:sim(1)+g_r, g_r+1:sim(2)+g_r);

  % divide original image by local luminance to normalize
  normd_im = double(im).*double(1./double(cm));

	% set 0s to 0 - don't want NaNs!
	normd_im(find(isnan(normd_im))) = 0;
