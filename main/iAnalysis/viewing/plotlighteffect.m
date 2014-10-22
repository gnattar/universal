function [meaneffect] = plotlighteffect(pooled_contact_CaTrials,grp)
save([grp 'pooled_contact_CaTrials'],'pooled_contact_CaTrials');
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

% figure;fnam = [ grp 'Event rate Scatter'];
% plot(meaneffect.alleventrate_L(:,1),meaneffect.alleventrate_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');hold on; plot([0:1],[0:1],'k--')
% xlabel('Event Rate Light'); ylabel('Event Rate No Light'); title(fnam)
% set(findall(gcf,'type','text'),'FontSize',20)
% saveas(gcf,[pwd,filesep,fnam],'jpg');
% 
% figure;fnam = [ grp 'FWHM Scatter'];
% plot(meaneffect.allfwhm_L(:,1),meaneffect.allfwhm_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
% axis([0 5 0 5]);xlabel('FWHM Light'); ylabel('FWHM No Light'); title(fnam)
% set(findall(gcf,'type','text'),'FontSize',20)
% hold on; plot([0:5],[0:5],'k--')
% axes('Position',[.7 .7 .2 .2])
% box on
% errorbarxy(meaneffect.allfwhm_L(:,1),meaneffect.allfwhm_NL(:,1),meaneffect.allfwhm_L(:,2),meaneffect.allfwhm_NL(:,2),{'bo','k','r'});axis ([0 5 0 5]);hold on; plot([0:5],[0:5],'k--')
% saveas(gcf,[pwd,filesep,fnam],'jpg');
% 
% figure;fnam = [ grp 'Int AreA Scatter'];
% plot(meaneffect.allintarea_L(:,1),meaneffect.allintarea_NL(:,1),'bo','Markersize',10,'Markerfacecolor','b');
% axis([0 800 0 800]);xlabel('Int Area Light'); ylabel('Int Area No Light'); title(fnam)
% set(findall(gcf,'type','text'),'FontSize',20)
% hold on; plot([0:800],[0:800],'k--');
% axes('Position',[.7 .7 .2 .2])
% box on
% errorbarxy(meaneffect.allintarea_L(:,1),meaneffect.allintarea_NL(:,1),meaneffect.allintarea_L(:,2),meaneffect.allintarea_NL(:,2),{'bo','k','r'});axis ([0 800 0 800]);hold on; plot([0:700],[0:700],'k--')
% saveas(gcf,[pwd,filesep,fnam],'jpg');
% 
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
intarea_trials = cell2mat(cellfun(@(x) x.intarea (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
lightstim_trials = cell2mat(cellfun(@(x) x.lightstim (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
peakamp_trials = cell2mat(cellfun(@(x) x.peakamp (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
fwhm_trials = cell2mat(cellfun(@(x) x.fwhm (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
 eventsdetected_trials = cell2mat(cellfun(@(x) x.eventsdetected (:,1) ,pooled_contact_CaTrials,'uniformoutput',0)');
% 
%  intarea_trials(eventsdetected_trials==0) = 0;
%  peakamp_trials(eventsdetected_trials==0) = 0;
%  fwhm_trials(eventsdetected_trials==0) = 0;

meaneffect.eventrate_X_hist = [0:.05:1];
meaneffect.eventrate_NL_hist=cumsum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist));meaneffect.eventrate_L_hist=cumsum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist));
figure;fnam = [ grp 'Event Rate Cumulative Hist'];
plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_L_hist,'r'); hold on; plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_NL_hist,'k');xlabel('Cumulative EventRate');ylabel('Counts'); title(fnam); 
% text(.6,.2,[ 'Shift = ' num2str(meaneffect.eventrate_X_hist(meaneffect.eventrate_L_hist == 0.5) - meaneffect.eventrate_X_hist(meaneffect.eventrate_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');

meaneffect.eventrate_X_hist = [0:.05:1];
meaneffect.eventrate_NL_hist=cumsum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist)/sum(hist(meaneffect.alleventrate_NL,meaneffect.eventrate_X_hist)));meaneffect.eventrate_L_hist=cumsum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist)/sum(hist(meaneffect.alleventrate_L,meaneffect.eventrate_X_hist)));
figure;fnam = [ grp 'Event Rate Cumulative Hist Norm'];
plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_L_hist,'r'); hold on; plot(meaneffect.eventrate_X_hist,meaneffect.eventrate_NL_hist,'k');xlabel('Norm Cumulative EventRate');ylabel('Counts'); title(fnam);axis ([0 1 0 1]);
% text(.6,.2,[ 'Shift = ' num2str(meaneffect.eventrate_X_hist(meaneffect.eventrate_L_hist == 0.5) - meaneffect.eventrate_X_hist(meaneffect.eventrate_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');
  
intarea_trials_L= intarea_trials(eventsdetected_trials&lightstim_trials);
intarea_trials_NL= intarea_trials(eventsdetected_trials & ~lightstim_trials);
ia_t_X_hist =[0:50:800];
ia_t_L_hist = cumsum(hist(intarea_trials_L,ia_t_X_hist)/sum(lightstim_trials==1));
ia_t_NL_hist = cumsum(hist(intarea_trials_NL,ia_t_X_hist)/sum(lightstim_trials==0));
figure;fnam = [ grp 'Int Area Cumulative Hist'];
plot(ia_t_X_hist,ia_t_L_hist,'r');hold on; plot(ia_t_X_hist,ia_t_NL_hist,'k');xlabel('IntArea');ylabel('Counts'); title(fnam); 
% text(500,.2,[ 'Shift = ' num2str(sum(ia_t_L_hist - ia_t_NL_hist))]);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
temp = [ 50 100 200 300];
vline(temp,'k --');
% hline(ia_t_NL_hist(ismember(ia_t_X_hist,temp)),'k--');
% hline(ia_t_L_hist(ismember(ia_t_X_hist,temp)),'r--');
msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
text(500,300,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');
 
 
intarea_trials_L= intarea_trials(eventsdetected_trials&lightstim_trials);
intarea_trials_NL= intarea_trials(eventsdetected_trials & ~lightstim_trials);
ia_t_X_hist =[0:50:800];
ia_t_L_hist = cumsum(hist(intarea_trials_L,ia_t_X_hist)/sum(hist(intarea_trials_L,ia_t_X_hist)));
ia_t_NL_hist = cumsum(hist(intarea_trials_NL,ia_t_X_hist)/sum(hist(intarea_trials_NL,ia_t_X_hist)));
figure;fnam = [ grp 'Int Area Cumulative Hist Norm'];
plot(ia_t_X_hist,ia_t_L_hist,'r');hold on; plot(ia_t_X_hist,ia_t_NL_hist,'k');xlabel('IntArea');ylabel('Counts'); title(fnam);axis([0 800 0 1]);
% text(500,.2,[ 'Shift = ' num2str(sum(ia_t_L_hist - ia_t_NL_hist))]);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
temp = [ 50 100 200 300];
vline(temp,'k --');
% hline(ia_t_NL_hist(ismember(ia_t_X_hist,temp)),'k--');
% hline(ia_t_L_hist(ismember(ia_t_X_hist,temp)),'r--');
msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
text(500,.2,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');

peakamp_trials_L= peakamp_trials(eventsdetected_trials&lightstim_trials);
peakamp_trials_NL= peakamp_trials(eventsdetected_trials & ~lightstim_trials);

pa_t_X_hist = [0:50:600];
pa_t_L_hist = cumsum(hist(peakamp_trials_L,pa_t_X_hist)/sum(lightstim_trials==1));
pa_t_NL_hist = cumsum(hist(peakamp_trials_NL,pa_t_X_hist)/sum(lightstim_trials==0));
figure;fnam = [ grp 'Peak Amplitude Cumulative Hist'];
plot(pa_t_X_hist,pa_t_L_hist,'r');hold on; plot(pa_t_X_hist,pa_t_NL_hist,'k');xlabel('Amplitude ');ylabel('Counts'); title(fnam)
% text(300,.2,[ 'Shift = ' num2str(sum(pa_t_L_hist - pa_t_NL_hist))]);  % num2str(pa_t_X_hist(pa_t_L_hist == 0.5) - pa_t_X_hist(pa_t_NL_hist == 0.5))] );
msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
text(300,200,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');

pa_t_X_hist = [0:50:600];
pa_t_L_hist = cumsum(hist(peakamp_trials_L,pa_t_X_hist)/sum(hist(peakamp_trials_L,pa_t_X_hist)));
pa_t_NL_hist = cumsum(hist(peakamp_trials_NL,pa_t_X_hist)/sum(hist(peakamp_trials_NL,pa_t_X_hist)));
figure;fnam = [ grp 'Peak Amplitude Cumulative Hist Norm'];
plot(pa_t_X_hist,pa_t_L_hist,'r');hold on; plot(pa_t_X_hist,pa_t_NL_hist,'k');xlabel('Peak Amplitude ');ylabel('Counts'); title(fnam);axis([0 600 0 1]);
% text(300,.2,[ 'Shift = ' num2str(sum(pa_t_L_hist - pa_t_NL_hist))]);  % num2str(pa_t_X_hist(pa_t_L_hist == 0.5) - pa_t_X_hist(pa_t_NL_hist == 0.5))] );
msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
text(300,.2,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');

fwhm_trials_L= fwhm_trials(eventsdetected_trials & lightstim_trials);
fwhm_trials_NL= fwhm_trials(eventsdetected_trials & ~lightstim_trials);fwhm_trials_NL(fwhm_trials_NL>4.5) = 4.5;

fwhm_t_X_hist = [0:.25:5];
fwhm_t_L_hist = cumsum(hist(fwhm_trials_L,fwhm_t_X_hist )/sum(lightstim_trials==1));
fwhm_t_NL_hist =cumsum(hist(fwhm_trials_NL,fwhm_t_X_hist)/sum(lightstim_trials==0));
figure;fnam = [ grp 'FWHM Cumulative Hist '];
plot(fwhm_t_X_hist ,fwhm_t_L_hist,'r');hold on; plot(fwhm_t_X_hist ,fwhm_t_NL_hist,'k');xlabel('FWHM ');ylabel('Counts'); title(fnam)
% text(3,.2,[ 'Shift = ' num2str(sum(fwhm_t_L_hist - fwhm_t_NL_hist))]);   % num2str(fwhm_t_X_hist(fwhm_t_L_hist == 0.5) - fwhm_t_X_hist(fwhm_t_NL_hist == 0.5))] );
msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
text(3,200,msg);                    % num2str(ia_t_X_hist(ia_t_L_hist == 0.5) - ia_t_X_hist(ia_t_NL_hist == 0.5))] );
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');

fwhm_t_X_hist = [0:.25:5];
fwhm_t_L_hist = cumsum(hist(fwhm_trials_L,fwhm_t_X_hist )/sum(hist(fwhm_trials_L,fwhm_t_X_hist )));
fwhm_t_NL_hist =cumsum(hist(fwhm_trials_NL,fwhm_t_X_hist)/sum(hist(fwhm_trials_NL,fwhm_t_X_hist )));
figure;fnam = [ grp 'FWHM Cumulative Hist Norm'];
plot(fwhm_t_X_hist ,fwhm_t_L_hist,'r');hold on; plot(fwhm_t_X_hist ,fwhm_t_NL_hist,'k');xlabel('FWHM ');ylabel('Counts'); title(fnam);axis([0 5 0 1]);
% text(3,.2,[ 'Shift = ' num2str(sum(fwhm_t_L_hist - fwhm_t_NL_hist))]);   % num2str(fwhm_t_X_hist(fwhm_t_L_hist == 0.5) - fwhm_t_X_hist(fwhm_t_NL_hist == 0.5))] );
msg = sprintf([num2str(sum(eventsdetected_trials&lightstim_trials)) '/ ' num2str(sum(lightstim_trials==1)) ' trials L \n' num2str(sum(eventsdetected_trials&~lightstim_trials)) ' / '  num2str(sum(lightstim_trials==0)) 'trials NL']);
text(3,.2,msg); 
set(findall(gcf,'type','text'),'FontSize',20)
saveas(gcf,[pwd,filesep,fnam],'jpg');

 
 ID_trials(:,1) = cellfun(@(x) x.mousename ,pooled_contact_CaTrials,'uniformoutput',0)';ID_trials(:,2) = cellfun(@(x) x.sessionname ,pooled_contact_CaTrials,'uniformoutput',0)';
 ID_trials(:,3) = cellfun(@(x) x.reg ,pooled_contact_CaTrials,'uniformoutput',0)';ID_trials(:,4) = cellfun(@(x) x.fov ,pooled_contact_CaTrials,'uniformoutput',0)';
 ID_trials(:,5) = cellfun(@(x) x.dend ,pooled_contact_CaTrials,'uniformoutput',0)';
 