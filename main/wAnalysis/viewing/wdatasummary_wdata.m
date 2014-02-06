
function[w_data]...
    =  wdatasummary_wdata(sessionInfo,obj,block_tags,block_trialnums,avg_trials,gopix,nogopix,restrictTime,pd,plot_whiskerfits,str,timewindowtag,min_meanbarpos,baseline_barpos,dev_threshold,data_to_analyze)
%% new version : compare within block & with top 90% percentile of setpoint values
% w_setpoint_trials % all setpoint values from all trials  entire length
% w_setpoint_early % within the restricted time window from early trials
% w_setpoint_late % within the restricted time window from late trials
% w_setpoint_trials_med % mean of 90th percentile of setpoint values within window
% w_setpoint_trials_width std of the points avgd over
% data_to_analyze = 1 (theta) = 0 (thetaenvelope)
w_data = struct('datatrials',[],'time',[],'dist',[],'bins',[],'amp',[],'dist_epoch',[],'meandev_data',[],'meandev_data_binned',[],'meanpole_data',[],'meanpole_data_binned',[],...
    'meandev_whiskamp',[],'meandev_whiskamp_binned',[],...
    'meanpole_whiskamp',[],'meanpole_whiskamp_binned',[], ...
    'peakdev_data',[],'peakdev_data_binned',[],...
    'prepole_data',[],'prepole_data_binned',[],'prcoccupancy',[],'prcoccupancy_binned',[],'prcoccupancy_epoch',[],'prcoccupancy_epoch_binned',[],'pval',[],'mean_barpos',[]);

%'totalpole_whiskamp',[],'totalpole_whiskamp_binned',[], 'totaldev_whiskamp',[],'totaldev_whiskamp_binned',[],
numblocks = size(block_tags,2);

%% get mean bar theta cut off

y  =sessionInfo.go_bartheta;
x = sessionInfo.gopos;
ind = find(~isnan(y));
y = y(ind);
x = x(ind);

y = sort(y ,'ascend');

p=polyfit(x,y,1);
%      mean_selecttrials = nanmedian(sessionInfo.goPosition_runmean(block_trialnums{1}));
mean_selecttrials = min_meanbarpos;
biased_bartheta = round(polyval(p,mean_selecttrials*10000)*100)/100;
shoulder = 2.5; % avg 5 deg between pole positions , should = 2.5 deg
baseline_bartheta =  round(polyval(p,baseline_barpos*10000)*100)/100;
mean_bartheta =  round(polyval(p,sessionInfo.goPosition_mean*10000)*100)/100;

point = max(gopix);
gopix(:,2) = point(1,2);
nogopix(1,2) = point(1,2);


frames_list=arrayfun(@(x) size(x{:}.time{1},2), obj,'uniformoutput',false);
maxframes = max(cell2mat(frames_list));
numpoleframes = round((restrictTime(2)-restrictTime(1))*500);

if~(exist([pd '/plots/'],'dir'))
    mkdir (pd,'plots') ;
end

fpath = [pd '/plots/'];
if ~(exist([fpath timewindowtag],'dir'))
    mkdir (fpath,timewindowtag) ;
end

fpath = [pd '/plots/' timewindowtag '/'];
if ~(exist([fpath str],'dir'))
    mkdir (fpath,str) ;
end

fpath = [pd '/plots/' timewindowtag '/' str];

