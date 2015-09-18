l=pooled_contactCaTrials_locdep{1}.lightstim;
nlind = find(l == 0);
lind = find(l == 1);

nl=mean(cell2mat((cellfun(@(x) x.sigpeak(nlind),pooled_contactCaTrials_locdep,'uni',0))));
l=mean(cell2mat((cellfun(@(x) x.sigpeak(lind),pooled_contactCaTrials_locdep,'uni',0))));

peak_diff = nl-l

find(peak_diff<0)

nl=mean(cell2mat((cellfun(@(x) x.sigmag(nlind),pooled_contactCaTrials_locdep,'uni',0))));
l=mean(cell2mat((cellfun(@(x) x.sigmag(lind),pooled_contactCaTrials_locdep,'uni',0))));

mag_diff = nl-l

find(mag_diff<0)