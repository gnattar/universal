%
% SP Sept 2011
%
% Generates batch sequence for parallel daemon based execution without
%  a gui.  Note that any processor must have process_batch_nogui and
%  construct_params methods, otherwise this will fail.
%
% USAGE:
%
%  fluo_pargen_nogui(source_path, source_wildcard, output_path, par_path, 
%                    processor_names, processor_params, override_parmat_warning)
%
% PARAMS:
%
%  source_path, source_wildcard: where the source .tif/image files reside ; 
%                                source_path can be get_fluo_dirs_from_wc 
%                                compatible, in which case, if par_path contains
%                                %###, that will be replaced by the 3-digit 
%                                number of the source directory.  Note that 
%                                source_wildcard is STILL employed.
%                                source_path can also be cell array.
%  output_path: where things will end up; if source_path is get_fluo_dirs_from_wc
%               based, will simply be fluo_batch_out directory in matched dir.  SAme
%               if source_path is array.  If blank, uses fluo_batch_out subdir too.
%  par_path: where to put par files ; supports '%###' if multiple source_paths - either
%            due to source_path being cell array or using get_fluo_dirs_from_wc.
%            %### is replaced by 001, 002, and so on, for each source dir.
%  processor_names: cell array of processor names to run
%  processor_params: cell array of params structure, one per processor
%  override_parmat_warning: if set to 1, will allow populating already-populated
%                           par directories.  This is a sanity check 4 U!
%
function fluo_pargen_nogui(source_path, source_wildcard, output_path, par_path, ...
                           processor_names, processor_params, override_parmat_warning)

  % --- input process
	if (nargin < 6) 
	  disp('fluo_pargen_nogui::must specify all but override_parmat_warning.');
		help('fluo_pargen_nogui');
		return;
	end
	if (nargin < 7) ; override_parmat_warning = 0; end
	if (~iscell(source_path)) ; source_path = {source_path}; end

  % --- run over multiple directories?
	if (length(source_path) == 1 && length(get_fluo_dirs_from_wc(source_path{1})) > 0)
	  source_path = get_fluo_dirs_from_wc(source_path{1});
		if (length(source_path) < 1) ; disp('No matches to source_path wildcard found.') ; return ; end
  end

  % do all dirs
  for d=1:length(source_path)

		% build specific output path if multiple sources
		if (length(source_path) > 1 | length(output_path) == 0) 
		  output_path = [source_path{d} filesep 'fluo_batch_out' filesep]; 
		end

    % multiple output targets for parallel execution
    fin_par_path = par_path;
    if (length(strfind(par_path, '%###')) > 0)
      num_idx = strfind(par_path, '%###');
			fin_par_path = [par_path(1:num_idx-1) sprintf('%03d', d) par_path(num_idx+4:end)]  ;
		end
    
		% and call main method
		disp('=============================================================================');
		disp(['Source path: ' source_path{d}]);
		disp(['Output path: ' output_path]);
		disp(['Par path: ' fin_par_path]);
		disp(' ');
		fluo_pargen_nogui_single(source_path{d}, source_wildcard, output_path ,fin_par_path, ...
					processor_names, processor_params, override_parmat_warning);
	end

