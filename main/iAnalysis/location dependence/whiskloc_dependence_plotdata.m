function [pooled_contactCaTrials_locdep] = whiskloc_dependence_plotdata(pooled_contactCaTrials_locdep,dends,par,fit_separate,traces)
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
    p_NL1 =zeros(numloc,2,2);p_L1 =zeros(numloc,2,2);
    p_NL2 =zeros(numloc,4,2);p_L2 =zeros(numloc,4,2);
    sig_kappa_L = zeros(numloc,3,2);
    sig_kappa_NL = zeros(numloc,3,2);
    for i = 1:numloc
        NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
        L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
        subplot(length(dends),numloc+xcol,count);
        %% No light
        %         cdir= cellfun( @(x) (sum(x==1)>sum(x==0))*1+(sum(x ==1)<sum(x==0)*0), pooled_contactCaTrials_locdep{n}.contactdir);
        %         retract = find(cdir(NL_ind)==0);
        %         protract = find(cdir(NL_ind)==1);
        
        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind) <0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract)),'o','color',[.5 .5 .5],'Markersize',7,'Markerfacecolor',[.5 .5 .5]); hold on;
        plot(abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract)),'ko','Markersize',7, 'Markerfacecolor',[0 0 0]); hold on;
        
        if fit_separate
            % separating protraction and retraction
            %protraction
            str = '_NL_P';temp = [];
            x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract)));
            y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract));
            fittype = 'lin';
            [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
            temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
            p_NL1(i,:,1) = param;
            p_NL1CIL(i,:,1) = paramCI(1,:);p_NL1CIU(i,:,1) = paramCI(2,:);
            
            %         fittype = 'sig';param =[];
            %         [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
            %         temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
            %         p_NL2(i,:,1) = param;
            %         p_NL2CIL(i,:,1) = paramCI(1,:);p_NL2CIU(i,:,1) = paramCI(2,:);
            
            % retraction
            str = '_NL_R';temp = [];
            x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract)));
            y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract));
            fittype = 'lin';
            [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
            temp (:,1) = x;temp(:,2) = y;temp(:,3) = f;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str 'fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str 'fitevals'])(i,:,1) = fitevals;
            p_NL1(i,:,2) = param;
            p_NL1CIL(i,:,2) = paramCI(1,:);p_NL1CIU(i,:,2) = paramCI(2,:);
            
            %         fittype = 'sig';
            %         [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
            %         temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
            %         p_NL2(i,:,2) = param;
            %         p_NL2CIL(i,:,2) = paramCI(1,:);p_NL2CIU(i,:,2) = paramCI(2,:);
        else
            % pooling together protraction and retraction
            
            str = '_NL';temp = [];
            x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind));
            y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind);
            fittype = 'lin';
            [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
            temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
            p_NL1(i,:,1) = param;
            p_NL1CIL(i,:,1) = paramCI(1,:);p_NL1CIU(i,:,1) = paramCI(2,:);
            
%             fittype = 'sig';param =[];
%             [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
%             temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
%             pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
%             pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
%             pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCIL'])(i,:,:) = paramCI(1,:);
%             pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCIU'])(i,:,:) = paramCI(1,:);
%             pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
%             p_NL2(i,:,1) = param;
%             p_NL2CIL(i,:,1) = paramCI(1,:);p_NL2CIU(i,:,1) = paramCI(2,:);
            
        end
        
        if ~isempty(L_ind)
            % Light trials
            retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind) >0);
            protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind)<0);
            
            plot(abs(pooled_contactCaTrials_locdep_fit.totalKappa_epoch(L_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(retract)),'o','color',[.85 .5 .5],'Markersize',7,'Markerfacecolor',[.85 .5 .5]); hold on;%axis( [0 5 -50 150]);
            plot(abs(pooled_contactCaTrials_locdep_fit.totalKappa_epoch(L_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(protract)),'ro','Markersize',7,'Markerfacecolor',[1 0 0 ]); hold on;
            
            if fit_separate
                % separating protraction and retraction
                %protraction
                str = '_L_P';temp = [];
                x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract)));
                y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract));
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
                temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
                p_L1(i,:,1) = param;
                p_L1CIL(i,:,1) = paramCI(1,:);p_L1CIU(i,:,1) = paramCI(2,:);
                
                %         fittype = 'sig';param =[];
                %         [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
                %         temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
                %         p_L2(i,:,1) = param;
                %         p_L2CIL(i,:,1) = paramCI(1,:);p_L2CIU(i,:,1) = paramCI(2,:);
                
                % retraction
                str = '_L_R';temp = [];
                x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(retract)));
                y =pooled_contactCaTrials_locdep{n}.(par)(L_ind(retract));
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = f;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str 'fitparam'])(i,:,1) = param;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str 'fitevals'])(i,:,1) = fitevals;
                p_L1(i,:,2) = param;
                p_L1CIL(i,:,2) = paramCI(1,:);p_L1CIU(i,:,2) = paramCI(2,:);
                
                %         fittype = 'sig';
                %         [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
                %         temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                %         pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
                %         p_L2(i,:,2) = param;
                %         p_L2CIL(i,:,2) = paramCI(1,:);p_L2CIU(i,:,2) = paramCI(2,:);
            else
                % pooling together protraction and retraction
                
                str = '_L';temp = [];
                x=abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind));
                y =pooled_contactCaTrials_locdep{n}.(par)(L_ind);
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
                temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
                p_L1(i,:,1) = param;
                p_L1CIL(i,:,1) = paramCI(1,:);p_L1CIU(i,:,1) = paramCI(2,:);
                
