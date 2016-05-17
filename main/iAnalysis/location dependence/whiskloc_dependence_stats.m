function [pooled_contactCaTrials_locdep]= whiskloc_dependence_stats(pooled_contactCaTrials_locdep,dends,wpar,capar,pos,traces,fit_separate)
load('/Users/ranganathang/Documents/MATLAB/universal/main/helper_funcs/mycmap3.mat');
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
if traces
    % h_fig2 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w'); % retract Ca
    h_fig3 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w'); % protract Ca
    
    % h_fig5 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w'); % protract dKa
end
count =1;
uL = 10;
lL=10e-3;
clc
for d=1:length(dends)
    n = dends(d);
    xcol =2;
    polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
    numloc = length(polelocs);
    a = 1;
    z = numloc;
    slopes = nan(numloc,4,2);
    slopesCI = nan(numloc,4,4);
    
    fittype = 'lin';
    if fit_separate
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_R_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_R_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_R_fitevals']) = nan(numloc,3,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_R_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_R_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_R_fitevals']) = nan(numloc,3,2);
        
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_P_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_P_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_P_fitevals']) = nan(numloc,3,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_P_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_P_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_P_fitevals']) = nan(numloc,3,2);
    else
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['NL_fitevals']) = nan(numloc,3,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_fitparam']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_fitparamCI']) = nan(numloc,2,2);
        pooled_contactCaTrials_locdep{n}.fitmean.(['L_fitevals']) = nan(numloc,3,2);
    end
    
    dKappa_bins=(logspace(-3,0,5));
%     dKappa_bins=(logspace(-4,1.5,10)); used first
    theta_at_touch = nan(numloc,2,2);
    for i = 1:numloc
        if fit_separate
            retract = (pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.(wpar) >0.00001);
            protract =  ( pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i))&(pooled_contactCaTrials_locdep{n}.(wpar) <-0.00001);
            
            retract_ind = find(retract==1);
            protract_ind = find(protract==1);
            
            NL_R_ind = find(retract==1 & pooled_contactCaTrials_locdep{n}.lightstim ==0);
            L_R_ind = find(retract==1 & pooled_contactCaTrials_locdep{n}.lightstim ==1);
            
            NL_P_ind = find(protract==1 & pooled_contactCaTrials_locdep{n}.lightstim ==0);
            L_P_ind = find(protract==1 & pooled_contactCaTrials_locdep{n}.lightstim ==1);
        else
            NL_ind = find((pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i)) & pooled_contactCaTrials_locdep{n}.lightstim ==0);
            L_ind = find((pooled_contactCaTrials_locdep{n}.poleloc == polelocs(i)) & pooled_contactCaTrials_locdep{n}.lightstim ==1);
        end
        
        % %  retract and prottract separately!        theta_at_loc = pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(
        
        if fit_separate
            str_all = {'NL_P','NL_R','L_P','L_R'};
        elseif ~isempty(L_ind)
            str_all = {'NL','L'};
        else
            str_all = {'NL'};
        end
        tatt=0;tattind = [0 0 ];
        for s = 1:length(str_all)
            str = str_all{s};
            switch str
                case 'NL'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(NL_ind);                    
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));                    
                    col = [0 0 0 ];
                    [y,sortiNL] = sort(ka,'descend');
                    tattind=[1 1]; % theta at touch ind
                    tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(NL_ind));
%                     if i ==1 tatt = -3.9062; end % for sess 156_150711
                case 'L'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(L_ind);
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));
                    col = [.85 0 0 ];
                    [y,sortiL] = sort(ka,'descend');
                    tattind=[2 1]; % theta at touch ind
                    tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(L_ind));
                case 'NL_R'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_R_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(NL_R_ind);
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_R_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));
                    col = [.5 .5 .5];
                    [y,sortiNLR] = sort(ka,'descend');
                    tattind=[1 2]; % theta at touch ind
                    tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(NL_R_ind));
                case 'NL_P'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(NL_P_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(NL_P_ind);
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_P_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));
                    col = [0 0 0 ];
                    [y,sortiNLP] = sort(ka,'descend');
                    tattind=[1 1]; % theta at touch ind
                    tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(NL_P_ind));
                case 'L_R'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_R_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(L_R_ind);
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_R_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));
                    col = [.85 .5 .5];
                    [y,sortiLR] = sort(ka,'descend');
                    tattind=[2 2]; % theta at touch ind
                    tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(L_R_ind));
                case 'L_P'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_P_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(L_P_ind);
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_P_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));
                    col = [.85 0 0 ];
                    [y,sortiLP] = sort(ka,'descend');
                    tattind=[2 1]; % theta at touch ind
                    tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(L_P_ind));
            end
            
            [h,edges,mid,l] = histcn(ka,dKappa_bins);
            for cn = 1: length(h)
                if (h(cn) >0)
                    ca_l_m(cn)  = nanmean(ca(find(l==cn)));
                    ca_l_sd(cn) = nanstd(ca(find(l==cn)))./sqrt(h(cn)+1);
                    ka_l_m(cn)  = nanmean(ka(find(l==cn)));
                    ka_l_sd(cn) = nanstd(ka(find(l==cn)))./sqrt(h(cn)+1);
                else
                    ca_l_m(cn)  =nan;
                    ca_l_sd(cn) = nan;
                    ka_l_m(cn)  = nan;
                    ka_l_sd(cn) = nan;
                end
            end
