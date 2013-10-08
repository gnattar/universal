
% 
% This updates the display of fluo_display_axes -- ANY drawing that takes
%  place does so here.
%
function fluo_display_update_display
  global glovars;

  % does the fluo display exist?
  
	% --- some prelims
  im_size = size(glovars.fluo_display.display_im);
	im_s12 = im_size(1)*im_size(2);

  % --- fluo_display_axes: image itself
  %  update it
	cmoffs = 0; % offset to apply to image colormap - if you use filled rois // maxdff rois this matters
  axes(glovars.fluo_display.fluo_display_axes);

	switch computer % computer-dependent renderer
	  case {'MACI', 'MACI64'}
		  renderer = 'opengl';
		case {'GLNXA64', 'GLNX86'}
		  renderer = 'painters';
		otherwise
		  renderer = 'painters';
	end

	set(glovars.fluo_display.fluo_display_figure, 'RendererMode', 'manual', 'Renderer', renderer);
	
	switch glovars.fluo_display.display_mode
	  case 1 % just the current frame, plain and simple
		  disp_im = glovars.fluo_display.display_im(:,:,glovars.fluo_display.display_im_frame);

		case 2 % mean across frames
		  disp_im = mean(glovars.fluo_display.display_im, 3);

		case 3 % max across frames
		  disp_im = max(glovars.fluo_display.display_im, [], 3);
	
	  case 4 % gaussian-normalized
      gauss_size = str2num(get( glovars.fluo_control_main.norm_gauss_size_edit, 'String'));
			disp_im = normalize_via_gaussconvdiv(mean(glovars.fluo_display.display_im,3), gauss_size);
			disp_im = disp_im - min(min(disp_im));
			disp_im = disp_im/max(max(disp_im))*glovars.fluo_display.max_pixel_value;
	end

	% assign glovars.fluo_display.currently_displayed_image -- no post processing for this as this
	%  is used for image processing
	glovars.fluo_display.currently_displayed_image = disp_im;

	% apply min/max to disp_im as specified by user
	pix_val_range = glovars.fluo_display.colormap_max-glovars.fluo_display.colormap_min;
	under = find(disp_im < glovars.fluo_display.colormap_min);
	over = find(disp_im > glovars.fluo_display.colormap_max);
	disp_im(under) = glovars.fluo_display.colormap_min;
	disp_im(over) = glovars.fluo_display.colormap_max;
	disp_im = disp_im - glovars.fluo_display.colormap_min; % zero it out
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
	if (glovars.fluo_roi_control.show_filled_rois) 
		R = disp_im(:,:,1);
		G = disp_im(:,:,2);
		B = disp_im(:,:,3);

    % loop over ROIs, assigning RGB accordingly ...
		for r=1:glovars.fluo_roi_control.n_rois
			roi = glovars.fluo_roi_control.roi(r);

			R(roi.indices) = roi.color(1);
			G(roi.indices) = roi.color(2);
			B(roi.indices) = roi.color(3);
		  
			% - selected - white
      if (glovars.fluo_roi_control.roi_selected == 0 | length(find(r == glovars.fluo_roi_control.roi_selected)) > 0)
				R(roi.indices) = 1;
				G(roi.indices) = 1;
				B(roi.indices) = 1;
			end 
		end

    % final assignment
		disp_im(:,:,1) = R;
		disp_im(:,:,2) = G;
		disp_im(:,:,3) = B;
  end

	% --- plot image with color-coded rois based on maxdff
% DEPRECATED -- I will nuke this SOON
  if ( 1 == 0)
%	if ((glovars.fluo_roi_control.show_maxdff_rois | glovars.fluo_roi_control.show_tpeak_rois) ...
%	     & glovars.fluo_roi_control.n_rois > 0)
		% compute maxdff for each roi
		disp('fluo_display_update_display::using frames 1-5 OR median as f_o ; should base off of fluo_roi_control.');
		for r=1:glovars.fluo_roi_control.n_rois
			roi = glovars.fluo_roi_control.roi(r);
			f0 = mean(roi.raw_fluo(1:5));
			f0 = min(f0,median(roi.raw_fluo));
			dff(r,:) = (roi.raw_fluo-f0)/f0;
