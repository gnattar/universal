%
% Parallel execution wrapper.
%
%   USAGE:
%
%     par_execute(parpath, persist)
%
%   ARGUMENTS:
%
%     parpath: the path where parfile_*.mat is checked for.  Note that parpath
%              itself can be a wildcard or a cell array of directories if you
%              want the daemon to work on many directories.  You can also use a
%              get_fluo_dirs_from_wc compliant wildcard.
%     persist: an optional flag ; default is 0 (off).  If 1, daemon will 
%              keep running even if all files are gone.
%
%
% This looks to a given directory for .mat files, and assumes they have within them:
%  funcname - a function that should be in path (add below if needbe) and is called
%  subfunc - the first parameter passed to funcname; intended as a secondary subfunction
%            within funcname.m
%  params - structure passed as second parameter to funcname
%  
%  That is, calls eval([funcname '(' subfunc ',' params)]).
%
%  dep_file_path - a wildcard (or '') string that, if dir returns anything for, results
%                  in delay of execution
%
% To terminate execution of a persistent daemon, 'touch' stop_par.m in the directory.  
%  Touching the file during execution will also result in cessation of execution 
%  after any outstanding steps are completed.
%
%  A lockfile for the directory, lock.m, prevents inter-file conflict.  If it remains
%  following some interrupted execution, it must be removed for processing to 
%  resume properly.  
%
%
% Sample execution using screen, which in OS X or Linux makes it a background 
%  process.  My advice for Windows users is always the same: use a better OS.
%
% screen -d -m /usr/bin/matlab -nodesktop -nosplash -r "par_execute('~/sci/anal/par/')"
%
% screen -d -m /Applications/MATLAB_R2007b/bin/matlab -nodesktop -nosplash -r "par_execute('~/sci/anal/par/')"
%
% For cluster execution, invoke with something like:
%
% qsub -pe batch 1 -j y -o /dev/null -b y -cwd -V "/groups/svoboda/wdbp/perons/sci/anal/par/par_execute /groups/svoboda/wdbp/perons/sci/anal/par > par.log"
%
% (C) S Peron Nov. 2009
%

