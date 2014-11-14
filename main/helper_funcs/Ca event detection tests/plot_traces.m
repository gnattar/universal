for i = 1:43
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
if(~isempty(find(pooled_contact_CaTrials{i}.eventsdetected==1 & pooled_contact_CaTrials{i}.lightstim==1)))
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==1 & pooled_contact_CaTrials{i}.lightstim==1),:)');title(['cell' num2str(i) ' detected Light'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');
end
subplot(2,2,4);
if(~isempty(find(pooled_contact_CaTrials{i}.eventsdetected==0 & pooled_contact_CaTrials{i}.lightstim==1)))
plot([1:size(pooled_contact_CaTrials{i}.rawdata_smth,2)].*pooled_contact_CaTrials{i}.FrameTime,pooled_contact_CaTrials{i}.rawdata_smth(find(pooled_contact_CaTrials{i}.eventsdetected==0 & pooled_contact_CaTrials{i}.lightstim==1),:)');title(['cell' num2str(i) ' undetected Light'])
axis([0.1 5 -100 400])
hline(30,'k--');
hline(0,'k-');
end
saveas(gcf,['cell' num2str(i)],'jpg')
close(gcf)
end
