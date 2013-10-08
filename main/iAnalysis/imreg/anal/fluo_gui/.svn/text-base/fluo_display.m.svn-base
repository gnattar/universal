function varargout = fluo_display(varargin)
% FLUO_DISPLAY M-file for fluo_display.fig
%      FLUO_DISPLAY, by itself, creates a new FLUO_DISPLAY or raises the existing
%      singleton*.
%
%      H = FLUO_DISPLAY returns the handle to a new FLUO_DISPLAY or the handle to
%      the existing singleton*.
%
%      FLUO_DISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUO_DISPLAY.M with the given input arguments.
%
%      FLUO_DISPLAY('Property','Value',...) creates a new FLUO_DISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluo_display_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluo_display_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluo_display

% Last Modified by GUIDE v2.5 08-Apr-2010 18:34:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluo_display_OpeningFcn, ...
                   'gui_OutputFcn',  @fluo_display_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before fluo_display is made visible.
function fluo_display_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluo_display (see VARARGIN)

% SP ----------------------------------------------------------------------
if (isglobal('glovars')) ; clear global glovars ; end
global glovars; 

% 0) Assign global variable settings that need to be 'zeroed'
glovars.fluo_display_axes.mouse_mode = 0; % 0 - nothing ; 1 - roi-selection
glovars.fluo_display.display_mode = 1; % 1: frame 2: stack mean 3: stack max proj 4: gauss convolved
glovars.fluo_display.display_im_x_matrix = []; % for use in computations ; populated in loading im
glovars.fluo_display.display_im_y_matrix = [];
glovars.fluo_display.stop_movie = 0; % set to 1 during movie play to stop

% 1) load config file --

% a) ALL THIS should be assignable from the future config gui
glovars.data_rootpath = '/data/mouse_gcamp_learn/';
disp(['fluo_display.m::data_rootpath set to ' glovars.data_rootpath '; edit fluo_display.m right before this message to change.']);
glovars.fluo_display.hor_pix2um = 1; % in um/pix
glovars.fluo_display.ver_pix2um = 1; % in um/pix
glovars.fluo_display.max_pixel_value = 4096; % maximal value for pixels

% b) things that are not necessarily assignable
glovars.data_lastpath = '/home/speron/data/mouse_gcamp_learn/';
glovars.data_lastpath = '/media/tmp/an27043';
glovars.fluo_display.nchan = 1; % number of image channels
glovars.fluo_display.usedchan = 1; % used image channel

% 2) files in place? determine your execution etc. paths based off of where fluo_display.m resides
glovars.root_path = strrep(which('fluo_display'), ['fluo_gui' filesep 'fluo_display.m'],'');
glovars.confpath = [glovars.root_path 'conf'];
disp(['fluo_display.m::confpath set to ' glovars.confpath]);
if (exist([glovars.root_path filesep 'tmp'], 'dir') == 0)
  disp(['fluo_display::making temp directory ' glovars.root_path filesep 'tmp ...']);
  mkdir([glovars.root_path filesep 'tmp']);
end
if (exist(glovars.confpath, 'dir') == 0)
  disp(['fluo_display::making config file directory ' glovars.confpath]);
  mkdir(glovars.confpath);
end
glovars.processors_path = [glovars.root_path filesep 'processors'];
glovars.tmp_path = [glovars.root_path filesep 'tmp'];
glovars.par_path = [glovars.root_path filesep 'par']; % directory for parallel processing .mat files and scripts

% 3) connect relevant gui elements to glovars
glovars.fluo_display.fluo_display_figure = handles.figure1;
glovars.fluo_display.fluo_display_axes = handles.fluo_display_axes;
glovars.fluo_display.fluo_display_message_text = handles.fluo_display_message_text;
glovars.fluo_display.fluo_display_frame_slider = handles.fluo_display_frame_slider;
glovars.fluo_display.fluo_display_framenum_text = handles.fluo_display_framenum_text;

% 4) assign default values to glovar members that need it
glovars.fluo_display.aspect_ratio = 1; % 1: square ; 2: image size ; 3: pix/um-based

% 5) open other relevant guis
fluo_control_main();
fluo_roi_control();

% 6) load image file
if (length(varargin) > 1)
	fluo_display_open_stack(varargin{1},varargin{2}, [], 1);
%	fluo_display_update_display(); % update display after load
elseif (length(varargin) == 1)
  if (exist(varargin{1}) == 7) % directory
		fluo_display_open_stack(varargin{1});
	elseif (exist(varargin{1}) == 2) % file
	  [fpath fname ext] = fileparts(varargin{1});
		fluo_display_open_stack([fpath filesep], [fname ext], [], 1);
	end
