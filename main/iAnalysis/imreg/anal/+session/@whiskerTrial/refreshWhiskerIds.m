% 
% Updates obj.whiskerIds by looking @ positionMatrix.
%
function obj = refreshWhiskerIds (obj)
	obj.whiskerIds = sort(unique(obj.positionMatrix(:,2)));
