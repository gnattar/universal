%
% Performs ROI "maintanance" -- passed a 2x1 vector, steps, with el 2 specifying
%  whether to recompute df/f (1 = yes) and el 1 specifyign whether to recompute
%  lines for bounding poly display, constraints for roi presence etc.
%
% USAGE:
% 
%    fluo_roi_control_update_rois(steps)
%
% steps: [recompute bounding lines?  recompute dff?]
%
function fluo_roi_control_update_rois(steps)
  global glovars;

	% default behavior: JUST df/f update
	if (~ exist('steps', 'var'))
	  steps = [0 1];
	end

	% --- recalculation of bounding polygons lines; will cancel out indices if no corners present
	if (steps(1))
		im_size = size(glovars.fluo_display.display_im);

		% --- fluo_display_axes: ROIs
		for r=1:glovars.fluo_roi_control.n_rois
			roi = glovars.fluo_roi_control.roi(r);
%%% ADD -- ALLOW PARTIAL IMAGE OVERLAP
			l_indices = [];
			% - all but last point:
			for p=1:length(roi.corners)-1
				% call bresenham algorithm
				[lx ly] = extern_bresenham ( [roi.corners(1,p) roi.corners(2,p) ; roi.corners(1,p+1) roi.corners(2,p+1)]);

				% convert x/y to indices [THIS SHOULD ONLY HAPPEN WHEN ROIs CHANGE]
				l_indices = [l_indices ly+im_size(1)*(lx-1)];
			end
			% - last point connection
			[lx ly] = extern_bresenham ( [roi.corners(1,p) roi.corners(2,p) ; roi.corners(1,p+1) roi.corners(2,p+1)]);
			l_indices = [l_indices ly+im_size(1)*(lx-1)];

			% - assign
			glovars.fluo_roi_control.roi(r).poly_indices = l_indices;
		end
	end

  % --- recomputation of df/f
	if (steps(2))
		% loop over frames
		for f=1:glovars.fluo_display.display_im_nframes
			frame_im = glovars.fluo_display.display_im(:,:,f);
			% loop over rois
			for r=1:glovars.fluo_roi_control.n_rois
				if (f == 1) ; glovars.fluo_roi_control.roi(r).raw_fluo = []; end % clear previous

				% reject 0 values -- this is for rejected pixels only
				values = frame_im(glovars.fluo_roi_control.roi(r).indices);
				val = find(values>0);
				
				% assign
				glovars.fluo_roi_control.roi(r).raw_fluo(f) = mean(values(val));
			end
		end
	end


