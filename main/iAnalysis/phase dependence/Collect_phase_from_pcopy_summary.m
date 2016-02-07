function [data] = Collect_phase_from_pcopy_summary()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*pooled_contactCaTrials_phasedep.mat','Load .mat file');
    else
        [filename,pathName]=uigetfile( filename,'Load phasedep.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
    for d =1:dends
        
        PPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phasedep.PPI_NL;
        meanResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phasedep.mResp_NL;
        normResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phasedep.normResp_NL;
        [v,i]=max(pooled_contactCaTrials_locdep{d}.phasedep.normResp_NL);
        PPid_ctrl{count}(d,1) = i;
        PPh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phasedep.touchPhase_mid(i);
        
        
        if isfield( pooled_contactCaTrials_locdep{d}.phasedep,'PPI_L')
        PPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.phasedep.PPI_L;
        meanResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phasedep.mResp_L;
        normResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phasedep.normResp_L;
        [v,i]=max(pooled_contactCaTrials_locdep{d}.phasedep.normResp_L);
        PPid_mani{count}(d,1) = i;
        PPh_mani{count}(d,1) = pooled_contactCaTrials_locdep{1}.phasedep.touchPhase_mid(i);
        NormCh{count}(d,:) = pooled_contactCaTrials_locdep{d}.phasedep.normChange;
        FrCh{count}(d,:) = pooled_contactCaTrials_locdep{d}.phasedep.frChange;
        end
        
    end
    
    cd (pathName);
end
data.PPI_ctrl=PPI_ctrl;
data.meanResp_phase_ctrl=meanResp_phase_ctrl;
data.normResp_phase_ctrl=normResp_phase_ctrl;
data.PPid_ctrl=PPid_ctrl;
data.PPh_ctrl=PPh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.phasedep,'PPI_L')
    data.PPI_mani=PPI_mani;
    data.meanResp_phase_mani=meanResp_phase_mani;
    data.normResp_phase_mani=normResp_phase_mani;
    data.PPid_mani=PPid_mani;
    data.PPh_mani=PPh_mani;
    data.FrCh=FrCh;
    data.NormCh=NormCh;
end
% folder = uigetdir;
% cd (folder);
save('Phase Summary Data','data');

