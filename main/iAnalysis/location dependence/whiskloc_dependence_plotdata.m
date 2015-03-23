function whiskloc_dependence_plotdata(pooled_contactCaTrials_locdep,dends,par)
sc = get(0,'ScreenSize');
% h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
count =1;
for d=1:length(dends)
    n = dends(d);
    xcol =2;
    polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
    numloc =length(polelocs);
    a = 1;
    z = numloc;
    p_NL =zeros(numloc,2);p_L =zeros(numloc,2);
    
    for i = 1:numloc
        NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
        L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
        subplot(length(dends),numloc+xcol,count);
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind) <0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract)),'ko','Markersize',7); hold on;
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract)),'ko','Markersize',7, 'Markerfacecolor',[.5 .5 .5]); hold on;
       
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract)));
        y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract));
        sig_kappa_NL(i,1,1) = nanmean(y)./nanmean(x);
        sig_kappa_NL(i,2,1) = nanstd(y)./nanmean(x);
        sig_kappa_NL(i,3,1) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_NL(i,:,1) = polyfit(x,y,1);
        sig_kappa_NL_trials{n,i,1} = y./x;
        
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract)));
        y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract));
        sig_kappa_NL(i,1,2) = nanmean(y)./nanmean(x);
        sig_kappa_NL(i,2,2) = nanstd(y)./nanmean(x);
        sig_kappa_NL(i,3,2) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_NL(i,:,2) = polyfit(x,y,1);
        sig_kappa_NL_trials{n,i,2} = y./x;
        
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind)<0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(retract)),'ro','Markersize',7); hold on;%axis( [0 5 -50 150]);
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(protract)),'ro','Markersize',7); hold on;
        
                           
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(protract)));
        y =pooled_contactCaTrials_locdep{n}.sigmag(L_ind(protract));
        sig_kappa_L(i,1,1) = nanmean(y)./nanmean(x);
        sig_kappa_L(i,2,1) = nanstd(y)./nanmean(x);
        sig_kappa_L(i,3,1) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_L(i,:,1) = polyfit(x,y,1);        
        sig_kappa_L_trials{n,i,1} = y./x;
        
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(retract)));
        y =pooled_contactCaTrials_locdep{n}.sigmag(L_ind(retract));
        sig_kappa_L(i,1,2) = nanmean(y)./nanmean(x);
        sig_kappa_L(i,2,2) = nanstd(y)./nanmean(x);
        sig_kappa_L(i,3,2) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_L(i,:,2) = polyfit(x,y,1);        
        sig_kappa_L_trials{n,i,2} = y./x;

        mx = max([abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind)); abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind))]);
        my = max([pooled_contactCaTrials_locdep{n}.sigmag(NL_ind); pooled_contactCaTrials_locdep{n}.sigmag(L_ind)]);
        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i),2) >1)
                title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
                            title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
                %         axis([0  mx+5 -50 my+100]);
        if strcmp(par,'sigmag')
            axis([10e-4 .15 0 5000]);
        elseif strcmp(par,'sigpeak')
            axis([10e-4 .15 0 600]);
        end
        count = count+1;
  
        
        hline(30,'k:');
        hline(0,'k--');
        
        plot([0.01:.01:1.5],polyval(p_NL(i,:,1) ,[0.01:.01:1.5]),'k-','linewidth',2);hold on;
        plot([0.01:.01:1.5],polyval(p_L(i,:,1),[0.01:.01:1.5]),'r-','linewidth',2);hold on;
        
        plot([0.01:.01:1.5],polyval(p_NL(i,:,2) ,[0.01:.01:1.5]),'color',[.5 .5 .5],'linewidth',2);hold on;
        plot([0.01:.01:1.5],polyval(p_L(i,:,2),[0.01:.01:1.5]),'color',[.85 .5 .5],'linewidth',2);  
        
%         plot([0.0001:.01:1.0],polyval(p_NL(i,:,1) ,[0.0001:.01:1.0]),'k-','linewidth',2);hold on;
%         plot([0.0001:.01:1.0],polyval(p_L(i,:,1),[0.0001:.01:1.0]),'r-','linewidth',2);hold on;
%         
%          plot([0.0001:.01:1.0],polyval(p_NL(i,:,2) ,[0.0001:.01:1.0]),'color',[.5 .5 .5],'linewidth',2);hold on;
%         plot([0.0001:.01:1.0],polyval(p_L(i,:,2),[0.0001:.01:1.0]),'color',[.85 .5 .5],'linewidth',2);       
        
        
    end
    
    setpoint_at_contact = pooled_contactCaTrials_locdep{n}.Setpoint_at_contact_Mean; %%% use ths for joint plot
    
    subplot(length(dends),numloc+xcol,count:count+1);
    h= plot([1:numloc],p_NL(:,1),'k-o'); set(h,'linewidth',1.5);hold on;
    h= plot([1:numloc],p_L(:,1),'r-o');set(h,'linewidth',1.5);
    hline(0,'k:');
    title( ' slopes'); axis([0 6 min(min(p_NL([a:z],1)),min(p_L([a:z],1)))-50  max(max(p_NL([a:z],1)),max(p_L([a:z],1)))+50]);
    
    count = count+2;
end
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 18 24]);
set(gcf, 'PaperSize', [24,10]);
set(gcf,'PaperPositionMode','manual');
%         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Loc Dep SL ' par ' reg  D ' num2str(dends)],'jpg');

