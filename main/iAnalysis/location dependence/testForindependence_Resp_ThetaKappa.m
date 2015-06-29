function [pR_ThK,pR_Th,pR_K] = testForindependence_Resp_ThetaKappa(pooled_contactCaTrials_locdep,d,indstr,cscale)

% cdir= cellfun( @(x) (sum(x==1)>sum(x==0))*1+(sum(x ==1)<sum(x==0)*0), pooled_contactCaTrials_locdep{d}.contactdir);
% protrials_ind = find(cdir==1);
% rettrials_ind = find(cdir==0);


ls=pooled_contactCaTrials_locdep{d}.lightstim;
NLind = find(ls==0); 
Lind = find(ls==1);

cdir=  pooled_contactCaTrials_locdep{d}.totalKappa_epoch;
protrials_ind = find(cdir<0.000001);
rettrials_ind = find(cdir>-0.000001); 
cd(protrials_ind) = 1;
cd(rettrials_ind) = 0;
cd = cd';
% t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(protrials_ind);
% k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs(protrials_ind);
% r=pooled_contactCaTrials_locdep{d}.sigpeak(protrials_ind);

tall=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(:);
kall=pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs(:);
rall=pooled_contactCaTrials_locdep{d}.sigpeak(:);
lall=pooled_contactCaTrials_locdep{d}.poleloc(:);

pos = unique(lall); cp = 1;
% ind = find(lall==pos(cp));
% ind = 1:length(lall);
%% protractions 
if indstr == 'NL'
    ind = (ls ==0) & (cd ==1);
elseif indstr == 'L'
    ind=(ls == 1) & (cd == 1);
end

t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(ind);
k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs(ind);
r=pooled_contactCaTrials_locdep{d}.sigpeak(ind);
l=pooled_contactCaTrials_locdep{d}.poleloc(ind);

[ThKmid,R,T,K,pR_ThK,pR_Th,pR_K]=calc_p(t,k,r,l);      
% figure;subplot(2,2,1);contour(ThKmid{2},ThKmid{1},R);caxis([0 cscale(2)]);
sc = get(0,'ScreenSize');
figure('position', [1000, sc(4)/10-100, sc(3)/2, sc(4)], 'color','w');
subplot(3,2,1);contourf(pos,ThKmid{2},R');caxis([0 cscale(2)]);  set(gca,'yscale','log');set(gca,'XTick',logspace(-3,2,6));xlabel('Loc'); ylabel('TouchMag'); set(gca,'FontSize',12);
% subplot(4,2,3);surf(ThKmid{2},ThKmid{1},R);caxis(cscale); %subplot(2,3,3);surf(ThKmid{2},ThKmid{1},T*K');caxis([0 800]); 
% subplot(2,2,4); colorbar;
subplot(3,2,3); plot(pos,T,'o-'); xlabel('Loc');ylabel('CaSig');set(gca,'FontSize',12);%axis([-25 30 -10 cscale(2)]); 
subplot(3,2,5); plot(ThKmid{2},K,'o-'); set(gca,'XTick',logspace(-3,2,6)); xlabel('Touch Mag'); ylabel('CaSig'); axis([0.0001 50 -10 cscale(2)]); set(gca,'xscale','log');
TK = T*K';
set(gca,'FontSize',12);
% Lw = R./TK;
% [U S V]= svd(R);
% 
% subplot(2,3,4);surf(ThKmid{2},ThKmid{1},S);subplot(2,3,5); plot(ThKmid{1},U);subplot(2,3,6); plot(ThKmid{2},V);
% size(U)

%% retractions
if indstr == 'NL'
    ind = (ls ==0) & (cd ==0);
elseif indstr == 'L'
    ind=(ls == 1) & (cd == 0);
end

t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(ind);
k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch_abs(ind);
r=pooled_contactCaTrials_locdep{d}.sigpeak(ind);
l=pooled_contactCaTrials_locdep{d}.poleloc(ind);

[ThKmid,R,T,K,pR_ThK,pR_Th,pR_K]=calc_p(t,k,r,l);      
% figure;subplot(2,2,1);contour(ThKmid{2},ThKmid{1},R);caxis([0 cscale(2)]);
subplot(3,2,2);contourf(pos,ThKmid{2},R');caxis([0 cscale(2)]);  set(gca,'yscale','log'); xlabel('Loc'); ylabel('TouchMag'); set(gca,'FontSize',12);
% subplot(4,2,4);surf(ThKmid{2},pos,R);caxis(cscale); %subplot(2,3,3);surf(ThKmid{2},ThKmid{1},T*K');caxis([0 800]); 
% subplot(2,2,4); colorbar;
subplot(3,2,4); plot(pos,T,'o-');  xlabel('Loc');ylabel('CaSig');set(gca,'FontSize',12); %axis([-25 30 -10 cscale(2)]);
subplot(3,2,6); plot(ThKmid{2},K,'o-'); set(gca,'XTick',logspace(-3,2,6)); xlabel('Touch Mag'); ylabel('CaSig');  axis([0.001 50 -10 cscale(2)]); set(gca,'xscale','log');set(gca,'FontSize',12);
% suptitle([num2str(d) indstr]);
TK = T*K';

suptitle([num2str(d) indstr]);
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[1 1 6 8]);
% set(gcf, 'PaperSize', [10,5]);
% set(gcf,'PaperPositionMode','manual');
print( gcf ,'-depsc2','-painters','-loose',['D' num2str(d) indstr]);

end




function [ThKmid,R,T,K,pR_ThK,pR_Th,pR_K]=calc_p(t,k,r,l)
vals(:,1) = t;vals(:,2) = k;vals(:,3) = r;
% bins(1) = {[-25:10:45]}; % theta bins
bins(1) = {[-25:5:-5,30]}; % theta bins

vals(:,1) = l;vals(:,2) = k;vals(:,3) = r;
bins(1) = {[40 50 200 240 280 315 340]};
% bins(1) = {[40 200 240 280 310 340]};

% bins(2) = {[-.2:0.2:2.5]}; %Kappa bins
bins(2) ={logspace(-4,2,10)}; %Kappa bins
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

R = zeros(size(pThK)); 
K = nan(length(ThKmid{2}),1);
T = zeros(length(ThKmid{1}),1);

for Tpos = 1:length(ThKmid{1})
    for Kpos = 1:length(ThKmid{2})
        ind = find( (ThKloc(:,1) == Tpos) & (ThKloc(:,2) == Kpos));
        if ~isempty(ind)
            R(Tpos,Kpos) = mean(r(ind));
        end
        ind = find(ThKloc(:,2) == Kpos); if ~isempty(ind) K(Kpos) = mean( r(ind)); else  K(Kpos) = nan; end
    end
    ind = find(ThKloc(:,1) == Tpos);  if ~isempty(ind) T(Tpos) = mean( r(ind)); else T(Tpos) = 0; end
end
end