%                 fittype = 'sig';param =[];
%                 [param,paramCI,fitevals,f] = FitEval(x,y,fittype);
%                 temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
%                 pooled_contactCaTrials_locdep{n}.(['Fit_' fittype 'waves' str ]){i} = temp;
%                 pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
%                 pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
%                 pooled_contactCaTrials_locdep{n}.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
%                 p_L2(i,:,1) = param;
%                 p_L2CIL(i,:,1) = paramCI(1,:);p_L2CIU(i,:,1) = paramCI(2,:);
%                 
                
            end
            
        end
        
        %         mx = max([abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind)); abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind))]);
        %         my = max([pooled_contactCaTrials_locdep{n}.sigmag(NL_ind); pooled_contactCaTrials_locdep{n}.sigmag(L_ind)]);
        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i),2) >1)
            title([ ' ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
            title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
        %         axis([0  mx+5 -50 my+100]);
        if strcmp(par,'sigmag')
            axis([10e-4 2.0 0 5000]);
        elseif strcmp(par,'sigpeak')
            axis([10e-4 2.0 0 900]);
        end
        count = count+1;
        
        
        hline(30,'k:');
        hline(0,'k--');
        
        plot([0.0001:.01:2.5],polyval(p_NL1(i,:,1) ,[0.0001:.01:2.5]),'k-','linewidth',2);hold on;
        if fit_separate
            plot([0.0001:.01:2.5],polyval(p_NL1(i,:,2) ,[0.0001:.01:2.5]),'color',[.5 .5 .5],'linewidth',2);
        end
        
%         
%         fsigm = @(param,xval) param(1)+(param(2)-param(1))./(1+10.^((param(3)-xval)*param(4)));
%         plot([0.0001:.01:2.5],fsigm(p_NL2(i,:,1) ,[0.0001:.01:2.5]),'b-','linewidth',2);
        if fit_separate
            plot([0.0001:.01:2.5],fsigm(p_NL2(i,:,2) ,[0.0001:.01:2.5]),'color',[.5 .5 .85],'linewidth',2);
        end
        if ~isempty(L_ind)
            
            plot([0.0001:.01:2.5],polyval(p_L1(i,:,1),[0.0001:.01:2.5]),'r-','linewidth',2);hold on;
            if fit_separate
                plot([0.0001:.01:2.5],polyval(p_L1(i,:,2),[0.0001:.01:2.5]),'color',[.85 .5 .5],'linewidth',2);
            end
            %             plot([0.0001:.01:1.5],fsigm(pSig_L(i,:,1),[0.0001:.01:1.5]),'m-','linewidth',2);hold on;
            %             plot([0.0001:.01:1.5],fsigm(pSig_L(i,:,2),[0.0001:.01:1.5]),'color',[.85 .5 .85],'linewidth',2);
            
        end
        
        set(gca,'xscale','log');
    end
    
    theta_at_contact = pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean; %%% use ths for joint plot
    
    subplot(length(dends),numloc+xcol,count:count+1);
    h= plot([1:numloc],p_NL1(:,1,1),'k-o'); set(h,'linewidth',3);hold on;
    plot([1:numloc],p_NL1CIU(:,1,1),'k--','linewidth',2); plot([1:numloc],p_NL1CIL(:,1,1),'k--','linewidth',2);
%     LPI = (max(p_NL1(:,1,1))-mean(p_NL1(:,1,1)))/(mean(p_NL1(:,1,1)));
    LPI = (max(p_NL1(:,1,1))-min(p_NL1(:,1,1)))/(max(p_NL1(:,1,1))+ min(p_NL1(:,1,1)));

    LPI = round(LPI*100)./100;
    tb=text(3,max(p_NL1(:,1,1)) +100,['LPI ' num2str(LPI)],'FontSize',18);
    pooled_contactCaTrials_locdep{n}.LPI = LPI;
    if fit_separate
        h= plot([1:numloc],p_NL1(:,1,2),'-o','color',[.5 .5 .5]); set(h,'linewidth',3);
        plot([1:numloc],p_NL1CIU(:,1,2),'--','color',[.5 .5 .5]); plot([1:numloc],p_NL1CIL(:,1,2),'--','color',[.5 .5 .5]);set(h,'linewidth',3);
    end
    
    if ~isempty(L_ind)
        h= plot([1:numloc],p_L1(:,1,1),'r-o');set(h,'linewidth',1.5);hold on;
        LSI = (max(p_L1(:,1,1))-mean(p_L1(:,1,1)))/mean(p_L1(:,1,1));
        text(5,500,['LSI_l ' num2str(LSI)]);
        if fit_separate
            h= plot([1:numloc],p_L1(:,1,2),'-o','color',[.85, .5 , .5]);set(h,'linewidth',3);
        end
    end
    axis([0  numloc+1 -100  max(p_NL1(:,1,1))+200]);
    
     
    
%     subplot(length(dends),numloc+xcol,count+1);
%     h= plot([1:numloc],p_NL2(:,4,1),'k-o'); set(h,'linewidth',1.5);hold on;
%     plot([1:numloc],p_NL2CIU(:,4,1),'k--'); plot([1:numloc],p_NL2CIL(:,4,1),'k--');
%     if fit_separate
%         h= plot([1:numloc],p_NL2(:,4,2),'-o','color',[.5 .5 .5]); set(h,'linewidth',1.5);hold on;
%         plot([1:numloc],p_NL2CIU(:,4,2),'b--'); plot([1:numloc],p_NL2CIL(:,4,2),'b--');
%     end
%     if ~isempty(L_ind)
%         h= plot([1:numloc],p_L2(:,4,1),'r-o');set(h,'linewidth',1.5);
%         h= plot([1:numloc],p_L2(:,4,2),'-o','color',[.85, .5 , .5]);set(h,'linewidth',1.5);
%     end
%     axis([0  numloc+1 -1  10]);
    hline(0,'k:');
    title( ' slopes');
    %axis([0 6 min(min(p_NL([a:z],1)),min(p_L([a:z],1)))-50  max(max(p_NL([a:z],1)),max(p_L([a:z],1)))+50]);
    
    count = count+2;
end
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Loc Dep  ' par ' reg  D ' num2str(dends)],'jpg');

 if traces

% h_fig2= figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
h_fig2= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
set(h_fig2, 'Renderer', 'OpenGL'); % faster drawing
h_fig3= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
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
    touchmag = [.025:.025:.25];

    colr = othercolor('PuBu3',10);
    colp = othercolor('OrRd5',10);
    for i = 1:numloc
        ts = [1:size(pooled_contactCaTrials_locdep{n}.rawdata,2)].*samp_time;
        NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
        L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));

        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind)<0);
        if(~isempty(retract))
            for r=1:length(retract)
                %                 pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract(r)))
                [ mval, colind] = min(abs(touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract(r))))));
                figure(h_fig2); subplot(length(dends),numloc+xcol,count);
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(retract(r)),:),'color',colr(colind,:),'linewidth',1.5); hold on;
                %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(retract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{NL_ind(retract(r))},'color',colr(colind,:),'linewidth',.15); hold on;
                %
            end
        end
        if(~isempty(protract))
            for r=1:length(protract)
                %                 pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract(r)))
                [ mval, colind]=min(abs((touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract(r)))))));
                figure(h_fig2); subplot(length(dends),numloc+xcol,count);
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(protract(r)),:),'color',colp(colind,:),'linewidth',1.5);hold on;
                %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(protract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{NL_ind(protract(r))},'color',colp(colind,:),'linewidth',.15); hold on;

            end
        end

        retract = find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind)<0);

        if(~isempty(retract))
            for r=1:length(retract)
                [ mval, colind] = min(abs(touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(retract(r))))));
                figure(h_fig2); subplot(length(dends),numloc+xcol,count);
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(retract(r)),:),'-','color',col(colind,:),'linewidth',1.5); hold on;
                %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(retract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{L_ind(retract(r))},'color',col(colind,:),'linewidth',.15); hold on;

            end
        end
        if(~isempty(protract))
            for r=1:length(protract)
                [ mval, colind]=min(abs((touchmag - abs(pooled_contactCaTrials_locdep{n}.totalKappa_epoch(L_ind(protract(r)))))));
                figure(h_fig2); subplot(length(dends),numloc+xcol,count);
                plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(protract(r)),:),'color',col(colind,:),'linewidth',1.5);
                %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(protract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{L_ind(protract(r))},'color',col(colind,:),'linewidth',.15); hold on;

            end
        end
        figure(h_fig2);
        axis([0 2.5 0 650]);
        hline(30,'k.');
        hline(0,'k--');

        %         figure(h_fig3);
        %         axis([0 2.5 -.5 0.5]);

        count = count+1;

        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i),2) >1)
            figure(h_fig2);
            title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
            %                 figure(h_fig3);
            %                 title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);

        else
            figure(h_fig2);
            title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
            %                 figure(h_fig3);
            %                 title([ 'D ' num2str(n) '  '  num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);

        end
    end

    %     subplot(length(dends),numloc+xcol,count:count+1);
    %
    %     h= plot([1:numloc],p_NL(:,1),'k-o'); set(h,'linewidth',1.5);hold on;
    %     h= plot([1:numloc],p_L(:,1),'r-o');set(h,'linewidth',1.5);
    %     hline(0,'k:');
    %     title( ' slopes'); axis([0 6 min(min(p_NL([a:z],1)),min(p_L([a:z],1)))-50  max(max(p_NL([a:z],1)),max(p_L([a:z],1)))+50]);
    %
    %     count = count+2;
    %
    %
end
figure(h_fig2);
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
        print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Loc Dep Ca Traces  D ' num2str(dends)],'jpg');
% saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');

end

% 












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(h_fig3);
% set(gcf,'PaperUnits','inches');
% set(gcf,'PaperPosition',[1 1 18 24]);
% set(gcf, 'PaperSize', [24,10]);
% set(gcf,'PaperPositionMode','manual');
% %         print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
% saveas(gcf,[' Loc Dep Tou Traces  D ' num2str(dends)],'jpg');


% % % %% to check trial by trial
% % % obj = pooled_contactCaTrials_locdep{3};
% % % loc =1;
% % % figure
% % % for j = 1:obj.num_trials(loc)
% % %     ts = obj.wSig_dKappatime{loc}{j}(2)-obj.wSig_dKappatime{loc}{j}(1) ;
% % %     dKaapa_time = obj.wSig_dKappatime{loc}{j} - obj.wSig_dKappatime{loc}{j}(1) + ts;
% % % [ax,h1,h2] = plotyy(obj.CaSig_time{loc},obj.CaSig_data{loc}(j,:)',dKaapa_time,(obj.wSig_dKappadata{loc}{j}./24.38));
% % % set(ax(1),'YLim',[-50, 500])
% % % set(ax(2),'YLim',[-.5,.5])% plot(dKaapa_time,obj.wSig_dKappadata{loc}{j},'r'); hold off;
% % % text(1,100,num2str(obj.wSig_totmodKappa{loc}(j)));
% % % waitforbuttonpress
% % % end


% % % % % % %% bonus : 3D plot of joint dependence
% % % % % % i = 9;
% % % % % % prot = find(pooled_contactCaTrials_locdep{i}.totalKappa_epoch<.01);
% % % % % % x=pooled_contactCaTrials_locdep{i}.totalKappa_epoch_abs;y=pooled_contactCaTrials_locdep{i}.Theta_at_contact_Mean;z=pooled_contactCaTrials_locdep{i}.sigpeak;
% % % % % % f= fit([x,y],z,'cubicinterp')
% % % % % % figure;
% % % % % % scatter3(abs(pooled_contactCaTrials_locdep{i}.totalKappa_epoch(prot)),pooled_contactCaTrials_locdep{i}.Theta_at_contact_Mean(prot),pooled_contactCaTrials_locdep{i}.sigpeak(prot),'filled');hold on;
% % % % % % plot( f, [x, y], z );
% % % % % % title(['Dend ' num2str(i)])