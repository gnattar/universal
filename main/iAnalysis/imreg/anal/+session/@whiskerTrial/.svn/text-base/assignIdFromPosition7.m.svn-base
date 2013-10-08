%
% SP Sept 2010
%
% This is a chunk combiner that uses positional, order, and length information
%  to determine, at frames where some/all 1:numWhiskers are missing, 
%
% Only operates on id > 0 from previous calls to, e.g., applyLengthThreshold().
%
% Uses the following variables:
% obj.correctionTemporalDirection: 1 (default) go in increasing frame # ; 
%  -1: decreasing
%
function obj = assignIdFromPosition7(obj)

  % --- prelimes
	if (obj.messageLevel >= 1) ; disp(['assignIdFromPosition7::processing ' obj.basePathName]); end

  % --- connect chunks ...
	status = frameChunker (obj);
	if (status == 0)  % try backwards if things failed
	  obj.correctionTemporalDirection = -1*obj.correctionTemporalDirection;
		obj.refreshWhiskerIds();
		status = frameChunker(obj);
	  obj.correctionTemporalDirection = -1*obj.correctionTemporalDirection;
		if (status == 0) % failed AGAIN??? nuclear
		  disp('assignIdFromPosition7::GOING NUCLEAR.');
			status = frameChunker(obj,1);
		end
	end

%
% This is the heart of the matter -- status is 0 if fail
%
%   nuclearOption: dont give up
%
function status = frameChunker(obj, nuclearOption);
  status = 0;
	if (nargin == 1) ; nuclearOption = 0; end

	% --- Order based on temporal direction desired
	allFrames = obj.frames;
	if (obj.correctionTemporalDirection == 1) % increasing
		allFrames = sort(allFrames, 'ascend');
	else % decreasing
		allFrames = sort(allFrames, 'descend');
	end

	% --- Make sure init order is proper, no dupes
	obj.forceOrderingAtFrame(allFrames(1),4);
	obj.updateFramesPresent();
  obj.removeWhiskerIdDuplicates();

	% --- main loop
	if (obj.waitBar) ; wb = waitbar(0, 'Combining chunks ...'); end
	framet = []; % times 
	for F=1:length(allFrames) % loop thru ALL frames but then test if bad ...
	  % grab frame
		tic;
	  if (obj.waitBar) ; waitbar(F/length(allFrames), wb, 'Combining chunks ...'); end
    f = allFrames(F);

    [missingIds presentIds] = getMissingAndPresent(obj, f);

    % is anyone missing? 
    if (length(missingIds) > 0)
		
			% if no one is present, assign using conservative interpolation
			if (length(presentIds) == 0)
        if (F == 1) % this is a critical failure -- means first frame failed
				  return;
				end

        assignMissingIdsFromInterp(obj, missingIds, f, .5);

				% anyone present now?
				[missingIds presentIds] = getMissingAndPresent(obj, f);
				if (length(presentIds) == 0)  % try more liberal net motion interpolation
					assignMissingIdsFromInterp(obj, missingIds, f, 1);
					[missingIds presentIds] = getMissingAndPresent(obj, f);
				end

				if (length(presentIds) > 0) % YES: assignMissingIdFromPresent()
%					assignMissingIdsFromPresent(obj, missingIds, presentIds, f);
					iterativelyAssignIdsFromMostRecentlyPresent (obj, missingIds, presentIds, f);
				else % NO: FAIL [in future, assignMissingIdFromLiberalInterpPosLen()]
					disp(['assignIdFromPosition7:: at frame ' num2str(f) ' reached critical failure for ' obj.basePathName]);
					if (~nuclearOption)
						if (obj.waitBar) ; delete(wb) ; end
						return;
					end
			  end
			else
