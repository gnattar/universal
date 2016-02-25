
 files = dir('*pooled_contactCaTrials_phasedep.mat')
 for fn = 6:10
     f = files(fn).name
     load(f)
     
p=unique(pooled_contactCaTrials_locdep{1}.poleloc)
pl = pooled_contactCaTrials_locdep{1}.poleloc
temp_theta_binned=pl;
for i = 1:length(p)
ind = [];
ind = find(pl == p(i));
m=mean(pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean(ind));
temp_theta_binned (ind) = m;
end
for d = 1:size(pooled_contactCaTrials_locdep,2)
    pooled_contactCaTrials_locdep{d}.theta_binned = temp_theta_binned;
end

save(f,'pooled_contactCaTrials_locdep');
clear pooled_contactCaTrials_locdep
 end