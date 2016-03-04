%% plot_theta_at_touch
function [pooled_contactCaTrials_locdep]=  plot_theta_at_touch(pooled_contactCaTrials_locdep,d)
ls = pooled_contactCaTrials_locdep{d(1)}.lightstim;

    NL_ind = find(ls == 0);
    light =0;
if max(ls)>0
    L_ind = find(ls == 1);
    light = 1;
end


    theta_mid = unique(pooled_contactCaTrials_locdep{1}.theta_binned);

    touchTheta_NL =  pooled_contactCaTrials_locdep{1}.theta_binned(NL_ind);
%     [num edges mid id_NL] = histcn(touchPhase_NL,phase_bins);
    ind = [];id_NL = [];
    for i = 1: length(theta_mid)
        ind = find(touchTheta_NL==theta_mid(i));
        id_NL(ind) = i;
    end
    
    
    
    
if light
    touchTheta_L =  pooled_contactCaTrials_locdep{1}.theta_binned(L_ind);
%     [num edges mid id_L] = histcn(touchPhase_L,phase_bins);
        ind = [];id_L = [];
    for i = 1: length(theta_mid)
        ind = find(touchTheta_L==theta_mid(i));
        id_L(ind) = i;
    end
end
    sc = get(0,'ScreenSize');
    h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
    count = 1;
    numcols = length(unique(id_NL))+1;
for i = 1:length(d)

sigpeak_NL = pooled_contactCaTrials_locdep{d(i)}.sigpeak(NL_ind);
touchmag_NL = abs(pooled_contactCaTrials_locdep{d(i)}.re_totaldK(NL_ind));
% touchphase_NL = pooled_contactCaTrials_locdep{d(i)}.touchPhase(NL_ind);
if light
    sigpeak_L = pooled_contactCaTrials_locdep{d(i)}.sigpeak(L_ind);
    touchmag_L = abs(pooled_contactCaTrials_locdep{d(i)}.re_totaldK(L_ind));
%     touchphase_L = pooled_contactCaTrials_locdep{d(i)}.touchPhase(L_ind);
end

for th =1:length(unique(id_NL))
    inds_NL = find(id_NL==th);
    if light
    inds_L = find(id_L==th);
    end
    subplot(length(d),numcols,count);
    plot(touchmag_NL(inds_NL),sigpeak_NL(inds_NL),'ko','markerfacecolor',[.5 .5 .5]); 
    if light 
        hold on;
       plot(touchmag_L(inds_L),sigpeak_L(inds_L),'ro','markerfacecolor',[.85 0 0]); 
       hold off;
       title(['D' num2str(d(i)) ' th ' num2str(theta_mid(th)) ' T ' num2str(length(inds_NL)) ' ' num2str(length(inds_L))]);
    else
        title(['D' num2str(d(i)) ' th ' num2str(theta_mid(th)) ' T ' num2str(length(inds_NL))]);
    end
    
    set(gca,'xscale','log');%set(gca,'ticklength',[.05 .05]);
    axis ([.001 2.5 0 800]);
    count= count+1;
    if light
        contact_theta_binned([NL_ind(inds_NL);L_ind(inds_L)]) = theta_mid(th);
    else
        contact_theta_binned([NL_ind(inds_NL)]) = theta_mid(th);
    end
    mResp_NL(th) = mean(sigpeak_NL(inds_NL));
    sdResp_NL(th) = std(sigpeak_NL(inds_NL));
    numResp_NL(th) = length(sigpeak_NL(inds_NL));
    mdK_NL(th) = mean(touchmag_NL(inds_NL));
    sddK_NL(th) = std(touchmag_NL(inds_NL));
   
    if light
    mResp_L(th) = mean(sigpeak_L(inds_L));
    sdResp_L(th) = std(sigpeak_L(inds_L));
    numResp_L(th) = length(sigpeak_L(inds_L));
    mdK_L(th) = mean(touchmag_L(inds_L));
    sddK_L(th) = std(touchmag_L(inds_L));
    end
end

 pooled_contactCaTrials_locdep{d(i)}.theta.touchTheta_mid = theta_mid;
 pooled_contactCaTrials_locdep{d(i)}.theta.touchTheta_id_NL = id_NL;
 pooled_contactCaTrials_locdep{d(i)}.theta.touchTheta_binned = contact_theta_binned';

 pooled_contactCaTrials_locdep{d(i)}.theta.mResp_NL = mResp_NL;
 pooled_contactCaTrials_locdep{d(i)}.theta.sdResp_NL = sdResp_NL;
 pooled_contactCaTrials_locdep{d(i)}.theta.numResp_NL = numResp_NL;
 pooled_contactCaTrials_locdep{d(i)}.theta.mdK_NL = mdK_NL;
 pooled_contactCaTrials_locdep{d(i)}.theta.sddK_NL = sddK_NL;
 
 pooled_contactCaTrials_locdep{d(i)}.theta.normResp_NL = mResp_NL./mean(mResp_NL);
 pooled_contactCaTrials_locdep{d(i)}.theta.TPI_NL = max(mResp_NL./mean(mResp_NL));
 
 if light
  pooled_contactCaTrials_locdep{d(i)}.theta.touchTheta_id_NL = id_NL;
  pooled_contactCaTrials_locdep{d(i)}.theta.mResp_L = mResp_L;
 pooled_contactCaTrials_locdep{d(i)}.theta.sdResp_L = sdResp_L;
 pooled_contactCaTrials_locdep{d(i)}.theta.numResp_L = numResp_L;
 pooled_contactCaTrials_locdep{d(i)}.theta.mdK_L = mdK_L;
 pooled_contactCaTrials_locdep{d(i)}.theta.sddK_L = sddK_L;
 
 pooled_contactCaTrials_locdep{d(i)}.theta.normResp_L = mResp_L./mean(mResp_NL);
 pooled_contactCaTrials_locdep{d(i)}.theta.TPI_L = max(mResp_L./mean(mResp_NL));
 end
 
 subplot(length(d),numcols,count);
 plot( theta_mid,pooled_contactCaTrials_locdep{d(i)}.theta.normResp_NL ,'ko-','markerfacecolor','k','linewidth',2,'markersize',10);
 if light
   hold on; 
    plot( theta_mid,pooled_contactCaTrials_locdep{d(i)}.theta.normResp_L ,'ro-','markerfacecolor','r','linewidth',2,'markersize',10);
    hold off;
     tb_L = text(0.9,1.35,[ num2str( pooled_contactCaTrials_locdep{d(i)}.theta.TPI_L )]);set(tb_L,'color','r');
 end
     
tb_NL= text(0,1.6,['PPI ' num2str( pooled_contactCaTrials_locdep{d(i)}.theta.TPI_NL )]);set(tb_NL,'color','k');

 axis([-30 30 0.5 2])
 count = count+1;
 end
% print(h,'-dtiff','-painters','-loose',['D ' num2str(d)])

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',['D ' num2str(d)]);
saveas(gcf,['D ' num2str(d)],'jpg');
