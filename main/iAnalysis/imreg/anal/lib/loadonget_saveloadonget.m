%
% SP Oct 2011
% 
% Saves a loadonget compliant class's subvariable to file.
%
% USAGE: 
%
%  loadonget_saveloadonget(obj,varname)
%
% PARAMS:
%
%   obj: object you want to save to file
%   varname: name of variable to save.
%
function loadonget_saveloadonget(obj, varname)
	subfile = strrep(obj.baseFileName, '.mat', ['.' varname '.mat']);
	if (strcmp(subfile, obj.baseFileName)) % same? then append varname bc no extension
		subfile = [subfile '.' varname '.mat'];
	end
	if (exist(subfile) == 2) % if it exists, we check for save
		idx = find(strcmp(obj.loadableVar ,varname));
		if (obj.loadFlag(idx))
			saveVar = eval(['obj.' varname]) ; save(subfile, 'saveVar');
		end
	else % write, since file non-existent
		saveVar = eval(['obj.' varname]) ; save(subfile, 'saveVar');
	end

