function varargout = fluo_roi_control(varargin)
% FLUO_ROI_CONTROL M-file for fluo_roi_control.fig
%      FLUO_ROI_CONTROL, by itself, creates a new FLUO_ROI_CONTROL or raises the existing
%      singleton*.
%
%      H = FLUO_ROI_CONTROL returns the handle to a new FLUO_ROI_CONTROL or the handle to
%      the existing singleton*.
%
%      FLUO_ROI_CONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLUO_ROI_CONTROL.M with the given input arguments.
%
%      FLUO_ROI_CONTROL('Property','Value',...) creates a new FLUO_ROI_CONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fluo_roi_control_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fluo_roi_control_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fluo_roi_control

% Last Modified by GUIDE v2.5 17-Apr-2010 16:23:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fluo_roi_control_OpeningFcn, ...
                   'gui_OutputFcn',  @fluo_roi_control_OutputFcn, ...
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


% --- Executes just before fluo_roi_control is made visible.
function fluo_roi_control_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fluo_roi_control (see VARARGIN)

% SP ----------------------------------------------------------------------
global glovars; 

% 0) Assign gloval variables that need to be 'zeroed'

% ROIs and their properties
glovars.fluo_roi_control.new_roi.n_corners = 0;
glovars.fluo_roi_control.new_roi.corners = [];
glovars.fluo_roi_control.new_roi.indices = [];
glovars.fluo_roi_control.new_roi.raw_fluo = [];
glovars.fluo_roi_control.new_roi.color = [1 1 0];
glovars.fluo_roi_control.roi = [];
glovars.fluo_roi_control.n_rois = 0;

% bounding polygon for ROIs, selection, and other plotting
glovars.fluo_roi_control.bounding_poly.corners = [];
glovars.fluo_roi_control.bounding_poly.color = [1 0 1];

% matrix & points for computed affine match
glovars.fluo_roi_control.aff_mat = [];
glovars.fluo_roi_control.match_roi_corners = [];
glovars.fluo_roi_control.match_image_corners = [];

% GUI elements
glovars.fluo_roi_control.current_roi_text = handles.current_roi_text;
glovars.fluo_roi_control.roi_detect_method_list = handles.roi_detect_method_list;
glovars.fluo_roi_control.file_format_list = handles.file_format_list;
glovars.fluo_roi_control.translate_x_edit = handles.translate_x_edit;
glovars.fluo_roi_control.translate_y_edit = handles.translate_y_edit;
glovars.fluo_roi_control.rotate_angle_edit = handles.rotate_angle_edit;
glovars.fluo_roi_control.show_numbers_checkbox = handles.show_numbers_checkbox;
glovars.fluo_roi_control.fill_rois_checkbox = handles.fill_rois_checkbox;
glovars.fluo_roi_control.edge_roi_checkbox = handles.edge_roi_checkbox;
glovars.fluo_roi_control.roi_fill_method_list = handles.roi_fill_method_list;

glovars.fluo_roi_control.roi_group_list = handles.roi_group_list;
glovars.fluo_roi_control.roi_group_id_edit = handles.roi_group_id_edit;
glovars.fluo_roi_control.roi_group_name_edit = handles.roi_group_name_edit;
glovars.fluo_roi_control.roi_group_color_edit = handles.roi_group_color_edit;
glovars.fluo_roi_control.roi_group_set_membership_edit = handles.roi_group_set_membership_edit;

glovars.fluo_roi_control.roi_group_set_list = handles.roi_group_set_list;
glovars.fluo_roi_control.roi_group_set_id_edit = handles.roi_group_set_id_edit;
glovars.fluo_roi_control.roi_group_set_name_edit = handles.roi_group_set_name_edit;

% GUI variables
glovars.fluo_roi_control.show_roi_numbers = 0;
glovars.fluo_roi_control.show_roi_edges = 0;
glovars.fluo_roi_control.show_filled_rois = 1;
glovars.fluo_roi_control.roi_selected = -1; % -1= none ; 0 = all
glovars.fluo_roi_control.last_fill_method = 1;

