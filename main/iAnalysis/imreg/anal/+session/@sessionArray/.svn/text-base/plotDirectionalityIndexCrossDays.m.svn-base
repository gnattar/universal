%
% SP May 2011
%
%  This will plot the directionality index for all/some ROIs across days in various
%   ways.
%
%  USAGE:
%
%    sA.plotDirectionalityIndexCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    roiIds: rois to look @ ; must specify
%    whiskerTags: cell array of who to do
%    plotsShown: 1/0 means show/don't
%                (1): progression of DI for individual ROIs
%                (2): FOV plot for all days, whiskers showing DI and pro v ret
%                (3): same as (2) but average for all days
%                (4): color-based atari plot for directional preference
%    rangeAUC: [0.5 0.75] default ; color range for plots showing raw AUC
%    rangeDI: [0.5 0.75] default ; color range for plots showing raw DI
%    printPath: if provided, will print to this path ...
%
function plotDirectionalityIndexCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotDirectionalityIndexCrossDays');
		return;
	end

  % dflts
  whiskerTags = {'c1','c2','c3'};
	plotsShown = [0 0 1 1];
	rangeAUC = [0.5 0.75];
	rangeDI = [-1 1];
	printPath = '';

  % pull required
  roiIds = params.roiIds; % whick roi(s) to get nice plots on?

  % pull optional
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'rangeAUC')) ; rangeAUC = params.rangeAUC; end
	if (isfield(params, 'rangeDI')) ; rangeDI = params.rangeDI; end
	if (isfield(params, 'printPath')) ; printPath = params.printPath; end

  % --- meat
  for si=1:length(obj.sessions) ; sLabels{si} = obj.dateStr{si}(1:6); end
	sVec = nan*zeros(1,length(obj.sessions));
	proReColors = [1 0 0 ; 0.5 0 0 ; 0 1 0 ; 0 0.5 0 ; 0 0 1 ; 0 0 0.5];
	wColors = [1 0 0 ; 0 1 0 ; 0 0 1];
	for w=1:length(whiskerTags)
	  prWhiskerTags{2*w-1} = ['Pro '  whiskerTags{w}];
	  prWhiskerTags{2*w} = ['Ret '  whiskerTags{w}];
	end

	% --- 1) for select ROIs, plot progression of whiskerAndDirPref
	if (plotsShown(1))
		for r=1:length(roiIds)
			ri = find(obj.roiIds == roiIds(r));
			for w=1:length(whiskerTags)
				% blank stuff ...
				wDir{2*w-1} = sVec;
				wDir{2*w} = sVec;
				wDirCI{2*w-1} = [sVec ; sVec];
				wDirCI{2*w} = [sVec ; sVec];
				wDI{w} = sVec;
				xDI{w} =  (2:2:2*length(obj.sessions)) + (w-1)/3;
				xDir{2*w} =  (2:2:2*length(obj.sessions)) + ((2*w)-1)/7;
				xDir{2*w-1} =  (2:2:2*length(obj.sessions)) + ((2*w-1)-1)/7;

				wDIBase{w} = sVec;
				wDIBaseCI{w} = [sVec ; sVec];
				wDIKappaNorm{w} = sVec;
				wDIKappaNormCI{w} = [sVec ; sVec];
				wDIThetaNorm{w} = sVec;
				wDIThetaNormCI{w} = [sVec ; sVec];
				wDIKappaThetaNorm{w} = sVec;
				wDIKappaThetaNormCI{w} = [sVec ; sVec];
				for si=1:length(obj.sessions)
					wi = find(strcmp(obj.whiskerAndDirPref{si}.whiskerTags, whiskerTags{w}));
					if (length(wi) > 0 ) 
					  % protraction
						wDir{2*w-1}(si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi-1, ri, 1);
						wDirCI{2*w-1}(1,si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi-1, ri, 2);
						wDirCI{2*w-1}(2,si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi-1, ri, 3);

						% retraction
						wDir{2*w}(si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi, ri, 1);
						wDirCI{2*w}(1,si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi, ri, 2);
						wDirCI{2*w}(2,si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi, ri, 3);

						% compute directionality index ...
						wDI{w}(si) = 2*(wDir{2*w-1}(si) -	wDir{2*w}(si) );

						% strip insigs
						if (nanmin(wDirCI{2*w-1}(:,si)) < nanmax(wDirCI{2*w}(:,si)) && wDI{w}(si) > 0) ; wDI{w}(si) = 0 ; end
						if (nanmax(wDirCI{2*w-1}(:,si)) > nanmin(wDirCI{2*w}(:,si)) && wDI{w}(si) < 0) ; wDI{w}(si) = 0 ; end

						% mode DIs ...
						if (length( obj.whiskerAndDirPref{si}.dirAUC) >= length(whiskerTags) && ...
						    length(obj.whiskerAndDirPref{si}.dirAUC{wi}) > 0)
							wDIBase{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCBase(ri); 
							wDIBaseCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCBaseCI(:,ri);
							wDIKappaNorm{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaNorm(ri); 
							wDIKappaNormCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaNormCI(:,ri);
							wDIThetaNorm{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCThetaNorm(ri); 
							wDIThetaNormCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCThetaNormCI(:,ri);
							wDIKappaThetaNorm{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaThetaNorm(ri); 
							wDIKappaThetaNormCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaThetaNormCI(:,ri);
						end
					end
				end
			end

			figure;
			subplot(2,1,1);
			plot_multilines_with_error(xDir, wDir, wDirCI, proReColors, prWhiskerTags, {}, ...
													 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			set(gca,'TickDir','out');
			ylabel('AUC');
			title(['Pro vs. re raw for ROI # ' num2str(roiIds(r))]);

			subplot(2,1,2);
			plot_multilines_with_error(xDI, wDI, {}, wColors, whiskerTags, sLabels, ...
													 [], '', [0 2*(length(obj.sessions)+1) -1.5 1]);
			set(gca,'TickDir','out');
			plot([0 2*(length(obj.sessions)+1)], [0 0], 'k:');
			ylabel('DI ([Pro-Re] x 2)');
			title(['Directionality index for ROI # ' num2str(roiIds(r))]);

			if (length(printPath) > 0) ; 
        print(gcf, '-depsc2', [printPath filesep 'dirPref_' obj.mouseId '_roi_' num2str(roiIds(r)) '.eps']);
			end

			figure ; 
			subplot(4,1,1);
			plot_multilines_with_error(xDI, wDIBase, wDIBaseCI, wColors, whiskerTags, {}, ...
													 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			set(gca,'TickDir','out');
			plot([0 2*(length(obj.sessions)+1)], [0 0], 'k:');
			ylabel('AUC Pro vs. Ret');
			title(['Directional selectivity for ROI # ' num2str(roiIds(r))]);

			subplot(4,1,2);
			plot_multilines_with_error(xDI, wDIKappaNorm, wDIKappaNormCI, wColors, whiskerTags, {}, ...
													 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			set(gca,'TickDir','out');
			plot([0 2*(length(obj.sessions)+1)], [0 0], 'k:');
			ylabel('AUC Pro vs. Ret');
			title(['Kappa normalized']);

			subplot(4,1,3);
			plot_multilines_with_error(xDI, wDIThetaNorm, wDIThetaNormCI, wColors, whiskerTags, {}, ...
													 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			set(gca,'TickDir','out');
			plot([0 2*(length(obj.sessions)+1)], [0 0], 'k:');
			ylabel('AUC Pro vs. Ret');
			title(['Theta normalized']);

			subplot(4,1,4);
			plot_multilines_with_error(xDI, wDIKappaThetaNorm, wDIKappaThetaNormCI, wColors, whiskerTags, sLabels, ...
													 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			set(gca,'TickDir','out');
			plot([0 2*(length(obj.sessions)+1)], [0 0], 'k:');
			ylabel('AUC Pro vs. Ret');
			title(['Kappa & Theta normalized']);

			if (length(printPath) > 0) ; 
        print(gcf, '-depsc2', [printPath filesep 'dirPrefNormd_' obj.mouseId '_roi_' num2str(roiIds(r)) '.eps']);
			end

		end
	end

  % =============================================
	% build data matrices -- used by 2, 3 & 4
  dataMat = nan*zeros(length(obj.roiIds), 2*length(whiskerTags), length(obj.sessions));
	DIBasicMat = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));
	AUCDIBase = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));
	AUCDIKappaNorm = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));
	AUCDIThetaNorm = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));
	AUCDIKappaThetaNorm = nan*zeros(length(obj.roiIds), length(whiskerTags), length(obj.sessions));

	for si=1:length(obj.sessions)
	  for w=1:length(whiskerTags)
		  wi = find(strcmp(obj.whiskerAndDirPref{si}.whiskerTags, whiskerTags{w}));
		  if (length(wi) > 0 )%&& obj.whiskerAndDirPref{si}.nonDirectionalScores(wi, ri, 2) > 0.5) % exclude chance
        dataMat(:,2*w-1,si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi-1, :, 1);
        dataMat(:,2*w,si) = obj.whiskerAndDirPref{si}.directionalScores(2*wi, :, 1);
			  
        DIBasicMat(:,w,si) =  ...
				  2*(obj.whiskerAndDirPref{si}.directionalScores(2*wi-1, :, 1) -  obj.whiskerAndDirPref{si}.directionalScores(2*wi, :, 1));
