%% plot_phase_at_touch
function [pooled_contactCaTrials_locdep]=  plot_theta_at_touch(pooled_contactCaTrials_locdep,d)
ls = pooled_contactCaTrials_locdep{d(1)}.lightstim;

    NL_ind = find(ls == 0);
    light =0;
if max(ls)>0
    L_ind = find(ls == 1);
    light = 1;
end


    phase_bins = linspace(-pi,pi,6);
%     phase_bins = [-pi:pi/2:pi];

    touchPhase_NL =  pooled_contactCaTrials_locdep{1}.touchPhase(NL_ind);
    [num edges mid id_NL] = histcn(touchPhase_NL,phase_bins);
if light
    touchPhase_L =  pooled_contactCaTrials_locdep{1}.touchPhase(L_ind);
    [num edges mid id_L] = histcn(touchPhase_L,phase_bins);
end
    sc = get(0,'ScreenSize');
%     figure('position', [1000, sc(4)/10-100, sc(3)/2.5, sc(4)], 'color','w');
    h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
    count = 1;
    numcols = length(unique(id_NL))+1;
for i = 1:length(d)

sigpeak_NL = pooled_contactCaTrials_locdep{d(i)}.sigpeak(NL_ind);
touchmag_NL = abs(pooled_contactCaTrials_locdep{d(i)}.re_totaldK(NL_ind));
touchphase_NL = pooled_contactCaTrials_locdep{d(i)}.touchPhase(NL_ind);
if light
    sigpeak_L = pooled_contactCaTrials_locdep{d(i)}.sigpeak(L_ind);
    touchmag_L = abs(pooled_contactCaTrials_locdep{d(i)}.re_totaldK(L_ind));
    touchphase_L = pooled_contactCaTrials_locdep{d(i)}.touchPhase(L_ind);
end

for ph =1:length(unique(id_NL))
    inds_NL = find(id_NL==ph);
    if light
    inds_L = find(id_L==ph);
    end
    subplot(length(d),numcols,count);
    plot(touchmag_NL(inds_NL),sigpeak_NL(inds_NL),'ko','markerfacecolor',[.5 .5 .5]); 
    if light 
        hold on;
       plot(touchmag_L(inds_L),sigpeak_L(inds_L),'ro','markerfacecolor',[.85 0 0]); 
       hold off;
       title(['D' num2str(d(i)) ' ph ' num2str(mid{1}(ph)) ' T ' num2str(length(NL_ind)) ' ' num2str(length(L_ind))]);
    else
        title(['D' num2str(d(i)) ' ph ' num2str(mid{1}(ph)) ' T ' num2str(length(NL_ind))]);
    end
    
    set(gca,'xscale','log');%set(gca,'ticklength',[.05 .05]);
    axis ([.001 2.5 0 800]);
    count= count+1;
    if light
        contact_phase_binned([NL_ind(inds_NL);L_ind(inds_L)]) = mid{1}(ph);
    else
        contact_phase_binned([NL_ind(inds_NL)]) = mid{1}(ph);
    end
    mResp_NL(ph) = mean(sigpeak_NL(inds_NL));
    sdResp_NL(ph) = std(sigpeak_NL(inds_NL));
    numResp_NL(ph) = length(sigpeak_NL(inds_NL));
    mdK_NL(ph) = mean(touchmag_NL(inds_NL));
    sddK_NL(ph) = std(touchmag_NL(inds_NL));
   
    if light
    mResp_L(ph) = mean(sigpeak_L(inds_L));
    sdResp_L(ph) = std(sigpeak_L(inds_L));
    numResp_L(ph) = length(sigpeak_L(inds_L));
    mdK_L(ph) = mean(touchmag_L(inds_L));
    sddK_L(ph) = std(touchmag_L(inds_L));
    end
end

 pooled_contactCaTrials_locdep{d(i)}.phase.touchPhase_mid = mid{1};
 pooled_contactCaTrials_locdep{d(i)}.phase.touchPhase_id_NL = id_NL;
 pooled_contactCaTrials_locdep{d(i)}.phase.touchPhase_binned = contact_phase_binned';

 pooled_contactCaTrials_locdep{d(i)}.phase.mResp_NL = mResp_NL;
 pooled_contactCaTrials_locdep{d(i)}.phase.sdResp_NL = sdResp_NL;
 pooled_contactCaTrials_locdep{d(i)}.phase.numResp_NL = numResp_NL;
 pooled_contactCaTrials_locdep{d(i)}.phase.mdK_NL = mdK_NL;
 pooled_contactCaTrials_locdep{d(i)}.phase.sddK_NL = sddK_NL;
 
 pooled_contactCaTrials_locdep{d(i)}.phase.normResp_NL = mResp_NL./mean(mResp_NL);
 pooled_contactCaTrials_locdep{d(i)}.phase.PPI_NL = max(mResp_NL./mean(mResp_NL));
 
 if light
  pooled_contactCaTrials_locdep{d(i)}.phase.touchPhase_id_L = id_L;
  pooled_contactCaTrials_locdep{d(i)}.phase.mResp_L = mResp_L;
 pooled_contactCaTrials_locdep{d(i)}.phase.sdResp_L = sdResp_L;
 pooled_contactCaTrials_locdep{d(i)}.phase.numResp_L = numResp_L;
 pooled_contactCaTrials_locdep{d(i)}.phase.mdK_L = mdK_L;
 pooled_contactCaTrials_locdep{d(i)}.phase.sddK_L = sddK_L;
 
 pooled_contactCaTrials_locdep{d(i)}.phase.normResp_L = mResp_L./mean(mResp_NL);
 pooled_contactCaTrials_locdep{d(i)}.phase.PPI_L = max(mResp_L./mean(mResp_NL));
 end
 
 subplot(length(d),numcols,count);
 plot( mid{1},pooled_contactCaTrials_locdep{d(i)}.phase.normResp_NL ,'ko-','markerfacecolor','k','linewidth',2,'markersize',10);
 if light
   hold on; 
    plot( mid{1},pooled_contactCaTrials_locdep{d(i)}.phase.normResp_L ,'ro-','markerfacecolor','r','linewidth',2,'markersize',10);
    hold off;
     tb_L = text(0.9,1.35,[ num2str( pooled_contactCaTrials_locdep{d(i)}.phase.PPI_L )]);set(tb_L,'color','r');
 end
     
tb_NL= text(0,1.6,['PPI ' num2str( pooled_contactCaTrials_locdep{d(i)}.phase.PPI_NL )]);set(tb_NL,'color','k');

 axis([-4 4 0.5 2])
 count = count+1;
 end
% print(h,'-dtiff','-painters','-loose',['D ' num2str(d)])

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',['D ' num2str(d)]);
saveas(gcf,['D ' num2str(d)],'jpg');