function whiskloc_dependence_plotdata(pooled_contactCaTrials_locdep,dends,par)
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
count =1;
for d=1:length(dends)
    n = dends(d);
    xcol =2;
    polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
    numloc =length(polelocs);
    a = 1;
    z = numloc;
    for i = 1:numloc
        NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
        L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
        subplot(length(dends),numloc+xcol,count);
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind) <0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract)),'ko','Markersize',7); hold on;
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract)),'ko','Markersize',7, 'Markerfacecolor',[.5 .5 .5]); hold on;
        
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind)<0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(retract)),'ro','Markersize',7); hold on;%axis( [0 5 -50 150]);
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(protract)),'ro','Markersize',7); hold on;
        

        mx = max([abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind)); abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind))]);
        my = max([pooled_contactCaTrials_locdep{n}.sigmag(NL_ind); pooled_contactCaTrials_locdep{n}.sigmag(L_ind)]);
        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i),2) >1)
                title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
                            title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
                %         axis([0  mx+5 -50 my+100]);
        if strcmp(par,'sigmag')
            axis([-0.1 1 0 5000]);
        elseif strcmp(par,'sigpeak')
            axis([-0.1 1 0 350]);
        end
        count = count+1;
        
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind));
        y =pooled_contactCaTrials_locdep{n}.sigmag(NL_ind);
        sigmag_kappa_L(i,1) = nanmean(y)./nanmean(x);
        sigmag_kappa_L(i,2) = nanstd(y)./nanmean(x);
        sigmag_kappa_L(i,3) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_NL(i,:) = polyfit(x,y,1);
        sigmag_kappa_L_trials{n,i} = y./x;
        
        x=abs(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind));
        y =pooled_contactCaTrials_locdep{n}.sigmag(L_ind);
        sigmag_kappa_NL(i,1) = nanmean(y)./nanmean(x);
        sigmag_kappa_NL(i,2) = nanstd(y)./nanmean(x);

        sigmag_kappa_NL(i,3) = (nanstd(y)./nanmean(x))/sqrt(length(x)+1);
        p_L(i,:) = polyfit(x,y,1);
        
        sigmag_kappa_NL_trials{n,i} = y./x;
         hline(30,'k:');
        hline(0,'k--');
%         
%         plot([1:50],polyval(p_NL(i,:) ,[1:50]),'k-');
%         plot([1:50],polyval(p_L(i,:),[1:50]),'r-');
%         
        % %         x=pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind);
        % %         y =pooled_contactCaTrials_locdep{n}.sigmag(NL_ind);
        % %         yy = y(x<0);%% retraction touches
        % %         xx = x(x < 0);
        % %         p_NL(i,:,1) = polyfit(xx,yy,1);
        % %         yy = y(x>0);%% protraction touches
        % %         xx = x(x > 0);
        % %         p_NL(i,:,2) = polyfit(xx,yy,1);
        % %
        % %         x=pooled_contactCaTrials_locdep{n}.totalKappa(L_ind);
        % %         y =pooled_contactCaTrials_locdep{n}.sigmag(L_ind);
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
saveas(gcf,[' Loc Dep ' par ' reg  D ' num2str(dends)],'jpg');

h_fig2= figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
count=1;
for d=1:length(dends)
    n = dends(d);
    xcol =0;
    polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
    numloc =length(polelocs);
    samp_time = pooled_contactCaTrials_locdep{n}.FrameTime;
    a = 1;
    z = numloc;
%     touchmag = [0.01,0.05,0.1,0.2,.3,.4,.5,1];
        touchmag = [.01:.01:.1];

col = othercolor('MIndexed24',10);
    for i = 1:numloc
        ts = [1:size(pooled_contactCaTrials_locdep{n}.rawdata,2)].*samp_time;
        NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
        L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
        subplot(length(dends),numloc+xcol,count);
        
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind)<0);
        if(~isempty(retract))
            for r=1:length(retract)
                [ mval, colind] = min(abs(touchmag - pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind(retract(r)))));
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(retract(r)),:),'color',col(colind,:),'linewidth',.15); hold on;
            end
        end
        if(~isempty(protract))
            for r=1:length(protract)
                colind=find(min(touchmag - pooled_contactCaTrials_locdep{n}.totalKappa(NL_ind(protract(r)))));
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(protract(r)),:),'color',col(colind,:),'linewidth',.15);hold on;
            end
        end
        
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa(L_ind)<0);
        
        if(~isempty(retract))
            for r=1:length(retract)
                colind=find(min(touchmag - pooled_contactCaTrials_locdep{n}.totalKappa(L_ind(retract(r)))));
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(retract(r)),:),'-','color',col(colind,:),'linewidth',.15); hold on;
            end
        end
        if(~isempty(protract))
            for r=1:length(protract)
                colind=find(min(touchmag - pooled_contactCaTrials_locdep{n}.totalKappa(L_ind(protract(r)))));
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(protract(r)),:),'color',col(colind,:),'linewidth',.15);
            end
        end
        axis([0 5 0 350]);
        
        hline(30,'k.');
        hline(0,'k--');
        count = count+1;
        
        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i),2) >1)
                title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
                title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
    end
    
end
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 18 24]);
set(gcf, 'PaperSize', [24,10]);
set(gcf,'PaperPositionMode','manual');
%         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Loc Dep Traces  D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
