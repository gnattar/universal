%
% SP Oct 2011
%
% Loads a loadOnGet variable for a loadOnGet compliant class.
%
% USAGE: 
%
%  value = loadonget_loadonget(obj,varname)
%
% PARAMS:
%
%   obj: object you want to load var for
%   varname: name of variable to load.
%
% RETURNS:
%
%   value: the loaded subvariable
%
function value = loadonget_loadonget(obj, varname)
	value = [];
	
	% sanity check -- blank baseFileName
	if (length(obj.baseFileName) == 0) ; return ; end

	subfile = strrep(obj.baseFileName, '.mat', ['.' varname '.mat']);
	if (strcmp(subfile, obj.baseFileName)) % same? then append varname bc no extension
		subfile = [subfile '.' varname '.mat'];
	end
	idx = find(strcmp(obj.loadableVar ,varname));
	fullpathsubfile = subfile;

	% default is to use PWD
	if (exist(subfile(max(find(subfile == filesep))+1:end)) ~= 2) % try same but what if from different OS?
		dfilesep = '\'; 
		if(filesep == dfilesep) ; dfilesep = '/'; end
		subfile = subfile(max(find(subfile == dfilesep))+1:end);
		subfile = [pwd filesep subfile];
	else
		subfile = subfile(max(find(subfile == filesep))+1:end);
		subfile = [pwd filesep subfile];
	end

	% otherwise try fullpath ...
	if (exist(subfile) ~= 2) 
		subfile = fullpathsubfile;
	end

	if (exist(subfile) == 2 & obj.loadFlag(idx) == 0)
		disp(['loadonget_loadonget::loading ' subfile]);
		load(subfile);
		if (exist('saveVar','var'))
  		value = saveVar;
		elseif (exist('o','var')) % in case of nested loadOnGets
		  value = o;
		end
		obj.loadFlag(idx) = 1;
	end