end

% 7) Connect keyboard processing
set(glovars.fluo_display.fluo_display_figure,'KeyPressFcn', @fluo_display_keypress_process);

% END SP ------------------------------------------------------------------

% Choose default command line output for fluo_display
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fluo_display wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fluo_display_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_open_stack_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_open_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_display_open_stack();


% --- Executes on slider movement.
function fluo_display_frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_display_frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  global glovars;

  im_frame = round(get(hObject,'Value'));
	glovars.fluo_display.display_im_frame = im_frame;
	glovars.fluo_display.stop_movie = 1;
	fluo_display_update_display();

% --- Executes during object creation, after setting all properties.
function fluo_display_frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fluo_display_frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --------------------------------------------------------------------
function config_menu_Callback(hObject, eventdata, handles)
% hObject    handle to config_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_save_user_settings_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_save_user_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_save_gui_settings_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_save_gui_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fluo_save_stack_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_save_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
	global glovars;

	% go to appropriate directory
	cwd = pwd();

	% dialog
  cd (glovars.processor_step(1).im_path);

	[filename, pathname, filt] = ... 
	  uiputfile({'*.tif'}, 'Save stack to file ...', ...
		strrep(glovars.processor_step(1).im_fname, '.tif', '_2.tif'));

  % and save ...
	if (isequal(filename,0) == 0)
	  stack = glovars.fluo_display.display_im;
		save_image(stack, [pathname filesep filename], glovars.fluo_display.display_im_hdr);
		%imwrite(uint16(stack(:,:,1)), [pathname filesep filename], 'tif', 'Compression', 'none', 'WriteMode', 'overwrite');
		%for s=2:size(stack,3)
		%	imwrite(uint16(stack(:,:,s)), [pathname filesep filename], 'tif', 'Compression', 'none', 'WriteMode', 'append');
		%end
		%disp(['Image stack saved to ' pathname filesep filename]);
	end

  % cleanup
	cd(cwd);

% --------------------------------------------------------------------
function fluo_print_display_Callback(hObject, eventdata, handles)
% hObject    handle to fluo_print_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
 
  % generate a fiure with the current view by swapping axes and running 
	%  fluo_display_update_display
	old_axes = glovars.fluo_display.fluo_display_axes; 
  f = figure;
	ax = axes;
	glovars.fluo_display.fluo_display_axes = ax;
	fluo_display_update_display();

	% put it back
	glovars.fluo_display.fluo_display_axes = old_axes; 
	fluo_display_update_display();
  

% --- Executes on button press in play_movie_button.
function play_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;

  % sanity
	if (glovars.fluo_display.display_im_nframes == 1)
	  disp('Only one frame - that would be stOOOpid.');
		return;
	end

  % grab current frame
  cf = glovars.fluo_display.display_im_frame;
	glovars.fluo_display.stop_movie = 0;

	% loop start to finish, around current frame
	frame_dt = min(0.025, 5/glovars.fluo_display.display_im_nframes);
  for f=[cf:glovars.fluo_display.display_im_nframes 1:cf]
		glovars.fluo_display.display_im_frame = f;
		if (glovars.fluo_display.stop_movie) ; break ; end
		fluo_display_update_display();
		pause (frame_dt); % 10 hz -- OR 10 s at most in case long movie
	end

 


% --- Executes on button press in stop_movie_button.
function stop_movie_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_movie_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;
	glovars.fluo_display.stop_movie = 1;


% --- Executes on button press in play_loop_button.
function play_loop_button_Callback(hObject, eventdata, handles)
% hObject    handle to play_loop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global glovars;

  % sanity
	if (glovars.fluo_display.display_im_nframes == 1)
	  disp('Only one frame - that would be stOOOpid.');
		return;
	end

  % enable playing
	glovars.fluo_display.stop_movie = 0;

	% loop around and around and around
	frame_dt = min(0.025, 5/glovars.fluo_display.display_im_nframes);
  f = glovars.fluo_display.display_im_frame;

	while (~ glovars.fluo_display.stop_movie)
    % increment
		f = f+1;
		if (f > glovars.fluo_display.display_im_nframes) ; f = 1 ; end

		% display & pozz
		glovars.fluo_display.display_im_frame = f;
		fluo_display_update_display();
		pause (frame_dt); % 10 hz -- OR 10 s at most in case long movie
	end



% --------------------------------------------------------------------
% --------------------------------------------------------------------
% MY OWN FUNCTIONS -- NOT GUI GENERATED
% --------------------------------------------------------------------
% --------------------------------------------------------------------

