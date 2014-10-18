function [collected_meaneffect]=plot_effect_vs_threshold()
    count = 0;    def = {'30'};
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
    
    collected_meaneffect{count}.eventrate = meaneffect.eventrate;
	collected_meaneffect{count}.intarea  = meaneffect.intarea(1,:);
    collected_meaneffect{count}.fwhm= meaneffect.peakamp(1,:);
	collected_meaneffect{count}.peakamp = meaneffect.fwhm(1,:); 
    
    collected_meaneffect{count}.alleventrate_NL = meaneffect.alleventrate_NL(:,1);
    collected_meaneffect{count}.alleventrate_L = meaneffect.alleventrate_L(:,1);
    
    collected_meaneffect{count}.allintarea_NL = meaneffect.allintarea_NL(:,1);
    collected_meaneffect{count}.allintarea_L = meaneffect.allintarea_L(:,1);
        
    collected_meaneffect{count}.allfwhm_NL = meaneffect.allfwhm_NL(:,1);
    collected_meaneffect{count}.allfwhm_L = meaneffect.allfwhm_L(:,1);
    
    collected_meaneffect{count}.allpeakamp_NL = meaneffect.allpeakamp_NL(:,1);
    collected_meaneffect{count}.allpeakamp_L = meaneffect.allpeakamp_L(:,1);
    
end

fname=['Event Rate Modulation'];
threshold = [30,50,100,150,200,250,300];
figure; plot(threshold,cell2mat(cellfun(@(x) x.eventrate, collected_meaneffect,'uniformoutput',0)),'linewidth',3)
title(fname);set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

figure; fname=['Event Rate '];
for i = 1:size(collected_meaneffect,2)
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{1,i}.alleventrate_NL,1));
    y=[collected_meaneffect{1,i}.alleventrate_NL(:,1)';collected_meaneffect{1,i}.alleventrate_L(:,1)'];
    plot(x,y,'b','linewidth',2);hold on;
    m = [nanmean(collected_meaneffect{1,i}.alleventrate_NL(:,1));nanmean(collected_meaneffect{1,i}.alleventrate_L(:,1))];
    sem=[nanstd(collected_meaneffect{1,i}.alleventrate_NL(:,1))/sqrt(length(collected_meaneffect{1,i}.alleventrate_NL(:,1)));...
        nanstd(collected_meaneffect{1,i}.alleventrate_L(:,1))/sqrt(length(collected_meaneffect{1,i}.alleventrate_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'k','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'k');
end
title(fname);set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

fname=['Int Area Modulation'];
threshold = [30,50,100,150,200,250,300];
figure; plot(threshold,cell2mat(cellfun(@(x) x.intarea(1,1), collected_meaneffect,'uniformoutput',0)),'linewidth',3);
axis([0 400 -100 100]);hline([0],'k--');
title(fname);set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

figure; fname=['Int Area '];
for i = 1:size(collected_meaneffect,2)
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{1,i}.allintarea_NL,1));
    y=[collected_meaneffect{1,i}.allintarea_NL(:,1)';collected_meaneffect{1,i}.allintarea_L(:,1)'];
    plot(x,y,'b','linewidth',2);hold on;
    m = [nanmean(collected_meaneffect{1,i}.allintarea_NL(:,1));nanmean(collected_meaneffect{1,i}.allintarea_L(:,1))];
    sem=[nanstd(collected_meaneffect{1,i}.allintarea_NL(:,1))/sqrt(length(collected_meaneffect{1,i}.allintarea_NL(:,1)));...
        nanstd(collected_meaneffect{1,i}.allintarea_L(:,1))/sqrt(length(collected_meaneffect{1,i}.allintarea_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'k','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'k');
end
title(fname);set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');


figure; fname=['Peak Amplitude Modulation'];
threshold = [30,50,100,150,200,250,300];
figure; plot(threshold,cell2mat(cellfun(@(x) x.peakamp(1,1), collected_meaneffect,'uniformoutput',0)),'linewidth',3);
axis([0 400 -50 50]);hline([0],'k--');
title(fname);set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');

figure; fname=['Peak Amplitude '];
for i = 1:size(collected_meaneffect,2)
    x=repmat([threshold(i)-10;threshold(i)+10],1,size(collected_meaneffect{1,i}.allpeakamp_NL,1));
    y=[collected_meaneffect{1,i}.allpeakamp_NL(:,1)';collected_meaneffect{1,i}.allpeakamp_L(:,1)'];
    plot(x,y,'b','linewidth',2);hold on;
    m = [nanmean(collected_meaneffect{1,i}.allpeakamp_NL(:,1));nanmean(collected_meaneffect{1,i}.allpeakamp_L(:,1))];
    sem=[nanstd(collected_meaneffect{1,i}.allpeakamp_NL(:,1))/sqrt(length(collected_meaneffect{1,i}.allpeakamp_NL(:,1)));...
        nanstd(collected_meaneffect{1,i}.allpeakamp_L(:,1))/sqrt(length(collected_meaneffect{1,i}.allpeakamp_L(:,1)))];
    plot([threshold(i)-10;threshold(i)+10],m,'k','Linewidth',3)
    errorbar([threshold(i)-10;threshold(i)+10],m,sem,'k');
end
title(fname);set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,filesep,fname],'jpg');
    

    
    
    