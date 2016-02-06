function plot_normResp_phase_locnotfixed(data,light)
ph=[-2.5133,
   -1.2566,
         0,
    1.2566,
    2.5133];

sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
collected_ctrl = nan(200,11);
collected_mani = nan(200,11);
template = [-5:1:5];
numpts  = zeros(1,11);count =1;inccount = 0;
numpts_C  = zeros(1,11);numpts_M  = zeros(1,11);
for s = 1:size(data.meanResp_phase_ctrl,2)
    
    mR_c = data.meanResp_phase_ctrl{s};
    m_2_n = mean(mR_c,2);
    m_2_n = repmat(m_2_n,1,size(mR_c,2));
    norm_mR_c = mR_c./m_2_n;
    [v,i] = max(norm_mR_c');
    PrefPhid_ctrl = i';

    
    PrefPh_C = ph(PrefPhid_ctrl);
    
    
    xphid = zeros(size(norm_mR_c));
    numphid = size(norm_mR_c,2);
    for l = 1: size(xphid,2)
        xphid(:,l) = l;
    end
    prefphid_C = repmat(PrefPhid_ctrl,1,size(xphid,2));
    xphid_C = xphid - prefphid_C;

    
    if light
        mR_m = data.meanResp_phase_mani{s};
        norm_mR_m = mR_m./m_2_n;
        [v,i] = max(norm_mR_m');
        PrefPhid_mani= i';
        prefphid_M = repmat(PrefPhid_mani,1,size(xphid,2));
        PrefPh_M = ph(PrefPhid_mani);
        xphid_M = xphid - prefphid_M;
    end
    
    
    
    subplot(1,2,1);
    plot(xphid_C',norm_mR_c','color',[.5 .5 .5],'linewidth',.5);hold on;
    if light
    subplot(1,2,2);
    plot(xphid_M',norm_mR_m','color',[.85 .5 .5],'linewidth',.5);hold on;
    end
    
    for c= 1:size(xphid,1)
        for t = 1:length(xphid(c,:))
            collected_ctrl (count,find(template==xphid_C(c,t))) = norm_mR_c(c,t);
            numpts_C(count,find(template==xphid_C(c,t))) = 1;
            if light
            collected_mani (count,find(template==xphid_M(c,t))) = norm_mR_m(c,t);
            numpts_M(count,find(template==xphid_M(c,t))) = 1;
            end
            
        end  
    count = count+1;
    end
end
 
collected_ctrl(count:end,:) = [];
if light
collected_mani(count:end,:) = [];
end
 temp = collected_ctrl;
 temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts_C));
 m_C = nanmean(temp);
 s_C = nanstd(temp)./temp2;
if light
    temp = collected_mani;
 temp (find(temp==0)) = nan;
 temp2 = sqrt(sum(numpts_M));
 m_M = nanmean(temp);
 s_M = nanstd(temp);
 s_M= nanstd(temp)./temp2;
 
%  FracChange = (m_C-m_M)./m_C;
CP=collected_ctrl(:,6);
MP=collected_mani(:,6);
CNP=collected_ctrl(:,[1:5,7:11]);
MNP= collected_mani(:,[1:5,7:11]);
Pref_reduction = (CP-MP)./CP;
NonPref_reduction = (nanmean(CNP,2) - nanmean(MNP,2))./nanmean(CNP,2);
PhaseTuningReduction = mean(Pref_reduction)
end

     subplot(1,2,1);title('Phase tuning ctrl')
     e1=errorbar(template,m_C,s_C,'ko-'); axis([-5 5 0 3])
     phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);


     if light
    subplot(1,2,2);title('Phase tuning mani')
     e2=errorbar(template,m_M,s_M,'ro-'); axis([-5 5 0 3]);
     tb = text(1,2.5,['FracChange Pref ' num2str(round(mean(Pref_reduction)*1000)/10) '+/- ' num2str(round(std(Pref_reduction)./sqrt(200)*1000)/10)]);
     set(tb,'color','r');
     tb = text(1,2.1,['FracChange NPref ' num2str(round(mean(NonPref_reduction)*1000)/10) '+/- ' num2str(round(std(NonPref_reduction)./sqrt(200)*1000)/10)]);
     set(tb,'color','r');
     end
 text(2,2,['n=' num2str(count-1) ' cells'])
phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
fnam = 'normRespPhase Tuning';
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);

if light
 t = m_C-m_M;
 figure;
 plot([-5:5],t,'o-','markersize',10,'color',[.85 0 .2]);title('Diff in phase tuning')
 phaxis = [-5:5].*72;
set(gca,'Xtick',[-5 : 5]);
set(gca,'Xticklabel',phaxis);


set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');

fnam = 'normRespPhase Tuning Diff';
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);












end

%% hist of PPIs
temp=arrayfun(@(x) x.PPI_ctrl, data,'uni',0)';
temp=temp{1}';
PPI_NL_list = cell2mat(temp);
if light
    temp=arrayfun(@(x) x.PPI_mani, data,'uni',0)';
    temp=temp{1}';
    PPI_L_list = cell2mat(temp);
end

bins = [0:.1:4];
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4), sc(3)/2, sc(4)/3], 'color','w');
subplot(1,2,1);hnl=hist(PPI_NL_list(:,1),bins);plot(bins,hnl,'k');hold on ;
if light
    hl=hist(PPI_L_list(:,1),bins); plot(bins,hl,'r');
end
set(gca,'yscale','lin');
xlabel('norm Resp Amp at Pref Phase','Fontsize',16);title('Hist norm Resp Amp at Pref Phase','Fontsize',16);
set(gca,'Fontsize',16);


set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');


fnam = 'normRespPhase Hist';
saveas(gcf,[pwd,filesep,fnam],'fig');
print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);


C=nanmean(collected_ctrl)
M=nanmean(collected_mani)
FracChange = (C-M)./C;
figure;plot(template,FracChange)
figure;plot(C-M)
CP=collected_ctrl(:,6);
MP=collected_mani(:,6);
temp = (CP-MP)./CP;