% --- Executes on mouse press over main_axes background.
function fluo_display_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  this_point = get(handles.fluo_display_axes,'CurrentPoint');

	switch (glovars.fluo_display_axes.mouse_mode)
	  case 1 % ROI drawing -- highlight w/ yellow line / dot
		  np = glovars.fluo_roi_control.new_roi.n_corners + 1;
		  glovars.fluo_roi_control.new_roi.n_corners = np;

		  glovars.fluo_roi_control.new_roi.corners(:,np) = ...
			  [this_point(1,1) this_point(1,2)];
	    draw_x(glovars.fluo_roi_control.new_roi.corners(1,np), ...
	           glovars.fluo_roi_control.new_roi.corners(2,np), 1, ...
						 glovars.fluo_roi_control.new_roi.color);
			if (np > 1) % connect line to last point if needbe
			  hold on;
			  plot([glovars.fluo_roi_control.new_roi.corners(1,np-1) ...
			        glovars.fluo_roi_control.new_roi.corners(1,np)], ...
			        [glovars.fluo_roi_control.new_roi.corners(2,np-1) ...
			        glovars.fluo_roi_control.new_roi.corners(2,np)], ...
							'-', 'Color', glovars.fluo_roi_control.new_roi.color);
				hold off;
			end

		case 2 % selecting existing ROI
		  for r=1:length(glovars.fluo_roi_control.roi)
			  x = this_point(1,1);
				y = this_point(1,2);
			  x_c = glovars.fluo_roi_control.roi(r).corners(1,:);
			  y_c = glovars.fluo_roi_control.roi(r).corners(2,:);

        if (x > min(x_c) & x < max(x_c) & y > min(y_c) & y < max(y_c))
					glovars.fluo_roi_control.roi_selected = r; % select this guy
					set(glovars.fluo_roi_control.current_roi_text,'String', num2str(r));
					set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', glovars.fluo_roi_control.roi(r).color);
			 
					% update screen
					fluo_display_update_display();
				  break;
				end
			end

		case 3 % selecting *multiple* rois
		  for r=1:length(glovars.fluo_roi_control.roi)
			  x = this_point(1,1);
				y = this_point(1,2);
			  x_c = glovars.fluo_roi_control.roi(r).corners(1,:);
			  y_c = glovars.fluo_roi_control.roi(r).corners(2,:);

        if (x > min(x_c) & x < max(x_c) & y > min(y_c) & y < max(y_c))
				  if (length(find(glovars.fluo_roi_control.roi_selected == r)) > 0) % already member? REMOVE
					  glovars.fluo_roi_control.roi_selected = setdiff(glovars.fluo_roi_control.roi_selected,r); 
					else
					  glovars.fluo_roi_control.roi_selected = [glovars.fluo_roi_control.roi_selected r]; % GROW selected index
					  set(glovars.fluo_roi_control.current_roi_text,'String', 'Multi');
					  set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
					end
			 
					% update screen reflecting selection
					fluo_display_update_display();
				  break;
				end
			end

		case 4 % seelcting multiple ROIs via bounding polygon
		  np = size(glovars.fluo_roi_control.bounding_poly.corners,2)+1;

		  glovars.fluo_roi_control.bounding_poly.corners(:,np) = ...
			  [this_point(1,1) this_point(1,2)];
	    draw_x(glovars.fluo_roi_control.bounding_poly.corners(1,np), ...
	           glovars.fluo_roi_control.bounding_poly.corners(2,np), 1, ...
						 glovars.fluo_roi_control.bounding_poly.color);
			if (np > 1) % connect line to last point if needbe
			  hold on;
			  plot([glovars.fluo_roi_control.bounding_poly.corners(1,np-1) ...
			        glovars.fluo_roi_control.bounding_poly.corners(1,np)], ...
			        [glovars.fluo_roi_control.bounding_poly.corners(2,np-1) ...
			        glovars.fluo_roi_control.bounding_poly.corners(2,np)], ...
							'-', 'Color', glovars.fluo_roi_control.bounding_poly.color );
				hold off;
			end

		case 5 % selecting points (3) for an affine transform of ROIs
		  nr = size(glovars.fluo_roi_control.match_roi_corners,2)+1;
		  ni = size(glovars.fluo_roi_control.match_image_corners,2)+1;

			if (nr == ni) % add roi corner
				glovars.fluo_roi_control.match_roi_corners(:,nr) = ...
					[this_point(1,1) this_point(1,2)];
				draw_x(glovars.fluo_roi_control.match_roi_corners(1,nr), ...
							 glovars.fluo_roi_control.match_roi_corners(2,nr), 1, ...
							 'r');
			else % add image point
				glovars.fluo_roi_control.match_image_corners(:,ni) = ...
					[this_point(1,1) this_point(1,2)];
				draw_x(glovars.fluo_roi_control.match_image_corners(1,ni), ...
							 glovars.fluo_roi_control.match_image_corners(2,ni), 1, ...
							 'b');
				% connect line to matching point
				hold on;
				plot([glovars.fluo_roi_control.match_image_corners(1,ni) ...
								glovars.fluo_roi_control.match_roi_corners(1,nr-1)], ...
								[glovars.fluo_roi_control.match_image_corners(2,ni) ...
								glovars.fluo_roi_control.match_roi_corners(2,nr-1)], ...
								'w-');
				hold off;

				% final point?
				if (nr == 4)
					% determine transform
					x = glovars.fluo_roi_control.match_roi_corners(1,:);
					y = glovars.fluo_roi_control.match_roi_corners(2,:);
					x_h = glovars.fluo_roi_control.match_image_corners(1,:);
					y_h = glovars.fluo_roi_control.match_image_corners(2,:);

          p_s = [x(1) y(1) x(2) y(2) x(3) y(3)];
          p_t = [x_h(1) y_h(1) x_h(2) y_h(2) x_h(3) y_h(3)];
          
					glovars.fluo_roi_control.aff_mat = compute_affmat(p_s, p_t);
					disp('Affine matrix computed from points.  Click APPLY to use it.');

					% reset everything
					glovars.fluo_roi_control.match_roi_corners = [];
					glovars.fluo_roi_control.match_image_corners = [];
					glovars.fluo_display_axes.mouse_mode = 0;
				end
		  end

	  case 6 % ROI drawing -- highlight w/ yellow line / dot -- BUT for redraw
		  np = glovars.fluo_roi_control.new_roi.n_corners + 1;
		  glovars.fluo_roi_control.new_roi.n_corners = np;

		  glovars.fluo_roi_control.new_roi.corners(:,np) = ...
			  [this_point(1,1) this_point(1,2)];
	    draw_x(glovars.fluo_roi_control.new_roi.corners(1,np), ...
	           glovars.fluo_roi_control.new_roi.corners(2,np), 1, ...
						 glovars.fluo_roi_control.new_roi.color);
			if (np > 1) % connect line to last point if needbe
			  hold on;
			  plot([glovars.fluo_roi_control.new_roi.corners(1,np-1) ...
			        glovars.fluo_roi_control.new_roi.corners(1,np)], ...
			        [glovars.fluo_roi_control.new_roi.corners(2,np-1) ...
			        glovars.fluo_roi_control.new_roi.corners(2,np)], ...
							'-', 'Color', glovars.fluo_roi_control.new_roi.color);
				hold off;
			end

	end

