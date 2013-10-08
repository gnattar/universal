%
% Swaps the ids of two whiskers - i.e., chunk swap
%
% USAGE: 
%   obj.swapIds(Id1, Id2)
% 
% The Ids are sawpped in whiskerData, and also in positionMatrix.
%
function obj = swapIds(obj, Id1, Id2)
	% find positions
	pmi1 = find(obj.positionMatrix(:,2) == Id1);
	pmi2 = find(obj.positionMatrix(:,2) == Id2);

	% swap positions
	obj.positionMatrix(pmi1,2) = Id2;
	obj.positionMatrix(pmi2,2) = Id1;
