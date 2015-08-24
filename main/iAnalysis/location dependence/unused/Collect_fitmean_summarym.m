function [collected_fitmean_summary_stats,data] = Collect_fitmean_summary()

collected_fitmean_summary_stats = {};
count=0;
  def={'136','150322','self'};
  
LPI_ctrl = [];
LPI_mani=[];
PLoc_ctrl = [];
PLoc_mani=[];
PTh_ctrl=[];
PTh_mani=[];
TouchTh_ctrl=[];
TouchTh_mani=[];

info = {};

while(count>=0)
    [filename,pathName]=uigetfile('*_pooled_contactCaTrials_locdep_fitmean.mat','Load fitmean.mat file');
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
    for d =1:dends
        LPI_ctrl{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.NL_LPI;
        PLoc_ctrl{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.NL_LP_pos;
        PTh_ctrl{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.NL_Pref_thetaattouch;
        TouchTh_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.fitmean.NL_theta_at_touch(:)';
        
        if isfield(pooled_contactCaTrials_locdep{d}.fitmean,'L_LPI')
            LPI_mani{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.L_LPI;
            PLoc_mani{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.L_LP_pos;
            PTh_mani{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.L_Pref_thetaattouch;
            TouchTh_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.fitmean.L_theta_at_touch(:)';
        end
    end
    
    cd (pathName);
%     collected_fitmean_summary_stats{count}.info = summary.info; 
    collected_fitmean_summary_stats{count}.LPI_ctrl = LPI_ctrl{count}
    collected_fitmean_summary_stats{count}.PLoc_ctrl = PLoc_ctrl{count};    
    collected_fitmean_summary_stats{count}.PTh_ctrl= PTh_ctrl{count};
    collected_fitmean_summary_stats{count}.TouchTh_ctrl= TouchTh_ctrl{count};
    
    collected_fitmean_summary_stats{count}.LPI_mani = LPI_mani{count}
    collected_fitmean_summary_stats{count}.PLoc_mani = PLoc_mani{count};    
    collected_fitmean_summary_stats{count}.PTh_mani= PTh_mani{count};
    collected_fitmean_summary_stats{count}.TouchTh_mani= TouchTh_mani{count};
%     info(count) = {summary.info};
    
end
data.LPI_ctrl=LPI_ctrl;
data.PLoc_ctrl=PLoc_ctrl;
data.PTh_ctrl=PTh_ctrl;
data.TouchTh_ctrl=TouchTh_ctrl;

data.LPI_mani=LPI_mani;
data.PLoc_mani=PLoc_mani;
data.PTh_mani=PTh_mani;
data.TouchTh_mani=TouchTh_mani;

data.info=info;
folder = uigetdir;
cd (folder);
save('Firmean Summary Data','data');
save('collected_fitmean_summary_stats','collected_fitmean_summary_stats');
