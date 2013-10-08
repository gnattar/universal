%
% This will eliminate whiskers that are not long enuff, in terms of 
%  pixels.  Specifically, assigns ID 0 to whiskers below obj.minWhiskerLength
%  pixels long.
%
% Set preventDeZero to 1 to skip de-zeroing of already-zeroed whiskers
%
function obj = applyLengthThreshold(obj, preventDeZero)
	if (nargin == 1) ; preventDeZero = 0 ; end
	nid = max(obj.whiskerIds)+1;
	for F=1:length(obj.frames) % loop thru frames
		f = obj.frames(F);
    startIdx = min(find(obj.positionMatrix(:,1) == f));
    endIdx = max(find(obj.positionMatrix(:,1) == f));
		frameIdx = startIdx:endIdx;
		setZero = find (obj.lengthVector(frameIdx) < obj.minWhiskerLength);
		deZero = frameIdx(find(obj.positionMatrix(frameIdx,2) == 0 & ...
									obj.lengthVector(frameIdx) >= obj.minWhiskerLength));

		obj.positionMatrix(frameIdx(setZero),2) = 0;

		% sufficiently long whiskers that HAD a value of zero should be
		%  assigned a value that is  above obj.numWhiskers, so as to allow
		%  them to be used in correction steps 
		if (preventDeZero == 0)
			for d=1:length(deZero) 
				obj.positionMatrix(deZero(d),2) =  nid;
				nid = nid+1;
			end
		end
	end

  % clean up nan positions -- this automatically consigns you to ID 0!
	nanPositions = find(isnan(obj.positionMatrix(:,3)));
	obj.positionMatrix(nanPositions,2) = 0;

  % update
	obj.refreshWhiskerIds();