%
% processes single source_path
%
function fluo_pargen_nogui_single(source_path, source_wildcard, output_path ,par_path, ...
	      processor_names, processor_params, override_parmat_warning);

  % if 1, process via parallel -- for now, "fire and forget" so you kickoff processes but do NOT
	%  wait for their completion
  dep_filepath = ''; % blank means nothing

  % --- first, create output, par directories if needbe
	if (exist(output_path,'dir') == 0)
	  disp(['Batch output directory, ' output_path ', does not exist; creating.']);
    mkdir(output_path);
	end
  if (exist(par_path,'dir') == 0)
	  disp(['Parfile output directory, ' par_path ', does not exist; creating.']);
    mkdir(par_path);
	end
 
  % get file list ; assign last_out_path for each file stream as the main source file
	flist = dir([source_path filesep source_wildcard]);
	
	% transfer flist to source_files
	for f=1:length(flist)
		source_files{f} = flist(f).name;
	end

	for f=1:length(source_files)
		last_out_path{f} = [source_path filesep source_files{f}];
	end
	last_step_is_base = 1; % 1: previous step was base image ; sets to 0 after first output

  %  unique string stamp for this batch for parallel execution
	ustr = datestr(now,'yyyymmddHHMMSSFFF');

  % --- TOP LOOP --- go thru all the processors 
	ns = length(processor_names);
	for s=1:length(processor_names)
		step_idx = s;
		file_output = 0;

    processor = get_processors(processor_names{s});
		p_struct = processor_params{s};

    % if this has batch_style of 3 or 4, assign dep file for *previous* step
		if(processor.batch_style == 3 &  s > 1)
		  dep_filepath = [par_path filesep 'parfile_' ustr '_' num2str(s-1) '_*']; % tmp and mat should be included
		end
		if(processor.batch_style == 4 &  s > 1)
		  dep_filepath = [par_path filesep 'parfile_' ustr '_' num2str(s-1) '_*']; % tmp and mat 
		end

    % --- SECOND LOOP ---go thru all the files
    for f=1:length(source_files)
		  % for processors that only need one run
			if(processor.batch_nfiles == 2 & f > 1)
			  break;
			end

			% construct params -- for a processor, this is always:
			%  1: id of process step in processor_step array
			%  2: path of source image file 
			%  3: output path 
			%  4: progress
			params(1).value = step_idx;

			% source path -- last step's output; this is "safe" in terms of processors
			%  that do not output files since only ones that DO get to affect last_out_path
			params(2).value = last_out_path{f};

			% output path: based on specified path, processor name
			if (processor.image_output == 1)
				params(3).value = [output_path filesep strrep(processor.name,' ', '_') '_' num2str(step_idx) '_' source_files{f}];
			else
			  params(3).value = -1;
			end

			% progress -- this is the only case where this matters
      params(4).value = [f length(source_files)];

			% --- setup parallel processing pertinent info

				% 0) .mat file name -- for parallel processing -- params(4)
				if (s == 2 & f == 1) % VERY FIRST so check for unfinished
				  par_list = dir([par_path filesep '*.mat']);
					if (length(par_list) > 1 & override_parmat_warning == 0)
					  disp(['There are .mat files in ' par_path ' implying incomplete execution.  Pass override_parmat_warning to skip.']);
						return;
					end
				end
				mat_fpath = [par_path filesep 'parfile_' ustr '_' num2str(step_idx) '_' num2str(f) '.mat'];
        params(5).value = mat_fpath;
  
				% 1) dependencies -- if other step must be done before, specify it as params(5)
				params(6).value = dep_filepath;

				% params to pass that are processor-specific to the process_batch_nogui method
				params(7).value = p_struct;

				% make the call to process batch IF PARALLEL EXECUTION ; 
				func = 'process_batch_nogui';
				retparams = eval([processor.func_name '(func,params);']);

			% --- process retparams
			% did this (should this!) return a path? - then update next step so that it knows to look to new file
			im_path = '';
			im_fname = '';
			if (processor.image_output == 1)
				file_output = 1;

				% - extract filename
				out_path = params(3).value;
				if (out_path(length(out_path)) == filesep) ; out_path = out_path(1:length(out_path)-1); end
				sli = find(out_path == filesep, 1, 'last');
				im_path = out_path(1:sli-1);
				im_fname = out_path(sli+1:length(out_path));

				% - keep last output path pointing to this step since it is your last step w/ a file output
				last_out_path{f} = [im_path filesep im_fname];
			end	

			% EVENTUALLY you should have 2 checkboxes 1) parallel mode 2) wait for par to execute ; if user selects 2
			%  as well as 1, this should ping every few seconds to see how much is left, and update gui at end 
			disp(['Processor execution of ' processor.name ' successfully queued.']);
			disp(['  Image fname: ' im_path filesep im_fname]);
			disp(['  .MAT file path: ' retparams(1).value]);
		end

    % if this has batch_style of 1, assign dep file for *next* step for parallel processing
		if(processor.batch_style == 1)
		  dep_filepath = [par_path filesep 'parfile_' ustr '_' num2str(s) '_*'];
		end
		if(processor.batch_style == 4)
		  dep_filepath = [par_path filesep 'parfile_' ustr '_' num2str(s) '_*'];
		end

		% if there was file output, and last step was base, last step is no longer base
		if (last_step_is_base & file_output)
		  last_step_is_base = 0;
		end
	end

	% --- cleanup

	% 'touch' ready_to_run in parfiles directory 
	fh = fopen([par_path filesep 'ready_to_run'], 'w+');
	fclose(fh);
