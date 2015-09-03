%script_to_generate_LAddback_NLsubtract_datasets_for_decoder

% load('145_150430_Thr25_pooled_contact_CaTrials_smth.mat')


l=pooled_contact_CaTrials{1}.lightstim;
for d = 1: size(pooled_contactCaTrials_locdep,2)
    r=pooled_contact_CaTrials{d}.peakamp;
    sigpeak = pooled_contactCaTrials_locdep{d}.sigpeak;
    poleloc =pooled_contactCaTrials_locdep{d}.poleloc;
    re_totaldK = pooled_contactCaTrials_locdep{d}.re_totaldK;
    paNL = r(l==0);
    paL = r(l==1);
    diff=mean(paNL)-mean(paL)
    pooled_contactCaTrials_locdep{d}.decoder.diff=diff;
    sigpeakAD(l==1,1) = sigpeak(l==1,1) + diff;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.sigpeak=sigpeakAD;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.poleloc=poleloc;
    pooled_contactCaTrials_locdep{d}.decoder.LAD.re_totaldK=re_totaldK;
    
    
    sigpeakNLS = sigpeak;
    polelocNLS=poleloc;
    re_totaldKNLS = re_totaldK;
    
    sigpeakNLS(l==0,1) =  sigpeakNLS(l==0,1) - diff;
    
    l2 = [ l;l];
  
    poleloc2 = [ poleloc;polelocNLS];
    re_totaldK2 = [re_totaldK;re_totaldKNLS];
    sigpeak2=[sigpeak;sigpeakNLS];
    ind = find(l2==1);
   sigpeak2(ind)=[];
   poleloc2(ind) = [];
   re_totaldK2(ind) = [];
 
    pooled_contactCaTrials_locdep{d}.decoder.NLS.sigpeak=sigpeak2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.poleloc=poleloc2;
    pooled_contactCaTrials_locdep{d}.decoder.NLS.re_totaldK=re_totaldK2;

    waitforbuttonpress

end
