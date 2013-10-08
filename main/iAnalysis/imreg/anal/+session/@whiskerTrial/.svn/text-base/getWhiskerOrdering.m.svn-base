%
% Returns the ordering in terms of whiskerIds for frame f.  That is, if you
%  tell it to find orderin for [1 2 10 20 25] and, positionally, they are 
%  arranged [20 25 1 2 10], that is what you will get in return.  Note that 
%  it is ALWAYS going to give you the 'left-to-right' order - i.e., the
%  FIRST ordering element is the one with the LOWEST position value.
%
% USAGE:
%
%   ordering = getWhiskerOrdering(f, whiskerIds)
%
% f: frame to look at
% whiskerIds: list of whisker IDs to get order for ; blank implies that it should
%             get all whiskers at that frame with id > 0
% ordering: order of whiskers (vector same size as whiskerIds); lowest position
%   has value 1, and so on.  0 means whisker was absent.
%
function ordering = getWhiskerOrdering(obj, f, whiskerIds)
  if (nargin < 3) 
	  whiskerIds = obj.positionMatrix(find(obj.positionMatrix(:,1) == f),2);
	end

	% get position for each whisker 
  position = obj.getWhiskerPosition( whiskerIds,f);

	% sort ..
	[newPosition ordering] = sort(position, 'ascend');

	ordering = whiskerIds(ordering);
	ordering(find(isnan(newPosition))) = 0;

