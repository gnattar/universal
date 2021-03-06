
function h_figs = plot_sorted_Ca_behave_Trials(obj, ROInum, sorting,color_scale)
%% Sort Ca Trial objects - Aug, 09
trial_inds = obj.get_trial_inds;
CaObj_hit = obj(trial_inds.hit);
CaObj_miss = obj(trial_inds.miss);
CaObj_cr = obj(trial_inds.cr);
CaObj_fa = obj(trial_inds.fa);
CaObj_go = obj(trial_inds.go);
CaObj_nogo = obj(trial_inds.nogo);
%% Sort Ca hit trials by go positions (default)
if ~exist('sorting','var') || strcmpi(sorting,'goPos')
    goPos_hit = [];
    for i = 1:length(CaObj_hit)
        goPos_hit(i) = CaObj_hit(i).behavTrial.goPosition;
    end;
    [goPos_hit_sort, inds_sort_by_pos] = sort(goPos_hit);
    CaObj_hit = CaObj_hit(inds_sort_by_pos);
    ind_hit = trial_inds.hit(inds_sort_by_pos);
end

%% Sort 
if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
    AnswerLickTimes_hit = [];
    AnswerLickTimes_fa = [];
    for i = 1:length(CaObj_hit)
        AnswerLickTimes_hit(i) = CaObj_hit(i).behavTrial.answerLickTime;
    end
    [answerT_sort_hit, inds_sort_hit] = sort(AnswerLickTimes_hit);
    CaObj_hit = CaObj_hit(inds_sort_hit);
    
    for i = 1:length(CaObj_fa)
        AnswerLickTimes_fa(i) = CaObj_fa(i).behavTrial.answerLickTime;
    end
    [answerT_sort_fa, inds_sort_fa] = sort(AnswerLickTimes_fa);
    CaObj_fa = CaObj_fa(inds_sort_fa);
end

%%
% ROInum = 6;
nTrials = length(obj);
ROItype = obj(1).ROIType{ROInum};
titleStr = ['ROI# ' num2str(ROInum) '(' ROItype ')' '-' obj(1).AnimalName '-' obj(1).ExpDate '-' obj(1).SessionName];
color_sc = [-10 200];
ts = (1:obj(1).nFrames).*obj(1).FrameTime;
if obj(1).FrameTime > 1
    ts = ts/1000;
end
if ~exist('fig1','var') || ~ishandle(fig1)
    scrsz = get(0, 'ScreenSize');
    fig1 = figure('Position', [20, 50, scrsz(3)/4+100, scrsz(4)-200], 'Color', 'w');
else
    figure(fig1); clf;
end;
h_axes0 = axes('Position', [0 0 1 1], 'Visible', 'off');
if ~isempty(CaObj_hit)
    h_axes(1) = axes('Position', [0.1, 0.05, 0.8, length(CaObj_hit)/nTrials*0.85]);
    [traces_hit, hit_mean, hit_se, ts_hit] = get_traces_and_plot(CaObj_hit, ROInum,h_axes(1));
    
    if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
        [traces_hit_align, ts1] = align_traces(CaTraces_hit, ts, answerT_sort_hit);
        hit_mean = mean(traces_hit_align,1);
    end
    set(h_axes(1),'Box','off', 'FontSize',13);
    
end
if ~isempty(CaObj_miss)
    h_axes(2) = axes('Position', [0.1, length(CaObj_hit)/nTrials*0.85+0.06, 0.8,...
        length(CaObj_miss)/nTrials*0.85]);
    [traces_miss, miss_mean, miss_se, ts_miss] = get_traces_and_plot(CaObj_miss, ROInum,h_axes(2));
    set(h_axes(2),'XTickLabel','','Box','off', 'FontSize',13);    
end
if ~isempty(CaObj_cr)
    h_axes(3) = axes('Position', [0.1, length([CaObj_hit CaObj_miss])/nTrials*0.85+0.07, 0.8,...
        length(CaObj_cr)/nTrials*0.85]);
    [traces_cr, cr_mean, cr_se, ts_cr] = get_traces_and_plot(CaObj_cr, ROInum,h_axes(3));
    set(h_axes(3),'XTickLabel','','Box','off', 'FontSize',13);
end

if ~isempty(CaObj_fa)
    h_axes(4) = axes('Position', [0.1, length([CaObj_hit CaObj_miss CaObj_cr])/nTrials*0.85+0.08,...
        0.8, length(CaObj_fa)/nTrials*0.85]);
    [traces_fa, fa_mean, fa_se, ts_fa] = get_traces_and_plot(CaObj_fa, ROInum,h_axes(4));
    set(h_axes(4),'XTickLabel','','Box','off', 'FontSize',13);
    if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
        [traces_fa_align, ts2] = align_traces(CaTraces_fa, ts, answerT_sort_fa);
        fa_mean = mean(traces_fa_align,1);
    end
end
title(titleStr, 'FontSize', 18);
if ~exist('color_scale','var') || isempty(color_scale)
    allTraces = [traces_hit(:); traces_miss(:); traces_cr(:); traces_fa(:)];
    clim(1) = round((prctile(allTraces,0.5))/10)*10; % round((min(allTraces))/10)*10;
    clim(2) = round((prctile(allTraces,99.5))/10)*10; % max(allTraces); %
    clrsc_str = ['Color Scale: [' num2str(clim(1)) ', ' num2str(clim(2)) ']'];
    axes(h_axes0); text(0.3,0.01,clrsc_str ,'FontSize',14,'Color', 'b');
    disp(clrsc_str);
    for i=1:4,
        set(h_axes(i), 'CLim', clim);
    end
    
