n=1

a(:,1) = pooled_contactCaTrials_thetadep_Silenced{n}.lightstim;
a(:,4)=pooled_contactCaTrials_thetadep_Silenced{n}.sigmag;
a(:,3)=pooled_contactCaTrials_thetadep_Silenced{n}.totalKappa;
a(:,2)=pooled_contactCaTrials_thetadep_Silenced{n}.poleloc;
a(:,5)=pooled_contactCaTrials_thetadep_Silenced{n}.trialnum;

ac(:,1)=pooled_contactCaTrials_thetadep_Silenced{n}.touchdeltaKappa;
ac(:,2)=pooled_contactCaTrials_thetadep_Silenced{n}.contacts';
ac(:,3)=pooled_contactCaTrials_thetadep_Silenced{n}.contactdir;
ac(:,4)=pooled_contactCaTrials_thetadep_Silenced{n}.timews;
ploc = unique(a(:,2));


x=3
id = find((a(:,1)==0) & (a(:,2)==ploc(x)))
stemp = a((a(:,1)==0) & (a(:,2)==ploc(x)),4);
ktemp = a((a(:,1)==0) & (a(:,2)==ploc(x)),3);
figure;plot(ktemp,stemp,'o');vline(0,'k--')
title(['Prox Cell' num2str(n) ' poleloc' num2str(x) ' ' num2str(ploc(x)) ', ' num2str(length(stemp)) ' NL'])

id = find((a(:,1)==01) & (a(:,2)==ploc(x)))
stemp = a((a(:,1)==1) & (a(:,2)==ploc(x)),4);
ktemp = a((a(:,1)==1) & (a(:,2)==ploc(x)),3);
figure;plot(ktemp,stemp,'o');vline(0,'k--')
title(['Prox Cell' num2str(n) ' poleloc' num2str(x) ' ' num2str(ploc(x)) ', ' num2str(length(stemp)) ' L'])

axis([-35 35 0 5000]);



%%

j=32
figure;plot(ac{j,4}*500,ac{j,1}); title(num2str(a(j,5)));
touchind =floor(ac{j,2}(:));
temp = round(ac{j,4}*500);
[ri,ti,ci]= intersect(temp,touchind);
hold on;  plot(ri,ac{j,1}(ti),'r*')
figure;plot(pooled_contactCaTrials_thetadep_Silenced{n}.rawdata(j,:));hline(0,'k-')
t = ac{j, 2};
ind=find(diff(t)~=1);
count =1;Peakpercontact=0;
for p = 1:length(ind)
    vals = ac{j,1}(ti(count:ind(p))) ;
    contdir = (median(vals) >0) *0 +(median(vals)< 0)*1;
    if (contdir)
        Peakpercontact =Peakpercontact + min(vals );
    else
        Peakpercontact =Peakpercontact + max(vals );
    end
count = count +ind(p);
end
%%




b(:,1) = arrayfun(@(x) x.lightstim, contact_CaTrials);
b(:,2) = arrayfun(@(x) x.barpos, contact_CaTrials);
b(:,3) = arrayfun(@(x) x.total_touchKappa, contact_CaTrials);
b(:,4) = arrayfun(@(x) nansum(x.dff(1,:)), contact_CaTrials);
