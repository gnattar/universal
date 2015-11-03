function [pooled_contactCaTrials_locdep] = whiskloc_dependence_plotdata(pooled_contactCaTrials_locdep,dends,par,wpar,fit_separate,traces,lpv,disp)
%% obj, dends, par = 'sigpeak' or 'sigmag', wpar = ' re_totaldK', fit_separate = 1 (prot and ret separately',

sc = get(0,'ScreenSize');
% h_fig1 = figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
count =1;
uL=1.5;
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
    fittype = 'lin';
    if fit_separate
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_NL_R' '_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_NL_R' '_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_NL_R' '_fitevals']) = nan(numloc,3,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_L_R' '_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_L_R' '_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_L_R' '_fitevals']) = nan(numloc,3,2);
        
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_NL_P' '_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_NL_P' '_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_NL_P' '_fitevals']) = nan(numloc,3,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_L_P' '_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_L_P' '_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par '_L_P' '_fitevals']) = nan(numloc,3,2);
    end
    for i = 1:numloc
        NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
        L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
        subplot(length(dends),numloc+xcol,count);
        %% No light
        %         cdir= cellfun( @(x) (sum(x==1)>sum(x==0))*1+(sum(x ==1)<sum(x==0)*0), pooled_contactCaTrials_locdep{n}.contactdir);
        %         retract = find(cdir(NL_ind)==0);
        %         protract = find(cdir(NL_ind)==1);
        
        retract = find(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind) >0);
        protract =  find(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind) <0);
        
        plot(abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract)),'o','color',[.5 .5 .5],'Markersize',7,'Markerfacecolor',[.5 .5 .5]); hold on;
        plot(abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract)),'ko','Markersize',7, 'Markerfacecolor',[0 0 0]); hold on;
        set(gca,'ticklength',[.05 .05]);
        ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(retract)));
        ca=pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract));
        
        
        dkappa_bins = logspace(-4,2,10); %Kappa bins
        if isempty(ka)
            NL_Ret_mean = 0;
        else
            
            [valcount edges mid loc] = histcn(ka,dkappa_bins);
            NL_Ret_mean = zeros(size(loc));
            for vali = 1:max(loc)
                inds = find(loc==vali);
                NL_Ret_mean(vali)=mean(ca(inds));
            end
        end
        
        if fit_separate
            
            % separating protraction and retraction
            %protraction
            str = '_NL_P';temp = [];
            x=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(protract)));
            y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(protract));
            fittype = 'lin';
            baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
            baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(protract),[1:baselinepts]);
            %             baselinevals = reshape(baselinevals,(size(baselinevals,1)*size(baselinevals,2)),1);
            noisethr = mean(prctile(baselinevals,99));
            
            if length(x) >2
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x,y,fittype,noisethr);
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = f;
            else
                fittype = 'lin';
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = nan;
                param = [nan nan];
                paramCI = [nan,nan;nan ,nan];
                fitevals = [nan nan nan];
            end
            
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype 'waves' str ]){i} = temp;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
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
            x=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(retract)));
            y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind(retract));
            fittype = 'lin';
            baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
            baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(retract),[1:baselinepts]);
            %             baselinevals = reshape(baselinevals,(size(baselinevals,1)*size(baselinevals,2)),1);
            noisethr = mean(prctile(baselinevals,99));
            
            if length(x) >2
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x,y,fittype,noisethr);
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = f;
            else
                fittype = 'lin';
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = nan;
                param = [nan nan];
                paramCI = [nan,nan;nan ,nan];
                fitevals = [nan nan nan];
            end
            
            
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype 'waves' str ]){i} = temp;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str 'fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str 'fitevals'])(i,:,1) = fitevals;
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
            x=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind));
            y =pooled_contactCaTrials_locdep{n}.(par)(NL_ind);
            fittype = 'lin';
            baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
            baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_ind,[1:baselinepts]);
            %             baselinevals = reshape(baselinevals,(size(baselinevals,1)*size(baselinevals,2)),1);
            noisethr = mean(prctile(baselinevals,99));
            
            [param,paramCI,fitevals,f] = FitEval(x,y,fittype,noisethr);
            temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype 'waves' str ]){i} = temp;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
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
            retract = find(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind) >0);
            protract =  find(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind)<0);
            
            
            plot(abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind(retract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(retract)),'o','color',[.85 .5 .5],'Markersize',7,'Markerfacecolor',[.85 .5 .5]); hold on;
            plot(abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind(protract))),pooled_contactCaTrials_locdep{n}.(par)(L_ind(protract)),'ro','Markersize',7, 'Markerfacecolor',[1 0 0]); hold on;
            set(gca,'ticklength',[.05 .05]);
            if fit_separate
                % separating protraction and retraction
                %protraction
                str = '_L_P';temp = [];
                x=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind(protract)));
                y =pooled_contactCaTrials_locdep{n}.(par)(L_ind(protract));
                fittype = 'lin';
                baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_ind(protract),[1:baselinepts]);
                %                 baselinevals = reshape(baselinevals,(size(baselinevals,1)*size(baselinevals,2)),1);
                noisethr = mean(prctile(baselinevals,99));
                
                if length(x) >2
                    fittype = 'lin';
                    [param,paramCI,fitevals,f] = FitEval(x,y,fittype,noisethr);
                    temp (:,1) = x;temp(:,2) = y;temp(:,3) = f;
                else
                    fittype = 'lin';
                    temp (:,1) = x;temp(:,2) = y;temp(:,3) = nan;
                    param = [nan nan];
                    paramCI = [nan,nan;nan ,nan];
                    fitevals = [nan nan nan];
                end
                
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype 'waves' str ]){i} = temp;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
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
                x=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind(retract)));
                y =pooled_contactCaTrials_locdep{n}.(par)(L_ind(retract));
                baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_ind(retract),[1:baselinepts]);
                %                 baselinevals = reshape(baselinevals,(size(baselinevals,1)*size(baselinevals,2)),1);
                noisethr = mean(prctile(baselinevals,99));
                if length(x) >2
                    fittype = 'lin';
                    [param,paramCI,fitevals,f] = FitEval(x,y,fittype,noisethr);
                    temp (:,1) = x;temp(:,2) = y;temp(:,3) = f;
                else
                    fittype = 'lin';
                    temp (:,1) = 0;temp(:,2) = 0;temp(:,3) = nan;
                    param = [nan nan];
                    paramCI = [nan,nan;nan ,nan];
                    fitevals = [nan nan nan];
                end
                
                
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype 'waves' str ]){i} = temp;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
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
                x=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind));
                y =pooled_contactCaTrials_locdep{n}.(par)(L_ind);
                baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_ind,[1:baselinepts]);
                %                 baselinevals = reshape(baselinevals,(size(baselinevals,1)*size(baselinevals,2)),1);
                noisethr = mean(prctile(baselinevals,99));
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x,y,fittype,noisethr);
                temp (:,1) = x;temp(:,2) = y; temp(:,3) = f;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype 'waves' str ]){i} = temp;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparam'])(i,:,1) = param;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitparamCI'])(i,:,:) = paramCI;
                pooled_contactCaTrials_locdep{n}.fit.(['Fit_' fittype par str '_fitevals'])(i,:,1) = fitevals;
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
       % has to be a column vector
        if size(pooled_contactCaTrials_locdep{n}.num_trials,2)>2
            pooled_contactCaTrials_locdep{n}.num_trials=pooled_contactCaTrials_locdep{n}.num_trials';
        end

        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i,:),2) >1)
            title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
            title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
        %         axis([0  mx+5 -50 my+100]);
        
        count = count+1;
        
        
        hline(30,'k:');
        hline(0,'k--');
        
