function [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,wpar,indstr,cscale,ptype,disp,locbins)
%  [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,wpar,indstr,cscale,ptype,disp,locbins)
% peakloc =       % location at which least touch gives most amp
% peakamp =
%%[pR_ThK,pR_Th,pR_K] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,wpar,indstr,cscale,ptype)

% cdir= cellfun( @(x) (sum(x==1)>sum(x==0))*1+(sum(x ==1)<sum(x==0)*0), pooled_contactCaTrials_locdep{d}.contactdir);
% protrials_ind = find(cdir==1);
% rettrials_ind = find(cdir==0);
pointsize = 40;

ls=pooled_contactCaTrials_locdep{d}.lightstim;
NLind = find(ls==0);
Lind = find(ls==1);
if(isempty(Lind))
    plotcols =1;
else
    plotcols = 2;
end

cdir=  pooled_contactCaTrials_locdep{d}.(wpar);
protrials_ind = find(cdir<0.000001);
rettrials_ind = find(cdir>-0.000001);
cd(protrials_ind) = 1;
cd(rettrials_ind) = 0;
cd = cd';

% t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(protrials_ind);
% k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs(protrials_ind);
% r=pooled_contactCaTrials_locdep{d}.sigpeak(protrials_ind);

tall=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(:);
kall=abs(pooled_contactCaTrials_locdep{d}.(wpar)(:));
rall=pooled_contactCaTrials_locdep{d}.sigpeak(:);
lall=pooled_contactCaTrials_locdep{d}.poleloc(:);

pos = unique(lall); cp = 1;
if isempty(locbins)
answer=inputdlg('Give Bins','Bins',1,{'110  210 250 280 310 350'});
locbins = str2num(answer{1});
else
    locbins = locbins;
end
% ind = find(lall==pos(cp));
% ind = 1:length(lall);
%% No light control first
if indstr == 'P'
    ind = (ls ==0) & (cd ==1);
elseif indstr == 'R'
    ind=(ls == 0) & (cd == 0);
elseif indstr == 'PR'
    ind=(ls == 0);
end

t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(ind);
k=abs(pooled_contactCaTrials_locdep{d}.(wpar)(ind));
r=pooled_contactCaTrials_locdep{d}.sigpeak(ind);
l=pooled_contactCaTrials_locdep{d}.poleloc(ind);

[ThKmid,R,T,K,Tk,Rs,Ts,Ks,Tks]=calc_p(t,k,r,l,locbins);
if disp
% figure;subplot(2,2,1);contour(ThKmid{2},ThKmid{1},R);caxis([0 cscale(2)]);
sc = get(0,'ScreenSize');
if ~isempty(Lind)
    figure('position', [1000, sc(4)/10-100, sc(3)/2, sc(4)], 'color','w');
else
    figure('position', [1000, sc(4)/10-100, sc(3)/4, sc(4)], 'color','w');
end