%             ca_l_m(9) = .2511 % fix for 158_150712 cell6
            figure(h_fig1);subplot(length(dends),numloc+xcol,count);
            if strcmp(str,'NL_P') | strcmp(str,'L_P')
%                 errorbar(mid{1},ca_l_m,ca_l_m-ca_l_sd,ca_l_m+ca_l_sd,'o-','color',col,'Markersize',7,'Markerfacecolor',col);
                    plot(mid{1},ca_l_m,'o-','color',col,'Markersize',7,'Markerfacecolor',col);set(gca,'ticklength',[.05 .05]);
            elseif strcmp(str,'NL') | strcmp(str,'L')
%                 errorbar(mid{1},ca_l_m,ca_l_m-ca_l_sd,ca_l_m+ca_l_sd,'o-','color',col,'Markersize',7,'Markerfacecolor',col);
                plot(mid{1},ca_l_m,'o-','color',col,'Markersize',7,'Markerfacecolor',col);set(gca,'ticklength',[.05 .05]);
            end
            hold on;
%             if i ==2 tatt = abs(tatt); end % for sess 157_150723

            pooled_contactCaTrials_locdep{n}.fitmean.([str '_theta_at_touch'])(i,tattind(1),tattind(2)) = tatt;
            if i ==1
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' capar]) =[];
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' capar])= [];
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' wpar]) = [];
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' wpar]) = [];
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' 'mid'])= {};
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' 'npts']) = [];
            end
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' capar])(:,i,1) = ca_l_m;
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' capar])(:,i,2) = ca_l_sd;
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' wpar])(:,i,1) = ka_l_m;
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' wpar])(:,i,2) = ka_l_sd;
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' 'mid'])(:,1) = mid;
            pooled_contactCaTrials_locdep{n}.fitmean.([ str '_' 'npts'])(:,1) = h;
           
