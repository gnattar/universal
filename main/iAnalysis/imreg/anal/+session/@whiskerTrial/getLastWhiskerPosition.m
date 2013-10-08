%
% Returns most recent position of whisker(s) whiskerId before or ON f
%
% USAGE:
%  wp =  wt.getLastWhiskerPosition(whiskerId, f)
%
% whiskerId: the id (or vector for multiple) of whisker(s)
% f: frame to look at (or before)
% wp: vector correspodning to whiskerId with positions; nan for failure
%
function wp = getLastWhiskerPosition(obj, whiskerId, f)
	wp = nan+0*whiskerId;
	for w=1:length(whiskerId)
		wpmi = find(obj.positionMatrix(:,2) == whiskerId);
		fi = obj.positionMatrix(wpmi,1);

		if (obj.correctionTemporalDirection == 1) % time increases with frame #
			lastF = unique(max(fi(find(fi <= f))));
		else
			lastF = unique(min(fi(find(fi >= f))));
	  end

		if (length(lastF) == 1)
		  wp(w) = obj.getWhiskerPosition(whiskerId(w),lastF);
    end
	end


