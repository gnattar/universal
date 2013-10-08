%
% SP Sept 2011
%
% Updates the single-trial plot during GUI mode.
%
% USAGE:
%
%   obj.updateSingleTrialPlot()
%
function updateSingleTrialPlot(obj)
  % build ES shown list
	ESShown = find(obj.ESListOn);
	ESShownList = {};
	for e=1:length(ESShown)
	  ESShownList{e} = obj.ESList{ESShown(e)};
	end

  if (length(obj.trialPlotTrialNumber) == 0) ; return ; end
 
  % --- build new?
	alreadyPresent = 1;
	if (length(obj.trialPlotH) == 0)
    alreadyPresent = 0;
	elseif (~ishandle(obj.trialPlotH(1)))
	  alreadyPresent = 0;
	elseif (strcmp(get(obj.trialPlotH(1),'Name'), 'Single Trial Plot') == 0)
	  alreadyPresent = 0;
	end

	if (~alreadyPresent)
		obj.trialPlotH(1) = figure('Position',[100 100 800 400], 'Name', 'Single Trial Plot', 'NumberTitle','off');
		obj.trialPlotH(3) = nan; % no avg
		obj.trialPlotH(2) = axes('Position',[0.05 .05 .45 .9]); % left
		obj.trialPlotH(5) = nan; % no avg
		obj.trialPlotH(4) = axes('Position',[0.5375 .05 .45 .9]); % right
	end


	% --- call plotter
  if (length(obj.leftListTSA) > 0)
		% plot value range
    lpvr = [nan nan];
		if (ischar(obj.leftPlotValueRange))
			M = nanmax(nanmax(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:)));
			m = nanmin(nanmin(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:)));
			sd = nanstd(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));
			mu = nanmean(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));
			med = nanmedian(reshape(obj.leftListTSA{obj.leftIdx(1)}.valueMatrix(obj.leftIdx(2),:),[],1));

			lpvr = eval([obj.leftPlotValueRange ';']);
    elseif (length(obj.leftPlotValueRange) == 2)
			lpvr = obj.leftPlotValueRange;
		end
  
	  % plotter call
    session.timeSeriesArray.plotTimeSeriesAsLineS(obj.leftListTSA{obj.leftIdx(1)}, obj.leftIdx(2), ...
       obj.trialStartTimeMat, ESShownList, obj.trialPlotTrialNumber, obj.trialTypeMat, ...
			 obj.trialType, obj.trialTypeStr, obj.trialTypeColor, ...
			 [0 10 lpvr(1) lpvr(2)], obj.trialPlotH(2:3), 0);

    % add trial # to titles
    titleH = get(obj.trialPlotH(2),'Title');
    curTitle = get(titleH,'String');
    set(titleH, 'String', [curTitle ' (trial: ' num2str(obj.trialPlotTrialNumber) ')']);
  end

	% call plotter
  if (length(obj.rightListTSA) > 0)
		% plot value range
    rpvr = [nan nan];
		if (ischar(obj.rightPlotValueRange))
			M = nanmax(nanmax(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:)));
			m = nanmin(nanmin(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:)));
			sd = nanstd(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));
			mu = nanmean(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));
			med = nanmedian(reshape(obj.rightListTSA{obj.rightIdx(1)}.valueMatrix(obj.rightIdx(2),:),[],1));

			rpvr = eval([obj.rightPlotValueRange ';']);
    elseif (length(obj.rightPlotValueRange) == 2)
			rpvr = obj.rightPlotValueRange;
		end
  
	  % plotter call
    session.timeSeriesArray.plotTimeSeriesAsLineS(obj.rightListTSA{obj.rightIdx(1)}, obj.rightIdx(2), ...
       obj.trialStartTimeMat, ESShownList, obj.trialPlotTrialNumber, obj.trialTypeMat, ...
			 obj.trialType, obj.trialTypeStr, obj.trialTypeColor, ...
			 [0 10 rpvr(1) rpvr(2)], obj.trialPlotH(4:5), 0);

    % add trial # to titles
    titleH = get(obj.trialPlotH(2),'Title');
    curTitle = get(titleH,'String');
    set(titleH, 'String', [curTitle ' (trial: ' num2str(obj.trialPlotTrialNumber) ')']);
  end


