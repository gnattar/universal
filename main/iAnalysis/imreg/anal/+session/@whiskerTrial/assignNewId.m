%
% Assigns ALL whiskers with a given ID a new id -- AKA chunk join!
%  If you set stopOverlap to 1, it will not allow assignNew operations
%  if such an operation would result in duplication of the newId at
%  some frames following assignment.
%
% USAGE:
%  wt.assignNewId(obj, oldId, newId, stopOverlap)
%
% oldId, newId: all whiskers with id oldId will be given id newId
% stopOverlap: if 1 (blank implies 0), it will check that the assignment
%  does not produce overlap before proceeding ; if it does, it will not do it.
%
function obj = assignNewId(obj, oldId, newId, stopOverlap)
  % stopOveralp?
	if (nargin < 4)
	  stopOverlap = 0;
	end

	% redo position matrix
	oldPmi = find(obj.positionMatrix(:,2) == oldId);
	if (stopOverlap)
	  newPmi = find(obj.positionMatrix(:,2) == newId);
		oldFrames = obj.positionMatrix(oldPmi,1);
		newFrames = obj.positionMatrix(newPmi,1);

		if (length(intersect(oldFrames, newFrames)) > 0) ; return ; end
	end
	obj.positionMatrix(oldPmi,2) = newId;

	% refresh
	obj.refreshWhiskerIds();
