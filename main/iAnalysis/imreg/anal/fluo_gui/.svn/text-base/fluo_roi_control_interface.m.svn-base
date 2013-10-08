%
% This is a wrapper ; should be using classes but for backwards compatibility
%  this will have to do.
% 
% Basically, this allows function calls to talk to fluo_roi_control - format
%  is 
%
%  fluo_roi_control_interface(funcname,params)
%
%  where funcname is a string representation of the desired function and params
%  is whatever that function needs (it is passed by fluo_roi_control_interface
%  directly to funcname).  
%
%  So, what happens is "eval([funcname '(params)'])".  No returns are made.
%  
% Functions available (params listed when relevant - usually none)
%  new_roi: initiates new roi drawing on the gui
%  done_roi: completes roi drawing
%  select_roi: allows gui-based roi selection
%  next_roi, prev_roi: next and previous roi, resp.
%  move_left, move_right, move_up, move_down:
%    pass blank params --> move by one
%    pass a NUMBER in params and move by that number
%  
function fluo_roi_control_interface(funcname, params)
  eval([funcname '(params);']);

%
% Help -- lists all keyboard shortcuts
%
function help(params)
  disp('=============== KEYBOARD SHORTCUTS AVAILABLE =================');
	disp('MISC:');
	disp('S - save rois');
	disp('L - load rois');
	disp('n - make new roi via polygon');
	disp('p - select rois via polygon');
	disp('d - done with polygon drawing');
	disp(' ');
	disp('ROI SELECTION:');
	disp('s - select single ROI');
	disp('a - select all ROIs');
	disp('o - select all ROIs NOT currently selected (complement)');
	disp('m - select multiple - toggle by clicking on an ROI');
	disp('< > - select previous/next ROI');
	disp(' ');
	disp('ROI ACTIONS:');
	disp('arrow keys - move selected ROI(s).  Use shift to move by 10');
	disp('w - redraw current ROI');
	disp('del - delete selected ROI(s)');
	disp('j - join selected ROIs');
	disp('l - split ROI into connected component(s)');
	disp('x - delete all but the largest connected component');
	disp('r - restrict by currently selected restriction filter');
	disp('D - dilate border by 1');
	disp('E - erode border by 1');
	disp('F - fill holes in the pixelated region');
	disp('T - make border be convex hull of current pixels');
	disp('{ } - take away/add next 10 darkest/brightest points to indices');
	disp('[ ] - take away/add next 1 darkest/brightest points to indices');
	disp('');
	disp(' ');
	disp('ROI DISPLAY:');
	disp('b - toggle borders on/off');
	disp('f - toggle fill pixels on/off');
	disp('# - toggle numbering on/off');
	disp('h - plot intensity histogram for current ROI(s)');

%
% New roi
%
function new_roi(params)
  global glovars;
	disp('Draw your ROI in fluo_display; click done when finished (or hit d)');
	glovars.fluo_display_axes.mouse_mode = 1;
	glovars.fluo_roi_control.new_roi.n_corners = 0;
	glovars.fluo_roi_control.new_roi.corners = [];
	glovars.fluo_roi_control.new_roi.indices = [];
	glovars.fluo_roi_control.new_roi.poly_indices = [];
	glovars.fluo_roi_control.new_roi.raw_fluo = [];
	glovars.fluo_roi_control.new_roi.groups = [];
	glovars.fluo_roi_control.new_roi.misc_vals = [];

%
% Redraw ROI - keep index but redraw ...
%
function redraw_roi(params)
  global glovars;
	disp('Draw your ROI in fluo_display; click done when finished (or hit d)');
	glovars.fluo_display_axes.mouse_mode = 6;
	glovars.fluo_roi_control.new_roi.n_corners = 0;
	glovars.fluo_roi_control.new_roi.corners = [];
	glovars.fluo_roi_control.new_roi.indices = [];
	glovars.fluo_roi_control.new_roi.poly_indices = [];
	glovars.fluo_roi_control.new_roi.raw_fluo = [];
	glovars.fluo_roi_control.new_roi.groups = [];
	glovars.fluo_roi_control.new_roi.misc_vals = [];

