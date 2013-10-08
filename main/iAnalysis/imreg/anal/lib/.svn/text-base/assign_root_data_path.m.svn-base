%
% S Peron Jan 2011
%
% Will take string s and return sm, which is a modified version of s where
%  <%rootDataPath%> is replaced with what global rootDataPath is.  If the
%  variable is NOT in place, warns user and sets it to '~/data/'
%
%  Note that if you want to DISABLE strrep, set a global variable 
%  rootDataPathDisable = 1. Since this should be used in get.xxx methods, this
%  is very useful since you can't really put a trivial if statement with a 
%  secondary flag in them.
%
% USAGE:
%
%   sm = assign_root_data_path(s)
%
%   s: input string
%   sm: modified string (strrep(s,'<%rootDataPath%>', rootDataPath), basically)
%
function sm = assign_root_data_path(s)
  rdp = get_root_data_path();

	% did they disable?
	disable = 0;
  if (length(whos('global','rootDataPathDisable')) == 1)
	  global rootDataPathDisable;
		disable = rootDataPathDisable;
	end

	% do it!
	if (disable == 1)
	  sm = s;
  elseif (length(s) == 0)
    sm = s;
  else
		sm = strrep(s,'<%rootDataPath%>', rdp);
	end

