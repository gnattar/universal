%
% This will return a *range* of positions in which a particular whisker is likely
%  to reside based on the interpolation of the position of the entire whisker pad.
%
% missingIds and presentIds should, upon intersect, constitute 1:numWhiskers. 
%  If this assumption is violated, this will not work right -- no checks are
%  in place because checking would make this slower.
%
% USAGE:
%
%   [expectedPosition positionRange] = 
%          wt.getPositionRangeForMissingFromNetMotionInterp(missingIds, presentIds, f)
%
%   missingIds: id(s) of missing whiskers ; 1:numWhiskers only.
%   presentIds: id(s) of present whiskers ; 1:numWhiskers only.
%   f: frame at which the range is estimated
%
%   expectedPosition: the exact position that is expected for each whisker
%   positionRange: len(missing)+len(present)x3 matrix, where column 1 is whisker 
%                  id, and 2 and 3 represent the bounds on that whisker
%                  Note that ALL ids are returned, not just missing.
%
function [expectedPosition positionRange] = getPositionRangeForMissingFromNetMotionInterp (obj, missingIds, presentIds, f)
  disp('***WARNING::getPositionRangeForMissingFromNetMotionInterp should not be used ; use getPositionRangeForMissingFromNetMotionInterp2 instead.');
	minDp = 10; % applied to first and last whisker as range -- will add/subtract @ least this from the guessed position
	            %  important for whiskers that clump
 
  % who OF MISSING was present in LAST FRAME?
	lfpmi = find(obj.positionMatrix(:,1) ==  f-1);
	lastPresentIds = intersect(missingIds, unique(obj.positionMatrix(lfpmi,2)));

  % construct id composite
  if (size(missingIds,1) > 1) ; missingIds = missingIds' ; end
  if (size(presentIds,1) > 1) ; presentIds = presentIds' ; end
  if (size(lastPresentIds,1) > 1) ; lastPresentIds = lastPresentIds' ; end
%	allIds = sort([missingIds presentIds]);
	allIds = lastPresentIds;
  positionRange = zeros([length(allIds)],3);

	% create the mean position vector across all frames of interest
	nfb = max(5,min(f-1,20)); % number of frames back in time -- ideally 20, at least 5
	meanPos = nan*ones(length(f-nfb:f-1),1);
	fi = 1;
	for frm=f-nfb:f-1
	  tpos = nan*allIds;
	  for a=1:length(allIds)
		  tpos(a) = obj.getWhiskerPosition(allIds(a),frm);
    end
	  meanPos(fi) = nanmean(tpos);
		fi = fi+1;
	end
	fi = fi-1;

  % for all Ids, compute offset from mean in all frames
	offsetFromMean = 0*allIds;
	for a=1:length(allIds)
	  lastPos = obj.getWhiskerPosition(allIds(a),f-1);
		if (length(lastPos) == 0)
		  disp('getPositionRangeForMissingFromNetMotionInterp::ERROR -- did not have position in last frame!');
		end
		offsetFromMean(a) = meanPos(fi) - lastPos;
	end

	% interpolate mean
	knownFrames = f-nfb:f-1;
	predictedFrames = f;
  knownTimes = obj.frameTimes(knownFrames);
  predictedTimes = obj.frameTimes(predictedFrames);
	%meanPos
	predictedMeanPos = interp1(knownTimes, meanPos, predictedTimes, 'pchip');

	% for each missing ID, compute consensus position
	if (obj.positionDirection == -1) ; offsetFromMean = -1*offsetFromMean;  end
	expectedPosition = nan*missingIds;
	for m=1:length(missingIds)	  
    ai = find(allIds == missingIds(m));
		if (length(ai) > 0)
			expectedPosition(m) = predictedMeanPos + offsetFromMean(ai);
		end
	end

	% position or allIds
	p = nan*allIds;
	for a=1:length(allIds)
	  % get last position
	  p(a) = obj.getWhiskerPosition(allIds(a),f-1); 
	end

	% bound additions
	dp2 = floor(abs(diff(p)/2));
allIds
dp2
	% assign bounds, depending on order . . .
	if (obj.positionDirection == 1) % L to R
		positionRange(1,:) = [allIds(1) max(0,p(1)-max(minDp,dp2(1))) p(1)+dp2(1)];
	  for a=2:length(allIds)-1
		  positionRange(a,:) = [allIds(a) p(a)-dp2(a-1) p(a)+dp2(a)];
		end
		if (length(allIds) > 2)
			positionRange(a+1,:) = [allIds(a+1)  p(a+1)-dp2(a) p(a+1)+max(dp2(a), minDp)];
		end
	elseif (obj.positionDirection == -1) % R to L
		positionRange(1,:) = [allIds(1)  p(1)-dp2(1) p(1)+max(minDp,dp2(1))];
	  for a=2:length(allIds)-1
		  positionRange(a,:) = [allIds(a) p(a)-dp2(a) p(a)+dp2(a-1)];
		end
		if (length(allIds) > 2)
			positionRange(a+1,:) = [allIds(a+1) max(0,p(a+1)-max(minDp,dp2(a))) p(a+1)+dp2(a)];
		end
  end


