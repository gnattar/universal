function [pooled_contact_CaTrials] = Compute_collected_summary (collected_data,collected_summary,event_detection_threshold)

pooled_contact_CaTrials = [];
count =1;
for i = 1: size(collected_summary,2) 
    d = length(collected_summary{1,i}.dends);
    for j = 1:d
        temp_data = cell2mat(arrayfun(@(x) x.dff(j,:), collected_data{1,i},'uniformoutput',0)');
        sampling_time = collected_data{1,i}(1).FrameTime;
        winsize =round(0.4/sampling_time); %% fixed to match 200 ms of time window
%         winsize = 5;
        src_data = filter(ones(1,winsize)/winsize,1,temp_data,[],2);
%         src_data2 = conv(temp_data,ones(1,winsize)/winsize);
        [event_detected_data,events_septs,detected] = detect_Ca_events(src_data,sampling_time,event_detection_threshold);
        lightstim=arrayfun(@(x) x.lightstim, collected_data{1,i},'uniformoutput',0)';

        numtrials = size(temp_data,1);
        intarea = nan(numtrials,1);
        peakamp = nan(numtrials,1);
        fwhm = nan(numtrials,1);
        for k = 1:numtrials
            
            if (detected(k,1))
                bl = nanmean (temp_data(k,[1:round(0.5./sampling_time)]));
                bl_std = nanstd (temp_data(k,[1:round(0.5./sampling_time)]));
% %                 if(bl>bl_std*2)                  
% %                     temp_data(k,:) = temp_data(k,:) - bl;
% %                 end
                try 
                    fwhm(k) = findFWHM([1:size(temp_data,2)],temp_data(k,:))*sampling_time;
                catch
                intarea(k) = nansum(temp_data(k,:)).*sampling_time;
                peakamp(k) = nanmean(prctile(temp_data(k,:),95));
%                     fwhm(k) = nan;
                    detected(k,1) = 0;
                end
                
                intarea(k) = nansum(temp_data(k,:)).*sampling_time;
%                  intarea(k) = nansum(src_data(k,:)).*sampling_time;
                peakamp(k) = nanmean(prctile(temp_data(k,:),95));
                
            else
                intarea(k) = nansum(temp_data(k,:)).*sampling_time;
                peakamp(k) = nanmean(prctile(temp_data(k,:),95));
%                 fwhm(k) = nan;
            end
        end
        pooled_contact_CaTrials{count}.rawdata = temp_data;
         pooled_contact_CaTrials{count}.rawdata_smth = src_data;
        pooled_contact_CaTrials{count}.eventsdetected= detected;
        pooled_contact_CaTrials{count}.lightstim= lightstim;
        pooled_contact_CaTrials{count}.FrameTime = sampling_time;
        pooled_contact_CaTrials{count}.intarea = intarea;
        pooled_contact_CaTrials{count}.peakamp= peakamp;
        pooled_contact_CaTrials{count}.fwhm= fwhm;
       
        pooled_contact_CaTrials{count}.eventrate_L= sum(detected(lightstim==1))/length(detected(lightstim==1));        
        pooled_contact_CaTrials{count}.eventrate_NL= sum(detected(lightstim==0))/length(detected(lightstim==0));
        pooled_contact_CaTrials{count}.eventrate_diff= pooled_contact_CaTrials{count}.eventrate_L - pooled_contact_CaTrials{count}.eventrate_NL;     
        
        pooled_contact_CaTrials{count}.intarea_L= [nanmean(intarea((lightstim==1)& (detected==1))); nanstd(intarea((lightstim==1)& (detected==1)),[],1)/sqrt(sum(detected(lightstim==1)))];        
        pooled_contact_CaTrials{count}.intarea_NL=[nanmean(intarea((lightstim==0)& (detected==1)));nanstd(intarea((lightstim==0)& (detected==1)),[],1)/sqrt(sum(detected(lightstim==0)))];        
        cs_X = [0:50:800];
        cs_L = cumsum(hist(intarea(lightstim&detected), cs_X)/ sum(hist(intarea(lightstim&detected), cs_X)));
        cs_NL = cumsum(hist(intarea(~lightstim&detected), cs_X)/ sum(hist(intarea(~lightstim&detected), cs_X)));
%         pooled_contact_CaTrials{count}.intarea_diff=cs_X(cs_L == .5) - cs_X(cs_NL == .5);
        pooled_contact_CaTrials{count}.intarea_diff=sum(cs_L - cs_NL) ;
        
        pooled_contact_CaTrials{count}.peakamp_L= [nanmean(peakamp((lightstim==1)& (detected==1)));nanstd(peakamp((lightstim==1)& (detected==1)),[],1)/sqrt(sum(detected(lightstim==1)))];        
        pooled_contact_CaTrials{count}.peakamp_NL= [nanmean(peakamp((lightstim==0)& (detected==1)));nanstd(peakamp((lightstim==0)& (detected==1)),[],1)/sqrt(sum(detected(lightstim==0)))];        
        cs_X = [0:50:600];
        cs_L = cumsum(hist(peakamp(lightstim&detected), cs_X)/ sum(hist(peakamp(lightstim&detected), cs_X)));
        cs_NL = cumsum(hist(peakamp(~lightstim&detected), cs_X)/ sum(hist(peakamp(~lightstim&detected), cs_X)));
%         pooled_contact_CaTrials{count}.peakamp_diff=cs_X(cs_L == .5) - cs_X(cs_NL == .5);
        pooled_contact_CaTrials{count}.peakamp_diff=sum(cs_L - cs_NL);
        
        pooled_contact_CaTrials{count}.fwhm_L= [nanmean(fwhm((lightstim==1)& (detected==1)));nanstd(fwhm((lightstim==1)& (detected==1)),[],1)/sqrt(sum(detected(lightstim==1)))];        
        pooled_contact_CaTrials{count}.fwhm_NL= [nanmean(fwhm((lightstim==0)& (detected==1)));nanstd(fwhm((lightstim==0)& (detected==1)),[],1)/sqrt(sum(detected(lightstim==0)))]; 
        cs_X = [0:.25:5];
        cs_L = cumsum(hist(fwhm(lightstim&detected), cs_X)/ sum(hist(fwhm(lightstim&detected), cs_X)));
        cs_NL = cumsum(hist(fwhm(~lightstim&detected), cs_X)/ sum(hist(fwhm(~lightstim&detected), cs_X)));
%         pooled_contact_CaTrials{count}.fwhm_diff=cs_X(cs_L == .5) - cs_X(cs_NL == .5);
        pooled_contact_CaTrials{count}.fwhm_diff= sum(cs_L - cs_NL);

        pooled_contact_CaTrials{count}.mousename= collected_summary{i}.mousename;
        pooled_contact_CaTrials{count}.sessionname= collected_summary{i}.sessionname;
        pooled_contact_CaTrials{count}.reg= collected_summary{i}.reg;
        pooled_contact_CaTrials{count}.fov= collected_summary{i}.fov;
        pooled_contact_CaTrials{count}.dend= collected_summary{i}.dends(j);
           
        count = count+1;
    end
end
save('pooled_contact_CaTrials','pooled_contact_CaTrials');