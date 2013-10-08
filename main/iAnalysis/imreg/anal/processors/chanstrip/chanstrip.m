% 
% S Peron Jan. 2010
%
% This is a processor CHANSTRIP. 
%
% It will keep a matlab eval-compatible list of channels from the input image.
%
% "func" is the *string* name of the function you wish to call below, with 
%        params always getting passed thereto.
%
% "params" is a structure, with params.value carrying content.  This allows us 
%          type independence obviating need for a huge number of variables. 
% 
% I would love to use MATLAB objects, but this allows us backwards compatability ...
%
function retparams = chanstrip(func, params)
  % --- DO NOT EDIT THIS FUNCTION AT ALL -- it should not talk to glovars, etc.
  retparams = eval([func '(params);']);

% =============================================================================
% --- Generic processor functions (these are required for every processor)
% =============================================================================

%
% Intialize chanstrip processor -- called by fluo_display_control when added to
%  processor sequence.  Basically a constructor.
%
%  params: 
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%    
function retparams = init(params)
  global glovars;
  retparams = [];

	disp('chanstrip processor init start ...');

	% --- start the gui
  [winhan handles_struct] = chanstrip_control();

	% --- connect to glovars.processor_step(params(1).value).gui_handle
	glovars.processor_step(params(1).value).gui_handle = handles_struct;

	disp('chanstrip processor init end ...');

%
% Closes the chanstrip processor -- basically destructor.
%
%  params:
%    1: process ID -- id within processor sequence.  Allows you to talk to 
%                     glovars, as this is glovars.processor_step(params(1).value)
%
function retparams = shutdown(params)
  retparams = [];

%
% The core of the processor -- this guy is *not* allowed to talk to glovars.
%
%  params:
%    1: path of image file to process 
%    2: output path 
%    3: channel(s) to keep
%
%  retparams: either -1 if fail, or a struct with the following:
%    1: image path if this is an outputting processor
%
function retparams = process(params)
  retparams = [];

  % assign meaningful names to params
  src_path = params(1).value;
	out_path = params(2).value;
	keepchans = params(3).value;

  % --- prelims
	keepchans = sort(keepchans);
  disp(['Starting processor chanstrip on source file ' src_path ' and output file ' out_path]);

  % --- reading
	imopt.channel = 0;
	[im_s improps] = load_image(src_path, -1, imopt);

	if (max(keepchans) > improps.nchans)
	  disp(['chanstrip::' src_path ' contains less channels than the max requested removed channel.  Aborting strip.']);
	  retparams = -1;
		return
	end

  % --- construct output stack
	new_im = zeros(size(im_s,1), size(im_s,2), round(size(im_s,3)*(length(keepchans)/improps.nchans)));
	i = 1;
	new_im(:,:,i) = im_s(:,:,keepchans(1)); i = i +1;
	for c=2:length(keepchans)
		new_im(:,:,i) =  im_s(:,:,keepchans(c)); i=i+1;
	end
  for f=2:size(im_s,3)/improps.nchans
	  base = (f-1)*improps.nchans;
		for c=1:length(keepchans)
			new_im(:,:,i) = im_s(:,:,base + keepchans(c)); i = i+1;
		end
	end

	% --- update the header if needbe in scanimage fashion -- ONLY 'state.acq.numberOfChannelsAcquire=' is changed
	hdr_txt = improps.header;
	hdr_txt = strrep(hdr_txt,['state.acq.numberOfChannelsAcquire=' num2str(improps.nchans)], ...
     ['state.acq.numberOfChannelsAcquire=' num2str(length(keepchans))]);

	% --- output tif
	save_image(new_im, out_path, hdr_txt);
	retparams(1).value = out_path;

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

	% 1) get gui-defined parameters (1-8)
	pr_params = construct_params_from_gui(params);

	% 2) call process()
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

	% 1) get gui-defined parameters 
	pr_params = construct_params_from_gui(params);

	% 2) call process()
  retparams(1).value = par_generate('chanstrip','process',pr_params, params(5).value, params(6).value);


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

%
% constructs a params structure that can be passed to process based on GUI 
% assigned properties
%
function pr_params = construct_params_from_gui(params)
  global glovars;

	si = params(1).value;
	step = glovars.processor_step(si);
	han = step.gui_handle;

  % 1) the only gui variable is the channels to keep
	keepchans = eval(get(han.chans_to_keep_text, 'String'));

  % 2) construct params for process()
  pr_params(1).value = params(2).value; % path of image file to process
  pr_params(2).value = params(3).value; % output path
  pr_params(3).value = keepchans; % channels kept

