%
% A morphology based roi re-aligner.  Uses a template image to match it against the larger image
%  via normxcorr2. 
%
% Note that aspect ratios are treated by scaling the image into a square, upsampling to the
%  largest dimension.  This will therefore fail if the larger dimension is not a multiple of
%  the smaller dimension, in therms of size.
%
% USAGE:
%
%   corrval = findMatchingRoisInNewImage(rA_t, rA_s, params)
%
% ARGUMENTS: 
%
%   rA_t - roiArray object with rA_t.workingImage being the target image (the "established" image
%          where ROIS are properly placed).  rA_t.rois are the ROIs.
%   rA_s - the roiArray object for source image.  Thus, rA_s.workingImage is the source image where
%          ROIs from rA_t will be placed.  Note that if there are rois in rA_s, and they match, by roi.id,
%          rois in rA_t, they will be treated as valid matches for neighbor realign and will NOT have group
%          membership 9001 ever assigned (nor will they be put in 9000).  Thus, if you want to only match
%          an roi that you just added to rA_t, you can run this method with the new rA_t and the old rA_s as
%          parameters and rA_s will be updated appropriately.  If you are doing a day de-novo, create a 
%          roiArray ,assign the workingImage, and then run this; rois will be populated appropriately.
%   params: structure with following fields (if passed, assigned ; otherwise default)
%     params.debug - 1 to show messages ; 0 dflt 
%     params.gauss_size: how big is your luminance pre-convolving gaussian? in fraction of img size
%     params.min_template_size: what is the minimal template size, in terms of FRACTION of img size
%     params.translation_bound: how much can the roi move - AGAIN in terms of fraction of img size; 1 = off
%     params.n_closest: how many neighbors to use if you have to fall back to closest paradigm?
%     params.method: roi_centric (which only fits rois) or image_grid 
%          
%
% Assigns group set 9000 -  flags in yellow (group 9001) those that had to be moved by guess 
%  (i.e., using neighbor moves).
%
% (C) S Peron May 2010
function corrval = findMatchingRoisInNewImage(rA_t, rA_s, params)
  % --- 0) prelims
	corrval = nan;

  if (nargin < 2)
	  disp('roiArray.findMatchingRoisInNewImage::must at least rA_t and rA_s.');
		return;
	elseif (nargin == 2)
	  params = [];
	end

  % defaults
	use_waitbar = 0;
	debug = 0;
	lum_gauss_sd_size = 0.005; 
	min_template_size = .05;
	translation_bound = 0.1;
	n_closest = 5;
	method = 'roi_centric';

  % get images
	oim_t = rA_t.workingImage;
	oim_s = rA_s.workingImage;

	% pull rois ; you copy because you will alter for aspect ratio correction
	o_rois = rA_t.rois;
	for r=1:length(o_rois)
	  already_matched(r) = 0;
	  rois_t{r} = o_rois{r}.copy();
		tmp_roi = rA_s.getRoiById(o_rois{r}.id);
		if (length(tmp_roi) == 0)
			rois_s{r} = o_rois{r}.copy();
			orois_s{r} = o_rois{r}.copy();
		else
			rois_s{r} = tmp_roi.copy();
			orois_s{r} = tmp_roi.copy();
			already_matched(r) = 1;
		end
	end

  % debug flag
	if (nargin >= 3)
		eval(assign_vars_from_struct(params, 'params'));
	end


  % other assignments / sanity chex
  S_o = size(oim_s);
	if (sum(size(oim_s) == size(oim_t)) ~= length(size(oim_s))) ; disp ('roiArray.findMatchingRoisInNewImage::dimensions of images must agree.') ; return ;  end


  % --- 1) pre-processing
	
  % --- normalize aspect ratios for image -- 'upsample' along smaller dimension
	ar = 1;
	if (S_o(1) > S_o(2))
	  ar = S_o(1)/S_o(2);
		if (round(ar) ~= ar) ; disp('roiArray.findMatchinRoisInNewImage::can only handle images with integral aspect ratio for large/small.'); return ; end 
	  for d=1:S_o(2)
		  i1=((d-1)*ar)+1;
			for i=i1:i1+ar-1;
				bigims(:,i) = oim_s(:,d);
				bigimt(:,i) = oim_t(:,d);
			end
		end
	elseif(S_o(2) > S_o(1))
	  ar = S_o(2)/S_o(1);
		if (round(ar) ~= ar) ; disp('roiArray.findMatchingRoisInNewImage::can only handle images with integral aspect ratio for large/small.'); return ;end 
	  for d=1:S_o(1)
		  i1=((d-1)*ar)+1;
			for i=i1:i1+ar-1;
				bigims(i,:) = oim_s(d,:);
				bigimt(i,:) = oim_t(d,:);
			end
		end
  else % already ok?
    bigims = oim_s;
    bigimt = oim_t;
  end
    
	im_s = bigims;
	im_t = bigimt;
	S = size(im_s); 

	% --- normalize aspect ratios for ROI borders, members -- again, upsample along smaller dim
	normalize_aspect_ratio(rois_t, S_o, S, ar);
	normalize_aspect_ratio(rois_s, S_o, S, ar);

	% --- precompute roi COM based on borders, distance matrix
	roi_com = zeros(2,length(rois_t));
  for r=1:length(rois_t)
	  roi_com(1,r) = mean(rois_t{r}.corners(1,:));
	  roi_com(2,r) = mean(rois_t{r}.corners(2,:));
  end
	roi_dist = zeros(length(rois_t),length(rois_t));
	for r1=1:length(rois_t)
	  roi_dist(r1,r1) = 0;
	  for r2=r1+1:length(rois_t)
		  D = sqrt(((roi_com(1,r1)-roi_com(1,r2))^2)+((roi_com(2,r1)-roi_com(2,r2))^2));
			roi_dist(r1,r2) = D;
			roi_dist(r2,r1) = D;
		end
	end
	nroi_com = roi_com; % where new coms are stored

	% --- normalize light intensity via gaussian
	nim_s = normalize_via_gaussconvdiv(im_s,lum_gauss_sd_size);
	nim_t = normalize_via_gaussconvdiv(im_t,lum_gauss_sd_size);

  % --- set to [0 1] range
  nim_s = nim_s - min(min(nim_s));
  nim_s = nim_s/max(max(nim_s));
  nim_t = nim_t - min(min(nim_t));
  nim_t = nim_t/max(max(nim_t));

	% --- 2) Actual matching
  if (strcmp(method, 'roi_centric'))
		if (use_waitbar) ; wb = waitbar(0,'roiArray.findMatchingRoisInNewImage::Main processing loop ...'); end
		min_rs = ceil((min_template_size*S)/2);
		max_dp = ceil(translation_bound*S(1)); % same in x and y since we work with skwarZ
		dx_r = [] ; dy_r = [] ; % where the displacements are stored
		corrval = nan*zeros(length(rois_t));
		for r=1:length(rois_t)
			if (use_waitbar) ; waitbar(r/length(rois_t),wb, ['roiArray.findMatchingRoisInNewImage::Main processing loop: ' num2str(r) ' of ' num2str(length(rois_t)) ' ROIs']); end
			if(already_matched(r)) 
				sroi_com(1,r) = mean(rois_s{r}.corners(1,:)); 
				sroi_com(2,r) = mean(rois_s{r}.corners(2,:)); 
				dx = sroi_com(1,r) - roi_com(1,r);
				dy = sroi_com(2,r) - roi_com(2,r);
			else
				% call the template matcher
				[dx dy corrval(r)] = find_match_to_roi_template(nim_t, nim_s, rois_t{r}, min_rs, max_dp);
				if (debug) ; disp(['dx: ' num2str(dx) ' dy: ' num2str(dy) ' corr: ' num2str(corrval(r))]); end
			end

			% store dx, dy -- you can use this later to test for failures
			dx_r(r) = dx;
			dy_r(r) = dy;

			% new roi com -- for redo test
			nroi_com(:,r) = roi_com(:,r) + [dx dy]';
		end


		% --- process redos (in roi_centric only)
		% determine redos by looking at distribution of displacement vectors for neighbors
		gdo_params.n_closest = n_closest;
	  gdo_params.median_difference_thresh = 0; % basically go until 7 x median criteria met
	  dX = [dx_r' dy_r'];
	  [outlier_idx redo_thresh]= get_displacement_outliers(nroi_com', dX, gdo_params);

		redo = zeros(1,length(dx_r));
		redo(outlier_idx) = 1;
		redo(find(already_matched)) = 0;
		if (length(find(redo == 1)) >= length(dx_r)/4) % If a lot of redos, user should inspect visually
			disp('roiArray.findMatchingRoisInNewImage::at least 25% of ROIs had to be redone ; check manually.');
		end
		oredo = redo; % for plotting in debug mode, keep original redo so you can flag redone guys

		% roi-centric world: redo them one by one
		for r=1:length(redo)
			if (use_waitbar) ; waitbar(r/length(redo),wb, ['roiArray.findMatchingRoisInNewImage::Processing redos ...']); end
			if (redo(r))
		 
				% --- try to redo with larger templates -- can you get in criteria?
				for n=1:4
					if(debug) ; disp(['**** Attempting correction ' num2str(n)]); end
					min_rs = (n+1)*ceil((min_template_size*S)/2);

					% call the template matcher
					[dx dy corrval(r)] = find_match_to_roi_template(nim_t, nim_s, rois_t{r}, min_rs, max_dp);
					if (debug) 
						disp(['corrected dx: ' num2str(dx) ' (was ' num2str(dx_r(r)) ') dy: ' num2str(dy) ' (was ' num2str(dy_r(r)) ') corr: ' num2str(corrval(r))]); 
					end

					% store dx, dy -- you can use this later to test for failures
					dx_r(r) = dx;
					dy_r(r) = dy;

					% new roi com -- for redo test
					nroi_com(:,r) = roi_com(:,r) + [dx dy]';

					% okay?
					redo(r) = is_redo_nbr_dist(r, redo_thresh, roi_dist, n_closest, nroi_com);

					if (~ redo(r)) ; break ; end
				end

				% --- fail -- then go and just use your (5?) nearest neighbors from ORIGINAL set
				if (redo(r))
					% compute 5 closest UNFAILED neighbors
					dists = roi_dist(r,:);
					[cd closest_idx] = sort(dists);

					n = 2; % first is going to be the same roi since distance is 0!
					nc = 0;
					closest_good = [];
					while (nc < n_closest & n < length(closest_idx))
						if (~redo(closest_idx(n))) % if its good, use it
							closest_good = [closest_good closest_idx(n)];
							nc = nc+1;
						end
						n = n+1;
					end

					% average their dx/dy and use it
					dx_r(r) = round(mean(dx_r(closest_good)));
					dy_r(r) = round(mean(dy_r(closest_good)));

					if (debug) 
						disp(['Based on average of neighbors, corrected dx: ' num2str(dx_r(r)) ' dy: ' num2str(dy_r(r))]);
					end
				end
			end
		end
		if (use_waitbar) ; delete(wb);end

  % --- image_grid mode 
	elseif (strcmp(method, 'image_grid')) 

	  opt.n_divs = 10;
		opt.subim_size = round(0.2*[S(2) S(1)]);
		opt.lum_gauss_sd_size = 0;

    [im_c warp_parms_r] = imreg_warp_via_subregion(nim_s, nim_t,opt);
    warp_parms_r.X = round(warp_parms_r.X);
    warp_parms_r.Y = round(warp_parms_r.Y);

		% now loop thru ROIs and determine their displacement vectors
    rroi_com = round(roi_com);
		for r=1:length(rois_t)
		  nroi_com(:,r)  = [warp_parms_r.X(rroi_com(2,r),rroi_com(1,r))  warp_parms_r.Y(rroi_com(2,r),rroi_com(1,r))];
      dx_r(r) = roi_com(1,r) - nroi_com(1,r);
      dy_r(r) = roi_com(2,r) - nroi_com(2,r);
    end

	  oredo = 0*dx_r;
  end
	
	% --- 3) post-processing

  % --- convert dx/dy from square to actual aspect ratio
  if (S_o(1) > S_o(2)) 
	  dx_r = dx_r/ar;
	else  
	  dy_r = dy_r/ar;
	end

	% --- call moveBy on orois_s
	for r=1:length(rois_t)
    orois_s{r}.moveBy(dx_r(r), dy_r(r));
 
		% 9001 group if redone ...
		if (oredo(r))  
			orois_s{r}.addToGroup(9001);
		end
	end

  % update object ... delete bad thigs
	for r=1:length(orois_s)
	  if (~ already_matched(r))
		  rA_s.addRoi(orois_s{r});
		end
	end

