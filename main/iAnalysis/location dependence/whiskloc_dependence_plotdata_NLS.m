function [pooled_contactCaTrials_locdep] = whiskloc_dependence_plotdata_NLS(pooled_contactCaTrials_locdep,dends,par,wpar,traces,disp,locs,locbins)
%% obj, dends, par = 'sigpeak' or 'sigmag', wpar = ' re_totaldK', fit_separate = 1 (prot and ret separately',

% sc = get(0,'ScreenSize');
% h_fig1 = figure('position', [1000, sc(4), sc(3), sc(4)], 'color','w');
% count =1;
% uL=1.5;
% for d=1:length(dends)
%     n = dends(d);
%     xcol =2;
%     polelocs = unique(pooled_contactCaTrials_locdep{n}.poleloc);
%     numloc =length(polelocs);
%     a = 1;
%     z = numloc;
%     p_NL1 =zeros(numloc,2,2);p_L1 =zeros(numloc,2,2);
%     p_NL2 =zeros(numloc,4,2);p_L2 =zeros(numloc,4,2);
%     sig_kappa_L = zeros(numloc,3,2);
%     sig_kappa_NL = zeros(numloc,3,2);
%     
%     for i = 1:numloc
%         NL_ind = find(( pooled_contactCaTrials_locdep{n}.decoder.NLS.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.decoder.NLS.lightstim ==0));
%         L_ind =  find(( pooled_contactCaTrials_locdep{n}.decoder.NLS.poleloc == polelocs(i))& (pooled_contactCaTrials_locdep{n}.decoder.NLS.lightstim ==1));
%         subplot(length(dends),numloc+xcol,count);
%         
%         retract = find(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(NL_ind) >0);
%         protract =  find(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(NL_ind) <0);
%         
%         plot(abs(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(NL_ind(retract))),pooled_contactCaTrials_locdep{n}.decoder.NLS.(par)(NL_ind(retract)),'o','color',[.5 .5 .5],'Markersize',7,'Markerfacecolor',[.5 .5 .5]); hold on;
%         plot(abs(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(NL_ind(protract))),pooled_contactCaTrials_locdep{n}.decoder.NLS.(par)(NL_ind(protract)),'ko','Markersize',7, 'Markerfacecolor',[0 0 0]); hold on;
%         set(gca,'ticklength',[.05 .05]);
%         
%         
%         if ~isempty(L_ind)
%             % Light trials
%             retract = find(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(L_ind) >0);
%             protract =  find(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(L_ind)<0);
%             
%             
%             plot(abs(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(L_ind(retract))),pooled_contactCaTrials_locdep{n}.decoder.NLS.(par)(L_ind(retract)),'o','color',[.85 .5 .5],'Markersize',7,'Markerfacecolor',[.85 .5 .5]); hold on;
%             plot(abs(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(L_ind(protract))),pooled_contactCaTrials_locdep{n}.decoder.NLS.(par)(L_ind(protract)),'ro','Markersize',7, 'Markerfacecolor',[1 0 0]); hold on;
%             set(gca,'ticklength',[.05 .05]);
%             
%         end
%         
%         if size(pooled_contactCaTrials_locdep{n}.num_trials,2)>2
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.num_trials=pooled_contactCaTrials_locdep{n}.num_trials';
%         end
%         
%         if(size(pooled_contactCaTrials_locdep{n}.num_trials(i,:),2) >1)
%             title([ ' ' num2str(n)   ' D ' num2str(pooled_contactCaTrials_locdep{n}.dend)  '  ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,2)) ' L ' ]);
%         else
%             title([ ' ' num2str(n) ' D '  num2str(pooled_contactCaTrials_locdep{n}.dend) ' ' num2str(pooled_contactCaTrials_locdep{n}.num_trials(i,1)) ' NL ']);
%         end
%         
%         count = count+1;
%         
%         
%         hline(30,'k:');
%         hline(0,'k--');
%         
%         
%         set(gca,'XMinorTick','on','XTick',[0.0001,0.001,0.01,.1,1],'Tickdir','out');
%         if strcmp(par,'sigmag')
%             axis([1e-4 uL 0 5000]);
%         elseif strcmp(par,'sigpeak')
%             axis([1e-4 uL 0 600]);
%         end
%         set(gca,'xscale','log');set(gca,'ticklength',[.05 .05]);
%         
%     end
%     
%     theta_at_contact = pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean; %%% use ths for joint plot
%     
%     subplot(length(dends),numloc+xcol,count:count+1);
%     
%     LPI = max(abs(p_NL1(1:end,1,1)))/(mean(abs(p_NL1(:,1,1))));
%     
%     LPI = round(LPI*100)./100;%LPI_sp = round(LPI_sp*100)./100;
%     tb=text(3,max(p_NL1(:,1,1)) +100,['LPI ' num2str(LPI)],'FontSize',18);
%     pooled_contactCaTrials_locdep{n}.decoder.NLS.LPI = LPI;
%     
%     if ~isempty(L_ind)
%         
%         LPI_l = (max(abs(p_L1(1:end,1,1))))/(mean(abs(p_L1(:,1,1))));
%         
%         LPI_l = round(LPI_l*100)./100;%LPI_sp_l = round(LPI_sp_l*100)./100;
%         pooled_contactCaTrials_locdep{n}.LPI_l = LPI_l;
%         tb = text(4,max(p_NL1(:,1,1)) +100,['LPI_l ' num2str(LPI_l)],'FontSize',18);set(tb,'color','r');
%     end
%     axis([0  numloc+1 -100  max(p_NL1(:,1,1))+200]);set(gca,'ticklength',[.05 .05]);
%     
%     
%     hline(0,'k:');
%     title( ' slopes');
%     
%     count = count+2;
% end
% set(gcf,'PaperUnits','inches');
% set(gcf,'PaperPosition',[1 1 24 18]);
% set(gcf, 'PaperSize', [10,24]);
% set(gcf,'PaperPositionMode','manual');
% print( gcf ,'-depsc2','-painters','-loose',[' Theta Dep  Pnts reg temp D ' num2str(dends)]);
% saveas(gcf,[' Loc Dep Pnts ' par ' reg  D ' num2str(dends)],'jpg');
%% whisk_locdep_stats

% count =1;
% 
% for d=1:length(dends)
%     n = dends(d);
%     xcol =2;
%     polelocs = unique(pooled_contactCaTrials_locdep{n}.decoder.NLS.poleloc);
%     numloc = length(polelocs);
%     a = 1;
%     z = numloc;
%     slopes = nan(numloc,4,2);
%     slopesCI = nan(numloc,4,4);
%     
%     fittype = 'lin';
% 
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.(['NL_fitparam']) = nan(numloc,2,2);
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.(['NL_fitparamCI']) = nan(numloc,2,2);
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.(['NL_fitevals']) = nan(numloc,3,2);
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.(['L_fitparam']) = nan(numloc,2,2);
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.(['L_fitparamCI']) = nan(numloc,2,2);
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.(['L_fitevals']) = nan(numloc,3,2);
% 
%     dKappa_bins=(logspace(-3,0,5));
% 
%     theta_at_touch = nan(numloc,2,2);
%     for i = 1:numloc
% 
%             NL_ind = find((pooled_contactCaTrials_locdep{n}.decoder.NLS.poleloc == polelocs(i)) & pooled_contactCaTrials_locdep{n}.decoder.NLS.lightstim ==0);
%             L_ind = find((pooled_contactCaTrials_locdep{n}.decoder.NLS.poleloc == polelocs(i)) & pooled_contactCaTrials_locdep{n}.decoder.NLS.lightstim ==1);
% 
% 
%       if ~isempty(L_ind)
%             str_all = {'NL','L'};
%         else
%             str_all = {'NL'};
%       end
%         tatt=0;tattind = [0 0 ];
%         for s = 1:length(str_all)
%             str = str_all{s};
%             switch str
%                 case 'NL'
%                     ka=abs(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(NL_ind));
%                     ca=pooled_contactCaTrials_locdep{n}.decoder.NLS.(par)(NL_ind);                    
% %                     baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
% %                     baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(NL_ind,[1:baselinepts]);
%                     noisethr = 30;% mean(prctile(baselinevals,99));                    
%                     col = [0 0 0 ];
%                     [y,sortiNL] = sort(ka,'descend');
%                     tattind=[1 1]; % theta at touch ind
%                     tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(NL_ind));
% %                     if i ==1 tatt = -3.9062; end % for sess 156_150711
%                 case 'L'
%                     ka=abs(pooled_contactCaTrials_locdep{n}.decoder.NLS.(wpar)(L_ind));
%                     ca=pooled_contactCaTrials_locdep{n}.decoder.NLS.(par)(L_ind);
% %                     baselinepts = floor(0.25./pooled_contactCaTrials_locdep{n}.FrameTime);
% %                     baselinevals = pooled_contactCaTrials_locdep{n}.filtdata(L_ind,[1:baselinepts]);
%                     noisethr = 30%mean(prctile(baselinevals,99));
%                     col = [.85 0 0 ];
%                     [y,sortiL] = sort(ka,'descend');
%                     tattind=[2 1]; % theta at touch ind
%                     tatt = mean(pooled_contactCaTrials_locdep{n}.Theta_at_contact_Mean(L_ind));                
%             end
%             
%             [h,edges,mid,l] = histcn(ka,dKappa_bins);
%             for cn = 1: length(h)
%                 if (h(cn) > 1)
%                     ca_l_m(cn)  = nanmean(ca(find(l==cn)));
%                     ca_l_sd(cn) = nanstd(ca(find(l==cn)))./sqrt(h(cn)+1);
%                     ka_l_m(cn)  = nanmean(ka(find(l==cn)));
%                     ka_l_sd(cn) = nanstd(ka(find(l==cn)))./sqrt(h(cn)+1);
%                 else
%                     ca_l_m(cn)  =nan;
%                     ca_l_sd(cn) = nan;
%                     ka_l_m(cn)  = nan;
%                     ka_l_sd(cn) = nan;
%                 end
%             end
% 
% 
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_theta_at_touch'])(i,tattind(1),tattind(2)) = tatt;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' par]) =[];
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' par])= [];
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' wpar]) = [];
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' wpar]) = [];
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' 'mid'])= {};
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' 'npts']) = [];
%             
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' par])(:,i,1) = ca_l_m;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' par])(:,i,2) = ca_l_sd;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' wpar])(:,i,1) = ka_l_m;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' wpar])(:,i,2) = ka_l_sd;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' 'mid'])(:,1) = mid;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([ str '_' 'npts'])(:,1) = h;
%            
%              pooled_contactCaTrials_locdep{n}.decoder.NLS.pointslope.([ str '_B']){i} = ca_l_m./ ka_l_m;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.pointslope.([ str '_meanB'])(i,1) = nanmean(ca_l_m./ ka_l_m);
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.pointslope.([ str '_stdB'])(i,1) = nanstd(ca_l_m./ ka_l_m);
%             
%             temp = [];
%             notnan = ~isnan(ka_l_m);
%             x=ka_l_m;
%             y =ca_l_m;
%             fittype = 'lin';
%             if length(x(notnan)) >2
%                 fittype = 'lin';
%                 [param,paramCI,fitevals,f] = FitEval(x(notnan),y(notnan),fittype,-1);
%                 f_all = nan(size(x));f_all(notnan) = f;
%                 temp (:,1) = x;temp(:,2) = y;temp(:,3) = f_all;
%             else
%                 fittype = 'lin';
%                 temp (:,1) = x;temp(:,2) = y;temp(:,3) = nan;
%                 param = [nan nan];
%                 paramCI = [nan,nan;nan ,nan];
%                 fitevals = [nan nan nan];
%             end
%             
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_fitparam'])(i,:,1) = param;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_fitparamCI'])(i,:,:) = paramCI;
%             pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_fitevals'])(i,:,1) = fitevals;
% 
%             slopes(i,s,1) = param(1);slopes(i,s,2) = param(2); % param 1 is slope param 2 is intercept
%             slopesCI (i,s,1) = paramCI(1);slopesCI (i,s,2) = paramCI(2);
%             slopesCI (i,s,3) = paramCI(3);slopesCI (i,s,4) = paramCI(4);
%         end
% 
%     end
%     
%     %%
%     if ~isempty(L_ind)
%         str_all = {'NL','L'};
%     else
%         str_all = {'NL'};
%     end
%     
%     for s = 1:length(str_all)
%         str = str_all{s};
%         switch str
%             case 'NL'
%                 slopes_column = 1;
%                 col = [0 0 0 ];
%                 tp = 3;
%                  mR = pooled_contactCaTrials_locdep{n}.meanResp.NL;
%             case 'L'
%                 slopes_column = 2;
%                 col = [.85 0 0 ];
%                 tp = 4;
%                  mR = pooled_contactCaTrials_locdep{n}.meanResp.L;
%         end
%  
%         mR_n= mR./mean(pooled_contactCaTrials_locdep{n}.meanResp.NL);
%          pntslp = pooled_contactCaTrials_locdep{n}.pointslope.([ str '_meanB'])(:,1); 
%          pntslpctrl=  pooled_contactCaTrials_locdep{n}.pointslope.(['NL_meanB'])(:,1); 
%         LPI = nanmax(abs(slopes(:,slopes_column,1)))/(nanmean(abs(slopes(:,slopes_column,1))));
%         LPI_diff = nanmax(abs(slopes(:,slopes_column,1)))-(nanmin(abs(slopes(:,slopes_column,1))));
%         [v,LP] = nanmax(abs(slopes(:,slopes_column,1)));
% 
%         LPI = round(LPI*100)./100; LPI_diff = round(LPI_diff*100)./100;
%         if strcmp(str,'NL')
%            lpinorm = nanmax(slopes(:,slopes_column,1)./nanmean(slopes(:,1,1)));
%            pslnorm = nanmax(pntslp(:,1))./nanmean(pntslp(:,1));           
%             LPI_mR = nanmax(mR_n);
%         elseif strcmp(str,'L')
%             [ctrlnormslope,ctrllp] = nanmax( slopes(:,1,1)./nanmean(slopes(:,1,1)));
%             tempw=slopes(:,slopes_column,1)./nanmean(slopes(:,1,1));
%             lpinorm = nanmax(tempw);
% %             lpinorm = tempw(ctrllp); %at lp of ctrl
%             pslnorm = nanmax(pntslp(:,1))./nanmean(pntslpctrl(:,1));
%             LPI_mR = nanmax(mR_n);
%         end
%         lpinorm=round(lpinorm*100)./100;
%         pslpnorm = round(pslnorm*100)./100;
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_LPI']) = LPI;
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.pointslope.([str '_LPI']) = pslpnorm;
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_LPI_diff']) = LPI_diff;
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_LP_pos']) = locs(LP);
%         tatt_all =  pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_theta_at_touch']);
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str '_Pref_thetaattouch']) =  tatt_all(LP,:);
% 
%         pooled_contactCaTrials_locdep{n}.decoder.NLS.fitmean.([str 'slopes']) =slopes(:,slopes_column,:);
%     end
%     
%     %     axis([0  numloc+1 -100  max(slopes(:,2))+200]);
%     axis([1  numloc 0 3]);set(gca,'ticklength',[.05 .05]);
%     hline(0,'k:'); hline(1,'b:');
%     title( ' slopes');
%     
%     count = count+2;
% end


