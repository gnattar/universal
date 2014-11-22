
function plot_thetadep_L_NL_reg_prot_ret(pooled_contactCaTrials_thetadep,dends)
    sc = get(0,'ScreenSize');
    h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1, sc(4)*1], 'color','w');
    count =1;
for d=1:length(dends)
    n = dends(d);
    xcol =4;
    polelocs = unique(pooled_contactCaTrials_thetadep{n}.poleloc);
    numloc =length(polelocs);    
    a = 1;
    z = numloc;
    for i = 1:numloc 
        NL_ind = find(( pooled_contactCaTrials_thetadep{n}.poleloc == polelocs(i)) & (pooled_contactCaTrials_thetadep{n}.lightstim ==0) );
        L_ind =  find(( pooled_contactCaTrials_thetadep{n}.poleloc == polelocs(i)) & (pooled_contactCaTrials_thetadep{n}.lightstim ==1) );
        subplot(length(dends),numloc+xcol,count); 
        
       
        retract = NL_ind(find(pooled_contactCaTrials_thetadep{n}.totalKappa(NL_ind) <0));
        protract = NL_ind( find(pooled_contactCaTrials_thetadep{n}.totalKappa(NL_ind) >0));
        
        plot(pooled_contactCaTrials_thetadep{n}.totalKappa(retract),pooled_contactCaTrials_thetadep{n}.sigmag(retract),'o','color',[.5 .5 .5],'Markersize',10, 'Markerfacecolor',[.5 .5 .5]); hold on; 
        plot(pooled_contactCaTrials_thetadep{n}.totalKappa(protract),pooled_contactCaTrials_thetadep{n}.sigmag(protract),'ko','Markersize',10, 'Markerfacecolor','k'); hold on; 

        
        
        x=pooled_contactCaTrials_thetadep{n}.totalKappa(protract);
        y =pooled_contactCaTrials_thetadep{n}.sigmag(protract);
        sigmag_kappa_NL(i,1,1) = nanmean(y./x);
        sigmag_kappa_NL(i,2,1) = nanstd(y./x);
        sigmag_kappa_NL(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
%         sigmag_kappa_NL(i,1,1) = nanmean(y)./nanmean(x);
%         sigmag_kappa_NL(i,2,1) = nanstd(y)./nanmean(x);
%         sigmag_kappa_NL(i,3,1) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_NL(i,:,1) = polyfit(x,y,1);
        sigmag_kappa_NL_trials{n,i,1} = y./x;
        
        x=pooled_contactCaTrials_thetadep{n}.totalKappa(retract);
        y =pooled_contactCaTrials_thetadep{n}.sigmag(retract);
        sigmag_kappa_NL(i,1,2) = nanmean(y./x);
        sigmag_kappa_NL(i,2,2) = nanstd(y./x);
        sigmag_kappa_NL(i,3,2) = (nanstd(y./x))/sqrt(length(x)+1);
        p_NL(i,:,2) = polyfit(x,y,1);
        sigmag_kappa_NL_trials{n,i,2} = y./x;      

        retract = [];
        protract = [];
        
        retract = L_ind(find(pooled_contactCaTrials_thetadep{n}.totalKappa(L_ind) <0));
        protract = L_ind( find(pooled_contactCaTrials_thetadep{n}.totalKappa(L_ind) >0));
        
        plot(pooled_contactCaTrials_thetadep{n}.totalKappa(retract),pooled_contactCaTrials_thetadep{n}.sigmag(retract),'o','color',[1 .65 .65],'Markersize',10,'Markerfacecolor',[1 .65 .65]);
        hold on; 
        %axis( [0 5 -50 150]);
        plot(pooled_contactCaTrials_thetadep{n}.totalKappa(protract),pooled_contactCaTrials_thetadep{n}.sigmag(protract),'ro','Markersize',10,'Markerfacecolor','r');
        hold on; 
      
        x=pooled_contactCaTrials_thetadep{n}.totalKappa(protract);
        y =pooled_contactCaTrials_thetadep{n}.sigmag(protract);
        sigmag_kappa_L(i,1,1) = nanmean(y./x);
        sigmag_kappa_L(i,2,1) = nanstd(y./x);
        sigmag_kappa_L(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
        p_L(i,:,1) = polyfit(x,y,1);
        sigmag_kappa_L_trials{n,i,1} = y./x;
        
        x=pooled_contactCaTrials_thetadep{n}.totalKappa(retract);
        y =pooled_contactCaTrials_thetadep{n}.sigmag(retract);
        sigmag_kappa_L(i,1,2) = nanmean(y)./nanmean(x);
        sigmag_kappa_L(i,2,2) = nanstd(y)./nanmean(x);
        sigmag_kappa_L(i,3,2) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_L(i,:,2) = polyfit(x,y,1);
        sigmag_kappa_L_trials{n,i,2} = y./x;      

        
        mx = max([abs(pooled_contactCaTrials_thetadep{n}.totalKappa(NL_ind)); abs(pooled_contactCaTrials_thetadep{n}.totalKappa(L_ind))]);
        my = max([pooled_contactCaTrials_thetadep{n}.sigmag(NL_ind); pooled_contactCaTrials_thetadep{n}.sigmag(L_ind)]);
         if (my<0) 
             my = 50
         end
        title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_thetadep{n}.num_trials(1,i)) ' NL ' num2str(pooled_contactCaTrials_thetadep{n}.num_trials(2,i)) ' L ' ]);