%			max_dff(r) = max(dff(r,:));
      [max_dff(r) tmax_dff(r)] = max(dff(r,:));
			if (isnan(max_dff(r))) ; max_dff(r) = 0; end % safety first!
		end

    % set max based on max or t peak
		M = max(max_dff);
		Mt = max(tmax_dff);
		if (glovars.fluo_roi_control.show_maxdff_rois) 
			cm =jet(100);
		else % time of peak instead
		  tmax_dff(find(max_dff < 0.2*M)) = 0; % omit points with small deflections
			disp(['fluo_display_update_display::not color coding points where df/f is below ' num2str(0.2*M)]);
		  cm =hot(100);
		end
		disp(['fluo_display_update_display::setting max to: ' num2str(M)]);
    % now assign the part of the image with the roi the appropriate value based on colormap
		for r=1:glovars.fluo_roi_control.n_rois
			roi = glovars.fluo_roi_control.roi(r);

			% where in the colormap? based on maxdff vs t peak
			if (glovars.fluo_roi_control.show_maxdff_rois) 
				map_idx = ceil(100*(max_dff(r)/M));
			else
			  map_idx = ceil(100*(tmax_dff(r)/Mt));
			end
			if (map_idx == 0 ) ; map_idx = 1 ; end
			if (map_idx > 100) ; map_idx = 100; end

			disp_im(roi.indices) = cm(map_idx,1);
			disp_im(roi.indices + im_s12) = cm(map_idx,2);
			disp_im(roi.indices+ (2*im_s12)) = cm(map_idx,3);

			% selected? white
      if (glovars.fluo_roi_control.roi_selected == 0 | length(find(r == glovars.fluo_roi_control.roi_selected)) > 0)
				disp_im(roi.indices) = 1;
				disp_im(roi.indices + im_s12) = 1;
				disp_im(roi.indices+ (2*im_s12)) = 1;
			end 
		end
  end

	% --- roi borders
  if (glovars.fluo_roi_control.show_roi_edges)
		R = disp_im(:,:,1);
		G = disp_im(:,:,2);
		B = disp_im(:,:,3);

    % loop over ROIs, assigning RGB accordingly ...
		for r=1:glovars.fluo_roi_control.n_rois
			roi = glovars.fluo_roi_control.roi(r);
			l_indices = roi.poly_indices;

			R(l_indices) = roi.color(1);
			G(l_indices) = roi.color(2);
			B(l_indices) = roi.color(3);
		  
			% - selected - white
      if (glovars.fluo_roi_control.roi_selected == 0 | length(find(r == glovars.fluo_roi_control.roi_selected)) > 0)
				R(l_indices) = 1;
				G(l_indices) = 1;
				B(l_indices) = 1;
			end 
		end

    % final assignment
		disp_im(:,:,1) = R;
		disp_im(:,:,2) = G;
		disp_im(:,:,3) = B;
  end

  % --- and the image hooked up to button down function
  tmp = imshow(disp_im, [0 1]);
  set(tmp,'ButtonDownFcn', 'fluo_display(''fluo_display_axes_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
%  set(glovars.fluo_display.fluo_display_axes,'KeyPressFcn', 'fluo_display(''fluo_display_axes_KeyPressFcn'',gcbo,[],guidata(gcbo))');
%  set(tmp,'KeyPressFcn', 'fluo_display(''fluo_display_axes_KeyPressFcn'',gcbo,[],guidata(gcbo))');

	% --- aspect ratio ...
	switch glovars.fluo_display.aspect_ratio
	  case 1 % square
		  s1 = im_size(2)/max(im_size(1:2));
		  s2 = im_size(1)/max(im_size(1:2));
		  set(glovars.fluo_display.fluo_display_axes, 'DataAspectRatio', [s1 s2 1]);

		case 2 % based on image -- i.e., free
		  set(glovars.fluo_display.fluo_display_axes, 'DataAspectRatio', [1 1 1]);

		case 3 % based on mag
		  M = max(glovars.fluo_display.hor_pix2um,glovars.fluo_display.ver_pix2um);
		  s1 =  glovars.fluo_display.ver_pix2um/M;
		  s2 = glovars.fluo_display.hor_pix2um/M;
		  set(glovars.fluo_display.fluo_display_axes, 'DataAspectRatio', [s1 s2 1]);
      set(glovars.fluo_control_main.um_per_pix_hor_edit, 'String', ... 
			    num2str(glovars.fluo_display.hor_pix2um));
      set(glovars.fluo_control_main.um_per_pix_ver_edit, 'String', ... 
			    num2str(glovars.fluo_display.ver_pix2um));

			% - draw the distance bar 
			ver_extent = glovars.fluo_display.ver_pix2um * im_size(1);
%			hor_extent = glovars.fluo_display.hor_pix2um * im_size(2);
			p = floor(log10(ver_extent));
			hold on ; 
			plot([10 10], [10 10+((10^p)/glovars.fluo_display.ver_pix2um)], ...
			  'Color', [1 1 1], 'LineWidth', 3);
			 text (15 , 10+0.5*((10^p)/glovars.fluo_display.ver_pix2um),  ...
			  [num2str(10^p) ' um'], 'Color' ,[1 1 1]);
				
      
	end

  % --- fluo_display_axes: ROI #s
	if (glovars.fluo_roi_control.show_roi_numbers == 1)
		hold on;
		for r=1:glovars.fluo_roi_control.n_rois
			roi = glovars.fluo_roi_control.roi(r);
			if (length(roi.corners) == 0 ) ; break ; end % some are blank if not outlined

		  % unfilled rois? white in middle
			if (~ glovars.fluo_roi_control.show_filled_rois) 
				text(mean(roi.corners(1,:)), ...
						 mean(roi.corners(2,:)), ...
						 num2str(r), 'Color', 'w');
			else % filled? black
				text(mean(roi.corners(1,:)), ...
						 mean(roi.corners(2,:)), ...
						 num2str(r), 'Color', 'w');
			end
		end
		hold off;
  end

	% --- fluo_display_frame_slider, fluo_display_framenum_text, fluo_display_message_text 
	if (numel(im_size) > 2) % only if multiframe
		set(glovars.fluo_display.fluo_display_frame_slider,'Min', 1);
		set(glovars.fluo_display.fluo_display_frame_slider,'Max', im_size(3));
		set(glovars.fluo_display.fluo_display_frame_slider,'SliderStep', [1/(im_size(3)-1) min(1,10/(im_size(3)-1))]);
		set(glovars.fluo_display.fluo_display_frame_slider,'value', glovars.fluo_display.display_im_frame);
		set(glovars.fluo_display.fluo_display_framenum_text, 'String', ...
			['Frame ' num2str(glovars.fluo_display.display_im_frame) ' of ' num2str(im_size(3)) ...
			' (' num2str(im_size(1)) ' lines x ' num2str(im_size(2)) ' pixels per line)']);
		set(glovars.fluo_display.fluo_display_message_text,'String', glovars.fluo_display.im_filename);
  else
  	set(glovars.fluo_display.fluo_display_frame_slider,'Min', 1);
		set(glovars.fluo_display.fluo_display_frame_slider,'Max', 1);
		set(glovars.fluo_display.fluo_display_frame_slider,'SliderStep', [1 1]);
		set(glovars.fluo_display.fluo_display_frame_slider,'value', glovars.fluo_display.display_im_frame);
		set(glovars.fluo_display.fluo_display_message_text,'String', glovars.fluo_display.im_filename);
		set(glovars.fluo_display.fluo_display_framenum_text, 'String', ...
			['Single frame (' num2str(im_size(1)) ' lines x ' num2str(im_size(2)) ' pixels per line)']);
	 end

	% --- fluo_control_main min/max color slider/text
	set(glovars.fluo_control_main.min_color_slider,'Min', 0);
	set(glovars.fluo_control_main.min_color_slider,'Max', glovars.fluo_display.max_pixel_value);
	set(glovars.fluo_control_main.min_color_slider,'value', glovars.fluo_display.colormap_min);
	set(glovars.fluo_control_main.min_color_edit,'String', num2str(glovars.fluo_display.colormap_min));
	set(glovars.fluo_control_main.max_color_slider,'Min', 0);
	set(glovars.fluo_control_main.max_color_slider,'Max', glovars.fluo_display.max_pixel_value);
	set(glovars.fluo_control_main.max_color_slider,'value', glovars.fluo_display.colormap_max);
	set(glovars.fluo_control_main.max_color_edit,'String', num2str(glovars.fluo_display.colormap_max));

	% --- fluo_contro_main nchan, usedchan
	set(glovars.fluo_control_main.nchan_edit, 'String', num2str(glovars.fluo_display.nchan));
	set(glovars.fluo_control_main.usedchan_edit, 'String', num2str(glovars.fluo_display.usedchan));



