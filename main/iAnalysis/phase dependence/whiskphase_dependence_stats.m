function [pooled_contactCaTrials_locdep]= whiskphase_dependence_stats(pooled_contactCaTrials_locdep,dends,traces,light)
wpar = 're_totaldK';
capar = 'sigpeak';
load('/Users/ranganathang/Documents/MATLAB/universal/main/helper_funcs/mycmap3.mat');
sc = get(0,'ScreenSize');
h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
if traces
    h_fig3 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w'); % protract Ca
end
count =1;
uL = 10;
lL=10e-3;

for d=1:length(dends)
    n = dends(d);
    xcol =2;
    touchPhases = unique(pooled_contactCaTrials_locdep{n}.phase.touchPhase_binned);
    numph = length(touchPhases);
    a = 1;
    z = numph;
    slopes = nan(numph,4,2);
    slopesCI = nan(numph,4,4);
    
        pooled_contactCaTrials_locdep{n}.phase.fit.(['NL_fitparam']) = nan(numph,2,2);
        pooled_contactCaTrials_locdep{n}.phase.fit.(['NL_fitparamCI']) = nan(numph,2,2);
        pooled_contactCaTrials_locdep{n}.phase.fit.(['NL_fitevals']) = nan(numph,3,2);
        pooled_contactCaTrials_locdep{n}.phase.fit.(['L_fitparam']) = nan(numph,2,2);
        pooled_contactCaTrials_locdep{n}.phase.fit.(['L_fitparamCI']) = nan(numph,2,2);
        pooled_contactCaTrials_locdep{n}.phase.fit.(['L_fitevals']) = nan(numph,3,2);

    
    dKappa_bins=(logspace(-3,0,5));
%     dKappa_bins=(logspace(-4,1.5,10)); used first
    theta_at_touch = nan(numph,2,2);
    for i = 1:numph
            phase_bins = linspace(-pi,pi,6);
            touchPhase =  pooled_contactCaTrials_locdep{1}.touchPhase;
            [num edges mid id] = histcn(touchPhase,phase_bins);
            pooled_contactCaTrials_locdep{n}.phase.touchPhase_binned = mid{1}(id)';
            NL_ind = find((pooled_contactCaTrials_locdep{n}.phase.touchPhase_binned == touchPhases(i)) & pooled_contactCaTrials_locdep{n}.lightstim ==0);
            L_ind = find((pooled_contactCaTrials_locdep{n}.phase.touchPhase_binned == touchPhases(i)) & pooled_contactCaTrials_locdep{n}.lightstim ==1);


        if ~isempty(L_ind)
            str_all = {'NL','L'};
        else
            str_all = {'NL'};
        end
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
                    numtrials_NL=length(ka);
                    
                case 'L'
                    ka=abs(pooled_contactCaTrials_locdep{n}.(wpar)(L_ind));
                    ca=pooled_contactCaTrials_locdep{n}.(capar)(L_ind);
                    baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
                    baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_ind,[1:baselinepts]);
                    noisethr = mean(prctile(baselinevals,99));
                    col = [.85 0 0 ];
                    [y,sortiL] = sort(ka,'descend');   
                    numtrials_L=length(ka);
            end
            
            [h,edges,mid,l] = histcn(ka,dKappa_bins);
            for cn = 1: length(h)
                if (h(cn) > 0)
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
%             ca_l_m(9) = .2511 % fix fo2 158_150712 cell6
            figure(h_fig1);subplot(length(dends),numph+xcol,count);

            if strcmp(str,'NL') | strcmp(str,'L')
