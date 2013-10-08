%
% SP Oct 2010
%
% This method should be a 'wrapper' that invokes the best-of-class sequence of 
%  session.whiskerTrial methods for linking whisker data.
%
% USAGE:
%
%  score = obj.link()
%  
%  score: return from final obj.scorePositionMatrix call
%
function score = link(obj)
  stopLinkingScore = 0.01; % at this point, all is well

  % first off, lets give nathan a shot -- once you figure out how to score against large delta position
%	obj.loadDotMeasurementsFile();
%	nateScore = obj.scorePositionMatrix(); % NOTE: this applyLengthThresholds and applyMaxFollicleYs
%  nateScore = [0 1]; % for now, we don't do this since nathan's permits large positional jumps, and this is not in score
%  if (nateScore(2) > stopLinkingScore)
  if (obj.numWhiskers < 2) % single whisker? 
%  	obj.loadDotMeasurementsFile();
%  	nateScore = obj.scorePositionMatrix(); % NOTE: this applyLengthThresholds and applyMaxFollicleYs
%		score = [0 1];
%    if (nateScore(2) > stopLinkingScore) % try alternative approach
			% seed initially 
			obj.applyLengthThreshold(); 
			obj.applyMaxFollicleY();
			obj.removeWhiskerIdDuplicates();

			% just simple position based screen
			obj.assignIdFromPosition();
		  score = obj.scorePositionMatrix(); % NOTE: this applyLengthThresholds and applyMaxFollicleYs
%		end
 
%    if (score(2) > nateScore(2)) % go back to nathan system?
%  	  obj.loadDotMeasurementsFile();
%			score = nateScore;
%		end
	else % much harder
		% seed initially 
		obj.applyLengthThreshold(); 
		obj.applyMaxFollicleY();
		obj.removeWhiskerIdDuplicates();
		obj.assignIdByConservativeDisplacementChunking();

		% First round of assignIdFromPosition - start by breaking things up . . .
		obj.breakupUnusualPositionJumpsForPrincipals();
		obj.breakupOrderingReversals();
		obj.breakupLargePositionJumps();
		obj.breakupLargeLengthJumps(); 
		obj.assignIdFromPosition7();

		% Second round
		score = obj.scorePositionMatrix(); % NOTE: this applyLengthThresholds and applyMaxFollicleYs
	%obj.assignRandomColors();obj.plotPositionTrajectory(obj.whiskerIds);title('1');
		if (score(2) > 0.2) % REAL bad?  try backwards
			[obj score] = tryReverseDirection(obj, score, 1);
	%obj.assignRandomColors();obj.plotPositionTrajectory(obj.whiskerIds);title('2');
		end

		if (score(2) > stopLinkingScore) % not done? otherwise we are :D
			obj.breakupUnusualPositionJumpsForPrincipals();
			obj.breakupLargePositionJumps(1); % very large jumps only ; calls removeWhiskerIdDuplicates
			obj.breakupOrderingReversals();
			obj.breakupLargeLengthJumps();
			obj.assignIdFromPosition7();

			% Third round -- this time no reintroduction
			obj.breakupUnusualPositionJumpsForPrincipals();
			obj.breakupOrderingReversals();
			obj.breakupLargeLengthJumps();
			obj.assignIdFromPosition7();
	%obj.assignRandomColors();obj.plotPositionTrajectory(obj.whiskerIds);title('3');

			% Fourth round -- contingent on low score
			score = obj.scorePositionMatrix();
			if (score(2) > 0.25) % more than 10% unassigned with long-enough present
				[obj score] = tryReverseDirection(obj, score, 1);

				score = obj.scorePositionMatrix();
				obj.correctionTemporalDirection = -1*obj.correctionTemporalDirection;
	%obj.assignRandomColors();obj.plotPositionTrajectory(obj.whiskerIds);title('4');
			end

			% Fourth or fifth round [normally we would do applyLengthThresh, but scorePositionMatrix did this
			if (score(2) > stopLinkingScore) % 1% unassigned? one more pass
				obj.assignIdFromPosition7();
				score = obj.scorePositionMatrix();
	%obj.assignRandomColors();obj.plotPositionTrajectory(obj.whiskerIds);title('5');
			end
			if (score(2) > stopLinkingScore) % 1% unassigned? one more pass
				obj.assignIdFromPosition7();
	%obj.assignRandomColors();obj.plotPositionTrajectory(obj.whiskerIds);title('6');
			end
		end

		% final score ...
		score = obj.scorePositionMatrix();
	end

	% cleanup
	obj.removeWhiskerIdDuplicates(); % remove dupes
	obj.removeExtraWhiskers([],1);
	obj.refreshWhiskerIds();
	obj.assignRandomColors();
	obj.updateWhiskerData(); 

	obj.lastLinkPositionMatrixScore = score;

%
% runs the standard test-reverse-direction, reassigning obj if necessary and
%  returning new score
%
function [obj score] = tryReverseDirection(obj, score, severeBreakup)
	tobj = obj.lightCopy();
	tobj.correctionTemporalDirection = -1*tobj.correctionTemporalDirection;
	tobj.breakupUnusualPositionJumpsForPrincipals();
	tobj.breakupOrderingReversals();
	if (severeBreakup)
		tobj.breakupLargePositionJumps();
		tobj.breakupLargeLengthJumps();
	end
	tobj.assignIdFromPosition7();

  % we have to run scorePositionMAtrix on obj since scoring requires whiskerDAta
  opm = obj.positionMatrix;
	ofp = obj.framesPresent;
	owid = obj.whiskerIds;
	obj.positionMatrix = tobj.positionMatrix;
	tscore = obj.scorePositionMatrix(); % NOTE: this applyLengthThresholds and applyMaxFollicleYs updateFramePresents
	if (tscore(2) < score(2))
		obj.correctionTemporalDirection = tobj.correctionTemporalDirection;
		obj.lengthVector = tobj.lengthVector;
		obj.whiskerIds = tobj.whiskerIds;
		score = tscore;
	else
	  obj.positionMatrix = opm; % restore pre-score positionMatrix
		obj.framesPresent = ofp; % restore frames present
		obj.whiskerIds = owid;
	end
