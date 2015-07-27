%script_to_make_dataarray_for_Sandro
 ca_area_data (:,d) = pooled_contactCaTrials_locdep{d}.sigmag;
 ca_peak_data (:,d) = pooled_contactCaTrials_locdep{d}.sigpeak;
 ka_total_data (:,d) = pooled_contactCaTrials_locdep{d}.re_totaldK;
 ka_max_data (:,d) = pooled_contactCaTrials_locdep{d}.re_maxdK;
 light_data(:,d) = pooled_contactCaTrials_locdep{d}.lightstim;
 loc_data(:,d) = pooled_contactCaTrials_locdep{d}.poleloc;
 save('GR_150521_arraydata.mat');