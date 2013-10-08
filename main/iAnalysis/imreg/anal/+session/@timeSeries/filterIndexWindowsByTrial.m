%
% SP Jan 2011
%
% Reduces an index window matrix to those which belong entirely
%  or partly to the specified trials. Partial members have the non-
%  belonging part nan'd.
%
% USAGE:
%
%  indexMat = filterIndexWindowByTrial (indexMat, trialIndices, restrictToTrials)
%
%    indexMat: each row is a series of indices correspoding to a presumed
%              time/value vector of a timeSeries object
%    trialIndices: a vector of same size as time/value that, for each data 
%                  point, gives which trial # it is in
%    restrictToTrials: which trials to restrict to
%                             
function indexMat = filterIndexWindowByTrial (indexMat, trialIndices, restrictToTrials)

  % --- must give all
	if (nargin < 3)
	  disp('filterIndexWindowByTrial::must give indexMat, trialIndices and restrictToTrials')
		return;
	end
	restrictToTrials = unique(restrictToTrials);

	% --- apply row-by-row
	keepRow = 0*size(indexMat,1);
	baseIdxVec = 1:size(indexMat,2);
	for r=1:size(indexMat,1)
	  rowVec = indexMat(r,:);
	  rowTrialIndex = nan*rowVec;
		valIdx = find(~isnan(rowVec));
	  rowTrialIndex(valIdx) = trialIndices(rowVec(valIdx));

    % is it valid?
		valIdx = find(ismember(rowTrialIndex, restrictToTrials));
		if (length(valIdx) > 0)
		  keepRow(r) = 1;

			% kill off any invalid points with nans
			invalIdx = setdiff(baseIdxVec, valIdx);
			if (length(invalIdx) > 0)
			  indexMat(r,invalIdx) = nan;
			end
		end
	end

	% --- rebuild
	indexMat = indexMat(find(keepRow),:);

