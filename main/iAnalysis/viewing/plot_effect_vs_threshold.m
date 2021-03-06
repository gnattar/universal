function [collected_meaneffect]=plot_effect_vs_threshold(grp,varargin)
count = 0;    def = {'30'};
if (nargin <2)
    while(count>=0)
        [filename,pathName]=uigetfile('*meaneffect*.mat','Load *meaneffect*.mat file');
        if isequal(filename, 0) || isequal(pathName,0)
            break
        end
        count=count+1;
        load( [pathName filesep filename], '-mat');
        cd (pathName);
        prompt={'Detection Threshold'};
        name='Threshold';
        numlines=1;
        d = inputdlg(prompt,name,numlines,def) ;
        def=d;
        collected_meaneffect{count}.threshold =str2num(d{1});
        
        collected_meaneffect{count}.intarea  = meaneffect.intarea(1,:);
        collected_meaneffect{count}.fwhm= meaneffect.peakamp(1,:);
        collected_meaneffect{count}.peakamp = meaneffect.fwhm(1,:);
        
        collected_meaneffect{count}.alleventrate_NL = meaneffect.alleventrate_NL(:,1);
        collected_meaneffect{count}.alleventrate_L = meaneffect.alleventrate_L(:,1);
        
        collected_meaneffect{count}.eventrate =  (mean(meaneffect.alleventrate_NL(:,1))- mean(meaneffect.alleventrate_L(:,1)))/mean(meaneffect.alleventrate_NL(:,1));
        
        collected_meaneffect{count}.allintarea_NL = meaneffect.allintarea_NL(:,1);
        collected_meaneffect{count}.allintarea_L = meaneffect.allintarea_L(:,1);
        
        collected_meaneffect{count}.allfwhm_NL = meaneffect.allfwhm_NL(:,1);
        collected_meaneffect{count}.allfwhm_L = meaneffect.allfwhm_L(:,1);
        
        collected_meaneffect{count}.allpeakamp_NL = meaneffect.allpeakamp_NL(:,1);
        collected_meaneffect{count}.allpeakamp_L = meaneffect.allpeakamp_L(:,1);
        
    end
else
    collected_meaneffect = varargin{1};
    for i = 1:size(collected_meaneffect,2)
    collected_meaneffect{i}.eventrate =  (mean(collected_meaneffect{i}.alleventrate_NL(:,1))-mean(collected_meaneffect{i}.alleventrate_L(:,1)))/mean(collected_meaneffect{i}.alleventrate_NL(:,1));
    end
end
threshold = [30,50,100,150,200,250,300];
 kstest_hp = zeros(size(collected_meaneffect,2),2); % hyp prob
