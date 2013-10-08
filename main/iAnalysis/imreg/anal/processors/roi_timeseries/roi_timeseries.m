% 
% S Peron Sept. 2009
%
% This processor generates roi_timeseries given 1) an ROI selection and 2)
%   a series of / single image.  It does not return any images, but instead
%   writes to a *single* file in which ROI timeseries data is stored by trial:
%     roi_trial(x).sourcefile : source filename
%                 .raw_fluo : raw fluorescence timeseries
%                 .time : time
%                 .dff : stored only because it saved computation
%                 .ms_per_frame 
%                 .hz_frame_rate
%
%     roi_trial(x).timeseries(y).values      : raw fluorescence
%                               .sourcefile  : {1}:name of source file {2}: roi file
%                               .time        : time points
%                               .time_unit_id: time units ; 1 (ms) 
%                               .samp_rate   : in Hz
%                               .dt          : dt between time points
%                               .type_id     : 1 ; ROI fluo
%                               .unique_id   : ROI #
%                               .id_str      : "ROI_" x "_an_" an_id
%
function retparams = roi_timeseries(func, params)
  % --- DO NOT EDIT THIS FUNCTION AT ALL -- it should not talk to glovars, etc.
  retparams = eval([func '(params);']);

% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize roi_timeseries processor -- called by fluo_display_control when added to
%  processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('roi_timeseries processor init start ...');
	% --- start the gui
  [winhan handles_struct] = roi_timeseries_control();

	% --- setup some glovars
	glovars.processor_step(params(1).value).gui_handle = handles_struct;
	
	disp('roi_timeseries processor init end ...');

%
% Closes the roi_timeseries processor -- basically destructor.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = shutdown(params)
  retparams = [];


%
% The core of the processor -- calls processing functions
%
%  params:
%    1: path of image file to process 
%    2: roi timeseries file - where output ends up
%    3: roi file path - contains ROI definition
%    4: image frame rate in hz
%    5: progress [cur_idx total]
%
%  retparams: either -1 if fail, or 1 upon success (no image output)
%
%  glovars used:
%    uses *internal* glovars only -- 
%
function retparams = process(params)

  global glovars;

  retparams = [];
	overwrite = 1; % SET FROM GUI LATER

  % -1) progress message
	if (params(5).value(2) > 1)
	  disp(['roi_timeseries::Step ' num2str(params(5).value(1)) ' of ' num2str(params(5).value(2))]);
	end

  % 0) are required values assigned: frame rate, output *ROI* file
	out_file_path = params(2).value;
	if (length(out_file_path) == 0) ; out_file_path = '' ; end
  if (strcmp(out_file_path,''))
	  disp('Must specify output file for timseries data in roi_timeseries_control GUI.');
    return;
	end
	out_frame_rate_hz = params(4).value;
	out_ms_per_frame = 1000/out_frame_rate_hz;

	% 1) load the image file OR grab from glovars 
	if (params(1).value == -1)
	  disp('ROI timseries processor works only with files - aborting.');
		return;
	else
	  fstr = params(1).value;
		if (exist(fstr, 'file') == 0)
		  disp(['Image file ' fstr ' not found; aborting roi_timeseries execution.']);
			return;
		end
    [im_stack improps] = load_image(fstr, -1, []);
	end

	% 2) load the ROI file
  roi_file = params(3).value;
	rA = load(roi_file); rA = rA.obj;

	% 3) loop over frames, rois ; populate fluo vectors
	for f=1:size(im_stack,3)
		frame_im = im_stack(:,:,f);
	  for r=1:length(rA.rois)
      out_trial.roi(r).fluo(f) = mean (frame_im(rA.rois{r}.indices));
		end
	end

	% 4) write to output file -- insert if needbe ; FREAK OUT if rois changed!
	if (params(5).value(2) == 1 & exist(out_file_path, 'file') == 0) % de novo
		for r=1:length(rA.rois)
		  roi_trial(1).timeseries(r).sourcefile{1} = params(1).value;
		  roi_trial(1).timeseries(r).sourcefile{2} = params(3).value;
			roi_trial(1).timeseries(r).values = out_trial.roi(r).fluo;
		  roi_trial(1).timeseries(r).time = 0:out_ms_per_frame:(size(im_stack,3)-1)*out_ms_per_frame;
			roi_trial(1).timeseries(r).time_unit_id = 1; % 1=ms
			roi_trial(1).timeseries(r).samp_rate = out_frame_rate_hz;
			roi_trial(1).timeseries(r).dt = out_ms_per_frame;
			roi_trial(1).timeseries(r).type_id = 1; % ROI fluo
			roi_trial(1).timeseries(r).unique_id = r; % ms
			roi_trial(1).timeseries(r).id_str = ['ROI_' num2str(rA.rois{r}.id)]; % ms
    end
	else % insert
	  % 1) load -- if not in multi-mode and already loaded ...
		if (params(5).value(2) > 1)
		  if (params(5).value(1) == 1) % FIRST -- pre-allocate etc.
				if (isfield(glovars, 'roi_timeseries') == 0) % not existent
					glovars.roi_timeseries.roi_trial = [];
				end
				if (length(glovars.roi_timeseries.roi_trial) < 1) % not instantiated?
				  % file exists? load
					if (exist(out_file_path, 'file')) % de novo
						load(out_file_path);
					else
						for r=1:length(rA.rois)
							roi_trial(1).timeseries(r).sourcefile{1} = params(1).value;
							roi_trial(1).timeseries(r).sourcefile{2} = params(3).value;
							roi_trial(1).timeseries(r).values = out_trial.roi(r).fluo;
							roi_trial(1).timeseries(r).time = 0:out_ms_per_frame:(size(im_stack,3)-1)*out_ms_per_frame;
							roi_trial(1).timeseries(r).time_unit_id = 1; % 1=ms
							roi_trial(1).timeseries(r).samp_rate = out_frame_rate_hz;
							roi_trial(1).timeseries(r).dt = out_ms_per_frame;
							roi_trial(1).timeseries(r).type_id = 1; % ROI fluo
							roi_trial(1).timeseries(r).unique_id = r; % ms
							roi_trial(1).timeseries(r).id_str = ['ROI_' num2str(rA.rois{r}.id)]; % ms
						end
					end
				end
			else
			  roi_trial = glovars.roi_timeseries.roi_trial;
			end
		else
			load(out_file_path);
		end

		% 2) verify