%         plot([0.0001:.01:10],polyval(p_NL1(i,:,1) ,[0.0001:.01:10]),'k-','linewidth',2);hold on;set(gca,'ticklength',[.05 .05]);
        if fit_separate
            %             plot([0.0001:.01:10],polyval(p_NL1(i,:,2) ,[0.0001:.01:10]),'color',[.5 .5 .5 ],'linewidth',2);
        end
        
        %
        %         fsigm = @(param,xval) param(1)+(param(2)-param(1))./(1+10.^((param(3)-xval)*param(4)));
        %         plot([0.0001:.01:2.5],fsigm(p_NL2(i,:,1) ,[0.0001:.01:2.5]),'b-','linewidth',2);
        %         if fit_separate
        %             plot([0.0001:.01:2.5],fsigm(p_NL2(i,:,2) ,[0.0001:.01:2.5]),'color',[.5 .5 .85],'linewidth',2);
        %         end
        if ~isempty(L_ind)
            
%             plot([0.0001:.01:10],polyval(p_L1(i,:,1),[0.0001:.01:10]),'r-','linewidth',2);hold on;
            if fit_separate
                %                 plot([0.0001:.01:10],polyval(p_L1(i,:,2),[0.0001:.01:10]),'color',[.85 .5 .5],'linewidth',2);
            end
            %             plot([0.0001:.01:1.5],fsigm(pSig_L(i,:,1),[0.0001:.01:1.5]),'m-','linewidth',2);hold on;
            %             plot([0.0001:.01:1.5],fsigm(pSig_L(i,:,2),[0.0001:.01:1.5]),'color',[.85 .5 .85],'linewidth',2);
            
        end
        set(gca,'XMinorTick','on','XTick',[0.0001,0.001,0.01,.1,1]);
