cd ('/Volumes/GR_Ext_Analysis/v5/Analysis/Location preference silencing/Analysis v2 151009/Phase_Location/all_sess')
files = dir('*_pooled_*.mat')
count = 1;
for n = 1: 10
f = files(n).name
load(f)
all_sess{count}.theta=pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean;
all_sess{count}.theta=pooled_contactCaTrials_locdep{1}.Theta_at_contact_Mean;
all_sess{count}.phase=pooled_contactCaTrials_locdep{1}.touchPhase;
all_sess{count}.lightstim=pooled_contactCaTrials_locdep{1}.lightstim;
all_sess{count}.poleloc=pooled_contactCaTrials_locdep{1}.poleloc;
l=[];v=[];i=[];l2=[];
l=pooled_contactCaTrials_locdep{1}.poleloc;
[v,i]=unique(l);
for p = 1:length(l)
l2(p)=find(v==l(p));
end
l2 = l2';
all_sess{count}.locs=l2;
count= count+1;
end



phase=cell2mat(cellfun(@(x) x.phase,all_sess,'uni',0)')
theta=cell2mat(cellfun(@(x) x.theta,all_sess,'uni',0)')
loc=cell2mat(cellfun(@(x) x.locs,all_sess,'uni',0)')
lightstim=cell2mat(cellfun(@(x) x.lightstim,all_sess,'uni',0)')
poleloc=cell2mat(cellfun(@(x) x.poleloc,all_sess,'uni',0)')

temp=find(poleloc>280 & poleloc<310);
poleloc(temp) = 298;
temp=find(poleloc>330)
poleloc(temp) = 335;
temp=find(poleloc>250 & poleloc<280)
poleloc(temp) = 261;

temp=find(poleloc>200 & poleloc<240)
poleloc(temp) = 225;
unique(poleloc)
temp=find(poleloc>150 & poleloc<190)
poleloc(temp) = 188;
temp=find(poleloc>110 & poleloc<116)
poleloc(temp) = 114;
find(poleloc>280 & poleloc<310)
temp=find(poleloc<100)
poleloc(temp) = 114;

data.poleloc=poleloc;
data.theta=theta;
data.phase=phase;
data.lightstim=lightstim;
save('data','data')

figure;plot(theta(lightstim==0),poleloc(lightstim==0),'o');hold on; plot(theta(lightstim==1),poleloc(lightstim==1)+5,'ro');
axis([-35 40 100 350])

set(gca,'Ytick',unique(poleloc))
set(gca,'Yticklabel',{'1';'2';'3';'4';'5';'6'})
set(gca,'YDir','reverse')
set(gca,'XDir','reverse');
set(gca,'fontsize',16);
ylabel('Location','fontsize',16);xlabel('Whisker Theta at touch','fontsize',16)
title('Pole location vs whisker angle','fontsize',16)

figure;plot(phase(lightstim==0),poleloc(lightstim==0),'o');hold on; plot(phase(lightstim==1),poleloc(lightstim==1)+5,'ro');
axis([-3.5 3.5 100 350]);
 set(gca,'Ytick',unique(poleloc))
set(gca,'Yticklabel',{'1';'2';'3';'4';'5';'6'})
set(gca,'YDir','reverse');
 set(gca,'fontsize',16);
ylabel('Location','fontsize',16);xlabel('Whisker Phase at touch','fontsize',16)
set(gca,'Xtick',[-pi:pi/2:pi]);set(gca,'Xticklabel',{'-pi';'-pi/2';'0';'pi/2';'pi'})
title('Pole location vs whisker phase','fontsize',16)

phasebins = [-pi:.2:pi]
thetabins = [-40:2.5:40];
figure;for i = 1: length(l)
subplot(length(l),1,i); plot(phasebins,hPh(i,:));axis([-3.5 3.5 0 .2]);
set(gca,'XDir','reverse');set(gca,'tickDir','out','ticklength',[.02 .02]);
end
 suptitle('Phase per touch location')
 
 
figure;for i = 1: length(l)
subplot(length(l),1,i); plot(thetabins,hTh(i,:));axis([-35 40 0 .4]);
set(gca,'XDir','reverse');set(gca,'tickDir','out','ticklength',[.02 .02]);
end

suptitle('Theta per touch location')
axis([-35 40 0 .3])