%             pooled_contactCaTrials_locdep{n}.pointslope.([ str '_']){i} = ca./ka;
%             pooled_contactCaTrials_locdep{n}.pointslope.([ str '_mean'])(i,1) = nanmean(ca./ka);
%             pooled_contactCaTrials_locdep{n}.pointslope.([ str '_std'])(i,1) = nanstd(ca./ka);
            
            pooled_contactCaTrials_locdep{n}.pointslope.([ str '_B']){i} = ca_l_m./ ka_l_m;
            pooled_contactCaTrials_locdep{n}.pointslope.([ str '_meanB'])(i,1) = nanmean(ca_l_m./ ka_l_m);
            pooled_contactCaTrials_locdep{n}.pointslope.([ str '_stdB'])(i,1) = nanstd(ca_l_m./ ka_l_m);
            
            temp = [];
            notnan = ~isnan(ka_l_m);
            x=ka_l_m;
            y =ca_l_m;
            fittype = 'lin';
            if length(x(notnan)) >2
                fittype = 'lin';
                [param,paramCI,fitevals,f] = FitEval(x(notnan),y(notnan),fittype,-1);
                f_all = nan(size(x));f_all(notnan) = f;
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = f_all;
            else
                fittype = 'lin';
                temp (:,1) = x;temp(:,2) = y;temp(:,3) = nan;
                param = [nan nan];
                paramCI = [nan,nan;nan ,nan];
                fitevals = [nan nan nan];
            end
            
            pooled_contactCaTrials_locdep{n}.fitmean.([str '_fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.fitmean.([str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.fitmean.([str '_fitevals'])(i,:,1) = fitevals;
            
            if strcmp(str,'NL_P') | strcmp(str,'L_P')
                plot([0.0001:.01:max(ka_l_m)],polyval(param ,[0.0001:.01:max(ka_l_m)]),'-','color',col,'linewidth',2);set(gca,'ticklength',[.05 .05]);
            elseif strcmp(str,'NL') | strcmp(str,'L')
                plot([0.0001:.01:max(ka_l_m)],polyval(param ,[0.0001:.01:max(ka_l_m)]),'-','color',col,'linewidth',2);set(gca,'ticklength',[.05 .05]);
            end
            hold on;
            % s = nl ; l; or nl_p;nl_r;l_p;l_r; - these are the slopes_columns
            slopes(i,s,1) = param(1);slopes(i,s,2) = param(2); % param 1 is slope param 2 is intercept
            slopesCI (i,s,1) = paramCI(1);slopesCI (i,s,2) = paramCI(2);
            slopesCI (i,s,3) = paramCI(3);slopesCI (i,s,4) = paramCI(4);
        end
        
        if traces
            
            %         figure(h_fig2);subplot(length(dends),numloc+xcol,count);
            %         inds_all = [NL_R_ind(sortiNLR); L_R_ind(sortiLR)];
            %         imdata = pooled_contactCaTrials_locdep{n}.rawdata(inds_all,:);
            %         im_data_t = [1:size(imdata,2)].* pooled_contactCaTrials_locdep{n}.FrameTime;
            %         trials = [1:length(inds_all)];
            %         imagesc(im_data_t,trials,imdata); caxis([0,500]);colormap([1-gray])
            %         t=[1:15:0:length(inds_all)];
            %         set(gca,'YTick',t);
            %         set(gca,'YTickLabels',pooled_contactCaTrials_locdep{n}.re_totaldK(inds_all(t)));
            
            figure(h_fig3);subplot(length(dends),numloc+xcol,count);
            %         inds_all = [NL_P_ind(sortiNLP); L_P_ind(sortiLP)];
            if fit_separate
                inds_all = [NL_P_ind(sortiNLP); NL_R_ind(sortiNLR);L_P_ind(sortiLP);L_R_ind(sortiLR)];
            elseif ~isempty(L_ind)
%                 inds_all = [NL_ind(sortiNL);L_ind(sortiL)];
                inds_all = [NL_ind;L_ind];
            else
%                 inds_all = [NL_ind(sortiNL)];
                inds_all = [NL_ind]; % if just by order of trial
                
            end
            imdata = pooled_contactCaTrials_locdep{n}.rawdata(inds_all,:);
            im_data_t = [1:size(imdata,2)].* pooled_contactCaTrials_locdep{n}.FrameTime;
            trials = [1:length(inds_all)];
            imagesc(im_data_t,trials,imdata); caxis([0,350]);colormap(mycmap3);%colormap([1-gray]);
%             axis([0.25 2.0 0 length(NL_ind)])
            hline(length(NL_ind),'w-');
            t=[1,length(inds_all)];
            set(gca,'YTick',t);set(gca,'ticklength',[.05 .05]);
            %         set(gca,'YTickLabels',round(abs(pooled_contactCaTrials_locdep{n}.re_totaldK(inds_all(t)))*1000)./1000);
            % % %
            % % %         figure(h_fig5);subplot(length(dends),numloc+xcol,count);
            % % %         tda = cell2mat(pooled_contactCaTrials_locdep{1}.touchdeltaKappa(inds_all,:));
            % % %         notnan = find(~isnan(tda(1,:)));
            % % %         touchdata = tda(:,notnan);
            % % %         wsrate = 500;pxlpermm = 24.38;
            % % %         touchdata_t = [1:size(touchdata,2)].* (1/wsrate);
            % % %         trials = [1:length(inds_all)];
            % % %         imagesc(touchdata_t,trials,touchdata./pxlpermm); colormap([gray]);caxis([0,1]);
            % % %         t=[1,length(inds_all)];
            % % %         set(gca,'YTick',t);
            % % %         set(gca,'YTickLabels',pooled_contactCaTrials_locdep{n}.re_totaldK(inds_all(t)));
            % % %
            
            
            %         figure(h_fig2);
            %         if(size(pooled_contactCaTrials_locdep{n}.num_trials(i,:),2) >1)
            %             title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
            %         else
            %             title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
            %         end
            
        end
         if traces
        figure(h_fig3);
        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i,:),2) >1)
            title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  ' ' str ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
            title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' str ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
         end
        figure(h_fig1);
        if(size(pooled_contactCaTrials_locdep{n}.num_trials(i,:),2) >1)
            title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  ' ' str ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
        else
            title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' str ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
        end
        
        count = count+1;
        set(gca,'XMinorTick','on','XTick',[0.0001,0.001,0.01,.1,1,10]);
