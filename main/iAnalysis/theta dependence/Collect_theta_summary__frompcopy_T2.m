function [data] = Collect_theta_summary__frompcopy_T2(dends,r)
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*pooled_contactCaTrials_thetadep.mat','Load .mat file');
    else
        [filename,pathName]=uigetfile( filename,'Load thetadep.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
%     dends = size(obj,2);
    
    for d =1:length(dends)
        meanResp_theta_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.mResp_NL;
        mR_NL = pooled_contactCaTrials_locdep{dends(d)}.thetadep.mResp_NL;
        norm =(mR_NL-min(mR_NL))./min(mR_NL);
        normResp_theta_ctrl{count}(d,:) = norm;
        [v,i] = max(norm);
        PPI_ctrl{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        PNPI_ctrl{count}(d,:) = norm(NPid); 
        PPid_ctrl{count}(d,1) = i;
        PPh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.touchTheta_mid(i);
        NPPid_ctrl{count}(d,:) =  NPid;
        
        if isfield( pooled_contactCaTrials_locdep{dends(d)}.thetadep,'PPI_L')
        meanResp_theta_mani{count}(d,:) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.mResp_L;
        mR_L = pooled_contactCaTrials_locdep{dends(d)}.thetadep.mResp_L;
        norm= (mR_L-min(mR_L))./min(mR_L);
        normResp_theta_mani{count}(d,:) =norm;
        [v,i] = max(norm);
        PPI_mani{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        PNPI_mani{count}(d,:) = norm(NPid); 
        
        PPid_mani{count}(d,1) = i;
        NPPid_mani{count}(d,:) =  NPid;
%         
%         [v,i]=max(pooled_contactCaTrials_locdep{d}.theta.normResp_L);
        PPh_mani{count}(d,1) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.touchTheta_mid(i);
        NPPh_mani{count}(d,:) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.touchTheta_mid(NPid);

        FrCh{count}(d,:) = (mR_L-mR_NL)./mR_NL;
%         FrCh{count}(d,:) = (PPI_mani{count}(d,1)-PPI_ctrl{count}(d,1))./PPI_ctrl{count}(d,1);

        PrefCh{count}(d,:) = PPid_mani{count}(d,1) - PPid_ctrl{count}(d,1);
        CellID{count}(d,:) = dends(d);
        end
        
    end
    
    cd (pathName);
end

data.meanResp_theta_ctrl=meanResp_theta_ctrl;
data.normResp_theta_ctrl=normResp_theta_ctrl;
data.PPI_ctrl=PPI_ctrl;
data.PNPI_ctrl=PNPI_ctrl;
data.PPid_ctrl=PPid_ctrl;
data.NPPid_ctrl=NPPid_ctrl;
data.PPh_ctrl=PPh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.thetadep,'PPI_L')   
    data.meanResp_theta_mani=meanResp_theta_mani;
    data.normResp_theta_mani=normResp_theta_mani;
    data.PPI_mani=PPI_mani;
    data.PNPI_mani=PNPI_mani;
    data.PPid_mani=PPid_mani;
     data.NPPid_mani=NPPid_mani;
    data.PPh_mani=PPh_mani;
    data.NPPh_mani=NPPh_mani;
    
    data.FrCh=FrCh;
    data.PrefCh=PrefCh;
end
data.CellID = CellID;
data.run = r;
% folder = uigetdir;
% cd (folder);
save(['Theta Summary Data r' r],'data');

