%
% Returns most recent length of whisker(s) whiskerId before or ON f
%
% USAGE:
%  wl =  wt.getLastWhiskerLength(whiskerId, f)
%
% whiskerId: the id (or vector for multiple) of whisker(s)
% f: frame to look at (or before)
% wl: vector correspodning to whiskerId with lengths; nan if nothing found
%
function wl = getLastWhiskerLength(obj, whiskerId, f)
	wl = nan+0*whiskerId;
	for w=1:length(whiskerId)
		wpmi = find(obj.positionMatrix(:,2) == whiskerId);
		fi = obj.positionMatrix(wpmi,1);

		if (obj.correctionTemporalDirection == 1) % time increases with frame #
			lastF = unique(max(fi(find(fi <= f))));
		else
			lastF = unique(min(fi(find(fi >= f))));
	  end

		% was there a frame?
		if (length(lastF) == 1)
			wl(w) = obj.getWhiskerLength( whiskerId(w),lastF);
		end
	end