%%%%%
for d=1:length(dends)

    l = pooled_contactCaTrials_locdep{d}.lightstim;
    ind = find(l==0);
    TatCM = pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean;
    TatCM_NLS = [TatCM(ind); TatCM(ind)];
    pooled_contactCaTrials_locdep{d}.decoder.NLS.Theta_at_contact_Mean =  TatCM_NLS;
    

    ls=pooled_contactCaTrials_locdep{d}.decoder.NLS.lightstim;
    NLind = find(ls==0);
    Lind = find(ls==1);
    
    
    cdir=  pooled_contactCaTrials_locdep{d}.(wpar);
    protrials_ind = find(cdir<0.000001);
    rettrials_ind = find(cdir>-0.000001);
    cd(protrials_ind) = 1;
    cd(rettrials_ind) = 0;
    cd = cd';
    
    
    tall=pooled_contactCaTrials_locdep{d}.decoder.NLS.Theta_at_contact_Mean(:);
    kall=abs(pooled_contactCaTrials_locdep{d}.decoder.NLS.(wpar)(:));
    rall=pooled_contactCaTrials_locdep{d}.decoder.NLS.sigpeak(:);
    lall=pooled_contactCaTrials_locdep{d}.decoder.NLS.poleloc(:);
    
    pos = unique(lall); cp = 1;
    if isempty(locbins)
        answer=inputdlg('Give Bins','Bins',1,{'110  210 250 280 310 350'});
        locbins = str2num(answer{1});
    else
        locbins = locbins;
    end
    
    %% No light control first
    
    ind=(ls == 0);
    
    t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(ind);
    k=abs(pooled_contactCaTrials_locdep{d}.(wpar)(ind));
    r=pooled_contactCaTrials_locdep{d}.sigpeak(ind);
    l=pooled_contactCaTrials_locdep{d}.poleloc(ind);
    
    [ThKmid,R,T,K,Tk,Rs,Ts,Ks,Tks]=calc_p(t,k,r,l,locbins);
    
    TK = T*K';
    
    pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_locPI = nanmax(T)/nanmean(T);
    pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_touPI = nanmax(K)/nanmean(K);
    pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_locPI_diff = nanmax(T)-nanmean(T);
    pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_touPI_diff = nanmax(K)-nanmean(K);
    [v,vind] = max(T);
    pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_PrefLoc = vind;
    locs = unique(l);
    numloc = length(locs);
    T2 = zeros(numloc,1);
    for loc = 1:numloc
        T2(loc,1)= nanmean(r(l==locs(loc)));
    end
    pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL= T;
    if ~isempty(Lind)
        %% Light condition
        
        
        ind=(ls == 1);
        
        t=pooled_contactCaTrials_locdep{d}.decoder.NLS.Theta_at_contact_Mean(ind);
        k=abs(pooled_contactCaTrials_locdep{d}.decoder.NLS.(wpar)(ind));
        r=pooled_contactCaTrials_locdep{d}.decoder.NLS.sigpeak(ind);
        l=pooled_contactCaTrials_locdep{d}.decoder.NLS.poleloc(ind);
        
        [ThKmid,R,T,K,Tk,Rs,Ts,Ks,Tks]=calc_p(t,k,r,l,locbins);
        
        TK = T*K';
        
        
        pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_locPI = nanmax(T)/nanmean(T);
        pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_touPI = nanmax(K)/nanmean(K);
        pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_locPI_diff = nanmax(T)-nanmean(T);
        pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_touPI_diff = nanmax(K)-nanmean(K);
        [v,vind] = max(T);
        pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_PrefLoc = vind;
        locs = unique(l);
        numloc = length(locs);
        T2 = zeros(numloc,1);
        for loc = 1:numloc
            T2(loc,1)= nanmean(r(l==locs(loc)));
        end
        pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L= T;
        
    end