%%%%% strip insigs
        
				% AUC Based 'DI's
	  		if (length( obj.whiskerAndDirPref{si}.dirAUC) >= length(whiskerTags) && ...
				    isstruct(obj.whiskerAndDirPref{si}.dirAUC{wi}))
			    AUCDIBase(:,w,si) =  obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCBase; 
					inval = find(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCBaseCI(1,:) < 0.5);
%					inval = union(inval,find(diff(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCBaseCI(1,:)) == 0));
					AUCDIBase(inval,w,si) = 0.5;
			    AUCDIKappaNorm(:,w,si) =  obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaNorm; 
					inval = find(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaNormCI(1,:) < 0.5);
%					inval = union(inval,find(diff(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaNormCI(1,:)) == 0));
					AUCDIKappaNorm(inval,w,si) = 0.5;
			    AUCDIThetaNorm(:,w,si) =  obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCThetaNorm; 
					inval = find(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCThetaNormCI(1,:) < 0.5);
%					inval = union(inval,find(diff(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCThetaNormCI(1,:)) == 0));
					AUCDIThetaNorm(inval,w,si) = 0.5;
			    AUCDIKappaThetaNorm(:,w,si) =  obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaThetaNorm; 
					inval = find(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaThetaNormCI(1,:) < 0.5);