for(blk=1:numblocks)
    trialnums = block_trialnums{blk};
    col=jet(length(trialnums));
    data_bins = -50:2.5:50;
    occupancy_bins = -40:1:40;
    occupancy_nbins = length(occupancy_bins );
    nbins=length(data_bins);
    data_dist = nan(length(trialnums),nbins);
    data_dist_epoch = nan(length(trialnums),nbins);
    data_occupancy = nan(length(trialnums), occupancy_nbins);
    data_trials = nan(length(trialnums)+1,numpoleframes);
    amp_trials= nan(length(trialnums)+1,numpoleframes);
    local.meandev_data = nan(length(trialnums),2);
    local.peakdev_data = nan(length(trialnums),2);
    local.totaldev_whiskamp = nan(length(trialnums),1);
    local.meandev_whiskamp = nan(length(trialnums),1);
    local.meanpole_data = nan(length(trialnums),2);
    local.totalpole_whiskamp = nan(length(trialnums),1);
    local.meanpole_whiskamp = nan(length(trialnums),1);
    local.prcoccupancy = nan(length(trialnums),1);
    local.prcoccupancy_epoch = nan(length(trialnums),1);
    local.prepole_data = nan(length(trialnums),2);
    ref_time = restrictTime(1)+.002:.002:restrictTime(2);ref_time=round(ref_time.*1000)./1000;
    data_time =   ref_time;
    numpoleframes = length(ref_time);
    
    %        count =1;
    
    for(i=1:1:length(trialnums))
        
        t = trialnums(i);
        frames = length(obj{t}.theta{1,1});
        if(frames<1500)
            disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))])
            frameTime = obj{t}.framePeriodInSec;
        else
            frameTime = obj{t}.framePeriodInSec;
            setpoint = obj{t}.Setpoint{1,1};
            amp     = obj{t}.Amplitude{1,1};
            theta = obj{t}.theta{1,1};        
            thetaenv = envelope(theta,'linear');
            if(strcmp(data_to_analyze,'theta')) %1 = theta
                data = theta;
            else % 0 = thetaenv
                data = thetaenv;
            end
            xt = obj{t}.time{1,1};xt = round( xt.*1000)./1000;
            poleinds =  find((restrictTime(1)< xt) & (xt<=restrictTime(2)));
            poleinds_dev = find(amp(poleinds)>dev_threshold*mad(amp(poleinds)));
            prepoleinds = find( (xt>restrictTime(1)-.2) & (xt<=restrictTime(1)));
            prepoleinds_dev = find(amp(prepoleinds)>dev_threshold*mad(amp(prepoleinds)));
            if(isempty(poleinds))
                trialnums(i);
                obj{i}.trackerFileName
            end
            data_pole = data(poleinds);
            xt_pole = xt(poleinds);
            [lia,matchedinds]= ismember( xt_pole,ref_time);
            data_trials(i,matchedinds>0) =   data_pole;
            data_amp(i,matchedinds>0) = amp(poleinds);
            data_dev = data(poleinds_dev);
            data_occupancy(i,:) = histnorm(data_pole,occupancy_bins);
            data_dist(i,:) = histnorm(data_pole,data_bins);%./length(data_pole);
            data_dist_epoch (i,:) = histnorm(data_dev,data_bins);
            past_meanbar= find(data_bins > biased_bartheta - shoulder);
            local.meandev_data(i,1) = mean(data_dev);
            local.meandev_data(i,2) =  std(data_dev);
            local.meanpole_data(i,1) = mean(data_pole);
            local.meanpole_data(i,2) =  std(data_pole);
            prc = prctile(data_dev,90);
            temp = data_dev(data_dev>prc);
            local.peakdev_data(i,1) = mean(temp); %%
            local.peakdev_data(i,2) = std(temp);
            temp = data(prepoleinds);
            local.prepole_data(i,1) = mean(temp);
            local.prepole_data(i,2) = std(temp);            
            local.prcoccupancy(i,1) = sum(data_dist(i,past_meanbar));
            local.prcoccupancy_epoch(i,1) = sum(data_dist_epoch(i,past_meanbar));
            local.meandev_whiskamp(i,1) = mean(amp(poleinds_dev));
            local.totaldev_whiskamp(i,1) = sum(amp(poleinds_dev));
            local.meanpole_whiskamp(i,1) = mean(amp(poleinds));
            local.totalpole_whiskamp(i,1) = sum(amp(poleinds));   
        end
    end
end

hold off;
avg_trials = floor(length(trialnums)/3);
if(i-1<=avg_trials)
    avg_trials = i-2;
    disp ([ 'there are only' num2str(i-1) ' good trials , reduced trialstoavg to ' num2str(i-2)]);
end

earlyinds= [1:avg_trials] ;
lateinds= [i-1-avg_trials : i-1] ;

