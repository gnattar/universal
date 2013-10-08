%
% SP May 2011
%
%
%  USAGE:
%
%    sA.plotTreeScoreCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    whiskerTags: cell array of who to do
%    roiIds: which ROIs to look @
%
%    tbRootDir: where to get tree data if pulling anew
%    inputTag: see session.getTreeScores
%    treeTag: again, see session.getTreeScores
%    scoreMethod: how to score (spearman, etc.) -- session.getTreeScores
%    minNEvents: ROIs with less than this many events have score set to nan (D=11)
%
%    plotFeatures: numeric list of plot features shown (default = all);
%                  make a call to sA.sessions{??}.listTreeFeatuers to see the list.
%    sessions: which sessions to plot(dflt all).
%    plotsShown: 1/0 means show/don't
%                (1): ROI Matrix plot, 1 row per feature SHOWN
%                (2): lines -- must specify roiIds
%                (3): atari plot for each featuer
%    featureColors: a nx3 matrix of colors for each of the plotFeatures
%    rangeR: [0.5 0.75] default ; color range for color plots
%    minNEv: minimum # of events for a ROI to count (11 default -- i.e., > 10)
%    printPath: if provided, will print to this path ...
%
function plotTreeScoreCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotTreeScoreCrossDays');
		return;
	end

  % dflts
  whiskerTags = {'c1','c2','c3'};
	plotsShown = [0 0 1];
	rangeR = [0.25 0.75];
	plotFeatures = [];
	featureColors = [];
	tbRootDir ='';
	inputTag = [];
	treeTag = [];
	scoreMethod = '';
	printPath = '';
	minNEv = 11;
	roiIds = [];
	sessions = 1:length(obj.sessions);

  % pull optional
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'roiIds')) ; roiIds = params.roiIds; end
	if (isfield(params, 'tbRootDir')) ; tbRootDir = params.tbRootDir; end
	if (isfield(params, 'inputTag')) ; inputTag = params.inputTag; end
	if (isfield(params, 'treeTag')) ; treeTag = params.treeTag; end
	if (isfield(params, 'scoreMethod')) ; scoreMethod = params.scoreMethod; end
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'sessions')) ; sessions = params.sessions; end
	if (isfield(params, 'plotFeatures')) ; plotFeatures = params.plotFeatures; end
	if (isfield(params, 'featureColors')) ; featureColors = params.featureColors; end
	if (isfield(params, 'rangeR')) ; rangeR = params.rangeR; end
	if (isfield(params, 'minNEv')) ; minNEv = params.minNEv; end
	if (isfield(params, 'printPath')) ; printPath = params.printPath; end

  % --- meat
	% call getTreeScores ...
	if (length(inputTag) > 0 && length(treeTag) > 0)
		obj.getTreeScores(tbRootDir, inputTag, treeTag, scoreMethod);
	end
  if (length(plotFeatures) == 0)
	  plotFeatures = 1:length(obj.sessions{sessions(1)}.treeFeatureList);
	end
	featureList = obj.sessions{sessions(1)}.treeFeatureList(plotFeatures);
	featureLabels = featureList;
	for f=1:length(featureList) ; featureLabels{f} = strrep(featureList{f},'_','-'); end

	% some prelims
  for s=1:length(sessions) ; si=sessions(s); sLabels{s} = obj.dateStr{si}(1:6); end
	sVec = nan*zeros(1,length(sessions));
	if (length(featureColors) == 0)
		featureColors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 0 1 1 ; 1 0 1 ; 1 1 1 ];
		if (size(featureColors,1) < length(featureList)) ; featureColors = jet(length(featureList)) ; end
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
	dataMat = nan*zeros(length(obj.roiIds), length(plotFeatures), length(obj.sessions));
	for s=1:length(sessions)
		si = sessions(s);
		pfi = 1:length(plotFeatures);
		vfi = [];
		for f=1:length(plotFeatures)
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

  % --- 1) ROI Matrix plot
  if (plotsShown(1))
    singleRoiMatrixCall(obj,dataMat, featureLabels, featureColors, rangeR(2), rangeR(1), sessions,'');
		if (length(printPath) > 0) ; 
			print(gcf, '-depsc2', [printPath filesep 'treeScore_' obj.mouseId '_megaMatrix.eps']);
		end
	end

	% --- 2) Single ROI line plots
	if (plotsShown(2))
	  figure ('Position', [100 100 400 length(roiIds)*100]); 
		xT = 2:2:2*length(sessions);
		for f=1:length(featureList) 
		  xVals{f} = xT;
		end

		for f=1:length(featureList)
		  sessVec{f} = sessions;
			sessIdxVec{f} = 1:length(sessions);
      for s=1:length(sessions)
			  si = sessions(s);
		    fi = find(strcmp(obj.sessions{si}.treeFeatureList, featureList{f}));
				if (length(fi) ~= 1)
				  sessVec{f} = setdiff(sessVec{f},si);
				  sessIdxVec{f} = setdiff(sessIdxVec{f},s);
				end
			end
		end

		for r=1:length(roiIds)  
		  ri = find(obj.roiIds == roiIds(r));
			fR = {};
		  for f=1:length(featureList)
			  fR{f} = sVec;
				fR{f}(sessIdxVec{f}) = squeeze(dataMat(ri, f, sessVec{f}));
			end

			subplot(length(roiIds),1,r);
			if (r == length(roiIds)) ; xlab = sLabels ; else ; xlab = {} ; end
			plot_multilines_with_error(xVals, fR, [], featureColors, featureLabels, xlab, ...
													 [], ':', [0 2*(length(sessions)+1) -0.2 1]);
			set(gca,'TickDir','out');
			set(gca,'XTick',[]);
			ylabel('R');
			title(['ROI # ' num2str(roiIds(r))]);
		end
		if (length(printPath) > 0) ; 
			print(gcf, '-depsc2', [printPath filesep 'treeScore_' obj.mouseId '_indiRois.eps']);
		end
	end

	% --- 3) 'ATARI' plot for each feature x cell
	if (plotsShown(3))
		figure('Position', [ 100 100 4*length(sessions)*length(featureLabels) 1000]);

    w = .95/length(featureList);
    for f=1:length(featureList)
			cmap = [linspace(0,featureColors(f,1),256)' linspace(0,featureColors(f,2),256)' linspace(0,featureColors(f,3),256)'];

			tMat = squeeze(dataMat(:,f,sessions)) ;
			tMat(find(isnan(tMat))) = 0;
			tMat= round((256/diff(rangeR))*(tMat-rangeR(1))); % so it is [0 256]
			tMat(find(tMat<= 0)) = 1;
			tMat(find(tMat> 256)) = 256;
			imMat = reshape(cmap(tMat,:), length(obj.roiIds), length(sessions), 3);

		  ax = subplot('Position',[(f-1)*w .05 w .9]);
      imshow(imMat, 'Parent', ax,'Border','tight');
		  title(featureLabels{f});
		end
		if (length(printPath) > 0) ; 
			print(gcf, '-depsc2', [printPath filesep 'treeScore_' obj.mouseId '_atari.eps']);
		end
  end


%
% pltos a single roiMatrix
%
function singleRoiMatrixCall(obj, dataMat, varLabel, varMaxColor, varMax, varMin, sessions, suppTitle)
	prmParams.dataMat = dataMat;
	prmParams.plotMode = 1;
	prmParams.varLabel = varLabel;
	prmParams.varMaxColor = varMaxColor;
	prmParams.varMax = varMax;
	prmParams.varMin = varMin;
	prmParams.sessions = sessions;
	obj.plotRoiMatrixCrossDays(prmParams);
	if (length(suppTitle) > 0)
		set(get(gca,'Title'), 'String', [get(get(gca,'Title'), 'String') ' ' suppTitle]);
	end