%         set(gca,'XMinorTick','on','XTick',[0.5:.5:2]);
        if strcmp(par,'sigmag')
            axis([1e-4 uL 0 5000]);
        elseif strcmp(par,'sigpeak')
            axis([1e-4 uL 0 500]);
        end
        set(gca,'xscale','log');set(gca,'ticklength',[.05 .05]);
%         set(gca,'xscale','linear')
    end
    
    theta_at_contact = pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean; %%% use ths for joint plot
    
    subplot(length(dends),numloc+xcol,count:count+1);
%     h= plot([1:numloc],p_NL1(:,1,1),'k-o'); set(h,'linewidth',3);hold on;
%     plot([1:numloc],p_NL1CIU(:,1,1),'k--','linewidth',2); plot([1:numloc],p_NL1CIL(:,1,1),'k--','linewidth',2);
%     set(gca,'ticklength',[.05 .05]);
    if (lpv == 'v2')
        LPI = (max(abs(p_NL1(1:end,1,1)))-min(abs(p_NL1(:,1,1))))/(max(abs(p_NL1(:,1,1)))+min(abs(p_NL1(:,1,1))));
        %     LPI_sp = (max(abs(p_NL1(2:end,1,1)))-mean(abs(p_NL1(:,1,1))))/(max(abs(p_NL1(:,1,1)))+mean(abs(p_NL1(:,1,1))));
    elseif (lpv == 'v1')
        LPI = max(abs(p_NL1(1:end,1,1)))/(mean(abs(p_NL1(:,1,1))));
        %     LPI_sp = (max(abs(p_NL1(2:end,1,1)))-mean(abs(p_NL1(:,1,1))))/(max(abs(p_NL1(:,1,1))));
    end
    LPI = round(LPI*100)./100;%LPI_sp = round(LPI_sp*100)./100;
    tb=text(3,max(p_NL1(:,1,1)) +100,['LPI ' num2str(LPI)],'FontSize',18);
    pooled_contactCaTrials_locdep{n}.LPI = LPI;
    %     pooled_contactCaTrials_locdep{n}.LPI_sp = LPI_sp;
    if fit_separate
        %         h= plot([1:numloc],p_NL1(:,1,2),'-o','color',[.5 .5 .5]); set(h,'linewidth',3);
        %         plot([1:numloc],p_NL1CIU(:,1,2),'--','color',[.5 .5 .5]); plot([1:numloc],p_NL1CIL(:,1,2),'--','color',[.5 .5 .5]);set(h,'linewidth',3);
    end
    
    if ~isempty(L_ind)