%				assignMissingIdsFromPresent(obj, missingIds, presentIds, f);
        iterativelyAssignIdsFromMostRecentlyPresent (obj, missingIds, presentIds, f);
			end
			
			% Got everything? then discard CRAP wholesale -- i.e., delete segments!
			[missingIds presentIds] = getMissingAndPresent(obj, f);
			if (length(missingIds) == 0)
			  obj.removeExtraWhiskers(f);
				% obj.deleteAllWithId(id)
			end
		end

    % timing
		framet(F) = toc;
	end
	if (obj.messageLevel >= 2) ; disp(['assignIdFromPosition7:: chunk join mean frame processing time: ' num2str(mean(framet)) ' max: ' num2str(max(framet))]); end
 
  % --- Update things that need updating and give some messages
	obj.refreshWhiskerIds();
	if (obj.waitBar) ; delete(wb) ; end
	status = 1; % good exit status -- if we got here (no return etc.

%
% gets missing and present IDs of 1:numwhiskers ; updates framesPresent
%
function [missingIds presentIds] = getMissingAndPresent(obj, f)
  obj.updateFramesPresent(f);

  % who is here, who is missing?
	presentIds = find(obj.framesPresent(:,f));
	missingIds = find(0 == obj.framesPresent(:,f));

  
%
% assignMissingIdsFromInterp(obj, missingIds, f)
% 
% Operates under the assumption that there are no present Ids so all position 
%  guesses are derived via interpolation.
%
function assignMissingIdsFromInterp(obj, missingIds, f, SFdEP)
	% 1) get valid order-preserving candidates
  [originalIdVec originalPMIVec candidateIdMat] = obj.getAllOrderPreservingCandidates(f);

  % 2) get interp'd position for each guy PRESENT IN LAST FRAME
%  modeDt = mode(diff(obj.frameTimes));
%	thisDt = obj.frameTimes(f)-obj.frameTimes(f-1);
%	if ((thisDt/modeDt) >= 2 | method == 2) % twice the normal dt
  if (obj.numWhiskers > 1)
		[expectedPos positionRange] = obj.getPositionRangeForMissingFromNetMotionInterp2 (missingIds, [], f, SFdEP);
		methodName = ['netmotioninterp2 sf:' num2str(SFdEP)];
	else
%		[expectedPos positionRange] = obj.getPositionRangeForMissingFromNetMotionInterp2 (missingIds, [], f);
		[expectedPos positionRange] = obj.getPositionRangeForMissingFromInterp (missingIds, [], f);
		methodName = 'interp';
	end

	% 3) for each candidate, score based on length change and range
	score = [];
	for r=1:size(candidateIdMat,1)
		candidateRow = candidateIdMat(r,:);
		
		% score(r) = obj.getLengthPositionCompositeScore(candidateRow, originalIdVec, missingIds, f, positionRange);
		score(r) = obj.getLengthPositionCompositeScore(candidateRow, originalIdVec, missingIds, f, positionRange, expectedPos);
	end

	% 4) take best score and assign off of it, if such a score exists . . . 
	if (length(score) > 1)
		[bestScore bestIdx] = max(score);
		bestCandidate = candidateIdMat(bestIdx,:);
		reassignIds(obj, originalIdVec, bestCandidate, f, methodName); 
	end

%
% assignMissingIdsFromPresent(obj, missingIds, f)
%
function assignMissingIdsFromPresent(obj, missingIds, presentIds, f)

  % get position ranges for the missing
  positionRange = obj.getPositionRangeForMissingFromPresent (missingIds, presentIds, f);

	% get lengths for everyone
	lastLengths = zeros(size(positionRange,1),1);
	for p=1:length(lastLengths)
	  lastLengths(p) = obj.getLastWhiskerLength(positionRange(p,1), f);
	end

	% compile candidates that satisfy order
  [originalIdVec originalPMIVec newIdMat] = obj.getAllOrderPreservingCandidates(f);

	% winnow down to those candidates which conform with presentIds
  % [must have column set that matches what is there -- only match present, so if you have 1 3 present, 1 * 3 * will match]
	% i.e., build a matchRow where 0 means *, then find matches
	matchRow = zeros(1,size(newIdMat,2));
	for p=1:length(presentIds)
	  matchRow(find(originalIdVec == presentIds(p))) = presentIds(p);
	end
	candidates = ones(1,size(newIdMat,1));
	for c=1:length(matchRow) % match all columns for row
	  if (matchRow(c) > 0)
			candidates(find(newIdMat(:,c) ~= matchRow(c))) = 0;
		end
  end

  % any candidates left over?
	if (length(find(candidates)) > 0)
	  % build candidate matrix
		candidateIdMat = newIdMat(find(candidates),:);

		% for each candidate, score based on length change and range
		score = [];
		for r=1:size(candidateIdMat,1)
		  candidateRow = candidateIdMat(r,:);
      
      score(r) = obj.getLengthPositionCompositeScore(candidateRow, originalIdVec, missingIds, f, positionRange);
		end

		% take best score and assign off of it, if such a score exists . . . 
		if (length(score) > 1)
			[bestScore bestIdx] = max(score);
			bestCandidate = candidateIdMat(bestIdx,:);
			reassignIds(obj, originalIdVec, bestCandidate, f, 'neighbor'); 
		end
	end