% etc
% glovars.fluo_roi_control.roi_colors = ['r', 'g', 'b', 'm', 'c'];
glovars.fluo_roi_control.roi_colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 0 1 1];
% END SP ------------------------------------------------------------------


% Choose default command line output for fluo_roi_control
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fluo_roi_control wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Set default gui parameters
set(glovars.fluo_roi_control.current_roi_text,'String', 'None');
set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
set(handles.show_numbers_checkbox,'Value', 0);
set(handles.fill_rois_checkbox,'Value', 1);
set(handles.edge_roi_checkbox,'Value', 0);
set(handles.file_format_list, 'String', {'Format: fluo_display format', 'Format: ephus ROI format'});
set(handles.file_format_list, 'Value', 1);
set(handles.roi_fill_method_list, 'String', {'Select an ROI fill method', 'Random colors' ,'One color', 'Max dF/F', 'Time of peak'});
set(handles.roi_fill_method_list, 'Value', 1);

% ROI groups - initialize
glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start = 6; % including this and afterwards, these guys on roi_fill_method_list are group sets
glovars.fluo_roi_control.roi_group_file_path = [glovars.confpath filesep 'roi_groups.mat'];
fluo_roi_control_interface('load_roi_group_file', []);
fluo_roi_control_interface('update_roi_group_gui', []);

% initialize autodetector
% roi_detect('init', [], []);
%set(handles.roi_detect_method_list, 'String', {'Border Polygon','Med.+SD thresh', 'Med. thresh', 'Med.-SD thresh', 'Temp. Corr.'});
%set(handles.roi_detect_method_list, 'Value', 1);
%set(handles.roi_detect_method_list, 'String', {'Intns. Mrph. 1', 'Ellipse Kernel'});
%set(handles.roi_detect_method_list, 'String', {'ROI polygon', 'Basic threshold', 'Lum. normalized threshold', 'Ellipse kernel', 'Neighbor temp. corr', 'PCA,ICA (Schnitzer)'});
%set(handles.roi_detect_method_list, 'Value', 1);

% --- Outputs from this function are returned to the command line.
function varargout = fluo_roi_control_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in new_roi_button.
function new_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('new_roi', []);

% --- Executes on button press in select_roi_button.
function select_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('select_roi',[]);



% --- Executes on button press in previous_roi_button.
function previous_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('prev_roi', []);

% --- Executes on button press in next_roi_button.
function next_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('next_roi', []);



% --- Executes on button press in delete_roi_button.
function delete_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('delete_roi', []);

% --- Executes on button press in save_rois_button.
function save_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('save_rois', []);
  
% --- Executes on button press in load_rois_button.
function load_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('load_rois',[]);

% --- Executes on button press in restrictby_rois_button.
function restrictby_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to restrictby_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('restrict_by',[]);

% --- Executes on selection change in roi_detect_method_list.
function roi_detect_method_list_Callback(hObject, eventdata, handles)
% hObject    handle to roi_detect_method_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_detect_method_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_detect_method_list
  global glovars;
 
  % get selection idx
	roi_detector_idx = get(glovars.fluo_roi_control.roi_detect_method_list,'Value');

	% make call
  roi_detect('start_gui', roi_detector_idx, '');

% --- Executes during object creation, after setting all properties.
function roi_detect_method_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_detect_method_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

	
% --- Executes on button press in seedby_rois_button.
function seedby_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to seedby_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
 
  % gui gear
	roi_detector_idx = get(glovars.fluo_roi_control.roi_detect_method_list,'Value');

	% make call
  roi_detect('seed', roi_detector_idx, '');



% --- Executes on button press in done_roi_button.
function done_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('done_roi',[]);



% --- Executes on button press in redraw_roi_button.
function redraw_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to redraw_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('redraw_roi',[]);

function base_frame_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_frame_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_frame_start_edit as text
%        str2double(get(hObject,'String')) returns contents of base_frame_start_edit as a double


% --- Executes during object creation, after setting all properties.
function base_frame_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_frame_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function base_frame_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to base_frame_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of base_frame_end_edit as text
%        str2double(get(hObject,'String')) returns contents of base_frame_end_edit as a double


