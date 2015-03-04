function [pooled_contactCaTrials_locdep] = whiskloc_dependence_pooldata(collected_data,collected_summary)
pooled_contactCaTrials_locdep = [];
count =1;
pxlpermm = 24.38; %% 18-7.5 mm = 298-42 pixels
for i = 1: size(collected_summary,2) 
    d = length(collected_summary{1,i}.dends);
    
        temp_solotrial = cell2mat(arrayfun(@(x) x.solo_trial(1), collected_data{1,i},'uniformoutput',0)');
        temp_contactdir = arrayfun(@(x) x.contactdir{1}, collected_data{1,i},'uniformoutput',0)';
        temp_contacts = arrayfun(@(x) x.contacts{1}, collected_data{1,i},'uniformoutput',0);
        temp_tws = arrayfun(@(x) x.ts_wsk{1}, collected_data{1,i},'uniformoutput',0)';
        temp_touchSetpoint = arrayfun(@(x) x.Setpoint{1}, collected_data{1,i},'uniformoutput',0)'; 
        temp_touchdeltaKappa = arrayfun(@(x) x.deltaKappa{1}, collected_data{1,i},'uniformoutput',0)';         
        
    for j = 1:d
        data = cell2mat(arrayfun(@(x) x.dff(j,:), collected_data{1,i},'uniformoutput',0)');
        sampling_time = collected_data{1,i}(1).FrameTime;
        winsize = round(.2/sampling_time);
        temp_data = data;
        temp_data_filt = filter(ones(1,winsize)/winsize,1,data,[],2);

        temp_totalKappa = cell2mat(arrayfun(@(x) x.total_touchKappa(1), collected_data{1,i},'uniformoutput',0)');

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
          wSig_totmodKappa = cell(length(polelocs),2);
          num_trials =  zeros(length(polelocs),2);          
        else
          CaSig_mag = cell(length(polelocs),1); %NL
          CaSig_peak = cell(length(polelocs),1);
          CaSig_dur = cell(length(polelocs),1); %fwhm 
          wSig_totmodKappa = cell(length(polelocs),1);
          num_trials =  zeros(length(polelocs),1);
        end
        
        for k = 1: length(polelocs)
            curr_poleloc_trials = (temp_poleloc == polelocs(k));
            if max(temp_lightstim) >0
                curr_loc_L_trials = temp_data (find(curr_poleloc_trials & temp_lightstim),:);
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_L_Kappa = temp_totalKappa (find(curr_poleloc_trials & temp_lightstim));
                curr_loc_NL_Kappa = temp_totalKappa (find(curr_poleloc_trials & ~temp_lightstim));
                num_trials (k,2) = size(curr_loc_L_Kappa ,1);
                num_trials (k,1) = size(curr_loc_NL_Kappa ,1);
                CaSig_mag{k,1} = nansum(curr_loc_NL_trials,2);
                CaSig_mag{k,2} = nansum(curr_loc_L_trials,2);
                CaSig_peak{k,1} = prctile(curr_loc_NL_trials,99,2);
                CaSig_peak{k,2} = prctile(curr_loc_L_trials,99,2);
                wSig_totmodKappa{k,1} = curr_loc_NL_Kappa./pxlpermm;
                wSig_totmodKappa{k,2} = curr_loc_L_Kappa ./pxlpermm;

            else
                curr_loc_NL_trials = temp_data (find(curr_poleloc_trials & ~temp_lightstim),:);
                curr_loc_NL_Kappa = temp_totalKappa (find(curr_poleloc_trials & ~temp_lightstim));
                CaSig_mag{k,1} = nansum(curr_loc_NL_trials,2);
                CaSig_peak{k,1} = prctile(curr_loc_NL_trials,99,2);
                wSig_totmodKappa{k,1} = curr_loc_NL_Kappa./pxlpermm;
                num_trials (k,1) = size(curr_loc_NL_Kappa ,1);
            end

        end

        
        pooled_contactCaTrials_locdep {count}.rawdata = temp_data;
         pooled_contactCaTrials_locdep {count}.filtdata =temp_data_filt ;
        pooled_contactCaTrials_locdep {count}.sigmag = nansum(temp_data,2);
        pooled_contactCaTrials_locdep {count}.sigpeak = prctile(temp_data,99,2);
        pooled_contactCaTrials_locdep {count}.FrameTime = sampling_time;
        pooled_contactCaTrials_locdep {count}.totalKappa = temp_totalKappa./pxlpermm;
        pooled_contactCaTrials_locdep {count}.touchSetpoint = temp_touchSetpoint;
        pooled_contactCaTrials_locdep {count}.touchdeltaKappa = temp_touchdeltaKappa;
        pooled_contactCaTrials_locdep{count}.poleloc= temp_poleloc ;
        pooled_contactCaTrials_locdep{count}.lightstim=   temp_lightstim ;
        pooled_contactCaTrials_locdep{count}.num_trials=   num_trials;
        pooled_contactCaTrials_locdep{count}.CaSig_mag = CaSig_mag;
        pooled_contactCaTrials_locdep{count}.CaSig_peak= CaSig_peak;
        pooled_contactCaTrials_locdep{count}.wSig_totmodKappa = wSig_totmodKappa;
        pooled_contactCaTrials_locdep{count}.mousename= collected_summary{i}.mousename;
        pooled_contactCaTrials_locdep{count}.sessionname= collected_summary{i}.sessionname;
        pooled_contactCaTrials_locdep{count}.reg= collected_summary{i}.reg;
        pooled_contactCaTrials_locdep{count}.fov= collected_summary{i}.fov;
        pooled_contactCaTrials_locdep{count}.dend= collected_summary{i}.dends(j);
        pooled_contactCaTrials_locdep{count}.trialnum= temp_solotrial;
        pooled_contactCaTrials_locdep{count}.contactdir= temp_contactdir;
        pooled_contactCaTrials_locdep{count}.contacts= temp_contacts;
        pooled_contactCaTrials_locdep{count}.timews=temp_tws;      
        count = count+1;
    end
end
save('pooled_contactCaTrials_locdep','pooled_contactCaTrials_locdep');



