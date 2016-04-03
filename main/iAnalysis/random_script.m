tt=[];inds=[];pl=[];temp=[];
pl=unique(pooled_contactCaTrials_locdep{1}.decoder.NLS.poleloc)
temp = pooled_contactCaTrials_locdep{1}.decoder.NLS.poleloc;
for i = 1:length(pl)
inds = find(temp == pl(i));
tt(inds) = i;
end
for i = 1: size(pooled_contactCaTrials_locdep,2)
pooled_contactCaTrials_locdep{i}.decoder.NLS.poleloc = tt';
end
save(f,'pooled_contactCaTrials_locdep');
clear pooled_contactCaTrials_locdep
