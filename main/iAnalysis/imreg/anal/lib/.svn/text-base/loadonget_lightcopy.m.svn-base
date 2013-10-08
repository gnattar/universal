%
% SP Oct 2011
%
% lightCopy that a class can call if it uses loadOnGet functionality.  Returns 
%  a copy of the object that has none of the other-file save variables.  It is
%  assumed that the name of externally stored variables is in obj.loadableVar.
%  It is also assumed that the loadFlag field is in use.
%
% USAGE: 
%
%  light_obj = loadonget_lightcopy (obj)
%
% PARAMS:
%
%   obj: object you want to lighten
%
% RETURNS:
%
%   light_obj: the light object
%  
function light_obj = loadonget_lightcopy(obj)
  class_name = class(obj);

	% make an empty object
	light_obj = eval([class_name '();']);

	% anything that is NOT loadableVar should be saved ...
	var_list = fieldnames(obj);
	for v=1:length(var_list)
		% save only loadable vars
		if (sum(strcmp(var_list{v}, obj.loadableVar)) == 0)
			% ensure it is not constant, because we don't need to copy those
			fp = findprop(obj, var_list{v});
			if (~fp.Constant)
				eval(['light_obj.' var_list{v} ' = obj.' var_list{v} ';']);
			end
		end
	end

	% reset loadFlag
	light_obj.loadFlag = -1+0*obj.loadFlag;

