for d = 2:28
    pooled_contactCaTrials_locdep2{d}.rawdata(remtrials,:) = [];
    pooled_contactCaTrials_locdep2{d}.filtdata(remtrials,:) = [];
    pooled_contactCaTrials_locdep2{d}.sigmag(remtrials) = [];
    pooled_contactCaTrials_locdep2{d}.sigpeak(remtrials) = [];
    pooled_contactCaTrials_locdep2{d}.totalKappa(remtrials) = [];
     pooled_contactCaTrials_locdep2{d}.touchTheta(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.touchdeltaKappa(remtrials) = [];
       pooled_contactCaTrials_locdep2{d}.poleloc(remtrials) = [];
        pooled_contactCaTrials_locdep2{d}.lightstim(remtrials) = [];
        
     pooled_contactCaTrials_locdep2{d}.trialnum(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.contactdir(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.contacts(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.timews(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.totalKappa_epoch(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.totalKappa_epoch_abs(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.Theta_at_contact(remtrials) = [];
      pooled_contactCaTrials_locdep2{d}.Theta_at_contact_Mean(remtrials) = [];
     
     
         pooled_contactCaTrials_locdep2{d}.num_trials(2) = [];
          pooled_contactCaTrials_locdep2{d}.trialnames(2) = [];
          pooled_contactCaTrials_locdep2{d}.CaSig_mag(2) = [];
          pooled_contactCaTrials_locdep2{d}.CaSig_peak(2) = [];
          pooled_contactCaTrials_locdep2{d}.CaSig_dur(2) = [];
          pooled_contactCaTrials_locdep2{d}.wSig_totmodKappa(2) = [];
          pooled_contactCaTrials_locdep2{d}.CaSig_data(2) = [];
          pooled_contactCaTrials_locdep2{d}.CaSig_time(2) = [];
          pooled_contactCaTrials_locdep2{d}.wSig_dKappadata(2) = [];
          pooled_contactCaTrials_locdep2{d}.wSig_dKappatime(2) = [];
          pooled_contactCaTrials_locdep2{d}.wSig_contacts(2) = [];
          pooled_contactCaTrials_locdep2{d}.wSig_contactdir(2) = [];
end

for d = 1:26
     pooled_contactCaTrials_locdep{d}.rawdata = [ pooled_contactCaTrials_locdep1{d1}.rawdata; pooled_contactCaTrials_locdep2{d2}.rawdata];
    pooled_contactCaTrials_locdep{d}.filtdata = [ pooled_contactCaTrials_locdep1{d1}.filtdata; pooled_contactCaTrials_locdep2{d2}.filtdata];
    pooled_contactCaTrials_locdep{d}.sigmag = [pooled_contactCaTrials_locdep1{d1}.sigmag;pooled_contactCaTrials_locdep2{d2}.sigmag];
    pooled_contactCaTrials_locdep{d}.sigpeak= [pooled_contactCaTrials_locdep1{d1}.sigpeak;pooled_contactCaTrials_locdep2{d2}.sigpeak];
    pooled_contactCaTrials_locdep{d}.totalKappa = [ pooled_contactCaTrials_locdep1{d1}.totalKappa; pooled_contactCaTrials_locdep2{d2}.totalKappa];
     pooled_contactCaTrials_locdep{d}.touchTheta= [pooled_contactCaTrials_locdep1{d1}.touchTheta;pooled_contactCaTrials_locdep2{d2}.touchTheta];
      pooled_contactCaTrials_locdep{d}.touchdeltaKappa= [ pooled_contactCaTrials_locdep1{d1}.touchdeltaKappa; pooled_contactCaTrials_locdep2{d2}.touchdeltaKappa];
       pooled_contactCaTrials_locdep{d}.poleloc = [pooled_contactCaTrials_locdep1{d1}.poleloc;pooled_contactCaTrials_locdep2{d2}.poleloc];
        pooled_contactCaTrials_locdep{d}.lightstim = [pooled_contactCaTrials_locdep1{d1}.lightstim;pooled_contactCaTrials_locdep2{d2}.lightstim];
        
     pooled_contactCaTrials_locdep{d}.trialnum = [ pooled_contactCaTrials_locdep1{d1}.trialnum; pooled_contactCaTrials_locdep2{d2}.trialnum];
      pooled_contactCaTrials_locdep{d}.contactdir = [ pooled_contactCaTrials_locdep1{d1}.contactdir; pooled_contactCaTrials_locdep2{d2}.contactdir];
      pooled_contactCaTrials_locdep{d}.contacts = [pooled_contactCaTrials_locdep1{d1}.contacts;pooled_contactCaTrials_locdep2{d2}.contacts];
      pooled_contactCaTrials_locdep{d}.timews = [pooled_contactCaTrials_locdep1{d1}.timews;pooled_contactCaTrials_locdep2{d2}.timews];
      pooled_contactCaTrials_locdep{d}.totalKappa_epoch = [pooled_contactCaTrials_locdep1{d1}.totalKappa_epoch;pooled_contactCaTrials_locdep2{d2}.totalKappa_epoch];
      pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs = [pooled_contactCaTrials_locdep1{d1}.totalKappa_epoch_abs;pooled_contactCaTrials_locdep2{d2}.totalKappa_epoch_abs];
      pooled_contactCaTrials_locdep{d}.Theta_at_contact = [pooled_contactCaTrials_locdep1{d1}.Theta_at_contact;pooled_contactCaTrials_locdep2{d2}.Theta_at_contact];
      pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean = [pooled_contactCaTrials_locdep1{d1}.Theta_at_contact_Mean;pooled_contactCaTrials_locdep2{d2}.Theta_at_contact_Mean];
     
     
      for k =1:6 
         pooled_contactCaTrials_locdep{d}.num_trials(k) = [ pooled_contactCaTrials_locdep1{d1}.num_trials(k)+ pooled_contactCaTrials_locdep2{d2}.num_trials(k)];
          pooled_contactCaTrials_locdep{d}.trialnames{k}= [ pooled_contactCaTrials_locdep1{d1}.trialnames{k}; pooled_contactCaTrials_locdep2{d2}.trialnames{k}];
          pooled_contactCaTrials_locdep{d}.CaSig_mag{k}= [ pooled_contactCaTrials_locdep1{d1}.CaSig_mag{k}; pooled_contactCaTrials_locdep2{d2}.CaSig_mag{k}];
          pooled_contactCaTrials_locdep{d}.CaSig_peak{k}= [ pooled_contactCaTrials_locdep1{d1}.CaSig_peak{k}; pooled_contactCaTrials_locdep2{d2}.CaSig_peak{k}];
          pooled_contactCaTrials_locdep{d}.CaSig_dur{k}= [ pooled_contactCaTrials_locdep1{d1}.CaSig_dur{k}; pooled_contactCaTrials_locdep2{d2}.CaSig_dur{k}];
          pooled_contactCaTrials_locdep{d}.wSig_totmodKappa{k}= [ pooled_contactCaTrials_locdep1{d1}.wSig_totmodKappa{k}; pooled_contactCaTrials_locdep2{d2}.wSig_totmodKappa{k}];
          pooled_contactCaTrials_locdep{d}.CaSig_data{k}= [ pooled_contactCaTrials_locdep1{d1}.CaSig_data{k}; pooled_contactCaTrials_locdep2{d2}.CaSig_data{k}];
          pooled_contactCaTrials_locdep{d}.CaSig_time{k}= [ pooled_contactCaTrials_locdep1{d1}.CaSig_time{k}; pooled_contactCaTrials_locdep2{d2}.CaSig_time{k}];
          pooled_contactCaTrials_locdep{d}.wSig_dKappadata{k}= [ pooled_contactCaTrials_locdep1{d1}.wSig_dKappadata{k}; pooled_contactCaTrials_locdep2{d2}.wSig_dKappadata{k}];
          pooled_contactCaTrials_locdep{d}.wSig_dKappatime{k}= [ pooled_contactCaTrials_locdep1{d1}.wSig_dKappatime{k}; pooled_contactCaTrials_locdep2{d2}.wSig_dKappatime{k}];
          pooled_contactCaTrials_locdep{d}.wSig_contacts{k}= [ pooled_contactCaTrials_locdep1{d1}.wSig_contacts{k}; pooled_contactCaTrials_locdep2{d2}.wSig_contacts{k}];
          pooled_contactCaTrials_locdep{d}.wSig_contactdir{k}= [ pooled_contactCaTrials_locdep1{d1}.wSig_contactdir{k}; pooled_contactCaTrials_locdep2{d2}.wSig_contactdir{k}];
end
end


    pooled_contactCaTrials_locdep{d}.rawdata(remtrials,:) = [];
    pooled_contactCaTrials_locdep{d}.filtdata(remtrials,:) = [];
    pooled_contactCaTrials_locdep{d}.sigmag(remtrials) = [];
    pooled_contactCaTrials_locdep{d}.sigpeak(remtrials) = [];
    pooled_contactCaTrials_locdep{d}.totalKappa(remtrials) = [];
     pooled_contactCaTrials_locdep{d}.touchTheta(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.touchdeltaKappa(remtrials) = [];
       pooled_contactCaTrials_locdep{d}.poleloc(remtrials) = [];
        pooled_contactCaTrials_locdep{d}.lightstim(remtrials) = [];
        
     pooled_contactCaTrials_locdep{d}.trialnum(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.contactdir(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.contacts(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.timews(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.totalKappa_epoch(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.Theta_at_contact(remtrials) = [];
      pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(remtrials) = [];
      
      pxlpermm = 24.38;
      for d = 1:28
          pooled_contactCaTrials_locdep{d}.re_maxdK = [];
          pooled_contactCaTrials_locdep{d}.re_totaldK = [];
          numtr= size( pooled_contactCaTrials_locdep{d}.totalKappa,1);
          for t = 1:numtr
              curr_dkappa = pooled_contactCaTrials_locdep{d}.touchdeltaKappa{t};
              curr_dkappa_t = pooled_contactCaTrials_locdep{d}.timews{t};
              curr_contacts = pooled_contactCaTrials_locdep{d}.contacts{t};
              curr_contacts = curr_contacts(curr_contacts < 1190); %% within the first 1 sec
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