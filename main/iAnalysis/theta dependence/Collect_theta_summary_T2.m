function [data] = Collect_theta_summary_T2()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)

count=0;

filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*_pooled_contactCaTrials_thetadep*.mat','Load .mat file');
    else
        [filename,pathName]=uigetfile( filename,'Load thetadep.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
    for d =1:dends
        meanResp_theta_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.theta.mResp_NL;
        mR_NL = pooled_contactCaTrials_locdep{d}.theta.mResp_NL;
%          normResp_phase_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.normResp_NL;
        norm =(mR_NL-min(mR_NL))./min(mR_NL);
        normResp_theta_ctrl{count}(d,:) = norm;
        [v,i] = max(norm);
        TPI_ctrl{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        TNPI_ctrl{count}(d,:) = norm(NPid); 
        TPid_ctrl{count}(d,1) = i;
        PTh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.theta.touchTheta_mid(i);
        TNPid_ctrl{count}(d,:) =  NPid;
        
        if isfield( pooled_contactCaTrials_locdep{d}.theta,'TPI_L')
        meanResp_theta_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.theta.mResp_L;
        mR_L = pooled_contactCaTrials_locdep{d}.theta.mResp_L;
%                 normResp_phase_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.normResp_L;
        norm= (mR_L-min(mR_L))./min(mR_L);
        normResp_theta_mani{count}(d,:) =norm;
        [v,i] = max(norm);
%                 PPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.PPI_L;
        TPI_mani{count}(d,1) = norm(i);
        NPid = setxor([1:length(norm)],i);
        TNPI_mani{count}(d,:) = norm(NPid); 
        
        TPid_mani{count}(d,1) = i;
        TNPid_mani{count}(d,:) =  NPid;
%         
%         [v,i]=max(pooled_contactCaTrials_locdep{d}.phase.normResp_L);
        PTh_mani{count}(d,1) = pooled_contactCaTrials_locdep{1}.theta.touchTheta_mid(i);
        NPTh_mani{count}(d,:) = pooled_contactCaTrials_locdep{1}.theta.touchTheta_mid(NPid);

        FrCh{count}(d,:) = (mR_L-mR_NL)./mR_NL;
%         FrCh{count}(d,:) = (PPI_mani{count}(d,1)-PPI_ctrl{count}(d,1))./PPI_ctrl{count}(d,1);

        PrefCh{count}(d,:) = TPid_mani{count}(d,1) - TPid_ctrl{count}(d,1);
 
        end
        
    end
    
    cd (pathName);
end

data.meanResp_theta_ctrl=meanResp_theta_ctrl;
data.normResp_theta_ctrl=normResp_theta_ctrl;
data.TPI_ctrl=TPI_ctrl;
data.TNPI_ctrl=TNPI_ctrl;
data.TPid_ctrl=TPid_ctrl;
data.TNPid_ctrl=TNPid_ctrl;
data.PTh_ctrl=PTh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.theta,'TPI_L')   
    data.meanResp_theta_mani=meanResp_theta_mani;
    data.normResp_theta_mani=normResp_theta_mani;
    data.TPI_mani=TPI_mani;
    data.TNPI_mani=TNPI_mani;
    data.TPid_mani=TPid_mani;
     data.TNPid_mani=TNPid_mani;
    data.PTh_mani=PTh_mani;
    data.NPTh_mani=NPTh_mani;
    
    data.FrCh=FrCh;
    data.PrefCh=PrefCh;
end
folder = uigetdir;
cd (folder);
save('Theta Summary Data','data');

