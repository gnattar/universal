%
% This will break whisker id at f -- making 2 chunks.  Everything from frame
%  f forward is given newId; everything before keeps oldId.
%  and assign one id to frames(1) and left and another to frames(2) and 
%  forward.
%
% Creates new segment with id max(obj.whiskerIds)+1 or newId if one is given.
% 
% As this is an OPERATOR and made for speed it updates nothing outside 
%  positionMatrix.
%
% USAGE:
%   obj.breakupIdSegment (f , oldId, newId)
%
function obj = breakupIdSegment (obj, f, oldId, newId)
	if (nargin <= 3) ; newId = max(obj.whiskerIds)+1; end

	% redo position matrix
	newPmi = find(obj.positionMatrix(:,2) == oldId & obj.positionMatrix(:,1) >= f);
	if (length(newPmi) == 0)
	  disp('breakupIdSegment::no match found.');
		disp(' ');
		disp('USAGE: ');
    disp(' obj.breakupIdSegment (f , oldId, newId)');
	else 
		obj.positionMatrix(newPmi,2) = newId;
		obj.whiskerIds = [obj.whiskerIds; newId];
	end