%
% The core function -- returns dx, dy given an roi, source and target images, and
%  max displacement (max_dp) and minimal size of template (min_rs).  Note that
%  min_rs is 2x1 while max_dp is 1x1 - this is odd and not important! both min_rs 
%  should be same.  
%
function [dx dy corrval] = find_match_to_roi_template(nim_t, nim_s, roi, min_rs, max_dp)
  S = size(nim_t);

	% based on corners, define template bounding rectangle 
	corners = roi.corners;
	min_x = round(min(corners(1,:)));
	max_x = round(max(corners(1,:)));
	min_y = round(min(corners(2,:)));
	max_y = round(max(corners(2,:)));

	% is rectangle large enuff? if not, make bigger ; get center and radius
	r_x = ceil((max_x-min_x)/2); 
	c_x = min_x + r_x;
	r_y = ceil((max_y-min_y)/2);
	c_y = min_y + r_y;
	if (r_y < min_rs(1)) ; r_y = min_rs(1); end
	if (r_x < min_rs(2)) ; r_x = min_rs(2); end

	% make the bounds and ensure their respect of image boundaries -- since it is ASSUMED that the template
	%  is CENTERED on ROI center, you must keep symmetrical radii about center
	x1 = c_x-r_x;
	x2 = c_x+r_x;
	if (x1 < 1) ; x2 = x2+x1-1 ; x1 = 1 ; end
	if (x2 > S(2)) ; x1 = x1+ (x2-S(2)); x2 = S(2) ; end
	y1 = c_y-r_y;
	y2 = c_y+r_y;
	if (y1 < 1) ;y2 = y2+y1-1; y1 = 1 ; end
	if (y2 > S(1)) ; y1=y1+(y2-S(1)); y2 = S(1) ; end

	% now make the template
	template = nim_t(y1:y2, x1:x2);
  
  % blank template check
  if (min(size(template)) < 2 ) 
    dx = 0;
    dy = 0;
    corrval = 0;
    return;
  end
  
	% debug show
	if (0 == 1) ; figure ; debug_plot_roi_detail(nim_t, roi, template, x1, x2, y1, y2, c_x, c_y); end

	% for each template, determine the x/y displacement and rotation *about its center* using normxcorr2
	%  here, you get cross correlation of template with the 'source' image -- where you want to find the
	%  template, which is in a sense the 'target' -- and you then look for the hopefully-unique peak in 
	%  the x-corr landscape

	cim = normxcorr2(template, nim_s); 
	st = ceil((size(template)-[1 1])/2);
	cim = cim(st(1):size(cim,1)-st(1)-1, st(2):size(cim,2)-st(2)-1) ; % remove borders

	if ( 1 == 0 ) ; figure ; imshow(cim) ; colormap jet ; pause ; end

	% compute dx, dy, accomodating maximal displacement
	lb1 = max(1,c_y-max_dp);
	ub1 = min(S(1),c_y+max_dp);
	lb2 = max(1,c_x-max_dp);
	ub2 = min(S(2),c_x+max_dp);
	d1 = ub1-lb1+1;
	d2 = ub2-lb2+1;
	%OLD
	%cim_v = reshape(cim,[],1);
	%[val idx] = max(cim_v);
	%x_peak = ceil(idx/S(1));
	%y_peak = idx-S(1)*(x_peak-1);

	cim_v = reshape(cim(lb1:ub1,lb2:ub2),[],1);
	[corrval idx] = max(cim_v);
	x_peak = ceil(idx/d1);
	y_peak = idx-d1*(x_peak-1);
	x_peak = x_peak + lb2;
	y_peak = y_peak + lb1;

	% 2 is the correction factor due to rounding issues above
	dx = x_peak-c_x-2;
	dy = y_peak-c_y-2;