subplot(4,plotcols,1);
if ptype == 'cf'
    Rtemp = R;
    Rtemp(isnan(R)) = 0;
    contourf(pos,ThKmid{2},Rtemp');caxis([0 cscale(2)]); % axis([0 400 0.0001 2.5]);
elseif ptype == 'cs'
    contour(pos,ThKmid{2},R');caxis([0 cscale(2)]); hold on;  scatter(l,k,pointsize,r,'filled');axis([0 400 0.0001 10]);
end
set(gca,'yscale','log'); xlabel('Loc'); ylabel('TouchMag'); set(gca,'FontSize',12); title ('Ctrl');  set(gca,'YTick',logspace(-3,2,6));
% subplot(4,2,3);surf(ThKmid{2},ThKmid{1},R);caxis(cscale); %subplot(2,3,3);surf(ThKmid{2},ThKmid{1},T*K');caxis([0 800]);
% subplot(2,2,4); colorbar;
subplot(4,plotcols,plotcols+1); errorbar(ThKmid{2},K,Ks,'o-'); set(gca,'XTick',logspace(-3,2,6)); xlabel('Touch Mag'); ylabel('CaSig'); axis([0.0001 10 -10 cscale(2)]); set(gca,'xscale','log');
subplot(4,plotcols,2*plotcols+1); errorbar(pos,T,Ts,'o-'); xlabel('Loc');ylabel('CaSig');set(gca,'FontSize',12);axis([100 350 0 cscale(2)]);
subplot(4,plotcols,3*plotcols+1); errorbar(pos,Tk,Tks,'o-'); xlabel('Loc');ylabel('Touch Mag');set(gca,'FontSize',12);axis([100 350 0 .5]);

set(gca,'FontSize',12);
TK = T*K';

% Lw = R./TK;
% [U S V]= svd(R);
%
% subplot(2,3,4);surf(ThKmid{2},ThKmid{1},S);subplot(2,3,5); plot(ThKmid{1},U);subplot(2,3,6); plot(ThKmid{2},V);
% size(U)
end
    pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI = nanmax(T)/nanmean(T);
    pooled_contactCaTrials_locdep{d}.meanResp.NL_touPI = nanmax(K)/nanmean(K);
    pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI_diff = nanmax(T)-nanmean(T);
    pooled_contactCaTrials_locdep{d}.meanResp.NL_touPI_diff = nanmax(K)-nanmean(K);
    [v,vind] = max(T);
    pooled_contactCaTrials_locdep{d}.meanResp.NL_PrefLoc = vind;
    pooled_contactCaTrials_locdep{d}.meanResp.NL= T;
if ~isempty(Lind)
    %% Light condition
    if indstr == 'P'
        ind = (ls ==1) & (cd ==1);
    elseif indstr == 'R'
        ind=(ls == 1) & (cd == 0);
    elseif indstr == 'PR'
        ind=(ls == 1);
    end
    
    t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(ind);
    k=abs(pooled_contactCaTrials_locdep{d}.(wpar)(ind));
    r=pooled_contactCaTrials_locdep{d}.sigpeak(ind);
    l=pooled_contactCaTrials_locdep{d}.poleloc(ind);
    
    [ThKmid,R,T,K,Tk,Rs,Ts,Ks,Tks]=calc_p(t,k,r,l,locbins);
    if disp
    % figure;subplot(2,2,1);contour(ThKmid{2},ThKmid{1},R);caxis([0 cscale(2)]);
    subplot(4,plotcols,plotcols);
    if ptype == 'cf'
        Rtemp = R;
        Rtemp(isnan(R)) = 0;
        contourf(pos,ThKmid{2},Rtemp');caxis([0 cscale(2)]);   %axis([0 400 0.0001 2.5]);
    elseif ptype == 'cs'
        contour(pos,ThKmid{2},R');caxis([0 cscale(2)]); hold on;   scatter(l,k,pointsize,r,'filled');axis([0 400 0.0001 10]);
    end
    set(gca,'yscale','log'); xlabel('Loc'); ylabel('TouchMag'); set(gca,'FontSize',12); title ('Silenced');set(gca,'YTick',logspace(-3,2,6));
    % subplot(4,2,4);surf(ThKmid{2},pos,R);caxis(cscale); %subplot(2,3,3);surf(ThKmid{2},ThKmid{1},T*K');caxis([0 800]);
    % subplot(2,2,4); colorbar;
    subplot(4,plotcols,2*plotcols); errorbar(ThKmid{2},K,Ks,'o-'); set(gca,'XTick',logspace(-3,2,6)); xlabel('Touch Mag'); ylabel('CaSig');  axis([0.0001 10 -10 cscale(2)]); set(gca,'xscale','log');set(gca,'FontSize',12);
    subplot(4,plotcols,3*plotcols); errorbar(pos,T,Ts,'o-');  xlabel('Loc');ylabel('CaSig');set(gca,'FontSize',12); axis([100 350 0 cscale(2)]);
    subplot(4,plotcols,4*plotcols); errorbar(pos,Tk,Tks,'o-');  xlabel('Loc');ylabel('Touch Mag');set(gca,'FontSize',12); axis([100 350 0 .5]);
    
    % suptitle([num2str(d) indstr]);
    TK = T*K';

    suptitle([num2str(d) indstr]);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 6 8]);
    % set(gcf, 'PaperSize', [10,5]);
    % set(gcf,'PaperPositionMode','manual');
    end
    pooled_contactCaTrials_locdep{d}.meanResp.L_locPI = nanmax(T)/nanmean(T);
    pooled_contactCaTrials_locdep{d}.meanResp.L_touPI = nanmax(K)/nanmean(K);
    pooled_contactCaTrials_locdep{d}.meanResp.L_locPI_diff = nanmax(T)-nanmean(T);
    pooled_contactCaTrials_locdep{d}.meanResp.L_touPI_diff = nanmax(K)-nanmean(K);
    [v,vind] = max(T);
    pooled_contactCaTrials_locdep{d}.meanResp.L_PrefLoc = vind;
    pooled_contactCaTrials_locdep{d}.meanResp.L= T;
else
    if disp
    suptitle([num2str(d) indstr]);
    set(gcf,'PaperUnits','inches');
    set(gcf,'PaperPosition',[1 1 3 8]);
    % set(gcf, 'PaperSize', [10,5]);
    % set(gcf,'PaperPositionMode','manual');
    end
    
end
if disp print( gcf ,'-depsc2','-painters','-loose',['D' num2str(d) indstr '_' ptype]);end 
% 
% pooled_contactCaTrials_locdep{d}.meanResp.R = R;
% pooled_contactCaTrials_locdep{d}.meanResp.T = T;
% pooled_contactCaTrials_locdep{d}.meanResp.K = K;
% pooled_contactCaTrials_locdep{d}.meanTouch.Tk = Tk;
% pooled_contactCaTrials_locdep{d}.meanResp.R = Rs;
% pooled_contactCaTrials_locdep{d}.meanResp.T = Ts;
% pooled_contactCaTrials_locdep{d}.meanResp.K = Ks;
% pooled_contactCaTrials_locdep{d}.meanTouch.Tk = Tks;
% pooled_contactCaTrials_locdep{d}.meanResp.bins = ThKmid;


end




function [ThKmid,R,T,K,Tk,Rs,Ts,Ks,Tks]=calc_p(t,k,r,l,locbins)
vals(:,1) = t;vals(:,2) = k;vals(:,3) = r;
% bins(1) = {[-25:10:45]}; % theta bins
bins(1) = {[-25:5:-5,30]}; % theta bins

vals(:,1) = l;vals(:,2) = k;vals(:,3) = r;


% bins(1) = {[40 210 250 280 310 350 ]};
bins(1) = {locbins};
bins(2) ={logspace(-4,2,6)}; % dKappa bins
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
    ind = find(ThKloc(:,1) == Tpos);  if ~isempty(ind) T(Tpos) = mean( r(ind));  Tk(Tpos) = mean( k(ind));
        Ts(Tpos) = std( r(ind))./sqrt(length(ind));  Tks(Tpos) = std( k(ind))./sqrt(length(ind));else T(Tpos) = 0; Tk(Tpos) = 0; end
end
end