%					inval = union(inval,find(diff(obj.whiskerAndDirPref{si}.dirAUC{wi}.AUCKappaThetaNormCI(1,:)) == 0));
					AUCDIKappaThetaNorm(inval,w,si) = 0.5;
%							wDIBase{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCBase(ri); 
%							wDIBaseCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCBaseCI(:,ri);
%							wDIKappaNorm{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCKappaNorm(ri); 
%							wDIKappaNormCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCKappaNormCI(:,ri);
%							wDIThetaNorm{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCThetaNorm(ri); 
%							wDIThetaNormCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCThetaNormCI(:,ri);
%							wDIKappaThetaNorm{w}(si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCKappaThetaNorm(ri); 
%							wDIKappaThetaNormCI{w}(:,si) = obj.whiskerAndDirPref{si}.dirAUC{w}.AUCKappaThetaNormCI(:,ri);
				end
			end
		end
	end

  % =============================================

	% --- 2) for ALL ROIs x whiskers, plot FOV
	% plot 
	if (plotsShown(2))

    singleRoiMatrixCall(obj, dataMat, prWhiskerTags, proReColors, rangeAUC(2)*[1 1 1 1 1 1], rangeAUC(1)*[1 1 1 1 1 1] , '')

		% basic DI
    singleRoiMatrixCall(obj, DIBasicMat, whiskerTags, wColors, rangeDI(2)*[1 1 1 ], rangeDI(1)*[1 1 1] , 'DI')
		
		% AUC "DIs"
    singleRoiMatrixCall(obj, AUCDIBase, whiskerTags, wColors, rangeAUC(2)*[1 1 1 ], rangeAUC(1)*[1 1 1] , 'AUC Base DI')
    singleRoiMatrixCall(obj, AUCDIKappaNorm, whiskerTags, wColors, rangeAUC(2)*[1 1 1 ], rangeAUC(1)*[1 1 1] , 'AUC KappaNorm DI')
    singleRoiMatrixCall(obj, AUCDIThetaNorm, whiskerTags, wColors, rangeAUC(2)*[1 1 1 ], rangeAUC(1)*[1 1 1] , 'AUC ThetaNorm DI')
    singleRoiMatrixCall(obj, AUCDIKappaThetaNorm, whiskerTags, wColors, rangeAUC(2)*[1 1 1 ], rangeAUC(1)*[1 1 1] , 'AUC KappaThetaNorm DI')
	end

	
	% --- 3) for ALL ROIs x whiskers, plot FOV average x-days
	if (plotsShown(3))
	%	sDataMat = nanmax(dataMat,[],3)
		sDataMat = nanmean(dataMat,3);
		nW = ceil(sqrt(length(prWhiskerTags)));
		figure;
		for w=1:length(prWhiskerTags)
			axRef = subplot(3,2,w);
			cmap = [linspace(0,proReColors(w,1),256)' linspace(0,proReColors(w,2),256)' linspace(0,proReColors(w,3),256)'];
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeAUC,axRef,0);
			title(prWhiskerTags{w});
		end
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_FOV_dirScore_' obj.mouseId '.eps']);
		end


		% discrim
	%	sDataMat = nanmax(dataMat,[],3)
		sDataMat = nanmean(DIBasicMat,3);
		nW = ceil(sqrt(length(whiskerTags)));
		figure;
		cmap1 = [linspace(1,0,128)' linspace(0,0,128)' linspace(1,0,128)'];
		cmap2 = [linspace(0,0,128)' linspace(0,1,128)' linspace(0,1,128)'];
		cmap = [cmap1 ; cmap2];
		for w=1:length(whiskerTags)
			axRef = subplot(nW,nW,w);
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeDI,axRef,1);
			title(whiskerTags{w});
		end
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_FOV_DIBasic_' obj.mouseId '.eps']);
		end

		% AUC Base
		sDataMat = nanmean(AUCDIBase,3);
		nW = ceil(sqrt(length(whiskerTags)));
		figure;
		for w=1:length(whiskerTags)
			axRef = subplot(nW,nW,w);
			cmap = [linspace(0,wColors(w,1),256)' linspace(0,wColors(w,2),256)' linspace(0,wColors(w,3),256)'];
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeAUC,axRef,0);
			title([whiskerTags{w} ' AUC Base'] );
		end
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_FOV_AUCBase_' obj.mouseId '.eps']);
		end

		% AUC KappaNorm
		sDataMat = nanmean(AUCDIKappaNorm,3);
		nW = ceil(sqrt(length(whiskerTags)));
		figure;
		for w=1:length(whiskerTags)
			axRef = subplot(nW,nW,w);
			cmap = [linspace(0,wColors(w,1),256)' linspace(0,wColors(w,2),256)' linspace(0,wColors(w,3),256)'];
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeAUC,axRef,0);
			title([whiskerTags{w} ' AUC KappaNorm'] );
		end
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_FOV_AUCKNorm_' obj.mouseId '.eps']);
		end

		% AUC ThetaNorm
		sDataMat = nanmean(AUCDIThetaNorm,3);
		nW = ceil(sqrt(length(whiskerTags)));
		figure;
		for w=1:length(whiskerTags)
			axRef = subplot(nW,nW,w);
			cmap = [linspace(0,wColors(w,1),256)' linspace(0,wColors(w,2),256)' linspace(0,wColors(w,3),256)'];
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeAUC,axRef,0);
			title([whiskerTags{w} ' AUC ThetaNorm'] );
		end
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_FOV_AUCTNorm_' obj.mouseId '.eps']);
		end

		% AUC KappaThetaNorm
		sDataMat = nanmean(AUCDIKappaThetaNorm,3);
		nW = ceil(sqrt(length(whiskerTags)));
		figure;
		for w=1:length(whiskerTags)
			axRef = subplot(nW,nW,w);
			cmap = [linspace(0,wColors(w,1),256)' linspace(0,wColors(w,2),256)' linspace(0,wColors(w,3),256)'];
			obj.sessions{1}.plotColorRois([],[],[],cmap,sDataMat(:,w),rangeAUC,axRef,0);
			title([whiskerTags{w} ' AUC KappaThetaNorm'] );
		end
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_FOV_AUCTNorm_' obj.mouseId '.eps']);
		end
  end

	% --- 4) for all whiskers, ROIs, score across days in color thingy
  if (plotsShown(4))

	  % regular AUC score
	  if (length(whiskerTags) ~= 3) ; disp('plotDirectionalityIndexCrossDays::only for c1 c2 c3'); end
	  imMat1 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat2 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat3 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat4 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat5 = zeros(length(obj.roiIds), length(obj.sessions), 3);
	  imMat6 = zeros(length(obj.roiIds), length(obj.sessions), 3);
		imMat1(:,:,1) = squeeze(dataMat(:,1,:));
		imMat2(:,:,1) = squeeze(dataMat(:,2,:));
		imMat3(:,:,2) = squeeze(dataMat(:,3,:));
		imMat4(:,:,2) = squeeze(dataMat(:,4,:));
		imMat5(:,:,3) = squeeze(dataMat(:,5,:));
		imMat6(:,:,3) = squeeze(dataMat(:,6,:));
		imMat1(find(isnan(imMat1))) = 0; imMat1(find(imMat1 < 0.5)) = 0;
		imMat2(find(isnan(imMat2))) = 0; imMat2(find(imMat2 < 0.5)) = 0;
		imMat3(find(isnan(imMat3))) = 0; imMat3(find(imMat3 < 0.5)) = 0;
		imMat4(find(isnan(imMat4))) = 0; imMat4(find(imMat4 < 0.5)) = 0;
		imMat5(find(isnan(imMat5))) = 0; imMat5(find(imMat5 < 0.5)) = 0;
		imMat6(find(isnan(imMat6))) = 0; imMat6(find(imMat6 < 0.5)) = 0;
		imMat1 = (1/diff(rangeAUC))*(imMat1 -rangeAUC(1)); % so it is [0 1]
		imMat2 = (1/diff(rangeAUC))*(imMat2 -rangeAUC(1)); % so it is [0 1]
		imMat3 = (1/diff(rangeAUC))*(imMat3 -rangeAUC(1)); % so it is [0 1]
		imMat4 = (1/diff(rangeAUC))*(imMat4 -rangeAUC(1)); % so it is [0 1]
		imMat5 = (1/diff(rangeAUC))*(imMat5 -rangeAUC(1)); % so it is [0 1]
		imMat6 = (1/diff(rangeAUC))*(imMat6 -rangeAUC(1)); % so it is [0 1]
		figure('Position', [ 100 100 400 800]);
		ax = subplot('Position',[0.01 .05 .15 .9]);
    imshow(imMat1, 'Parent', ax,'Border','tight');
		title('c1 Pro');
		ax = subplot('Position',[0.16 .05 .15 .9]);
    imshow(imMat2, 'Parent', ax,'Border','tight');
		title('c1 Ret');
		ax = subplot('Position',[0.34 .05 .15 .9]);
    imshow(imMat3, 'Parent', ax,'Border','tight');
		title('c2 Pro');
		ax = subplot('Position',[0.49 .05 .15 .9]);
    imshow(imMat4, 'Parent', ax,'Border','tight');
		title('c2 Ret');
		ax = subplot('Position',[0.67 .05 .15 .9]);
    imshow(imMat5, 'Parent', ax,'Border','tight');
		title('c3 Pro');
		ax = subplot('Position',[0.82 .05 .15 .9]);
    imshow(imMat6, 'Parent', ax,'Border','tight');
		title('c3 Ret');
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_atari_base_AUC_' obj.mouseId '.eps']);
		end

		% DI --> want to go [ret] 101 to 011 [pro] 
		cmap1 = [linspace(1,0,128)' linspace(0,0,128)' linspace(1,0,128)'];
		cmap2 = [linspace(0,0,128)' linspace(0,1,128)' linspace(0,1,128)'];
		cmap = [cmap1 ; cmap2];

		tMat = squeeze(DIBasicMat(:,1,:)); %c1 
		tMat(find(isnan(tMat))) = 0;
		tMat= round((256/diff(rangeDI))*(tMat-rangeDI(1))); % so it is [0 256]
		tMat(find(tMat<= 0)) = 1;
		tMat(find(tMat> 256)) = 256;
		imMat1 = reshape(cmap(tMat,:), length(obj.roiIds), length(obj.sessions), 3);
		
		tMat = squeeze(DIBasicMat(:,2,:)); %c2
		tMat(find(isnan(tMat))) = 0;
		tMat= round((256/diff(rangeDI))*(tMat-rangeDI(1))); % so it is [0 256]
		tMat(find(tMat<= 0)) = 1;
		tMat(find(tMat> 256)) = 256;
		imMat2 = reshape(cmap(tMat,:), length(obj.roiIds), length(obj.sessions), 3);

		tMat = squeeze(DIBasicMat(:,3,:)); %c3
		tMat(find(isnan(tMat))) = 0;
		tMat= round((256/diff(rangeDI))*(tMat-rangeDI(1))); % so it is [0 256]
		tMat(find(tMat<= 0)) = 1;
		tMat(find(tMat> 256)) = 256;
		imMat3 = reshape(cmap(tMat,:), length(obj.roiIds), length(obj.sessions), 3);
		

		figure('Position', [ 100 100 200 800]);
		ax = subplot('Position',[0.01 .05 .3 .9]);
    imshow(imMat1, 'Parent', ax,'Border','tight');
		title('c1');

		ax = subplot('Position',[0.34 .05 .3 .9]);
    imshow(imMat2, 'Parent', ax,'Border','tight');
		title('c2 DI');

		ax = subplot('Position',[0.67 .05 .3 .9]);
    imshow(imMat3, 'Parent', ax,'Border','tight');
		title('c3');
		if (length(printPath) > 0) ; 
       print(gcf, '-depsc2', [printPath filesep 'dir_atari_DI_' obj.mouseId '.eps']);
		end

		% AUC 'DI'
    singleAUCDIAtariPlot(obj, printPath, AUCDIBase, rangeAUC, 'Base AUC');
    singleAUCDIAtariPlot(obj, printPath, AUCDIKappaNorm, rangeAUC, 'KappaNorm AUC');
    singleAUCDIAtariPlot(obj, printPath, AUCDIThetaNorm, rangeAUC, 'ThetaNorm AUC');
    singleAUCDIAtariPlot(obj, printPath, AUCDIKappaThetaNorm, rangeAUC, 'KappaThetaNorm AUC');
	end

%
% pltos a single roiMatrix
%
function singleRoiMatrixCall(obj, dataMat, varLabel, varMaxColor, varMax, varMin, suppTitle)
	prmParams.dataMat = dataMat;
	prmParams.plotMode = 1;
	prmParams.varLabel = varLabel;
	prmParams.varMaxColor = varMaxColor;
	prmParams.varMax = varMax;
	prmParams.varMin = varMin;
	obj.plotRoiMatrixCrossDays(prmParams);
	if (length(suppTitle) > 0)
		set(get(gca,'Title'), 'String', [get(get(gca,'Title'), 'String') ' ' suppTitle]);
	end


%
% for a single DI atari plot
% 
function singleAUCDIAtariPlot(obj,printPath, dataMat, rangeAUC, titleTag)
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
	title(['c2 ' titleTag]);
	ax = subplot('Position',[0.67 .05 .3 .9]);
	imshow(imMat3, 'Parent', ax,'Border','tight');
	title('c3');

	if (length(printPath) > 0) ; 
    print(gcf, '-depsc2', [printPath filesep 'dir_atari_' strrep(titleTag, ' ', '_') '_' obj.mouseId '.eps']);
	end
