%
% SP Sept 2010
%
% Will predict position of whisker at desired frames.  Uses matlab's interp1 function.  
%  Note that this will use frameTimes, so interpolation should account for 
%  instances where frames were for instance dropped or the timer was
%  asynchronous.
%
% USAGE:
%
%  posVec = predictPositionFromInterp(obj, whiskerId, knownFrames, predictedFrames, method, frameHorizon)
%
%  posVec: position vector for predictedFrames
%
%  whiskerId: whisker # to predict position for
%  knownFrames: frames to use that are known -- vector is frame #, scalar
%               means get this many frames.  Note that if frameHorizon is imposed
%               and knownFrames is a scalar and the number of frames
%               available upto frameHorizon is LESS than knownFrames, then
%               nan is returned (i.e., FAIL)
%  predictedFrames: frame(s) that you want prediction for
%  method: default is pchip; see MATLAB documentation for details [spline,
%          nearest, linear, pchip]; pchip is the best, but also the slowest.
%  frameHorizon: how many frames, away from frames you want prediction for,
%                can you travel to get knownFrames?  By default, 2 x the 
%                number of knownFrames
% 
function posVec = predictPositionFromInterp(obj, whiskerId, knownFrames, predictedFrames, method, frameHorizon)
  if (nargin < 5) ; method = 'pchip'; end
	if (nargin < 6) % frameHorizon 
	  if (length(knownFrames) == 1)
		  frameHorizon = 2*knownFrames;
		else
		  frameHorizon = 2*length(knownFrames);
		end
	end
	 
	% pull out the whisker's indices in position matrix
  wpmi = find(obj.positionMatrix(:,2) == whiskerId);

  % knownFrames specified?
	% this is (barely) slower -- must find the most recent frames, as some may be missing
	nFramesWanted = length(knownFrames);
	if (length(knownFrames) == 1)
	  nFramesWanted = knownFrames;
	  candidateFrames = obj.positionMatrix(wpmi,1);
		if (obj.correctionTemporalDirection == 1) % forward in time
		  minPred = min(predictedFrames);
			candidateFrames = candidateFrames(find(candidateFrames<minPred));
			startCandidateFramesIdx = max(1, length(candidateFrames)-knownFrames+1);
			knownFrames = candidateFrames(startCandidateFramesIdx:length(candidateFrames));
			
			% frameHorizon
			knownFrames = knownFrames(find(knownFrames > minPred-frameHorizon-1));
		else % backward
		  maxPred = max(predictedFrames);
			candidateFrames = candidateFrames(find(candidateFrames>maxPred));
			endCandidateFramesIdx = max(length(candidateFrames), length(candidateFrames)-knownFrames+1);
			knownFrames = candidateFrames(1:endCandidateFramesIdx);
			knownFrames = knownFrames(find(knownFrames < maxPred+ frameHorizon+1));
		end
  end

  % a final sanity check
	if (length(knownFrames) < 2 & obj.messageLevel >=2 | length(knownFrames) < nFramesWanted)
%	  disp('predictPositionFromInterp::FAIL! Must have at least 2 points to do interpolation');
		posVec = nan;
		return;
	end

	% since we can safely assume that frames are in order in positionMatrix, indexing is fast
	minIdx = find(obj.positionMatrix(wpmi,1) == min(knownFrames));
	maxIdx = find(obj.positionMatrix(wpmi,1) == max(knownFrames));

	knownPositions = obj.positionMatrix(wpmi(minIdx:maxIdx), 3);

  % final check -- NOT ALLOWED to use nan
	if (sum(isnan(knownPositions)) > 0 | length(knownFrames) ~= length(knownPositions)) ; posVec  = nan ; return ; end

	% predict ...
  knownTimes = obj.frameTimes(knownFrames);
  predictedTimes = obj.frameTimes(predictedFrames);
	posVec = interp1(knownTimes, knownPositions, predictedTimes, method);
