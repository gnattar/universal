%
% Returns length of whisker(s) whiskerId at frame f
%
% USAGE:
%  wl =  wt.getWhiskerLength(whiskerId, f)
%
% whiskerId: the id (or vector for multiple) of whisker(s)
% f: frame to look at 
% wl: vector correspodning to whiskerId with lengths; nan if missing
%
function wl = getWhiskerLength(obj, whiskerId, f)
  wl = nan+0*whiskerId;
	fpmi = find(obj.positionMatrix(:,1) == f);
  for w=1:length(whiskerId)
	  wi = find(obj.positionMatrix(fpmi,2) == whiskerId(w));
		if (length(wi) == 1)
			wl(w) = obj.lengthVector(fpmi(wi));
		end
	end

