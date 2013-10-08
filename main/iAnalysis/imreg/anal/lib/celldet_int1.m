%
% S Peron Dec. 2009
%
% An intensity-based cell detector (i.e., no convolution with morpho
%  filters.)
%
% params should be a structure with:
%  params(1).value: im - your image stack
%  params(2).value: size_thresh - 2 element vector determining size of connected cell set [25 300] dflt
%  params(3).value: thresh_mult - multiply (for now sd of post-processed img) by this to get thresh
%  params(4).value: thresh_method - decides what to do with thresh_mult ; 
%    1: thresh = thresh_mult
%    2: thresh = mean + thresh_mult*sd (GLOBAL)
%    3: thresh = mean + thresh_mult*sd (LOCAL -- for restrict only! -- otherwise GLOBAL)
%  params(5).value: gauss_size - the size, in terms of image dimension FRACTION (applied 
%                   independently to each dimension) of the convolving luminance-norm'ing gaussian 
%                   0 implies NOTHING.
%  params(6).value: source_image_meth - what to do to the image stack:
%    1: take mean
%    2: max projection
%    3: max projection - mean
%  params(7).value: rois - if passed, will only RESTRICT based on filled polys of these ROIs 
%  params(8).value: debug - 1 to show messages ; 0 dflt
%  params(9).value: border_omit - this many pixels from border? you dIE BITCH
%  params(10).value: post_op_type - post-detection operation; 1: none 2: dilation 3: erosion
%  params(11).value: post_op_param - post-detection operation parameter ; for dilation and erosion, 
%                    pixel size of neighborohood (raidus)
%
% returns structure 'members', each of which has a vector, 'indices', specifying
%  index-based (in im) membership.
%
function members = celldet_int1(params)
	global glovars;

  % -1) assignage
	stack = params(1).value;
	size_thresh = params(2).value;
	thresh_mult = params(3).value;
  thresh_meth = params(4).value;
	gauss_size = params(5).value;
	stack2im_meth = params(6).value;
	rois = params(7).value;
	debug = params(8).value;
	border_omit = params(9).value;
	post_op_type = params(10).value;
	post_op_param = params(11).value;

  % --- build the image
  if (length(size(stack)) == 2) % only one frame? then no preprocessing thereof
	  im = stack;
	else % multi-frame? use selected preprocessing method
		switch stack2im_meth
			case 1 % mean
				im = mean(stack,3);
			case 2 % maxproj
			  im = max(stack,[],3);
			case 3 % max-mean
			  im = max(stack,[],3) - mean(stack,3);
		end
	end

  % --- prelims
	if (~ exist('size_thresh', 'var') || length(size_thresh) == 0)
	  size_thresh = [25 300];
	end
	if (length(rois) == 0 & thresh_meth == 3) % prevent from using local mean when no rois
	  disp('celldet_int1::Cannot use local mean if not ROIs exist already; using global mean.'); 
		thresh_meth = 2;
	end
  

  members(1).indices = [];
  S = size(im);

  % parameters for processing 
	sd_mult = thresh_mult; % intensity threshold = mean + sd_mult*sd;

  % --- normalize light by convolving with gaussian
	sim = size(im);
  g_rf = min (10*gauss_size,1); 
	g_r = round(max(sim)*g_rf);
	g_sd = round([sim(1) sim(2)]*gauss_size);

  gauss = customgauss([2*g_r+1 2*g_r+1], g_sd(1) , g_sd(2), 0, 0, 1, [1 1]*(g_r+1));
  cm = conv2(im,gauss);
  cm = cm(g_r+1:S(1)+g_r, g_r+1:S(2)+g_r);
	%if (debug) ; figure ; imshow(gauss,'InitialMagnification','fit'); axis square; end
	if (debug) ; figure ; imshow(cm,[0 max(max(cm))], 'InitialMagnification','fit'); title('Gaussian-convolved image'); axis square; end

  % divide original image by local luminance to normalize
	if (gauss_size > 0)
		fm = double(im).*double(1./double(cm));
	else
		fm = double(im);
	end
 
