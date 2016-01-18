function [data] = Collect_meanResp_summary_NLS()
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)
%Always have PrefLocFixed=1, doesnt make sense otherwise
%% you need to have run whiskloc_dep_stats & whisk_locdep_plot_contour before this
% toquickly run them
% [pooled_contactCaTrials_locdep]= whiskloc_dependence_stats(pooled_contactCaTrials_locdep,[1:size(pooled_contactCaTrials_locdep,2)],'re_totaldK','sigpeak', [12 11 10 9 8],0,0);
% for d = 1: size(pooled_contactCaTrials_locdep,2)
%     [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,'re_totaldK','PR',[0 400],'cf',0,[180 210 230 250 270 300]);
% end

count=0;
def={'136','150322','self'};

% LPI_ctrl = []; % get both with fitmean -1  and meanResp - 2
% LPI_mani=[];
% LPd_ctrl =[];
% LPd_mani=[];
% PLoc_ctrl = [];
% PLoc_mani=[];
% PTh_ctrl=[];
% PTh_mani=[];
% TouchTh_ctrl=[];
% TouchTh_mani=[];
% NormSlopes_ctrl =[];
% NormSlopes_mani =[];
% meanResp_ctrl=[];
% meanResp_mani=[];
info = {};
filename = '';
while(count>=0)
    if strcmp(filename, '');
        [filename,pathName]=uigetfile('*_pooled_contactCaTrials_locdep*.mat','Load fitmean.mat file');
    else
        [filename,pathName]=uigetfile(filename,'Load fitmean.mat file');
    end
    if isequal(filename, 0) || isequal(pathName,0)
        break
    end
    count=count+1;
    load( [pathName filesep filename], '-mat');
    obj = pooled_contactCaTrials_locdep;
    dends = size(obj,2);
    for d =1:dends
        
        
        if isfield( pooled_contactCaTrials_locdep{d}.decoder.NLS,'meanResp');
            LPI_ctrl{count}(d,2) = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_locPI;
            LPId_ctrl{count}(d,2) = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_locPI_diff;
           mR_loc = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL_PrefLoc;
            LP_ctrl{count}(d,2) = mR_loc;
            PLoc_ctrl = mR_loc;
        end
        
        meanResp_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL ./mean(pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL ); % div if normalized;;
        
        if isfield( pooled_contactCaTrials_locdep{d}.decoder.NLS,'meanResp');
            LPI_mani{count}(d,2) = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_locPI;
            LPId_mani{count}(d,2) = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_locPI_diff;
            
            mR_loc = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L_PrefLoc;

            PLoc_mani = mR_loc;
            LP_mani{count}(d,2) = mR_loc;
            
        end
        
        meanResp_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.L ./mean(pooled_contactCaTrials_locdep{d}.decoder.NLS.meanResp.NL ); % div if normalized;;;
    end
end

data.LPI_ctrl = LPI_ctrl;
data.LPId_ctrl = LPId_ctrl;
data.PLoc_ctrl = PLoc_ctrl;

data.LP_ctrl = LP_ctrl;

data.meanResp_ctrl=meanResp_ctrl;

if isfield(pooled_contactCaTrials_locdep{d}.meanResp,'L_locPI')
    data.LPI_mani=LPI_mani;
    data.LPId_mani=LPId_mani;
    data.PLoc_mani=PLoc_mani;
    data.LP_mani = LP_mani;
    data.meanResp_mani=meanResp_mani;
end


num_sessions = size(data.LPI_ctrl,2);

for sess = 1: num_sessions
    num_dends = size(data.LPI_ctrl{sess},1);

    
    if isfield(data,'LPI_mani')
      
        [maxval,maxind] = max(data.meanResp_mani{sess}');
        [minval,minind] = min(data.meanResp_mani{sess}');
        data.diffmeanResp_mani{sess} = (maxval-minval)';

            data.meanRespPrefLoc_mani{sess} = maxval';

        [maxval,maxind] = max(data.meanResp_ctrl{sess}');
        [minval,minind] = min(data.meanResp_ctrl{sess}');
        data.diffmeanResp_ctrl{sess} = (maxval-minval)';
        data.meanRespPrefLoc_ctrl{sess} = maxval';

            for d = 1:num_dends
                data.meanRespPrefLoc_mani{sess}(d,1) = data.meanResp_mani{sess}(d,maxind(d));
            end
    else
        [maxval,maxind] = max(data.meanResp_ctrl{sess}');
        [minval,minind] = min(data.meanResp_ctrl{sess}');
        data.diffmeanResp_ctrl{sess} = (maxval-minval)';
        data.meanRespPrefLoc_ctrl{sess} = maxval';
        
    end

end


folder = uigetdir;
cd (folder);
save('Fitmean Summary Data','data');


