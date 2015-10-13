function [meaneffect] = plotlighteffect_final(pooled_contact_CaTrials,grp,par,sel)
% [meaneffect] = plotlighteffect_final(pooled_contact_CaTrials,grp,par,sel)
% par can be 'peak' or 'area'
% sel can be 'all' or 'events'
save([grp 'pooled_contact_CaTrials'],'pooled_contact_CaTrials');
tosave =1;
%% script to plot Light Nl Light conditions
meaneffect.alleventrate_NL= cell2mat(cellfun(@(x) x.eventrate_NL, pooled_contact_CaTrials,'uniformoutput',0))';
meaneffect.alleventrate_L = cell2mat(cellfun(@(x) x.eventrate_L, pooled_contact_CaTrials,'uniformoutput',0))';

meaneffect.allintarea_NL(:,1) = cell2mat(cellfun(@(x) x.intarea_NL(1,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allintarea_L(:,1) = cell2mat(cellfun(@(x) x.intarea_L(1,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allintarea_NL(:,2) = cell2mat(cellfun(@(x) x.intarea_NL(2,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allintarea_L(:,2)= cell2mat(cellfun(@(x) x.intarea_L(2,1), pooled_contact_CaTrials,'uniformoutput',0));


meaneffect.allfwhm_NL (:,1)= cell2mat(cellfun(@(x) x.fwhm_NL(1,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allfwhm_L (:,1) = cell2mat(cellfun(@(x) x.fwhm_L(1,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allfwhm_NL (:,2)= cell2mat(cellfun(@(x) x.fwhm_NL(2,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allfwhm_L (:,2) = cell2mat(cellfun(@(x) x.fwhm_L(2,1), pooled_contact_CaTrials,'uniformoutput',0));

meaneffect.allpeakamp_NL(:,1) = cell2mat(cellfun(@(x) x.peakamp_NL(1,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allpeakamp_L(:,1) = cell2mat(cellfun(@(x) x.peakamp_L(1,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allpeakamp_NL(:,2) = cell2mat(cellfun(@(x) x.peakamp_NL(2,1), pooled_contact_CaTrials,'uniformoutput',0));
meaneffect.allpeakamp_L(:,2)= cell2mat(cellfun(@(x) x.peakamp_L(2,1), pooled_contact_CaTrials,'uniformoutput',0));

meaneffect.eventrate = mean(meaneffect.alleventrate_NL)-mean(meaneffect.alleventrate_L)/mean(meaneffect.alleventrate_NL);
meaneffect.intarea = nanmean(meaneffect.allintarea_L) - nanmean(meaneffect.allintarea_NL);
meaneffect.fwhm = nanmean(meaneffect.allfwhm_L)/nanmean(meaneffect.allfwhm_NL);
meaneffect.peakamp = nanmean(meaneffect.allpeakamp_L) - nanmean(meaneffect.allpeakamp_NL);

save([grp 'meaneffect'],'meaneffect');

figure;fnam = [ grp ' Event Probability Bar '];
% plot(meaneffect.alleventrate_L(:,1),meaneffect.alleventrate_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');hold on; plot([0:1],[0:1],'k--')
hold on; h= bar([1],[nanmean(meaneffect.alleventrate_NL(:,1))],0.25,'k');
hold on; h= bar([1.5],[nanmean(meaneffect.alleventrate_L(:,1))],0.25,'r');
h=errorbar([1;1.5],[nanmean(meaneffect.alleventrate_NL(:,1));nanmean(meaneffect.alleventrate_L(:,1))],[nanstd(meaneffect.alleventrate_NL(:,1))/sqrt(size(meaneffect.alleventrate_NL,1)); nanstd(meaneffect.alleventrate_L(:,1))/sqrt(size(meaneffect.alleventrate_L,1))],'.r');
axis([ .5 2 0 0.4]);
set(h, 'linewidth',0.2,'Markersize',1,'Markerfacecolor','k');

set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:.1:1]);
ylabel('Event Probability'); title(fnam)
set(findall(gcf,'type','text'),'FontSize',20);
set(gcf,'PaperUnits','inches');
currposition = get(gcf,'paperposition');
currposition(3) = currposition(3)/2;
set(gcf,'paperposition',currposition);
set(gcf, 'PaperSize', [24,10]);
set(gcf,'PaperPositionMode','manual');
if tosave
    saveas(gcf,[pwd,filesep,fnam],'fig');
    print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
end

figure;fnam = [ grp ' Event Probability '];
x = ones(size(meaneffect.alleventrate_L,1),2);x(:,2) = 1.5;
hold on;
plot(x',[meaneffect.alleventrate_NL(:,1)';meaneffect.alleventrate_L(:,1)'],'-o','color',[ .5 .5 .5], 'Markersize',10,'linewidth',.1);hold on;set(gca,'ticklength',[.025 .025]);
hold on;
h=errorbar([1;1.5],[nanmean(meaneffect.alleventrate_NL(:,1));nanmean(meaneffect.alleventrate_L(:,1))],[nanstd(meaneffect.alleventrate_NL(:,1))/sqrt(size(meaneffect.alleventrate_NL,1)); nanstd(meaneffect.alleventrate_L(:,1))/sqrt(size(meaneffect.alleventrate_L,1))],'or');
set(h, 'linewidth',0.2,'Markersize',10);
axis([ .5 2 0 1.0]);
set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:.1:1]);
ylabel('Event Probability'); title(fnam)
set(findall(gcf,'type','text'),'FontSize',20);
set(gcf,'PaperUnits','inches');
currposition = get(gcf,'paperposition');
currposition(3) = currposition(3)/2;
set(gcf,'paperposition',currposition);
set(gcf, 'PaperSize', [24,10]);
set(gcf,'PaperPositionMode','manual');
if tosave
    saveas(gcf,[pwd,filesep,fnam],'fig');
    print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
end
% figure;fnam = [ grp 'FWHM Scatter'];
% plot(meaneffect.allfwhm_L(:,1),meaneffect.allfwhm_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
% axis([0 5 0 5]);xlabel('FWHM Light'); ylabel('FWHM No Light'); title(fnam)
% set(findall(gcf,'type','text'),'FontSize',20)
% hold on; plot([0:5],[0:5],'k--')
% axes('Position',[.7 .7 .2 .2])
% box on
% errorbarxy(meaneffect.allfwhm_L(:,1),meaneffect.allfwhm_NL(:,1),meaneffect.allfwhm_L(:,2),meaneffect.allfwhm_NL(:,2),{'bo','k','r'});axis ([0 5 0 5]);hold on; plot([0:5],[0:5],'k--')
% saveas(gcf,[pwd,filesep,fnam],'jpg');

if strcmp(par,'area')
    
    figure;fnam = [ grp 'Event Integral Area Bar'];
    hold on; bar([1],[nanmean(meaneffect.allintarea_NL(:,1))],0.25,'k');
    hold on; bar([1.5],[nanmean(meaneffect.allintarea_L(:,1))],0.25,'r');
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allintarea_NL(:,1));nanmean(meaneffect.allintarea_L(:,1))],[nanstd(meaneffect.allintarea_NL(:,1))/sqrt(size(meaneffect.allintarea_NL,1));nanstd(meaneffect.allintarea_L(:,1))/sqrt(size(meaneffect.allintarea_L,1))],'.r');
    set(h, 'linewidth',0.2,'Markersize',1,'Markerfacecolor','k');
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    axis([ .5 2 0 200]);
    ylabel('Event Size (Integral Area) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    % plot(meaneffect.allintarea_L(:,1),meaneffect.allintarea_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
    figure;fnam = [ grp 'Event Integral Area '];
    hold on; plot(x',[meaneffect.allintarea_NL(:,1)';meaneffect.allintarea_L(:,1)'],'-o','color',[.5 .5 .5], 'Markersize',10);hold on;
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allintarea_NL(:,1));nanmean(meaneffect.allintarea_L(:,1))],[nanstd(meaneffect.allintarea_NL(:,1))/sqrt(size(meaneffect.allintarea_NL,1));nanstd(meaneffect.allintarea_L(:,1))/sqrt(size(meaneffect.allintarea_L,1))],'or');
    set(gca,'ticklength',[.025 .025]);
    axis([ .5 2 0 200]);
    set(h, 'linewidth',0.2,'Markersize',10);
    
    
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    ylabel('Event Size (Integral Area) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    %
    
    
    
    figure;fnam = [ grp 'Integral Area Bar'];
    hold on; bar([1],[nanmean(meaneffect.allintarea_NL(:,1))],0.25,'k');
    hold on; bar([1.5],[nanmean(meaneffect.allintarea_L(:,1))],0.25,'r');
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allintarea_NL(:,1));nanmean(meaneffect.allintarea_L(:,1))],[nanstd(meaneffect.allintarea_NL(:,1))/sqrt(size(meaneffect.allintarea_NL,1));nanstd(meaneffect.allintarea_L(:,1))/sqrt(size(meaneffect.allintarea_L,1))],'.r');
    set(h, 'linewidth',0.2,'Markersize',1,'Markerfacecolor','k');
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    axis([ .5 2 0 200]);
    ylabel('Event Size (Integral Area) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    % plot(meaneffect.allintarea_L(:,1),meaneffect.allintarea_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
    figure;fnam = [ grp 'Event Integral Area '];
    hold on; plot(x',[meaneffect.allintarea_NL(:,1)';meaneffect.allintarea_L(:,1)'],'-o','color',[.5 .5 .5], 'Markersize',10);hold on;
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allintarea_NL(:,1));nanmean(meaneffect.allintarea_L(:,1))],[nanstd(meaneffect.allintarea_NL(:,1))/sqrt(size(meaneffect.allintarea_NL,1));nanstd(meaneffect.allintarea_L(:,1))/sqrt(size(meaneffect.allintarea_L,1))],'or');
    set(gca,'ticklength',[.025 .025]);
    axis([ .5 2 0 200]);
    set(h, 'linewidth',0.2,'Markersize',10);
    
    
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    ylabel('Event Size (Integral Area) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    
elseif strcmp(par,'peak')
    
    figure;fnam = [ grp 'Event Peak Amplitude Bar'];
    hold on; bar([1],[nanmean(meaneffect.allpeakamp_NL(:,1))],0.25,'k');
    hold on; bar([1.5],[nanmean(meaneffect.allpeakamp_L(:,1))],0.25,'r');
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allpeakamp_NL(:,1));nanmean(meaneffect.allpeakamp_L(:,1))],[nanstd(meaneffect.allpeakamp_NL(:,1))/sqrt(size(meaneffect.allpeakamp_NL,1));nanstd(meaneffect.allpeakamp_L(:,1))/sqrt(size(meaneffect.allpeakamp_L,1))],'.r');
    set(h, 'linewidth',0.2,'Markersize',1,'Markerfacecolor','k');
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    axis([ .5 2 0 200]);
    ylabel('Event Amplitude (Peak) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    % plot(meaneffect.allintarea_L(:,1),meaneffect.allintarea_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
    figure;fnam = [ grp 'Event Peak Amp '];
    hold on; plot(x',[meaneffect.allpeakamp_NL(:,1)';meaneffect.allpeakamp_L(:,1)'],'-o','color',[.5 .5 .5], 'Markersize',10);hold on;
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allpeakamp_NL(:,1));nanmean(meaneffect.allpeakamp_L(:,1))],[nanstd(meaneffect.allpeakamp_NL(:,1))/sqrt(size(meaneffect.allpeakamp_NL,1));nanstd(meaneffect.allpeakamp_L(:,1))/sqrt(size(meaneffect.allpeakamp_L,1))],'or');
    set(gca,'ticklength',[.025 .025]);
    axis([ .5 2 0 200]);
    set(h, 'linewidth',0.2,'Markersize',10);
    
    
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    ylabel('Event Amplitude (Peak) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    %
    
    
    
    figure;fnam = [ grp 'Peak Amplitude Bar'];
    hold on; bar([1],[nanmean(meaneffect.allpeakamp_NL(:,1))],0.25,'k');
    hold on; bar([1.5],[nanmean(meaneffect.allpeakamp_L(:,1))],0.25,'r');
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allpeakamp_NL(:,1));nanmean(meaneffect.allpeakamp_L(:,1))],[nanstd(meaneffect.allpeakamp_NL(:,1))/sqrt(size(meaneffect.allpeakamp_NL,1));nanstd(meaneffect.allpeakamp_L(:,1))/sqrt(size(meaneffect.allpeakamp_L,1))],'.r');
    set(h, 'linewidth',0.2,'Markersize',1,'Markerfacecolor','k');
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    axis([ .5 2 0 200]);
    ylabel('Event Amplitude (Peak) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    % plot(meaneffect.allintarea_L(:,1),meaneffect.allintarea_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
    figure;fnam = [ grp 'Event Amplitude  '];
    hold on; plot(x',[meaneffect.allpeakamp_NL(:,1)';meaneffect.allpeakamp_L(:,1)'],'-o','color',[.5 .5 .5], 'Markersize',10);hold on;
    hold on; h=errorbar([1;1.5],[nanmean(meaneffect.allpeakamp_NL(:,1));nanmean(meaneffect.allpeakamp_L(:,1))],[nanstd(meaneffect.allpeakamp_NL(:,1))/sqrt(size(meaneffect.allpeakamp_NL,1));nanstd(meaneffect.allpeakamp_L(:,1))/sqrt(size(meaneffect.allpeakamp_L,1))],'or');
    set(gca,'ticklength',[.025 .025]);
    axis([ .5 2 0 200]);
    set(h, 'linewidth',0.2,'Markersize',10);
    
    
    set(gca,'XTick',[1 2],'XTickLabel',{'NL','L'},'YTick',[0:100:800]);
    ylabel('Event Amplitude (Peak) '); title(fnam)
    set(findall(gcf,'type','text'),'FontSize',20)
    
    set(gcf,'PaperUnits','inches');
    currposition = get(gcf,'paperposition');
    currposition(3) = currposition(3)/2;
    set(gcf,'paperposition',currposition);
    set(gcf, 'PaperSize', [24,10]);
    set(gcf,'PaperPositionMode','manual');
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    
    
end


% figure;fnam = [ grp 'Peak Amp Scatter'];
% plot(meaneffect.allpeakamp_L(:,1),meaneffect.allpeakamp_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
% axis([0 600 0 600]);xlabel('Peak Amp Light'); ylabel('Peak Amp No Light'); title(fnam)
% set(findall(gcf,'type','text'),'FontSize',20)
% hold on; plot([0:600],[0:600],'k--')
% axes('Position',[.7 .7 .2 .2])
% box on
% errorbarxy(meaneffect.allpeakamp_L(:,1),meaneffect.allpeakamp_NL(:,1),meaneffect.allpeakamp_L(:,2),meaneffect.allpeakamp_NL(:,2),{'bo','k','r'}); axis([0 600 0 600]);hold on; plot([0:600],[0:600],'k--')
% saveas(gcf,[pwd,filesep,fnam],'jpg');

%% histograms of trial data from all dends

intarea_trials = cell2mat(cellfun(@(x) x.intarea (:,1),pooled_contact_CaTrials,'uniformoutput',0)');
lightstim_trials = cell2mat(cellfun(@(x) x.lightstim (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
peakamp_trials = cell2mat(cellfun(@(x) x.peakamp (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
fwhm_trials = cell2mat(cellfun(@(x) x.fwhm (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
eventsdetected_trials = cell2mat(cellfun(@(x) x.eventsdetected (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');


%
%  intarea_trials(eventsdetected_trials==0) = 0;
%  peakamp_trials(eventsdetected_trials==0) = 0;
%  fwhm_trials(eventsdetected_trials==0) = 0;

meaneffect.eventrate_X_hist = [0:.05:1];
meaneffect.eventrate_NL_hist=hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist)/sum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist));
meaneffect.eventrate_L_hist=hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist)/sum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist));



figure;fnam = [ grp ' Event Prob Histogram '];
plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_L_hist,'r','linewidth',1.5); hold on; plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_NL_hist,'k','linewidth',1.5);xlabel(' Event Probability');ylabel('Fraction of Dendrites'); title(fnam);
% text(.6,.2,[ 'Shift = ' num2str(meaneffect.eventrate_X_hist(meaneffect.eventrate_L_hist == 0.5) - meaneffect.eventrate_X_hist(meaneffect.eventrate_NL_hist == 0.5))] );
set(gca,'ticklength',[.025 .025]);
legend({'L';'NL'});set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

meaneffect.eventrate_NL_hist=cumsum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist));meaneffect.eventrate_L_hist=cumsum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist));

meaneffect.eventrate_X_hist = [0:.05:1];
meaneffect.eventrate_NL_hist=cumsum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist)/sum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist)));meaneffect.eventrate_L_hist=cumsum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist)/sum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist)));
figure;fnam = [ grp ' Event Prob Cumulative Histogram'];
plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_L_hist,'r','linewidth',1.5); hold on; plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_NL_hist,'k','linewidth',1.5);xlabel('Cumulative Event Probability');ylabel('Fraction of Dendrites'); title(fnam);axis ([0 1 0 1]);
% text(.6,.2,[ 'Shift = ' num2str(meaneffect.eventrate_X_hist(meaneffect.eventrate_L_hist == 0.5) - meaneffect.eventrate_X_hist(meaneffect.eventrate_NL_hist == 0.5))] );
set(gca,'ticklength',[.025 .025]);
set(findall(gcf,'type','text'),'FontSize',20); legend({'L';'NL'});
if tosave
    saveas(gcf,[pwd,filesep,fnam],'fig');
    print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
end

if strcmp(sel,'all')
    intarea_trials_L= intarea_trials(lightstim_trials==1);
    intarea_trials_NL= intarea_trials(lightstim_trials==0);
    peakamp_trials_L= peakamp_trials(lightstim_trials==1);
    peakamp_trials_NL= peakamp_trials(lightstim_trials==0);
elseif strcmp(sel,'events')
    intarea_trials_L= intarea_trials(eventsdetected_trials&lightstim_trials);
    intarea_trials_NL= intarea_trials(eventsdetected_trials & ~lightstim_trials);
    peakamp_trials_L= peakamp_trials(eventsdetected_trials&lightstim_trials);
    peakamp_trials_NL= peakamp_trials(eventsdetected_trials & ~lightstim_trials);
end


meaneffect.intarea_trials = intarea_trials;
meaneffect.intarea_trials_L_NE = intarea_trials(~eventsdetected_trials&lightstim_trials);
meaneffect.intarea_trials_NL_NE = intarea_trials(~eventsdetected_trials&~lightstim_trials);

meaneffect.intarea_trials = intarea_trials;
meaneffect.intarea_trials_L_NE = intarea_trials(~eventsdetected_trials&lightstim_trials);
meaneffect.intarea_trials_NL_NE = intarea_trials(~eventsdetected_trials&~lightstim_trials);

meaneffect.eventsdetected_trials = eventsdetected_trials;
meaneffect.lightstim_trials = lightstim_trials;

meaneffect.intarea_trials_L = intarea_trials_L;
meaneffect.intarea_trials_NL = intarea_trials_NL;

meaneffect.peakamp_trials_L = peakamp_trials_L;
meaneffect.peakamp_trials_NL = peakamp_trials_NL;

meaneffect.trials_L= sum(lightstim_trials==1);
meaneffect.trials_NL= sum(lightstim_trials==0);
meaneffect.event_trials_L= sum(lightstim_trials&eventsdetected_trials);
meaneffect.event_trials_NL= sum(~lightstim_trials&eventsdetected_trials);


if strcmp(par,'area')
    ia_t_X_hist =[0:25:600];
    if strcmp(sel,'all')
        ia_t_L_hist = hist(intarea_trials_L,ia_t_X_hist)/length(intarea_trials_L);
        ia_t_NL_hist = hist(intarea_trials_NL,ia_t_X_hist)/length(intarea_trials_NL);
    elseif strcmp(sel,'events')
        ia_t_L_hist = hist(intarea_trials_L,ia_t_X_hist)/sum(lightstim_trials==1);
        ia_t_NL_hist = hist(intarea_trials_NL,ia_t_X_hist)/sum(lightstim_trials==0);
    end
    figure;fnam = [ grp ' Event Size (Integral Area) Histogram'];
    plot(ia_t_X_hist,ia_t_L_hist,'r','linewidth',1.5);hold on; plot(ia_t_X_hist,ia_t_NL_hist,'k','linewidth',1.5);xlabel('Event Size');ylabel('Probabiity of Event Size'); title(fnam);
    set(gca,'ticklength',[.025 .025]);
    temp = [ 50 100 200 300];
    vline(temp,'k .-.');
    msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials (' num2str(sum(eventsdetected_trials&lightstim_trials)/sum(lightstim_trials==1)) ') L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials  (' num2str(sum(eventsdetected_trials&~lightstim_trials)/sum(lightstim_trials==0)) ')NL']);
    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
    set(findall(gcf,'type','text'),'FontSize',20); legend({'L';'NL'});text(350,.05,msg);
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    ia_t_L_hist = cumsum(hist(intarea_trials_L,ia_t_X_hist)/sum(lightstim_trials==1));
    ia_t_NL_hist = cumsum(hist(intarea_trials_NL,ia_t_X_hist)/sum(lightstim_trials==0));
    figure;fnam = [ grp 'Event Size (Integral Area) Cumulative Histogram'];
    plot(ia_t_X_hist,ia_t_L_hist,'r','linewidth',1.5);hold on; plot(ia_t_X_hist,ia_t_NL_hist,'k','linewidth',1.5);xlabel('Event Size');ylabel('Probability of Event Size'); title(fnam);
    % text(500,.2,[ 'Shift = ' num2str(sum(ia_t_L_hist - ia_t_NL_hist))]);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
    set(gca,'ticklength',[.025 .025]);
    temp = [ 50 100 200 300];
    vline(temp,'k .-.');
    % hline(ia_t_NL_hist(ismember(ia_t_X_hist,temp)),'k--');
    % hline(ia_t_L_hist(ismember(ia_t_X_hist,temp)),'r--');
    msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L  (' num2str(sum(eventsdetected_trials&lightstim_trials)/sum(lightstim_trials==1)) ')\n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL (' num2str(sum(eventsdetected_trials&~lightstim_trials)/sum(lightstim_trials==0)) ')']);
    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
    set(findall(gcf,'type','text'),'FontSize',20); legend({'L';'NL'});text(350,.1,msg);
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    
elseif strcmp(par,'peak')
    pa_t_X_hist =[0:25:600];
    if strcmp(sel,'all')
        pa_t_L_hist = hist(peakamp_trials_L,pa_t_X_hist)/length(peakamp_trials_L);
        pa_t_NL_hist = hist(peakamp_trials_NL,pa_t_X_hist)/length(peakamp_trials_NL);
    elseif strcmp(sel,'events')
        pa_t_L_hist = hist(peakamp_trials_L,pa_t_X_hist)/sum(lightstim_trials==1);
        pa_t_NL_hist = hist(peakamp_trials_NL,pa_t_X_hist)/sum(lightstim_trials==0);
    end
    
    figure;fnam = [ grp ' Event Amp (Peak) Histogram'];
    plot(pa_t_X_hist,pa_t_L_hist,'r','linewidth',1.5);hold on; plot(pa_t_X_hist,pa_t_NL_hist,'k','linewidth',1.5);xlabel('Event Amp');ylabel('Probabiity of Event Size'); title(fnam);
    set(gca,'ticklength',[.025 .025]);
    temp = [ 50 100 200 300];
    vline(temp,'k .-.');
    msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials (' num2str(sum(eventsdetected_trials&lightstim_trials)/sum(lightstim_trials==1)) ') L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials  (' num2str(sum(eventsdetected_trials&~lightstim_trials)/sum(lightstim_trials==0)) ')NL']);
    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
    set(findall(gcf,'type','text'),'FontSize',20); legend({'L';'NL'});text(350,.05,msg);
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    pa_t_L_hist = cumsum(hist(peakamp_trials_L,pa_t_X_hist)/sum(lightstim_trials==1));
    pa_t_NL_hist = cumsum(hist(peakamp_trials_NL,pa_t_X_hist)/sum(lightstim_trials==0));
    figure;fnam = [ grp 'Event Amplitude (Peak) Cumulative Histogram'];
    plot(pa_t_X_hist,pa_t_L_hist,'r','linewidth',1.5);hold on; plot(pa_t_X_hist,pa_t_NL_hist,'k','linewidth',1.5);xlabel('Event Amp');ylabel('Probability of Event Size'); title(fnam);
    % text(500,.2,[ 'Shift = ' num2str(sum(ia_t_L_hist - ia_t_NL_hist))]);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
    set(gca,'ticklength',[.025 .025]);
    temp = [ 50 100 200 300];
    vline(temp,'k .-.');
    % hline(ia_t_NL_hist(ismember(ia_t_X_hist,temp)),'k--');
    % hline(ia_t_L_hist(ismember(ia_t_X_hist,temp)),'r--');
    msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L  (' num2str(sum(eventsdetected_trials&lightstim_trials)/sum(lightstim_trials==1)) ')\n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL (' num2str(sum(eventsdetected_trials&~lightstim_trials)/sum(lightstim_trials==0)) ')']);
    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
    set(findall(gcf,'type','text'),'FontSize',20); legend({'L';'NL'});text(350,.1,msg);
    if tosave
        saveas(gcf,[pwd,filesep,fnam],'fig');
        print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
    end
    
    
end

for d = 1:length(pooled_contact_CaTrials)
ls = pooled_contact_CaTrials{d}.lightstim;
if strcmp(par,'peak')
    pa = pooled_contact_CaTrials{d}.peakamp;
elseif strcmp(par,'area')
 pa = pooled_contact_CaTrials{d}.intarea;
end
avgresp(d,1) = nanmean(pa(ls==0));
avgresp(d,2) = nanmean(pa(ls==1));
end
m=nanmean(avgresp);
s=nanstd(avgresp)./sqrt(size(avgresp,1)+1);
figure;plot(avgresp','color',[.5 .5 .5]);hold on
e=errorbar(m,s,'ko-');
set(e,'markersize',10,'linewidth',1.5)
axis([0 3 0 140]);
set(gca,'Xtick',[1 2],'Xticklabel',{'NL','L'});
[h,p]=ttest(avgresp(:,1),avgresp(:,2))
text(1.75,100,['p=' num2str(p)]);
title('Average Resp' )

% intarea_trials_L= intarea_trials(eventsdetected_trials&lightstim_trials);
% intarea_trials_NL= intarea_trials(eventsdetected_trials & ~lightstim_trials);
% ia_t_X_hist =[0:50:800];
% ia_t_L_hist = cumsum(hist(intarea_trials_L,ia_t_X_hist)/sum(hist(intarea_trials_L,ia_t_X_hist)));
% ia_t_NL_hist = cumsum(hist(intarea_trials_NL,ia_t_X_hist)/sum(hist(intarea_trials_NL,ia_t_X_hist)));
% figure;fnam = [ grp 'Int Area Cumulative Hist Norm'];
% plot(ia_t_X_hist,ia_t_L_hist,'r','linewidth',1.5);hold on; plot(ia_t_X_hist,ia_t_NL_hist,'k','linewidth',1.5);xlabel('IntArea');ylabel('Counts'); title(fnam);axis([0 800 0 1]);
% % text(500,.2,[ 'Shift = ' num2str(sum(ia_t_L_hist - ia_t_NL_hist))]);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
% temp = [ 50 100 200 300];
% vline(temp,'k .-.');
% % hline(ia_t_NL_hist(ismember(ia_t_X_hist,temp)),'k--');
% % hline(ia_t_L_hist(ismember(ia_t_X_hist,temp)),'r--');
% msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
% text(500,.2,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
% set(findall(gcf,'type','text'),'FontSize',20); legend({'L';'NL'});
% saveas(gcf,[pwd,filesep,fnam],'jpg');
% print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);


peakamp_trials_L= peakamp_trials(eventsdetected_trials&lightstim_trials);
peakamp_trials_NL= peakamp_trials(eventsdetected_trials & ~lightstim_trials);

meaneffect.peakamp_trials_L = peakamp_trials_L;
meaneffect.peakamp_trials_NL = peakamp_trials_NL;


if strcmp(par,'area')
    Lt = meaneffect.intarea_trials_L;
    NLt = meaneffect.intarea_trials_NL;
    bins = [0:25:600];
    parname = 'Area Size'
elseif strcmp(par,'peak')
    
    Lt = meaneffect.peakamp_trials_L;
    NLt = meaneffect.peakamp_trials_NL;
    bins=[0:25:600];
    parname = 'Peak Amp'
end
hL=hist(Lt,bins);
hNL=hist(NLt,bins);

fhNL = (hNL./meaneffect.trials_NL);
fhL = (hL./meaneffect.trials_L);

chL=cumsum(hL);
chNL=cumsum(hNL);
cumfreqNL = chNL/ meaneffect.trials_NL;
cumfreqL = chL/ meaneffect.trials_L;

% figure;plot([0:30:1000],cumfreqL,'ro');
% hold on; plot([0:30:1000],cumfreqNL,'ko');

frch_cfreq = (fhNL-fhL)./fhNL ;
figure;

fnam = [ grp ' Fractional Change in event' parname 'Freq'];


plot(bins,frch_cfreq,'ko');set(gca,'ticklength',[.025 .025]);
axis([0 600 0 1])
xlabel(['Event ' par]);
ylabel('Fr. change in freq');
title([grp 'Fractional change with Light']);
set(findall(gcf,'type','text'),'FontSize',20);


meaneffect.(['frch_cfreq' par]) = frch_cfreq;
meaneffect.(['frch_cfreq' par 'bins']) = bins;
save([grp 'meaneffect'],'meaneffect');

x = bins;
y=frch_cfreq;
y([1:2]) = nan; % too small bins
temp = find(~isnan(y) & ~isinf(y));
posi= find(y(temp)>0);
ind = temp(posi);
[param,paramCI,fitevals,f] = FitEval(x(ind),y(ind),'lin',-1);
hold on; plot(x,polyval(param ,x),'-','color','k','linewidth',1);

if tosave
    saveas(gcf,[pwd,filesep,fnam],'fig');
    print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
end


% name = 'Dist_Increased';
name  = grp;
fname = [name ' Trial Count.txt'];
fid = fopen(fname,'w');
if fid ~=-1
    fprintf(fid,'%s \n Trial count: \n Light Events %d \n Light Trials %d \n No Light Events %d \n No Light Trials %d',name, meaneffect.event_trials_L,meaneffect.trials_L,meaneffect.event_trials_NL,meaneffect.trials_NL);
    fclose(fid)
end

if strcmp(par,'area')
    dlmwrite([name '_EventArea_trials_NL.txt'],meaneffect.intarea_trials_NL,'delimiter',',');
    dlmwrite([name '_EventArea_trials_L.txt'],meaneffect.intarea_trials_L,'delimiter',',');
elseif strcmp(par,'peak')
    dlmwrite([name '_EventPeakAmp_trials_NL.txt'],meaneffect.peakamp_trials_NL,'delimiter',',');
    dlmwrite([name '_EventPeakAmp_trials_L.txt'],meaneffect.peakamp_trials_L,'delimiter',',');
end
%% cummulative event mag prob analaysis cell wise





























% % % % pa_t_X_hist = [0:50:600];
% % % % pa_t_L_hist = cumsum(hist(peakamp_trials_L,pa_t_X_hist)/sum(lightstim_trials==1));
% % % % pa_t_NL_hist = cumsum(hist(peakamp_trials_NL,pa_t_X_hist)/sum(lightstim_trials==0));
% % % % figure;fnam = [ grp 'Peak Amplitude Cumulative Hist'];
% % % % plot(pa_t_X_hist,pa_t_L_hist,'r');hold on; plot(pa_t_X_hist,pa_t_NL_hist,'k');xlabel('Amplitude ');ylabel('Counts'); title(fnam)
% % % % % text(300,.2,[ 'Shift = ' num2str(sum(pa_t_L_hist - pa_t_NL_hist))]);  % num2str(pa_t_X_hist(pa_t_L_hist == 0.5) - pa_t_X_hist(pa_t_NL_hist == 0.5))] );
% % % % msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
% % % % text(300,.2,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
% % % % set(findall(gcf,'type','text'),'FontSize',20)
% % % % saveas(gcf,[pwd,filesep,fnam],'jpg');
% % % %
% % % % pa_t_X_hist = [0:50:600];
% % % % pa_t_L_hist = cumsum(hist(peakamp_trials_L,pa_t_X_hist)/sum(hist(peakamp_trials_L,pa_t_X_hist)));
% % % % pa_t_NL_hist = cumsum(hist(peakamp_trials_NL,pa_t_X_hist)/sum(hist(peakamp_trials_NL,pa_t_X_hist)));
% % % % figure;fnam = [ grp 'Peak Amplitude Cumulative Hist Norm'];
% % % % plot(pa_t_X_hist,pa_t_L_hist,'r');hold on; plot(pa_t_X_hist,pa_t_NL_hist,'k');xlabel('Peak Amplitude ');ylabel('Counts'); title(fnam);axis([0 600 0 1]);
% % % % % text(300,.2,[ 'Shift = ' num2str(sum(pa_t_L_hist - pa_t_NL_hist))]);  % num2str(pa_t_X_hist(pa_t_L_hist == 0.5) - pa_t_X_hist(pa_t_NL_hist == 0.5))] );
% % % % msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
% % % % text(300,.2,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist = 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
% % % % set(findall(gcf,'type','text'),'FontSize',20)
% % % % saveas(gcf,[pwd,filesep,fnam],'jpg');
% % % %
% % % % fwhm_trials_L= fwhm_trials(eventsdetected_trials & lightstim_trials);
% % % % fwhm_trials_NL= fwhm_trials(eventsdetected_trials & ~lightstim_trials);fwhm_trials_NL(fwhm_trials_NL>4.5) = 4.5;
% % % %
% % % % fwhm_t_X_hist = [0:.25:5];
% % % % fwhm_t_L_hist = cumsum(hist(fwhm_trials_L,fwhm_t_X_hist )/sum(lightstim_trials==1));
% % % % fwhm_t_NL_hist =cumsum(hist(fwhm_trials_NL,fwhm_t_X_hist)/sum(lightstim_trials==0));
% % % % figure;fnam = [ grp 'FWHM Cumulative Hist '];
% % % % plot(fwhm_t_X_hist ,fwhm_t_L_hist,'r');hold on; plot(fwhm_t_X_hist ,fwhm_t_NL_hist,'k');xlabel('FWHM ');ylabel('Counts'); title(fnam)
% % % % % text(3,.2,[ 'Shift = ' num2str(sum(fwhm_t_L_hist - fwhm_t_NL_hist))]);   % num2str(fwhm_t_X_hist(fwhm_t_L_hist == 0.5) - fwhm_t_X_hist(fwhm_t_NL_hist == 0.5))] );
% % % % msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
% % % % text(3,.2,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
% % % % set(findall(gcf,'type','text'),'FontSize',20)
% % % % saveas(gcf,[pwd,filesep,fnam],'jpg');
% % % %
% % % % fwhm_t_X_hist = [0:.25:5];
% % % % fwhm_t_L_hist = cumsum(hist(fwhm_trials_L,fwhm_t_X_hist )/sum(hist(fwhm_trials_L,fwhm_t_X_hist )));
% % % % fwhm_t_NL_hist =cumsum(hist(fwhm_trials_NL,fwhm_t_X_hist)/sum(hist(fwhm_trials_NL,fwhm_t_X_hist )));
% % % % figure;fnam = [ grp 'FWHM Cumulative Hist Norm'];
% % % % plot(fwhm_t_X_hist ,fwhm_t_L_hist,'r');hold on; plot(fwhm_t_X_hist ,fwhm_t_NL_hist,'k');xlabel('FWHM ');ylabel('Counts'); title(fnam);axis([0 5 0 1]);
% % % % % text(3,.2,[ 'Shift = ' num2str(sum(fwhm_t_L_hist - fwhm_t_NL_hist))]);   % num2str(fwhm_t_X_hist(fwhm_t_L_hist == 0.5) - fwhm_t_X_hist(fwhm_t_NL_hist == 0.5))] );
% % % % msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
% % % % text(3,.2,msg);
% % % % set(findall(gcf,'type','text'),'FontSize',20)
% % % % saveas(gcf,[pwd,filesep,fnam],'jpg');
% % % %
% % % %
% % % %  ID_trials(:,1) = cellfun(@(x) x.mousename ,pooled_contact_CaTrials,'uniformoutput',0)';ID_trials(:,2) = cellfun(@(x) x.sessionname ,pooled_contact_CaTrials,'uniformoutput',0)';
% % % %  ID_trials(:,3) = cellfun(@(x) x.reg ,pooled_contact_CaTrials,'uniformoutput',0)';ID_trials(:,4) = cellfun(@(x) x.fov ,pooled_contact_CaTrials,'uniformoutput',0)';
% % % %  ID_trials(:,5) = cellfun(@(x) x.dend ,pooled_contact_CaTrials,'uniformoutput',0)';
% % %