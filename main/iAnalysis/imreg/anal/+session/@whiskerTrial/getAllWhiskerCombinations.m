%
% Geenrates all possible combinations of AVAILABLE whiskerIds given a number
%  of numDesiredWhiskerIds.
%
% Treat the output of this matrix as telling you which available whisker to
%  assign which ID.  That is, given a row of comboMat, assign the whisker
%  that currently has ID comboMatRow(x) the ID x.  The number of columns will
%  always be the number of desired whiskers, so column # is the ID you should
%  assign. Since whisker skipping is permitted, 0 means that the whisker should
%  be OMITTED from that particular test.
%
% So, e.g., say you have 5 whiskers that have met previously applied criteria
%  (length etc.) and you want to test via some algorithm all possible 3-whisker
%  combinations of the 5 whisker positions. Then availableWhiskerIds would be
%  the IDs of your 5 whiskers while numDesiredWhiskerIds would be 3.  Sometimes,
%  numDesiredWhiskerIds exceeds length(availableWhiskerIds), in which case you
%  must decide which of the desired whiskers to exclude.  
%
% Basically, available/candidate whisker of index comboMat(r,c) should be 
%  assigned an id of c, where r and c are row and column indices.  Note that
%  the number of columns is simply numDesiredWhiskerIds in this scheme.
%
% Finally, minNumWhiskers is the minimal number of whiskers; comboMats will
%  be built with a range of [minNumWhiskers,numDesiredWhiskers] in terms of
%  the number of whiskers possible.
%
function comboMat = getAllWhiskerCombinations(availableWhiskerIds, numDesiredWhiskerIds, minNumWhiskers)
  baseComboMat = getSingleComboMat(availableWhiskerIds, numDesiredWhiskerIds);

	% loop creating additional subsections to combomat
	comboMat = baseComboMat;
	if (length(availableWhiskerIds) > 1)
		for k=minNumWhiskers:numDesiredWhiskerIds-1
			retainMat = nchoosek(availableWhiskerIds,k);
			for r=1:size(retainMat,1)
				retainWhiskers = retainMat(r,:);
				tempComboMat = getSingleComboMat(retainWhiskers, numDesiredWhiskerIds);
				tempComboMat = unique(tempComboMat,'rows');
				comboMat = [comboMat;tempComboMat];
			end
		end
  end

	% unique the whole thing
	comboMat = unique(comboMat,'rows');

%
% For a SIGNLE comboMat, specified completely by numDesiredWhiskerIds and availableWhiskerIds
%
function comboMat = getSingleComboMat(availableWhiskerIds, numDesiredWhiskerIds)
  minNumWhiskers = 2; % must have at LEAST this many whiskers
	k = numDesiredWhiskerIds;
	vec = availableWhiskerIds;
	finalStep = 0;
	if (k > length(availableWhiskerIds))  % we want more than we have -- i.e., some will have to get dropped
	  M = max(availableWhiskerIds)+1;
		lenDiff = k-length(availableWhiskerIds)-1;
	  vec = [availableWhiskerIds M:M+lenDiff];
		finalStep = 1;
	end

	% the core of the matter
	baseCombos = nchoosek(vec,k);
	sbc = size(baseCombos,1);
	sp = size(perms(1:k),1);
	nRows = sbc*sp;
	comboMat = zeros(nRows,k);

	rows=1:sp;
	for b=1:sbc
		subPerms = perms(baseCombos(b,:));
		comboMat(rows,:) = subPerms;
		rows = rows+sp;
	end

	% and if we have too much?
  if (finalStep)
	  newComboMat = 0*comboMat;
    for a=1:length(availableWhiskerIds)
		  newComboMat(find(comboMat == availableWhiskerIds(a))) = availableWhiskerIds(a);
		end
		comboMat = unique(newComboMat,'rows');
	end