%         h= plot([1:numloc],p_L1(:,1,1),'r-o');set(h,'linewidth',1.5);hold on;
%         plot([1:numloc],p_L1CIU(:,1,1),'r--','linewidth',2); plot([1:numloc],p_L1CIL(:,1,1),'r--','linewidth',2);
%         set(gca,'ticklength',[.05 .05]);
        if(lpv == 'v1')
            LPI_l = (max(abs(p_L1(1:end,1,1))))/(mean(abs(p_L1(:,1,1))));
            %           LPI_sp_l = (max(abs(p_L1(2:end,1,1)))-mean(abs(p_L1(:,1,1))))/(max(abs(p_L1(:,1,1)))+mean(abs(p_L1(:,1,1))));
        elseif lpv== 'v2'
            LPI_l = (max(abs(p_L1(1:end,1,1)))-min(abs(p_L1(:,1,1))))/(max(abs(p_L1(:,1,1))));
            %           LPI_sp_l = (max(abs(p_L1(2:end,1,1)))-mean(abs(p_L1(:,1,1))))/(max(abs(p_L1(:,1,1))));
        end
        LPI_l = round(LPI_l*100)./100;%LPI_sp_l = round(LPI_sp_l*100)./100;
        pooled_contactCaTrials_locdep{n}.LPI_l = LPI_l;
        %                 pooled_contactCaTrials_locdep{n}.LPI_sp_l = LPI_sp_l;
        tb = text(4,max(p_NL1(:,1,1)) +100,['LPI_l ' num2str(LPI_l)],'FontSize',18);set(tb,'color','r');
        if fit_separate
            %             h= plot([1:numloc],p_L1(:,1,2),'-o','color',[.85, .5 , .5]);set(h,'linewidth',3);
        end
    end
    axis([0  numloc+1 -100  max(p_NL1(:,1,1))+200]);set(gca,'ticklength',[.05 .05]);
    
    
    
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
print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  Pnts reg temp D ' num2str(dends)]);
saveas(gcf,[' Loc Dep Pnts ' par ' reg  D ' num2str(dends)],'jpg');

if traces
    % h_fig2= figure('position', [1000, sc(4)/10-100, sc(3)*1/2.5, sc(4)*1], 'color','w');
    h_fig2= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
    set(h_fig2, 'Renderer', 'OpenGL'); % faster drawing
    h_fig3= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
end

