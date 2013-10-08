%
% SP Jan 2011
%
% This will retrieve the global rootDataPath and set default if that is your
%  wanting.
%
% USAGE:
%  
%   rdp = get_root_data_path()
%
%   rdp: rootDataPath global ; default is below.
%
function rootDataPath = get_root_data_path()
  % get it or set to default
  if (length(whos('global','rootDataPath')) == 0)
	  disp('get_root_data_path::rootDataPath not assigned; setting to ~/data/');
		global rootDataPath;
		rootDataPath = ['~' filesep 'data' filesep];
	end
	global rootDataPath;

  % 0 length
	if (length(rootDataPath) == 0)
	  disp('get_root_data_path::rootDataPath not assigned; setting to ~/data/');
		rootDataPath = ['~' filesep 'data' filesep];
	end

	% make sure it ends in filesep
	if(rootDataPath(length(rootDataPath)) ~= filesep)
	  rootDataPath = [rootDataPath filesep]; % must end in filesep!
	end
