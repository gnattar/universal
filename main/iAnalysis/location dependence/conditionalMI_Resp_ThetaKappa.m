function [MI,hR,hR_ThK] = conditionalMI_Resp_ThetaKappa(pooled_contactCaTrials_locdep,d)
t=pooled_contactCaTrials_locdep{d}.Theta_at_contact_Mean;
k=pooled_contactCaTrials_locdep{d}.totalKappa_epoch;
r=pooled_contactCaTrials_locdep{d}.sigpeak;

vals(:,1) = t;vals(:,2) = k;vals(:,3) = r;
bins(1) = {[-50:5:50]}; % theta bins
bins(2) = {[-2.5:0.25:2.5]}; %Kappa bins
bins(3) = {[0:50:1000]}; % Resp peak bins

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
% figure;plot(Rmid{1},pR)
log2pR = -log2(pR);
hR = nanmean(pR.*log2pR);

[count edges mid loc] = histcn(t,bins{1});
pTh=count./(sum(count));
Thedges = edges;
Thmid = mid;
Thloc = loc;
% figure;plot(Thmid{1},pTh)
log2pTh = -log2(pTh);
hTh = nanmean(pTh.*log2pTh);

[count edges mid loc] = histcn(k,bins{2});
pK=count./(sum(count));
Kedges = edges;
Kmid = mid;
Kloc = loc;
% figure;plot(Kmid{1},pK)
log2pK = -log2(pK);
hK = nanmean(pK.*log2pK);

hR_Th = 0;
for th = 1:length(ThKRmid{1})
    pR_currTh = pThR(th,:)./pTh(th);
    log2pR_currTh = -log2( pR_currTh );
    hR_Th=nansum([hR_Th , pTh(th) .* nanmean(squeeze(pR_currTh).*squeeze(log2pR_currTh))]);
end


hR_K = 0;
for ka = 1:length(ThKRmid{2})
    pR_currK = pKR(ka,:)./pK(ka);
    log2pR_currK = -log2( pR_currK );
    hR_K=nansum([hR_K , pK(ka) .* nanmean(squeeze(pR_currK).*squeeze(log2pR_currK))]);
end

hR_ThK = 0;
for th = 1:length(ThKRmid{1})
    for ka = 1:length(ThKRmid{2})
        pR_currThK = pThKR(th,ka,:)./pThK(th,ka);
        log2pR_currThK = -log2( pR_currThK );
        hR_ThK=nansum([hR_ThK, pThK(th,ka).* nanmean(squeeze(pR_currThK).*squeeze(log2pR_currThK))]);
    end
end

% h_R_ThK = h_R_ThK*-1;
MI(1)= hR - hR_ThK;
MI(2)= hR - hR_Th;
MI(3)= hR - hR_K;