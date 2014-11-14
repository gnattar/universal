
function plot_thetadep_L_NL_mean(pooled_contactCaTrials_thetadep,dends)
    sc = get(0,'ScreenSize');
    h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
    count =1;
for d=1:length(dends)
    n = dends(d);
    numloc = size(pooled_contactCaTrials_thetadep{n}.avg_loc,2);

    for i = 1:numloc 
        subplot(length(dends),numloc+4,count); plot([1:length(pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,1))]* pooled_contactCaTrials_thetadep{n}.FrameTime,pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,1),'k','linewidth',1.5); hold on; 
        plot([1:length(pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,1))]* pooled_contactCaTrials_thetadep{n}.FrameTime,pooled_contactCaTrials_thetadep{n}.avg_loc(:,i,2),'r','linewidth',1.5);axis( [0 5 -50 150]);
        title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_thetadep{n}.num_trials(1,i)) ' NL ' num2str(pooled_contactCaTrials_thetadep{n}.num_trials(2,i)) ' L ' ]);
        count = count+1;
    end 
     
     pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:)==0) = nan;
     pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:)==0) = nan;
     
%      temp_sigmagNL = (pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:) - min(pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:),[],2))./ min(pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:),[],2);
%      temp_sigmagL = (pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:) - min(pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:),[],2))./ min(pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:),[],2);
    
     temp_sigmagNL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:,1) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(1,:);
     temp_sigmagL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:,1) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(2,:);
     
     std_sigmagNL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:,2) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(1,:);
     std_sigmagL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:,2) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(2,:);
  
     subplot(length(dends),numloc+4,count:count+1);
    h= errorbar([1:numloc],temp_sigmagNL,std_sigmagNL,'k-o'); set(h,'linewidth',1.5);hold on; 
    h= errorbar([1:numloc],temp_sigmagL,std_sigmagL,'r-o');set(h,'linewidth',1.5);
     title( ' mean SigMag / mean TotalKappa'); 
     
%      text(0.1,200,['E' num2str(round(nansum(temp_sigmagL)/nansum(temp_sigmagNL)*100)/100)]); 
    t= text(0.1,-20,[ num2str((max(temp_sigmagNL)-min(temp_sigmagNL))/(min(temp_sigmagNL)))]); set(t,'Color' ,[0 0 0]);
    t =text(4.1,-20,[ num2str((max(temp_sigmagL)-min(temp_sigmagL))/(min(temp_sigmagL)))]);  set(t,'Color' ,[1 0 0]);
    axis([0 numloc+1 -50 400]);
     count = count+2;
    
     pooled_contactCaTrials_thetadep{n}.std_totmodKappa(isnan(pooled_contactCaTrials_thetadep{n}.std_totmodKappa))= 0;
     subplot(length(dends),numloc+4,count);
     h=errorbar([1:numloc],pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(1,:),pooled_contactCaTrials_thetadep{n}.std_totmodKappa(1,:));
      set(h,'color','k','linewidth',1.5);hold on;
     h=errorbar([1:numloc],pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(2,:),pooled_contactCaTrials_thetadep{n}.std_totmodKappa(2,:)); title( 'Total Kappa'); 
    set(h,'color','r','linewidth',1.5);
     axis([0 numloc+1 -1 25]);
     count = count+1;
     
    subplot(length(dends),numloc+4,count);
    trials_L = pooled_contactCaTrials_thetadep{n}.lightstim ==1;
    trials_NL = pooled_contactCaTrials_thetadep{n}.lightstim == 0;
    temp_rawdata_L = pooled_contactCaTrials_thetadep{n}.rawdata(trials_L,:);
    temp_rawdata_NL = pooled_contactCaTrials_thetadep{n}.rawdata(trials_NL,:);    
    mean_rawdata_NL = nanmean(temp_rawdata_NL);
    mean_rawdata_L = nanmean(temp_rawdata_L);
   
    nancount= sum(isnan(temp_rawdata_NL));
    delpnts = find(nancount>size(temp_rawdata_NL,1)/3);
    mean_rawdata_NL(delpnts) = nan;
    
    nancount= sum(isnan(temp_rawdata_L));
    delpnts = find(nancount>size(temp_rawdata_L,1)/3);
    mean_rawdata_L(delpnts) = nan;
    
    plot([1:size(temp_rawdata_NL,2)]* pooled_contactCaTrials_thetadep{n}.FrameTime,mean_rawdata_NL,'k','linewidth',1.5);hold on;
    plot([1:size(temp_rawdata_L,2)]* pooled_contactCaTrials_thetadep{n}.FrameTime,mean_rawdata_L,'r','linewidth',1.5);
    title([ 'D ' num2str(n) ' Net NL-L ' num2str(nansum(mean_rawdata_NL)-nansum(mean_rawdata_L)) ]);
    axis( [0 5 -50 150]);
    count = count + 1;
     
     pooled_contactCaTrials_thetadep{dends(d)}.thetadepNL = temp_sigmagNL ;
     pooled_contactCaTrials_thetadep{dends(d)}.thetadepL = temp_sigmagL ;
     pooled_contactCaTrials_thetadep{dends(d)}.effect_thetadep = temp_sigmagNL ;
end

       set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 18 24]);
        set(gcf, 'PaperSize', [24,10]);
        set(gcf,'PaperPositionMode','manual');
%         print( gcf ,'-depsc2','-painters','-loose',[pwd,filesep,fnam]);
saveas(gcf,[' Theta Dep D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
 
