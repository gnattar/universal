function [pooled_contactCaTrials_locdep] = prep_deltatheta(pooled_contactCaTrials_locdep)
% temp1 = pooled_contactCaTrials_locdep{1}.theta_binned;
p = unique(pooled_contactCaTrials_locdep{1}.poleloc);
for n = 1: length(p)
    ind = find(pooled_contactCaTrials_locdep{1}.poleloc == p(n));
tempwave(ind,1) = mean(pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean(ind));
end
temp1 = tempwave;
a=sort(unique(temp1),'descend')
t=diff(a)/2
temp = pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean;
if(length(a) == 3)
be=[max(temp)+.1 a(1)+t(1) a(2)+t(2) min(temp)-.1]; % for 4 locs
elseif(length(a) == 4)
be=[max(temp)+.1 a(1)+t(1) a(2)+t(2) a(3)+t(3) min(temp)-.1]; % for 4 locs
elseif (length(a) ==5)
be=[max(temp)+.1 a(1)+t(1) a(2)+t(2) a(3)+t(3) a(4)+t(4) min(temp)-.1]; % for 5 locs
elseif (length(a) ==6)
be=[max(temp)+.1 a(1)+t(1) a(2)+t(2) a(3)+t(3) a(4)+t(4) a(5)+t(5) min(temp)-.1]; % for 5 locs
end
bedge=sort(be,'ascend');
[count edges mid loc] = histcn(temp, bedge);

mids = mid{1};
outliers = find(loc==0);
length(outliers);
temp_thetabinned=mids(loc);

for i = 1:size(pooled_contactCaTrials_locdep,2)
pooled_contactCaTrials_locdep{i}.theta_binned_new = temp_thetabinned';
pooled_contactCaTrials_locdep{i}.theta_binned = tempwave;
end


t = sort(unique(pooled_contactCaTrials_locdep{1}.poleloc),'descend')
t2 = sort(unique(pooled_contactCaTrials_locdep{1}.theta_binned_new),'ascend')
for i = 1:length(a)
pp(find(pooled_contactCaTrials_locdep{1}.poleloc == t(i))) = i;
pp2(find(pooled_contactCaTrials_locdep{1}.theta_binned_new == t2(i))) = i;
end
pp=pp';
pp2=pp2';

figure;plot(pp);hold on;
plot(pp2,'r')