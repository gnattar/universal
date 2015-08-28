function [Sil_sameLP,Sil_diffLP,Inc_sameLP,Inc_diffLP]= Analyze_meanResp_summary(data,lightcond,group)
%%Analyze_meanResp_summary(data)
%% you need to have run whiskloc_dep_stats & whisk_locdep_plot_contour before this 
% toquickly run them
% [pooled_contactCaTrials_locdep]= whiskloc_dependence_stats(pooled_contactCaTrials_locdep,[1:size(pooled_contactCaTrials_locdep,2)],'re_totaldK','sigpeak', [12 11 10 9 8],0,0);
% for d = 1: size(pooled_contactCaTrials_locdep,2)
%     [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,'re_totaldK','PR',[0 400],'cf',0,[180 210 230 250 270 300]);
% end


LPI_nl=arrayfun(@(x) x.LPI_ctrl(1,:)', data,'uni',0)';LPI_nl = cell2mat(LPI_nl{1});
LPInCTRL_nl=arrayfun(@(x) x.LPInCTRL_ctrl(1,:)', data,'uni',0)';LPInCTRL_nl = cell2mat(LPInCTRL_nl{1}); 
LPId_nl=arrayfun(@(x) x.LPId_ctrl(1,:)', data,'uni',0)';LPId_nl = cell2mat(LPId_nl{1});% this has max - mean
diffmR_nl=arrayfun(@(x) x.diffmeanResp_ctrl(1,:)', data,'uni',0)';diffmR_nl = cell2mat(diffmR_nl{1}); % this hass max - min
mRPrefLoc_nl=arrayfun(@(x) x.meanRespPrefLoc_ctrl(1,:)', data,'uni',0)';mRPrefLoc_nl = cell2mat(mRPrefLoc_nl{1}); 
PTh_nl= arrayfun(@(x) x.PTh_ctrl(1,:)', data,'uni',0)';PTh_nl=cell2mat(PTh_nl{1});
PLoc_nl= arrayfun(@(x) x.PLoc_ctrl(1,:)', data,'uni',0)';PLoc_nl=cell2mat(PLoc_nl{1});

if lightcond
  LPI_l=arrayfun(@(x) x.LPI_mani(1,:)', data,'uni',0)';LPI_l = cell2mat(LPI_l{1});
LPInCTRL_l=arrayfun(@(x) x.LPInCTRL_mani(1,:)', data,'uni',0)';LPInCTRL_l = cell2mat(LPInCTRL_l{1});
LPId_l=arrayfun(@(x) x.LPId_mani(1,:)', data,'uni',0)';LPId_l = cell2mat(LPId_l{1});% this has max - mean
diffmR_l=arrayfun(@(x) x.diffmeanResp_mani(1,:)', data,'uni',0)';diffmR_l = cell2mat(diffmR_l{1});% this has max - min
mRPrefLoc_l=arrayfun(@(x) x.meanRespPrefLoc_mani(1,:)', data,'uni',0)';mRPrefLoc_l = cell2mat(mRPrefLoc_l{1}); 
PTh_l= arrayfun(@(x) x.PTh_mani(1,:)', data,'uni',0)';PTh_l=cell2mat(PTh_l{1});
PLoc_l= arrayfun(@(x) x.PLoc_mani(1,:)', data,'uni',0)';PLoc_l=cell2mat(PLoc_l{1});  

% LPI from norm slopes wrt ctrl data

effect = (LPInCTRL_nl(:,1)>LPInCTRL_l(:,1));
if lightcond & ~group
    effect(:,1) = 1;
end
sil = find(effect==1);
inc= find(effect==0);

else
    effect = ones(size(LPInCTRL_nl,1));
    sil = find(effect==1);
    inc =[];
end



%Norm Slope at PRef Loc
bins = [0:.25:10];
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);hnl=hist(LPInCTRL_nl(:,1),bins);plot(bins,hnl,'k');hold on ;
if lightcond
hl=hist(LPInCTRL_l(:,1),bins); plot(bins,hl,'r');
end
set(gca,'yscale','lin');
xlabel('Loc Pref normalized Slope Max/Mean','Fontsize',16);title('Hist LPI NormSlope Max/Mean','Fontsize',16);
set(gca,'Fontsize',16);

subplot(1,2,2);plot(bins,cumsum(hnl),'k');hold on ;
if lightcond
plot(bins,cumsum(hl),'r');set(gca,'yscale','lin');
end
xlabel('Loc Pref normalized Slope Max/Mean','Fontsize',16);title('Cum Hist LPI NormSlope Max/Mean','Fontsize',16);
set(gca,'Fontsize',16);
text(5,80,['Sil ' num2str(length(sil))  ' cells']);
text(5,50,['Inc ' num2str(length(inc))  ' cells']);

% meanResp at PRef Loc
bins = [0:25:600];
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);hnl=hist(mRPrefLoc_nl(:,1),bins);plot(bins,hnl,'k');hold on ;
if lightcond
hl=hist(mRPrefLoc_l(:,1),bins); plot(bins,hl,'r');
end
set(gca,'yscale','lin');
xlabel('mean Resp Amp at Pref Loc','Fontsize',16);title('Hist mean Resp Amp at Pref Loc','Fontsize',16);
set(gca,'Fontsize',16);

subplot(1,2,2);plot(bins,cumsum(hnl),'k');hold on ;
if lightcond
plot(bins,cumsum(hl),'r');set(gca,'yscale','lin');
end
xlabel('mean Resp Amp at Pref Loc','Fontsize',16);title('Cum Hist mean Resp Amp at Pref Loc','Fontsize',16);
set(gca,'Fontsize',16);
text(100,200,['Sil ' num2str(length(sil))  ' cells']);
text(100,180,['Inc ' num2str(length(inc))  ' cells']);

% plotting norm slopes ctrl
totaldends = size(LPInCTRL_nl,1);
hsil=figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w'); hold on;
if lightcond
hinc=figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w'); hold on;
end
count = 1;
thetabins = [-50:5:50];
tempdata= nan(totaldends,length(thetabins),2);
for sess = 1: size(data.NormSlopesnCTRL_ctrl,2)
    dends = size(data.NormSlopesnCTRL_ctrl{sess},1);
    for d = 1:dends
        touch_th = data.TouchTh_ctrl{sess}(d,:);
        Pref_touch_th = data.PTh_ctrl{sess}(d);
        temp = touch_th-Pref_touch_th;
        x = 5.*round(temp/5); % rounding to nearest 5
        y = data.NormSlopesnCTRL_ctrl{sess}(d,:,1);
        
        if effect(count)==1
            figure(hsil);ind = 1;
        else
            figure(hinc);ind =2;
        end               
        subplot(1,2,1);plot(x,y,'o-','color',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'linewidth',.05); hold on;
        for t = 1:length(x)
            tempdata (count,find(thetabins==x(t)),ind) = y(t);
        end
        count = count+1;
    end
end
figure(hsil);
subplot(1,2,1); hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,1)),nanstd(tempdata(:,:,1))./sqrt(nansum(tempdata(:,:,1))),'ko-');
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 0 8]);
title('Theta preference ctrl');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('Slope dFF vs |dK|','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]); 

figure(hinc);
subplot(1,2,1); hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,2)),nanstd(tempdata(:,:,2))./sqrt(nansum(tempdata(:,:,2))),'ko-');
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 0 8]);
title('Theta preference ctrl');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('Slope dFF vs |dK|','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]); 

NormSlopesnCTRL_PTcentered_nl = tempdata;

count = 1;
% plotting Norm slopes mani
tempdata= nan(totaldends,length(thetabins),2);
for sess = 1: size(data.NormSlopes_mani,2)
    dends = size(data.Slopes_mani{sess},1);
    for d = 1:dends
        touch_th = data.TouchTh_mani{sess}(d,:);
        Pref_touch_th = data.PTh_mani{sess}(d,1);
        temp = touch_th-Pref_touch_th;
        x = 5.*round(temp/5); % rounding to nearest 5
        y = data.NormSlopesnCTRL_mani{sess}(d,:,1);
        if effect(count)==1
            figure(hsil);ind = 1;
        else
            figure(hinc);ind = 2;
        end           
        subplot(1,2,2);plot(x,y,'o-','color',[.85 .5 .5],'MarkerEdgeColor',[.85 .5 .5],'MarkerFaceColor',[.85 .5 .5],'linewidth',.05); hold on;
        for t = 1:length(x)
            tempdata (count,find(thetabins==x(t)),ind) = y(t);
        end
        count = count+1;
    end
end
figure(hsil);
subplot(1,2,2);hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,1)),nanstd(tempdata(:,:,1))./sqrt(nansum(tempdata(:,:,1))),'ro-')
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 0 8]);
title('Theta preference mani');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('Slope dFF vs |dK|','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]);

figure(hinc);
subplot(1,2,2);hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,2)),nanstd(tempdata(:,:,2))./sqrt(nansum(tempdata(:,:,2))),'ro-')
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 0 8]);
title('Theta preference mani');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('Slope dFF vs |dK|','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]);

NormSlopesnCTRL_PTcentered_l = tempdata;

% plotting mResp ctrl
totaldends = size(LPInCTRL_nl,1);
hsil=figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w'); hold on;
hinc=figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w'); hold on;
count = 1;
thetabins = [-50:5:50];
tempdata= nan(totaldends,length(thetabins),2);
for sess = 1: size(data.meanResp_ctrl,2)
    dends = size(data.meanResp_ctrl{sess},1);
    for d = 1:dends
        y = data.meanResp_ctrl{sess}(d,:,1);
        [maxval,LP] = max(y); 
        touch_th = data.TouchTh_ctrl{sess}(d,:);
        Pref_touch_th = touch_th(LP);
        temp = touch_th-Pref_touch_th;
        x = 5.*round(temp/5); % rounding to nearest 5
%         y=y./nanmin(data.meanResp_ctrl{sess}(d,:,1)); % if you want to normalize
        if effect(count)==1
            figure(hsil);ind = 1;
        else
            figure(hinc);ind =2;
        end               
        subplot(1,2,1);plot(x,y,'o-','color',[.5 .5 .5],'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',[.5 .5 .5],'linewidth',.05); hold on;
        for t = 1:length(x)
            tempdata (count,find(thetabins==x(t)),ind) = y(t);
        end
        count = count+1;
    end
end
figure(hsil);
subplot(1,2,1); hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,1)),nanstd(tempdata(:,:,1))./sqrt(nansum(tempdata(:,:,1))),'ko-');
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 50 300]);
title('Theta preference ctrl');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('mean Resp Amp','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]); 


figure(hinc);
subplot(1,2,1); hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,2)),nanstd(tempdata(:,:,2))./sqrt(nansum(tempdata(:,:,2))),'ko-');
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 50 300]);
title('Theta preference ctrl');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('mean Resp Amp','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]); 

NormmeanResp_PTcentered_nl = tempdata;

% plotting mResp mani
count = 1;
tempdata= nan(totaldends,length(thetabins),2);
for sess = 1: size(data.NormSlopes_mani,2)
    dends = size(data.Slopes_mani{sess},1);
    for d = 1:dends
         y = data.meanResp_mani{sess}(d,:,1);
         [maxval,LP] = max(y); 
        touch_th = data.TouchTh_mani{sess}(d,:);
        Pref_touch_th = touch_th(LP);
        temp = touch_th-Pref_touch_th;
        x = 5.*round(temp/5); % rounding to nearest 5
%         y = y./nanmin(data.meanResp_ctrl{sess}(d,:,1)); % to normalize9
        if effect(count)==1
            figure(hsil);ind = 1;
        else
            figure(hinc);ind = 2;
        end           
        subplot(1,2,2);plot(x,y,'o-','color',[.85 .5 .5],'MarkerEdgeColor',[.85 .5 .5],'MarkerFaceColor',[.85 .5 .5],'linewidth',.05); hold on;
        for t = 1:length(x)
            tempdata (count,find(thetabins==x(t)),ind) = y(t);
        end
        count = count+1;
    end
end
figure(hsil);
subplot(1,2,2);hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,1)),nanstd(tempdata(:,:,1))./sqrt(nansum(tempdata(:,:,1))),'ro-')
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 .5 300]);
title('Theta preference mani');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('mean Resp Amp','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]);


figure(hinc);
subplot(1,2,2);hold on;h= errorbar(thetabins,nanmean(tempdata(:,:,2)),nanstd(tempdata(:,:,2))./sqrt(nansum(tempdata(:,:,2))),'ro-')
set(h,'linewidth',2,'markersize',6);
set(gca,'yscale','lin');
axis([-20 20 .5 3]);
title('Theta preference mani');
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('mean Resp Amp','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]);

NormmeanResp_PTcentered_l = tempdata;


nl=nanmax(NormSlopesnCTRL_PTcentered_nl(sil,:,1)'); 
l=nanmax(NormSlopesnCTRL_PTcentered_l(sil,:,1)');

Sil_sameLP = length(find(nl>l));
Sil_diffLP = length(find(nl<l));

[nl,lpnl]=nanmax(NormSlopesnCTRL_PTcentered_nl(inc,:,2)'); 
[l,lpl]=nanmax(NormSlopesnCTRL_PTcentered_l(inc,:,2)');

Inc_sameLP = length(find(lpnl==lpl));
Inc_diffLP = length(find(lpnl~=lpl));


%% Diff in mean Resp between most and least prefered locations 

bins = [0:20:240];
%% Sil cells
% use diffmR_nl(:,1) for Max-Min and LPId_nl(:,2) for Max-mean
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);
hnl=hist(diffmR_nl(sil,1),bins);plot(bins,hnl,'k');hold on ;
if lightcond
hl=hist(diffmR_l(sil,1),bins); plot(bins,hl,'r');set(gca,'yscale','lin');
end
xlabel('Diff in meanResp Max-Min ','Fontsize',16);title('Hist of diff in meanResp between most and least prefered location','Fontsize',16);
set(gca,'Fontsize',16);

subplot(1,2,2);
plot(bins,cumsum(hnl),'k');hold on ;
if lightcond
plot(bins,cumsum(hl),'r');set(gca,'yscale','lin');
end
xlabel('Diff in meanResp Max-Min ','Fontsize',16);title('Cum Hist of diff in meanResp between most and least prefered location','Fontsize',16);
set(gca,'Fontsize',16);
text(100,50,['Sil ' num2str(length(sil)) ' cells']);

if lightcond
%% Inc scells
% use diffmR_nl(:,1) for Max-Min and LPId_nl(:,2) for Max-mean
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);
hnl=hist(diffmR_nl(inc,1),bins);plot(bins,hnl,'k');hold on ;
hl=hist(diffmR_l(inc,1),bins); plot(bins,hl,'r');set(gca,'yscale','lin');
xlabel('Diff in meanResp Max-Min ','Fontsize',16);title('Hist of diff in meanResp between most and least prefered location','Fontsize',16);
set(gca,'Fontsize',16);

subplot(1,2,2);
plot(bins,cumsum(hnl),'k');hold on ;
plot(bins,cumsum(hl),'r');set(gca,'yscale','lin');
xlabel('Diff in meanResp Max-Min ','Fontsize',16);title('Cum Hist of diff in meanResp between most and least prefered location','Fontsize',16);
set(gca,'Fontsize',16);
text(100,20,['Inc ' num2str(length(inc)) ' cells']);
end

if lightcond
%% difference betwee NL and L
% Norm Slope at prefered location
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
tempdata = [LPInCTRL_nl(:,1),LPInCTRL_l(:,1)];
subplot(1,3,1);plot(tempdata','color',[.5 .5 .5]); axis([0.5 2.5 0 8]);hold on;
set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'NL';'L'});
[h,p]=kstest2(tempdata(:,1),tempdata(:,2));
m=mean(tempdata);
s=std(tempdata)./sqrt(size(tempdata,1));
h=errorbar(m,s,'ko-');
set(h,'linewidth',1.5);
title('Norm Slope at prefered location','Fontsize',16);
set(gca,'Fontsize',16);
text(1,7,['p=' num2str(p)]);


%mean Resp at ctrl Pref Loc
tempdata = [mRPrefLoc_nl(:,1),mRPrefLoc_l(:,1)];
subplot(1,3,2);plot(tempdata','color',[.5 .5 .5]); axis([0.5 2.5 0 350]);hold on;
set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'NL';'L'});
[h,p]=kstest2(tempdata(:,1),tempdata(:,2));
m=mean(tempdata);
s=std(tempdata)./sqrt(size(tempdata,1));
h=errorbar(m,s,'ko-');
set(h,'linewidth',1.5);
title('mean Resp Amp at prefered location','Fontsize',16);
text(1,225,['p=' num2str(p)]);


%Diff in mean REsp between most and least prefered locations 
% use diffmR_nl(:,1) for max - min LPId_nl(:,2) for Max-mean
tempdata = [diffmR_nl(:,1),diffmR_l(:,1)];
subplot(1,3,3);plot(tempdata','color',[.5 .5 .5]); axis([0.5 2.5 0 200]);hold on;
set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'NL';'L'});
[h,p]=kstest2(tempdata(:,1),tempdata(:,2));
m=mean(tempdata);
s=std(tempdata)./sqrt(size(tempdata,1));
h=errorbar(m,s,'ko-');
set(h,'linewidth',1.5);
title('Diff in mean Resp Most-least prefered location','Fontsize',16);
text(1,180,['p=' num2str(p)]);
end 

% Plot tuning from slopes on normalized dTouchTheta
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
numcells = size(LPI_nl,1);
subplot(1,2,1);
thetabins=[0:.05:1];
thetabins=round(thetabins.*100)./100;
tempdatay =nan(numcells,length(thetabins)); 
tempdatax =nan(numcells,length(thetabins)); 
count =0;
for sess = 1: size(data.meanResp_ctrl,2)
t =data.TouchTh_ctrl{sess}
mi=min(data.TouchTh_ctrl{sess}')'
numdends=size(t,1);
temp = t-repmat(mi,1,size(t,2));
ma=max(max(temp));
temp2= temp ./ ma(1);
x = temp2;
x=.05.*round(x./.05); % rounding to nearest 0.05;
y = data.NormSlopesnCTRL_ctrl{sess};
if lightcond
NS= data.LPInCTRL_ctrl{sess}-data.LPInCTRL_mani{sess};
sil = find(NS>0);
else
    sil =[1:size(y,1)];
end
tempx = round(x(1,:).*100)./100;
ind = (count +sil);
        for t = 1:size(x,2)           
            tempdatay (ind,find(thetabins==tempx(t))) = y(sil,t);
            tempdatax (ind,find(thetabins==tempx(t))) = 1;
        end

plot(x(sil,:)',y(sil,:)','o-','color',[.5 .5 .5]);hold on;
count = count+numdends;
end
my = nanmean(tempdatay);
sy = nanstd(tempdatay);
numy = nansum(tempdatax);
h=errorbar(thetabins,my,sy./sqrt(numy),'ko');set(h,'linewidth',2);
 axis([0 1 0 5]);
subplot(1,2,2);
thetabins=[0:.05:1];
thetabins=round(thetabins.*100)./100;
tempdatay =nan(numcells,length(thetabins)); 
tempdatax =nan(numcells,length(thetabins)); 
count =0;
for sess = 1: size(data.meanResp_ctrl,2)
t =data.TouchTh_ctrl{sess}
mi=min(data.TouchTh_ctrl{sess}')'
numdends=size(t,1);
temp = t-repmat(mi,1,size(t,2));
ma=max(max(temp));
temp2= temp ./ ma(1);
x = temp2;
x=.05.*round(x./.05); % rounding to nearest 0.05;
y = data.NormSlopesnCTRL_mani{sess};
NS= data.LPInCTRL_ctrl{sess}-data.LPInCTRL_mani{sess};
% NS= max(data.NormSlopesnCTRL_ctrl{sess},[],2)-max(data.NormSlopesnCTRL_mani{sess},[],2);
sil = find(NS>0);
tempx = round(x(1,:).*100)./100;
ind = (count +sil);
        for t = 1:size(x,2)           
            tempdatay (ind,find(thetabins==tempx(t))) = y(sil,t);
            tempdatax (ind,find(thetabins==tempx(t))) = 1;
        end

plot(x(sil,:)',y(sil,:)','o-','color',[.85 .5 .5]);hold on;
count = count+numdends;
end
my = nanmean(tempdatay);
sy = nanstd(tempdatay);
numy = nansum(tempdatax);
h=errorbar(thetabins,my,sy./sqrt(numy),'ko');set(h,'linewidth',2);
axis([0 1 0 5]);
xlabel('Normalized whisker angle for location ','Fontsize',16);title('Normalized tuning for location');
text(0.7,4,['Sil ' num2str(length(sil)) ' cells']);


% 
% 
% 
% 
% 
% 
% 
% 
% figure;hnl=hist(LPId_nl(:,src),bins);plot(bins,hnl,'k');hold on ;
% hl=hist(LPId_l(:,src),bins{src}); plot(bins{src},hl,'r');set(gca,'yscale','lin');
% xlabel('Loc Pref from max-min','Fontsize',16);title('diff dist from max - min','Fontsize',16);
% set(gca,'Fontsize',16);
% 
% figure;plot(bins{src},cumsum(hnl),'k');hold on ;
% plot(bins{src},cumsum(hl),'r');set(gca,'yscale','lin');
% xlabel('Loc Pref from max-min','Fontsize',16);title('cumulative diff dist from max - min','Fontsize',16);
% set(gca,'Fontsize',16);
% 
% 
% tempdata = [LPId_nl(:,src),LPId_l(:,src)];
% figure;plot(tempdata','color',[.5 .5 .5]); axis([0.5 2.5 0 150]);
% set(gca,'XTick',[1 2]);set(gca,'XTicklabel',{'NL';'L'});
% [h,p]=kstest2(tempdata(:,1),tempdata(:,2));
% m=mean(tempdata);
% s=std(tempdata)./sqrt(size(tempdata,1));
% h=errorbar(m,s,'ko-');
% set(h,'linewidth',1.5);
% 
% 
% figure;hnl=hist(PTh_nl(:,src),[-30:5:30]);plot([-30:5:30],hnl,'k');hold on ; 
% hl=hist(PTh_l(:,src),[-30:5:30]); plot([-30:5:30],hl,'r')
% xlabel('Prefered Touch theta (deg)','Fontsize',10);title('Pref Touch Theta Dist');
% set(gca,'Fontsize',16,'Xtick',[-30:10:30]);
% 
% figure;hnl=hist(LPI_nl(:,src),[0:.1:5]);plot([0:.1:5],hnl,'k');hold on ;
% hl=hist(LPI_l(:,src),[0:.1:5]); plot([0:.1:5],hl,'r')
% xlabel('Loc Pref Index','Fontsize',10);title('Loc Pref Ind Dist');
% set(gca,'Fontsize',16);
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 























% 
% 
% 
% 
% totaldends = size(LPI_nl,1);
% figure; hold on;
% count = 1;
% thetabins = [-50:5:50];
% tempdata= nan(totaldends,length(thetabins));
% for sess = 1: size(data.Slopes_ctrl,2)
%     dends = size(data.Slopes_ctrl{sess},1);
%     for d = 1:dends
%         touch_th = data.TouchTh_ctrl{sess}(d,:);
%         Pref_touch_th = data.PTh_ctrl{sess}(d);
%         temp = touch_th-Pref_touch_th;
%         x = 5.*round(temp/5); % rounding to nearest 5
%         y = data.NormSlopesnCTRL_ctrl{sess}(d,:,1);
%         
%         plot(x,y,'o-','color',[.5 .5 .5],'linewidth',.2); hold on;
%         for t = 1:length(x)
%             tempdata (count,find(thetabins==x(t))) = y(t);
%         end
%         count = count+1;
%     end
% end
% hold on;h= errorbar(thetabins,nanmean(tempdata),nanstd(tempdata)./sqrt(nansum(tempdata)),'ko-')
% set(h,'linewidth',2,'markersize',6);
% set(gca,'yscale','lin');
% axis([-50 50 0 8]);
% title('Theta preference ctrl');
% xlabel('dTheta (deg from max)','Fontsize',10);
% ylabel('Slope dFF vs |dK|','Fontsize',10);
% set(gca,'Fontsize',16,'Xtick',[-50:10:50]); 
% 
% figure; hold on;
% count = 1;totaldends = length(LPI_l);
% thetabins = [-50:5:50];
% tempdata= nan(totaldends,length(thetabins));
% for sess = 1: size(data.NormSlopes_mani,2)
%     dends = size(data.Slopes_mani{sess},1);
%     for d = 1:dends
%         touch_th = data.TouchTh_mani{sess}(d,:);
%         Pref_touch_th = data.PTh_mani{sess}(d,1);
%         temp = touch_th-Pref_touch_th;
%         x = 5.*round(temp/5); % rounding to nearest 5
%         y = data.NormSlopesnCTRL_mani{sess}(d,:,1);
%         
%         plot(x,y,'o-','color',[.85 .5 .5],'linewidth',.2); hold on;
%         for t = 1:length(x)
%             tempdata (count,find(thetabins==x(t))) = y(t);
%         end
%         count = count+1;
%     end
% end
% hold on;h= errorbar(thetabins,nanmean(tempdata),nanstd(tempdata)./sqrt(nansum(tempdata)),'ro-')
% set(h,'linewidth',2,'markersize',6);
% set(gca,'yscale','lin');
% axis([-50 50 0 8]);
% title('Theta preference mani');
% xlabel('dTheta (deg from max)','Fontsize',10);
% ylabel('Slope dFF vs |dK|','Fontsize',10);
% set(gca,'Fontsize',16,'Xtick',[-50:10:50]);
% %%
% 
% 
% 
% 
