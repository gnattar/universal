%
% SP May 2011
%
%
%  USAGE:
%
%    sA.plotPrefWhiskerCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    roiIds: rois to look @ ; must specify
%    whiskerTags: cell array of who to do
%    plotsShown: 1/0 means show/don't
%                (1): progression of whisker preference for individual ROIs
%                (2): FOV plot for all days, whiskers
%                (3): FOV plot averaged across all days
%                (4): color-based atari plot for whisker preference
%                (5): different touch parameters and their whisker preference
%    rangeAUC: [0.5 0.75] default ; color range for color plots
%    printPath: if provided, will print to this path ...
%
function plotPrefWhiskerCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotPrefWhiskerCrossDays');
		return;
	end

  % dflts
  whiskerTags = {'c1','c2','c3'};
	plotsShown = [0 0 1 1 0];
	rangeAUC = [0.5 0.75];
	printPath = '';

  % pull required
  roiIds = params.roiIds; % whick roi(s) to get nice plots on?

  % pull optional
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'rangeAUC')) ; rangeAUC = params.rangeAUC; end
	if (isfield(params, 'printPath')) ; printPath = params.printPath; end

  % --- meat
  for si=1:length(obj.sessions) ; sLabels{si} = obj.dateStr{si}(1:6); end
	sVec = nan*zeros(1,length(obj.sessions));
	wColors = [1 0 0 ; 0 1 0 ; 0 0 1];

	% --- 1) for select ROIs, plot progression of whiskerAndDirPref
	if (plotsShown(1))
		for r=1:length(roiIds)
			ri = find(obj.roiIds == roiIds(r));
			for w=1:length(whiskerTags)
				% blank stuff ...
				wPref{w} = sVec;
				wPrefCI{w} = [sVec ; sVec];
				x{w} =  (2:2:2*length(obj.sessions)) + (w-1)/3;
				for si=1:length(obj.sessions)
					wi = find(strcmp(obj.whiskerAndDirPref{si}.whiskerTags, whiskerTags{w}));
%wPref{w}(si) = obj.touchIndexMats{si}{9}(w,:);
					if (length(wi) > 0 ) %&& obj.whiskerAndDirPref{si}.nonDirectionalScores(wi, ri, 2) > 0.5) % exclude chance
						wPref{w}(si) = obj.whiskerAndDirPref{si}.nonDirectionalScores(wi, ri, 1);
						wPrefCI{w}(1,si) = obj.whiskerAndDirPref{si}.nonDirectionalScores(wi, ri, 2);
						wPrefCI{w}(2,si) = obj.whiskerAndDirPref{si}.nonDirectionalScores(wi, ri, 3);
					end
				end
			end

			figure;
			plot_multilines_with_error(x, wPref, wPrefCI, wColors, whiskerTags, sLabels, ...
													 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			set(gca,'TickDir','out');
			ylabel('AUC');
			title(['Whisker preference for ROI # ' num2str(roiIds(r))]);

			if (length(printPath) > 0) ; 
        print(gcf, '-depsc2', [printPath filesep 'prefWhisker_' obj.mouseId '_roi_' num2str(roiIds(r)) '.eps']);
			end
		end
	end

  % =============================================
	% build data mat -- used by 2, 3 & 4
	dataMat = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));
	for si=1:length(obj.sessions)
	  for w=1:length(whiskerTags)
%    dataMat(:,w,si) =  obj.touchIndexMats{9}{si}(w,:); % AUC from touchIndexMats
 % PProd     dataMat(:,w,si) =  obj.touchIndexMats{1}{si}(w,:);
		  wi = find(strcmp(obj.whiskerAndDirPref{si}.whiskerTags, whiskerTags{w}));
		  if (length(wi) > 0 )%&& obj.whiskerAndDirPref{si}.nonDirectionalScores(wi, ri, 2) > 0.5) % exclude chance
			  dataMat(:,w,si) = obj.whiskerAndDirPref{si}.nonDirectionalScores(wi,:, 1);
			  inval = find(obj.whiskerAndDirPref{si}.nonDirectionalScores(wi,:, w) < 0.5);
				dataMat(inval,w,si) = 0.5;
			end
		end
	end

  % =============================================

	% --- 2) for ALL ROIs x whiskers, plot FOV
	% plot 
	if (plotsShown(2))
		prmParams.dataMat = dataMat;
		prmParams.plotMode = 1;
		prmParams.varLabel = whiskerTags;
		prmParams.varMaxColor = wColors;
		prmParams.varMax = rangeAUC(2)*[1 1 1];
		prmParams.varMin = rangeAUC(1)*[1 1 1];
		obj.plotRoiMatrixCrossDays(prmParams);
			if (length(printPath) > 0) ; 
        print(gcf, '-depsc2', [printPath filesep 'prefWhisker_' obj.mouseId '_fullFOVMatrix.eps']);
			end
	end

	
	% --- 3) for ALL ROIs x whiskers, plot FOV average x-days
	if (plotsShown(3))
	%	sDataMat = nanmax(dataMat,[],3)
		sDataMat = nanmean(dataMat,3);