% --- Executes during object creation, after setting all properties.
function base_frame_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to base_frame_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_dff_button.
function plot_dff_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_dff_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	% THESE SHOULD BE SEPARATE BUTTONS/FuNCTIONS!!
	show_hist = 0;

  % SELECT f0 either via gui or MEDIAN or . . . .mode??
	% plot via session plotter??

%% 
base_frames = [1 5];
disp('fluo_roi_control::base frames assumed to be 1-5, inclusive, for f_o');

  % 0) update rois ; determine which one(s) is/are selected
  fluo_roi_control_update_rois();
  croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % 1) compute
	dff = zeros(length(R), glovars.fluo_display.display_im_nframes);
	max_dff = zeros(length(R), 1);
  for r=1:length(R)
    roi = glovars.fluo_roi_control.roi(R(r));
		f0 = mean(roi.raw_fluo(base_frames(1):base_frames(2)));
    f0 = min(f0,median(roi.raw_fluo));
		dff(r,:) = (roi.raw_fluo-f0)/f0;
		max_dff(r) = max(dff(r,:));
	end

	% 2) plot -- separate loops bc we want to know things about *all* plots
	figure;
	if (length(R) <= 10) % plot as lines
		offset = 1.2*max(max(dff));
		t = 1:glovars.fluo_display.display_im_nframes;
		hold on;
		for r=1:length(R)
			plot(t, (r-1)*offset + dff(r,:), 'Color', glovars.fluo_roi_control.roi(R(r)).color);
		 
			% line @ "0"
			plot([min(t) max(t)], [(r-1)*offset (r-1)*offset], 'k:');

			% label #
			text(min(t) + 0.1*(max(t)-min(t)), (r-0.75)*offset , num2str(R(r)), 'Color', 'k');

			% noise stats
			vec = dff(r,:);
			valvec = find (vec < 3*median(vec)); 
			disp(['ROI ' num2str(R(r)) ' SD for points below 3x median: ' num2str(std(vec(valvec))) ' max: ' num2str(max(dff(r,:)))]);
		end
  else % plot as a color-coded image
		M = max(max(dff));
		t = 0:glovars.fluo_display.display_im_nframes-1;
		dt = 1;
%M = 2; % 500 % is max
		image(100*dff, 'XData', (dt/2)+[min(t) (max(t))-dt-dt/4]);
	%	title(['max : ' num2str(max_dff)]);
		set(gca, 'TickDir', 'out');
		colormap( jet(100));
		xlabel('Frame');
		ylabel('ROI index');

		% colorbar - label it appropriately, 11 times
		cb = colorbar;
		set (cb,'YTick', [1 10:10:100]);
		rdff = max(max(dff)) - min(min(dff));
		for c=1:11
		  cb_label{c} = sprintf('%2.1f', 100*(min(min(dff)) + ((c-1)/10)*rdff));
		end
		set (cb, 'YTickLabel', cb_label);
	end

  % --- histo maxdff
	if (show_hist)
		figure;
		hist(max_dff, 20);
	end


% --- Executes on button press in plot_raw_fluo_button.
function plot_raw_fluo_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_raw_fluo_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	% 0) refresh in case of img change etc.
  fluo_roi_control_update_rois();
  croi = glovars.fluo_roi_control.roi_selected;
	if (croi == 0) ; R = 1:glovars.fluo_roi_control.n_rois; else ; R = croi; end

  % 1) compute
	fl = zeros(glovars.fluo_roi_control.n_rois, glovars.fluo_display.display_im_nframes);
  for r=1:length(R)
    roi = glovars.fluo_roi_control.roi(R(r));
		fl(r,:) = roi.raw_fluo;
	end

	% 2) plot -- separate loops bc we want to know things about *all* plots
	figure;
	offset = 1.2*max(max(fl));
	t = 1:glovars.fluo_display.display_im_nframes;
	hold on;
	for r=1:length(R)
	  plot(t, (r-1)*offset + fl(r,:), 'Color', glovars.fluo_roi_control.roi(R(r)).color);
   
	  % line @ "0"
    plot([min(t) max(t)], [(r-1)*offset (r-1)*offset], 'k:');

		% label #
    text(min(t) + 0.1*(max(t)-min(t)), (r-0.75)*offset , num2str(R(r)), 'Color', 'k');

    % noise stats
		vec = fl(r,:);
		valvec = find (vec < 3*median(vec));
		disp(['ROI ' num2str(R(r)) ' SD for points below 3x median: ' num2str(std(vec(valvec)))]);
	end



