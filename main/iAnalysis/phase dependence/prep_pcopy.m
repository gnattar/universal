function [pooled_contactCaTrials_locdep] = prep_pcopy(pcopy,cond)
%%%%% if for NLS run this first
% for i = 1:152
% pooled_contactCaTrials_locdep_NLS{i}.re_totaldK = pooled_contactCaTrials_locdep{i}.decoder.NLS.re_totaldK;
% pooled_contactCaTrials_locdep_NLS{i}.sigpeak = pooled_contactCaTrials_locdep{i}.decoder.NLS.sigpeak;
% pooled_contactCaTrials_locdep_NLS{i}.lightstim = pooled_contactCaTrials_locdep{i}.decoder.NLS.lightstim;
% pooled_contactCaTrials_locdep_NLS{i}.poleloc = pooled_contactCaTrials_locdep{i}.decoder.NLS.poleloc;
% end



switch cond 
    

%% for phase
    case 'phase'
pooled_contactCaTrials_locdep = pcopy;
% 
 numdends = size(pooled_contactCaTrials_locdep,2);
 
% lightstim = pooled_contactCaTrials_locdep{1}.lightstim;
% phase = pooled_contactCaTrials_locdep{1}.phase;
% NL_ind = find(lightstim == 0);
% L_ind = find(lightstim == 1);
% 
% phases = unique(pooled_contactCaTrials_locdep{1}.phase);

for d = 1:numdends
    
lightstim = pooled_contactCaTrials_locdep{d}.lightstim;
phase = pooled_contactCaTrials_locdep{d}.phase;
NL_ind = find(lightstim == 0);
L_ind = find(lightstim == 1);

phases = unique(pooled_contactCaTrials_locdep{d}.phase);
    
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
   

%% for location
 case 'loc'
pooled_contactCaTrials_locdep = pcopy;

numdends = size(pooled_contactCaTrials_locdep,2);
% lightstim = pooled_contactCaTrials_locdep{1}.lightstim;
% poleloc = pooled_contactCaTrials_locdep{1}.poleloc;
% NL_ind = find(lightstim == 0);
% L_ind = find(lightstim == 1);
% locs = unique(pooled_contactCaTrials_locdep{1}.poleloc);

for d = 1:numdends
    lightstim = pooled_contactCaTrials_locdep{d}.lightstim;
poleloc = pooled_contactCaTrials_locdep{d}.poleloc;
NL_ind = find(lightstim == 0);
L_ind = find(lightstim == 1);
locs = unique(pooled_contactCaTrials_locdep{d}.poleloc);

ca=pooled_contactCaTrials_locdep{d}.sigpeak;
for l = 1: length(locs)
inds = find(lightstim == 0 & poleloc == locs(l));
mResp_NL(l)= nanmean(ca(inds));
inds = find(lightstim == 1 & poleloc == locs(l));
mResp_L(l)= nanmean(ca(inds));
end
normResp_NL = mResp_NL(:) ./ nanmean(mResp_NL);
normResp_L = mResp_L(:) ./ nanmean(mResp_L);

pooled_contactCaTrials_locdep{d}.locdep.mResp_NL = mResp_NL  ;
pooled_contactCaTrials_locdep{d}.locdep.mResp_L = mResp_L;
% pooled_contactCaTrials_locdep{d}.locdep.normResp_NL=normResp_NL;
% pooled_contactCaTrials_locdep{d}.locdep.normResp_L = normResp_L;
% pooled_contactCaTrials_locdep{d}.locdep.LPI_NL = max(normResp_NL);
% pooled_contactCaTrials_locdep{d}.locdep.LPI_L = max(normResp_L);
pooled_contactCaTrials_locdep{d}.locdep.locs = locs;
pooled_contactCaTrials_locdep{d}.locdep.normChange = (mResp_NL-mResp_L)./nanmean((mResp_NL-mResp_L));
pooled_contactCaTrials_locdep{d}.locdep.frChange = (mResp_L-mResp_NL)./mResp_NL;

end
save('pooled_contactCaTrials_locdep','pooled_contactCaTrials_locdep');

%% for theta
    case 'theta'
pooled_contactCaTrials_locdep = pcopy;

numdends = size(pooled_contactCaTrials_locdep,2);

for d = 1:numdends
lightstim = pooled_contactCaTrials_locdep{d}.lightstim;
% theta = pooled_contactCaTrials_locdep{d}.theta; %% if from pcopy
% thetas = unique(pooled_contactCaTrials_locdep{d}.theta);%% if from pcopy
theta = pooled_contactCaTrials_locdep{d}.theta_binned_new; %% if from pooled_contactCaTrials_locdep_allcells
thetas = unique(pooled_contactCaTrials_locdep{d}.theta_binned_new); %% if from pooled_contactCaTrials_locdep_allcells
NL_ind = find(lightstim == 0);
L_ind = find(lightstim == 1);

ca=pooled_contactCaTrials_locdep{d}.sigpeak;
for ph = 1: length(thetas)
inds = find(lightstim == 0 & theta == thetas(ph));
mResp_NL(ph)= nanmean(ca(inds));
inds = find(lightstim == 1 & theta == thetas(ph));
mResp_L(ph)= nanmean(ca(inds));
end
normResp_NL = mResp_NL(:) ./ nanmean(mResp_NL);
normResp_L = mResp_L(:) ./ nanmean(mResp_L);

pooled_contactCaTrials_locdep{d}.thetadep.mResp_NL = mResp_NL  ;
pooled_contactCaTrials_locdep{d}.thetadep.mResp_L = mResp_L;
pooled_contactCaTrials_locdep{d}.thetadep.normResp_NL=normResp_NL;
pooled_contactCaTrials_locdep{d}.thetadep.normResp_L = normResp_L;
pooled_contactCaTrials_locdep{d}.thetadep.TPI_NL = max(normResp_NL);
pooled_contactCaTrials_locdep{d}.thetadep.TPI_L = max(normResp_L);
pooled_contactCaTrials_locdep{d}.thetadep.touchTheta_mid = thetas;
pooled_contactCaTrials_locdep{d}.thetadep.normChange = (mResp_NL-mResp_L)./nanmean((mResp_NL-mResp_L));
pooled_contactCaTrials_locdep{d}.thetadep.frChange = (mResp_L-mResp_NL)./mResp_NL;

end
save('pooled_contactCaTrials_thetadep','pooled_contactCaTrials_locdep');
end