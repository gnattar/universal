
function plot_thetadep_L_NL_reg_prot_ret_RE(pooled_contactCaTrials_thetadep,dends,tag,p)
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1, sc(4)*1], 'color','w');
count =1;
for d=1:length(dends)
    n = dends(d);
    xcol =2;
    polelocs = unique(pooled_contactCaTrials_thetadep{n}.poleloc);
        polelocs(polelocs<50) = [];
        if (p=='peak')
            subzero = find(pooled_contactCaTrials_thetadep{n}.sigpeak_RE(:) <0);
            pooled_contactCaTrials_thetadep{n}.sigpeak_RE(subzero) = 0;
        elseif (p=='mag')
            subzero = find(pooled_contactCaTrials_thetadep{n}.sigmag_RE(:) <0);
            pooled_contactCaTrials_thetadep{n}.sigmag_RE(subzero) = 0;
        end

    numloc =length(polelocs);
%         numloc = 5;
    a = 1;
    z = numloc;
    for i = 1:numloc
        NL_ind = find(( pooled_contactCaTrials_thetadep{n}.poleloc == polelocs(i)) & (pooled_contactCaTrials_thetadep{n}.lightstim ==0) );
        L_ind =  find(( pooled_contactCaTrials_thetadep{n}.poleloc == polelocs(i)) & (pooled_contactCaTrials_thetadep{n}.lightstim ==1) );
        subplot(length(dends),numloc+xcol,count);
        
        
        retract = NL_ind(find(pooled_contactCaTrials_thetadep{n}.totalKappa_RE(NL_ind) >= 0));
        protract = NL_ind( find(pooled_contactCaTrials_thetadep{n}.totalKappa_RE(NL_ind) <= 0));
        
        
        if tag
            if (p == 'peak')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract),pooled_contactCaTrials_thetadep{n}.sigpeak_RE(retract),'o','color',[.5 .5 .5],'Markersize',10, 'Markerfacecolor',[.5 .5 .5]); hold on;
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1,pooled_contactCaTrials_thetadep{n}.sigpeak_RE(protract),'ko','Markersize',10, 'Markerfacecolor','k'); hold on;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1;
                y =pooled_contactCaTrials_thetadep{n}.sigpeak_RE(protract);
                 y(x==0) = [];x(x==0) = []; y(y<0) = 0;
                sigmag_kappa_NL(i,1,1) = nanmean(y./x);
                sigmag_kappa_NL(i,2,1) = nanstd(y./x);
                sigmag_kappa_NL(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
                
                p_NL(i,:,1) = polyfit(x,y,1);
                sigmag_kappa_NL_trials{n,i,1} = y./x;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract);
                y =pooled_contactCaTrials_thetadep{n}.sigpeak_RE(retract);
               y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_NL(i,1,2) = nanmean(y./x);
                sigmag_kappa_NL(i,2,2) = nanstd(y./x);
                sigmag_kappa_NL(i,3,2) = (nanstd(y./x))/sqrt(length(x)+1);
                p_NL(i,:,2) = polyfit(x,y,1);
                sigmag_kappa_NL_trials{n,i,2} = y./x;
                
            elseif (p=='mag')
                
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract),pooled_contactCaTrials_thetadep{n}.sigmag_RE(retract),'o','color',[.5 .5 .5],'Markersize',10, 'Markerfacecolor',[.5 .5 .5]); hold on;
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1,pooled_contactCaTrials_thetadep{n}.sigmag_RE(protract),'ko','Markersize',10, 'Markerfacecolor','k'); hold on;
                
                
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1;
                y =pooled_contactCaTrials_thetadep{n}.sigmag_RE(protract);
               y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_NL(i,1,1) = nanmean(y./x);
                sigmag_kappa_NL(i,2,1) = nanstd(y./x);
                sigmag_kappa_NL(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
                
                p_NL(i,:,1) = polyfit(x,y,1);
                sigmag_kappa_NL_trials{n,i,1} = y./x;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract);
                y =pooled_contactCaTrials_thetadep{n}.sigmag_RE(retract);
              y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_NL(i,1,2) = nanmean(y./x);
                sigmag_kappa_NL(i,2,2) = nanstd(y./x);
                sigmag_kappa_NL(i,3,2) = (nanstd(y./x))/sqrt(length(x)+1);
                p_NL(i,:,2) = polyfit(x,y,1);
                sigmag_kappa_NL_trials{n,i,2} = y./x;
                
            end
            
            retract = [];
            protract = [];
        else
            if (p == 'peak')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(NL_ind),pooled_contactCaTrials_thetadep{n}.sigpeak_RE(NL_ind),'o','color',[.5 .5 .5],'Markersize',10, 'Markerfacecolor',[.5 .5 .5]); hold on;
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(NL_ind);
                y =pooled_contactCaTrials_thetadep{n}.sigpeak_RE(NL_ind);
            elseif (p == 'mag')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(NL_ind),pooled_contactCaTrials_thetadep{n}.sigmag_RE(NL_ind),'o','color',[.5 .5 .5],'Markersize',10, 'Markerfacecolor',[.5 .5 .5]); hold on;
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(NL_ind);
                y =pooled_contactCaTrials_thetadep{n}.sigmag_RE(NL_ind);
            end
            y(x==0) = [];x(x==0) = [];y(y<0) = 0;
            sigmag_kappa_NL(i,1,1) = nanmean(y./x);
            sigmag_kappa_NL(i,2,1) = nanstd(y./x);
            sigmag_kappa_NL(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
            
            p_NL(i,:,1) = polyfit(x,y,1);
            sigmag_kappa_NL_trials{n,i,1} = y./x;
            
        end
        
        retract = L_ind(find(pooled_contactCaTrials_thetadep{n}.totalKappa_RE(L_ind) >=0));
        protract = L_ind( find(pooled_contactCaTrials_thetadep{n}.totalKappa_RE(L_ind)<=0));
        
        
        if tag
            if (p == 'peak')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract),pooled_contactCaTrials_thetadep{n}.sigpeak_RE(retract),'o','color',[1 .65 .65],'Markersize',10,'Markerfacecolor',[1 .65 .65]);
                hold on;
                %axis( [0 5 -50 150]);
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1,pooled_contactCaTrials_thetadep{n}.sigpeak_RE(protract),'ro','Markersize',10,'Markerfacecolor','r');
                hold on;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1;
                y =pooled_contactCaTrials_thetadep{n}.sigpeak_RE(protract);
                 y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_L(i,1,1) = nanmean(y./x);
                sigmag_kappa_L(i,2,1) = nanstd(y./x);
                sigmag_kappa_L(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
                p_L(i,:,1) = polyfit(x,y,1);
                sigmag_kappa_L_trials{n,i,1} = y./x;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract);
                y =pooled_contactCaTrials_thetadep{n}.sigpeak_RE(retract);
                y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_L(i,1,2) = nanmean(y./x);
                sigmag_kappa_L(i,2,2) = nanstd(y./x);
                sigmag_kappa_L(i,3,2) = (nanstd(y./x))/sqrt(length(x)+1);
                p_L(i,:,2) = polyfit(x,y,1);
                sigmag_kappa_L_trials{n,i,2} = y./x;
                
            elseif (p== 'mag')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract),pooled_contactCaTrials_thetadep{n}.sigmag_RE(retract),'o','color',[1 .65 .65],'Markersize',10,'Markerfacecolor',[1 .65 .65]);
                hold on;
                %axis( [0 5 -50 150]);
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1,pooled_contactCaTrials_thetadep{n}.sigmag_RE(protract),'ro','Markersize',10,'Markerfacecolor','r');
                hold on;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(protract).*-1;
                y =pooled_contactCaTrials_thetadep{n}.sigmag_RE(protract);
              y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_L(i,1,1) = nanmean(y./x);
                sigmag_kappa_L(i,2,1) = nanstd(y./x);
                sigmag_kappa_L(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
                p_L(i,:,1) = polyfit(x,y,1);
                sigmag_kappa_L_trials{n,i,1} = y./x;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(retract);
                y =pooled_contactCaTrials_thetadep{n}.sigmag_RE(retract);
                y(x==0) = [];x(x==0) = [];y(y<0) = 0;
                sigmag_kappa_L(i,1,2) = nanmean(y./x);
                sigmag_kappa_L(i,2,2) = nanstd(y./x);
                sigmag_kappa_L(i,3,2) = (nanstd(y./x))/sqrt(length(x)+1);
                p_L(i,:,2) = polyfit(x,y,1);
                sigmag_kappa_L_trials{n,i,2} = y./x;
            end
        else
            if (p == 'peak')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(L_ind),pooled_contactCaTrials_thetadep{n}.sigpeak_RE(L_ind),'o','color',[1 .65 .65],'Markersize',10,'Markerfacecolor',[1 .65 .65]);
                hold on;
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(L_ind);
                y =pooled_contactCaTrials_thetadep{n}.sigpeak_RE(L_ind);
            elseif(p=='mag')
                plot(pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(L_ind),pooled_contactCaTrials_thetadep{n}.sigmag_RE(L_ind),'o','color',[1 .65 .65],'Markersize',10,'Markerfacecolor',[1 .65 .65]);
                hold on;
                
                x=pooled_contactCaTrials_thetadep{n}.AbstotalKappa_RE(L_ind);
                y =pooled_contactCaTrials_thetadep{n}.sigmag_RE(L_ind);
            end
            y(x==0) = [];x(x==0) = [];y(y<0) = 0;
            sigmag_kappa_L(i,1,1) = nanmean(y./x);
            sigmag_kappa_L(i,2,1) = nanstd(y./x);
            sigmag_kappa_L(i,3,1) = (nanstd(y./x))/sqrt(length(x)+1);
            p_L(i,:,1) = polyfit(x,y,1);
            sigmag_kappa_L_trials{n,i,1} = y./x;
            
        end
        
        %         title([ 'D ' num2str(n) '  PL ' num2str(polelocs(i)) '  ' num2str(pooled_contactCaTrials_thetadep{n}.num_trials(1,i)) ' NL ' num2str(pooled_contactCaTrials_thetadep{n}.num_trials(2,i)) ' L ' ]);
        title([ 'D ' num2str(n) '  PL ' num2str(polelocs(i)) '  ' num2str(length(NL_ind)) ' NL ' num2str(length(L_ind)) ' L ' ]);
        
        %           axis([0  mx+5 -50 my+100]);
        if tag
            if (p == 'peak')
                axis([-80 80 -10 250]);
            elseif (p =='mag')
                axis([-80 80 -1000 4000]);
            end
        else
            
            if (p == 'peak')
                axis([0 80 -10 400])
            elseif (p =='mag')
                axis([0 80 -1000 5000])
            end
        end
        vline(0,'k--');
        hline(0,'k--');
        count = count+1;
        
        %%plotting st line fits to points
        if(tag)
            %protract
            plot([-50:-1],polyval(p_NL(i,:,1) ,[-50:-1]),'k-','linewidth',1.5);
            plot([-50:-1],polyval(p_L(i,:,1),[-50:-1]),'r--','linewidth',1.5);
            
            %retract
            plot([1:50],polyval(p_NL(i,:,2) ,[1:50]),'color',[0.5 .5 .5],'linewidth',1.5);
            plot([1:50],polyval(p_L(i,:,2),[1:50]),'color',[01 .65 .65],'linewidth',1.5);
        else
            plot([1:50],polyval(p_NL(i,:,1) ,[1:50]),'color',[0.5 .5 .5],'linewidth',1.5);
            plot([1:50],polyval(p_L(i,:,1),[1:50]),'color',[01 .65 .65],'linewidth',1.5);
            
        end
        
    end
    
    % % %     %%plotting slopes
    % % %
    % % %      subplot(length(dends),numloc+xcol,count:count+1);
    % % %     h= plot([1:numloc],p_NL(:,1,1),'k-o'); set(h,'linewidth',1.5);hold on;
    % % %     h= plot([1:numloc],p_L(:,1,1),'r-o');set(h,'linewidth',1.5);
    % % %
    % % %     h= plot([1:numloc],p_NL(:,1,2),'o-','color',[.5 .5 .5]); set(h,'linewidth',1.5);hold on;
    % % %     h= plot([1:numloc],p_L(:,1,2),'o-','color',[1 .65 .65]);set(h,'linewidth',1.5);
    % % %
    % % %     hline(0,'k:');
    % % %      title( ' slopes');
    % % % %       axis([0 6 min(min(min(p_NL([a:z],1,:)),min(p_L([a:z],1,:))))-50  max(max(max(p_NL([a:z],1,:)),max(p_L([a:z],1,:))))+50]);
    % % %     axis([0 numloc+1 -500 500])
    % % %      count = count+2;
    % % %
    % % %
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
    
    
            if (p == 'peak')
                  axis([0 numloc+1 -10 10])
            elseif (p=='mag')
    axis([0 numloc+1 -1000 1000])
            end
    count = count+2;
    
end

set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
%         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Theta Dep reg temp D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');

