%
% This will return mean length of whisker with ID whiskerId
%
function meanLen = getMeanLength(obj, whiskerId)
	meanLen = nan;

	n = 0;
	netLen = 0;
	for F=1:length(obj.frames)
		f = obj.frames(F);
    startIdx = min(find(obj.positionMatrix(:,1) == f));
		widx = find(obj.positionMatrix(:,1) == f & obj.positionMatrix(:,2) == whiskerId) ;
		if (length(widx) > 0)
			netLen = netLen+obj.lengthVector(widx);
			n=n+1;
		end
	end

	if (n > 0 ) ; meanLen = netLen/n; end
