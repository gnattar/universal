n=4
a = []; ac = {};
a(:,1) = pooled_contactCaTrials_thetadep_Silenced_SW{n}.lightstim;
a(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.poleloc;
a(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.totalKappa;
a(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.sigmag;
a(:,5)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.trialnum;

ac(:,1)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.touchdeltaKappa;
ac(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.contacts';
ac(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.contactdir;
ac(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW{n}.timews;
ploc = unique(a(:,2));


x=2
id = find((a(:,1)==0) & (a(:,2)==ploc(x)))
stemp = a((a(:,1)==0) & (a(:,2)==ploc(x)),4);
ktemp = a((a(:,1)==0) & (a(:,2)==ploc(x)),3);
figure;plot(ktemp,stemp,'o');vline(0,'k--')
title(['Prox Cell' num2str(n) ' poleloc' num2str(x) ' ' num2str(ploc(x)) ', ' num2str(length(stemp)) ' NL'])
axis auto;

id = find((a(:,1)==01) & (a(:,2)==ploc(x)));
stemp = a((a(:,1)==1) & (a(:,2)==ploc(x)),4);
ktemp = a((a(:,1)==1) & (a(:,2)==ploc(x)),3);
hold on ; plot(ktemp,stemp,'ro');vline(0,'k--')
title(['Prox Cell' num2str(n) ' poleloc' num2str(x) ' ' num2str(ploc(x)) ', ' num2str(length(stemp)) ' L'])

axis auto;



%%

% j=47
figure;plot(ac{j,4}*500,ac{j,1}); title(num2str(a(j,5)));
touchind =unique(ac{j,2}(:));
temp = unique(round(ac{j,4}*500));
[ri,ti,ci]= intersect(temp,touchind);
hold on;  plot(ri,ac{j,1}(ti),'r*');
figure;plot(pooled_contactCaTrials_thetadep_Silenced_SW{n}.rawdata(j,:));hline(0,'k-');
t = unique(ac{j, 2});
ind=find(diff(t)~=1);
count =0;Peakpercontact=0;Peakpercontact_abs=0;

for p = 1:(length(ind)+1)
    
        if(p >length(ind))
               vals = ac{j,1}(ti(count+1:end)) ;
        else
             vals = ac{j,1}(ti(count+1:ind(p))) ;
        end
 
    contdir = (abs(max(vals)) > abs(min(vals))) *0 +   (abs(max(vals)) < abs(min(vals)))  *1;
    if (contdir &  min(vals )<.3)
        Peakpercontact = Peakpercontact + min(vals );
        Peakpercontact_abs = Peakpercontact_abs + abs(min(vals));
    elseif(max(vals)>.3)
        Peakpercontact = Peakpercontact + max(vals );
        Peakpercontact_abs = Peakpercontact_abs + abs(max(vals));
    end
    if(p>length(ind))
    else
    count = ind(p);
    end
  
end
Peakpercontact
Peakpercontact_abs
smag = nansum(pooled_contactCaTrials_thetadep_Silenced_SW{n}.rawdata(j,:))
%%




b(:,1) = arrayfun(@(x) x.lightstim, contact_CaTrials);
b(:,2) = arrayfun(@(x) x.barpos, contact_CaTrials);
b(:,3) = arrayfun(@(x) x.total_touchKappa, contact_CaTrials);
b(:,4) = arrayfun(@(x) nansum(x.dff(1,:)), contact_CaTrials);
