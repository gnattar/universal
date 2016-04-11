load('Phase Summary Data rPhase normmean ctrl.mat')
p=phasedata.meanResp_phase_ctrl{1};
pL=phasedata.meanResp_phase_mani{1};
corrp = corrcoef(p');
corrpL = corrcoef(pL');

temp=[];temp2=[];
temp=triu(corrp,1);temp(temp==0) = nan;
temp2 = reshape(temp,size(temp,1)*size(temp,2),1);
temp2(find(isnan(temp2)))=[];
bins=[-1:.1:1];
hphase = hist(temp2,bins)./length(temp2);
figure; plot(bins,hphase);

temp=[];temp2=[];
temp=triu(corrpL,1);temp(temp==0) = nan;
temp2 = reshape(temp,size(temp,1)*size(temp,2),1);
temp2(find(isnan(temp2)))=[];
bins=[-1:.1:1];
hphaseL = hist(temp2,bins)./length(temp2);
hold on; plot(bins,hphaseL,'r');
axis([-1 1 0 .08]);
set(gca,'xtick',[-1:.2:1],'tickdir','out','ticklength',[.02 .02],'fontsize',16)

title('Histogram of corrcoef of phase coding in L5 cells')



load('Theta Summary Data rTheta normmean ctrl.mat')



t=thetadata.meanResp_theta_ctrl{1};
tm=thetadata.meanResp_theta_mani{1};
corrt = corrcoef(t');
corrtL = corrcoef(tm');
temp=[];temp2=[];
temp=triu(corrt,1);temp(temp==0) = nan;
temp2 = reshape(temp,size(temp,1)*size(temp,2),1);
temp2(find(isnan(temp2)))=[];
bins=[-1:.1:1];
htheta = hist(temp2,bins)./length(temp2);
figure; plot(bins,htheta)


temp=[];temp2=[];
temp=triu(corrtL,1);temp(temp==0) = nan;
temp2 = reshape(temp,size(temp,1)*size(temp,2),1);
temp2(find(isnan(temp2)))=[];
bins=[-1:.1:1];
hthetaL = hist(temp2,bins)./length(temp2);
hold on; plot(bins,hthetaL,'r');

axis([-1 1 0 .08]);
set(gca,'xtick',[-1:.2:1],'tickdir','out','ticklength',[.02 .02],'fontsize',16)
title('Histogram of corrcoef of theta coding in L5 cells')
