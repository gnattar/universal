%
% SP Feb 2011
%
% A Wrapper for fileparts which will strrep / with \ if native filesep is \,
%  and vice versa if native filesep is /.
%
%  USAGE: 
%
%  [PATHSTR,NAME,EXT,VERSN] = fileparts_crossplatform(file)
%
function [pathstr name ext versn] = fileparts_crossplatform(file)
  if (filesep == '/')
	  file = strrep(file,'\','/');
	elseif (filesep == '\')
	  file = strrep(file,'/','\');
	end
  [pathstr name ext versn] = fileparts(file);