%
% Done roi -- finished drawing, so add it to list etc.
%
% action depends on mouse_mode:
%  1 - creating new roi
%  4 - select rois via poly 
%  6 - redraw existing ROI
%
function done_roi(params)
  global glovars;
	
	% mouse mode 1: creating new ROI
	if (glovars.fluo_display_axes.mouse_mode == 1 & glovars.fluo_roi_control.new_roi.n_corners > 1)
		% Done with selecting new ROI -- lets build it
		nr = glovars.fluo_roi_control.n_rois + 1;
		glovars.fluo_roi_control.n_rois = nr;
	 
		% 1) define corners, color
		glovars.fluo_roi_control.roi(nr).n_corners = glovars.fluo_roi_control.new_roi.n_corners;
		glovars.fluo_roi_control.roi(nr).corners = [glovars.fluo_roi_control.new_roi.corners ...
			glovars.fluo_roi_control.new_roi.corners(:,1)];
		ci = rem(nr,size(glovars.fluo_roi_control.roi_colors,1))+1;
		glovars.fluo_roi_control.roi(nr).color = glovars.fluo_roi_control.roi_colors(ci,:);

		% 2) determine indices (i.e., indices within image matrix for easy access)
		xv = glovars.fluo_roi_control.roi(nr).corners(1,:);
		yv = glovars.fluo_roi_control.roi(nr).corners(2,:);
    in = inpolygon(glovars.fluo_display.display_im_x_matrix, ...
                   glovars.fluo_display.display_im_y_matrix, ...
									 xv, yv);
		glovars.fluo_roi_control.roi(nr).indices = find(in == 1);

		% 3) raw fluo across the movie
		for f=1:glovars.fluo_display.display_im_nframes
			frame_im = glovars.fluo_display.display_im(:,:,f);
		  glovars.fluo_roi_control.roi(nr).raw_fluo(f) = ...
			  mean (frame_im(glovars.fluo_roi_control.roi(nr).indices));
		end

		% 4) clear new roi, mouse mode
		glovars.fluo_roi_control.new_roi.n_corners = 0;
		glovars.fluo_roi_control.new_roi.corners = [];
		glovars.fluo_roi_control.new_roi.indices = [];
		glovars.fluo_roi_control.new_roi.poly_indices = [];
		glovars.fluo_roi_control.new_roi.raw_fluo = [];
		glovars.fluo_roi_control.new_roi.groups = [];
		glovars.fluo_roi_control.new_roi.misc_vals = [];
		glovars.fluo_display_axes.mouse_mode = 0;

		% 5) update display
		glovars.fluo_roi_control.roi_selected = nr;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(nr));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(nr).color);
		fluo_roi_control_update_rois([1 0]);
		fluo_display_update_display();
  elseif (glovars.fluo_display_axes.mouse_mode == 4 & size(glovars.fluo_roi_control.bounding_poly.corners,2)> 1) % bounding roi poly
	  % determine points inside
		xv = glovars.fluo_roi_control.bounding_poly.corners(1,:);
		yv = glovars.fluo_roi_control.bounding_poly.corners(2,:);
    in = inpolygon(glovars.fluo_display.display_im_x_matrix, ...
                   glovars.fluo_display.display_im_y_matrix, ...
									 xv, yv);
    in = find(in == 1);

		% see which ROIs are flagged ; mark them
		glovars.fluo_roi_control.roi_selected = [];
		for r=1:length(glovars.fluo_roi_control.roi)
		  roi = glovars.fluo_roi_control.roi(r);
			nm = length(intersect(roi.indices, in));
			if (nm > 0)
				glovars.fluo_roi_control.roi_selected = [glovars.fluo_roi_control.roi_selected r];
			end
		end

		% update displays, clear bounding poly, etc.
		glovars.fluo_roi_control.bounding_poly.corners = [];
		glovars.fluo_display_axes.mouse_mode = 0;
		rs = glovars.fluo_roi_control.roi_selected;
		if (length(rs) == 1)
			set(glovars.fluo_roi_control.current_roi_text,'String', num2str(rs));
			set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
				glovars.fluo_roi_control.roi(rs).color);
		elseif(length(glovars.fluo_roi_control.roi_selected) > 1)
			set(glovars.fluo_roi_control.current_roi_text,'String', 'Multi');
			set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
				  [1 1 1]);
		else
			set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
			set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
				  [1 1 1]);
		end
		fluo_display_update_display();
	% mouse mode 6: redraw exustubg
	elseif (glovars.fluo_display_axes.mouse_mode == 6 & glovars.fluo_roi_control.new_roi.n_corners > 1)

		% Done with selecting new ROI -- lets build it
		nr = glovars.fluo_roi_control.roi_selected;
		if (length(nr) ~= 1) 
		  disp('done_roi::Only one ROI can be updated at once!');
			return;
		end
	 
		% 1) define corners, color
		glovars.fluo_roi_control.roi(nr).n_corners = glovars.fluo_roi_control.new_roi.n_corners;
		glovars.fluo_roi_control.roi(nr).corners = [glovars.fluo_roi_control.new_roi.corners ...
			glovars.fluo_roi_control.new_roi.corners(:,1)];
		ci = rem(nr,size(glovars.fluo_roi_control.roi_colors,1))+1;
		glovars.fluo_roi_control.roi(nr).color = glovars.fluo_roi_control.roi_colors(ci,:);

		% 2) determine indices (i.e., indices within image matrix for easy access)
		xv = glovars.fluo_roi_control.roi(nr).corners(1,:);
		yv = glovars.fluo_roi_control.roi(nr).corners(2,:);
    in = inpolygon(glovars.fluo_display.display_im_x_matrix, ...
                   glovars.fluo_display.display_im_y_matrix, ...
									 xv, yv);
		glovars.fluo_roi_control.roi(nr).indices = find(in == 1);

		% 3) raw fluo across the movie
		for f=1:glovars.fluo_display.display_im_nframes
			frame_im = glovars.fluo_display.display_im(:,:,f);
		  glovars.fluo_roi_control.roi(nr).raw_fluo(f) = ...
			  mean (frame_im(glovars.fluo_roi_control.roi(nr).indices));
		end

		% 4) clear new roi, mouse mode
		glovars.fluo_roi_control.new_roi.n_corners = 0;
		glovars.fluo_roi_control.new_roi.corners = [];
		glovars.fluo_roi_control.new_roi.indices = [];
		glovars.fluo_roi_control.new_roi.poly_indices = [];
		glovars.fluo_roi_control.new_roi.raw_fluo = [];
		glovars.fluo_roi_control.new_roi.groups = [];
		glovars.fluo_roi_control.new_roi.misc_vals = [];
		glovars.fluo_display_axes.mouse_mode = 0;

		% 5) update display
		glovars.fluo_roi_control.roi_selected = nr;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(nr));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(nr).color);
		fluo_roi_control_update_rois([1 0]);
		fluo_display_update_display();
	end

%
% Select an roi on gui
%
function select_roi(params)
  global glovars;
	glovars.fluo_display_axes.mouse_mode = 2;

  % set selected to none for now
	set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
	set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);

	disp('Select an ROI by clicking on it.');

%
% Selects all rois
%
function select_all(params)
  global glovars;

  % only if there are ROIs!!
  if (glovars.fluo_roi_control.n_rois > 0)
		glovars.fluo_roi_control.roi_selected = 0;
		set(glovars.fluo_roi_control.current_roi_text,'String', 'All');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
    fluo_display_update_display(); % call display update to thicken lines
	else
	  disp(['Delineate or load ROIs first']);
	end


