%
% SP Nov 2010
%
% This will generate parfile_xxx.mat files for par_execute to run process.
%
% USAGE:
%   wt.generateParFiles(whiskerSourcePathWc, parDirectoryPath)
%
%   whiskerSourcePathWc: directory + wildcard of which .whiskers files to do.
%      The directory can use get_fluo_dirs_from_wc format.
%   parDirectoryPath: where parfiles are put.
%
function generateParFiles(whiskerSourcePathWc, parDirectoryPath)
  if (nargin < 2)
	  parDirectoryPath = ['~' filesep 'sci' filesep 'anal' filesep 'par'];
	end
	doffs=0;

  
  % 0) pull parameters
  if (parDirectoryPath(length(parDirectoryPath)) ~= filesep) ; parDirectoryPath = [parDirectoryPath filesep]; end

  % 1) list of directories
	dirList = get_fluo_dirs_from_wc(whiskerSourcePathWc);
	slashIdx = find(whiskerSourcePathWc == filesep);
	if (length(dirList) == 0)
	  dirList = {whiskerSourcePathWc(1:slashIdx(length(slashIdx))-1)};
	elseif (length(dirList{1}) == 0)
	  dirList = {whiskerSourcePathWc(1:slashIdx(length(slashIdx))-1)};
	end

  % 2) list of .whiskers files
	if (length(slashIdx) == 0) ; slashIdx = 1; end
	wc = whiskerSourcePathWc(slashIdx(length(slashIdx))+1:length(whiskerSourcePathWc))
	for d=1:length(dirList)
	  flist = dir([dirList{d} filesep wc])
  
	  % dont overwrite
		testPath = [parDirectoryPath 'parfile_' num2str(doffs+d) '_*.mat'];
		while(length(dir(testPath)) > 0)
		  doffs = doffs+1;
			testPath = [parDirectoryPath 'parfile_' num2str(doffs+d) '_*.mat'];
		end
  
		% file loop
		for f=1:length(flist)
		  dotWhiskersPath = [dirList{d} filesep flist(f).name];
			parfilePath = [parDirectoryPath 'parfile_' num2str(doffs+d) '_' num2str(f) '.mat'];
		  disp(['generateParFiles::processing ' dotWhiskersPath]);
		  disp(['generateParFiles::generating ' parfilePath]);

			% --- generate the params structure
			funcname = 'session.whiskerTrial.executeParFile';
			subfunc = '';
			params.dotWhiskersPath = dotWhiskersPath;
			params.batchParamsFilePath = [dirList{d} filesep 'batchParameters.mat'];

      retpath = par_generate(funcname, subfunc, params, parfilePath);
		end
	end