%
% Performs aberration test for *single* dx/dy based on distance to nearnest neighbors
%
% r is your index ; thresh is threshold for acceptance
% roi_dist is the ORIGINAL roi distance matrix (prior to displacement)
% n_closest is how many neighbors to use and nroi_com is new COM matrix
%
function redo = is_redo_nbr_dist(r, thresh, roi_dist, n_closest, nroi_com)
	redo = 1;
	N = size(nroi_com,2); % how many ROIs are ther

	% get the closets neighbors for THIS particular roi
	dists = roi_dist(r,:);
	[cd closest_idx] = sort(dists);

  % determine *new* distance VECTOR for this guy
	nroi_dist = zeros(N,1);
	for r1=1:N
		D = sqrt(((nroi_com(1,r)-nroi_com(1,r1))^2)+((nroi_com(2,r)-nroi_com(2,r1))^2));
		nroi_dist(r) = D;
	end

	% compute n_closest neighbors for this particular roi
	dists = roi_dist(r,:);
	[cd closest_idx] = sort(dists);
	ndists = nroi_dist';

	% compute distances to neighbors that were closest
	cldist = dists(closest_idx(2:n_closest));
	ncldist = ndists(closest_idx(2:n_closest));

	% store, for this roi, distance difference
	D = mean(abs(cldist-ncldist));

  % and test -- if below threshold OK!
	if (D < thresh) ; redo = 0 ; end