% %% traces
% % h_fig2= figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
% h_fig2= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
% % h_fig3= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
% count=1;
% for d=1:length(dends)
%     n = dends(d);
%     xcol =0;
%     polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
%     numloc =length(polelocs);
%     samp_time = pooled_contactCaTrials_locdep{n}.FrameTime;
%     a = 1;
%     z = numloc;
% %     touchmag = [0.01,0.05,0.1,0.2,.3,.4,.5,1];
%         touchmag = [.025:.025:.25];
% 
%     colr = othercolor('Paired3',10);
%     colp = othercolor('PuOr4',10);
%     for i = 1:numloc
%         ts = [1:size(pooled_contactCaTrials_locdep{n}.rawdata,2)].*samp_time;
%         NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
%         L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
%       
%         retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind) >0);
%         protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind)<0);
%         if(~isempty(retract))
%             for r=1:length(retract)
% %                 pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract(r)))
%                 [ mval, colind] = min(abs(touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract(r))))));
%                 figure(h_fig2); subplot(length(dends),numloc+xcol,count);  
%                 plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(retract(r)),:),'color',colr(colind,:),'linewidth',.5); hold on;
% %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count); 
% %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(retract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{NL_ind(retract(r))},'color',colr(colind,:),'linewidth',.15); hold on;
% %         
%             end
%         end
%         if(~isempty(protract))
%             for r=1:length(protract)
% %                 pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract(r)))
%                  [ mval, colind]=min(abs((touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract(r)))))));
%                 figure(h_fig2); subplot(length(dends),numloc+xcol,count);                  
%                 plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(protract(r)),:),'color',colp(colind,:),'linewidth',.5);hold on;
% %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count); 
% %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(protract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{NL_ind(protract(r))},'color',colp(colind,:),'linewidth',.15); hold on;
%   
%             end
%         end
%         
%         retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind) >0);
%         protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind)<0);
%         
%         if(~isempty(retract))
%             for r=1:length(retract)
%                  [ mval, colind] = min(abs(touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(retract(r))))));
%                  figure(h_fig2); subplot(length(dends),numloc+xcol,count);  
%                 plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(retract(r)),:),'-','color',col(colind,:),'linewidth',.5); hold on;
% %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count); 
% %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(retract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{L_ind(retract(r))},'color',col(colind,:),'linewidth',.15); hold on;
% 
%             end
%         end
%         if(~isempty(protract))
%             for r=1:length(protract)
%                  [ mval, colind]=min(abs((touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(protract(r)))))));
%                  figure(h_fig2); subplot(length(dends),numloc+xcol,count);  
%                 plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(protract(r)),:),'color',col(colind,:),'linewidth',.5);
% %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count); 
% %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(protract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{L_ind(protract(r))},'color',col(colind,:),'linewidth',.15); hold on;
% 
%             end
%         end
%         figure(h_fig2);
%         axis([0 2.5 0 600]);
%         hline(30,'k.');
%         hline(0,'k--');
%         
% %         figure(h_fig3);
% %         axis([0 2.5 -.5 0.5]);
% 
%         count = count+1;
%         
%         if(size(pooled_contactCaTrials_locdep{n}.num_trials(i),2) >1)
%                 figure(h_fig2);
%                 title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
% %                 figure(h_fig3);
% %                 title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
% 
%         else
%                 figure(h_fig2);
%                 title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
% %                 figure(h_fig3);
% %                 title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
% 
%         end
%     end
%     
% %     subplot(length(dends),numloc+xcol,count:count+1);
% %     
% %     h= plot([1:numloc],p_NL(:,1),'k-o'); set(h,'linewidth',1.5);hold on;
% %     h= plot([1:numloc],p_L(:,1),'r-o');set(h,'linewidth',1.5);
% %     hline(0,'k:');
% %     title( ' slopes'); axis([0 6 min(min(p_NL([a:z],1)),min(p_L([a:z],1)))-50  max(max(p_NL([a:z],1)),max(p_L([a:z],1)))+50]);
% %     
% %     count = count+2;    
% %     
% %     
% end
% figure(h_fig2);
% set(gcf,'PaperUnits','inches');
% set(gcf,'PaperPosition',[1 1 18 24]);
% set(gcf, 'PaperSize', [24,10]);
% set(gcf,'PaperPositionMode','manual');
% %         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
% saveas(gcf,[' Loc Dep Ca Traces  D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');

% figure(h_fig3);
% set(gcf,'PaperUnits','inches');
% set(gcf,'PaperPosition',[1 1 18 24]);
% set(gcf, 'PaperSize', [24,10]);
% set(gcf,'PaperPositionMode','manual');
% %         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
% saveas(gcf,[' Loc Dep Tou Traces  D ' num2str(dends)],'jpg');


% % %% to check trial by trial
% % obj = pooled_contactCaTrials_locdep{3};
% % loc =1;
% % figure
% % for j = 1:obj.num_trials(loc)
% %     ts = obj.wSig_dKappatime{loc}{j}(2)-obj.wSig_dKappatime{loc}{j}(1) ; 
% %     dKaapa_time = obj.wSig_dKappatime{loc}{j} - obj.wSig_dKappatime{loc}{j}(1) + ts;
% % [ax,h1,h2] = plotyy(obj.CaSig_time{loc},obj.CaSig_data{loc}(j,:)',dKaapa_time,(obj.wSig_dKappadata{loc}{j}./24.38)); 
% % set(ax(1),'YLim',[-50, 500])
% % set(ax(2),'YLim',[-.5,.5])% plot(dKaapa_time,obj.wSig_dKappadata{loc}{j},'r'); hold off;
% % text(1,100,num2str(obj.wSig_totmodKappa{loc}(j)));
% % waitforbuttonpress
% % end
