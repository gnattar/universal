%
% SP Nov 2010
%
% This aligns scanimage data with the ephus data based on ephus trial #s.  
%  Specifically, this will alter the session object "obj" by reassigning
%  trialIndices to obj.caTSA.  
%
% It works based on the start times of trials, using the variability in 
%  interval and lining up so that the unique sequence of intervals agrees.
%  Clearly, this will FAIL if you have very similar intervals for all trials.
%
% This will align the time stamps of scanimage with behavior.
%
% USAGE:
%  
%  s.alignScanimageWithEphus();
%
function obj = alignScanimageWithEphus(obj)
  % --- presets 
	debug = 3;

  
	% --- 1) setup start-time vectors -- set each to start at ZERO
	disp('alignScanimageWithEphus::Starting alignment ... assuming intertrial interval jitter');

	% scanimage start times
	scimTrials = unique(obj.caTSA.trialIndices);
	scimTrialId = [];
	scimStartTime = [];
	for t=1:length(scimTrials)
	  vals = find(obj.caTSA.trialIndices == scimTrials(t));
		scimTrialId(t) = scimTrials(t);
    scimStartTime(t) = min(obj.caTSA.time(vals));
	end
	scimStartTime = scimStartTime - min(scimStartTime);

  % ephus start times
	ephTrials = unique(obj.ephusTSA.trialIndices);
	ephTrialId = [];
	ephStartTime = [];
	for t=1:length(ephTrials)
	  vals = find(obj.ephusTSA.trialIndices == ephTrials(t));
		ephTrialId(t) = ephTrials(t);
    ephStartTime(t) = min(obj.ephusTSA.time(vals));
	end
	ephStartTime = ephStartTime-min(ephStartTime);

  % --- 2) alignment
  % populate 2 vectors - ephTrialMap, scimTrialMap - based on 
	%  correspondence.  this is the mapping (i.e., ephTrialMap(n) = scimTrialMap(n), where
	%  ephTrialMap(n) and scimTrialMap(n) are not necessarily identical trial numbers.  if one
	%  is missing, it will be assigned -1.
	%
	% Algo: for a given N, start by overlapping *last* N scimStartTime with *first* N
	%  ephStartTime ; increment until you have *first* N scimStartTime aligned with
	%  *last* N ephStartTime.  At each point, compute the median distance for this alignment,
	%  where you only consider N trials at once.  AFter finding this minimum of this, and 
	%  using it as the initial alignment, find dropped trials in either series by matching
	%  trials only if the starts are within some multiple (5) of this median of one another.
	%
	
	% align starts -- note taht scimStartTime and ephStartTime must start at ZERO for this wto work
	Ls = length(scimStartTime);
	Le = length(ephStartTime);
	N = round(0.5*min(Ls, Le));
	if (debug >= 1) ; disp(['generateSession.alignScanimageWithEphus::using ' num2str(N) ' trials to align eph-scim.']); end

	% loop 1: same ephStartTime (1:N), different scimStartTime
	Ie = 1:N;
	si = 1;
	for ns=Ls-N+1:-1:1
	  Is = ns:ns+N-1;
		scimStartTimeTmp = scimStartTime(Is)-scimStartTime(Is(1));
		bestDist = [];
		for s=1:length(scimStartTimeTmp)
		  dists = abs(scimStartTimeTmp(s)-ephStartTime(Ie));
		  bestDist(s) = min(dists);
		end
    scoreL1(si) = median(bestDist);
		si = si+1;
	end

	% loop 2: same scimStartTime (1:N), different ephStartTime (2+)
	Is = 1:N;
	si = 1;
	for ne=2:Le-N+1
	  Ie = ne:ne+N-1;
		ephStartTimeTmp = ephStartTime(Ie)-ephStartTime(Ie(1));

		bestDist = [];
		for s=1:length(ephStartTimeTmp)
		  dists = abs(ephStartTimeTmp(s)-scimStartTime(Is));
		  bestDist(s) = min(dists);
		end
    scoreL2(si) = median(bestDist);

		si = si+1;
	end

	% where is the minimum? depending, we align ephStartTime and scimStartTime accordingly
	if (min(scoreL2) < min (scoreL1)) % min was found in loop 2
	  [offsThresh mIdx] = min(scoreL2);
		scimStartTime = scimStartTime+ephStartTime(mIdx+1);
	else % min was found in loop 1
	  [offsThresh mIdx] = min(scoreL1);
		ephStartTime = ephStartTime+scimStartTime(Ls-mIdx-N+2);
	end

	% plot for debugZ
	if (debug >= 2)
	  figure; hold on;
		% plot grouped trials
		for e=1:length(ephStartTime)
			plot([ephStartTime(e) ephStartTime(e)], [0 1], 'b-');
		end
		for s=1:length(scimStartTime)
			plot([scimStartTime(s) scimStartTime(s)], [1 2], 'r-');
		end
		title('Before alignment');
	end



	% --- 3) line em up -- match iff offset is sufficiently small
  % now that you have basal alignment & thresh, populate 2 vectors - ephTrialMap, scimTrialMap - based on 
	%  correspondence.  this is the mapping (i.e., ephTrialMap(n) = scimTrialMap(n), where
	%  ephTrialMap(n) and scimTrialMap(n) are not necessarily identical trial numbers.  if one
	%  is missing, it will be assigned -1)
	offsThresh = 10*abs(offsThresh);

	% first build collated vectors with both scanimage and ephus start times
  groupedVec = [scimStartTime ephStartTime];
	typeVec = [ones(1,length(scimStartTime)) zeros(1,length(ephStartTime))]; % 1 = scim time ; 0 = eph_Starts
	indexVec = [1:length(scimStartTime) 1:length(ephStartTime)]; % allows you to track the actual trial #s
	[val nidx] = sort(groupedVec); % sort the grouped vector, then the type-indexing vector

	% redo the vecctors
	groupedVec = groupedVec(nidx);
	typeVec = typeVec(nidx);
	indexVec = indexVec(nidx);

  % now determine, using the grouped vector, which start times are in the same trial
	threshVal = max(offsThresh, 1000); % use 1 second at LEAST - this is important.
	threshVal = min(offsThresh, 5000); % use 5 seconds at most
  threshVal=5000;
	if (debug >= 1) ; disp (['Threshold for intertrial spacing scim/eph (in ms usually): ' num2str(threshVal)]); end

  % now that you have threshold, populate 2 vectors - ephTrialMap, scimTrialMap - based on 
	%  correspondence.  this is the mapping (i.e., ephTrialMap(n) = scimTrialMap(n), where
	%  ephTrialMap(n) and scimTrialMap(n) are not necessarily identical trial numbers.  if one
	%  is missing, it will be assigned -1)
	i = 1; % grouped vec index
	lvec = 1; % final size of vectors - you will trim the two guys below after this is all done
	ephTrialMap = -1*ones(1,length(groupedVec));
	scimTrialMap = -1*ones(1,length(groupedVec));
	while i<length(groupedVec)
	  % same trial
	  if (groupedVec(i+1)-groupedVec(i) < threshVal)
		  % which is which (eph = 0 ; 1 = scim)
			if (typeVec(i) == 1) % if "i" is scim, i+1 must be eph
			  scimTrialMap(lvec) = indexVec(i);
			  ephTrialMap(lvec) = indexVec(i+1);
			else
			  ephTrialMap(lvec) = indexVec(i);
			  scimTrialMap(lvec) = indexVec(i+1);
			end

		  i=i+1; % extra incrementation to skip the next dood
		else % here we have to populate *either* one -- i.e., skipper
			if (typeVec(i) == 1) % if "i" is scim ...
			  scimTrialMap(lvec) = indexVec(i);
			else
			  ephTrialMap(lvec) = indexVec(i);
			end
		end

		% increment lvec - the length of your output vector - and i, your groupedVec index
		i=i+1;
		lvec = lvec + 1;
	end

	% trim the final vectors
	ephTrialMap = ephTrialMap(1:lvec-1);
	scimTrialMap = scimTrialMap(1:lvec-1);

	% plot for debugZ alignment mapping
	if (debug >= 2)
	  figure; hold on;

		% plot grouped trials
		for t = 1:length(scimTrialMap) % same index length so whatevs
		  if (scimTrialMap(t) > 0 & ephTrialMap(t) > 0) % plot togetha
			  idxs = scimTrialMap(t);
			  idxe = ephTrialMap(t);
				plot([scimStartTime(idxs) ephStartTime(idxe)], [2 1], 'k-');
			else % plot individual
			  if (scimTrialMap(t) > 0)
					idx = scimTrialMap(t);
					plot([scimStartTime(idx) scimStartTime(idx)], [1 2], 'r-');
				elseif(ephTrialMap(t) > 0)
					idx = ephTrialMap(t);
					plot([ephStartTime(idx) ephStartTime(idx)], [1 2], 'b-');
				end
			end
		end

    % plot individual trials
		V = ephStartTime ; I = ephTrialMap; 
		for i=1:length(I)  
		  if (I(i) > 0)
		    plot([V(I(i)) V(I(i))], [0 1], 'b-') ; 
			end
		end
		V = scimStartTime ; I = scimTrialMap; 
		for i=1:length(I)  
		  if (I(i) > 0)
		    plot([V(I(i)) V(I(i))], [2 3], 'r-') ; 
			end
		end
		title('After alignment');
	end

  % --- 4) Here, ephTrialMap(n) = scimTrialMap(n), where -1 means missing.  
	% That is, for the trial # given by ephTrialMap(n), the scanimage trial # is
	% scimTrialMap(n).  Update obj.caTSA.trialIndices to reflect the mapping.

  % by default, assign -1
	oldScimTrialIndices = obj.caTSA.trialIndices;
	obj.caTSA.trialIndices = nan*ones(size(obj.caTSA.trialIndices));

	% loop over ephTrialMap -- assign corresponding scanimage trial #s accordingly
	validTrialFlag = zeros(1,length(ephTrials));
	for t=1:length(ephTrialMap)
		if (scimTrialMap(t) > 0 & ephTrialMap(t) > 0) % presnt in both
		  % get new trial index
		  newScimTrialIdx = ephTrials(ephTrialMap(t));
      updatedVals = find(oldScimTrialIndices == scimTrials(scimTrialMap(t)));
			obj.caTSA.trialIndices(updatedVals) = newScimTrialIdx;
			validTrialFlag(ephTrialMap(t)) = 1;
		end
	end

  % update validTrialIndices to discard trials that there is no scanimage data for
	validScimTrials = ephTrials(find(validTrialFlag == 1));
	obj.validCaTrialIds = validScimTrials;
	

