%
% Computes the correlation between original and new image, scoring transform
%
% Specifically, it will generate a warpfield of the calling object (rA) and
%  compare it to rB via a normalized (sd and mean) Pearson correlation.  It
%  can either generate the warpfield by comparing the images or can use the
%  ROI positions in the two planes (method).
%
% USAGE:
%
%  rA.scoreInterdayTransform(rB, method)
%
%  rB: the other roiArray object; must have same # of ROIs
%  method: 'roi_centric' will derive warpfield from ROI centers 
%          'image_grid' will compute transform de-novo using
%          imreg_warp_via_subregion (default, FOR NOW)
%
% (C) Jul 2012 S Peron
%
function score = scoreInterdayTransform(obj, objB, method)

  %% --- sanity checks
	if (obj.length ~= objB.length)
	  disp('scoreInterdayTransform::both arrays must have same # of ROIs.');
		return;
  end
  
  if (nargin < 3)
    method = 'image_grid';
  end

  %% --- build the transformed image using imreg_warp_via_subregion
  S = size(obj.masterImage);
  if (strcmp(method, 'image_grid'))
		opt.n_divs = 10;
		opt.subim_size = round(0.2*[S(2) S(1)]);
		opt.lum_gauss_sd_size = 0.005;

		[im_w warp_parms_r] = imreg_warp_via_subregion(obj.masterImage, objB.masterImage, opt);
		X = round(warp_parms_r.X);
		Y = round(warp_parms_r.Y);
  elseif (strcmp(method, 'roi_centric'))

		% collect ROI COMs
		roi_com = zeros(2,obj.length);
		roi_b_com = zeros(2,obj.length);
		for r=1:obj.length
			roi_com(1,r) = mean(obj.rois{r}.corners(1,:));
			roi_com(2,r) = mean(obj.rois{r}.corners(2,:));
			roi_b_com(1,r) = mean(objB.rois{r}.corners(1,:));
			roi_b_com(2,r) = mean(objB.rois{r}.corners(2,:));
		end
		
		roi_com = round(roi_com);
		roi_b_com = round(roi_b_com);

		% build base X, Y matrices
		X = nan*zeros(size(obj.masterImage)); 
		Y = nan*zeros(size(obj.masterImage));
		for r=1:obj.length 
			if (roi_com(1,r) > 0 & roi_com(1,r) <= S(1) & roi_com(2,r) > 0 & roi_com(2,r) <= S(2) & ...
					roi_b_com(1,r) > 0 & roi_b_com(1,r) <= S(1) & roi_b_com(2,r) > 0 & roi_b_com(2,r) <= S(2))
				Y(roi_com(2,r), roi_com(1,r)) = roi_b_com(2,r);
				X(roi_com(2,r), roi_com(1,r)) = roi_b_com(1,r);
			end
		end

		% interpolate
		iparams.smooth_filt_type = 'rlowess';
		iparams.smooth_ds_factor = floor(min(.1*size(obj.masterImage))/2); % as small as possible -- 2 samples per interpolant
		iparams.smooth_size = [.1 .1];
		iparams.interp_method = 'linear';
		iparams.extrap_method = 'regress';
		iparams.mf2_size = [5 5];

		X = interp2_nans(X,iparams);  
		Y = interp2_nans(Y,iparams); 
  end


  %% --- correlate valid points (non-nan)
  
  % normalize both images
	im_b = double(objB.masterImage);
	im_w = double(obj.masterImage);

	qb = quantile(reshape(im_b,[],1), .9975);
	qw = quantile(reshape(im_b,[],1), .9975);

  % 1) peak fix
	im_b(find(im_b > qb)) = qb;
	im_w(find(im_w > qw)) = qw;
  
  % 2) subtract mean
  im_b = im_b - mean(reshape(im_b,[],1));
  im_w = im_w - mean(reshape(im_w,[],1));

  % 3) divide by sd product
  sd_wb = std(double(reshape(im_b,[],1)))*std(double(reshape(im_w,[],1)));
  
  	% get warped image
	im_w = get_warp_image(im_w, X,Y); 
  
  % compute correlation
  val = find(~isnan(im_w) & ~isnan(objB.masterImage));
  score =  corr(double(im_w(val)), double(im_b(val)), 'type','Pearson');
  
