%
% SP Oct 2011
%
% should be called by loadobj in classes using loadOnGet
%
% USAGE: 
%
%  obj = loadonget_loadobj (a)
%
% PARAMS:
%
%   a: the variable that is passed to loadobj by MATLAB
%  
% RETURNS:
%
%   obj: the object
% 
function obj = loadonget_loadobj ( a)
  class_name = class(a);
  no = eval([class_name '();']);  % create new object in case you change loadableVar (otherwise loaded one will be used)
	a.loadFlag = 0*(1:length(no.loadableVar)); % set it to 0 so it gets loaded ; it is saved as -1
	a.loadableVar = no.loadableVar;
  obj = a;