%% plot data _med,meanbarcross,prepole

var_set = {'meandev_data','peakdev_data','meanpole_data','prepole_data','prcoccupancy','prcoccupancy_epoch','meandev_whiskamp','meanpole_whiskamp'};
col_set = {'k','r','b','g','k','k','k','b'};
pval = zeros(length(var_set));
for v = 1: length(var_set)
    strg = var_set{v};
    fnam=[str strg '.tif'];
    h1a=figure('Name',[strg ' plot']);
    set(0,'CurrentFigure',h1a);
    tempstr =  strrep(strg,'_', ' ');
    tempstr = strrep(tempstr,'meandev', 'Mean Whisk Epoch');
    tempstr = strrep(tempstr,'epoch', ' Whisk Epoch');
    tempstr = strrep(tempstr,'meanpole', '  Mean Sampling Period');
    tempstr = strrep(tempstr,'data', data_to_analyze);
    suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName  ' ' tempstr ' from ' str 'trials']);
    set(gcf,'Visible','off');
    windowSize=10;
    grid on;
    data =local.(strg);
    data1 = data(:,1);
    binned= arrayfun( @(x) nanmean(data1(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data1,1), 'UniformOutput', false);
    binned=cat(1,binned{:});
    if(size(data,2)>1)
        data2 = data(:,2);
        binned_2 = arrayfun( @(x) nanmean(data2(x: min(x+windowSize-1,end) ),1), 1:windowSize:size(data2,1), 'UniformOutput', false);
        binned_2=cat(1,binned_2{:});
    end
    xbins = arrayfun( @(x) nanmean(x:min(x+windowSize-1,size(data,1))), 1:windowSize:size(data,1), 'UniformOutput', false);
    xbins=floor(cat(1,xbins{:}));    
    switch v
        case {5,6,7,8,9}
            plot(trialnums(xbins),binned,'linewidth',1,'color',col_set{v},'Marker','o','MarkerSize',8); hold on;
            plot (trialnums,data1,'linewidth',.5,'color',[.5 .5 .5]);
        otherwise
            errorbar(trialnums(xbins),binned,binned_2,'linewidth',1.5,'color',col_set{v},'Marker','o','MarkerSize',8);hold on;
            plot (trialnums,data1,'linewidth',.5,'color',[.5 .5 .5]);
            grid on;
            hline(biased_bartheta,{'r-','linewidth',1.5},{['bb ' num2str(biased_bartheta)]},[0 .1]);
            hline(mean_bartheta,{'r--','linewidth',1},{['mb ' num2str(mean_bartheta)]},[.75 -.1]);
    end
    if(length(binned)>3)
        s = regstats(binned,trialnums(xbins),'linear','tstat');
        pval(v)  = s.tstat.pval(2); % test for non-zero slope of med
    end
    w_data.(var_set{v}){blk} = {horzcat(trialnums,data(:,1))}; %% mean for restricted time window
    w_data.([var_set{v} '_binned']){blk} = {horzcat(trialnums(xbins),binned)}; %%median binned withi n restricted time window
    if(size(data,2)>1 )
        w_data.(var_set{v}){blk} = {horzcat(trialnums,data(:,1),data(:,2))}; %% mean for restricted time window
        w_data.([var_set{v} '_binned']){blk} = {horzcat(trialnums(xbins),binned,binned_2)}; %%median binned withi n restricted time window
    end
        saveas(gcf,[fpath,filesep,fnam],'tif');
        print(h1a,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
        close(h1a);
end
    w_data.amp{blk} = {data_amp};
    w_data.datatrials{blk} = {data_trials};
    w_data.time {blk}= {data_time};
    
%% plot dist
fnam=[str 'Dist' '.tif'];
h1a=figure('Name',[strg ' plot']);
set(0,'CurrentFigure',h1a);
suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName  'data Distribution from ' str ' trials']);  
set(gcf,'Visible','off');
nonzero_distvals = sum((data_dist_epoch>0),1);
cummu_dist = sum(data_dist_epoch,1)./size(data_dist_epoch,2);
plot(data_bins',cummu_dist','linewidth',1.5,'color',[.5 .5 .5]); hold on;
nonzero_distvals = sum((data_dist>0),1);
cummu_dist = sum(data_dist,1)./size(data_dist,2);
plot(data_bins',cummu_dist','linewidth',1.5,'color',[.5 .5 1]); hold on;
title('data Distribution');
%         cummu_dist = histnorm(reshape(data_trials,prod(size(data_trials)),1),data_bins);
%         plot(data_bins',cummu_dist','linewidth',1.5,'color',[.5 .5 1]); hold on;
legend('Occupancy Sampling period','Occupancy Whisk Epochs');
ylabel('Normalized Distribution');xlabel('Trials');
axis ([-50 50 0 .5]);grid on;
vline(biased_bartheta,{'r', 'linewidth',1.5},{num2str(biased_bartheta)},[0 0]);grid on;
vline(mean_bartheta,{'r--','linewidth',1},{num2str(mean_bartheta)},[.2 .5]);
saveas(gcf,[fpath,filesep,fnam],'tif');
print(h1a,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
close(h1a);

w_data.dist {blk}= {data_dist};
w_data.dist_epoch {blk}= {data_dist_epoch};
w_data.bins {blk}= {data_bins};
w_data.occupancy = {data_occupancy};
w_data.occupancybins = {occupancy_bins};
w_data.pval {blk}={pval};
w_data.biased_barpos{blk} = {biased_bartheta};
w_data.baseline_barpos{blk} = {baseline_bartheta};
w_data.mean_barpos{blk} = {mean_bartheta};

%%plot data first and last n trials
fnam=[str 'Theta_env trials.tif'];
h1c=figure('Name','Theta Envelope Trials');
set(0,'CurrentFigure',h1c);
suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName  ' ' str ' Trials Early - Late']);
set(gcf,'Visible','off');
xt = data_time;
plot(xt,data_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;
hline(biased_bartheta,{'r','linewidth',1.5},{['bb ' num2str(biased_bartheta)]},[0 .1]);
hline(mean_bartheta,{'r--','linewidth',1},{['mb ' num2str(mean_bartheta)]},[.75 -.1]);

avg_data = nanmean(data_trials(earlyinds,:));plot(xt,avg_data,'linewidth',1.5,'color','k');hold off;
axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
set(gca,'YTick',-30:10:30);
%          subplot(numblocks*2,3,(blk-1)*2+5);
subplot(numblocks*1,2,(blk-1)*2+2);
plot(xt,data_trials(lateinds(1:2:end),:),'color',[.5 .5 1],'linewidth',1); hold on;
hline(biased_bartheta,{'r','linewidth',1.5},{['bb ' num2str(biased_bartheta)]},[0 .1]);
hline(mean_bartheta,{'r--','linewidth',0.5},{['mb ' num2str(mean_bartheta)]},[.75 -.1]);%(mean_bartheta-biased_bartheta)/10]);
hline([biased_bartheta-shoulder, biased_bartheta+shoulder],{'k--','linewidth',0.5});
avg_data = nanmean(data_trials(lateinds,:),1); plot(xt,avg_data,'linewidth',1.5,'color','b'); grid on;   hold off;
axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
set(gca,'YTick',-30:10:30);
freezeColors;
saveas(gcf,[fpath,filesep,fnam],'tif');
print(h1c,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
close(h1c);

w_data.amp{blk} = {data_amp};
w_data.datatrials{blk} = {data_trials};
w_data.time {blk}= {data_time};

%% plot dist
fnam=[str 'Dist' '.tif'];
h1a=figure('Name',[strg ' plot'],'Visible','off');
set(0,'CurrentFigure',h1a);
suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName  'data Distribution from ' str ' trials']);
set(gcf,'Visible','off');
%         subplot(numblocks*2,3,(blk-1)*2+3);

