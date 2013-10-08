ut = unique(s.caTSA.trialIndices) ; 

% just assume trial number is already fine(!)
for t=1:length(ut)
  ti = find(s.caTSA.trialIndices == ut(t));
 
  btnum = ut(t)+1;
	bti = find(s.trialIds == btnum);

	if (length(bti) == 0)
	  startTime = max(timeVec) + mode(diff(timeVec));
	else
	  startTime = s.trial{bti}.startTime;
	end

	timeVec = s.caTSA.time(ti);
	timeVec = timeVec - min(timeVec);
	s.caTSA.time(ti) = timeVec + startTime;
end

% and now update trialIndices . . . 
s.caTSA.trialIndices = s.caTSA.trialIndices+1;
s.validCaTrialIds = unique(s.caTSA.trialIndices);
s.validTrialIds  = s.validCaTrialIds;

% catsaArray
s.caTSAArray.caTSA{1} = s.caTSA;
s.caTSAArray.validCaTrialIds{1} = s.validCaTrialIds;