%           axis([0  mx+5 -50 my+100]);
        axis([-50 50 0 12000]);
        count = count+1;
    
       %%plotting st line fits to points
        %protract
        plot([1:50],polyval(p_NL(i,:,1) ,[1:50]),'k-','linewidth',1.5);
        plot([1:50],polyval(p_L(i,:,1),[1:50]),'r--','linewidth',1.5);
        %retract
        plot([-50:-1],polyval(p_NL(i,:,2) ,[-50:-1]),'color',[0.5 .5 .5],'linewidth',1.5);
        plot([-50:-1],polyval(p_L(i,:,2),[-50:-1]),'color',[01 .65 .65],'linewidth',1.5);
        
% %         x=pooled_contactCaTrials_thetadep{n}.totalKappa(NL_ind);
% %         y =pooled_contactCaTrials_thetadep{n}.sigmag(NL_ind);
% %         yy = y(x<0);%% retraction touches
% %         xx = x(x < 0);        
% %         p_NL(i,:,1) = polyfit(xx,yy,1);
% %         yy = y(x>0);%% protraction touches
% %         xx = x(x > 0);        
% %         p_NL(i,:,2) = polyfit(xx,yy,1);
% %         
% %         x=pooled_contactCaTrials_thetadep{n}.totalKappa(L_ind);
% %         y =pooled_contactCaTrials_thetadep{n}.sigmag(L_ind);
% %         yy = y(x<0);%% retraction touches
% %         xx = x(x < 0);        
% %         p_L(i,:,1) = polyfit(xx,yy,1);
% %         yy = y(x>0); %% protraction touches
% %         xx = x(x > 0);        
% %         p_L(i,:,2) = polyfit(xx,yy,1);
% %             
% %         plot([-20:-1],polyval(p_NL(i,:,1) ,[-20:-1]),'k-'); hold on ; plot([1:20],polyval(p_NL(i,:,2) ,[1:20]),'k-');
% %        plot([-20:-1],polyval(p_L(i,:,1),[-20:-1]),'r-'); hold on; plot([1:20],polyval(p_L(i,:,2),[1:20]),'r-'); 
    end 
    
    %%plotting slopes

     subplot(length(dends),numloc+xcol,count:count+1);
    h= plot([1:numloc],p_NL(:,1,1),'k-o'); set(h,'linewidth',1.5);hold on; 
    h= plot([1:numloc],p_L(:,1,1),'r-o');set(h,'linewidth',1.5);

    h= plot([1:numloc],p_NL(:,1,2),'o-','color',[.5 .5 .5]); set(h,'linewidth',1.5);hold on; 
    h= plot([1:numloc],p_L(:,1,2),'o-','color',[1 .65 .65]);set(h,'linewidth',1.5);    
    
    hline(0,'k:');
     title( ' slopes'); 
%       axis([0 6 min(min(min(p_NL([a:z],1,:)),min(p_L([a:z],1,:))))-50  max(max(max(p_NL([a:z],1,:)),max(p_L([a:z],1,:))))+50]);
    axis([0 numloc+1 -500 500])
     count = count+2;   
   
  %plotting total sig mag / total kappa
% % %      temp_sigmagNL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:,1) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(1,:);
% % %      temp_sigmagL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:,1) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(2,:);
% % %      
% % %      std_sigmagNL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(1,:,2) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(1,:);
% % %      std_sigmagL = pooled_contactCaTrials_thetadep{n}.avg_sigmag(2,:,2) ./ pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(2,:);