% --- Executes on button press in fill_rois_checkbox.
function fill_rois_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to fill_rois_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fill_rois_checkbox
  global glovars;
	if (glovars.fluo_roi_control.show_filled_rois == 0)
		% need to upd8?
		if (get(glovars.fluo_roi_control.roi_fill_method_list,'Value') ~= glovars.fluo_roi_control.last_fill_method )
			fluo_roi_control_interface('assign_filled_roi_colors', []);
			glovars.fluo_roi_control.last_fill_method =  get(glovars.fluo_roi_control.roi_fill_method_list,'Value');
		end
		set(glovars.fluo_roi_control.fill_rois_checkbox,'Value', 1);
	  glovars.fluo_roi_control.show_filled_rois = 1;
		set (hObject,'Value', 1);
	else
	  glovars.fluo_roi_control.show_filled_rois = 0;
		set (hObject,'Value', 0);
	end
  
	fluo_display_update_display();

% --- Executes on button press in show_numbers_checkbox.
function show_numbers_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_numbers_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_numbers_checkbox
  global glovars;
	if (glovars.fluo_roi_control.show_roi_numbers == 0)
	  glovars.fluo_roi_control.show_roi_numbers = 1;
		set (hObject,'Value', 1);
	else
	  glovars.fluo_roi_control.show_roi_numbers = 0;
		set (hObject,'Value', 0);
	end
	fluo_display_update_display();

% --- Executes on button press in edge_roi_checkbox.
function edge_roi_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to edge_roi_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edge_roi_checkbox
  global glovars;
	if (glovars.fluo_roi_control.show_roi_edges == 0)
	  glovars.fluo_roi_control.show_roi_edges = 1;
		set (hObject,'Value', 1);
	else
	  glovars.fluo_roi_control.show_roi_edges = 0;
		set (hObject,'Value', 0);
	end
	fluo_display_update_display();

% --- Executes on button press in move_rois_left_button.
function move_rois_left_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_left_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('move_left',[]);

% --- Executes on button press in move_rois_right_button.
function move_rois_right_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_right_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('move_right',[]);


% --- Executes on button press in move_rois_down_button.
function move_rois_down_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_down_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('move_down',[]);


% --- Executes on button press in move_rois_up_button.
function move_rois_up_button_Callback(hObject, eventdata, handles)
% hObject    handle to move_rois_up_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('move_up',[]);


% --- Executes on button press in select_all_rois.
function select_all_rois_Callback(hObject, eventdata, handles)
% hObject    handle to select_all_rois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('select_all',[]);


% --- Executes on button press in addby_rois_button.
function addby_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to addby_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_multiple_button.
function select_multiple_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_multiple_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('select_multiple',[]);


% --- Executes on button press in select_multiple_poly_button.
function select_multiple_poly_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_multiple_poly_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('select_multiple_poly',[]);



% --- Executes on button press in join_rois_button.
function join_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to join_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('join_rois',[]);


% --- Executes on button press in select_complement_button.
function select_complement_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_complement_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fluo_roi_control_interface('select_complement',[]);


function translate_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to translate_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of translate_x_edit as text
%        str2double(get(hObject,'String')) returns contents of translate_x_edit as a double


% --- Executes during object creation, after setting all properties.
function translate_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translate_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function translate_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to translate_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of translate_y_edit as text
%        str2double(get(hObject,'String')) returns contents of translate_y_edit as a double


% --- Executes during object creation, after setting all properties.
function translate_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to translate_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shear_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to shear_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shear_x_edit as text
%        str2double(get(hObject,'String')) returns contents of shear_x_edit as a double


