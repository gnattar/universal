function [ca_onset,ft] = ca_latency_to_touch(pooled_contactCaTrials_locdep)
s =size(pooled_contactCaTrials_locdep,2);
for d = 1:s
    src_data = pooled_contactCaTrials_locdep{d}.rawdata;
    sampling_time = pooled_contactCaTrials_locdep{d}.FrameTime;
    event_detection_threshold = 35;
    event_detected_data=[];events_septs=[];events_amp=[];events_dur=[];events=[];detected=[];
    [event_detected_data,events_septs,events_amp,events_dur,events,detected] = detect_Ca_events(src_data,sampling_time,event_detection_threshold(d));
    temp = events_septs(:,1)-1;
    temp(temp<2) = 0;
    ca_onset{d} =temp*sampling_time;
    
    contacts=pooled_contactCaTrials_locdep{d}.contacts;
    ft{d} =cellfun(@(x) x(1),contacts)./500;
end