%
% Select complement of currently selected
%
function select_complement(params)
  global glovars;

  % delete selected currently, setting usr message 
	sel = glovars.fluo_roi_control.roi_selected;
	all_idx = 1:glovars.fluo_roi_control.n_rois;
	new_sel = setdiff(all_idx,sel);

  % all or none or ONE
	bgc = [1 1 1];
	if(length(new_sel) == length(all_idx))
	  new_sel = 0;
		str = 'All';
	elseif(length(new_sel) == 0) % none
	  new_sel = -1;
		str = 'None';
  elseif(length(new_sel) == 1) % single
	  str = num2str(new_sel);
	  bgc = glovars.fluo_roi_control.roi(new_sel).color;
	else % regular multi
	  str = 'Multi';
  end

  % update gui, glovars
	set(glovars.fluo_roi_control.current_roi_text,'String', str);
	set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', bgc);
  glovars.fluo_roi_control.roi_selected = new_sel;

  fluo_display_update_display();

%
% Select multiple by clicking on them, then done
%
function select_multiple(params)
  global glovars;

	% set appropriate mouse mode
	glovars.fluo_display_axes.mouse_mode = 3;

  % delete selected currently, setting usr message 
	set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
	set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
  glovars.fluo_roi_control.roi_selected = [];

  % message user
	disp('Select ROIs by clicking on them');


%
% Select mutliple by bounding them with polygon
%
function select_multiple_poly(params)
  global glovars;

	% set appropriate mouse mode
	glovars.fluo_display_axes.mouse_mode = 4;

  % delete selected currently, setting usr message 
	set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
	set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
  glovars.fluo_roi_control.roi_selected = [];

  % message user
	disp('Select ROIs by drawing a bounding polygon around them ; when finished click done or hit d.');



% 
% Select next roi
% 
function next_roi(params)
  global glovars;

  % only if there are ROIs!!
  if (glovars.fluo_roi_control.n_rois > 0)
	  if (length(glovars.fluo_roi_control.roi_selected) > 1)  % multiple selected? keep max only
		  glovars.fluo_roi_control.roi_selected = max(glovars.fluo_roi_control.roi_selected);
		end

		% now increment ...
		glovars.fluo_roi_control.roi_selected =  ...
			glovars.fluo_roi_control.roi_selected + 1;
		if (glovars.fluo_roi_control.roi_selected > glovars.fluo_roi_control.n_rois)
			glovars.fluo_roi_control.roi_selected =  1;
		end

		% update ui message
		gvs = glovars.fluo_roi_control.roi_selected;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(gvs));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(gvs).color);
 
    fluo_display_update_display(); % call display update to thicken lines
	else
	  disp(['Delineate or load ROIs first']);
	end

% 
% Select previous roi
% 
function prev_roi(params)
  global glovars;

  % only if there are ROIs!!
  if (glovars.fluo_roi_control.n_rois > 0)
	  if (length(glovars.fluo_roi_control.roi_selected) > 1)  % multiple selected? keep min only
		  glovars.fluo_roi_control.roi_selected = min(glovars.fluo_roi_control.roi_selected);
		end

		% the increment
		glovars.fluo_roi_control.roi_selected =  ...
			glovars.fluo_roi_control.roi_selected - 1;
		if (glovars.fluo_roi_control.roi_selected < 1)
			glovars.fluo_roi_control.roi_selected = ...
				glovars.fluo_roi_control.n_rois;
		end

		% the text message
		gvs = glovars.fluo_roi_control.roi_selected;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(gvs));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(gvs).color);
 
    fluo_display_update_display(); % call display update to thicken lines
	else
	  disp(['Delineate or load ROIs first']);
	end


%
% Delete an ROI
%
function delete_roi(params)

  global glovars;

	gvs = glovars.fluo_roi_control.roi_selected;
	roi = glovars.fluo_roi_control.roi;

  % all/multi -- are you SURE?
	if (gvs == 0 | length(gvs) > 1)
	  choice = questdlg('Are you sure you want to delete multiple ROIs?', ...
		 'Warning of imminent death', ...
		 'Yes, I know what I am doing','No, I am a retard', 'No, I am a retard');
		% Handle response
		delete_all = 0;
		switch choice
			case 'Yes, I know what I am doing'
				delete_all = 1;
			case 'No, I am a retard'
			  return;
		end
  end

  % all delete
	if (gvs == 0)
		% did the user REALLY want to?
		if (delete_all)
			glovars.fluo_roi_control.new_roi.n_corners = 0;
			glovars.fluo_roi_control.new_roi.corners = [];
			glovars.fluo_roi_control.new_roi.indices = [];
			glovars.fluo_roi_control.new_roi.poly_indices = [];
			glovars.fluo_roi_control.new_roi.raw_fluo = [];
			glovars.fluo_roi_control.new_roi.color = [1 1 0];
			glovars.fluo_roi_control.new_roi.groups = [];
			glovars.fluo_roi_control.new_roi.misc_vals = [];
			glovars.fluo_roi_control.roi = [];
			glovars.fluo_roi_control.n_rois = 0;
		end
  else
		% delete 
		nr = 1;
		newrois = [];
		for r=1:glovars.fluo_roi_control.n_rois
			% skip the victims
			if (length(find(r == gvs)) > 0) ; continue ; end

			% assign
			newrois(nr).color = roi(r).color;
			newrois(nr).corners= roi(r).corners;
			newrois(nr).n_corners= roi(r).n_corners;
			newrois(nr).indices = roi(r).indices;
			newrois(nr).poly_indices = roi(r).poly_indices;
			newrois(nr).raw_fluo = roi(r).raw_fluo;
			nr = nr + 1;
		end
		glovars.fluo_roi_control.roi = newrois;
	  glovars.fluo_roi_control.n_rois = length(newrois);
  end

	if (glovars.fluo_roi_control.n_rois == 0) % No rois? indicate it
	  glovars.fluo_roi_control.roi_selected = -1; 
		set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
	else % select
		ns = glovars.fluo_roi_control.n_rois;
	  glovars.fluo_roi_control.roi_selected = ns;
		set(glovars.fluo_roi_control.current_roi_text,'String', num2str(ns));
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		  glovars.fluo_roi_control.roi(ns).color);
	end

	% update graphics, structure
	fluo_display_update_display();

