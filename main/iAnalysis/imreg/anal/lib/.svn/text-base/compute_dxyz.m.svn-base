%
% S PEron 2010 May
%
% This function will return a vector with x,y,z-displacement for a given frame
%  a reference stack (not necessarily xy-aligned).  Employs matlab normxcorr2.
%
% source_im is the source (what is matched) ; target stack is the target (what
%  is matched to).  Note that *all* returned values are in terms of pixels/position
%  in the stack (array index; for dz).  source_im and target_stack must be n x m x 1
%  and n x m x f, respectively.
%
% Usage:
%  
%  [dx dy dz] = compute_dxyz(im_s, im_t)
%
% Params:
%  im_s: what you wish to match ; *single* image of same size as single frame of im_t
%  im_t: what you are matching ; multiple images
%
% Returns:
%  dx, dy, dz: best displacement for source_im to align with target_stack
%
function [dx dy dz] = compute_dxyz(im_s, im_t)
  % --- prelims
	S = size(im_t);
	if (S(1) ~= size(im_s,1) | S(2) ~= size(im_s,2))
	  disp('compute_dxyz::source and target images must have same dimensions; aborting.');
	end

	% --- THE HEART OF THE MATTER -- run through files and compute dz
	% note that im_t and im_s are *reversed* because normally, imreg_normxcorr2 is passed a *single*
	%  target image and a bunch of source images, and while we could loop thru several instances of
	%  imreg_normxcorr2 and keep convention, that would be wasteful becauase, for instance, im_t
	%  is luminance-corrected everry time.  Instead, flip the variables and just -1 the displacements.
  %
	% dx_r and dy_r are our displacement vectors for EACH z value and E is the error (correlation - so
	%  bigger is better).  We find max correlation, and "-1" dx dy.
  [im_c dx_r dy_r E] = imreg_normxcorr2(im_t, im_s, []);

	% take max corr -- this is your best match
	[corr_max idx_max] = max(E);
	dz = idx_max;
	dy = -1*dy_r(idx_max);
	dx = -1*dx_r(idx_max);