% --- Executes during object creation, after setting all properties.
function shear_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shear_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function shear_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to shear_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shear_y_edit as text
%        str2double(get(hObject,'String')) returns contents of shear_y_edit as a double


% --- Executes during object creation, after setting all properties.
function shear_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shear_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scale_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to scale_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_x_edit as text
%        str2double(get(hObject,'String')) returns contents of scale_x_edit as a double


% --- Executes during object creation, after setting all properties.
function scale_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scale_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to scale_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale_y_edit as text
%        str2double(get(hObject,'String')) returns contents of scale_y_edit as a double


% --- Executes during object creation, after setting all properties.
function scale_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotate_angle_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_angle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotate_angle_edit as text
%        str2double(get(hObject,'String')) returns contents of rotate_angle_edit as a double


% --- Executes during object creation, after setting all properties.
function rotate_angle_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate_angle_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply_transform_button.
function apply_transform_button_Callback(hObject, eventdata, handles)
% hObject    handle to apply_transform_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % affine matrix assinged?
	aff_mat = glovars.fluo_roi_control.aff_mat;
  if (length(aff_mat) == 0) 
	  trans_x = 0;
		trans_y = 0;
		rot_ang = 0;

	  % get from gui
		if (length(get(glovars.fluo_roi_control.translate_x_edit,'String')) > 0)
			trans_x = str2num(get(glovars.fluo_roi_control.translate_x_edit,'String'));
		end
		if (length(get(glovars.fluo_roi_control.translate_y_edit,'String')) > 0)
			trans_y = str2num(get(glovars.fluo_roi_control.translate_y_edit,'String'));
		end
		if (length(get(glovars.fluo_roi_control.rotate_angle_edit,'String')) > 0)
		  rot_ang = str2num(get(glovars.fluo_roi_control.rotate_angle_edit,'String'));
		end

		% none?
		if (trans_x == 0 & trans_y == 0 & rot_ang == 0)
			disp('An affine matrix must be computed or its parameters specified in the GUI.');
			return;
		% build matrix!
		else
		  aff_mat = [cosd(rot_ang) sind(rot_ang) trans_x ; -1*sind(rot_ang) cosd(rot_ang) trans_y ; 0 0 1];
		end
	end


	% determine indices you will be working with
	R = glovars.fluo_roi_control.roi_selected;
	if (R == -1) ; disp ('No ROIs selected ; aborting.') ; return ; end
	if (R == 0) ; R = 1:length(glovars.fluo_roi_control.roi); end

	% grab image size for X/Y -> index conversions
	S = size(glovars.fluo_display.display_im);
	% apply it to selected ROIs
	for r=1:length(R)
		roi = glovars.fluo_roi_control.roi(R(r));

		% --- indices
		indices = roi.indices;
		np = length(indices);

		% convert idx to XY
		Y = indices-S(1)*floor(indices/S(1));
		X = ceil(indices/S(1));

		% 'densify'  -- make this better LATER
		disp('WARNING - densification DISABLED - you may see some hollowness');
