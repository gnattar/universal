%
% Deletes all whisker segments with ID delId by setting their ID to zero and 
%  then nan'ing them in position matrix.
%
function obj = deleteAllWithId (obj, delId)
  % obj.positionMatrix
  delPMIdx = find(obj.positionMatrix(:,2) == delId);
	obj.positionMatrix(delPMIdx,2) = 0;

	% obj.whiskerIds
  delWIdx = find(obj.whiskerIds == delId);
	newIdx = setdiff(1:length(obj.whiskerIds), delWIdx);
	obj.whiskerIds = obj.whiskerIds(newIdx);