%         set(gca,'XMinorTick','on','XTick',[0.5:.5:2]);
        figure(h_fig1);
        if strcmp(capar,'sigpeak')
        axis([1e-4 uL 0 300]);
        elseif strcmp(capar,'sigmag')
            axis([1e-4 uL 0 6000]);
        end
        set(gca,'xscale','log');
%         set(gca,'xscale','linear');
    end
    
    %%
    figure(h_fig1);
    subplot(length(dends),numloc+xcol,count:count+1);
    if fit_separate
        str_all = {'NL_P','L_P'}; % fitting only protractions
    elseif ~isempty(L_ind)
        str_all = {'NL','L'};
    else
        str_all = {'NL'};
    end
    
    for s = 1:length(str_all)
        str = str_all{s};
        switch str
            case 'NL'
                slopes_column = 1;
                col = [0 0 0 ];
                tp = 3;
                 mR = pooled_contactCaTrials_locdep{n}.meanResp.NL;
            case 'L'
                slopes_column = 2;
                col = [.85 0 0 ];
                tp = 4;
                 mR = pooled_contactCaTrials_locdep{n}.meanResp.L;
                
            case 'NL_P'
                slopes_column = 1;
                col = [0 0 0 ];
                tp =3;
            case 'L_P'
                slopes_column = 3;
                col = [.85 0 0 ];
                tp = 4;
                
        end
        
        
        %     h= plot([1:numloc],slopes(:,1),'--o','color',[.5 .5 .5]); set(h,'linewidth',3);hold on; % Ret
        h= plot([1:numloc],slopes(:,slopes_column,1)./nanmean(slopes(:,1,1)),'--o','color',col,'linewidth',2); hold on;set(gca,'ticklength',[.05 .05]); % Prot
        hold on;
        mR_n= mR./mean(pooled_contactCaTrials_locdep{n}.meanResp.NL);
         h= plot([1:numloc],mR_n,'-o','color',col,'linewidth',2); hold on;set(gca,'ticklength',[.05 .05]); % Prot
         pntslp = pooled_contactCaTrials_locdep{n}.pointslope.([ str '_meanB'])(:,1); 
         pntslpctrl=  pooled_contactCaTrials_locdep{n}.pointslope.(['NL_meanB'])(:,1); 
%          plot([1:numloc],pntslp(:,1)./mean(pntslpctrl(:,1)),'-o','color',col,'linewidth',2);
%         plot([1:numloc],slopesCI(:,slopes_column,1)./mean(slopes(:,1,1)),'--o','color',col);  plot([1:numloc],slopesCI(:,slopes_column,2)./mean(slopes(:,1,1)),'k--o','color',col); %(normalizing wrt ctrl)
        %     LPI = (max(abs(e(:,2)))-min(abs(slopes(:,2))))/(max(abs(slopes(:,2)))+min(abs(slopes(:,2))));
        LPI = nanmax(abs(slopes(:,slopes_column,1)))/(nanmean(abs(slopes(:,slopes_column,1))));
        LPI_diff = nanmax(abs(slopes(:,slopes_column,1)))-(nanmin(abs(slopes(:,slopes_column,1))));
        [v,LP] = nanmax(abs(slopes(:,slopes_column,1)));
%         LPI2 = max(abs(slopes(:,slopes_column,1)))/(mean(abs(slopes(:,slopes_column,1))));
        
        
        LPI = round(LPI*100)./100; LPI_diff = round(LPI_diff*100)./100;
%         tb=text(tp,LPI+1,['LPI_d ' num2str(LPI_diff)],'FontSize',18);set(tb,'color',col);
        if strcmp(str,'NL')
           lpinorm = nanmax(slopes(:,slopes_column,1)./nanmean(slopes(:,1,1)));
           pslnorm = nanmax(pntslp(:,1))./nanmean(pntslp(:,1));           
            LPI_mR = nanmax(mR_n);
        elseif strcmp(str,'L')
            [ctrlnormslope,ctrllp] = nanmax( slopes(:,1,1)./nanmean(slopes(:,1,1)));
            tempw=slopes(:,slopes_column,1)./nanmean(slopes(:,1,1));
            lpinorm = nanmax(tempw);
