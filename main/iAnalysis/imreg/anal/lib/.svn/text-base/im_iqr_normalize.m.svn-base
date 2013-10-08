%
% SP May 2011
%
% Normalize image to IQR.  Specifically, this will first set the min pixel
%  to 0, then compute the IQR (25th to 75th %ile) and divide the image by
%  2X this number.  In an image with a UNIFORM pixel distribution, this wuold
%  obviously yield a range of [0 1] for pixel value.  This is of course not
%  the case, so an additional scaling factor value can be passed.
%
% USAGE:
%
%  nim = im_iqr_normalize(im, sf)
%
% PARAMS:
%
%  nim: returned normalized image (double)
%
%  im: the image
%  sf: scaling factor -- if passed, when the image is divided by IQR, it is
%      also MULTIPLIED by this sf.  Default is 0.5, which is like dividing by
%      2 X 25-75% range.
%
function nim = im_iqr_normalize(im, sf)
  nim = [];
  if (nargin < 1) 
	  help ('im_iqr_normalize');
	  return;
	end

	if (nargin < 2)
	  sf = 0.5;
	end

	% do it!
	nim = 0*double(im);
	for f=1:size(im,3) % multiframe ?
	  fim = im(:,:,f);
		fim = fim - nanmin(nanmin(fim)); % zero min pixel
		fim = double(fim); % double it in case it is integral
		lfim = reshape(fim,[],1);

		iqr = quantile(lfim,0.75) - quantile(lfim, 0.25);

		nim(:,:,f) = sf*fim/iqr;
	end