%		nW = ceil(sqrt(length(whiskerTags)));
		figure('Position', [100 100 900 300]);
		for w=1:length(whiskerTags)
%			axRef = subplot(nW,nW,w);
			axRef = subplot(1,3,w);
			cmap = [linspace(0,wColors(w,1),256)' linspace(0,wColors(w,2),256)' linspace(0,wColors(w,3),256)'];
	%	  obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),[0 0.02],axRef,0);
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeAUC,axRef,0);
			title(whiskerTags{w});
		end

		if (length(printPath) > 0) ; 
			print(gcf, '-depsc2', [printPath filesep 'prefWhisker_' obj.mouseId '_avgFOV.eps']);
		end

  end

	% --- 4) for all whiskers, ROIs, score across days in color thingy
  if (plotsShown(4))
	  if (length(whiskerTags) ~= 3) ; disp('plotPrefWhiskerCrossDays::only for c1 c2 c3'); end
	  imMat1 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat2 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat3 = zeros(length(obj.roiIds), length(obj.sessions), 3);
		imMat1(:,:,1) = squeeze(dataMat(:,1,:));
		imMat2(:,:,2) = squeeze(dataMat(:,2,:));
		imMat3(:,:,3) = squeeze(dataMat(:,3,:));
		imMat1(find(isnan(imMat1))) = 0; imMat1(find(imMat1 < 0.5)) = 0;
		imMat2(find(isnan(imMat2))) = 0; imMat2(find(imMat2 < 0.5)) = 0;
		imMat3(find(isnan(imMat3))) = 0; imMat3(find(imMat3 < 0.5)) = 0;
		imMat1 = (1/diff(rangeAUC))*(imMat1 -rangeAUC(1)); % so it is [0 1]
		imMat2 = (1/diff(rangeAUC))*(imMat2 -rangeAUC(1)); % so it is [0 1]
		imMat3 = (1/diff(rangeAUC))*(imMat3 -rangeAUC(1)); % so it is [0 1]
		figure('Position', [ 100 100 200 800]);
		ax = subplot('Position',[0.01 .05 .3 .9]);
    imshow(imMat1, 'Parent', ax,'Border','tight');
		title('c1');
		ax = subplot('Position',[0.34 .05 .3 .9]);
    imshow(imMat2, 'Parent', ax,'Border','tight');
		title('c2');
		ax = subplot('Position',[0.67 .05 .3 .9]);
    imshow(imMat3, 'Parent', ax,'Border','tight');
		title('c3');
		
		if (length(printPath) > 0) ; 
			print(gcf, '-depsc2', [printPath filesep 'prefWhisker_' obj.mouseId '_roi_atari.eps']);
		end
	end


	% --- 5) compare touch indices for various methods for key ROIs
	if (plotsShown(5))
		for r=1:length(roiIds)
			ri = find(obj.roiIds == roiIds(r));
			figure;
			subplot(3,3,1);
			singleMethodTouchScore(obj, ri, whiskerTags, 1, [-.03 .1], sLabels, wColors, sVec);
			subplot(3,3,2);
			singleMethodTouchScore(obj, ri, whiskerTags, 3, [-1 1], {}, wColors, sVec);
			subplot(3,3,3);
			singleMethodTouchScore(obj, ri, whiskerTags, 5, [-1 8], {}, wColors, sVec);
			subplot(3,3,4);
			singleMethodTouchScore(obj, ri, whiskerTags, 7, [-.1 .5], {}, wColors, sVec);
			subplot(3,3,5);
			singleMethodTouchScore(obj, ri, whiskerTags, 9, [0.4 1], {}, wColors, sVec);

			if (length(printPath) > 0) ; 
				print(gcf, '-depsc2', [printPath filesep 'prefWhisker_' obj.mouseId '_roi_' num2str(roiIds(r)) '_methods.eps']);
			end

		end
  end


%
% plots a single method panel
% 
function singleMethodTouchScore(obj, ri, whiskerTags, methodIdx, valRange, sLabels, wColors, sVec)

	for w=1:length(whiskerTags)
		% blank stuff ...
		wPref{w} = sVec;
		x{w} =  (2:2:2*length(obj.sessions)) ;
		for si=1:length(obj.sessions)
			wPref{w}(si) = obj.touchIndexMats{methodIdx}{si}(w,ri);
		end
	end

	plot_multilines_with_error(x, wPref, {}, wColors, whiskerTags, sLabels, ...
											 [], '', [0 2*(length(obj.sessions)+1) valRange(1) valRange(2)]);
	set(gca,'TickDir','out');
	ylabel(obj.touchIndexMatId{methodIdx});
	title(['ROI # ' num2str(obj.roiIds(ri)) ' pref']);


