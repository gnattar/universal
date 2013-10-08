%
% SP Sept 2010
%
% This will break whisker trajectories at places where one of two things happens
%  1) there is a large change in position relative what is normal
%  2) there is a chnange in position that is different than majority of whiskers
% 
% USAGE
%
%  obj.breakupLargePositionJumps(veryLargeJumps)
%
%   veryLargeJumps: if present and 1, dpThresh is min(20,max(5,2*tpThresh))
%
function obj = breakupLargePositionJumps(obj, veryLargeJumps)

  % --- prelims
	if (length(find(diff(obj.frames) < 0)) > 0) ; disp('breakupLargePositionJumps::cannot have descending obj.frames.'); return ; end
	if (obj.messageLevel >= 1) ; disp(['breakupLargePositionJumps::processing ' obj.basePathName]); end
	if (nargin < 2) ; veryLargeJumps = 0 ;end

  % --- remove whisker duplicates ...
  obj.removeWhiskerIdDuplicates();

  % --- Generate displacement statistics
	% 1) get a threshold for displacement by combining diff of displacement matrix
	medDp = nan*ones(1,length(obj.whiskerIds));
	for w=1:length(obj.whiskerIds)
	  pmi = find(obj.positionMatrix(:,2) == obj.whiskerIds(w));
		diffVec = abs(diff(obj.positionMatrix(pmi,3)));
%		sd(w) = 1.4826*mad(diffVec)
		medDp(w) = nanmedian(diffVec);
	end
%	dpThresh = 10*nanmean(sd(find(sd > 0)));
%	dpThresh = min(dpThresh, 20);
  if (obj.numWhiskers > 1) % use interadjacent distance 
		iawdmVal = find(obj.interAdjacentWhiskerDistanceMatrix(:,3) > 1); % omit the crazies
		dpThresh = min(obj.interAdjacentWhiskerDistanceMatrix(iawdmVal,3))/2;
	else % default 20
	  dpThresh  =20;
	end
	if (length(dpThresh) == 0) ; dpThresh = 20 ; end % an occasionally encountered error condition
	dpThresh = min(dpThresh, 20);
	if (veryLargeJumps) 
		dpThresh = min(max(5,2*dpThresh), 20);
	end

	% 2) compute the typical dispersion at diff mat for a region of time - this
	%    can be used to then look at diffMat and see if the change in position
	%    deviates from the change in position of the other whiskers; since motion
	%    is highly correlated, *change* in position should remain in a tight
	%    range.
	disperson = nan+zeros(1,length(obj.frames)-1);
	medianDiff = nan+zeros(1,length(obj.frames)-1);
	diffVec = {};

	for F=2:length(obj.frames);
    % what whiskers do I want to examine?
	  f = obj.frames(F);
	  fpmi = find(obj.positionMatrix(:,1) == f);
		tWhiskerIds = unique(obj.positionMatrix(fpmi,2));
		tWhiskerIds = tWhiskerIds(find(tWhiskerIds > 0));

		% call getDeltaPosition
	  dfxm = obj.getDeltaPosition(f, tWhiskerIds, obj.numFrames);
		whiskerIds = tWhiskerIds(find(~isnan(dfxm)));
		dfxm = dfxm(find(~isnan(dfxm)));

    % and dispersion . . . 
		dispersion(F-1) = 1.4826*mad(dfxm);
		medianDiff(F-1) = nanmedian(dfxm);
		diffVec{F-1} = dfxm;
		diffIds{F-1} = whiskerIds;
	end

	% median filter it
  diffMatDispersion = medfilt1(dispersion,15);

	dispersionSF=5; % scale factor applied to difMatDispersion
	minDispersionThresh = nanmean(diffMatDispersion)*dispersionSF;
	
	% debug?

	if (obj.messageLevel >= 2) ; disp(['breakupLargePositionJumps::dpThresh=' num2str(dpThresh) ' mean dispersion=' num2str(nanmean(diffMatDispersion))]) ; end
	% --- detect large changes in diffMat
	breakEndFrames = [];
	breakIds = [];
	for F=2:length(obj.frames) % loop thru ALL frames but then test if bad ...
	  % grab frame
    f = obj.frames(F);

		% For this frame, find dpThresh violators
		excessiveDpIdx = find (abs(diffVec{F-1}) > dpThresh);
		excessiveDpId = diffIds{F-1}(excessiveDpIdx);

		% Find dispersion violators
		dispersionThresh = max(minDispersionThresh, dispersionSF*diffMatDispersion(F-1));
		excessiveDispersionIdx = find(abs(diffVec{F-1}-medianDiff(F-1)) > dispersionThresh);
		excessiveDispersionId = diffIds{F-1}(excessiveDispersionIdx);

    % combine
		problemWhiskerId = union(excessiveDispersionId, excessiveDpId);

		% do something if needbe
		for p=1:length(problemWhiskerId)
			breakIds = [breakIds problemWhiskerId(p)];
			breakEndFrames = [breakEndFrames f];

		%	disp(['Frame ' num2str(f) ' problem ID: ' num2str(problemWhiskerId')]);

		end
	end

  % --- Break stuff up ...
	if (length(breakEndFrames) > 0)
	  [breakEndFrames bfi] = sort(breakEndFrames, 'ascend');
    breakIds = breakIds(bfi);
    newId = max(obj.whiskerIds)+1;
  
	  for b=1:length(breakEndFrames)
		  breakFrames = breakEndFrames(b);
			breakId = breakIds(b);
			obj.breakupIdSegment (breakFrames, breakId, newId);

			% now update for future frames ...
			breakIds(find(breakIds == breakId)) = newId;
      newId = newId+1;
    end
  end

  % --- Update things that need updating and give some messages
	obj.refreshWhiskerIds();
	obj.updateFramesPresent();
