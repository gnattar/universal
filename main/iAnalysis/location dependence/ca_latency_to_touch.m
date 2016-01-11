function [ca_onset,ft] = ca_latency_to_touch(pooled_contactCaTrials_locdep)
s =size(pooled_contactCaTrials_locdep,2);
for d = 1:s
    src_data = pooled_contactCaTrials_locdep{d}.rawdata;
    sampling_time = pooled_contactCaTrials_locdep{d}.FrameTime;
    event_detection_threshold = ones(size(pooled_contactCaTrials_locdep,2),1).*25;
    event_detected_data=[];events_septs=[];events_amp=[];events_dur=[];events=[];detected=[];
    [event_detected_data,events_septs,events_amp,events_dur,events,detected] = detect_Ca_events(src_data,sampling_time,event_detection_threshold(d));
    temp = events_septs(:,1)-2;
    temp(temp<2) = 0;
    ca_onset{d} =temp*sampling_time;
    
    contacts=pooled_contactCaTrials_locdep{d}.contacts;
    ft{d} =cellfun(@(x) x(1),contacts)./(500*2);
end

% %% to pool 
% [ca_onset,ft] = ca_latency_to_touch(pooled_contactCaTrials_locdep);
% for i = 1:size(pooled_contactCaTrials_locdep,2)
%     temp(:,i)=ca_onset{i}-ft{i};
% end
% temp2 = temp;
% temp2=reshape(temp2,(size(temp,1)*size(temp,2)),1);
% temp2(temp2<0)=nan;temp2(temp2>.3)=nan;
% bins = [.03:.03:.3];
% h=hist(temp2,bins);
% figure;hist(temp2,bins);