%fm = -1*gradient(gradient(fm));

  % --- set to [0 1] range IF not exact
	if (thresh_meth ~= 1)
		fm = fm - min(min(fm));
		fm = fm/max(max(fm));
	else
	  fm = fm/glovars.fluo_display.max_pixel_value;
	end
  if(debug) ;	figure; imshow(fm, [0 max(max(fm))], 'InitialMagnification', 'fit'); 
	  axis square; title('Luminance-corrected image -- THIS IS WHAT IS THRESHOLDED'); colorbar; end

	% --- now label using vector and apply size threshold
  fmv = reshape(fm,[],1);
  disp(['celldet_int1::mean intensity on intesnity-corrected image: ' num2str(mean(fmv)) ' std: ' num2str(std(fmv)) ...
         '; range from ' num2str(min(fmv)) ' to ' num2str(max(fmv)) '; median: ' num2str(median(fmv))]);

  % --- if you are doing restricting, precompute inside of polygons -- important for local thresholding
	if (length(rois) > 0)
	  rrfp_params(1).value = rois;
		poly_members =  reset_rois_filled_poly(rrfp_params);
	end

  % --- the intensity thresholding itself
	if (thresh_meth == 1) % exact -- THIS implies an EXACT luminance value
	  disp('celldet_int::exact means EXACT luminance from min (0) to max (usually 4096)');
	  int_thresh = thresh_mult/glovars.fluo_display.max_pixel_value;
		fmb = im2bw(fm,int_thresh);
	elseif (thresh_meth == 2) % mean + thresh_mult*sd GLOBAL
	  int_thresh = mean(fmv) + thresh_mult*std(fmv);
		fmb = im2bw(fm,int_thresh);
	elseif (thresh_meth == 3) % mean + thresh_mult*sd LOCAL
	  fmb = zeros(size(fm));
	  for p=1:length(poly_members)
		  indices = poly_members(p).indices;
		  int_thresh = mean(fmv(indices)) + thresh_mult*std(fmv(indices));
			fmb_sub = im2bw(fm,int_thresh);
			fmb(find(fmb_sub == 1)) = 1;
		end
	end


	% label matrix of off binary
	labmat = bwlabel(fmb);

 	% --- reject too small and too large, too close to border assign the members structure
  ul = unique(labmat);
	M = 1;
	for u=1:length(ul)
	  uidx = find(labmat == ul(u));
	  sul = length(uidx);
		
		% compute min, max x; min, max y for border enforcement
		Y = uidx-sim(1)*floor(uidx/sim(1));
		X = ceil(uidx/sim(1));  

		if (sul < size_thresh(1) | sul > size_thresh(2)) % size threshold
		  labmat(uidx) = 0 ; 
    elseif ( (min(X) < border_omit) | (min(Y) < border_omit) | ...
		     (max(X) > sim(2)-border_omit) | (max(Y) > sim(1)-border_omit) )% border enforcement . . . are you an iLLLEGAL ALIEN!?!?!?
		else
		  members(M).indices = uidx;
			M = M + 1;
		end
	end

  % --- Apply erosion or dilation if needbe
	if (post_op_type == 2 | post_op_type == 3) % dilate
	  global glovars;
	  % general stuff
	  npix = post_op_param;

		% determine appropriate aspect ratio
		im_size = size(glovars.fluo_display.display_im);
		
		switch glovars.fluo_display.aspect_ratio
			case 1 % square
				s1 = im_size(2)/max(im_size(1:2));
				s2 = im_size(1)/max(im_size(1:2));

			case 2 % 1:1
				s1 = 1;
				s2 = 1;

			case 3 % based on mag
				M = max(glovars.fluo_display.hor_pix2um,glovars.fluo_display.ver_pix2um);
				s1 =  glovars.fluo_display.ver_pix2um/M;
				s2 = glovars.fluo_display.hor_pix2um/M;
		end

		% and build your neighborhood (what you will erode/dilate with) using custom gaussian
		g_r = 2*npix;
		cg = customgauss([2*g_r+1 2*g_r+1], g_r*s2, g_r*s1, 0, 0, 1,[1 1]*(g_r+1));
		cg(find(cg > 0.7))=1;
		cg(find(cg <= 0.7))=0;	

		% for each one, erode/dilate
		base_im = zeros(im_size(1), im_size(2));
		for m=1:length(members)

			% create binary base image
			indices = members(m).indices;
			base_im = 0*base_im;
			base_im(indices) = 1;
			
			% apply operator
			if (post_op_type == 2) % dilate
				f_im = imdilate(base_im, cg);
			elseif (post_op_type == 3) % erode
				f_im = imerode(base_im, cg);
			end
			members(m).indices = find(f_im == 1);
		end
	end



  if (debug) ; disp(['Found ' num2str(M) ' ROIs.']); end

	% --- IF rois is assigned, then compute intersect between filled polygons and what you have
	if (length(rois) > 0)
%for i=1:length(members) ; oi(i) = length(members(i).indices) ; end
		valid = find(fmb == 1);
%		figure ; imshow(fmb); pause;
		% b) perform an AND operation with the thresholded binary image
		for p=1:length(poly_members)
			poly_members(p).indices = intersect(poly_members(p).indices, valid);
%if (oi ~= length(poly_members(p).indices)) ; disp('XXXXXXXXXXXXXXXXXXXX') ; end
%disp(['oi: ' num2str(oi(p)) ' ni: ' num2str(length(poly_members(p).indices))]);
		end

		% fini - assign
		members = poly_members;
	end