%
% Iteratively calls assignIdsFromMostRecentlyPresent until no more can be added
%
function iterativelyAssignIdsFromMostRecentlyPresent (obj, missingIds, presentIds, f)
	assignMissingIdsFromMostRecentlyPresent(obj, missingIds, presentIds, f);
			
	% Got everything? then discard CRAP wholesale -- i.e., delete segments!
	[nMissingIds nPresentIds] = getMissingAndPresent(obj, f); % updates framesPresnt

	while(length(intersect(nMissingIds, missingIds)) ~= length(missingIds)) % i.e., while there is a difference
	  missingIds = nMissingIds;
		assignMissingIdsFromMostRecentlyPresent(obj, nMissingIds, nPresentIds, f);
	  [nMissingIds nPresentIds] = getMissingAndPresent(obj, f); % updates FramesPresent
	end

  obj.updateFramesPresent(f);


%
% assignMissingIdsFromMostRecentlyPresent(obj, missingIds, f)
%
function assignMissingIdsFromMostRecentlyPresent(obj, missingIds, presentIds, f)

  % get position ranges for the missing
  positionRange = obj.getPositionRangeForMissingFromMostRecentlyPresent (missingIds, presentIds, f);

	% get lengths for everyone
	lastLengths = zeros(size(positionRange,1),1);
	for p=1:length(lastLengths)
	  lastLengths(p) = obj.getLastWhiskerLength(positionRange(p,1), f);
	end

	% compile candidates that satisfy order
  [originalIdVec originalPMIVec newIdMat] = obj.getAllOrderPreservingCandidates(f);

	% winnow down to those candidates which conform with presentIds
  % [must have column set that matches what is there -- only match present, so if you have 1 3 present, 1 * 3 * will match]
	% i.e., build a matchRow where 0 means *, then find matches
	matchRow = zeros(1,size(newIdMat,2));
	for p=1:length(presentIds)
	  matchRow(find(originalIdVec == presentIds(p))) = presentIds(p);
	end
	candidates = ones(1,size(newIdMat,1));
	for c=1:length(matchRow) % match all columns for row
	  if (matchRow(c) > 0)
			candidates(find(newIdMat(:,c) ~= matchRow(c))) = 0;
		end
  end

  % any candidates left over?
	if (length(find(candidates)) > 0)
	  % build candidate matrix
		candidateIdMat = newIdMat(find(candidates),:);

		% for each candidate, score based on length change and range
		score = [];
		for r=1:size(candidateIdMat,1)
		  candidateRow = candidateIdMat(r,:);
      
      score(r) = obj.getLengthPositionCompositeScore(candidateRow, originalIdVec, missingIds, f, positionRange);
		end

		% take best score and assign off of it, if such a score exists . . . 
		if (length(score) > 1)
			[bestScore bestIdx] = max(score);
			bestCandidate = candidateIdMat(bestIdx,:);
			reassignIds(obj, originalIdVec, bestCandidate, f, 'neighbor'); 
		end
	end

%
% reassigns several
%
function reassignIds (obj, originalIds, newIds, f, methodId)
  % which ones to do?
	reass = find(originalIds' ~= newIds & newIds > 0);
	for r=1:length(reass)
% check -- will I be creating overlap? if so, CAN'T
%if (f < 1000) ; disp('AAAAA'); end

		% otherwise OK
		if (obj.messageLevel >= 2) ; disp([num2str(f) ' assigning (' methodId '): ' num2str(originalIds(reass(r))) ' to ' num2str(newIds(reass(r)))]); end
		obj.assignNewId(originalIds(reass(r)), newIds(reass(r)),1); % do NOT allow overlap
	end
