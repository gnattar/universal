%
% SP Oct 2010
%
% This will udpate the whiskerData structure, specifically it will update 
%  whiskerData.whiskerId based off positionMatrix.
%
% USAGE:
%   wt.updateWhiskerData()
%
function updateWhiskerData(obj)
  obj.enableWhiskerData();

  % thru frames
	for f=1:obj.numFrames
	  fpmi = find(obj.positionMatrix(:,1) == f);
	  obj.whiskerData(f).whiskerId = obj.positionMatrix(fpmi,2)';
	end
	obj.whiskerDataUpdated = 1;