%             lpinorm = tempw(ctrllp); %at lp of ctrl
            pslnorm = nanmax(pntslp(:,1))./nanmean(pntslpctrl(:,1));
            LPI_mR = nanmax(mR_n);
        end
        lpinorm=round(lpinorm*100)./100;
        pslpnorm = round(pslnorm*100)./100;
        tb=text(tp-1,tp-1.5,['FS' num2str(lpinorm)],'FontSize',14);set(tb,'color',col);
        tb=text(tp-1,tp-1.2,['mRS' num2str(LPI_mR)],'FontSize',14);set(tb,'color',col);
%         tb=text(tp-1,tp+.5,['PS' num2str(pslpnorm)],'FontSize',14);set(tb,'color',col);
        pooled_contactCaTrials_locdep{n}.fitmean.([str '_LPI']) = LPI;
        pooled_contactCaTrials_locdep{n}.pointslope.([str '_LPI']) = pslpnorm;
        pooled_contactCaTrials_locdep{n}.fitmean.([str '_LPI_diff']) = LPI_diff;
        pooled_contactCaTrials_locdep{n}.fitmean.([str '_LP_pos']) = pos(LP);
        tatt_all =  pooled_contactCaTrials_locdep{n}.fitmean.([str '_theta_at_touch']);
        pooled_contactCaTrials_locdep{n}.fitmean.([str '_Pref_thetaattouch']) =  tatt_all(LP,:);
        % % % % % % % % % %     if ~isempty(L_P_ind)
        % % % % % % % % % %         %         plot([1:numloc],slopes(:,3),'--o','color',[.85 .5 .5]); set(h,'linewidth',3);hold on; % Ret
        % % % % % % % % % %         %         plot([1:numloc],slopesCI(:,3,1),'--o','color',[.85 .5 .5]);  plot([1:numloc],slopesCI(:,3,2),'--o','color',[.85 .5 .5]);
        % % % % % % % % % %         plot([1:numloc],slopes(:,4),'r--o','linewidth',2); % Prot
        % % % % % % % % % %         plot([1:numloc],slopesCI(:,4,1),'r--o','color',[0 0 0 ]);  plot([1:numloc],slopesCI(:,4,2),'r--o','color',[0 0 0]);
        % % % % % % % % % %         LPI_l = (max(abs(slopes(1:end,4)))-mean(abs(slopes(:,1,1))))%/(max(abs(slopes(:,4)))+min(abs(slopes(:,4))));
        % % % % % % % % % %         LPI_l = round(LPI_l*100)./100;
        % % % % % % % % % %         pooled_contactCaTrials_locdep{n}.fitmean.LPI_l = LPI_l;
        % % % % % % % % % %         pooled_contactCaTrials_locdep{n}.fitmean.LPI_sp_l = LPI_sp_l;
        % % % % % % % % % %         tb = text(4,max(slopes(:,1,1)) +100,['LPI_l ' num2str(LPI_l)],'FontSize',18);set(tb,'color','r');
        % % % % % % % % % %
        % % % % % % % % % %     end
        pooled_contactCaTrials_locdep{n}.fitmean.([str 'slopes']) =slopes(:,slopes_column,:);
    end
    
    %     axis([0  numloc+1 -100  max(slopes(:,2))+200]);
    axis([1  numloc 0 3]);set(gca,'ticklength',[.05 .05]);
    hline(0,'k:'); hline(1,'b:');
    title( ' slopes');
    
    count = count+2;
end
figure(h_fig1);
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  reg temp D ' num2str(dends)]);
saveas(gcf,[' Loc Dep  ' capar ' reg  D ' num2str(dends)],'jpg');
saveas(gcf,[' Loc Dep  ' capar ' reg  D ' num2str(dends)],'fig');
%
% figure(h_fig2);
% set(gcf,'PaperUnits','inches');
% set(gcf,'PaperPosition',[1 1 24 18]);
% set(gcf, 'PaperSize', [10,24]);
% set(gcf,'PaperPositionMode','manual');
% % print( gcf ,'-depsc2','-painters','-loose',[' Sorted Ret Trials reg temp D ' num2str(dends)]);
% saveas(gcf,['Sorted Ret Trials ' capar ' reg  D ' num2str(dends)],'jpg');

if  traces
    figure(h_fig3);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    print( gcf ,'-depsc2','-painters','-loose',[' Sorted Prot Trials reg temp D ' num2str(dends)]);
    saveas(gcf,['Sorted Prot Trials '  ' reg  D ' num2str(dends)],'jpg');
end

% answer=inputdlg('Filename','Filename',1,'');
%
% save([answer '_' 'pooled_contactCaTrials_locdep_fitmean'],'pooled_contactCaTrials_locdep');
end