%		if (roi_ts.frame_rate_hz ~= out_frame_rate_hz | length(roi_ts.time_vec) ~= size(im_stack,3))
		if (roi_trial(1).timeseries(1).samp_rate ~= out_frame_rate_hz ) %| ...
%		   length(roi_trial(1).timeseries(1).time) ~= size(im_stack,3))
			if (overwrite)
				% in future, overwrite only if checkbox
				roi_trial = [];
				for r=1:length(rA.rois)
				  roi_trial(1).timeseries(r).sourcefile{1} = params(1).value;
					roi_trial(1).timeseries(r).sourcefile{2} = params(3).value;
					roi_trial(1).timeseries(r).values = out_trial.roi(r).fluo;
					roi_trial(1).timeseries(r).time = 0:out_ms_per_frame:(size(im_stack,3)-1)*out_ms_per_frame;
					roi_trial(1).timeseries(r).time_unit_id = 1; % 1=ms
					roi_trial(1).timeseries(r).samp_rate = out_frame_rate_hz;
					roi_trial(1).timeseries(r).dt = out_ms_per_frame;
					roi_trial(1).timeseries(r).type_id = 1; % ROI fluo
					roi_trial(1).timeseries(r).unique_id = r; % ms
					roi_trial(1).timeseries(r).id_str = ['ROI_' num2str(rA.rois{r}.id)]; % ms
				end
			else 
				disp ('Mismatch between timeseries output file frame rate and your frame rate; aborting');
				%return;
			end
		end

    % 3) find position - skip if exists **EVENTUALLY CHECK OVERWRITE FLAG **
		% construct fname index -- assumption: timeseries right now is ONLY roi data,
		%  so grab first roi filename
		fi = [];
		for t=1:length(roi_trial)
		  fi{t} = roi_trial(t).timeseries(1).sourcefile{1};
		end
%    fi = roi_ts.fname_index;

		my_idx = find(ismember(fi, params(1).value));
		if (length(my_idx) > 0 & overwrite ~= 1)
		  disp(['Already found entry in ' out_file_path ' for ' params(1).value '; skipping']);
			return;
		elseif (length(my_idx) > 0 & overwrite == 1)
		  disp(['Replacing entry in ' out_file_path ' for ' params(1).value '.']);