% plotting avg of sigmag / mod(kappa) for each trial
     temp_sigmagNL(1,:) = sigmag_kappa_NL(:,1,1); % mean prot
     temp_sigmagL(1,:) = sigmag_kappa_L(:,1,1);
     
     std_sigmagNL(1,:) = sigmag_kappa_NL(:,3,1); % sem prot
     std_sigmagL(1,:) = sigmag_kappa_L(:,3,1);
  
     subplot(length(dends),numloc+xcol,count:count+1);
    h= errorbar([1:numloc],temp_sigmagNL(1,:),std_sigmagNL(1,:),'k-o'); set(h,'linewidth',1.5);hold on; 
    h= errorbar([1:numloc],temp_sigmagL(1,:),std_sigmagL(1,:),'r-o');set(h,'linewidth',1.5); hold on
     title( ' avg (SigMag / TotalKappa)'); 
     
     % plotting avg of sigmag / mod(kappa) for each trial
     temp_sigmagNL(2,:) = sigmag_kappa_NL(:,1,2); % mean ret
     temp_sigmagL (2,:)= sigmag_kappa_L(:,1,2);
     
     std_sigmagNL(2,:) = sigmag_kappa_NL(:,3,2); % sem ret
     std_sigmagL (2,:)= sigmag_kappa_L(:,3,2);
     
      h= errorbar([1:numloc],temp_sigmagNL(2,:),std_sigmagNL(2,:),'o-','color',[.5 .5 .5]); set(h,'linewidth',1.5);hold on; 
    h= errorbar([1:numloc],temp_sigmagL(2,:),std_sigmagL(2,:),'o-','color',[1.0 .65 .65]);set(h,'linewidth',1.5); hold on
     
     
     
     
     
     
     
%      text(0.1,200,['E' num2str(round(nansum(temp_sigmagL)/nansum(temp_sigmagNL)*100)/100)]); 
%     t= text(0.1,-20,[ num2str((max(temp_sigmagNL)-min(temp_sigmagNL))/(min(temp_sigmagNL)))]); set(t,'Color' ,[0 0 0]);
%     t =text(4.1,-20,[ num2str((max(temp_sigmagL)-min(temp_sigmagL))/(min(temp_sigmagL)))]);  set(t,'Color' ,[1 0 0]);
%     axis([0 numloc+1 -50 max([max(max(temp_sigmagNL)) ,max(max(temp_sigmagL))])+100]);
     axis([0 numloc+1 -1000 1000])
 
      count = count+2;   
     