if disp
    
    if fit_separate
        h_fig4= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
        % set(h_fig2, 'Renderer', 'OpenGL'); % faster drawing
        h_fig5= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
    else
        h_fig4= figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
    end
    
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
        
        
        colpL = othercolor('OrRd5',10);
        colp = othercolor('PuBu3',10);
        colrL = othercolor('Reds6',10);
        colr = othercolor('Greens6',10);
        
        for i = 1:numloc
            ts = [1:size(pooled_contactCaTrials_locdep{n}.rawdata,2)].*samp_time;
            NL_ind = find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==0));
            L_ind =  find(( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.lightstim ==1));
            
            retract = find(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind) >0);
            protract =  find(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind)<0);
            numtrials_NL_R = length(retract);
            numtrials_NL_P = length(protract);
            
            numtrials_NL = length(NL_ind);
            numtrials_L = length(L_ind);
            
            if(~isempty(retract))
                if traces
                    for r=1:length(retract)
                        %                 pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(retract(r)))
                        [ mval, colind] = min(abs(touchmag - abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(retract(r))))));
                        figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                        plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(retract(r)),:),'color',colr(colind,:),'linewidth',1.5); hold on;
                        set(gca,'ticklength',[.05 .05]);
                        %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                        %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(retract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{NL_ind(retract(r))},'color',colr(colind,:),'linewidth',.15); hold on;
                        %
                    end
                end
                if  fit_separate
                    figure(h_fig5); subplot(length(dends),numloc+xcol,count);
                    plot(ts,mean(pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(retract),:)),'color',[.5 .5 .5],'linewidth',1.5); hold on;
                    set(gca,'ticklength',[.05 .05]);
                end
            end
            
            if(~isempty(protract))
                if traces
                    for r=1:length(protract)
                        %                 pooled_contactCaTrials_locdep{n}.totalKappa_epoch(NL_ind(protract(r)))
                        [ mval, colind]=min(abs((touchmag - abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind(protract(r)))))));
                        figure(h_fig2); subplot(length(dends),numloc+xcol,count);
                        plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(protract(r)),:),'color',colp(colind,:),'linewidth',1.5);hold on;
                        set(gca,'ticklength',[.05 .05]);
                        %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                        %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(protract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{NL_ind(protract(r))},'color',colp(colind,:),'linewidth',.15); hold on;
                        
                    end
                end
                if fit_separate
                    figure(h_fig4); subplot(length(dends),numloc+xcol,count);
                    plot(ts,mean(pooled_contactCaTrials_locdep{n}.filtdata(NL_ind(protract),:)),'color',[0 0 0 ],'linewidth',1.5); hold on;
                    set(gca,'ticklength',[.05 .05]);
                end
            end
            
            if ~fit_separate
                figure(h_fig4); subplot(length(dends),numloc+xcol,count);
                plot(ts,mean(pooled_contactCaTrials_locdep{n}.filtdata(NL_ind,:)),'color',[0 0 0 ],'linewidth',1.5); hold on;
                set(gca,'ticklength',[.05 .05]);
            end
            retract = find(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind) >0);
            protract =  find(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind)<0);
            
            numtrials_L_R = length(retract);
            numtrials_L_P = length(protract);
            
            if(~isempty(retract))
                if traces
                    for r=1:length(retract)
                        [ mval, colind] = min(abs(touchmag - abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind(retract(r))))));
                        figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                        plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(retract(r)),:),'-','color',colrL(colind,:),'linewidth',1.5); hold on;
                        set(gca,'ticklength',[.05 .05]);
                        %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                        %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(retract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{L_ind(retract(r))},'color',col(colind,:),'linewidth',.15); hold on;
                        
                    end
                end
                if fit_separate
                    figure(h_fig5); subplot(length(dends),numloc+xcol,count);
                    plot(ts,mean(pooled_contactCaTrials_locdep{n}.filtdata(L_ind(retract),:)),'color',[.85 .5 .5],'linewidth',1.5); hold on;
                    set(gca,'ticklength',[.05 .05]);
                end
            end
            if(~isempty(protract))
                if traces
                    for r=1:length(protract)
                        [ mval, colind]=min(abs((touchmag - abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind(protract(r)))))));
                        figure(h_fig2); subplot(length(dends),numloc+xcol,count);
                        plot(ts,pooled_contactCaTrials_locdep{n}.filtdata(L_ind(protract(r)),:),'color',colpL(colind,:),'linewidth',1.5);
                        set(gca,'ticklength',[.05 .05]);
                        %                 figure(h_fig3); subplot(length(dends),numloc+xcol,count);
                        %                 plot(pooled_contactCaTrials_locdep{n}.timews{NL_ind(protract(r))},pooled_contactCaTrials_locdep{n}.touchdeltaKappa{L_ind(protract(r))},'color',col(colind,:),'linewidth',.15); hold on;
                        
                    end
                end
                if fit_separate
                    figure(h_fig4); subplot(length(dends),numloc+xcol,count);
                    plot(ts,mean(pooled_contactCaTrials_locdep{n}.filtdata(L_ind(protract),:)),'color',[1 0 0],'linewidth',1.5); hold on;
                    set(gca,'ticklength',[.05 .05]);
                end
            end
            
            if ~fit_separate
                figure(h_fig4); subplot(length(dends),numloc+xcol,count);
                plot(ts,mean(pooled_contactCaTrials_locdep{n}.filtdata(L_ind,:)),'color',[1 0 0],'linewidth',1.5); hold on;
                set(gca,'ticklength',[.05 .05]);
            end
            
            if traces
                figure(h_fig2);
                 ([0 2.5 0 600]);
                hline(30,'k.');
                hline(0,'k--');
                figure(h_fig3);
                axis([0 2.5 0 600]);
                hline(30,'k.');
                hline(0,'k--');
            end
            
            figure(h_fig4);
            axis([0 2.5 0 220]);
            hline(30,'k.');
            hline(0,'k--');
            if fit_separate
                figure(h_fig5);
                axis([0 2.5 0 150]);
                hline(30,'k.');
                hline(0,'k--');
            end
            set(gca,'ticklength',[.05 .05]);
            count = count+1;
            
            if(size(pooled_contactCaTrials_locdep{n}.num_trials(i,:),2) >1)
                if traces
                    figure(h_fig2);
                    title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(numtrials_NL_P) ' NL ' num2str(numtrials_L_P) ' L Prot' ]);
                    figure(h_fig3);
                    title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(numtrials_NL_R) ' NL ' num2str(numtrials_L_R) ' L Ret' ]);
                end
                figure(h_fig4);
                if fit_separate
                    title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(numtrials_NL_P) ' NL ' num2str(numtrials_L_P) ' L Prot' ]);
                    
                    figure(h_fig5);
                    title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(numtrials_NL_R) ' NL ' num2str(numtrials_L_R) ' L Ret' ]);
                else
                    title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(numtrials_NL) ' NL ' num2str(numtrials_L) ' L' ]);
                    
                end
            else
                if traces
                    figure(h_fig2);
                    title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(numtrials_NL_P) ' NL ']);
                    figure(h_fig3);
                    title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(numtrials_NL_R ) ' NL ']);
                end
                figure(h_fig4);
  
                if fit_separate
                    title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(numtrials_NL_P) ' NL ']);
                    figure(h_fig5);
                    title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(numtrials_NL_R ) ' NL ']);
                else
                     title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(numtrials_NL) ' NL ']);
                    
                end
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
end

