%
% Builds framesPresent matrix -- whisker with ID of a row is present in frame 
%  of column with value 1.  0 implies not present.  Specify frame f and only
%  at frame f is it reconstituted.
%
% Usage:
%
%  wt.updateFramePresent(f)
%
% f: optional ; frame to update.  LEave out to do all frames.
%
function obj = updateFramesPresent(obj, f)
  if (nargin == 1)
		obj.framesPresent = zeros(obj.numWhiskers,obj.numFrames);
	  f = 1:obj.numFrames;
	end

	% the meat -- look thru all frames and see if whisker is present
	for f=f
		fVec = find(obj.positionMatrix(:,1) == f);
		for wid=1:obj.numWhiskers
			if (length(find(obj.positionMatrix(fVec,2)  == wid)) > 0)
				obj.framesPresent(wid,f) = 1;
			else
				obj.framesPresent(wid,f) = 0;
			end
		end
	end