%                 errorbar(mid{1},ca_l_m,ca_l_m-ca_l_sd,ca_l_m+ca_l_sd,'o-','color',col,'Markersize',7,'Markerfacecolor',col);
                plot(mid{1},ca_l_m,'o-','color',col,'Markersize',7,'Markerfacecolor',col);set(gca,'ticklength',[.05 .05]);
            end
            hold on;

            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' capar]) =[];
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' capar])= [];
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' wpar]) = [];
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' wpar]) = [];
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' 'mid'])= {};
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' 'npts']) = [];
            
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' capar])(:,i,1) = ca_l_m;
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' capar])(:,i,2) = ca_l_sd;
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' wpar])(:,i,1) = ka_l_m;
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' wpar])(:,i,2) = ka_l_sd;
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' 'mid'])(:,1) = mid;
            pooled_contactCaTrials_locdep{n}.phase.fit.([ str '_' 'npts'])(:,1) = h;
         
            temp = [];
            notnan = ~isnan(ka_l_m);
            x=ka_l_m;
            y =ca_l_m;

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
            
            pooled_contactCaTrials_locdep{n}.phase.fit.([str '_fitparam'])(i,:,1) = param;
            pooled_contactCaTrials_locdep{n}.phase.fit.([str '_fitparamCI'])(i,:,:) = paramCI;
            pooled_contactCaTrials_locdep{n}.phase.fit.([str '_fitevals'])(i,:,1) = fitevals;
            

            if strcmp(str,'NL') | strcmp(str,'L')
                plot([0.0001:.01:max(ka_l_m)],polyval(param ,[0.0001:.01:max(ka_l_m)]),'-','color',col,'linewidth',2);set(gca,'ticklength',[.05 .05]);
            end
            hold on;
            slopes(i,s,1) = param(1);slopes(i,s,2) = param(2); % param 1 is slope param 2 is intercept
            slopesCI (i,s,1) = paramCI(1);slopesCI (i,s,2) = paramCI(2);
            slopesCI (i,s,3) = paramCI(3);slopesCI (i,s,4) = paramCI(4);
        end
        
        if traces

            figure(h_fig3);subplot(length(dends),numph+xcol,count);

            if ~isempty(L_ind)
                inds_all = [NL_ind;L_ind];
            else
                inds_all = [NL_ind]; % if just by order of trial                
            end
            imdata = pooled_contactCaTrials_locdep{n}.rawdata(inds_all,:);
            im_data_t = [1:size(imdata,2)].* pooled_contactCaTrials_locdep{n}.FrameTime;
            trials = [1:length(inds_all)];
            imagesc(im_data_t,trials,imdata); caxis([0,350]);colormap(mycmap3);%colormap([1-gray]);
            hline(length(NL_ind),'w-');
            t=[1,length(inds_all)];
            set(gca,'YTick',t);set(gca,'ticklength',[.05 .05]);

        end
         if traces
        figure(h_fig3);
        if(light)
            title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  ' ' str ' ' num2str(numtrials_NL) ' NL ' num2str(numtrials_L) ' L ' ]);
        else
            title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' str ' ' num2str(numtrials_NL) ' NL ']);
        end
         end
        figure(h_fig1);
        if(light)
            title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  ' ' str ' ' num2str(numtrials_NL) ' NL ' num2str(numtrials_L) ' L ' ]);
        else
            title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' str ' ' num2str(numtrials_NL) ' NL ']);
        end
        
        count = count+1;
        set(gca,'XMinorTick','on','XTick',[0.0001,0.001,0.01,.1,1,10]);
        figure(h_fig1);

        axis([1e-4 uL 0 300]);

        set(gca,'xscale','log');

    end
    
    %%
    figure(h_fig1);
    subplot(length(dends),numph+xcol,count:count+1);

   if ~isempty(L_ind)
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
                 mR = pooled_contactCaTrials_locdep{n}.phase.mResp_NL;
            case 'L'
                slopes_column = 2;
                col = [.85 0 0 ];
                tp = 4;
                 mR = pooled_contactCaTrials_locdep{n}.phase.mResp_L;
        end
        
        h= plot([1:numph],slopes(:,slopes_column,1)./nanmean(slopes(:,1,1)),'--o','color',col,'linewidth',2); hold on;set(gca,'ticklength',[.05 .05]); % Prot
        hold on;
        mR_n= mR./mean(pooled_contactCaTrials_locdep{n}.phase.mResp_NL);
         h= plot([1:numph],mR_n,'-o','color',col,'linewidth',2); hold on;set(gca,'ticklength',[.05 .05]); % Prot

        PPI = nanmax(abs(slopes(:,slopes_column,1)))/(nanmean(abs(slopes(:,slopes_column,1))));        
        [v,PP] = nanmax(abs(slopes(:,slopes_column,1)));

        PPI = round(PPI*100)./100; 
        if strcmp(str,'NL')
           ppinorm = nanmax(slopes(:,slopes_column,1)./nanmean(slopes(:,1,1)));
           PPI_mR = nanmax(mR_n);
        elseif strcmp(str,'L')
            [ctrlnormslope,ctrllp] = nanmax( slopes(:,1,1)./nanmean(slopes(:,1,1)));
            tempw=slopes(:,slopes_column,1)./nanmean(slopes(:,1,1));
            ppinorm = nanmax(tempw);
            PPI_mR = nanmax(mR_n);
        end
        ppinorm=round(ppinorm*100)./100;
        tb=text(tp-1,tp-1.5,['FS' num2str(ppinorm)],'FontSize',14);set(tb,'color',col);
        tb=text(tp-1,tp-1.2,['mRS' num2str(PPI_mR)],'FontSize',14);set(tb,'color',col);
        pooled_contactCaTrials_locdep{n}.phase.fit.([str '_PPI']) = PPI;
        pooled_contactCaTrials_locdep{n}.phase.fit.([str '_Phase']) = pooled_contactCaTrials_locdep{n}.phase.touchPhase_mid;
        pooled_contactCaTrials_locdep{n}.phase.fit.([str '_PPh']) = pooled_contactCaTrials_locdep{n}.phase.touchPhase_mid(PP);
        pooled_contactCaTrials_locdep{n}.phase.fit.([str 'slopes']) =slopes(:,slopes_column,:);
    end
    
    axis([1  numph 0 3]);set(gca,'ticklength',[.05 .05]);
    hline(0,'k:'); hline(1,'b:');
    title( ' slopes');   
    count = count+2;
end
figure(h_fig1);
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 24 18]);
set(gcf, 'PaperSize', [10,24]);
set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',[' Phase Dep D ' num2str(dends)]);
saveas(gcf,[' Phase Dep D ' num2str(dends)],'jpg');


if  traces
    figure(h_fig3);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 24 18]);
    set(gcf, 'PaperSize', [10,24]);
    set(gcf,'PaperPositionMode','manual');
    print( gcf ,'-depsc2','-painters','-loose',[' Sorted Prot Trials reg temp D ' num2str(dends)]);
    saveas(gcf,['Sorted Prot Trials '  ' reg  D ' num2str(dends)],'jpg');
end

end
