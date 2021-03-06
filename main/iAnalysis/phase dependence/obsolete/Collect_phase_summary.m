function [data] = Collect_phase_summary_T2()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*_pooled_contactCaTrials_phasedep.mat','Load .mat file');
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
        
        PPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.PPI_NL;
        meanResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.mResp_NL;
        normResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.normResp_NL;
        [v,i]=max(pooled_contactCaTrials_locdep{d}.phase.normResp_NL);
        PPid_ctrl{count}(d,1) = i;
        PPh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.touchPhase_mid(i);
        
        
        if isfield( pooled_contactCaTrials_locdep{d}.phase,'PPI_L')
        PPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.PPI_L;
        meanResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.mResp_L;
        normResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.normResp_L;
        [v,i]=max(pooled_contactCaTrials_locdep{d}.phase.normResp_L);
        PPid_mani{count}(d,1) = i;
        PPh_mani{count}(d,1) = pooled_contactCaTrials_locdep{1}.phase.touchPhase_mid(i);
        end
        
    end
    
    cd (pathName);
end
data.PPI_ctrl=PPI_ctrl;
data.meanResp_phase_ctrl=meanResp_phase_ctrl;
data.normResp_phase_ctrl=normResp_phase_ctrl;
data.PPid_ctrl=PPid_ctrl;
data.PPh_ctrl=PPh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.phase,'PPI_L')
    data.PPI_mani=PPI_mani;
    data.meanResp_phase_mani=meanResp_phase_mani;
    data.normResp_phase_mani=normResp_phase_mani;
    data.PPid_mani=PPid_mani;
    data.PPh_mani=PPh_mani;
end
folder = uigetdir;
cd (folder);
save('Phase Summary Data','data');

