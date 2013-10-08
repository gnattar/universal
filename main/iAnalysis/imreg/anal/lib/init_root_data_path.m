%
% S Peron Mar 2011
%
% Will take string s and return sm, which is a modified version of s where
%  any instance of the global rootDataPath is replaced with <%rootDataPath%>.
%  Basically the complement to assign_root_data_path.
%
% USAGE:
%
%   sm = init_root_data_path(s)
%
%   s: input string
%   sm: modified string (strrep(s,get_root_data_path,'<%rootDataPath%>'), basically)
%
function sm = init_root_data_path(s)
  rdp = get_root_data_path();

	% do it!
	sm = strrep(s,rdp, '<%rootDataPath%>');
