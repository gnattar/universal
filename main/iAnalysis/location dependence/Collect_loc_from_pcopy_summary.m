function [data] = Collect_loc_from_pcopy_summary()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*pooled_contactCaTrials_locdep.mat','Load .mat file');
    else
        [filename,pathName]=uigetfile( filename,'Load locdep.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
    for d =1:dends
        
        LPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.locdep.LPI_NL;
        meanResp_loc_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.locdep.mResp_NL;
        normResp_loc_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.locdep.normResp_NL;
        [v,i]=max(pooled_contactCaTrials_locdep{d}.locdep.normResp_NL);
        PLid_ctrl{count}(d,1) = i;
        PL_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.locdep.locs(i);
        
        
        if isfield( pooled_contactCaTrials_locdep{d}.locdep,'LPI_L')
        LPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.locdep.LPI_L;
        meanResp_loc_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.locdep.mResp_L;
        normResp_loc_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.locdep.normResp_L;
        [v,i]=max(pooled_contactCaTrials_locdep{d}.locdep.normResp_L);
        PLid_mani{count}(d,1) = i;
        PL_mani{count}(d,1) = pooled_contactCaTrials_locdep{1}.locdep.locs(i);
        NormCh{count}(d,:) = pooled_contactCaTrials_locdep{d}.locdep.normChange;
        FrCh{count}(d,:) = pooled_contactCaTrials_locdep{d}.locdep.frChange;
        end
        
    end
    
    cd (pathName);
end
data.LPI_ctrl=LPI_ctrl;
data.meanResp_loc_ctrl=meanResp_loc_ctrl;
data.normResp_loc_ctrl=normResp_loc_ctrl;
data.PLid_ctrl=PLid_ctrl;
data.PL_ctrl=PL_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.locdep,'LPI_L')
    data.LPI_mani=LPI_mani;
    data.meanResp_loc_mani=meanResp_loc_mani;
    data.normResp_loc_mani=normResp_loc_mani;
    data.PLid_mani=PLid_mani;
    data.PL_mani=PL_mani;
    data.FrCh=FrCh;
    data.NormCh=NormCh;
end
% folder = uigetdir;
% cd (folder);
save('Loc Summary Data','data');

