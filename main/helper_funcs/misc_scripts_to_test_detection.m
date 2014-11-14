misc_scripts_to_test_detection()
i = 30
area = [];
temp_data = pooled_contact_CaTrials{1,i}.rawdata;
sampling_time =pooled_contact_CaTrials{1,i}.FrameTime;

ia_data = nansum(temp_data,2).* sampling_time;
figure; plot(ia_data,'k'); hold on;

% winsize =round(0.3/sampling_time)
% src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
% area(:,1) = nansum(src_data2,2).* sampling_time;
% plot(area(:,1),'r');hold on;

winsize =round(0.4/sampling_time)
src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
area (:,2)= nansum(src_data2,2).* sampling_time;
plot(area(:,2),'b');hold on;
hline(30,'k')
% 
% winsize =round(0.5/sampling_time)
% src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
% area (:,3)= nansum(src_data2,2).* sampling_time;
% plot(area(:,3),'g');hold on;
% 
% winsize =round(0.6/sampling_time)
% src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
% area(:,4) = nansum(src_data2,2).* sampling_time;
% plot(area(:,4),'m');
% hline(30,'k')

% j = [6,26,28,46]
%  j = [52,75,76,91]

%%
  j = [1:36]+72
  j = [ 9 14 25 28  54 71 76 89  91 94 95 96  98 105
 
  figure;
  for k = 1:length(j)
  
  subplot(length(j)/2,2,k);
  
  
  plot(temp_data(j(k),:),'k')
  %
  % winsize =round(0.3/sampling_time)
  % src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
  % hold on; plot(src_data2(j(k),:),'r')
  %
  % winsize =round(0.4/sampling_time)
  % src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
  % hold on; plot(src_data2(j(k),:),'b')
  %
  % winsize =round(0.5/sampling_time)
  % src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
  % hold on; plot(src_data2(j(k),:),'g')
  %
  % winsize =round(0.6/sampling_time)
  % src_data2 = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
  % hold on; plot(src_data2(j(k),:),'m')
  hline(30,'k');
  title([num2str(j(k))])
  end
  
  %% tyo plot rawtraces
  
  
  
  
for i = 1: 85
figure;
subplot(1,2,1);
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==1),:)');title(['cell' num2str(i) ' detected'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');
subplot(1,2,2);
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==0),:)');title(['cell' num2str(i) ' undetected'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');
saveas(gcf,['cell' num2str(i)],'jpg')
close(gcf)
end

  
  

  
for i = 58: 60
figure;
subplot(2,2,1);
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==1 & pooled_contact_CaTrials{i}.lightstim==0),:)');title(['cell' num2str(i) ' detected NoLight'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');
subplot(2,2,2);
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==0 & pooled_contact_CaTrials{i}.lightstim==0),:)');title(['cell' num2str(i) ' undetected NoLight'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');

subplot(2,2,3);
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==1 & pooled_contact_CaTrials{i}.lightstim==1),:)');title(['cell' num2str(i) ' detected Light'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');
subplot(2,2,4);
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==0 & pooled_contact_CaTrials{i}.lightstim==1),:)');title(['cell' num2str(i) ' undetected Light'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');saveas(gcf,['cell' num2str(i)],'jpg')
close(gcf)
end
  
  
  
  
  
  
  
  
  
  
  
  
  
  %% to plot intarea dist for various conditions
  
  Lt = meaneffect.intarea_trials_L;
NLt = meaneffect.intarea_trials_NL;

trialcountEL = cumsum(cell2mat(cellfun(@(x) sum(x.eventsdetected.*(x.lightstim)), pooled_contact_CaTrials,'uniformoutput',0)));
trialcountENL = cumsum(cell2mat(cellfun(@(x) sum(x.eventsdetected.*(1-x.lightstim)), pooled_contact_CaTrials,'uniformoutput',0)));
trialcountL = cumsum(cell2mat(cellfun(@(x) sum(x.lightstim), pooled_contact_CaTrials,'uniformoutput',0)));
trialcountNL = cumsum(cell2mat(cellfun(@(x) sum(1-x.lightstim), pooled_contact_CaTrials,'uniformoutput',0)));
trialcount = cumsum(cell2mat(cellfun(@(x) length(x.eventsdetected), pooled_contact_CaTrials,'uniformoutput',0)));


figure;plot(Lt,'ro');
hline(30,'k-');
figure;plot(NLt,'ko');
hline(30,'k-');
text(600, 600,'Light')

text(600, 600,'NoLight')


figure; plot(meaneffect.intarea_trials)
figure; plot(meaneffect.intarea_trials,'bo'); hline(30,'k')

vline(3146,'k--')


figure; plot(meaneffect.intarea_trials(meaneffect.lightstim_trials==1),'ro'); hline(30,'k')

figure; plot(meaneffect.intarea_trials(meaneffect.lightstim_trials==1 & meaneffect.eventsdetected_trials==1),'ro'); hline(30,'k')
text(600, 600,'Light events')
vline(1364,'r--')

figure; plot(meaneffect.intarea_trials(meaneffect.lightstim_trials==0),'ko'); hline(30,'k')
hline(30,'g-');
vline(1782,'k--')
text(4000, 600,'No Light Trials')
text(1600, 600,'No Light Events')
  
  
  
  
  
  
  
  
  
  