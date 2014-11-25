n=1
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
%
%% 
n=5
a = []; ac = {};
a(:,1) = pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.lightstim;
a(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.poleloc;
a(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.AbstotalKappa_RE;
a(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag_RE;
a(:,5)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.trialnum;
a(:,6)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.totalKappa_RE;
a(:,7)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.sigmag;

ac(:,1)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.touchdeltaKappa;
ac(:,2)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contacts';
ac(:,3)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.contactdir;
ac(:,4)=pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.timews;
ploc = unique(a(:,2));

%% 
x=5
id = find((a(:,1)==0) & (a(:,2)==ploc(x)))
stemp = a(id,4);
ktemp = a(id,3).* sign(a(id,6));
figure;plot(ktemp,stemp,'o');vline(0,'k--');hold on;
stemp = a(id,7);plot(ktemp,stemp,'g*');
title(['Prox Cell' num2str(n) ' poleloc' num2str(x) ' ' num2str(ploc(x)) ', ' num2str(length(stemp)) ' NL'])
axis auto;
%%
id = find((a(:,1)==01) & (a(:,2)==ploc(x)));
stemp = a(id,4);
ktemp = a(id,3).* sign(a(id,6));
hold on ; plot(ktemp,stemp,'ro');vline(0,'k--')
stemp = a(id,7);plot(ktemp,stemp,'m*');
title(['Prox Cell' num2str(n) ' poleloc' num2str(x) ' ' num2str(ploc(x)) ', ' num2str(length(stemp)) ' L'])

axis auto;

%%
% j=47
FrameTime =pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.FrameTime(1);
%  figure;plot(ac{j,4}*500,ac{j,1}); title(num2str(a(j,5)));
touchind =unique(ac{j,2}(:));
temp = unique(round(ac{j,4}*500));
[ri,ti,ci]= intersect(temp,touchind);
%  hold on;  plot(ri,ac{j,1}(ti),'r*');
% figure;plot(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE(j,:));hline(0,'k-');
Cadata =pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE(j,:);
% title(num2str(a(j,5)));

pt = round(ac{j,4}(1)./FrameTime);
spt = pt.*FrameTime;
ept = ((length(Cadata)-1).* FrameTime)+spt;

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
smag = nansum(pooled_contactCaTrials_thetadep_Silenced_SW_RE{n}.rawdata_RE(j,:))
figure;plot(ac{j,4},ac{j,1}.*50,'k');hold on;
plot(ac{j,4}(ti),ac{j,1}(ti).*50,'r*')
plot([spt:FrameTime:ept], Cadata,'b');hline(0,'k-'); 
title([num2str(a(j,5)) ' K' num2str(sign(Peakpercontact).*Peakpercontact_abs) ' S' num2str(smag )] );
%%

b(:,1) = arrayfun(@(x) x.lightstim, contact_CaTrials);
b(:,2) = arrayfun(@(x) x.barpos, contact_CaTrials);
b(:,3) = arrayfun(@(x) x.total_touchKappa, contact_CaTrials);
b(:,4) = arrayfun(@(x) nansum(x.dff(1,:)), contact_CaTrials);