%
% Join selected ROIs
%
function join_roi(params)
  global glovars;

	sel = glovars.fluo_roi_control.roi_selected;
	roi = glovars.fluo_roi_control.roi;
 
  % sanity checks
	if (length(sel) < 2) 
	  disp('fluo_roi_control_interface::join_roi: select multiple ROIs for joining.');
		return;
	end

	% Join by rebuilding roi structure
  j_idx = [];
	nr = 1;
	newrois = [];
	N_indices = [];
	N_poly_indices = [];
	for r=1:glovars.fluo_roi_control.n_rois
		% member of new group
		if (length(find(r == sel)) > 0) 
			if (length(j_idx) == 0) ; j_idx = nr ; nr=nr+1; end % index for group

      % place holder bc struct weird
			newrois(nr).color = roi(r).color;
			newrois(nr).corners= roi(r).corners;
			newrois(nr).n_corners= roi(r).n_corners;
			newrois(nr).indices = roi(r).indices;
			newrois(nr).poly_indices = roi(r).poly_indices;
			newrois(nr).raw_fluo = roi(r).raw_fluo;
			newrois(nr).groups = roi(r).groups;
			newrois(nr).misc_vals= roi(r).misc_vals;

			% assign everyone else
			N_color = roi(r).color;
			N_corners= roi(r).corners;
			N_n_corners= roi(r).n_corners;
	    if (size(N_indices,1) > 1) ; N_indices = N_indices'; end
	    if (size(roi(r).indices,1) > 1) ; roi(r).indices = roi(r).indices'; end
			N_indices =[N_indices roi(r).indices];
	    if (size(N_poly_indices,1) > 1) ; N_poly_indices = N_poly_indices'; end
	    if (size(roi(r).poly_indices,1) > 1) ; roi(r).poly_indices = roi(r).poly_indices'; end
			N_poly_indices =[N_poly_indices roi(r).poly_indices];
			N_raw_fluo = roi(r).raw_fluo;
      N_groups = roi(r).groups;
      N_misc_vals= roi(r).misc_vals;
		else
			% assign everyone else
			newrois(nr).color = roi(r).color;
			newrois(nr).corners= roi(r).corners;
			newrois(nr).n_corners= roi(r).n_corners;
			newrois(nr).indices = roi(r).indices;
			newrois(nr).poly_indices = roi(r).poly_indices;
			newrois(nr).raw_fluo = roi(r).raw_fluo;
			newrois(nr).groups = roi(r).groups;
			newrois(nr).misc_vals = roi(r).misc_vals;
			nr = nr + 1;
		end
	end

	% --- assign new guy
	% basics
	newrois(j_idx).color = N_color;
	newrois(j_idx).indices = N_indices';
	newrois(j_idx).poly_indices = N_poly_indices';
	% bounding poly -- box FOR NOW
	[N_corners N_n_corners] = roi_compute_bounding_poly(N_indices, 2); 
	newrois(j_idx).corners= N_corners;
	newrois(j_idx).n_corners= N_n_corners;
	% raw fluo
	newrois(j_idx).raw_fluo = [];
	% groupd misc vals
	newrois(j_idx).groups = N_groups;
	newrois(j_idx).misc_vals = N_misc_vals;

  % update meta-roi parameters and recompute fluo
	glovars.fluo_roi_control.roi = newrois;
	glovars.fluo_roi_control.n_rois = length(newrois);
	fluo_roi_control_update_rois();

  % make the new joined roi the selected one
	glovars.fluo_roi_control.roi_selected = j_idx;
	set(glovars.fluo_roi_control.current_roi_text,'String', num2str(j_idx));
	set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', ...
		glovars.fluo_roi_control.roi(j_idx).color);

	% update graphics, structure
	fluo_display_update_display();

%
% Moves selected ROIs up one pixel
%
function move_up(params)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % for border check
	S = size(glovars.fluo_display.display_im);

	% move size
	if (length(params) == 0) 
	  moveby = 1;
	else
	  moveby = params;
	end

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
		  % corners
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) - moveby;

			% points (these VANISH @ border)
			indices = glovars.fluo_roi_control.roi(R(r)).indices;
			Y = indices-S(1)*floor(indices/S(1));
		  X = ceil(indices/S(1));
			Y = Y - moveby;
      indices = Y + S(1)*(X-1);

			% reject border
			keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal

			glovars.fluo_roi_control.roi(R(r)).indices = indices(keep_idx);
		end
		fluo_roi_control_update_rois([1 0]);
		fluo_display_update_display();
	end


%
% Moves selected ROIs down one pixel
%
function move_down(params)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % for border check
	S = size(glovars.fluo_display.display_im);

	% move size
	if (length(params) == 0) 
	  moveby = 1;
	else
	  moveby = params;
	end

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(2,:) + moveby;

			% points (these VANISH @ border)
			indices = glovars.fluo_roi_control.roi(R(r)).indices;
			Y = indices-S(1)*floor(indices/S(1));
		  X = ceil(indices/S(1));
			Y = Y + moveby;
      indices = Y + S(1)*(X-1);

			% reject border
			keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal

			glovars.fluo_roi_control.roi(R(r)).indices = indices(keep_idx);
		end
		fluo_roi_control_update_rois([1 0]);
		fluo_display_update_display();
	end