figure; fname=['Event Rate ' grp];
for i = 1:size(collected_meaneffect,2)
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{i}.alleventrate_NL,1));
    y=[collected_meaneffect{i}.alleventrate_NL(:,1)';collected_meaneffect{i}.alleventrate_L(:,1)'];
    plot(x,y,'k','linewidth',1.5);hold on;
    m = [nanmean(collected_meaneffect{i}.alleventrate_NL(:,1));nanmean(collected_meaneffect{i}.alleventrate_L(:,1))];
    sem=[nanstd(collected_meaneffect{i}.alleventrate_NL(:,1))/sqrt(length(collected_meaneffect{i}.alleventrate_NL(:,1)));...
        nanstd(collected_meaneffect{i}.alleventrate_L(:,1))/sqrt(length(collected_meaneffect{i}.alleventrate_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'r','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'r');
    [h,p] = ttest(collected_meaneffect{i}.alleventrate_NL(:,1),collected_meaneffect{i}.alleventrate_L(:,1));
    kstest_hp(i,:) = [h,p];
end
title(fname);
xlabel('Detection Threshold'); ylabel('Event rate No Light - Light');
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

fname=['Event Rate Modulation ' grp];
figure; plot(threshold,cell2mat(cellfun(@(x) x.eventrate, collected_meaneffect,'uniformoutput',0)),'k-o','linewidth',3) ;
hold on;
temp = cell2mat(cellfun(@(x) x.eventrate, collected_meaneffect,'uniformoutput',0));
temp(kstest_hp(:,1)==0) = nan;
plot(threshold,temp,'ro','MarkerSize',15,'MarkerFaceColor','r');
title(fname);
xlabel('Detection Threshold'); ylabel('Fractional change in Event rate');
set(findall(gcf,'type','text'),'FontSize',20);
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');


figure; fname=['Int Area ' grp ];
for i = 1:size(collected_meaneffect,2)    
    collected_meaneffect{i}.allintarea_NL((collected_meaneffect{i}.allfwhm_NL(:,1) > 5),1) = nan;
    collected_meaneffect{i}.allintarea_L((collected_meaneffect{i}.allfwhm_L(:,1) > 5),1) = nan;  
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{i}.allintarea_NL,1));
    y=[collected_meaneffect{i}.allintarea_NL(:,1)';collected_meaneffect{i}.allintarea_L(:,1)'];
    plot(x,y,'k','linewidth',2);hold on;
    m = [nanmean(collected_meaneffect{i}.allintarea_NL(:,1));nanmean(collected_meaneffect{i}.allintarea_L(:,1))];
    sem=[nanstd(collected_meaneffect{i}.allintarea_NL(:,1))/sqrt(length(collected_meaneffect{i}.allintarea_NL(:,1)));...
        nanstd(collected_meaneffect{i}.allintarea_L(:,1))/sqrt(length(collected_meaneffect{i}.allintarea_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'r','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'r');
    [h,p]= ttest(collected_meaneffect{i}.allintarea_NL(:,1),collected_meaneffect{i}.allintarea_L(:,1));
    kstest_hp(i,:) = [h,p];
end
title(fname);
xlabel('Detection Threshold'); ylabel(' Int Area, No Light - Light');
set(findall(gcf,'type','text'),'FontSize',20);
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

fname=['Int Area Modulation ' grp];
threshold = [30,50,100,150,200,250,300];
figure; plot(threshold,cell2mat(cellfun(@(x) x.intarea(1,1), collected_meaneffect,'uniformoutput',0)),'k-o','linewidth',3);
hold on;
temp = cell2mat(cellfun(@(x) x.intarea(1,1), collected_meaneffect,'uniformoutput',0));
temp(kstest_hp(:,1)==0) = nan;
plot(threshold,temp,'ro','MarkerSize',15,'MarkerFaceColor','r');
axis([0 400 -200 50]);hline([0],'k--');
title(fname);
xlabel('Detection Threshold'); ylabel('Change in Int Area');
set(findall(gcf,'type','text'),'FontSize',20);
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');


figure; fname=['Peak Amplitude ' grp];
for i = 1:size(collected_meaneffect,2)
    collected_meaneffect{i}.allpeakamp_NL((collected_meaneffect{i}.allfwhm_NL(:,1) > 5),1) = nan;
    collected_meaneffect{i}.allpeakamp_L((collected_meaneffect{i}.allfwhm_L(:,1) > 5),1) = nan;
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{i}.allpeakamp_NL,1));
    y=[collected_meaneffect{i}.allpeakamp_NL(:,1)';collected_meaneffect{i}.allpeakamp_L(:,1)'];
    plot(x,y,'k','linewidth',2);hold on;
    m = [nanmean(collected_meaneffect{i}.allpeakamp_NL(:,1));nanmean(collected_meaneffect{i}.allpeakamp_L(:,1))];
    sem=[nanstd(collected_meaneffect{i}.allpeakamp_NL(:,1))/sqrt(length(collected_meaneffect{i}.allpeakamp_NL(:,1)));...
        nanstd(collected_meaneffect{i}.allpeakamp_L(:,1))/sqrt(length(collected_meaneffect{i}.allpeakamp_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'r','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'r');
    [h,p]  = ttest(collected_meaneffect{i}.allpeakamp_NL(:,1),collected_meaneffect{i}.allpeakamp_L(:,1));
    kstest_hp(i,:) = [h,p];
end
title(fname);
xlabel('Detection Threshold'); ylabel(' Amplitude, No Light - Light');
set(findall(gcf,'type','text'),'FontSize',20);
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

figure; fname=['Peak Amplitude Modulation' grp];
threshold = [30,50,100,150,200,250,300];
figure; plot(threshold,cell2mat(cellfun(@(x) x.peakamp(1,1), collected_meaneffect,'uniformoutput',0)),'k-o','linewidth',3);
hold on;
temp = cell2mat(cellfun(@(x) x.peakamp(1,1), collected_meaneffect,'uniformoutput',0));
temp(kstest_hp(:,1)==0) = nan;
plot(threshold,temp,'ro','MarkerSize',15,'MarkerFaceColor','r');
axis([0 400 -100 100]);hline([0],'k--');
title(fname);
xlabel('Detection Threshold'); ylabel('Change in Peak Amplitude');
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');


figure; fname=['FWHM ' grp];
for i = 1:size(collected_meaneffect,2)
    collected_meaneffect{i}.allfwhm_NL((collected_meaneffect{i}.allfwhm_NL(:,1) > 5),1) = nan;
    collected_meaneffect{i}.allfwhm_L((collected_meaneffect{i}.allfwhm_L(:,1) > 5),1) = nan;
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{i}.allfwhm_NL,1));
    y=[collected_meaneffect{i}.allfwhm_NL(:,1)';collected_meaneffect{i}.allfwhm_L(:,1)'];
    plot(x,y,'k','linewidth',2);hold on;
    m = [nanmean(collected_meaneffect{i}.allfwhm_NL(:,1));nanmean(collected_meaneffect{i}.allfwhm_L(:,1))];
    sem=[nanstd(collected_meaneffect{i}.allfwhm_NL(:,1))/sqrt(length(collected_meaneffect{i}.allfwhm_NL(:,1)));...
        nanstd(collected_meaneffect{i}.allfwhm_L(:,1))/sqrt(length(collected_meaneffect{i}.allfwhm_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'r','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'r');
    [h,p] = ttest(collected_meaneffect{i}.allfwhm_NL(:,1),collected_meaneffect{i}.allfwhm_L(:,1));
    kstest_hp(i,:) = [h,p];
end
title(fname);
xlabel('Detection Threshold'); ylabel(' Duration (fwhm) , No Light - Light');
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

figure; fname=['zFWHM Modulation' grp];
threshold = [30,50,100,150,200,250,300];
figure; plot(threshold,cell2mat(cellfun(@(x) x.fwhm(1,1), collected_meaneffect,'uniformoutput',0)),'k-o','linewidth',3);
hold on;
temp = cell2mat(cellfun(@(x) x.fwhm(1,1), collected_meaneffect,'uniformoutput',0));
temp(kstest_hp(:,1)==0) = nan;
plot(threshold,temp,'ro','MarkerSize',15,'MarkerFaceColor','r');
axis([0 400 -100 100]);hline([0],'k--');
title(fname);
xlabel('Detection Threshold'); ylabel('Change in Duration (fwhm)');
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');
close all;
