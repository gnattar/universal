%
% SP Jun 2011
%
%  This will return a list of ROI IDs for ROIs that, based on some criteria, 
%   belong to a particular feature class.  Feature class is defined by the 
%   results of random forest analysis (for now).
%
% USAGE:
%
%   roiIds = sA.getRoisInFeatureClass(params)
%
% PARAMS: 
%  
%  roiIds: list of ROIs that made criteria, with one cell array corresponding
%          to each of the treeFeatures passed
%
%  params: structure with following fields:
%
%    tbRootDir: where to get tree data if pulling anew
%    inputTag: see session.getTreeScores
%    treeTag: again, see session.getTreeScores
%    scoreMethod: how to score (spearman, etc.) -- session.getTreeScores
%    minNEvents: ROIs with less than this many events have score set to nan (D=11)
%
%    treeFeatures: numeric list of plot features shown (default = all);
%                  make a call to sA.sessions{??}.listTreeFeatuers to see the list.
%    sessions: which sessions to look @
%    minNEv: minimum # of events for a ROI to count (11 default -- i.e., > 10)
%  
%
function roiIds = getRoisInFeatureClass(obj,params)

	% --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.getRoisInFeatureClass');
		return;
	end

  % dflts
	treeFeatures = [];
	featureColors = [];
	tbRootDir ='';
	inputTag = [];
	treeTag = [];
	scoreMethod = '';
	minNEv = 11;
	sessions = 1:length(obj.sessions);

  % pull optional
	if (isfield(params, 'tbRootDir')) ; tbRootDir = params.tbRootDir; end
	if (isfield(params, 'inputTag')) ; inputTag = params.inputTag; end
	if (isfield(params, 'treeTag')) ; treeTag = params.treeTag; end
	if (isfield(params, 'scoreMethod')) ; scoreMethod = params.scoreMethod; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'treeFeatures')) ; treeFeatures = params.treeFeatures; end
	if (isfield(params, 'minNEv')) ; minNEv = params.minNEv; end

  % --- meat
	% call getTreeScores ?
	if (length(inputTag) > 0 && length(treeTag) > 0)
		obj.getTreeScores(tbRootDir, inputTag, treeTag, scoreMethod);
	end
  if (length(treeFeatures) == 0)
	  treeFeatures = 1:length(obj.sessions{sessions(1)}.treeFeatureList);
	end
	featureList = obj.sessions{sessions(1)}.treeFeatureList(treeFeatures);

  % setup roiIds
	for f=1:length(featureList)
	  roiIds{f} = [];
		roiScore{f} = [];
	end

  % valid rois ..
	valRois = ones(length(sessions),length(obj.roiIds));
	if (length(minNEv) > 0)
	  for s=1:length(sessions)
		  si = sessions(s);
		  M = obj.sessions{si}.caTSA.caPeakTimeSeriesArray.valueMatrix;
      M(find(isnan(M))) = 0; M(find(isinf(M))) = 0;M(find(M~=0)) = 1;
			nM = sum(M');
      valRois(s,find(nM < minNEv)) = 0;
	  end
	end

  % build the matrix of the data, used throughout
	dataMat = nan*zeros(length(obj.roiIds), length(treeFeatures), length(obj.sessions));
	for s=1:length(sessions)
		si = sessions(s);
		pfi = 1:length(treeFeatures);
		vfi = [];
		for f=1:length(treeFeatures)
		  fi = find(strcmp(obj.sessions{si}.treeFeatureList, featureList{f}));
			if (length(fi) > 0)
			  vfi = [vfi fi];
			else
			  pfi = setdiff(pfi, f);
			end
		end
		if (length(obj.sessions{si}.treeScoreMatrix) > 0)
			dataMat(:,pfi,si) = obj.sessions{si}.treeScoreMatrix(vfi,:)';
			inval = find(valRois(s,:) == 0);
			dataMat(inval,:,si) = nan;
		end
	end
	dataMat = abs(dataMat); % no negs yo!

	% --- now do the measurement ...
  % criteria for now: for 25% of sessions, exceed score of minScore
	minN = round(.25*length(sessions));
	minScore = 0.35;
	allRois = [];
	for f=1:length(treeFeatures)
	  for r=1:length(obj.roiIds)
		  scoreVec = squeeze(dataMat(r,f,:));
			fracAbove = length(find(scoreVec > minScore))/length(sessions);
			if (fracAbove > minScore)  
			  roiIds{f} = [roiIds{f} obj.roiIds(r)]; 
				roiScore{f} = [roiScore{f} nanmean(scoreVec)];
				allRois = union(allRois, obj.roiIds(r));
			end
		end
  end

	% force into specific category . . . 
  for r=1:length(allRois)
	  featureScore = 0*(1:length(treeFeatures));
		for f=1:length(treeFeatures)
		  idx = find(roiIds{f} == allRois(r));
			if (length(idx) > 0)
			  featureScore(f) = roiScore{f}(idx);
			end
		end
		[irr bestFeatureIdx] = max(featureScore);
    otherFeatures = setdiff(1:length(treeFeatures), bestFeatureIdx);
    for f=otherFeatures
		  remIdx = find(roiIds{f} == allRois(r));
			nIdx = setdiff(1:length(roiIds{f}), remIdx);
			roiIds{f} = roiIds{f}(nIdx);
			roiScore{f} = roiScore{f}(nIdx);
		end
	end

