%
% S Peron 2010 May
%
% This function uses a special wildcard scheme to return a list of directories
%  for imaging data analysis.  
%
% USAGE:
%  dir_list = get_fluo_dirs_from_wc(wc_str)
%
% PARAMS:
%  wc_str: wildcard string, where %wc{...} is the wildcard string; wherever it
%          appears, dir matches to the contents of {...} using standard file
%          wildcards, returning all dirs matching it.  So, if you have
%           /foo/poo/01_02/abc/def
%           /foo/poo/01_03/abc/def
%           /foo/poo/01_04/abc/def
%           /foo/poo/02_04/abc/def
%          and you do /foo/poo/%wc{01_*}/abc/def, it will rerurn the first 
%          three in dir_list as a cell array.  If you use %wcnf, it will 
%          only return directories where %wcnf{*}/scanimage/fluo_batch_out is
%          NOT present -- i.e., image registration INCOMPLETE
%
function dir_list = get_fluo_dirs_from_wc(wc_str)
  if (nargin == 0) ; wc_str = ''; end
	dir_list = {};
	wcnf = 0; 

  % --- first, get directory list of top directory before wc
	wc_idx = strfind(wc_str, '%wc');
	if (length(strfind(wc_str, '%wcnf')) > 0) ; wcnf = 1; end
	if (length(wc_idx) ~= 1)
		help('get_fluo_dirs_from_wc');
	  disp('get_fluo_dirs_from_wc::must have one and only one wildcard.');
	end

	% pull out wildcard itself
	bracko_idx = strfind(wc_str,'{');
	brackc_idx = strfind(wc_str,'}');
	bracko_idx = min(bracko_idx(find(bracko_idx > wc_idx)));
	brackc_idx = min(brackc_idx(find(brackc_idx > wc_idx)));
	wc = wc_str(bracko_idx+1:brackc_idx-1);

  % before and after ...
	pre_wc = wc_str(1:wc_idx-1);
	post_wc = wc_str(brackc_idx+1:length(wc_str));

	% dir over before + wc
	flist = dir([pre_wc wc]);
	dir_list = {};
	for f=1:length(flist)
	  dirname = [pre_wc flist(f).name ];
    if (isdir(dirname)) 
		  if (~wcnf) % not looking for non-imreg'd
				dirname2 = [dirname post_wc];
				if (isdir(dirname2)) 
					dir_list{length(dir_list)+1} = dirname2;
				end
			else % look for NO imreg dirs
				dirname2 = [dirname post_wc];
				dirname3 = [dirname post_wc filesep 'fluo_batch_out'];
				if (isdir(dirname2) & ~isdir(dirname3)) 
					dir_list{length(dir_list)+1} = dirname2;
				end
			end
		end
	end




