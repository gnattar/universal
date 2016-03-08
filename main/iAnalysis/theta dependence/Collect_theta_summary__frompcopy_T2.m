function [data] = Collect_theta_summary__frompcopy_T2(dends,r,norm_cond)
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
        TPI_ctrl{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        TNPI_ctrl{count}(d,:) = norm(NPid); 
        PTid_ctrl{count}(d,1) = i;
        PTh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.touchTheta_mid(i);
        NPTid_ctrl{count}(d,:) =  NPid;
        
        if isfield( pooled_contactCaTrials_locdep{dends(d)}.thetadep,'TPI_L')
        meanResp_theta_mani{count}(d,:) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.mResp_L;
        mR_L = pooled_contactCaTrials_locdep{dends(d)}.thetadep.mResp_L;
        if strcmp(norm_cond,'ctrl_norm')
            norm= (mR_L-min(mR_L))./min(mR_NL);
        elseif strcmp(norm_cond,'self_norm')
            norm= (mR_L-min(mR_L))./min(mR_L);
        end
            
        
        normResp_theta_mani{count}(d,:) =norm;
        [v,i] = max(norm);
        TPI_mani{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        TNPI_mani{count}(d,:) = norm(NPid); 
        
        PTid_mani{count}(d,1) = i;
        NPTid_mani{count}(d,:) =  NPid;
%         
%         [v,i]=max(pooled_contactCaTrials_locdep{d}.theta.normResp_L);
        PTh_mani{count}(d,1) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.touchTheta_mid(i);
        NPTh_mani{count}(d,:) = pooled_contactCaTrials_locdep{dends(d)}.thetadep.touchTheta_mid(NPid);

        FrCh{count}(d,:) = (mR_L-mR_NL)./mR_NL;
%         FrCh{count}(d,:) = (PPI_mani{count}(d,1)-PPI_ctrl{count}(d,1))./PPI_ctrl{count}(d,1);

        PrefCh{count}(d,:) = PTid_mani{count}(d,1) - PTid_ctrl{count}(d,1);
        CellID{count}(d,:) = dends(d);
        end
        
    end
    
    cd (pathName);
end

data.meanResp_theta_ctrl=meanResp_theta_ctrl;
data.normResp_theta_ctrl=normResp_theta_ctrl;
data.TPI_ctrl=TPI_ctrl;
data.TNPI_ctrl=TNPI_ctrl;
data.PTid_ctrl=PTid_ctrl;
data.NPTid_ctrl=NPTid_ctrl;
data.PTh_ctrl=PTh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.thetadep,'TPI_L')   
    data.meanResp_theta_mani=meanResp_theta_mani;
    data.normResp_theta_mani=normResp_theta_mani;
    data.TPI_mani=TPI_mani;
    data.TNPI_mani=TNPI_mani;
    data.PTid_mani=PTid_mani;
     data.NPTid_mani=NPTid_mani;
    data.PTh_mani=PTh_mani;
    data.NPTh_mani=NPTh_mani;
    
    data.FrCh=FrCh;
    data.PrefCh=PrefCh;
end
data.CellID = CellID;
data.run = r;
% folder = uigetdir;
% cd (folder);
save(['Theta Summary Data r' r],'data');

