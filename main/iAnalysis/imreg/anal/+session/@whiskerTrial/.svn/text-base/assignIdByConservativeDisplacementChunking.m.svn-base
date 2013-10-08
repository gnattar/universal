%
% SP Aug 2010
%
% This will assign whiskers into "chunks".  Uses positional information
%  and assigns whiskers with ID > 0 (from pre-filter steps) to chunks in
%  whick very conservative displacement assumptions are made.  Uses
%  interpolation to figure out connections if possible; otherwise uses simple
%  displacement. (If interpolation is used, displacement threshold is applied
%  to the interpolant-predicted position)
%
% Note that ONLY whiskers with ID > 0 are considered because otherwise all the 
%  hairs around the face make this not work too well.
%
% Uses the following variables:
% obj.correctionTemporalDirection: 1 (default) go in increasing frame # ; 
%  -1: decreasing
%
function obj = assignIdByConservativeDisplacementChunking(obj)
%obj.clearDilatedIndices();
%obj.dilationMaxPixels = -1; % use entire whisker (ORNOT??)
%obj.dilationMaxPixels = 50; % OR NOT
%obj.dilationSize = 41; 
%obj.overlapNonlatestWeight = 4;
%obj.overlapWeighByDistance = 1;
%obj.overlapEnforceSpatialOrder = 1;
%disp(['assignIdByConservativeDisplacementChunking::REMOVE ABOVE!!!']);

if (obj.messageLevel >= 2) ; disp(['assignIdByConservativeDisplacementChunking::asumes starting frames good ; change this.']); end

  % --- prelimes
	if (obj.messageLevel >= 1) ; disp(['assignIdByConservativeDisplacementChunking::processing ' obj.basePathName]); end
	whiskerIds = 1:obj.numWhiskers;

	% --- setup dpThresh::MINIMAL interAdjacentWhiskerDistanceMatrix(:,3)
	val = find(obj.interAdjacentWhiskerDistanceMatrix(:,3) > 0);
	dpThresh = min(obj.interAdjacentWhiskerDistanceMatrix(val,3));
	if (obj.messageLevel >= 2) ; disp(['assignIdByConservativeDisplacementChunking::dpThresh ' num2str(dpThresh)]); end

	% --- Order based on temporal direction desired
	allFrames = obj.frames;
	if (obj.correctionTemporalDirection == 1) % increasing
		allFrames = sort(allFrames, 'ascend');
	else % decreasing
		allFrames = sort(allFrames, 'descend');
	end

  % --- LOOP 1: put everybody into chunks -- this is pretty bulletproof
	if (obj.waitBar) ; wb = waitbar(0, 'Assigning chunk ID from position ...'); end
	framet = []; % times 
	nextId = max(obj.whiskerIds)+1;
	for F=1:length(allFrames)-1 % loop thru ALL frames but then test if bad ...
	  % grab frame
		tic;
	  if (obj.waitBar) ; waitbar(F/length(obj.frames), wb, 'Assigning chunk ID from position ...'); end
    ft = allFrames(F); % our 'template' frame
    f = allFrames(F+1);

    % positionMatrix indices
	  fpmi = find(obj.positionMatrix(:,1) ==f);
	  ftpmi = find(obj.positionMatrix(:,1) ==ft);

    % --- ASSUME frame 1 is good . . . for next frame, assign IDs based on having
		%     minimal displacement & below dpThresh
    vwt = find(obj.positionMatrix (ftpmi,2) > 0);

    % try to get position via interpolation
		tPos = [];
		for w=1:length(vwt)
		  pPos = obj.predictPositionFromInterp(obj.positionMatrix(ftpmi(vwt(w)),2), 10, f, 'pchip', 10);
			if (pPos > 0) 
			  tPos(w) = pPos;
%				disp([num2str(f) ':A']);
			else % interp failed -- use constancy prediction
				tPos(w) = obj.positionMatrix(ftpmi(vwt(w)),3);
%				disp([num2str(f) ':B']);
			end
		end

		% gather positions from TEMPLATE frame
%				tPos = obj.positionMatrix(ftpmi(vwt),3);

    % now proces whiskers from the frame-of-itnerest
    vw = find(obj.positionMatrix (fpmi,2) > 0);
		pos = obj.positionMatrix(fpmi(vw),3);
		for w=1:length(vw) % as you gather position, assign ID
			if (length(tPos) > 0) % rare, but check that template frame has whiskers(!)
				% compute distance relative last frame points
				dp = abs(tPos-pos(w));

				% find minimal distance between this frame and template
				[mindp minidx] = min(dp);
			else % no whiskers in template frame? assign mindp > dpThrseh, forcing nextId
			  mindp = dpThresh+1; 
			end

      % minimal distance is acceptable? assign id
			if (mindp <= dpThresh)
			  obj.positionMatrix(fpmi(vw(w)),2) = obj.positionMatrix(ftpmi(vwt(minidx)),2);
			% if it does NOT satisfy dpThresh criterion, assign nextId and increment nextId
			else
			  obj.positionMatrix(fpmi(vw(w)),2) = nextId;
				nextId = nextId+1;
			end
		  
		end

		% duplicate removal
		newWhiskerIds = obj.positionMatrix(fpmi,2);
		newWhiskerIds = sort(newWhiskerIds(find(newWhiskerIds > 0)));
		dupeIds = newWhiskerIds(find(diff(newWhiskerIds) == 0));
		for d=1:length(dupeIds)
		  dpmi = fpmi(obj.positionMatrix(fpmi,2) == dupeIds(d));
			for i=2:length(dpmi)
			  obj.positionMatrix(dpmi(i),2) = nextId;
				nextId = nextId + 1;
			end
		end


%disp([num2str(f) ': nextid=' num2str(nextId)]);    :

    % timing
		framet(F) = toc;
	end
	if (obj.messageLevel >= 2) ; disp(['assignIdByConservativeDisplacementChunking:: chunking mean frame processing time: ' num2str(mean(framet)) ' max: ' num2str(max(framet))]); end
 
  % --- Update things that need updating and give some messages
	obj.refreshWhiskerIds();
	obj.removeWhiskerIdDuplicates();
	obj.updateFramesPresent();
	if (obj.waitBar) ; delete(wb) ; end
