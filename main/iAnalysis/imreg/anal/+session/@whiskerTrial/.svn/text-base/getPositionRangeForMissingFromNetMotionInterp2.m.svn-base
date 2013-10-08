%
% This will return a *range* of positions in which a particular whisker is likely
%  to reside based on the interpolation of the position of the entire whisker pad.
%
% This is the better algorithm (versus getPositionRange...NetMotionInterp.m) but the
%  other was left for legacy.
%
% USAGE:
%
%   [expectedPosition positionRange] = 
%          wt.getPositionRangeForMissingFromNetMotionInterp2(missingIds, presentIds, f, SFdEP)
%
%   missingIds: id(s) of missing whiskers ; 1:numWhiskers only.
%   presentIds: id(s) of present whiskers ; 1:numWhiskers only.
%   f: frame at which the range is estimated
%   SFdEP: additional scaling factor applied to dEP - the padding to position range.  A 
%          value of 1 (defualt) means that positionRange "fills in" by making 
%          the range be the midpoint between any two whiskers.  A value < 1 means
%          the range is narrowed - basically you constrict acceptable positions.
%          A value > 1 means you expand the positionRange.
%
%   expectedPosition: the exact position that is expected for each *missingIds* whisker
%   positionRange: len(missing)+len(present)x3 matrix, where column 1 is whisker 
%                  id, and 2 and 3 represent the bounds on that whisker
%                  Note that ALL ids are returned, not just missing.
%
function [expectedPosition positionRange] = getPositionRangeForMissingFromNetMotionInterp2 (obj, missingIds, presentIds, f, SFdEP)
  % input processing
	if (nargin < 5) 
	  SFdEP = 1;
	end

  % Other initial variables
	minDp = 10; % applied to first and last whisker as range -- will add/subtract @ least this from the guessed position
	            %  important for whiskers that clump
	Ntp = 5; % how many time points? if you are dealing with time jumps, this should go up
	expectedPosition = [];
	positionRange = [];
	allIds = 1:obj.numWhiskers;
 
  % If this is a skipped-frame vid, need more points (20)
  if (f <= 1)  % can't go
 	  disp(['getPositionRangeForMissingFromNetMotionInterp2::cannot operate on frame 1.']);
    return;
  end
	largeTemporalJump = 0;
  modeDt = mode(diff(obj.frameTimes));
	thisDt = obj.frameTimes(f)-obj.frameTimes(f-1);
	if ((thisDt/modeDt) > 2)
	  Ntp = 20;
		largeTemporalJump = 1;
	end

  % 1) Determine whiskers available for the computing the mean
	%    last 5 frames, which is more than enoguh for pchip which needs 3 poitns
	if (f <= Ntp)
	  disp(['getPositionRangeForMissingFromNetMotionInterp2::cannot operate on frame before ' num2str(Ntp) ' for pchip to work right.']);
    return;
	end
	if (obj.correctionTemporalDirection == 1)
		frm = f-Ntp:f-1;
	else
		frm = f+Ntp:-1:f+1;
	end
	whiskersForMean = intersect(allIds,obj.positionMatrix(find(obj.positionMatrix(:,1) == frm(1)),2));
	for F=2:length(frm)
	  whiskersForMean = intersect(whiskersForMean, obj.positionMatrix(find(obj.positionMatrix(:,1) == frm(F)),2));
	end
  if (length(whiskersForMean) == 0);
	  disp('getPositionRangeForMissingFromNetMotionInterp2::failure -- no whiskers consistently present in all last few frames');
    return;
	end
	
  % 2) Compute mean position and interpolate it
	meanPosVec = 0*frm;
	for F=1:length(frm)
		for w=1:length(whiskersForMean)
			meanPosVec(F) = meanPosVec(F) + obj.getWhiskerPosition(whiskersForMean(w),frm(F));
		end
	end
	meanPosVec = meanPosVec/length(whiskersForMean);
  knownTimes = obj.frameTimes(frm);
