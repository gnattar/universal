%
% S Peron Dec. 2009
%
% An intensity-based cell detector (i.e., no convolution with morpho
%  filters.)  It will use the following roiArray parameters:
%    workingImage: this is the image it works with ; do what you will to it
%    rois: this is where output ends up being stored
% 
% Passed parameters:
%  roiIds - which ROIs to work on?  blank means it will *REGENERATE* new rois,
%           roiIds
%  params - see below
%
% params should be a structure with:
%  params(1).value: debug - 1 to show messages ; 0 dflt
%  params(2).value: size_thresh - 2 element vector determining size of connected cell set [25 300] dflt
%  params(3).value: thresh_mult - multiply (for now sd of post-processed img) by this to get thresh
%  params(4).value: thresh_method - decides what to do with thresh_mult ; 
%    1: thresh = thresh_mult
%    2: thresh = mean + thresh_mult*sd (GLOBAL)
%    3: thresh = mean + thresh_mult*sd (LOCAL -- for restrict only! -- otherwise GLOBAL)
%  params(5).value: gauss_size - the size, in terms of image dimension FRACTION (applied 
%                   independently to each dimension) of the convolving luminance-norm'ing gaussian 
%                   0 implies NOTHING.
%  params(6).value: max_pixel_value - what is the maximal pixel value allowed in your data (e.g., 4096)
%  params(7).value: border_omit - this many pixels from border? you dIE BITCH
%
% Populates the roiArray.rois and roiArray.roiIds.
%
function obj = roiGenAutoIntensity(obj, roiIds, params)
  % -1) assignage
	debug = params(1).value;
	size_thresh = params(2).value;
	thresh_mult = params(3).value;
  thresh_meth = params(4).value;
	gauss_size = params(5).value;
	max_pixel_value = params(6).value;
	border_omit = params(7).value;

  % Clear roi IDs if that is called for
	if (length(roiIds) == 0)
	  obj.roiIds = [];
		obj.rois = {};
	end

  % - check
	if (length(obj.workingImage) == 0)
	  disp('roiArray.roiGenAutoIntensity::must have workingImage to do this.');
		return;
	end

  % --- prelims
	sim = size(obj.workingImage);
	if (~ exist('size_thresh', 'var') || length(size_thresh) == 0)
	  size_thresh = [25 300];
	end
	if (length(roiIds) == 0 & thresh_meth == 3) % prevent from using local mean when no rois
	  disp('roiArray.roiGenAutoIntensity::Cannot use local mean if not ROIs exist already; using global mean.'); 
		thresh_meth = 2;
	end
  
  % parameters for processing 
	sd_mult = thresh_mult; % intensity threshold = mean + sd_mult*sd;

  % --- normalize light by convolving with gaussian
	if (gauss_size > 0)
		fm = normalize_via_gaussconvdiv(obj.workingImage,gauss_size);
	else
		fm = double(obj.workingImage);
	end
 
  % --- set to [0 1] range IF not exact
	if (thresh_meth ~= 1)
		fm = fm - min(min(fm));
		fm = fm/max(max(fm));
	else
	  fm = fm/max_pixel_value;
	end
  if(debug) ;	figure; imshow(fm, [0 max(max(fm))], 'InitialMagnification', 'fit'); 
	  axis square; title('Luminance-corrected image -- THIS IS WHAT IS THRESHOLDED'); colorbar; end

	% --- now label using vector and apply size threshold
  fmv = reshape(fm,[],1);
  disp(['roiArray.roiGenAutoIntensity::mean intensity on intesnity-corrected image: ' num2str(mean(fmv)) ' std: ' num2str(std(fmv)) ...
         '; range from ' num2str(min(fmv)) ' to ' num2str(max(fmv)) '; median: ' num2str(median(fmv))]);

  % --- if you are doing restricting, precompute inside of polygons -- important for local thresholding
	if (length(roiIds) > 0)
	  obj.fillToBorder(roiIds);
	end
  % --- the intensity thresholding itself
	if (thresh_meth == 1) % exact -- THIS implies an EXACT luminance value
	  disp('roiArray.roiGenAutoIntensity::exact means EXACT luminance from min (0) to max (usually 4096)');
	  int_thresh = thresh_mult/max_pixel_value;
		fmb = im2bw(fm,int_thresh);
	elseif (thresh_meth == 2) % mean + thresh_mult*sd GLOBAL
	  int_thresh = mean(fmv) + thresh_mult*std(fmv);
		fmb = im2bw(fm,int_thresh);
	elseif (thresh_meth == 3) % mean + thresh_mult*sd LOCAL
	  fmb = zeros(size(fm));
	  for r=1:length(roiIds)
		  tRoi = obj.getRoiById(roiIds(r));
		  indices = tRoi.indices;
		  int_thresh = mean(fmv(indices)) + thresh_mult*std(fmv(indices));
			fmb_sub = im2bw(fm,int_thresh);
			fmb(find(fmb_sub == 1)) = 1;
		end
	end


	% --- Assign de novo ...
	if (length(roiIds) == 0)
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
			  tRoi = roi.roi(-1, [], uidx, [0 1 1], obj.imageBounds, []);
				tRoi.corners = tRoi.computeBoundingPoly();
			  obj.addRoi(tRoi);
			end
		end

		if (debug) ; disp(['Found ' num2str(M) ' ROIs.']); end

	% --- ... or update
	else
		valid = find(fmb == 1);
		% perform an AND operation with the thresholded binary image
		for r=1:length(roiIds)
		  tRoi = obj.getRoiById(roiIds(r));
			tRoi.indices = intersect(tRoi.indices, valid);
		end
	end