%
% Moves selected ROIs right one pixel
%
function move_right(params)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % for border check
	S = size(glovars.fluo_display.display_im);

	% move size
	if (length(params) == 0) 
	  moveby = 1;
	else
	  moveby = params;
	end

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) + moveby;

			% points (these VANISH @ border)
			indices = glovars.fluo_roi_control.roi(R(r)).indices;
			Y = indices-S(1)*floor(indices/S(1));
		  X = ceil(indices/S(1));
			X = X + moveby;
      indices = Y + S(1)*(X-1);

			% reject border
			keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal

			glovars.fluo_roi_control.roi(R(r)).indices = indices(keep_idx);
		end
		fluo_roi_control_update_rois([1 0]);
		fluo_display_update_display();
  end



%
% Moves selected ROIs left one pixel
%
function move_left(params)
  global glovars;
  croi = glovars.fluo_roi_control.roi_selected;

  % for border check
	S = size(glovars.fluo_display.display_im);

	% move size
	if (length(params) == 0) 
	  moveby = 1;
	else
	  moveby = params;
	end

  % sanity
	if (croi == -1)
	  disp('No ROIs selected.');
  else
		% move ...
		if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
		for r=1:length(R)
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) = ...
			glovars.fluo_roi_control.roi(R(r)).corners(1,:) - moveby;

			% points (these VANISH @ border)
			indices = glovars.fluo_roi_control.roi(R(r)).indices;
			Y = indices-S(1)*floor(indices/S(1));
		  X = ceil(indices/S(1));
			X = X - moveby;
      indices = Y + S(1)*(X-1);

			% reject border
			keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal

			glovars.fluo_roi_control.roi(R(r)).indices = indices(keep_idx);
		end
		fluo_roi_control_update_rois([1 0]);
		fluo_display_update_display();
  end

%
% Restricts roi(s) by selected detector
%
function restrict_by(params)
  global glovars;
 
  % gui gear
	roi_detector_idx = get(glovars.fluo_roi_control.roi_detect_method_list,'Value');

	% make call
  roi_detect('restrict', roi_detector_idx, '');



%
% Dilate border by 1 pixel
%
function dilate_border_by_one(params)
  % parameters to the detector
	roi_detector_idx = 2;
  params(1).value = 1; % gui override
	params(2).value = 1; % 1 - dilate ; 2 - erode
 	params(3).value = 1; % how many pixels to apply morphological operator

	% make call
  roi_detect('restrict', roi_detector_idx, params);

%
% Erode border by 1 pixel
%
function erode_border_by_one(params)
  % parameters to the detector
	roi_detector_idx = 2;
  params(1).value = 1; % gui override
	params(2).value = 2; % 1 - dilate ; 2 - erode
 	params(3).value = 1; % how many pixels to apply morphological operator

	% make call
  roi_detect('restrict', roi_detector_idx, params);

%
% Fill holes in ROI(s)
%
function fill_holes(params)
  global glovars;

	% grab variables -- selected rois
	rois = glovars.fluo_roi_control.roi;
	croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % get convex hulled rois
	for r=1:length(R)
	  roi = rois(R(r));
  	[corners n_corners] = roi_compute_bounding_poly(roi.indices, 2); % use convex hull to compute new bounding polygon off indices
    nrois(r).corners = corners;
    nrois(r).n_corners = n_corners;
	end

	% then reset to to full filled poly
	params(1).value = nrois;
  members = reset_rois_filled_poly(params);

	% and copy new indices into main roi structure
	for r=1:length(R)
	  rois(R(r)).indices = members(r).indices;
	end
  glovars.fluo_roi_control.roi = rois;
	fluo_roi_control_update_rois([0 1]);
	fluo_display_update_display();

%
% Tight border -- make border convex hull of points
%
function tight_border(params)
  global glovars;

	% grab variables -- selected rois
	rois = glovars.fluo_roi_control.roi;
	croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % get convex hulled rois
	for r=1:length(R)
	  roi = rois(R(r));
  	[corners n_corners] = roi_compute_bounding_poly(roi.indices, 2); % use convex hull to compute new bounding polygon off indices
    rois(R(r)).corners = corners;
    rois(R(r)).n_corners = n_corners;
	end

  % update all of it
  glovars.fluo_roi_control.roi = rois;
	fluo_roi_control_update_rois([1 1]);
	fluo_display_update_display();
 
%
% Expands / contracts roi indices based on histogram of intensity
%  params(1).value: how many to add/subtract (+ = add ; - = subtract)
%
function change_n_indices_on_lum(params)
  global glovars;

	% grab variables -- selected rois ; number
	n_chg = params(1).value;
	rois = glovars.fluo_roi_control.roi;
	croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % compute same image as what is displayed
	lum_im = glovars.fluo_display.currently_displayed_image;

  % get convex hulled rois
	for r=1:length(R)
    % original indices
		old_indices = rois(R(r)).indices;
		new_indices = old_indices;
	   
	  % get the indices inside
		rrfp_param(1).value = rois(R(r));
		mem = reset_rois_filled_poly(rrfp_param);
		idx_in = mem(1).indices;

		% add or subtract appropriately
    if (n_chg > 0) % grow ROI -- add brightest
			% get luminance of  candidates -- unselected points
			candidate_idx = setdiff(idx_in, old_indices);

			% sort the luminance of candidates
			lums = lum_im(candidate_idx);
			[val s_idx] = sort(lums, 'descend');

		  if (length(s_idx) > 0) % do we have anything to work with?
			  add_idx = candidate_idx(s_idx(1:min(n_chg, length(s_idx))));
				new_indices = [old_indices' add_idx']';
			else 
			  disp('No more points to add');
			end
		else % reduce ROI -- take away darkest
			% sort the luminance of candidates
			lums = lum_im(old_indices);
			[val s_idx] = sort(lums, 'ascend');

		  if (length(s_idx) > 0) % do we have anything to work with?
			  subst_idx = old_indices(s_idx(1:min(-1*n_chg, length(s_idx))));
				new_indices = setdiff(old_indices, subst_idx);
			else 
			  disp('No more points to remove');
			end
		end

		% update roi structure
    glovars.fluo_roi_control.roi(R(r)).indices = new_indices;
	end
  
	% display update ...
	fluo_roi_control_update_rois([0 1]);
	fluo_display_update_display();