% 
% for debug plotting of a closeup view of roi
%
function debug_plot_roi_detail(nim_t, roi, template, x1, x2, y1, y2, c_x, c_y);
	subplot(1,2,1);
	imshow(mean(nim_t,3), [0 max(max(nim_t))]);
	hold on;
	mycol = roi.color;
	for p=1:length(roi.corners)-1
		plot ([roi.corners(1,p) roi.corners(1,p+1)], ...
					[roi.corners(2,p) roi.corners(2,p+1)], ...
					'-', 'Color', mycol );
	end

	plot([x1 x2], [y1 y1], '-', 'Color', mycol);
	plot([x1 x2], [y2 y2], '-', 'Color', mycol);
	plot([x1 x1], [y1 y2], '-', 'Color', mycol);
	plot([x2 x2], [y1 y2], '-', 'Color', mycol);
	plot(c_x, c_y, 'rx');

	subplot(1,2,2);
	imshow(template, [0 max(max(nim_t))], 'InitialMagnification' ,'fit') ; 
	axis square;
	pause;


%
% Normalizes aspect ratio of roi objects in object array rois ; since tehse are
%  handles they need not be returned.  S_o is original size, S is square size.
%  ar is the aspect ratio.
%
function normalize_aspect_ratio(rois, S_o, S, ar)
  for r=1:length(rois)

		% corners
		if (S_o(1) > S_o(2))
		  rois{r}.corners(1,:) = ar*rois{r}.corners(1,:);
	  elseif (S_o(1) < S_o(2))
		  rois{r}.corners(2,:) = ar*rois{r}.corners(2,:);
		end % otherwise ar is 1 so no biggie

		% indices -- quite YUK
		indices = rois{r}.indices;
		Y = indices-S_o(1)*floor(indices/S_o(1));
	  X = ceil(indices/S_o(1));
    nX = [];
		nY = [];
		if (S_o(1) > S_o(2)) % more Y (1) values than X (2) -- grow in X
		  ux = unique(X);
			nX = [];
			nY = [];
			for d=1:length(ux)
			  fidx = find(X == ux(d));
				Ni = length(fidx);
				xo=((ux(d)-1)*ar)+1;
        xf = xo+ar-1;
				ax = [];
				for x=xo:xf
				  aX = [aX x*ones(Ni,1)'];
				end
				aY = repmat(Y(fidx),ar,1);
				nX = [nX aX];
				nY = [nY aY'];
			end
	  elseif (S_o(1) < S_o(2)) % more X points -- add Y
		  uy = unique(Y);
			nX = [];
			nY = [];
			for d=1:length(uy)
			  fidx = find(Y == uy(d));
				Ni = length(fidx);
				yo=((uy(d)-1)*ar)+1;
        yf = yo+ar-1;
				aY = [];
				for y=yo:yf
				  aY = [aY y*ones(Ni,1)'];
				end
				aX = repmat(X(fidx),ar,1);
				nY = [nY aY];
				nX = [nX aX'];
			end
    end
    new_indices = nY + S(1)*(nX-1);
		rois{r}.indices = new_indices;
	end

