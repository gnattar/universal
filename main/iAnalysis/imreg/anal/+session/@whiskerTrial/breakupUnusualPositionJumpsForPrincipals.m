%
% SP Oct 2010
%
% This will break whisker for 1:numWhiskers only at places where they make
%  large jumps, where the large jump is explicitly defined.  It looks for
%  the following (not caught by the generic breakupLargePositionJumps):
%   1) jumps across more than one frame (e.g., disappears for a bit)
%   2) places where one whisker's dP shifts with a magnitude that is on the 
%      order of the distance to its neighbors (precisely, 1/2 or more mean
%      distance to TWO neighbors)
% 
% USAGE
%
%  obj.breakupUnusualPositionJumpsForPrincipals()
%
function obj = breakupUnusualPositionJumpsForPrincipals(obj)
  % --- gather statistics FOR EACH WHISKER
	breakVec = []; % frame whiskerId in each row
	if (obj.messageLevel >= 1) ; disp(['breakupUnusualPositionJumpsForPrincipals::processing ' obj.basePathName]); end


	% --- 1) disappearances
	for whiskerId=1:obj.numWhiskers
	  wpmi = find(obj.positionMatrix(:,2) == whiskerId);
	  bigDpFrm=obj.positionMatrix(wpmi(1+find(diff(obj.positionMatrix(wpmi,1)) > 1)),1);

		% ALWAYS go backwards this obviates having to keep track of newIds since 
		%  breakupIdSegment assigns forward
		tMat = [bigDpFrm (bigDpFrm*0 + whiskerId)];
		breakVec = [breakVec ; tMat];
	end

	% --- 2) no break? then check against other whiskers' dP here -- weird?
	if (obj.numWhiskers > 1) % this makes no sense w/ one whisker
		for whiskerId=1:obj.numWhiskers
			% first determine which whisker(s) are present that are adjacent ...
			adjacentIds = [whiskerId-1 whiskerId+1];
			adjacentIds = adjacentIds(find(adjacentIds > 0 & adjacentIds <= obj.numWhiskers));

			wpmi = find(obj.positionMatrix(:,2) == whiskerId);
			wf = obj.positionMatrix(wpmi,1);
			apmi1 = find(obj.positionMatrix(:,2) == adjacentIds(1));
			af1 = obj.positionMatrix(apmi1,1);
			if (length(adjacentIds) > 1)
				apmi2 = find(obj.positionMatrix(:,2) == adjacentIds(2));
				af2 = obj.positionMatrix(apmi2,1);
			else
				apmi2 = [];
				af2 = [];
			end

			% now, for each frame, compute mean distance
			frameDist = nan*wf;
			framePos = nan*wf;
			for F=1:length(wf);
				f = wf(F);
				pw = obj.positionMatrix(wpmi(F),3);

				fd = nan;
				a1i = find(af1 == f);
				a2i = find(af2 == f);
				if (length(a1i) == 1 & length(a2i) == 1)
					fd = 0.5*(abs(pw - obj.positionMatrix(apmi2(a2i),3))+abs(pw - obj.positionMatrix(apmi1(a1i),3)));
				elseif (length(a1i) == 1)
					fd = abs(pw - obj.positionMatrix(apmi1(a1i),3));
				elseif (length(a1i) == 2)
					fd = abs(pw - obj.positionMatrix(apmi2(a2i),3));
				end

				frameDist(F) = fd;
				framePos(F) = pw;
			end

			% now smooth
			frameDist = medfilt1(frameDist,101);
			distThresh{whiskerId} = 0.25*frameDist;
			dFramePos{whiskerId} = abs(diff(framePos));
		%	hold on ; plot(wf,distThresh{whiskerId}, 'Color', obj.whiskerColors(whiskerId+1,:)) ; plot(wf(1:length(wf)-1),dFramePos{whiskerId}, ':', 'Color', obj.whiskerColors(whiskerId+1,:)) ; pause;
		end

		% apply the threshold
		for whiskerId=1:obj.numWhiskers
			wpmi = find(obj.positionMatrix(:,2) == whiskerId);
			wf = obj.positionMatrix(wpmi,1);

			for F=length(wf):-1:2;
				if (dFramePos{whiskerId}(F-1) > distThresh{whiskerId}(F))
					breakVec = [breakVec ; wf(F) whiskerId];
				end
			end
		end
  end
 
  % 3) breakup, cleanup
	breakVec = unique(breakVec, 'rows');
	[sortedBV sortedBVI] = sort(breakVec(:,1));
	breakVec = breakVec(sortedBVI,:);
	for b=size(breakVec,1):-1:1
    obj.breakupIdSegment(breakVec(b,1), breakVec(b,2)); 
	end
	obj.refreshWhiskerIds();
