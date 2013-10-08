%
% Stand-alone plotter for rois over a background image.  Will use current figure,
%  axes.
%
% USAGE:
%
%  plot_rois(bk_im, rois, bk_im_range, aspect_ratio, pix2um)
%
% bk_im: the background image
% rois: roi structure; roi.color IS used
% bk_im_range: minimal and maximal pixel values (1) (2)
% aspect_ratio: 1: square 2: image-based 3: pix2um based
% pix2um: element 1  horizontal ; 2 vertical
% 
function plot_rois(bk_im, rois, bk_im_range, aspect_ratio, pix2um)
 
  show_roi_numbers = 0; % pass eventually

	% --- some prelims
  im_size = size(bk_im);
	im_s12 = im_size(1)*im_size(2);
	disp_im = bk_im;
	disp_ax = gca;

	% apply min/max to disp_im as specified by user
	pix_val_range = bk_im_range(2)-bk_im_range(1);
	under = find(disp_im < bk_im_range(1));
	over = find(disp_im > bk_im_range(2));
	disp_im(under) = bk_im_range(1);
	disp_im(over) = bk_im_range(2);
	disp_im = disp_im - bk_im_range(1);
	disp_im = double(disp_im)/pix_val_range; % [0 1] confine it

	% convert to RGB
	R = disp_im;
	G = disp_im;
	B = disp_im;
	disp_im= zeros(size(disp_im,1), size(disp_im,2), 3);
	disp_im(:,:,1) = R;
	disp_im(:,:,2) = G;
	disp_im(:,:,3) = B;

  % --- ROIs are introduced into the image using rgb ; normal pixels have same
	%     value in all channels and are therefore grayscale
	R = disp_im(:,:,1);
	G = disp_im(:,:,2);
	B = disp_im(:,:,3);

	% loop over ROIs, assigning RGB accordingly ...
	for r=1:length(rois)
		roi = rois(r);

		R(roi.indices) = roi.color(1);
		G(roi.indices) = roi.color(2);
		B(roi.indices) = roi.color(3);
	end

	% final assignment
	disp_im(:,:,1) = R;
	disp_im(:,:,2) = G;
	disp_im(:,:,3) = B;

  % push image
  imshow(disp_im, [0 1]);


	% --- aspect ratio ...
	switch aspect_ratio
	  case 1 % square
		  s1 = im_size(2)/max(im_size(1:2));
		  s2 = im_size(1)/max(im_size(1:2));
		  set(disp_ax, 'DataAspectRatio', [s1 s2 1]);

		case 2 % based on image -- i.e., free
		  set(disp_ax, 'DataAspectRatio', [1 1 1]);

		case 3 % based on mag
		  M = max(pix2um);
		  s1 =  pix2um(2)/M;
		  s2 = pix2um(1)/M;
		  set(disp_ax, 'DataAspectRatio', [s1 s2 1]);

			% - draw the distance bar 
			ver_extent = pix2um(2) * im_size(1);
%			hor_extent = glovars.fluo_display.hor_pix2um * im_size(2);
			p = floor(log10(ver_extent));
			hold on ; 
			plot([10 10], [10 10+((10^p)/pix2um(2))], ...
			  'Color', [1 1 1], 'LineWidth', 3);
			 text (15 , 10+0.5*((10^p)/pix2um(2)),  ...
			  [num2str(10^p) ' um'], 'Color' ,[1 1 1]);
	end

  % --- ROI #s
	if (show_roi_numbers)
		hold on;
		for r=1:length(rois)
			roi = rois(r);
			if (length(roi.corners) == 0 ) ; break ; end % some are blank if not outlined

			text(mean(roi.corners(1,:)), ...
					 mean(roi.corners(2,:)), ...
					 num2str(r), 'Color', 'w');
		end
		hold off;
  end

  