% % % % % % % % %      
% % % % % % % % %     sigmag_kappa_anova = anova2(
% % % % % % % %   
% % % % % % % %      subplot(length(dends),numloc+xcol,count:count+1);
% % % % % % % %     h= errorbar([1:numloc],temp_sigmagNL,std_sigmagNL,'k-o'); set(h,'linewidth',1.5);hold on; 
% % % % % % % %     h= errorbar([1:numloc],temp_sigmagL,std_sigmagL,'r-o');set(h,'linewidth',1.5);
% % % % % % % %      title( ' mean SigMag / mean TotalKappa'); 
% % % % % % % %      
% % % % % % % % %      text(0.1,200,['E' num2str(round(nansum(temp_sigmagL)/nansum(temp_sigmagNL)*100)/100)]); 
% % % % % % % %     t= text(0.1,-20,[ num2str((max(temp_sigmagNL)-min(temp_sigmagNL))/(min(temp_sigmagNL)))]); set(t,'Color' ,[0 0 0]);
% % % % % % % %     t =text(4.1,-20,[ num2str((max(temp_sigmagL)-min(temp_sigmagL))/(min(temp_sigmagL)))]);  set(t,'Color' ,[1 0 0]);
% % % % % % % %     axis([0 numloc+1 -50 max([temp_sigmagNL([a:z]) ,temp_sigmagL([a:z])])+100]);
% % % % % % % %      
% % % % % % % %       count = count+2;        
% % % % % % % %      
% % % % % % % % 
% % % % % % % % % % % % %      subplot(length(dends),numloc+xcol,count:count+1);
% % % % % % % % % % % % %     h= errorbar([1:numloc],sigmag_kappa_NL(:,1),sigmag_kappa_NL(:,3)); set(h,'color','k','marker','o','linewidth',1.5);hold on; 
% % % % % % % % % % % % %     h= errorbar([1:numloc],sigmag_kappa_L(:,1),sigmag_kappa_L(:,3));set(h,'color','r','marker','o','linewidth',1.5);
% % % % % % % % % % % % %     hline(0,'k:');
% % % % % % % % % % % % %      title( ' mean(sigmag/kappa)'); 
% % % % % % % % % % % % %      axis([0 6 min(min(sigmag_kappa_NL(:,1)),min(sigmag_kappa_L(:,1)))-0.10  max(max(sigmag_kappa_NL(:,1)),max(sigmag_kappa_L(:,1)))+.1]);
% % % % % % % % % % % % %      
% % % % % % % % % % % % %      
% % % % % % % % % % % % % %     t= text(0.1,-20,[ num2str((max(temp_sigmagNL)-min(temp_sigmagNL))/(min(temp_sigmagNL)))]); set(t,'Color' ,[0 0 0]);
% % % % % % % % % % % % % %     t =text(4.1,-20,[ num2str((max(temp_sigmagL)-min(temp_sigmagL))/(min(temp_sigmagL)))]);  set(t,'Color' ,[1 0 0]);
% % % % % % % % % % % % %    
% % % % % % % % % % % % %      count = count+2;        
% % % % % % % %      
% % % % % % % %      
% % % % % % % %      
% % % % % % % %      
% % % % % % % %      pooled_contactCaTrials_thetadep{n}.std_totmodKappa(isnan(pooled_contactCaTrials_thetadep{n}.std_totmodKappa))= 0;
% % % % % % % %      subplot(length(dends),numloc+xcol,count);
% % % % % % % %      h=errorbar([1:numloc],pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(1,:),pooled_contactCaTrials_thetadep{n}.std_totmodKappa(1,:)./sqrt(length(pooled_contactCaTrials_thetadep{n}.std_totmodKappa(1,:))+1));
% % % % % % % %      set(h,'color','k','linewidth',1.5);hold on;
% % % % % % % %      h=errorbar([1:numloc],pooled_contactCaTrials_thetadep{n}.avg_totmodKappa(2,:),pooled_contactCaTrials_thetadep{n}.std_totmodKappa(2,:)./sqrt(length(pooled_contactCaTrials_thetadep{n}.std_totmodKappa(2,:))+1)); title( 'Total Kappa'); 
% % % % % % % %     set(h,'color','r','linewidth',1.5);
% % % % % % % %      axis([0 numloc+1 -1 25]);
% % % % % % % %      count = count+1;
% % % % % % % %      
% % % % % % % %     subplot(length(dends),numloc+xcol,count);
% % % % % % % %     trials_L = pooled_contactCaTrials_thetadep{n}.lightstim ==1;
% % % % % % % %     trials_NL = pooled_contactCaTrials_thetadep{n}.lightstim == 0;
% % % % % % % %     temp_rawdata_L = pooled_contactCaTrials_thetadep{n}.rawdata(trials_L,:);
% % % % % % % %     temp_rawdata_NL = pooled_contactCaTrials_thetadep{n}.rawdata(trials_NL,:);    
% % % % % % % %     mean_rawdata_NL = nanmean(temp_rawdata_NL);
% % % % % % % %     mean_rawdata_L = nanmean(temp_rawdata_L);
% % % % % % % %    
% % % % % % % %     nancount= sum(isnan(temp_rawdata_NL));
% % % % % % % %     delpnts = find(nancount>size(temp_rawdata_NL,1)/3);
% % % % % % % %     mean_rawdata_NL(delpnts) = nan;
% % % % % % % %     
% % % % % % % %     nancount= sum(isnan(temp_rawdata_L));
% % % % % % % %     delpnts = find(nancount>size(temp_rawdata_L,1)/3);
% % % % % % % %     mean_rawdata_L(delpnts) = nan;
% % % % % % % %     
% % % % % % % %     plot([1:size(temp_rawdata_NL,2)]* pooled_contactCaTrials_thetadep{n}.FrameTime,mean_rawdata_NL,'k','linewidth',1.5);hold on;
% % % % % % % %     plot([1:size(temp_rawdata_L,2)]* pooled_contactCaTrials_thetadep{n}.FrameTime,mean_rawdata_L,'r','linewidth',1.5);
% % % % % % % % %     title([ 'D ' num2str(n) ' Net NL-L ' num2str(nansum(mean_rawdata_NL)-nansum(mean_rawdata_L)) ]);
% % % % % % % %     axis( [0 5 -50 150]);
% % % % % % % %     count = count + 1;
     
%      pooled_contactCaTrials_thetadep{dends(d)}.thetadepNL = temp_sigmagNL ;
%      pooled_contactCaTrials_thetadep{dends(d)}.thetadepL = temp_sigmagL ;
%      pooled_contactCaTrials_thetadep{dends(d)}.effect_thetadep = temp_sigmagNL ;
end

       set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
%         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Theta Dep reg temp D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
 