end
h_figs(1) = fig1;

%% plot trial mean

fpos = get(fig1,'Position');
fig2 = figure('Position', [fpos(1)+100 fpos(2) fpos(3) fpos(3)/2]);
hold on;
if exist('sorting','var') && strcmpi(sorting,'AnswerLick')
    plot(ts1, hit_mean,'r', 'LineWidth', 1.5);
    plot(ts2, fa_mean,'k', 'LineWidth', 1.5);
    legend('Hit', 'F-A');
    set(gca,'FontSize',13);
    x1 = min(ts1(1),ts2(1)); x2 = max(ts1(end),ts2(end));
    xlim([x1 x2]);
    % yl = get(gca,'YLim'); ylim([-5 yl(2)]);
    set(gca,'XTick',(floor(x1):round(x2)));
    set(get(gca,'XLabel'), 'String', 'Time (sec)', 'FontSize', 18);
    set(get(gca,'YLabel'), 'String', 'mean dF/F (%)', 'FontSize',18);
else
    % errorshade(ts, hit_mean, hit_se, 'r');
    % errorshade(ts, miss_mean, miss_se, 'b');
    % errorshade(ts, cr_mean, cr_se, 'g');
    % errorshade(ts, fa_mean, fa_se, 'm');
    plot(ts, hit_mean,'r', 'LineWidth', 1.5);
    plot(ts, miss_mean, 'b', 'LineWidth', 1.5);
    plot(ts, cr_mean,'g', 'LineWidth', 1.5);
    plot(ts, fa_mean,'m', 'LineWidth', 1.5);
    legend('Hit', 'Miss', 'C-R', 'F-A');
    set(gca,'FontSize',13);
    xlim([ts(1) ts(end)]);
    % yl = get(gca,'YLim'); ylim([-5 yl(2)]);
    set(gca,'XTick',(floor(ts(1)):round(ts(end))));
    set(get(gca,'XLabel'), 'String', 'Time (sec)', 'FontSize', 18);
    set(get(gca,'YLabel'), 'String', 'mean dF/F (%)', 'FontSize',18);
    
    go_mean = mean(CaObj_go.get_CaTraces(ROInum,'asis'),1);
    go_se = std(CaObj_go.get_CaTraces(ROInum,'asis'),0,1)./sqrt(length(CaObj_go));
    nogo_mean = mean(CaObj_nogo.get_CaTraces(ROInum,'asis'),1);
    nogo_se = std(CaObj_nogo.get_CaTraces(ROInum,'asis'),0,1)./sqrt(length(CaObj_nogo));
    
    fig3 = figure('Position', [fpos(1)+200 fpos(2) fpos(3) fpos(3)/2]);
    hold on;
    plot(ts, go_mean, 'r', 'LineWidth', 2);
    plot(ts, nogo_mean, 'k', 'LineWidth', 2);
    legend('Go-trials', 'NoGo-trials');
    set(gca,'FontSize',13);
    xlim([ts(1) ts(end)]);
   % yl = get(gca,'YLim'); ylim([-5 yl(2)]);
    set(gca,'XTick',(floor(ts(1)):round(ts(end))));
    set(get(gca,'XLabel'), 'String', 'Time (sec)', 'FontSize', 18);
    set(get(gca,'YLabel'), 'String', 'mean dF/F (%)', 'FontSize',18);
end
h_figs(2) = fig2;
h_figs(3) = fig3;
function polePos_colors = color_go_pos(obj)
%% Label the pole position of go trial

if ~isempty(obj(1).behavTrial)
    for i = 1:length(obj)
        PolePos(i) = obj(i).behavTrial.goPosition;
    end
    PossibleGoPositions = unique(PolePos);
    clrs = {'w','g','y','m'};
    for i = 1:length(PossibleGoPositions)
        polePos_colors(PolePos == PossibleGoPositions(i)) = clrs(i);
    end
end

 
function [traces_aligned, ts_align] = align_traces(traces, ts, eventTimes)
%%
frameTime = ts(2)-ts(1);
eventFrame = ceil(eventTimes./frameTime);
window(1) = min(eventFrame); % ts(find(ts<min(eventTimes),1,'last'));
window(2) = length(ts) - max(eventFrame);
traces_aligned = [];
for i = 1:size(traces,1)
    inds{i} = eventFrame(i)-window(1)+1 : eventFrame(i)+window(2);
    traces_aligned(i,:) = traces(i,inds{i});
    ts_align = ts(inds{i})-eventTimes(i);
end

function [Traces, trace_mean, trace_se, ts] = get_traces_and_plot(CaObj, ROInum, h_axes)
%%
eventTimes = CaObj.get_behavTiming;
t_lick = eventTimes.lick;
poleOnset = eventTimes.poleOnset;
answerLick = eventTimes.answerLick;
polePos_colors = color_go_pos(CaObj);
[Traces, ts] = CaObj.get_CaTraces(ROInum,'asis');
color_sc = [-10 200];
cmap = 'jet';
trace_mean = nanmean(Traces, 1);
trace_se = nanstd(Traces,0, 1)./sqrt(size(Traces,1));
% if no_plotting == true
%    return;
% end
h_plot = cplot_Ca_behav_trials(Traces,ts,t_lick, ...
    poleOnset, answerLick, h_axes,color_sc,polePos_colors, cmap);