%	disp(num2str(meanPosVec));
%	disp(num2str(knownTimes'));
  predictedTime = obj.frameTimes(f);
	meanPosPredicted = interp1(knownTimes, meanPosVec, predictedTime, 'pchip') ;
	% if this prediction is WILD, try with rounded pchip
	dt = diff(knownTimes);
	if (size(dt,1) > 1) ; dt = dt' ; end
	dp = diff(meanPosVec);
	if (size(dp,1) > 1) ; dp = dp' ; end
	maxDpDt = max(abs(dp./dt));
  finalPos = meanPosVec(length(meanPosVec));
	finalDt = min(abs(knownTimes-predictedTime));
  if (abs(meanPosPredicted-finalPos)/finalDt > 2*maxDpDt)
		meanPosPredicted2 = interp1(knownTimes, floor(meanPosVec), predictedTime, 'pchip'); 
		if (abs(meanPosPredicted2-finalPos) < abs(meanPosPredicted-finalPos))
		  meanPosPredicted = meanPosPredicted2;
			disp('getPositionRangeForMissingFromNetMotionInter2::using floord estimate');
		end
		if (abs(meanPosPredicted-finalPos)/finalDt > 2*maxDpDt) % still too much? go linear
			meanPosPredicted2 = interp1(knownTimes, floor(meanPosVec), predictedTime, 'linear','extrap'); 
			if (abs(meanPosPredicted2-finalPos) < abs(meanPosPredicted-finalPos))
				meanPosPredicted = meanPosPredicted2;
				disp('getPositionRangeForMissingFromNetMotionInter2::using linear estimate');
			end
		end
	end



  % 3) For ANY missing whisker present during last Ntp frames, generate a guessed position
	expectedPosition = nan*missingIds;
  for m=1:length(missingIds)
	  allFrames = obj.positionMatrix(find(obj.positionMatrix(:,2) == missingIds(m)),1);
		if (obj.correctionTemporalDirection == 1)
			lastFrame = max(allFrames(find(allFrames < f & allFrames >= f-Ntp)));
		else
			lastFrame = min(allFrames(find(allFrames > f & allFrames <= f+Ntp)));
		end
		if (length(lastFrame) > 0) % generate a guessed position
			meanPosVec(find(frm == lastFrame));
		  meanOffset = obj.getWhiskerPosition(missingIds(m),lastFrame) - meanPosVec(find(frm == lastFrame));
      expectedPosition(m) = meanOffset + meanPosPredicted;
		end
	end

  % 4) For ANY whisker present during last Ntp frames, generate a position range 
	allPositions = nan*(allIds); % this is necessary in the next block
	for a=1:length(allIds)
	  pi = find (presentIds == allIds(a));
		if (length(pi) == 1)
      allPositions(a) = obj.getWhiskerPosition(presentIds(pi), f);
		else
		  if (largeTemporalJump) % be conservative in this case and use last frame as basis for position range center
				allPositions(a) = obj.getLastWhiskerPosition(allIds(a), f);
			else % use interpolant as it is accurate
				mi = find(missingIds == allIds(a));
				allPositions(a) = expectedPosition(mi);
			end
		end
	end
%	dEP = diff(allPositions);
	dEP = SFdEP*floor(abs(diff(allPositions)/2));
  positionRange = nan*ones(obj.numWhiskers,3);
	positionRange(:,1) = allIds;
	for w=1:obj.numWhiskers
	  mi = find(missingIds == w);
	  if (length(mi) == 1) % missing whisker? if NOT then don't mess with it!
		  if (~ isnan(allPositions(w))) % nan should be rejected
			  if (obj.positionDirection == 1) % L -> r
					if (w == 1) % first whisker -- left-to-right means this will be min 
					  positionRange(w,:) = [w max(0, allPositions(w)-3*max(minDp,dEP(1))) allPositions(w)+max(minDp,dEP(1))];
					elseif (w == obj.numWhiskers) % last whisker: L->R this is max
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w-1)) allPositions(w)+3*max(minDp,dEP(w-1))];
					else % all others
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w-1)) allPositions(w)+max(minDp,dEP(w))];
					end
				else % r -> l
					if (w == 1) % first whisker -- r to L means this is MAX
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w)) allPositions(w)+3*max(minDp,dEP(w))];
					elseif (w == obj.numWhiskers) % last whisker: R->L this is min
					  positionRange(w,:) = [w max(0, allPositions(w)-3*max(minDp,dEP(w-1))) allPositions(w)+max(minDp,dEP(w-1))];
					else % all others
					  positionRange(w,:) = [w allPositions(w)-max(minDp,dEP(w)) allPositions(w)+max(minDp,dEP(w-1))];
					end
				end
			end
		else % present whisker?
		  positionRange(w,:) = [w allPositions(w) allPositions(w)];
		end
	end

