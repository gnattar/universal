function [data] = Collect_loc_summary_T2()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*_pooled_contactCaTrials_locdep*.mat','Load .mat file');
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
        meanResp_loc_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.meanResp.NL;
        mR_NL = pooled_contactCaTrials_locdep{d}.meanResp.NL;
%         normResp_loc_ctrl{count}(d,:) = meanResp_loc_ctrl{count}(d,:)./mean(meanResp_loc_ctrl{count}(d,:));
        norm= (mR_NL-min(mR_NL))./min(mR_NL);
        normResp_loc_ctrl{count}(d,:) =norm;
        [v,i] = max(norm);
%         LPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI;
        LPI_ctrl{count}(d,1) =norm(i);
        NPid = setxor([1:length(norm)],i);
        LNPI_ctrl{count}(d,:) = norm(NPid); 

        PLid_ctrl{count}(d,1) = i;
        NPLid_ctrl{count}(d,:) =  NPid;
        
        
        if isfield( pooled_contactCaTrials_locdep{d}.meanResp,'L_locPI')
        meanResp_loc_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.meanResp.L;
        mR_L = pooled_contactCaTrials_locdep{d}.meanResp.L;
%         normResp_loc_mani{count}(d,:) = meanResp_loc_mani{count}(d,:)./mean(meanResp_loc_mani{count}(d,:));
        norm= (mR_L-min(mR_L))./min(mR_L);
        normResp_loc_mani{count}(d,:) =norm;
        [v,i] = max(norm);
%         LPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI;
        LPI_mani{count}(d,1) =norm(i);
        NPid = setxor([1:length(norm)],i);
        LNPI_mani{count}(d,:) = norm(NPid); 

        PLid_mani{count}(d,1) = i;
        NPLid_mani{count}(d,:) =  NPid;
        
         FrCh{count}(d,:) = (mR_L-mR_NL)./mR_NL;
%         FrCh{count}(d,:) = (LPI_mani{count}(d,1)-LPI_ctrl{count}(d,1))./LPI_ctrl{count}(d,1);

        PrefCh{count}(d,:) = PLid_mani{count}(d,1) - PLid_ctrl{count}(d,1);
        end
        
    end
    
    cd (pathName);
end

data.meanResp_loc_ctrl=meanResp_loc_ctrl;
data.normResp_loc_ctrl=normResp_loc_ctrl;
data.LPI_ctrl=LPI_ctrl;
data.LNPI_ctrl=LNPI_ctrl;
data.PLid_ctrl=PLid_ctrl;
data.NPLid_ctrl=NPLid_ctrl;
% data.PL_ctrl=PL_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.meanResp,'L_locPI')
    
    data.meanResp_loc_mani=meanResp_loc_mani;
    data.normResp_loc_mani=normResp_loc_mani;
    data.LPI_mani=LPI_mani;
    data.LNPI_mani=LNPI_mani;
    data.PLid_mani=PLid_mani;
    data.NPLid_mani=NPLid_mani;
%     data.PL_mani=PL_mani;
    data.FrCh=FrCh;
    data.PrefCh = PrefCh;
end
folder = uigetdir;
cd (folder);
save('Loc Summary Data','data');

