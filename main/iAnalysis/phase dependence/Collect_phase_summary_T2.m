function [data] = Collect_phase_summary_T2()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*_pooled_contactCaTrials_phasedep*.mat','Load .mat file');
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
        meanResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.mResp_NL;
        mR_NL = pooled_contactCaTrials_locdep{d}.phase.mResp_NL;
%          normResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.normResp_NL;
        norm =(mR_NL-min(mR_NL))./min(mR_NL);
        normResp_phase_ctrl{count}(d,:) = norm;
        [v,i] = max(norm);
%         PPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.PPI_NL;
        PPI_ctrl{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        PNPI_ctrl{count}(d,:) = norm(NPid); 
        PPid_ctrl{count}(d,1) = i;
        PPh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.touchPhase_mid(i);
        NPPid_ctrl{count}(d,:) =  NPid;
        
        if isfield( pooled_contactCaTrials_locdep{d}.phase,'PPI_L')
        meanResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.mResp_L;
        mR_L = pooled_contactCaTrials_locdep{d}.phase.mResp_L;
%                 normResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.normResp_L;
        norm= (mR_L-min(mR_L))./min(mR_L);
        normResp_phase_mani{count}(d,:) =norm;
        [v,i] = max(norm);
%                 PPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.PPI_L;
        PPI_mani{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        PNPI_mani{count}(d,:) = norm(NPid); 
        
        PPid_mani{count}(d,1) = i;
        NPPid_mani{count}(d,:) =  NPid;
%         
%         [v,i]=max(pooled_contactCaTrials_locdep{d}.phase.normResp_L);
        PPh_mani{count}(d,1) = pooled_contactCaTrials_locdep{1}.phase.touchPhase_mid(i);
        NPPh_mani{count}(d,:) = pooled_contactCaTrials_locdep{1}.phase.touchPhase_mid(NPid);

        FrCh{count}(d,:) = (mR_L-mR_NL)./mR_NL;
%         FrCh{count}(d,:) = (PPI_mani{count}(d,1)-PPI_ctrl{count}(d,1))./PPI_ctrl{count}(d,1);

        PrefCh{count}(d,:) = PPid_mani{count}(d,1) - PPid_ctrl{count}(d,1);
 
        end
        
    end
    
    cd (pathName);
end

data.meanResp_phase_ctrl=meanResp_phase_ctrl;
data.normResp_phase_ctrl=normResp_phase_ctrl;
data.PPI_ctrl=PPI_ctrl;
data.PNPI_ctrl=PNPI_ctrl;
data.PPid_ctrl=PPid_ctrl;
data.NPPid_ctrl=NPPid_ctrl;
data.PPh_ctrl=PPh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.phase,'PPI_L')   
    data.meanResp_phase_mani=meanResp_phase_mani;
    data.normResp_phase_mani=normResp_phase_mani;
    data.PPI_mani=PPI_mani;
    data.PNPI_mani=PNPI_mani;
    data.PPid_mani=PPid_mani;
     data.NPPid_mani=NPPid_mani;
    data.PPh_mani=PPh_mani;
    data.NPPh_mani=NPPh_mani;
    
    data.FrCh=FrCh;
    data.PrefCh=PrefCh;
end
folder = uigetdir;
cd (folder);
save('Phase Summary Data','data');

