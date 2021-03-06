function hcell = cplot_Ca_behav_trials(CaTrials, ROInum, color_scale, h_axes,plot_whisker) 

% CaTrials, the integrated CaTrials struct data, containing both CaTrial
%           info and behavioral trial objects
% color_scale, to set the color scale of pseudo color plotting
% h_axes, handle to the axes in which to plot 
%
% -- NX 5/2009

if nargin > 3
    axes(h_axes);
else
    fig = figure;
end
if nargin < 3
    color_scale = [-10 120];
end
if nargin < 5
    plot_whisker = 0;
end

h_licks = {};
h_poleOnset = [];
h_waterTimes = [];
polePos_colors = {};
nTrials = length(CaTrials);

% Label the pole position of go trial
if isfield(CaTrials, 'behavTrial')
    for i = 1:nTrials
        PolePos(i) = CaTrials(i).behavTrial.goPosition;
    end
    PossibleGoPositions = unique(PolePos);
    clrs = {'w','g','y','m'};
    for i = 1:length(PossibleGoPositions)
        polePos_colors(PolePos == PossibleGoPositions(i)) = clrs(i);
    end
end

if plot_whisker == 0
    [CaTraces, ts] = get_CaTraces(CaTrials, ROInum);
    ts = ts(1,:);
    %h_cplot = pcolor(ts, (1:nTrials+1), [CaTraces;zeros(1,size(CaTraces,2))]);
    %set(h_cplot, 'EdgeColor', 'none');
    %caxis(color_scale);
    h_cplot = imagesc(CaTraces, color_scale);
    set(h_cplot, 'XData', [ts(1) ts(end)]);
    set(gca,'XLim',get(h_cplot, 'XData'), 'YDir', 'normal');
    colormap(jet);
elseif plot_whisker ==1
    ts = [0 CaTrials(1).wVideoTS(1:end-1)];
    wSpeedTraces = get_CaTrial_WhiskerTrace(CaTrials);
    n = length(ts);
    ts = imresize(ts, [1, round(n/5)], 'bilinear');
    wSpeedTraces = imresize(wSpeedTraces, [size(wSpeedTraces,1) round(n/5)],'bilinear');
%     h_cplot = pcolor(ts, (1:nTrials+1), [wSpeedTraces;zeros(1,size(wSpeedTraces,2))]);
%     set(h_cplot, 'EdgeColor', 'none');
%     caxis(color_scale);
    h_cplot = imagesc(wSpeedTraces, color_scale);
    set(h_cplot, 'XData', [ts(1) ts(end)]);
    set(gca, 'XLim',get(h_cplot, 'XData'), 'YDir', 'normal');
    colormap(gray);
end

hcell = {h_cplot};

if nargin > 2
    hold on;
    for i= 1:nTrials
        % mark lick times
        x_lick = repmat(CaTrials(i).behavTrial.beamBreakTimes',2,1);
        y_lick = repmat([i; i+1], 1, size(x_lick,2));
        if ~isempty(x_lick)
            h_licks{i} = line(x_lick, y_lick, 'Color', 'm','LineWidth',1.12);
        end
        
        poleOnsetTimes(i) = CaTrials(i).behavTrial.pinDescentOnsetTime;
        if isempty(CaTrials(i).behavTrial.rewardTime)
            waterTimes(i) = NaN;
        else
            waterTimes(i) = CaTrials(i).behavTrial.rewardTime(1);
        end
        
        % Label the go positions
        if CaTrials(i).behavTrial.trialType == 1
            plot(ts(end-1), i, '*', 'Color', polePos_colors{i});
        end
    end
    y = [(1:nTrials); (2:nTrials+1)];
    h_poleOnset = line(repmat(poleOnsetTimes,2,1),y,'Color','w','LineWidth',1.5);
    h_waterTimes = line(repmat(waterTimes,2,1),y,'Color','w','LineWidth',2.5);
    
    hcell = [hcell {h_licks, h_poleOnset, h_waterTimes}];
end


