
temp = []; tw=[]; ind = [];
temp=sort(unique(pooled_contactCaTrials_locdep{1}.theta_binned_new),'descend');
tw=[0:length(temp)].*-6.75;
origThetabinned =pooled_contactCaTrials_locdep{1}.theta_binned_new;
for i = 1: length(temp)
ind = find(origThetabinned == temp(i));
tempGlobThetabinned (ind,1) = tw(i);
end
for i = 1:size(pooled_contactCaTrials_locdep,2)
pooled_contactCaTrials_locdep{i}.theta_binned_new = tempGlobThetabinned;
end
save(f,'pooled_contactCaTrials_locdep');


clear tempGlobThetabinned
clear origThetabinned
clear pooled_contactCaTrials_locdep