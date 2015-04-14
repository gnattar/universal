function [pR_ThK,pR_Th,pR_K] = testForindependence_Resp_ThetaKappa(pooled_contactCaTrials_locdep,d)

% cdir= cellfun( @(x) (sum(x==1)>sum(x==0))*1+(sum(x ==1)<sum(x==0)*0), pooled_contactCaTrials_locdep{d}.contactdir);
% protrials_ind = find(cdir==1);
% rettrials_ind = find(cdir==0);
% 
% t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(protrials_ind);
% k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch(protrials_ind);
% r=pooled_contactCaTrials_locdep{d}.sigpeak(protrials_ind);

t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean(:);
k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch(:);
r=pooled_contactCaTrials_locdep{d}.sigpeak(:);

vals(:,1) = t;vals(:,2) = k;vals(:,3) = r;
bins(1) = {[-25:5:45]}; % theta bins
bins(2) = {[-2.5:0.25:2.5]}; %Kappa bins
bins(3) = {[0:050:1000]}; % Resp peak bins

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
K = zeros(length(ThKmid{2}),1);
T = zeros(length(ThKmid{1}),1);

for Tpos = 1:length(ThKmid{1})
    for Kpos = 1:length(ThKmid{2})
        ind = find( (ThKloc(:,1) == Tpos) & (ThKloc(:,2) == Kpos));
        if ~isempty(ind)
            R(Tpos,Kpos) = mean(r(ind));
        end
        ind = find(ThKloc(:,2) == Kpos); if ~isempty(ind) K(Kpos) = mean( r(ind)); else  K(Kpos) = 0; end
    end
    ind = find(ThKloc(:,1) == Tpos);  if ~isempty(ind) T(Tpos) = mean( r(ind)); else T(Tpos) = 0; end
end
                    
figure;subplot(2,3,1);surf(ThKmid{2},ThKmid{1},R);subplot(2,3,2); plot(ThKmid{1},T);subplot(2,3,3); plot(ThKmid{2},K);
TK = T*K';
 Lw = R./TK;
 [U S V]= svd(R);

subplot(2,3,4);surf(ThKmid{2},ThKmid{1},S);subplot(2,3,5); plot(ThKmid{1},U);subplot(2,3,6); plot(ThKmid{2},V);
size(U)