end
end

function [ThKmid,R,T,K,Tk,Rs,Ts,Ks,Tks]=calc_p(t,k,r,l,locbins)
vals(:,1) = t;vals(:,2) = k;vals(:,3) = r;
% bins(1) = {[-25:10:45]}; % theta bins
bins(1) = {[-25:5:-5,30]}; % theta bins

vals(:,1) = l;vals(:,2) = k;vals(:,3) = r;


% bins(1) = {[40 210 250 280 310 350 ]};
bins(1) = {locbins};
bins(2) ={logspace(-4,2,10)}; % dKappa bins
bins(3) = {[0:100:800]}; % Resp peak bins

[count edges mid loc] = histcn(vals,bins{1},bins{2},bins{3}); %% joint dist Theta Kappa Capeak
pThKR = count / sum(sum(sum(count)));
ThKRedges = edges;
ThKRmid = mid;
ThKRloc = loc;

[count, edges mid loc] = histcn(vals(:,[1,2]),bins{1},bins{2});
pThK = count / sum(sum(count));
ThKedges = edges;
ThKmid = mid;
ThKloc = loc;
% figure; surf(ThKmid{2},ThKmid{1},pThK);

[count, edges mid loc] = histcn(vals(:,[1,3]),bins{1},bins{3});
pThR = count / sum(sum(count));
ThRedges = edges;
ThRmid = mid;
ThRloc = loc;