%			roi_ts.trial(my_idx) = out_trial;
			for r=1:length(rA.rois)
				roi_trial(my_idx).timeseries(r).values = out_trial.roi(r).fluo;
			end
		else % build new entry in existing structure
			t = length(roi_trial)+1;
			for r=1:length(rA.rois)
				roi_trial(t).timeseries(r).sourcefile{1} = params(1).value;
				roi_trial(t).timeseries(r).sourcefile{2} = params(3).value;
				roi_trial(t).timeseries(r).values = out_trial.roi(r).fluo;
				roi_trial(t).timeseries(r).time = 0:out_ms_per_frame:(size(im_stack,3)-1)*out_ms_per_frame;
				roi_trial(t).timeseries(r).time_unit_id = 1; % 1=ms
				roi_trial(t).timeseries(r).samp_rate = out_frame_rate_hz;
				roi_trial(t).timeseries(r).dt = out_ms_per_frame;
				roi_trial(t).timeseries(r).type_id = 1; % ROI fluo
				roi_trial(t).timeseries(r).unique_id = r; % ms
				roi_trial(t).timeseries(r).id_str = ['ROI_' num2str(rA.rois{r}.id)]; % ms
			end
		end
	end
	% the write :
	disp('Warning: roi_timeseries does not support parallel execution.  Fix this by checkpointing at the point of output (where this warning is in the code).');
%	save(out_file_path, 'roi_ts');
  % multi-step
	if (params(5).value(2) > 1)
	  % are we done?
	  if (params(5).value(1) == params(5).value(2)) % yes ; save to file
			save(out_file_path, 'roi_trial');
			disp('roi_timeseries::multi step save complete.');
			glovars.roi_timeseries.roi_trial = [];
		else % no? save to memory for next pass
			glovars.roi_timeseries.roi_trial = roi_trial;
		end
	% single step
	else
		save(out_file_path, 'roi_trial');
	end

  % OK
	retparams = 1;

%
% Processor wrapper for single instance mode ; should setup params and make a 
%  single process() call.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    2: path of image file to process 
%    3: output file path (if not an outputting processor, will be ignored)
%    4: progress ; progres(1): current call index ; progress(2): total number of calls
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image path if this is an outputting processor
%
%  glovars used:
%
function retparams = process_single(params)
  global glovars;
  retparams = [];

	% 1) get gui-defined parameters ; insert sanity checks here ... or just go crazy
	si = params(1).value;
%	tpmv = get(glovars.processor_step(si).gui_handle.target_process_menu,'Value');
  out_frame_rate_hz_str = get(glovars.processor_step(si).gui_handle.roi_frame_rate_hz_edit,'String');
	if (length(out_frame_rate_hz_str) == 0) ; out_frame_rate_hz_str = '' ; end
  if (strcmp(out_frame_rate_hz_str,''))
	  disp('Must specify frame rate and/or ms/frame in roi_timeseries_control GUI.');
    return;
	end
	out_frame_rate_hz = str2num(out_frame_rate_hz_str);

  roi_file_path = get(glovars.processor_step(si).gui_handle.roi_file_edit,'String');

  timeseries_file_path = get(glovars.processor_step(si).gui_handle.roi_timeseries_file_edit,'String');

  % 2) construct params for process()
	%    1: path of image file to process 
	%    2: roi timeseries file - where output ends up
	%    3: roi file path - contains ROI definition
	%    4: image frame rate in hz
	%    5: progress [cur_idx total]
  pr_params(1).value = params(2).value; % path of image file to process
  pr_params(2).value = timeseries_file_path;
	pr_params(3).value = roi_file_path;
  pr_params(4).value = out_frame_rate_hz;
  pr_params(5).value = params(4).value;

	% 3) call process()
  retparams = process(pr_params);


	

%
% Processor wrapper for batch mode ; should generate .mat files containing params
%  for process that a parallel agent can then call. Handle any glovars/gui communication 
%  and setup a glovars/gui independent params structure for process() itself.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    2: path(s) of source images -- cell array
%    3: output path 
%    4: progress ; progres(1): current call index ; progress(2): total number of calls
%    5: .mat file path -- filename for mat file that parallel processor will use
%    6: .mat dependency file(s) -- filename(s) that must be executed before this one
%                                  can include standard 'ls' wildcards
%
%  retparams: 
%    1: cell ARRAY with path(s) of .mat file(s) generated
%
function retparams = process_batch (params)
  global glovars;
  retparams = [];

	% Pre-setup the target image and its preprocessing - dont want to repeat each time

%
% Return values for saving in case gui is saved
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = get_saveable_settings(params)
  global glovars;
  retparams = [];

%
% Pass saved values for assigning to gui in case gui was saved
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = set_saveable_settings(params)
  global glovars;
  retparams = [];

% =============================================================================
% --- Processor-specific functions
% =============================================================================


