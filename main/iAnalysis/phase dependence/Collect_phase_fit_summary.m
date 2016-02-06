function [data] = Collect_phase_fit_summary()
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
        slopes_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.fit.NL_fitparam(:,1,1);
        normSlopes_ctrl {count}(d,:)= slopes_ctrl{count}(d,1)./nanmean(slopes_ctrl{count}(d,1));
       
        [v,i]=max(normSlopes_ctrl{count}(d,:));
        PPI_ctrl{count}(d,1) = v;
        PPid_ctrl{count}(d,1) = i;
        PPh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.touchPhase_mid(i);        
        
        if isfield( pooled_contactCaTrials_locdep{d}.phase,'PPI_L')
         slopes_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.phase.fit.L_fitparam(:,1,1);
         normSlopes_mani{count}(d,:) = slopes_mani{count}(d,1)./nanmean(slopes_ctrl{count}(d,1));
        [v,i]=max(normSlopes_mani{count}(d,:));
        PPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.fit.L_PPI;
        PPid_mani{count}(d,1) = i;
        PPh_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.phase.touchPhase_mid(i);
        end
        
    end
    
    cd (pathName);
end
data.PPI_ctrl=PPI_ctrl;
data.slopes_ctrl=slopes_ctrl;
data.normSlopes_ctrl=normSlopes_ctrl;
data.PPid_ctrl=PPid_ctrl;
data.PPh_ctrl=PPh_ctrl;
if isfield( pooled_contactCaTrials_locdep{1}.phase,'PPI_L')
    data.PPI_mani=PPI_mani;
    data.slopes_mani=slopes_mani;
    data.normSlopes_mani=normSlopes_mani;
    data.PPid_mani=PPid_mani;
    data.PPh_mani=PPh_mani;
end
folder = uigetdir;
cd (folder);
save('Phase Slope Summary Data','data');

