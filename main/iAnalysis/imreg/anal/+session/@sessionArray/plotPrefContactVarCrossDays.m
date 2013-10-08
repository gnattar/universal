%
% SP May 2011
%
%
%  USAGE:
%
%    sA.plotPrefContactVarCrossDays(params)
%
%  PARAMS:
%
%  params - structure with variables:
%
%    roiIds: rois to look @ ; must specify
%    whiskerTags: cell array of who to do
%
function plotPrefContactVarCrossDays(obj, params)

  % --- input process & default
	if (nargin < 2) 
	  help ('session.sessionArray.plotPrefContactVarCrossDays');
		return;
	end

	% dflts
	whiskerTags = {'c1','c2','c3'};

  % pull required
  roiIds = params.roiIds; 

  % pull optional inptus
	if (isfield(params, 'whiskerTags')) ; whiskerTags = params.whiskerTags; end

  % --- meat -> go ROI by ROI
	sVec = nan*zeros(1,length(obj.sessions));
	sLabels = {};
	kappaColors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 1 0.5 0 ; 0 1 1 ; 0 0 0];
	thetaColors = [1 0 0 ; 0 1 0 ; 0 0 1 ; 1 0 1 ; 1 0.5 0 ; 0 1 1 ; 0 0 0];
  for si=1:length(obj.sessions) ; sLabels{si} = obj.dateStr{si}(1:6); end

	for r=1:length(roiIds)
	  ri = find(obj.roiIds == roiIds(r));
     
	  % whisker-by-whisker
	  for w=1:length(whiskerTags)
			% gather data
			rpcv = obj.roiPrefContactVar{ri};

			% kappa variables 
			kappaTags = {};
			for p=1:7
			  % blank stuff ...
			  mAUCk{p} = sVec;
			  ciAUCk{p} = [sVec ; sVec];
				mMIk{p} = sVec;
				ciMIk{p} = [sVec ; sVec];
				xk{p} = (2:2:2*length(obj.sessions)) + (p-4)/10;
				for si=1:length(obj.sessions)
				  wi = find(strcmp(rpcv{si}.whiskerTags, whiskerTags{w}));
					if (length(wi) > 0 && length(rpcv{si}.kappaDetails{wi}) > 0)
						mAUCk{p}(si) = rpcv{si}.kappaDetails{wi}{p}.auc_mu;
						ciAUCk{p}(:,si) = rpcv{si}.kappaDetails{wi}{p}.auc_ci;
						mMIk{p}(si) = rpcv{si}.kappaDetails{wi}{p}.mi_mu;
						ciMIk{p}(:,si) = rpcv{si}.kappaDetails{wi}{p}.mi_ci;
					end
			  end

				% pull tag ...
        tag = rpcv{1}.kappaDetails{w}{p}.tag;
				kappaTags{p} = '';
				if (length(tag) > 0)
  				fi = strfind(tag,'for');
	  			kappaTags{p} = tag(fi(2)+7:end);
					kappaTags{p} = strrep(kappaTags{p}, ' excl: 1', '');
				end
			end

      % theta variables
			thetaTags = {};
			for p=1:3
			   % blank stuff ...
				 mAUCt{p} = sVec;
				 ciAUCt{p} = [sVec ; sVec];
				 mMIt{p} = sVec;
				 ciMIt{p} = [sVec ; sVec];
				 xt{p} = (2:2:2*length(obj.sessions)) + (p-4)/10;
				 for si=1:length(obj.sessions)
				   wi = find(strcmp(rpcv{si}.whiskerTags, whiskerTags{w}));
					 if (length(wi) > 0 && length(rpcv{si}.thetaDetails{wi}) > 0)
						 mAUCt{p}(si) = rpcv{si}.thetaDetails{wi}{p}.auc_mu;
						 ciAUCt{p}(:,si) = rpcv{si}.thetaDetails{wi}{p}.auc_ci;
						 mMIt{p}(si) = rpcv{si}.thetaDetails{wi}{p}.mi_mu;
						 ciMIt{p}(:,si) = rpcv{si}.thetaDetails{wi}{p}.mi_ci;
					 end
				 end

				 % pull tag ...
         tag = rpcv{1}.thetaDetails{w}{p}.tag;
				 thetaTags{p} = '';
				 if (length(tag) > 0)
  				 fi = strfind(tag,'for');
	  			 thetaTags{p} = tag(fi(2)+7:end);
					 thetaTags{p} = strrep(thetaTags{p}, ' excl: 1', '');
				 end
			 end


			 % plot for this whisker
			 figure;
			 subplot(2,2,1);
			 plot_multilines_with_error(xk, mAUCk , ciAUCk, kappaColors, kappaTags, sLabels, ...
			                            [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			 title([whiskerTags{w} ' AUC kappa roi ' num2str(roiIds(r))  ]);

			 subplot(2,2,3);
			 plot_multilines_with_error(xk, mMIk , ciMIk, kappaColors, kappaTags, sLabels,...
			                            [], '', [0 2*(length(obj.sessions)+1) -2 6]);
			 title([whiskerTags{w} ' MI kappa roi ' num2str(roiIds(r)) ]);

			 subplot(2,2,2);
			 plot_multilines_with_error(xt, mAUCt , ciAUCt, thetaColors, thetaTags, sLabels,...
			                            [], '', [0 2*(length(obj.sessions)+1) 0.4 1]);
			 title([whiskerTags{w} ' AUC theta roi ' num2str(roiIds(r)) ]);

			 subplot(2,2,4);
			 plot_multilines_with_error(xt, mMIt , ciMIt, thetaColors, thetaTags, sLabels,...
			                            [], '', [0 2*(length(obj.sessions)+1) -2 6]);
			 title([whiskerTags{w} ' MI theta roi ' num2str(roiIds(r)) ]);
			 end
		end


