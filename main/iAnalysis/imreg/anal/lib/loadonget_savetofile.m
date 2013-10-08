%
% SP Oct 2011
% 
% Saves a loadonget compliant class to file.
%
% USAGE: 
%
%  obj = loadonget_savetofile(obj,basefilename)
%
% PARAMS:
%
%   obj: object you want to save to file
%   basefilename: the BASE path of where to store things; subfiles are named
%                 by adding stuff to this.  Note that by default the object's
%                 baseFileName field is used.  If passed explicitly, this
%                 will change that field's value.
%
function obj = loadonget_savetofile(obj, basefilename)
	% file name passed?
	if (nargin > 1)
		obj.baseFileName = basefilename;
	end
	
	% make a copy -- this is what you will actually save(!)
	o = obj.lightCopy();

	% save loadable variables - caTSA, ephusTSA, etc. - to individual files
	for v=1:length(obj.loadableVar)
		obj.saveLoadOnGet(obj.loadableVar{v});
	end

	% --- save call
	save (obj.baseFileName, 'o');