function par_execute(parpath, persist)
  % --- to add stuff to path, invoke addpath below - you should just have it in
	%     your permanent path!

	% --- persistency
	if (nargin < 2)
	  persist = 0; % default is NOT persistent
	end

  % --- handle parpath contingencies
	if (~iscell(parpath)) % if it is a cell we r done
    % wildcard? if dir yields results AND its not a directory then that is the case
    if (length(dir(parpath)) > 1 & ~isdir(parpath))
		  fl = dir(parpath);
			baseDir = fileparts(parpath);
			nparpath = {};
			for f=1:length(fl)
			  if (isdir([baseDir filesep fl(f).name]) & ~strcmp(fl(f).name,'.') & ~strcmp(fl(f).name, '..'))
				  nparpath{length(nparpath)+1} = [baseDir filesep fl(f).name];
				end
			end
			if (length(nparpath) > 0)
			  parpath = nparpath;
			end
		elseif (strfind(parpath,'%wc')) % get_fluo_dirs style wildcard
		  parlist = get_fluo_dirs_from_wc(parpath);
			nparpath = {};
			for f=1:length(parlist)
				nparpath{length(nparpath)+1} = parlist{f};
			end
			if (length(nparpath) > 0)
			  parpath = nparpath;
			end
		end


		if (~iscell(parpath))
			% make cell always, even if 1
			parpath = {parpath};
		end
	end

  % --- The main loop
	% default loop state
	keep_going = 1;

  % assign initial subparpath
  subparpath = parpath{1};
	lock_path = [subparpath filesep 'lock.m'];
	stop_path = [subparpath filesep 'stop_par.m'];
	disp(['Using path: ' subparpath]);

  while(keep_going)
		% lock the file -- OR WAIT
		while(exist(lock_path, 'file') == 2)
			disp(['Lock ' lock_path '  exists -- waiting 1 s']);
			pause(1);
		end
		fid = fopen(lock_path, 'w');
		fclose(fid);

		% Read the LAST .mat file - do this so that length of flist is the amount left
		%  in Q letting generate work
		file_found = 0;
		flist = dir([subparpath filesep 'parfile_*.mat']);

    if (length(flist) > 0)
		  % go thru list and finda file with no dependencies to run
		  for f=1:length(flist)
				my_file = flist(f).name;
				load([subparpath filesep my_file]);

				% check dependencies
        if (length(dep_file_path) == 0) 
				  deps = [];
				else 
					deps = dir(dep_file_path);
				end
				% No dependencies? this is your file to run - tmp it to mark execution
				if (length(deps) == 0)
          file_found = 1;
					movefile([subparpath filesep my_file],[subparpath filesep my_file '.tmp']);
					break;
        end
		  end
    end

		% Unlock directory -- you no longer care
		delete(lock_path);

    % Execute ... if there are files and you found a valid one
    if (length(flist) > 0 & file_found)
		  if (exist('subfunc', 'var') & length(subfunc) > 0)
				exec_str = [funcname '(''' subfunc '''' ',params);'];
			else % straight call
				exec_str = [funcname '(params);'];
			end
      
	  	disp(['par_execute.m::Running parfile ' my_file]);
	  	disp(['par_execute.m::Executing ' exec_str]);
      eval(exec_str);
      delete([subparpath filesep my_file '.tmp']);
    elseif (~persist & length(flist) == 0) % in-persistent daemon 
		  keepparpath = ones(1,length(parpath));
		  % hunt thru other directories
		  for f=1:length(parpath)
        subparpath = parpath{f};

        % get list
				flist = dir([subparpath filesep 'parfile_*.mat']);

				% remove if empty
				if (length(flist) == 0) ; keepparpath(f) = 0; end
			end

      % was there a valid match?
      if (length(find(keepparpath)) > 0)
			  valpp = find(keepparpath);
				randomizer = randperm(length(valpp));

        subparpath = parpath{valpp(randomizer(1))};

				% assign new subparpath
				lock_path = [subparpath filesep 'lock.m'];
				stop_path = [subparpath filesep 'stop_par.m'];
				disp(['Using path: ' subparpath]);

				% clear out parpath
				keepidx = find(keepparpath);
				for k=1:length(keepidx)
				  nparpath{k} = parpath{keepidx(k)};
				end
				parpath = nparpath;
			else
				% if you find nothing, terminate
				disp ('No file found; terminating');
				keep_going = 0;
			end
% This condition would block a bunch of guys in a directory with dep fork !
%		elseif (length(flist) > 0)
%		  disp('No file available -- probably at a dep-file fork, or last file still being processed. Waiting 60 s.');
%			pause(60);
		else
		  % hunt thru other directories
		  keepparpath = ones(1,length(parpath));
		  for f=1:length(parpath)
        subparpath = parpath{f};

        % get list
				flist = dir([subparpath filesep 'parfile_*.mat']);

				% remove if empty
				if (length(flist) == 0) ; keepparpath(f) = 0; end
			end

      % was there a valid match?
      if (length(find(keepparpath)) > 0)
			  valpp = find(keepparpath);
				randomizer = randperm(length(valpp));

        subparpath = parpath{valpp(randomizer(1))};

				% assign new subparpath
				lock_path = [subparpath filesep 'lock.m'];
				stop_path = [subparpath filesep 'stop_par.m'];
				disp(['Using path: ' subparpath]);

				% clear out parpath
				keepidx = find(keepparpath);
				for k=1:length(keepidx)
				  nparpath{k} = parpath{keepidx(k)};
				end
				parpath = nparpath;
			else
				% if you find nothing, wait
				disp (['No file found; waiting 60 s ; create (e.g., via touch) ' stop_path ' to terminate execution.']);
				pause(60);
			end
    end

		% Stop file?
    if (exist(stop_path, 'file') == 2)
		  keep_going = 0;
			disp(['par_execute.m::Exit signal received - ' stop_path ' exists. Terminating. (If you just started par_execute, delete the aforementioned file and restart par_execute)']);
		end
  end
	exit;
