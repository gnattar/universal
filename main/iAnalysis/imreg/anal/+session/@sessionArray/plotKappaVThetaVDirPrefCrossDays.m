%
% SP May 2011
%
% This will plot obj.roiKappaThetaDirPref's results, which tell you, whenever
%  possible, cell's ability to discriminate via df/f for Kappa, Theta, and
%  direction conditioned on one or both of the other two variables.
%
%  USAGE:
%
%    obj.plotKappaVThetaVDirPrefCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    roiIds: rois to look @ ; must specify
%    whiskerTags: cell array of who to do
%    plotsShown: 1/0 to show/not
%                (1) evolution over time for all whiskers, rois ; 4 panels/wh-roi
%                (2) same as 1 but for max AUC vars
%    printPath: if provided, will print to this path ...
%
function plotKappaVThetaVDirPrefCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotKappaVThetaVDirPrefCrossDays');
		return;
	end

	% dflts
	whiskerTags = {'c1','c2','c3'};
	plotsShown = [1 1 1];
	printPath = '';

  % pull required
  roiIds = params.roiIds; 

  % pull inptus
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end
	if (isfield(params, 'plotsShown')) ; plotsShown = params.plotsShown; end
	if (isfield(params, 'printPath')) ; printPath = params.printPath; end

  % --- 1) for each whisker, a plot of conditionals across time
  if (plotsShown(1))
		% loop rois
		sVec = nan*ones(1,length(obj.sessions));
		sVecCI = nan*ones(2,length(obj.sessions));
		baseX =  (2:2:2*length(obj.sessions));
		kappaLabels = {'base'};
		direcLabels = {'base'};
		colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 0 1 1 ; 1 0.5 0 ; 1 0 1 ; 0 0 0];
		for si=1:length(obj.sessions) ; sLabels{si} = obj.dateStr{si}(1:6); end

		% setup var names
		thetaVars = {'AUCBase', 'AUCKappaNorm', 'AUCRet', 'AUCPro', 'AUCRetKappaNorm', 'AUCProKappaNorm'};
		for v=1:length(thetaVars) ; thetaLabels{v} = strrep(thetaVars{v},'AUC',''); thetaX{v} = baseX + (v-3)/7; end
		kappaVars = {'AUCBase', 'AUCThetaNorm', 'AUCRet', 'AUCPro', 'AUCRetThetaNorm', 'AUCProThetaNorm'};
		for v=1:length(kappaVars) ; kappaLabels{v} = strrep(kappaVars{v},'AUC',''); kappaX{v} = baseX + (v-3)/7; end
		direcVars = {'AUCBase', 'AUCKappaNorm', 'AUCThetaNorm', 'AUCKappaThetaNorm'};
		for v=1:length(direcVars) ; direcLabels{v} = strrep(direcVars{v},'AUC',''); direcX{v} = baseX + (v-3)/7; end

		for r=1:length(roiIds)
			ri = find(obj.roiIds == roiIds(r));

			rktdp = obj.roiKappaThetaDirPref{ri};

			% loop whiskerse
			figure ('Position', [100 100 800 400]);
			for w=1:length(whiskerTags)
				wi = find(strcmp(obj.whiskerTag , whiskerTags{w}));
		
				% blank the data
				for v=1:length(thetaVars) ; theta{v} = sVec ; thetaCI{v} = sVecCI ; end
				for v=1:length(kappaVars) ; kappa{v} = sVec ; kappaCI{v} = sVecCI ; end
				for v=1:length(direcVars) ; direc{v} = sVec ; direcCI{v} = sVecCI ; end

				% loop sessions to gather data
				for si=1:length(obj.sessions)
					if (length(rktdp{si}{wi}) > 0)
						for v=1:length(thetaVars)
							theta{v}(si) = eval(['rktdp{si}{wi}.thetaAUC.' thetaVars{v}]);
							thetaCI{v}(:,si) = eval(['rktdp{si}{wi}.thetaAUC.' thetaVars{v} 'CI']);
						end
						for v=1:length(kappaVars)
							kappa{v}(si) = eval(['rktdp{si}{wi}.kappaAUC.' kappaVars{v}]);
							kappaCI{v}(:,si) = eval(['rktdp{si}{wi}.kappaAUC.' kappaVars{v} 'CI']);
						end
						for v=1:length(direcVars)
							direc{v}(si) = eval(['rktdp{si}{wi}.dirAUC.' direcVars{v}]);
							direcCI{v}(:,si) = eval(['rktdp{si}{wi}.dirAUC.' direcVars{v} 'CI']);
						end
					end
				end
				
				% figure stuff
				wY = .05;
				wX = .05 + .3*(w-1);

				% plot this set
				subplot('Position', [wX wY+.6 .29 .25]);
				plot_multilines_with_error(kappaX, kappa, kappaCI, colors, kappaLabels, {}, ...
														 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
				set(gca,'TickDir','out');
				title([whiskerTags{w} ' Kappa statistics ROI ' num2str(roiIds(r)) ]);
				plot([0 2*(length(obj.sessions)+1)], [0.5 0.5], 'k:');			
				if (w > 1) ; set(gca,'YTick',[]); end
				set(gca,'XTick',[]);
				
				subplot('Position', [wX wY+.3 .29 .25]);
				plot_multilines_with_error(thetaX, theta, thetaCI, colors, thetaLabels, {}, ...
														 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
				set(gca,'TickDir','out');
				title([whiskerTags{w} ' Theta statistics ROI ' num2str(roiIds(r)) ]);
				plot([0 2*(length(obj.sessions)+1)], [0.5 0.5], 'k:');			
				if( w == 1);		ylabel('AUC (dff binwise)'); end
				if (w > 1) ; set(gca,'YTick',[]); end
				set(gca,'XTick',[]);
				
				subplot('Position', [wX wY .29 .25]);
				labels = {} ; if (w == 1) ; labels = sLabels ; end
				plot_multilines_with_error(direcX, direc, direcCI, colors, direcLabels, labels, ...
														 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
				set(gca,'TickDir','out');
				title([whiskerTags{w} ' Direction statistics ROI ' num2str(roiIds(r)) ]);
				plot([0 2*(length(obj.sessions)+1)], [0.5 0.5], 'k:');			
				if (w > 1) ; set(gca,'YTick',[]); end
				set(gca,'XTick',[]);
			end

			if (length(printPath) > 0) ; 
        print(gcf, '-depsc2', [printPath filesep 'kvtvp_' obj.mouseId '_roi_' num2str(roiIds(r)) '_meanAUC.eps']);
			end
		end
  end


  % --- 2) for each whisker, a plot of conditionals across time with MAX AUC
  if (plotsShown(2))
		% loop rois
		sVec = nan*ones(1,length(obj.sessions));
		sVecCI = nan*ones(2,length(obj.sessions));
		baseX =  (2:2:2*length(obj.sessions));
		kappaLabels = {'base'};
		direcLabels = {'base'};
		colors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 0 1 1 ; 1 0.5 0 ; 1 0 1 ; 0 0 0];
		for si=1:length(obj.sessions) ; sLabels{si} = obj.dateStr{si}(1:6); end

		% setup var names
		thetaVars = {'AUCMaxBase', 'AUCMaxKappaNorm', 'AUCMaxRet', 'AUCMaxPro', 'AUCMaxRetKappaNorm', 'AUCMaxProKappaNorm'};
		for v=1:length(thetaVars) ; thetaLabels{v} = strrep(thetaVars{v},'AUCMax',''); thetaX{v} = baseX + (v-3)/7; end
		kappaVars = {'AUCMaxBase', 'AUCMaxThetaNorm', 'AUCMaxRet', 'AUCMaxPro', 'AUCMaxRetThetaNorm', 'AUCMaxProThetaNorm'};
		for v=1:length(kappaVars) ; kappaLabels{v} = strrep(kappaVars{v},'AUCMax',''); kappaX{v} = baseX + (v-3)/7; end

		for r=1:length(roiIds)
			ri = find(obj.roiIds == roiIds(r));

			rktdp = obj.roiKappaThetaDirPref{ri};

			% loop whiskerse
			figure ('Position', [100 100 800 400]);
			for w=1:length(whiskerTags)
				wi = find(strcmp(obj.whiskerTag , whiskerTags{w}));
		
				% blank the data
				for v=1:length(thetaVars) ; theta{v} = sVec ; thetaCI{v} = sVecCI ; end
				for v=1:length(kappaVars) ; kappa{v} = sVec ; kappaCI{v} = sVecCI ; end

				% loop sessions to gather data
				for si=1:length(obj.sessions)
					if (length(rktdp{si}{wi}) > 0)
						for v=1:length(thetaVars)
							theta{v}(si) = eval(['rktdp{si}{wi}.thetaAUC.' thetaVars{v}]);
							thetaCI{v}(:,si) = eval(['rktdp{si}{wi}.thetaAUC.' thetaVars{v} 'CI']);
						end
						for v=1:length(kappaVars)
							kappa{v}(si) = eval(['rktdp{si}{wi}.kappaAUC.' kappaVars{v}]);
							kappaCI{v}(:,si) = eval(['rktdp{si}{wi}.kappaAUC.' kappaVars{v} 'CI']);
						end
					end
				end
				
				% figure stuff
				wY = .05;
				wX = .05 + .3*(w-1);

				% plot this set
				subplot('Position', [wX wY+.6 .29 .25]);
				plot_multilines_with_error(kappaX, kappa, kappaCI, colors, kappaLabels, {}, ...
														 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
				set(gca,'TickDir','out');
				title([whiskerTags{w} ' Kappa statistics ROI ' num2str(roiIds(r)) ]);
				plot([0 2*(length(obj.sessions)+1)], [0.5 0.5], 'k:');			
				if (w > 1) ; set(gca,'YTick',[]); end
				set(gca,'XTick',[]);
				
				subplot('Position', [wX wY+.3 .29 .25]);
				plot_multilines_with_error(thetaX, theta, thetaCI, colors, thetaLabels, {}, ...
														 [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
				set(gca,'TickDir','out');
				title([whiskerTags{w} ' Theta statistics ROI ' num2str(roiIds(r)) ]);
				plot([0 2*(length(obj.sessions)+1)], [0.5 0.5], 'k:');			
				if( w == 1);		ylabel('AUC (dff binwise MAX)'); end
				if (w > 1) ; set(gca,'YTick',[]); end
				set(gca,'XTick',[]);
				
			end
			if (length(printPath) > 0) ; 
        print(gcf, '-depsc2', [printPath filesep 'kvtvp_' obj.mouseId '_roi_' num2str(roiIds(r)) '_maxAUC.eps']);
			end
		end
  end