%
% This will remove all but the single largest component from an ROI --
%   no effect on border
%
function remove_all_but_largest_connected_component(params)
  global glovars;

	% grab variables -- selected rois ; number
	rois = glovars.fluo_roi_control.roi;
	croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % this is used for compnent detection
	bw_im = zeros(size(mean(glovars.fluo_display.display_im,3)));

  % loop over selected rois
	for r=1:length(R)
    % original indices
		indices = rois(R(r)).indices;
	   
	  % make a bw image where 1 = indices 0 = all else
		bw_im = 0*bw_im;
		bw_im(indices) = 1;

		% bw label it to get components
		bw_lab = bwlabel(bw_im);

    % take largest
		ul = unique(bw_lab);
		nl = zeros(length(ul),1);
		for l=1:length(ul)
		  if(ul(l) > 0)
			  nl(l) = length(find(bw_lab == ul(l)));
			end
		end
    [val idx] = max(nl);
		new_indices = find(bw_lab == ul(idx));
    
		% update roi structure
    glovars.fluo_roi_control.roi(R(r)).indices = new_indices;
	end
  
	% display update ...
	fluo_roi_control_update_rois([0 1]);
	fluo_display_update_display();
  

%
% This will split into connnected ROI pixels, updating border accordingly
%
function split_into_connected_components(params)
  global glovars;

	% grab variables -- selected rois 
	rois = glovars.fluo_roi_control.roi;
	croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end
	n_rois = length(rois);

  % this is used for compnent detection
	bw_im = zeros(size(mean(glovars.fluo_display.display_im,3)));

  % loop over selected rois
	for r=1:length(R)
    % original indices
		indices = rois(R(r)).indices;
	   
	  % make a bw image where 1 = indices 0 = all else
		bw_im = 0*bw_im;
		bw_im(indices) = 1;

		% bw label it to get components
		bw_lab = bwlabel(bw_im);

    % break them up . . . 
		ul = unique(bw_lab);
		sub_n = 1;
		for l=1:length(ul)
		  if(ul(l) > 0) % skip 0 = background
				new_indices = find(bw_lab == ul(l));
				 
				% bounding polygon update via tight
				[corners n_corners] = roi_compute_bounding_poly(new_indices, 2); 

				% update roi structure of FIRSt one
				if (sub_n == 1)
					glovars.fluo_roi_control.roi(R(r)).indices = new_indices;
					glovars.fluo_roi_control.roi(R(r)).corners = corners;
					glovars.fluo_roi_control.roi(R(r)).n_corners = n_corners;
				else % append rest to end
					n_rois = n_rois+1;
					glovars.fluo_roi_control.roi(n_rois).indices = new_indices;
					glovars.fluo_roi_control.roi(n_rois).corners = corners;
					glovars.fluo_roi_control.roi(n_rois).n_corners = n_corners;
					glovars.fluo_roi_control.roi(n_rois).raw_fluo = [];
					ci = rem(n_rois,size(glovars.fluo_roi_control.roi_colors,1))+1;
					glovars.fluo_roi_control.roi(n_rois).color = glovars.fluo_roi_control.roi_colors(ci,:);
				end

				sub_n = sub_n+1;
			end
	  end
	end

	% update n_rois
	glovars.fluo_roi_control.n_rois = n_rois;
	 
	% display update ...
	fluo_roi_control_update_rois([1 1]);
	fluo_display_update_display();
 

%
% Turns numbering on/off
%
function toggle_number_display(params)
  global glovars;
	if (glovars.fluo_roi_control.show_roi_numbers == 0)
	  glovars.fluo_roi_control.show_roi_numbers = 1;
		set (glovars.fluo_roi_control.show_numbers_checkbox,'Value', 1);
	else
	  glovars.fluo_roi_control.show_roi_numbers = 0;
		set (glovars.fluo_roi_control.show_numbers_checkbox,'Value', 0);
	end
	fluo_display_update_display();

%
% Plots histogram for currently selected ROI(s)
% 
function plot_intensity_hist(params)
 global glovars;

	% grab variables -- selected rois 
	rois = glovars.fluo_roi_control.roi;
	croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % this is used for compnent detection
	lum_im = mean(glovars.fluo_display.display_im,3); 

  % loop over selected rois
	for r=1:length(R)
	  % get the indices inside
		rrfp_param(1).value = rois(R(r));
		mem = reset_rois_filled_poly(rrfp_param);
		indices = mem(1).indices;
	   
		% plot
		vals = lum_im(indices);
		figure;
    hist(vals,50);

		disp(['mean: ' num2str(mean(vals)) ' median: ' num2str(median(vals)) ' sd: ' num2str(std(vals))]);
	end

%
% Allows saving ROI to file
%
function save_rois(params)
	global glovars;

	% go to appropriate directory
	cwd = pwd();

	% dialog
	if (exist(glovars.data_lastpath, 'dir') == 7) 
		cd (glovars.data_lastpath);
	end
	[filename, pathname, filt] = ... 
	  uiputfile({'*.mat'}, 'Save ROI data to file', 'ROI.mat');

  % and save ...
	if (isequal(filename,0) == 0)
		fluo_roi_control_update_rois();
	  roi = glovars.fluo_roi_control.roi;
	  n_rois = glovars.fluo_roi_control.n_rois;
	  % FORMAT dependence
		if (get(glovars.fluo_roi_control.file_format_list,'Value') == 1) % standard format
			save([pathname filesep filename], 'roi', 'n_rois');
			disp(['ROI data saved to ' pathname filesep filename]);
		else
      extern_roi2rtrk(roi, [pathname filesep filename]);
		end

    % store
		glovars.data_lastpath = pathname;
	end

  % cleanup
	cd(cwd);

