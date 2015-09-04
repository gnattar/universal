%script_to_generate_LAddback_NLsubtract_datasets_for_decoder

% load('145_150430_Thr25_pooled_contact_CaTrials_smth.mat')


l=pooled_contact_CaTrials{1}.lightstim;
for d = 1: size(pooled_contactCaTrials_locdep,2)
    r=pooled_contact_CaTrials{d}.peakamp;
    sigpeak = pooled_contactCaTrials_locdep{d}.sigpeak;
    poleloc =pooled_contactCaTrials_locdep{d}.poleloc;
    lightstim = pooled_contactCaTrials_locdep{d}.lightstim;
    re_totaldK = pooled_contactCaTrials_locdep{d}.re_totaldK;
    paNL = r(l==0);
    paL = r(l==1);
    diff=mean(paNL)-mean(paL);
    pooled_contactCaTrials_locdep{d}.decoder.diff=diff;
    sigpeakLAD = sigpeak;
    ind = find(l==1);
    sigpeakLAD(ind,1) = sigpeak(ind,1) + diff;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.sigpeak=sigpeakLAD;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.poleloc=poleloc;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.re_totaldK=re_totaldK;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.lightstim=lightstim;
    
    ind = [];
    polelocNLS=poleloc;
    re_totaldKNLS = re_totaldK;
    sigpeakNLS = sigpeak;
    sigpeakNLS(l==0,1) =  sigpeakNLS(l==0,1) - diff;
    
    l2 = [ l;l];
    numtrials = length(find(l==0));
    lightstimNLS = zeros(numtrials,1);
    poleloc2 = [ poleloc;polelocNLS];
    re_totaldK2 = [re_totaldK;re_totaldKNLS];
    sigpeak2=[sigpeak;sigpeakNLS];
    lightstim2 = [ lightstimNLS;lightstimNLS+1];
    ind = find(l2==1);
    sigpeak2(ind,1)=[];
    poleloc2(ind,1) = [];  
    re_totaldK2(ind,1) = [];
 
    pooled_contactCaTrials_locdep{d}.decoder.NLS.sigpeak=sigpeak2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.poleloc=poleloc2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.re_totaldK=re_totaldK2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.lightstim=lightstim2;
    
    
    % nochange sanity check
    sigpeakNC = [ sigpeak ; sigpeak];
    sigpeakNC(ind,1)=[];
    polelocNC = poleloc2;
    lightstimNC = lightstim2;
    re_totaldKNC = re_totaldK2;  
    
    pooled_contactCaTrials_locdep{d}.decoder.NC.sigpeak=sigpeakNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.poleloc=polelocNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.re_totaldK=re_totaldKNC;
    pooled_contactCaTrials_locdep{d}.decoder.NC.lightstim=lightstimNC;
      
end
