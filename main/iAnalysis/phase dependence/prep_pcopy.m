function [pooled_contactCaTrials_locdep] = prep_pcopy(pcopy)

pooled_contactCaTrials_locdep = pcopy;

numdends = size(pooled_contactCaTrials_locdep,2);
lightstim = pooled_contactCaTrials_locdep{1}.lightstim;
phase = pooled_contactCaTrials_locdep{1}.phase;
NL_ind = find(lightstim == 0);
L_ind = find(lightstim == 1);

phases = unique(pooled_contactCaTrials_locdep{1}.phase);

for d = 1:numdends
ca=pooled_contactCaTrials_locdep{d}.sigpeak;
for ph = 1: length(phases)
inds = find(lightstim == 0 & phase == phases(ph));
mResp_NL(ph)= nanmean(ca(inds));
inds = find(lightstim == 1 & phase == phases(ph));
mResp_L(ph)= nanmean(ca(inds));
end
normResp_NL = mResp_NL(:) ./ nanmean(mResp_NL);
normResp_L = mResp_L(:) ./ nanmean(mResp_L);

pooled_contactCaTrials_locdep{d}.phasedep.mResp_NL = mResp_NL  ;
pooled_contactCaTrials_locdep{d}.phasedep.mResp_L = mResp_L;
pooled_contactCaTrials_locdep{d}.phasedep.normResp_NL=normResp_NL;
pooled_contactCaTrials_locdep{d}.phasedep.normResp_L = normResp_L;
pooled_contactCaTrials_locdep{d}.phasedep.PPI_NL = max(normResp_NL);
pooled_contactCaTrials_locdep{d}.phasedep.PPI_L = max(normResp_L);
pooled_contactCaTrials_locdep{d}.phasedep.touchPhase_mid = phases;
pooled_contactCaTrials_locdep{d}.phasedep.normChange = (mResp_NL-mResp_L)./nanmean((mResp_NL-mResp_L));
pooled_contactCaTrials_locdep{d}.phasedep.frChange = (mResp_L-mResp_NL)./mResp_NL;

end
save('pooled_contactCaTrials_phasedep','pooled_contactCaTrials_locdep');