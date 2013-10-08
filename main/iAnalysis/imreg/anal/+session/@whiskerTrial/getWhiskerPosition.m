%
% Returns whisker position based on positionMatrixMode for frame f and
%  whisker whiskerId.  Returns nan if whisker is not present.
%
% whiskerId can be a vector of whisker Ids, in which case wp will also be a 
%  vector.
function wp = getWhiskerPosition(obj, whiskerId, f)
	wp = nan+0*whiskerId;
	fpmi = find(obj.positionMatrix(:,1) == f);
  for w=1:length(whiskerId)
	  wpmi = fpmi(find(obj.positionMatrix(fpmi,2) == whiskerId(w)));
		if (length(wpmi) == 1)
			wp(w) = obj.positionMatrix(wpmi,3);
		end
	end
