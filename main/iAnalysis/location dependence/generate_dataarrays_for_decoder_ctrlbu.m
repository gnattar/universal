%script_to_generate_LAddback_NLsubtract_datasets_for_decoder

% load('145_150430_Thr25_pooled_contact_CaTrials_smth.mat')
function [pooled_contactCaTrials_locdep]= generate_dataarrays_for_decoder_ctrl_bu(pooled_contactCaTrials_locdep,pooled_contact_CaTrials)

l=pooled_contactCaTrials_locdep{1}.lightstim;
for d = 4: size(pooled_contactCaTrials_locdep,2)

    sigpeak = pooled_contactCaTrials_locdep{d}.sigpeak;
%     sigmag = pooled_contactCaTrials_locdep{d}.sigmag;
    poleloc =pooled_contactCaTrials_locdep{d}.poleloc;
    lightstim = pooled_contactCaTrials_locdep{d}.lightstim;
    re_totaldK = pooled_contactCaTrials_locdep{d}.re_totaldK;
    r=pooled_contact_CaTrials{d}.peakamp;
    paNL = r(l==0);
    paL = r(l==1);
    diffPeak=nanmean(paNL)-nanmean(paL);
    pooled_contactCaTrials_locdep{d}.decoder.diff=diffPeak;
    sigpeakLAD = sigpeak;
    ind = find(l==1);
    sigpeakLAD(ind,1) = sigpeak(ind,1) + diffPeak;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.sigpeak=sigpeakLAD;
    
    r=pooled_contact_CaTrials{d}.intarea;
    iaNL = r(l==0);
    iaL = r(l==1);
    diffMag=nanmean(iaNL)-nanmean(iaL);
    pooled_contactCaTrials_locdep{d}.decoder.iadiff=diffMag;
    sigmagLAD = sigmag;
    ind = find(l==1);
    sigmagLAD(ind,1) = sigmag(ind,1) + diffMag;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.sigmag=sigmagLAD;
    
    pooled_contactCaTrials_locdep{d}.decoder.LAD.poleloc=poleloc;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.re_totaldK=re_totaldK;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.lightstim=lightstim;
    
    ind = [];
    polelocNLS=poleloc;
    re_totaldKNLS = re_totaldK;
    sigpeakNLS = sigpeak;
    sigpeakNLS(l==0,1) =  sigpeakNLS(l==0,1) - diffPeak;
    sigmagNLS = sigmag;
    sigmagNLS(l==0,1) =  sigmagNLS(l==0,1) - diffMag;
    
    l2 = [ l;l];
    numtrials = length(find(l==0));
    lightstimNLS = zeros(numtrials,1);
    poleloc2 = [ poleloc;polelocNLS];
    re_totaldK2 = [re_totaldK;re_totaldKNLS];
    sigpeak2=[sigpeak;sigpeakNLS];
    sigmag2=[sigmag;sigmagNLS];
    lightstim2 = [ lightstimNLS;lightstimNLS+1];
    ind = find(l2==1);
    sigpeak2(ind)=[];
    sigmag2(ind)=[];
    poleloc2(ind) = [];  
    re_totaldK2(ind) = [];
 
    pooled_contactCaTrials_locdep{d}.decoder.NLS.sigpeak=sigpeak2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.sigmag=sigmag2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.poleloc=poleloc2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.re_totaldK=re_totaldK2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.lightstim=lightstim2;
    
    
    % nochange sanity check
    sigpeakNC = [ sigpeak ; sigpeak];
    sigpeakNC(ind)=[];
    sigmagNC = [ sigmag ; sigmag];
    sigmagNC(ind)=[];
    polelocNC = poleloc2;
    lightstimNC = lightstim2;
    re_totaldKNC = re_totaldK2;  
    
    pooled_contactCaTrials_locdep{d}.decoder.NC.sigpeak=sigpeakNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.sigmag=sigmagNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.poleloc=polelocNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.re_totaldK=re_totaldKNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.lightstim=lightstimNC;
      
end
end