[count, edges mid loc] = histcn(vals(:,[2,3]),bins{2},bins{3});
pKR = count / sum(sum(count));
KRedges = edges;
KRmid = mid;
KRloc = loc;

[count edges mid loc] = histcn(r,bins{3});
pR=count./(sum(count));
Redges = edges;
Rmid = mid;
Rloc = loc;


[count edges mid loc] = histcn(t,bins{1});
pTh=count./(sum(count));
Thedges = edges;
Thmid = mid;
Thloc = loc;


[count edges mid loc] = histcn(k,bins{2});
pK=count./(sum(count));
Kedges = edges;
Kmid = mid;
Kloc = loc;

temp = pThKR;
for i = 1:length(Rmid{1})
    temp(:,:,i)  = temp(:,:,i) ./pThK;
end
pR_ThK = temp;

temp = pThR;
for i = 1:length(Rmid{1})
    temp(:,i)  = temp(:,i) ./pTh;
end
pR_Th = temp;

temp = pKR;
for i = 1:length(Rmid{1})
    temp(:,i)  = temp(:,i) ./pK;
end
pR_K = temp;

R = nan(size(pThK));
K = nan(length(ThKmid{2}),1);
T = nan(length(ThKmid{1}),1);
Tk = nan(length(ThKmid{1}),1);

Rs = nan(size(pThK));
Ks = nan(length(ThKmid{2}),1);
Ts = nan(length(ThKmid{1}),1);
Tks = nan(length(ThKmid{1}),1);

for Tpos = 1:length(ThKmid{1})
    for Kpos = 1:length(ThKmid{2})
        ind = find( (ThKloc(:,1) == Tpos) & (ThKloc(:,2) == Kpos));
        if ~isempty(ind)
            R(Tpos,Kpos) = mean(r(ind));Rs(Tpos,Kpos) = std(r(ind))./sqrt(length(ind));
        end
        ind = find(ThKloc(:,2) == Kpos); if ~isempty(ind) K(Kpos) = mean( r(ind)); Ks(Kpos) = std( r(ind))./sqrt(length(ind)); else  K(Kpos) = nan; end
    end
    ind = find(ThKloc(:,1) == Tpos);
    if ~isempty(ind) T(Tpos) = mean( r(ind));  Tk(Tpos) = mean( k(ind));
        Ts(Tpos) = std( r(ind))./sqrt(length(ind));
        Tks(Tpos) = std( k(ind))./sqrt(length(ind));
    else T(Tpos) = 0; Tk(Tpos) = 0; end
end
end