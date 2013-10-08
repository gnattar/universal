%
% SP Sept 2010
%
% This will return the ID vectors of all "valid" whisker candidates.  The 
%  "validity" of a whisker is that it must have id > 0.  The valididty of 
%  a set of whiskers is constrained by them having to obey, based on current
%  obj.positionMatrix, the obj.positionDirection constriant.
%
% This constraint is extremely important -- if the position is measured at the
%  right place (close to follicle), where crossings NEVER occur, then you can
%  safely assume that ONLY the list of candidates returned by this method 
%  qualifies at a given frame.
%
% The single-whisker case is included, as is the no-whisker case.  Since cases
%  where not ALL originalIdVec members are included need to be tested, 0 is
%  put in place of a whisker ID.  This means exclude that origianlIdVec whisker.
%
% Note that newIdMat will always have values of 1:obj.numWhiskers because it is
%  assumed you only want candidates with the right # of whiskers.  Of course,
%  candidates with missing whiskers are also considered.
%
% USAGE:
%
% function [originalIdVec originalPMIVec newIdMat] = getAllOrderPreservingCandidates(obj, f)
%
%  f: frame for which to compute the candidates
%
% RETURNS:
%
%  originalIdVec: the CURRENT id vector for the row of VALID whiskers
%  originalPMIdVec: positionMatrix row for each Id in the list above
%  newIdMat: multiple/1 row(s) of same length as originalIdVec that tells you 
%            what the new Id of the corresponding original Id would be for a
%            particular cnadidate.  Each row is a candidate.
%
function [originalIdVec originalPMIdxVec newIdMat] = getAllOrderPreservingCandidates(obj, f)
  % --- determine the valid candidates
	fpmi = find(obj.positionMatrix(:,1) == f);
	vwpmi = fpmi(find(obj.positionMatrix(fpmi,2) >0 & obj.positionMatrix(fpmi,3) > 0));

  % grab whisker IDs & positions
	whiskerIds = obj.positionMatrix(vwpmi,2);
	whiskerPositions = obj.positionMatrix(vwpmi,3);

	% sort the whisker IDs based on postion paying attention to positionDirection
	if (obj.positionDirection == 1)
		[nan ordering] = sort(whiskerPositions);
	else
		[nan ordering] = sort(whiskerPositions, 'descend');
	end
	orderedWhiskerIds = whiskerIds(ordering);

	% assign originalXXX
	originalIdVec = orderedWhiskerIds;
	originalPMIdxVec = vwpmi(ordering);

  % --- generate valid combinations that preserve order -- nchoosek ideally 
	%     suited for this as it assumes orderings are equivalent and so 
	%     conveniently only gives 1 ordering -- the proper one(!)
	desiredWhiskerIds = 1:obj.numWhiskers;

	nDesired = length(desiredWhiskerIds);
	nAvailable = length(orderedWhiskerIds);

	% build newIdMat
	newIdMat(1,:) = zeros(1,nAvailable); % blank condition
	for k=1:min(nAvailable, nDesired)
	  baseRows = nchoosek(desiredWhiskerIds, k);

		% zero-pad them
		for r=1:size(baseRows,1)
		  paddedRows = getZeroPaddedRows(baseRows(r,:), nAvailable);
			newIdMat = [newIdMat ; paddedRows];
		end
	end
  

%
% returns all zero-padded instances of a single row of Ids of length rowLen
% 
function paddedRows = getZeroPaddedRows(baseIds, rowLen)

  paddedRows = [];
	orderings = nchoosek(1:rowLen, length(baseIds));
	paddedRows = zeros(size(orderings,1), rowLen);
	for o=1:size(orderings,1)
	  paddedRows(o,orderings(o,:)) = baseIds;
	end
  
  


	

