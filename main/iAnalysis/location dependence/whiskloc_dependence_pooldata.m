function [pooled_contactCaTrials_locdep] = whiskloc_dependence_pooldata(collected_data,collected_summary,src_smoothed)
pooled_contactCaTrials_locdep = [];
count =1;
pxlpermm = 24.38; %% 18-7.5 mm = 298-42 pixels
for i = 1: size(collected_summary,2) 
    d = length(collected_summary{1,i}.dends);
    
        temp_solotrial = cell2mat(arrayfun(@(x) x.solo_trial(1), collected_data{1,i},'uniformoutput',0)');
        temp_contactdir = arrayfun(@(x) x.contactdir{1}, collected_data{1,i},'uniformoutput',0)';
        temp_contacts = arrayfun(@(x) x.contacts{1}, collected_data{1,i},'uniformoutput',0);
        temp_tws = arrayfun(@(x) x.ts_wsk{1}, collected_data{1,i},'uniformoutput',0)';
        temp_touchTheta = arrayfun(@(x) x.theta{1}, collected_data{1,i},'uniformoutput',0)'; 
        temp_touchdeltaKappa = arrayfun(@(x) x.deltaKappa{1}, collected_data{1,i},'uniformoutput',0)';         

            temp_Theta_at_contact = arrayfun(@(x) x.Theta_at_contact{1}, collected_data{1,i},'uniformoutput',0)'; 

    for j = 1:d
        data = cell2mat(arrayfun(@(x) x.dff(j,:), collected_data{1,i},'uniformoutput',0)');
        sampling_time = collected_data{1,i}(1).FrameTime;
        winsize = round(.2/sampling_time);
        temp_data = data;
        temp_data_filt = filter(ones(1,winsize)/winsize,1,data,[],2);
        if src_smoothed
         temp_data = temp_data_filt;
        end
        temp_totalKappa = cell2mat(arrayfun(@(x) x.total_touchKappa(1), collected_data{1,i},'uniformoutput',0)');
        temp_totalKappa_epoch  =cell2mat(arrayfun(@(x) x.total_touchKappa_epoch(1), collected_data{1,i},'uniformoutput',0)');
        temp_totalKappa_epoch_abs  =cell2mat(arrayfun(@(x) x.total_touchKappa_epoch_abs(1), collected_data{1,i},'uniformoutput',0)');
        
         temp_Theta_at_contact_Mean =cell2mat( arrayfun(@(x) x.Theta_at_contact_Mean{1}, collected_data{1,i},'uniformoutput',0)'); 
        temp_contacts = arrayfun(@(x) x.contacts_shifted{1}, collected_data{1,i},'uniformoutput',0)'; 
        temp_contactdir = arrayfun(@(x) x.contactdir{1}, collected_data{1,i},'uniformoutput',0)'; 
   
        temp_poleloc = cell2mat(arrayfun(@(x) x.barpos(1), collected_data{1,i},'uniformoutput',0)');
        a = collected_data{1,i}.lightstim;
        if(~isempty(a) )
      	 temp_lightstim = cell2mat(arrayfun(@(x) x.lightstim(1), collected_data{1,i},'uniformoutput',0)');
        else
            temp_lightstim = zeros(length(temp_poleloc),1);
        end
        polelocs = unique(temp_poleloc);
       
        if max(temp_lightstim) >0
          CaSig_mag = cell(length(polelocs),2); %% NL, L 
          CaSig_peak = cell(length(polelocs),2);
          CaSig_dur = cell(length(polelocs),2); %fwhm 
          CaSig_data=cell(length(polelocs),2);
          wSig_totmodKappa = cell(length(polelocs),2);
          wSig_dKappadata = cell(length(polelocs),2);
          wSig_contacts = cell(length(polelocs),2);
          wSig_contactdir = cell(length(polelocs),2);
          trialnames=cell(length(polelocs),2);
          num_trials =  zeros(length(polelocs),2);          
        else
          CaSig_mag = cell(length(polelocs),1); %NL
          CaSig_peak = cell(length(polelocs),1);
          CaSig_dur = cell(length(polelocs),1); %fwhm 
          CaSig_data=cell(length(polelocs),1);
          wSig_totmodKappa = cell(length(polelocs),1);
          wSig_dKappadata = cell(length(polelocs),1);
          wSig_contacts = cell(length(polelocs),1);
          wSig_contactdir = cell(length(polelocs),1);
          trialnames = cell(length(polelocs),1);
          num_trials =  zeros(length(polelocs),1);
        end
        
        for k = 1: length(polelocs)
            curr_poleloc_trials = (temp_poleloc == polelocs(k));
            if max(temp_lightstim) >0
                curr_loc_L_trials = temp_data (find(curr_poleloc_trials & temp_lightstim),:);
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_L_Kappa = temp_totalKappa_epoch (find(curr_poleloc_trials & temp_lightstim));
                curr_loc_NL_Kappa = temp_totalKappa_epoch (find(curr_poleloc_trials & ~temp_lightstim));
                curr_loc_L_dKappatrials = temp_touchdeltaKappa (find(curr_poleloc_trials & temp_lightstim));
                curr_loc_NL_dKappatrials = temp_touchdeltaKappa (find(curr_poleloc_trials & ~temp_lightstim));     
                curr_loc_L_dKappatrials_ts = temp_tws (find(curr_poleloc_trials & temp_lightstim));      
                curr_loc_NL_dKappatrials_ts = temp_tws (find(curr_poleloc_trials & ~temp_lightstim));
                curr_loc_NL_contacts = temp_contacts (find(curr_poleloc_trials & temp_lightstim));   
                curr_loc_L_contacts = temp_contacts (find(curr_poleloc_trials & ~temp_lightstim));   
                curr_loc_NL_contactdir =  temp_contactdir (find(curr_poleloc_trials & temp_lightstim));   
                curr_loc_L_contactdir =  temp_contactdir (find(curr_poleloc_trials & ~temp_lightstim));   
                num_trials (k,2) = size(curr_loc_L_Kappa ,1);
                num_trials (k,1) = size(curr_loc_NL_Kappa ,1);               
                threshold = 15;
                trialnames{k,1} =  temp_solotrial(find(curr_poleloc_trials & ~temp_lightstim));
                trialnames{k,2} =  temp_solotrial(find(curr_poleloc_trials & temp_lightstim));
                
                [event_detected_data,events_septs,events_amp,events_dur,events,detected] = detect_Ca_events(curr_loc_NL_trials,sampling_time,threshold);
                CaSig_mag{k,1} = nansum(curr_loc_NL_trials,2);
                CaSig_peak{k,1} =events_amp';
                CaSig_dur{k,1} = events_dur';
                CaSig_data{k,1}= curr_loc_NL_trials;
                CaSig_time{k,1} = [1:size(curr_loc_NL_trials,2)].* sampling_time;
                
                [event_detected_data,events_septs,events_amp,events_dur,events,detected] = detect_Ca_events(curr_loc_L_trials,sampling_time,threshold);
                CaSig_mag{k,2} = nansum(curr_loc_L_trials,2);
                CaSig_peak{k,2} = events_amp';
                CaSig_dur{k,2} = events_dur';
                CaSig_data{k,2}= curr_loc_L_trials;
                CaSig_time{k,2} = [1:size(curr_loc_L_trials,2)].* sampling_time;
                wSig_totmodKappa{k,1} = curr_loc_NL_Kappa./pxlpermm;
                wSig_totmodKappa{k,2} = curr_loc_L_Kappa ./pxlpermm;
                wSig_dKappadata{k,1}= curr_loc_NL_dKappatrials;
                wSig_dKappadata{k,2}= curr_loc_L_dKappatrials;
                wSig_dKappatime{k,1}= curr_loc_NL_dKappatrials_ts;
                wSig_dKappatime{k,2}= curr_loc_L_dKappatrials_ts; 
                wSig_contacts{k,1} = curr_loc_NL_contacts;
                wSig_contacts{k,2} = curr_loc_L_contacts;
                wSig_contactdir{k,1} = curr_loc_NL_contactdir;
                wSig_contactdir{k,2} = curr_loc_L_contactdir;
            else
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_NL_Kappa = temp_totalKappa_epoch (find(curr_poleloc_trials & ~temp_lightstim));
                curr_loc_NL_dKappatrials = temp_touchdeltaKappa (find(curr_poleloc_trials & ~temp_lightstim));                                
                curr_loc_NL_dKappatrials_ts = temp_tws (find(curr_poleloc_trials & ~temp_lightstim));   
                curr_loc_NL_contacts = temp_contacts (find(curr_poleloc_trials & ~temp_lightstim));   
                curr_loc_NL_contactdir =  temp_contactdir (find(curr_poleloc_trials & ~temp_lightstim));   
                 
                threshold=35;
                 trialnames{k,1} =  temp_solotrial(find(curr_poleloc_trials & ~temp_lightstim));
                 
                [event_detected_data,events_septs,events_amp,events_dur,events,detected] = detect_Ca_events(curr_loc_NL_trials,sampling_time,threshold);
                CaSig_mag{k,1} = nansum(curr_loc_NL_trials,2);
                CaSig_peak{k,1} =events_amp';
                CaSig_dur{k,1} = events_dur';
                CaSig_data{k,1}= curr_loc_NL_trials;
                CaSig_time{k,1} = [1:size(curr_loc_NL_trials,2)].* sampling_time;
                wSig_totmodKappa{k,1} = curr_loc_NL_Kappa./pxlpermm;
                wSig_dKappadata{k,1}= curr_loc_NL_dKappatrials;
                wSig_dKappatime{k,1}= curr_loc_NL_dKappatrials_ts;
                wSig_contacts{k,1} = curr_loc_NL_contacts;
                wSig_contactdir{k,1} = curr_loc_NL_contactdir;
                num_trials (k,1) = size(curr_loc_NL_Kappa ,1);
            end

        end

        pooled_contactCaTrials_locdep {count}.rawdata = data;
        pooled_contactCaTrials_locdep {count}.filtdata =temp_data_filt ;
        pooled_contactCaTrials_locdep {count}.sigmag = nansum(temp_data,2);
        pooled_contactCaTrials_locdep {count}.sigpeak = prctile(temp_data,99,2);
        pooled_contactCaTrials_locdep {count}.FrameTime = sampling_time;
        pooled_contactCaTrials_locdep {count}.totalKappa = temp_totalKappa./pxlpermm;
        pooled_contactCaTrials_locdep {count}.touchTheta = temp_touchTheta;
        pooled_contactCaTrials_locdep {count}.touchdeltaKappa = temp_touchdeltaKappa;
        pooled_contactCaTrials_locdep{count}.poleloc= temp_poleloc ;
        pooled_contactCaTrials_locdep{count}.lightstim=   temp_lightstim ;
        pooled_contactCaTrials_locdep{count}.num_trials=   num_trials;
        pooled_contactCaTrials_locdep{count}.trialnames=   trialnames;
        pooled_contactCaTrials_locdep{count}.CaSig_mag = CaSig_mag;
        pooled_contactCaTrials_locdep{count}.CaSig_peak= CaSig_peak;
        pooled_contactCaTrials_locdep{count}.CaSig_dur= CaSig_dur;
        pooled_contactCaTrials_locdep{count}.wSig_totmodKappa = wSig_totmodKappa;
        pooled_contactCaTrials_locdep{count}.CaSig_data= CaSig_data;
        pooled_contactCaTrials_locdep{count}.CaSig_time = CaSig_time;
        pooled_contactCaTrials_locdep{count}.wSig_dKappadata = wSig_dKappadata;        
        pooled_contactCaTrials_locdep{count}.wSig_dKappatime = wSig_dKappatime;
        pooled_contactCaTrials_locdep{count}.wSig_contacts = wSig_contacts;        
        pooled_contactCaTrials_locdep{count}.wSig_contactdir = wSig_contactdir;
        
        pooled_contactCaTrials_locdep{count}.mousename= collected_summary{i}.mousename;
        pooled_contactCaTrials_locdep{count}.sessionname= collected_summary{i}.sessionname;
        pooled_contactCaTrials_locdep{count}.reg= collected_summary{i}.reg;
        pooled_contactCaTrials_locdep{count}.fov= collected_summary{i}.fov;
        pooled_contactCaTrials_locdep{count}.dend= collected_summary{i}.dends(j);
        pooled_contactCaTrials_locdep{count}.trialnum= temp_solotrial;
        pooled_contactCaTrials_locdep{count}.contactdir= temp_contactdir;
        pooled_contactCaTrials_locdep{count}.contacts= temp_contacts;
        pooled_contactCaTrials_locdep{count}.timews=temp_tws;  
        
        pooled_contactCaTrials_locdep {count}.totalKappa_epoch = temp_totalKappa_epoch./pxlpermm;
        pooled_contactCaTrials_locdep {count}.totalKappa_epoch_abs = temp_totalKappa_epoch_abs./pxlpermm;

        pooled_contactCaTrials_locdep {count}.Theta_at_contact = temp_Theta_at_contact;
        pooled_contactCaTrials_locdep {count}.Theta_at_contact_Mean = temp_Theta_at_contact_Mean;

        
        count = count+1;
    end
end


pxlpermm = 24.38;
      for d = 1:size(pooled_contactCaTrials_locdep,2);
          pooled_contactCaTrials_locdep{d}.re_maxdK = [];
          pooled_contactCaTrials_locdep{d}.re_totaldK = [];
          numtr= size( pooled_contactCaTrials_locdep{d}.totalKappa,1);
          for t = 1:numtr
              curr_dkappa = pooled_contactCaTrials_locdep{d}.touchdeltaKappa{t};
              curr_dkappa_t = pooled_contactCaTrials_locdep{d}.timews{t};
              curr_contacts = pooled_contactCaTrials_locdep{d}.contacts{t};
              curr_contacts = curr_contacts(curr_contacts < 1400); %% within the first 1 sec used to be 1190
              touchdkappa = curr_dkappa(curr_contacts);
              touchdir = pooled_contactCaTrials_locdep{d}.contactdir{t};
              [maxval,maxind] =  max(abs(touchdkappa));            
              %% recompute total touch dKappa
              discreet_contacts_2= unique([1;find(diff(curr_contacts)>2.0)]);
              Peakpercontact=0;Peakpercontact_abs=0;
              for p = 1:length(discreet_contacts_2)                 
                  if(p == length(discreet_contacts_2))
                      vals = curr_dkappa(curr_contacts(discreet_contacts_2(p):end)) ;
                  else
                      vals = curr_dkappa(curr_contacts( discreet_contacts_2(p): discreet_contacts_2(p+1)-1) );
                  end
                  contdir = (abs(max(vals)) > abs(min(vals))) *0 +   (abs(max(vals)) < abs(min(vals)))  *1;
                  if (contdir)
                      Peakpercontact = Peakpercontact + min(vals );
                      Peakpercontact_abs = Peakpercontact_abs + abs(min(vals));
                  else
                      Peakpercontact = Peakpercontact + max(vals );
                      Peakpercontact_abs = Peakpercontact_abs + abs(max(vals));
                  end
                  
              end
                          
              if contdir
                  pooled_contactCaTrials_locdep{d}.re_totaldK(t,1) = Peakpercontact./pxlpermm;
              else
                  pooled_contactCaTrials_locdep{d}.re_totaldK(t,1) = Peakpercontact./pxlpermm;
              end            
              
              if touchdir(maxind) == 1
                  pooled_contactCaTrials_locdep{d}.re_maxdK(t,1) = (maxval * -1)./pxlpermm;
                  
              elseif touchdir(maxind) == 0
                  pooled_contactCaTrials_locdep{d}.re_maxdK(t,1) = (maxval)./pxlpermm;
              end
          end
      end

if src_smoothed
    save('pooled_contactCaTrials_locdep_smth','pooled_contactCaTrials_locdep','-v7.3');
else
    save('pooled_contactCaTrials_locdep_raw','pooled_contactCaTrials_locdep','-v7.3');
end