%		Xd = [X'-.4 X'-.2 X' X'+.2 X'+.4]';
%		Yd = [Y'-.4 Y'-.2 Y' Y'+.2 Y'+.4]';
		Xd = X;
		Yd = Y;

		% apply affine transform thereto
		for n=1:length(Xd) % SLOW
			res = aff_mat*[Xd(n) Yd(n) 1]';
			Xd(n)  = round(res(1));
			Yd(n) = round(res(2));
		end

		U = unique([Xd' ; Yd']', 'rows' );
		X = U(:,1);
		Y = U(:,2);
	
	
		% remove out-of-bounds
		keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal

		% and convert to index
		indices = Y + S(1)*(X-1);

		% and plug back in
		glovars.fluo_roi_control.roi(R(r)).indices = indices(keep_idx);

		% --- corners of bounding polygon
		corners = glovars.fluo_roi_control.roi(R(r)).corners;

		X = corners(1,:);
		Y = corners(2,:);

		% apply affine transform 
		for n=1:length(X) % SLOW
			res = aff_mat*[X(n) Y(n) 1]';
			X(n)  = round(res(1));
			Y(n) = round(res(2));
		end

		% remove out-of-bounds
%		keep_idx = find(Y > 0 & Y < S(1) & X > 0 & X < S(2)); % universal
    ncorners = [];
    keep_idx = 1:length(X);
		ncorners(1,:) = X(keep_idx);
		ncorners(2,:) = Y(keep_idx);
	  glovars.fluo_roi_control.roi(R(r)).corners = ncorners;
	end

	% update gui
	fluo_roi_control_update_rois([1 1]);
	fluo_display_update_display();
 
  % delete the matrix
	glovars.fluo_roi_control.aff_mat = [];


% --- Executes on button press in compute_transform_from_points_button.
function compute_transform_from_points_button_Callback(hObject, eventdata, handles)
% hObject    handle to compute_transform_from_points_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  disp('Click on 3 pairs of points, first click in ROI space, second in image space - for six total clicks');

	% setup variables
  glovars.fluo_display_axes.mouse_mode = 5;
	glovars.fluo_roi_control.match_roi_corners = [];
	glovars.fluo_roi_control.match_image_corners = [];


% --- Executes on button press in compute_transform_from_images_button.
function compute_transform_from_images_button_Callback(hObject, eventdata, handles)
% hObject    handle to compute_transform_from_images_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in file_format_list.
function file_format_list_Callback(hObject, eventdata, handles)
% hObject    handle to file_format_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns file_format_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_format_list


% --- Executes during object creation, after setting all properties.
function file_format_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_format_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  fluo_roi_control_interface('help', []);

% --- Executes on button press in merge_rois_button.
function merge_rois_button_Callback(hObject, eventdata, handles)
% hObject    handle to merge_rois_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

  % dialog, exist test
	[filename, filepath]=uigetfile({'*.mat'}, ...
	  'Select ROI file', glovars.processor_step(1).im_path);

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
 
    % loop thru -- anything new? then append
		if (n_rois > glovars.fluo_roi_control.n_rois)
			for r=glovars.fluo_roi_control.n_rois+1:n_rois
				glovars.fluo_roi_control.roi(r) = roi(r);
			end
			glovars.fluo_roi_control.n_rois = n_rois;
		else
		  disp('merge_rois_button_Callback::no additional ROIs in the file you selected. Nothing changes...');
		end


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

		% gui tweak
    glovars.fluo_roi_control.roi_selected = 0; % default is select all for fast plotting
		set(glovars.fluo_roi_control.current_roi_text,'String', 'All');
		set(glovars.fluo_roi_control.current_roi_text,'BackgroundColor', [1 1 1]);
 

		% update screen
		fluo_display_update_display();
  else
		disp(['Invalid ROI file: ' filepath filesep filename]);
	end

% --- Executes on selection change in roi_fill_method_list.
function roi_fill_method_list_Callback(hObject, eventdata, handles)
% hObject    handle to roi_fill_method_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_fill_method_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_fill_method_list
  global glovars;
	
	% need to upd8?
	if (get(glovars.fluo_roi_control.roi_fill_method_list,'Value') ~= glovars.fluo_roi_control.last_fill_method )
		fluo_roi_control_interface('assign_filled_roi_colors', []);
	  glovars.fluo_roi_control.last_fill_method =  get(glovars.fluo_roi_control.roi_fill_method_list,'Value');
	end

	% are we doing anything even -- 1 implies no fill
	if (get(glovars.fluo_roi_control.roi_fill_method_list,'Value') ~= 1)
		set(glovars.fluo_roi_control.fill_rois_checkbox,'Value', 1);
	  glovars.fluo_roi_control.show_filled_rois = 1;
	else
		set(glovars.fluo_roi_control.fill_rois_checkbox,'Value', 0);
	  glovars.fluo_roi_control.show_filled_rois = 0;
  end
  
	% --- display updation
	fluo_display_update_display();


% --- Executes during object creation, after setting all properties.
function roi_fill_method_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_fill_method_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in roi_group_list.
function roi_group_list_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_group_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_group_list
	fluo_roi_control_interface('update_roi_group_gui', []);


% --- Executes during object creation, after setting all properties.
function roi_group_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_selected_to_group_button.
function add_selected_to_group_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_selected_to_group_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_groups_file_button.
function save_groups_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_groups_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	% go to appropriate directory
	cwd = pwd();

	% dialog
	if (exist(glovars.confpath, 'dir') == 7) 
		cd (glovars.confpath);
	end
	[filename, pathname, filt] = ... 
	  uiputfile({'*.mat'}, 'Save ROI group data to file', 'roi_groups.mat');
	savepath = [pathname filesep filename];
  frci_params(1).value = savepath;

	% run it
  fluo_roi_control_interface('save_roi_groups', frci_params);

  % cleanup
	cd(cwd);


% --- Executes on button press in load_groups_file_button.
function load_groups_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_groups_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;
  
  % gui-based ask user
	[filename, filepath]=uigetfile({'*.mat', 'MAT file (*.mat)'; ...
                     '*.*','All Files (*.*)'},'Select MAT file', glovars.confpath);

	% and run
	frci_params(1).value = [filepath filesep filename];
  fluo_roi_control_interface('load_roi_group_file', frci_params);
	fluo_roi_control_interface('update_roi_group_gui', []);


% --- Executes on button press in roi_group_add_button.
function roi_group_add_button_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	% add a blank and set it as selected ...
	gl = get(glovars.fluo_roi_control.roi_group_list, 'String');
	ng = length(glovars.fluo_roi_control.roi_group);

	% defaults ..
	n_group.id = -1;
	n_group.descr_str = 'New Group';
	n_group.color = [1 0 0];
	n_group.set = [];

	% add
	glovars.fluo_roi_control.roi_group(ng+1) = n_group;
	gl{ng+1} = n_group.descr_str;
	set(glovars.fluo_roi_control.roi_group_list, 'String', gl);
	set(glovars.fluo_roi_control.roi_group_list, 'Value', ng+1);


	% update display ...
	fluo_roi_control_interface('update_roi_group_gui', []);



function roi_group_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_group_id_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_group_id_edit as a double
  global glovars;

	% geet group #
	ng = get(glovars.fluo_roi_control.roi_group_list, 'Value');

	% update name
	id = str2num(get(glovars.fluo_roi_control.roi_group_id_edit, 'String'));
	glovars.fluo_roi_control.roi_group(ng).id = id;


% --- Executes during object creation, after setting all properties.
function roi_group_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_group_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_group_name_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_group_name_edit as a double
  global glovars;

	% assign the name parameter
	gl = get(glovars.fluo_roi_control.roi_group_list, 'String');
	ng = get(glovars.fluo_roi_control.roi_group_list, 'Value');

	% update name
	name_str = get(glovars.fluo_roi_control.roi_group_name_edit, 'String');
	gl{ng} = name_str;
	glovars.fluo_roi_control.roi_group(ng).descr_str = name_str;
	set(glovars.fluo_roi_control.roi_group_list, 'String', gl);

	% update display ...
	fluo_roi_control_interface('update_roi_group_gui', []);


% --- Executes during object creation, after setting all properties.
function roi_group_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_group_color_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_color_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_group_color_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_group_color_edit as a double
  global glovars;

	% geet group #
	ng = get(glovars.fluo_roi_control.roi_group_list, 'Value');

	% update name
	color = str2num(get(glovars.fluo_roi_control.roi_group_color_edit, 'String'));
	if (length(color) == 0) ; return ; end
	glovars.fluo_roi_control.roi_group(ng).color = color;


% --- Executes during object creation, after setting all properties.
function roi_group_color_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_color_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_group_set_membership_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_set_membership_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_group_set_membership_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_group_set_membership_edit as a double
  global glovars;

	% geet group #
	ng = get(glovars.fluo_roi_control.roi_group_list, 'Value');

	% update name
	set_memb = str2num(get(glovars.fluo_roi_control.roi_group_set_membership_edit, 'String'));
	glovars.fluo_roi_control.roi_group(ng).set = set_memb;


% --- Executes during object creation, after setting all properties.
function roi_group_set_membership_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_set_membership_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_group_set_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_set_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_group_set_id_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_group_set_id_edit as a double
  global glovars;

	% geet group set #
	ng = get(glovars.fluo_roi_control.roi_group_set_list, 'Value');

	% update name
	id = str2num(get(glovars.fluo_roi_control.roi_group_set_id_edit, 'String'));
	glovars.fluo_roi_control.roi_group_set(ng).id = id;


% --- Executes during object creation, after setting all properties.
function roi_group_set_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_set_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function roi_group_set_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_set_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roi_group_set_name_edit as text
%        str2double(get(hObject,'String')) returns contents of roi_group_set_name_edit as a double
  global glovars;

	% assign the name parameter
	gl = get(glovars.fluo_roi_control.roi_group_set_list, 'String');
	ng = get(glovars.fluo_roi_control.roi_group_set_list, 'Value');

	% update name
	name_str = get(glovars.fluo_roi_control.roi_group_set_name_edit, 'String');
	gl{ng} = name_str;
	glovars.fluo_roi_control.roi_group_set(ng).descr_str = name_str;
	set(glovars.fluo_roi_control.roi_group_set_list, 'String', gl);

	% update fill method list
	mls = get(glovars.fluo_roi_control.roi_fill_method_list, 'String');
	for m=glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+(0:length(gl)-1)
	  mls{m} = gl{m-glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+1};
	end
  set(glovars.fluo_roi_control.roi_fill_method_list, 'String', mls);


	% update display ...
	fluo_roi_control_interface('update_roi_group_gui', []);


% --- Executes during object creation, after setting all properties.
function roi_group_set_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_set_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in roi_group_set_list.
function roi_group_set_list_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_set_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_group_set_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_group_set_list
	fluo_roi_control_interface('update_roi_group_gui', []);


% --- Executes during object creation, after setting all properties.
function roi_group_set_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_group_set_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in roi_group_set_add_button.
function roi_group_set_add_button_Callback(hObject, eventdata, handles)
% hObject    handle to roi_group_set_add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global glovars;

	% add a blank and set it as selected ...
	gsl = get(glovars.fluo_roi_control.roi_group_set_list, 'String');
	ngs = length(glovars.fluo_roi_control.roi_group_set);

	% defaults ..
	n_group_set.id = -1;
	n_group_set.descr_str = 'New Group';

	% add
	glovars.fluo_roi_control.roi_group_set(ngs+1) = n_group_set;
	gsl{ngs+1} = n_group_set.descr_str;
	set(glovars.fluo_roi_control.roi_group_set_list, 'String', gsl);
	set(glovars.fluo_roi_control.roi_group_set_list, 'Value', ngs+1);

	% update fill method list
	mls = get(glovars.fluo_roi_control.roi_fill_method_list, 'String');
	for m=glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+(0:length(gsl)-1)
	  mls{m} = gsl{m-glovars.fluo_roi_control.roi_fill_method_list_roi_sets_start+1};
	end
  set(glovars.fluo_roi_control.roi_fill_method_list, 'String', mls);


	% update display ...
	fluo_roi_control_interface('update_roi_group_gui', []);


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% MY OWN FUNCTIONS -- NOT GUI GENERATED
% --------------------------------------------------------------------
% --------------------------------------------------------------------


%
% Given a matrix size and indices therein, it will find, among indices,
%  the different connected sets return indices of the largest
%  connected (4-wise) set of pixels.
%
% S: 2 element image size vector
% indices: indices within the image that are to be broken up
%
function [new_indices] = get_largest_connected_member(S, indices)
	% now select the largest connected set
  tmp_im = zeros(S);
	tmp_im(indices) = 1;
	tmp_im = bwlabel(tmp_im,4);
	ids = unique(tmp_im);
	for i=1:length(ids)
		n_i(i) = length(find(tmp_im == ids(i)));
	end
	[irr sidx] = sort(n_i, 2, 'descend');
	new_indices = find(tmp_im == ids(sidx(2)));