%
% Allows loading of ROI file
%
function load_rois(params)
  global glovars;

  % dialog, exist test
	[filename, filepath]=uigetfile({'*.mat'}, ...
	  'Select ROI file', glovars.data_lastpath);

	% load
	if (exist([filepath filesep filename],'file') ~= 0)
	  % FORMAT dependence
		if (get(glovars.fluo_roi_control.file_format_list,'Value') == 1) % standard format
			load([filepath filesep filename]);
			disp(['Loaded ROI file ' filepath filesep filename]);
		else
		  roi = extern_rtrk2roi([filepath filesep filename]);
			n_rois = length(roi);
			disp(['Loaded rtrk compatible ROI file ' filepath filesep filename]);
		end
 
	  glovars.fluo_roi_control.roi = roi;
		glovars.fluo_roi_control.n_rois = n_rois;

		% --- legacy support  // check proper formatting

		% color
		for r=1:length(glovars.fluo_roi_control.roi)
		  if (length(glovars.fluo_roi_control.roi(r).color) == 1)
		    if (r == 1 ) ; disp('load_rois::found old color scheme ; updating.'); end
		    ci = rem(r,size(glovars.fluo_roi_control.roi_colors,1))+1;
				glovars.fluo_roi_control.roi(r).color = glovars.fluo_roi_control.roi_colors(ci,:);
			end
		end
	
		% group stuff
		for r=1:length(glovars.fluo_roi_control.roi)
		  if (~ isfield(glovars.fluo_roi_control.roi(r), 'groups'))
			  glovars.fluo_roi_control.roi(r).groups = [];
			end
	  end
			 
		% misc_vals
		for r=1:length(glovars.fluo_roi_control.roi)
		  if (~ isfield(glovars.fluo_roi_control.roi(r), 'misc_vals'))
			  glovars.fluo_roi_control.roi(r).misc_vals = [];
			end
	  end
			 
		% poly indices
		if (~ isfield(glovars.fluo_roi_control.roi, 'poly_indices'))
		  disp('load_rois::no poly_indices field found ; autogenerating.');
			fluo_roi_control_update_rois([1 1]);
		else
			fluo_roi_control_update_rois();
		end

    % --- update stuff

		% text of who is seelected
    glovars.fluo_roi_control.roi_selected = 0; % default is select all for fast plotting
		set(glovars.fluo_roi_control.current_roi_text,'String', 'All');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);

		% roi fill color update based on fill mode
		fluo_roi_control_interface('assign_filled_roi_colors', []);
 
    % update lastpath
	  glovars.data_lastpath = filepath;

		% update screen
		fluo_display_update_display();
  else
		disp(['Invalid ROI file: ' filepath filesep filename]);
	end

%
% Assigns ROI colors based on roi_fill_method_list
%
function assign_filled_roi_colors(params)
  global glovars;

  % 2: basic roi colors ; 3: monochrome ; 4: maxdff ; 5: tpeak ; 6: fill/not filled
  color_mode = get(glovars.fluo_roi_control.roi_fill_method_list, 'Value');
  
	% --- switch statement
  switch color_mode
    case 2 % basic colors
		  for r=1:length(glovars.fluo_roi_control.roi)
		    ci = rem(r,size(glovars.fluo_roi_control.roi_colors,1))+1;
				glovars.fluo_roi_control.roi(r).color = glovars.fluo_roi_control.roi_colors(ci,:);
			end

		case 3 % monochrome - blue is rockin
		  for r=1:length(glovars.fluo_roi_control.roi)
				glovars.fluo_roi_control.roi(r).color = [0 0.5 1];
			end

		case {4,5} % maxdff4 , tpeak 5
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
			if (color_mode == 4) % maxdff
				cm =jet(100);
			else % time of peak instead
				tmax_dff(find(max_dff < 0.2*M)) = 0; % omit points with small deflections
				disp(['fluo_display_update_display::not color coding points where df/f is below ' num2str(0.2*M)]);
				cm =hot(100);
			end
			disp(['fluo_display_update_display::setting max to: ' num2str(M)]);
			% now assign the part of the image with the roi the appropriate value based on colormap
			for r=1:glovars.fluo_roi_control.n_rois

				% where in the colormap? based on maxdff vs t peak
				if (color_mode == 4) % maxdff
					map_idx = ceil(100*(max_dff(r)/M));
				else
					map_idx = ceil(100*(tmax_dff(r)/Mt));
				end
				if (map_idx == 0 ) ; map_idx = 1 ; end
				if (map_idx > 100) ; map_idx = 100; end

				glovars.fluo_roi_control.roi(r).color = cm(map_idx,:);
			end

		otherwise 
		  % group set
			if (color_mode >= glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start)
			  si = color_mode-glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+1;
				group_set = glovars.fluo_roi_control.roi_group_set(si);
				set_id = group_set.id;
				groups = glovars.fluo_roi_control.roi_group;
       
			  % find groups that are part of this set
				for r=1:glovars.fluo_roi_control.n_rois
				  glovars.fluo_roi_control.roi(r).color = [0 0 0]; % default color
          for g=1:length(groups)
					  g_sets = groups(g).set;
					  if (length(find(g_sets == set_id)) == 1 & ...
						    length(find(glovars.fluo_roi_control.roi(r).groups == groups(g).id)) == 1)
						  glovars.fluo_roi_control.roi(r).color = groups(g).color;
						end
					end
				end
			else % fail -- MESSAGE!
				disp('fluo_roi_control_interface::select a fill mode to use fill.');
			end
	end


