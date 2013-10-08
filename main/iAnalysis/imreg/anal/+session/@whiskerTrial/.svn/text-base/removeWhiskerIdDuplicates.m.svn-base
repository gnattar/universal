%
% This will clean up whisker IDs preventing dupes at a given frame.
%  Most of the code is here for speed.  If you don't specfiy frame,
%  does all frames AND runs some cleanup at end.
%
% USAGE:
%
%   wt.removeWhiskerIdDuplicates(f, removeZeroDupes)
%
%  f: frame to do this at (blank -- [] --  for all frames).  If frame is
%     specified, fast version is used and removeZeroDupes DOES NOT WORK!
%  removeZeroDupes: if 1, it will also remove multiple whiskers with Id 0
%                   (default is 0)
%
function obj = removeWhiskerIdDuplicates(obj, f, removeZeroDupes)
  if (nargin < 2) ; f=1:obj.numFrames ; end
	if (nargin < 3) ; removeZeroDupes = 0 ; end

	% loop over whiskers
  nid = max(obj.whiskerIds)+1;
	
	% frames?
  if (length(f) > 1)
	  for f = f;
			somethingChanged = 0;
			% pull whisker Ids
			fpmi = find(obj.positionMatrix(:,1) == f);
			whiskerIds = obj.positionMatrix(fpmi,2);
			
			% check that there are any even here to look @
			nonZeroIds = sort(whiskerIds(find(whiskerIds > 0)));
			if (removeZeroDupes) ; nonZeroIds = whiskerIds; end
			if (length(find(diff(nonZeroIds) == 0)) == 0) ; continue ; end

			% you will only get here if there was a problem . . . 
			for w=1:length(whiskerIds)
				if (whiskerIds(w) == 0 & ~removeZeroDupes) ; continue ; end

				% indices of same whiskers
				idx = fpmi(find(obj.positionMatrix(fpmi,2) == whiskerIds(w)));
				if (length(idx) > 1) % change all but 1
					somethingChanged = 1;
					for i=2:length(idx)
						obj.positionMatrix(idx(i),2) = nid;
						obj.whiskerIds = [obj.whiskerIds ; nid];
						nid = nid+1;
					end
				end
			end
		end

		if (somethingChanged)
			obj.updateFramesPresent();
		end
	else % quick and dirty single framer
	  fpmi = find(obj.positionMatrix(:,1) == f);
		whiskerIds = obj.positionMatrix(fpmi,2);
		whiskerIds = sort(whiskerIds(find(whiskerIds > 0)));
		dupeIds = whiskerIds(find(diff(whiskerIds) == 0));
		for d=1:length(dupeIds)
			dpmi = fpmi(obj.positionMatrix(fpmi,2) == dupeIds(d));
			for i=2:length(dpmi)
				obj.positionMatrix(dpmi(i),2) = nid;
				obj.whiskerIds = [obj.whiskerIds ; nid];
				nid = nid + 1;
			end
		end
	end
