%
% [im_c dx_r dy_r E] = imreg_dft (im_s, im_t, fit_opt, opt)
%
% Given two images, finds optimal downsampled FFT transform via the 
%  extern_dftregistration.m function.  
%
%  Returns the corrected image -- im_s is source image, im_t is 
%   target image (i.e., shifts source so it fits with target). 
%   Note that im_s can be a stack; in this case, the dft fit is
%   performed frame-by-frame. im_c will also be a stack.
%
%  Also returns the x and y offste for each frame.
%
%  E is an error metric, per frame.  Usually it is the correlation.
%
% opt - structure containing parameters ; use structure to allow you to
%       vary the options without many function variables.
%        debug: set to 1 to get messages out the wazoo (default = 0)
%        wb_on: set to 1 to have a waitbar (default = 0)
%
function [im_c dx_r dy_r E] = imreg_dft (im_s, im_t, opt)

  % opt check:
  if (length(opt) == 0) % defaults
	  opt.debug = 0;
	  opt.wb_on = 0;
	else % sanity checks - user does not have to pass all opts, so default unassigned ones
	  if (isfield(opt,'debug') == 0)
		  opt.debug = 0;
		end
	  if (isfield(opt,'wb_on') == 0)
		  opt.wb_on= 0;
		end
	end

	% --- variable defaults 
	subpixelFraction = 1;
	wb_on = opt.wb_on;
	nframes = size(im_s,3);
	im_c = zeros(size(im_s));
	dx_r = zeros(nframes,1);
	dy_r = zeros(nframes,1);

  % --- loop and main call to extern_dftregistration
	if (wb_on) ; wb = waitbar(0, 'Performing downsampled FFT image registration...'); end
	for f=1:nframes;
	  if (wb_on) ; waitbar(f/nframes,wb); end
    [output Greg] = extern_dftregistration(fft2(double(im_t)),fft2(double(im_s(:,:,f))),subpixelFraction);
    regIm=abs(ifft2(Greg));
		dy_r(f) = output(3);
		dx_r(f) = output(4);
    im_c(:,:,f) = uint16(regIm);
	end

	% --- send to imreg_wrapup 
	if (wb_on) ; waitbar(1, wb, 'Sending to imreg-wrapup ...'); end
   [im_c E] = imreg_wrapup (im_s, im_t, dx_r, dy_r, [], [], [], []);


  % --- cleanup
	if (wb_on) ; delete(wb); end