%
% Loads an ROI groups file that defines groups and group sets.  Will load
%  the file specified by params(1).value.  If blank, loads the DEFAULT file,
%  and in this case it will pre-populate groups as well (this is done @ init)
%
function load_roi_group_file(params)
  global glovars;
 
	init_if_fail = 0;
  if (length(params) == 0)
	  group_file_path = glovars.fluo_roi_control.roi_group_file_path;
	  init_if_fail = 1;
  else
	  group_file_path = params(1).value;
	end

  % --- does it exist?
  if (exist(group_file_path,'file') == 2)
	  load(group_file_path);
		glovars.fluo_roi_control.roi_group = roi_group;
		glovars.fluo_roi_control.roi_group_set = roi_group_set;
  else
		% --- if not, and you are to init, do it
		disp(['load_roi_group_file::could not locate ' group_file_path]);
    if (init_if_fail)
		  % --- setup default groups
			roi_group(1).id = 99;
			roi_group(1).descr_str = 'Unverified for this day';
      roi_group(1).color = [1 0 0];
			roi_group(1).set = [];
			roi_group(2).id = 6001;
			roi_group(2).descr_str = 'Filled cell';
      roi_group(2).color = [1 0 0];
			roi_group(2).set = 1;
			roi_group(3).id = 6002;
			roi_group(3).descr_str = 'Unfilled cell';
      roi_group(3).color = [0 0 1];
			roi_group(3).set = 1;
			roi_group(4).id = 6003;
			roi_group(4).descr_str = 'Arbitrary fill cell';
      roi_group(4).color = [1 0 1];
			roi_group(4).set = 1;

			% --- defaults sets
			roi_group_set(1).id = 1;
			roi_group_set(1).descr_str = 'Nuclear filled?';

			% final
			glovars.fluo_roi_control.roi_group = roi_group;
			glovars.fluo_roi_control.roi_group_set = roi_group_set;

			% save
			frci_params(1).value = group_file_path;
			fluo_roi_control_interface('save_roi_groups', frci_params);
		end
	end

  % --- update gui elements (lists)
  % groups
  for g=1:length(glovars.fluo_roi_control.roi_group)
	  group = glovars.fluo_roi_control.roi_group(g);
	  g_str{g} = group.descr_str;
	end
	set(glovars.fluo_roi_control.roi_group_list, 'String', g_str);
	set(glovars.fluo_roi_control.roi_group_list, 'Value', 1);

	% sets
  for s=1:length(glovars.fluo_roi_control.roi_group_set)
	  group_set = glovars.fluo_roi_control.roi_group_set(s);
	  s_str{s} = group_set.descr_str;
	end
	set(glovars.fluo_roi_control.roi_group_set_list, 'String', s_str);
	set(glovars.fluo_roi_control.roi_group_set_list, 'Value', 1);

	% update fill method list
	mls = get(glovars.fluo_roi_control.roi_fill_method_list, 'String');
	for m=glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+(0:length(s_str)-1)
	  mls{m} = s_str{m-glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+1};
	end
  set(glovars.fluo_roi_control.roi_fill_method_list, 'String', mls);

%
% refreshes group-related pulldowns
% 
function refresh_group_related_pulldowns(params)
  global glovars;

  % --- update gui elements (lists)
  % groups
  for g=1:length(glovars.fluo_roi_control.roi_group)
	  group = glovars.fluo_roi_control.roi_group(g);
	  g_str{g} = group.descr_str;
	end
	set(glovars.fluo_roi_control.roi_group_list, 'String', g_str);
	set(glovars.fluo_roi_control.roi_group_list, 'Value', 1);

	% sets
  for s=1:length(glovars.fluo_roi_control.roi_group_set)
	  group_set = glovars.fluo_roi_control.roi_group_set(s);
	  s_str{s} = group_set.descr_str;
	end
	set(glovars.fluo_roi_control.roi_group_set_list, 'String', s_str);
	set(glovars.fluo_roi_control.roi_group_set_list, 'Value', 1);

	% update fill method list
	mls = get(glovars.fluo_roi_control.roi_fill_method_list, 'String');
	for m=glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+(0:length(s_str)-1)
	  mls{m} = s_str{m-glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+1};
	end
  set(glovars.fluo_roi_control.roi_fill_method_list, 'String', mls);

%
% updates the ROI group gui elements based on roi_group and roi_group_set in glovars.fluo_roi_control
% 
function update_roi_group_gui(params)
  global glovars;
 
  % pull IDs
	g_id = get(glovars.fluo_roi_control.roi_group_list, 'Value');
	s_id = get(glovars.fluo_roi_control.roi_group_set_list, 'Value');
  
  % group elements
	group = glovars.fluo_roi_control.roi_group(g_id);
  set(glovars.fluo_roi_control.roi_group_id_edit, 'String', num2str(group.id));
  set(glovars.fluo_roi_control.roi_group_name_edit, 'String', num2str(group.descr_str));
  set(glovars.fluo_roi_control.roi_group_color_edit, 'String', [ '[' num2str(group.color) ']']);
  set(glovars.fluo_roi_control.roi_group_set_membership_edit, 'String', [ '[' num2str(group.set) ']']);
 
	% group set elements
	group_set = glovars.fluo_roi_control.roi_group_set(s_id);
  set(glovars.fluo_roi_control.roi_group_set_id_edit, 'String', num2str(group_set.id));
  set(glovars.fluo_roi_control.roi_group_set_name_edit, 'String', num2str(group_set.descr_str));


%
% Allows saving ROI groups to file
%
% params(1).value = file to save to
function save_roi_groups(params)
	global glovars;

	% params
	savepath = params(1).value;

  % and save ...
  roi_group = glovars.fluo_roi_control.roi_group;
  roi_group_set = glovars.fluo_roi_control.roi_group_set;

	save(savepath, 'roi_group', 'roi_group_set');
	disp(['ROI group data saved to ' savepath]);