if traces
    figure(h_fig2);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    % print( gcf ,'-depsc2','-painters','-loose',[' Loc Dep Ca Traces  D ' num2str(dends) 'Prot']);
    saveas(gcf,[' Loc Dep Ca Traces  D ' num2str(dends) 'Prot'],'jpg');
    % saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
    
    figure(h_fig3);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    % print( gcf ,'-depsc2','-painters','-loose',[' Loc Dep Ca Traces  D ' num2str(dends) 'Ret']);
    saveas(gcf,[' Loc Dep Ca Traces  D ' num2str(dends) 'Ret'],'jpg');
    % saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
end

if disp
    figure(h_fig4);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    if fit_separate
        print( gcf ,'-depsc2','-painters','-loose',[' Loc Dep Ca Avg Traces  D ' num2str(dends) 'Prot']);
        saveas(gcf,[' Loc Dep Ca Avg Traces  D ' num2str(dends) 'Prot'],'jpg');
    else
        print( gcf ,'-depsc2','-painters','-loose',[' Loc Dep Ca Avg Traces  D ' num2str(dends)]);
        saveas(gcf,[' Loc Dep Ca Avg Traces  D ' num2str(dends)],'jpg');
    end
    % saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
    if fit_separate
        figure(h_fig5);
        set(gcf,'PaperUnits','inches');
        set(gcf,'PaperPosition',[1 1 24 18]);
        set(gcf, 'PaperSize', [10,24]);
        set(gcf,'PaperPositionMode','manual');
        print( gcf ,'-depsc2','-painters','-loose',[' Loc Dep Ca Avg Traces  D ' num2str(dends) 'Ret']);
        saveas(gcf,[' Loc Dep Ca Avg Traces  D ' num2str(dends) 'Ret'],'jpg');
        % saveas(gcf,[' Theta Dep D ' num2str(dends)],'fig');
        
    end
end
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