nonzero_distvals = sum((data_dist_epoch>0),1);
cummu_dist = sum(data_dist_epoch,1)./size(data_dist_epoch,2);
plot(data_bins',cummu_dist','linewidth',1.5,'color',[.5 .5 .5]); hold on;

nonzero_distvals = sum((data_dist>0),1);
cummu_dist = sum(data_dist,1)./size(data_dist,2);
plot(data_bins',cummu_dist','linewidth',1.5,'color',[.5 .5 1]); hold on;
%         subplot(numblocks*2,1,(blk-1)*2+(2));
title('data Distribution');
%         cummu_dist = histnorm(reshape(data_trials,prod(size(data_trials)),1),data_bins);
%         plot(data_bins',cummu_dist','linewidth',1.5,'color',[.5 .5 1]); hold on;
legend('Occupancy Sampling period','Occupancy Whisk Epochs');
ylabel('Normalized Distribution');xlabel('Trials');
axis ([-50 50 0 .5]);grid on;

vline(biased_bartheta,{'r', 'linewidth',1.5},{num2str(biased_bartheta)},[0 0]);grid on;
vline(mean_bartheta,{'r--','linewidth',1},{num2str(mean_bartheta)},[.2 .5]);

saveas(gcf,[fpath,filesep,fnam],'tif');
print(h1a,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
close(h1a);

w_data.dist {blk}= {data_dist};
w_data.dist_epoch {blk}= {data_dist_epoch};
w_data.bins {blk}= {data_bins};
w_data.occupancy = {data_occupancy};
w_data.occupancybins = {occupancy_bins};
w_data.pval {blk}={pval};
w_data.biased_barpos{blk} = {biased_bartheta};
w_data.baseline_barpos{blk} = {baseline_bartheta};
w_data.mean_barpos{blk} = {mean_bartheta};

%%plot data first and last n trials
fnam=[str 'Theta_env trials.tif'];
h1c=figure('Name','Theta Envelope Trials','Visible','off');
set(0,'CurrentFigure',h1c);
suptitle(['M:' obj{1}.mouseName ' S:' obj{1}.sessionName  ' ' str ' Trials Early - Late']);
set(gcf,'Visible','off');
xt = data_time;
%          subplot(numblocks*2,3,(blk-1)*2+4);
subplot(numblocks*1,2,(blk-1)*2+1);
plot(xt,data_trials(earlyinds(1:2:end),:),'color',[.5 .5 .5],'linewidth',1); hold on;
hline(biased_bartheta,{'r','linewidth',1.5},{['bb ' num2str(biased_bartheta)]},[0 .1]);
hline(mean_bartheta,{'r--','linewidth',1},{['mb ' num2str(mean_bartheta)]},[.75 -.1]);
avg_data = nanmean(data_trials(earlyinds,:));plot(xt,avg_data,'linewidth',1.5,'color','k');hold off;
axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
set(gca,'YTick',-30:10:30);
%          subplot(numblocks*2,3,(blk-1)*2+5);
subplot(numblocks*1,2,(blk-1)*2+2);
plot(xt,data_trials(lateinds(1:2:end),:),'color',[.5 .5 1],'linewidth',1); hold on;
hline(biased_bartheta,{'r','linewidth',1.5},{['bb ' num2str(biased_bartheta)]},[0 .1]);
hline(mean_bartheta,{'r--','linewidth',0.5},{['mb ' num2str(mean_bartheta)]},[.75 -.1]);%(mean_bartheta-biased_bartheta)/10]);
hline([biased_bartheta-shoulder, biased_bartheta+shoulder],{'k--','linewidth',0.5});
avg_data = nanmean(data_trials(lateinds,:),1); plot(xt,avg_data,'linewidth',1.5,'color','b'); grid on;   hold off;
axis([restrictTime(1),restrictTime(2),-30,30]);set(gca,'YGrid','on');
set(gca,'YTick',-30:10:30);
freezeColors;
saveas(gcf,[fpath,filesep,fnam],'tif');
print(h1c,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
close(h1c);


sc = get(0,'ScreenSize');
h1b = figure('position', [1000, sc(4)/10-100, sc(3)*3/10, sc(4)*3/4], 'color','w','Visible','off');
waterfall(occupancy_bins,trialnums,data_occupancy); hold on;
vline(biased_bartheta,{'w', 'linewidth',1.5});
vline([biased_bartheta-shoulder, biased_bartheta+shoulder],{'w--','linewidth',0.5});
fnam = [ str 'data_Occupancy'];
saveas(gcf,[fpath,filesep,fnam],'fig');
% print(h1b,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
close(h1b);

%% plot kappa
fnam=[str 'fkappa.tif'];
h2=figure('Name','Kappa','Visible','off');
set(0,'CurrentFigure',h2);


for(blk=1:numblocks)
    trialnums = block_trialnums{blk};
    kappa_trials= zeros(length(trialnums),maxframes);
    col=jet(length(trialnums));
    count =1;
    subplot(numblocks*2,2,(blk-1)*2+1);
    for(i=1:length(trialnums))
        t = trialnums(i);
        frames = length(obj{t}.kappa{1,1});
        if(frames<1500)
            disp(['delete trial' obj{t}.trackerFileName num2str(trialnums(i))]);
        else
            frameTime = obj{t}.framePeriodInSec;
            xt = obj{t}.time{1};
            temp=obj{t}.kappa{1,1};
            baselineinds = find(restrictTime(1)-.3< xt <restrictTime(1)-.1);
            baseline = mean(temp(baselineinds)); %mean(temp(round(0.3/frameTime):round(0.5/frameTime)));
            temp=temp-baseline;
            windowSize = 1;
            filtkappa= filter(ones(1,windowSize)/windowSize,1,temp);
            %             plot(xt(round(.3/frameTime):round(4/frameTime)),filtkappa(round(.3/frameTime):round(4/frameTime)),'color',col(i,:),'linewidth',1); axis ([.3 4 -.01 0.01]) ;
            plot(xt(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),filtkappa(round(restrictTime(1)/frameTime):round(restrictTime(2)/frameTime)),'color',col(i,:),'linewidth',1.5); axis ([restrictTime(1) restrictTime(2) -.01 0.01]) ;
            hold on;
            kappa_trials(count,[1:frames])=filtkappa;
            count=count+1;
        end
    end
    hold off;
    
    title(['M:' obj{1}.mouseName ' S: ' obj{1}.sessionName ' Ttype: ' str  ' Kappa'  ]);
    %     xt = [1:maxframes]*frameTime;
    maxkappa = cell2mat(cellfun(@(x) x.maxTouchKappaTrial,obj(trialnums),'uniformoutput',false));
    totalkappa = cell2mat(cellfun(@(x) x.totalTouchKappaTrial,obj(trialnums),'uniformoutput',false));
    
    temp = totalkappa;
    nocontact = find(temp==0);
    temp(nocontact) = [];
    subplot(numblocks*2,2,(blk-1)*2+2);
    if(~isempty(temp))
        totalkappa_dist = histnorm(temp,[-30:30]);
        plot([-30:30],totalkappa_dist,'color','k','Linewidth',1.5); xlabel('Kappa'); ylabel('Norm freq');  title('Kappa Dist Cummulative ');
        axis([-30 30 0 .75]);
        text(.5,.5,['Contacts ' num2str(length(totalkappa)-length(nocontact)) '/' num2str(length(totalkappa)) ],'VerticalAlignment','top','HorizontalAlignment','center');
    else
        axis([-30 30 0 .75]);
        text(.5,.2,['Contacts ' num2str(length(totalkappa)-length(nocontact)) '/' num2str(length(totalkappa)) ],'VerticalAlignment','top','HorizontalAlignment','center');
        
    end
    subplot(numblocks*2,2,(blk-1)*2+3);
    plot(totalkappa,'ko','MarkerFaceColor','k'); xlabel('Trials');ylabel('TotalKappa');
    subplot(numblocks*2,2,(blk-1)*2+4);
    plot(maxkappa,'ko','MarkerFaceColor','k');  xlabel('Trials');ylabel('MaxKappa');
    
    
end

saveas(gcf,[fpath,filesep,fnam],'tif');
print(h2,'-dtiff','-painters','-loose',[fpath,filesep,fnam])
close(h2);

w_data.totalTouchKappa{blk}= {horzcat(trialnums,totalkappa')};
w_data.maxTouchKappa{blk}= {horzcat(trialnums,maxkappa')};
w_data.kappatrials{blk} = {kappa_trials};

%% plot fitted whisker
if(plot_whiskerfits)
    w = waitbar(0,'Plotting fitted whisker');
    h3 = figure('Name','fitted whisker','visible','off');
    set(0,'CurrentFigure',h3);
    
    for(blk=1:numblocks)
        
        trialnums = block_trialnums{blk};
        for(i=1:1:length(trialnums))
            t = trialnums(i);
            % %                 fittedX = obj{t}.polyFitsROI{1}{1};
            % %                 fittedY = obj{t}.polyFitsROI{1}{2};
            % %                 fittedQ = obj{t}.polyFitsROI{1}{3};
            
            fittedX = obj{t}.polyFits{1}{1};
            fittedY = obj{t}.polyFits{1}{2};
            xt =  obj{t}.time{1};
            frames = [1: length(fittedX)];
            %             xt =  frames*frameTime;
            frameInds= find(xt >= restrictTime(1) & xt <= restrictTime(2));
            %             cmap=jet(length(frameInds));
            
            nframes = length(frameInds);
            x = cell(1,nframes);
            y = cell(1,nframes);
            
            %             col=repmat(linspace(0,1,nframes)',1,3);
            %             col=repmat([1,.1,.1],nframes,1).*col;
            %             col = pmkmp(nframes,'LinearL');
            colors = othercolor();
            colmap = 'Mrainbow';
            col = othercolor(colmap,nframes);
            colormap(othercolor(colmap));
            barpos = obj{t}.bar_pos_trial;
            barpos(1,2) = point(1,2);
            for k=1:nframes
                f = frameInds(k);
                px = fittedX(f,:);
                py = fittedY(f,:);
                %                     pq = fittedQ(f,:);
                %                     q = linspace(pq(1),pq(2));
                q=linspace(0,1);
                
                x{k} = polyval(px,q);
                y{k} = polyval(py,q);
                
                plot(x{k},y{k},'color',col(k,:),'linewidth',1); axis ([0 520 0 400]);
                hold on;
            end
            
            
            p = (0:0.1:2*pi);
            r = 5;
            for(k=1:size(gopix,1))
                plot(r*sin(p)+gopix(k,1),r*cos(p)+gopix(k,2),'linewidth',1,'color','blue');
                hold on;
            end
            pr = zeros(1,size(gopix,1));
            %             pr(1:size(gopix,1)-1) = .0125;
            %             pr(size(gopix,1)) = .95;
            pr(:) = .2;
            mean_gopix = pr(1:5)*gopix(1:5,:);
            plot(r*sin(p)+barpos(1,1),r*cos(p)+barpos(1,2),'linewidth',4,'color','red');
            plot(r*sin(p)+nogopix(1,1),r*cos(p)+nogopix(1,2),'linewidth',1.5,'color','black');
            plot(r*sin(p)+mean_gopix(1,1),r*cos(p)+mean_gopix(1,2),'linewidth',2,'color','m');
            colorbar;
            filename = [obj{i}.mouseName ' S: ' obj{i}.sessionName ' T:'  num2str(obj{t}.trialNum) 'Trial ind' num2str(i)];
            filename = strrep(filename,'_',' ');
            title(gca,filename);
            set(gca,'YDir','reverse');
            hold off;
            %               colorbar('location','EastOutside');
            fnam=['w' obj{t}.trackerFileName(30:33) ];
            saveas(h3,[fpath,filesep,fnam],'tif');
            print(h3,'-depsc2','-painters','-loose',[fpath,filesep,fnam])
            msg=sprintf('Plotting %d of %d',i,length(trialnums));
            waitbar(i/(length(trialnums)+1),w,msg);
            %       set(f,'visible','on');
            
        end
    end
    
    close(w);
end
end