% --- Executes whenever a key is struck while fluo_display is selected
%     src: the calling object
%     evnt: the event object; pertinent members:
%           evnt.Character - key struck
function fluo_display_keypress_process (src, evnt)
  global glovars;

	key = double(evnt.Character); % use numerical value -- this makes access to arrows etc. easy

	% process modifiers -- shift, etc.
	shift = 0;
	control = 0;
	alt = 0;

	mod = evnt.Modifier;
	if (strcmp(mod,'shift')) ; shift = 1; end
	if (strcmp(mod,'control')) ; control = 1; end
	if (strcmp(mod,'alt')) ; alt = 1; end

  % filter out non-keyboard buttons -- shift etc. not allowed now
	if (length(key) == 0) ; return ; end

	% This is really just one giant switch statement, BUT Matlab "switch" implementation
	%  is retarted because it does not allow case sharing, so I have to use if
	%  instead to accomodate instances where two keys (e.g., A and a) mean the same thing.
	if (key == 110) % n; new roi
	  fluo_roi_control_interface('new_roi',[]);
	elseif (key == 98) % b: border
	  if (glovars.fluo_roi_control.show_roi_edges)
			glovars.fluo_roi_control.show_roi_edges = 0;
			set(glovars.fluo_roi_control.edge_roi_checkbox,'Value', 0);
		else
			glovars.fluo_roi_control.show_roi_edges = 1;
			set(glovars.fluo_roi_control.edge_roi_checkbox,'Value', 1);
		end
		fluo_display_update_display();
	elseif (key == 102) % f: fil rois
	  if (glovars.fluo_roi_control.show_filled_rois)
			glovars.fluo_roi_control.show_filled_rois = 0;
			set(glovars.fluo_roi_control.fill_rois_checkbox,'Value', 0);
		else
			% need to upd8?
			if (get(glovars.fluo_roi_control.roi_fill_method_list,'Value') ~= glovars.fluo_roi_control.last_fill_method )
				fluo_roi_control_interface('assign_filled_roi_colors', []);
				glovars.fluo_roi_control.last_fill_method =  get(glovars.fluo_roi_control.roi_fill_method_list,'Value');
			end
			glovars.fluo_roi_control.show_filled_rois = 1;
			set(glovars.fluo_roi_control.fill_rois_checkbox,'Value', 1);
		end
		fluo_display_update_display();
	elseif (key == 35) % #: toggle #s
    fluo_roi_control_interface('toggle_number_display',[]);
	elseif (key == 83) % S - save ROIs
	  fluo_roi_control_interface('save_rois',[]);
	elseif (key == 76) % L - load ROIs
	  fluo_roi_control_interface('load_rois',[]);
	elseif (key == 100) % d: done with roi
	  fluo_roi_control_interface('done_roi',[]);
  elseif (key == 115) % s: select roi
	  fluo_roi_control_interface('select_roi',[]);
  elseif (key == 111) % o : select complement
	  fluo_roi_control_interface('select_complement',[]);
  elseif (key == 97) % a : select all
	  fluo_roi_control_interface('select_all',[]);
  elseif (key == 109) % m: select multiple
	  fluo_roi_control_interface('select_multiple',[]);
  elseif (key == 112) % p : select multiple via a polygon
	  fluo_roi_control_interface('select_multiple_poly',[]);
  elseif (key == 60) % < : prev
	  fluo_roi_control_interface('prev_roi',[]);
  elseif (key == 62) % > : next
	  fluo_roi_control_interface('next_roi',[]);
	elseif (key == 127 | key == 8) % delete
	  fluo_roi_control_interface('delete_roi',[]);
  elseif (key == 106) % j : join rois
	  fluo_roi_control_interface('join_roi',[]);
  elseif (key == 114) % r : Restrict by
	  fluo_roi_control_interface('restrict_by',[]);
  elseif (key == 119) % w: Redraw ROI
    fluo_roi_control_interface('redraw_roi', []);
  elseif (key == 30) % up arrow
	  moveby = 1;
		if (shift) ; moveby = 10; end
	  fluo_roi_control_interface('move_up',moveby);
  elseif (key == 31) % down arrow
	  moveby = 1;
		if (shift) ; moveby = 10; end
	  fluo_roi_control_interface('move_down',moveby);
  elseif (key == 29) % right arrow
	  moveby = 1;
		if (shift) ; moveby = 10; end
	  fluo_roi_control_interface('move_right',moveby);
  elseif (key == 28) % left arrow
	  moveby = 1;
		if (shift) ; moveby = 10; end
	  fluo_roi_control_interface('move_left',moveby);
	elseif (key == 63) % ?
	  fluo_roi_control_interface('help',[]);
	elseif (key == 68) % D - Dilate border by one
	  fluo_roi_control_interface('dilate_border_by_one',[]);
	elseif (key == 69) % E - Erode border by one
	  fluo_roi_control_interface('erode_border_by_one',[]);
	elseif (key == 70) % F - fill holes in roi
	  fluo_roi_control_interface('fill_holes',[]);
	elseif (key == 84) % T - make border tight fit of pixels
	  fluo_roi_control_interface('tight_border',[]);
	elseif (key == 91) % [ take away 1 next points in luminance
	  params(1).value = -1;
		fluo_roi_control_interface('change_n_indices_on_lum',params);
	elseif (key == 93) % ] add 1 next points in luminance
	  params(1).value = 1;
		fluo_roi_control_interface('change_n_indices_on_lum',params);
	elseif (key == 123) % { take away 10 next points in luminance
	  params(1).value = -10;
		fluo_roi_control_interface('change_n_indices_on_lum',params);
	elseif (key == 125) % } add 10 next points in luminance
	  params(1).value = 10;
		fluo_roi_control_interface('change_n_indices_on_lum',params);
	elseif (key == 120) % x: remove all but largest component
    fluo_roi_control_interface('remove_all_but_largest_connected_component',[]);
	elseif (key == 108) % l: split into connected components
    fluo_roi_control_interface('split_into_connected_components',[]);
	elseif (key == 104) % h: hist of intensity in square
	  fluo_roi_control_interface('plot_intensity_hist', []);
	else
	  disp(['Unrecognized key stroke: ' num2str(key)]);
	end
	
 

