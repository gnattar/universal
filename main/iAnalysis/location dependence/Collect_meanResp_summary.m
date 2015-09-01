function [collected_meanResp_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)
% [collected_meanRespPref_summary_stats,data] = Collect_meanResp_summary(PrefLocFixed)
%Always have PrefLocFixed=1, doesnt make sense otherwise
%% you need to have run whiskloc_dep_stats & whisk_locdep_plot_contour before this
% toquickly run them
% [pooled_contactCaTrials_locdep]= whiskloc_dependence_stats(pooled_contactCaTrials_locdep,[1:size(pooled_contactCaTrials_locdep,2)],'re_totaldK','sigpeak', [12 11 10 9 8],0,0);
% for d = 1: size(pooled_contactCaTrials_locdep,2)
%     [ThKmid,R,T,K,Tk,pooled_contactCaTrials_locdep] = whisk_loc_dependence_plot_contour(pooled_contactCaTrials_locdep,d,'re_totaldK','PR',[0 400],'cf',0,[180 210 230 250 270 300]);
% end

collected_meanResp_summary_stats = {};
count=0;
def={'136','150322','self'};

LPI_ctrl = []; % get both with fitmean -1  and meanResp - 2
LPI_mani=[];
LPd_ctrl =[];
LPd_mani=[];
PLoc_ctrl = [];
PLoc_mani=[];
PTh_ctrl=[];
PTh_mani=[];
TouchTh_ctrl=[];
TouchTh_mani=[];
NormSlopes_ctrl =[];
NormSlopes_mani =[];
meanResp_ctrl=[];
meanResp_mani=[];
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
        
        LPI_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.NL_LPI;
        LPId_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.NL_LPI_diff;
        PTh_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.NL_Pref_thetaattouch;
        TouchTh_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.fitmean.NL_theta_at_touch(:)';
        PLoc_ctrl{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.NL_LP_pos;
        %         PLoc_ctrl{count}(d,2) = pooled_contactCaTrials_locdep{d}.meanResp.NL_LP_pos;
        LP_ctrl{count}(d,1) = find(TouchTh_ctrl{count}(d,:) == PTh_ctrl{count}(d));
        
        
        if isfield( pooled_contactCaTrials_locdep{d},'meanResp');
            LPI_ctrl{count}(d,2) = pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI;
            LPId_ctrl{count}(d,2) = pooled_contactCaTrials_locdep{d}.meanResp.NL_locPI_diff;
            mR_loc = pooled_contactCaTrials_locdep{d}.meanResp.NL_PrefLoc;
            LP_ctrl{count}(d,2) = mR_loc;
            PTh_ctrl{count}(d,2) = pooled_contactCaTrials_locdep{d}.fitmean.NL_theta_at_touch(mR_loc);
        end
        s=pooled_contactCaTrials_locdep{d}.fitmean.NLslopes(:,1,1);
        NormSlopes_ctrl{count}(d,:) = s./mean(s);
        Slopes_ctrl{count}(d,:) = s;
        meanResp_ctrl{count}(d,:) = pooled_contactCaTrials_locdep{d}.meanResp.NL;
        if isfield(pooled_contactCaTrials_locdep{d}.fitmean,'L_LPI')
            
            LPI_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.L_LPI;
            LPId_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.L_LPI_diff;
            if PrefLocFixed
                PLoc_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.NL_LP_pos;
                TouchTh_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.fitmean.L_theta_at_touch(:,2)';
                %              PTh_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.L_Pref_thetaattouch(2);
                %             LP_mani{count}(d,1) = find(TouchTh_mani{count}(d,:) == PTh_mani{count}(d));
                LP_mani{count}(d,1) =  LP_ctrl{count}(d,1) ;
                PTh_mani{count}(d,1) = TouchTh_mani{count}(d,LP_mani{count}(d,1)); % same as NL condition
            else
                PLoc_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.L_LP_pos;
                TouchTh_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.fitmean.L_theta_at_touch(:,2)';
                PTh_mani{count}(d,1) = pooled_contactCaTrials_locdep{d}.fitmean.L_Pref_thetaattouch(2);
                LP_mani{count}(d,1) = find(TouchTh_mani{count}(d,:) == PTh_mani{count}(d));
            end
            if isfield( pooled_contactCaTrials_locdep{d},'meanResp');
                LPI_mani{count}(d,2) = pooled_contactCaTrials_locdep{d}.meanResp.L_locPI;
                LPId_mani{count}(d,2) = pooled_contactCaTrials_locdep{d}.meanResp.L_locPI_diff;
                if PrefLocFixed
                    mR_loc = pooled_contactCaTrials_locdep{d}.meanResp.NL_PrefLoc;
                else
                    mR_loc = pooled_contactCaTrials_locdep{d}.meanResp.L_PrefLoc;
                end
                LP_mani{count}(d,2) = mR_loc;
                PTh_mani{count}(d,2) = pooled_contactCaTrials_locdep{d}.fitmean.L_theta_at_touch(mR_loc,2);
            end
            s=pooled_contactCaTrials_locdep{d}.fitmean.Lslopes(:,1,1);
            NormSlopes_mani{count}(d,:) = s./mean(s);
            Slopes_mani{count}(d,:) = s;
            meanResp_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.meanResp.L;
        end
    end
    
    cd (pathName);
    %     collected_fitmean_summary_stats{count}.info = summary.info;
    collected_fitmean_summary_stats{count}.LPI_ctrl = LPI_ctrl{count}
    collected_fitmean_summary_stats{count}.PLoc_ctrl = PLoc_ctrl{count};
    collected_fitmean_summary_stats{count}.PTh_ctrl= PTh_ctrl{count};
    collected_fitmean_summary_stats{count}.TouchTh_ctrl= TouchTh_ctrl{count};
    collected_fitmean_summary_stats{count}.TouchTh_ctrl= TouchTh_ctrl{count};
    collected_fitmean_summary_stats{count}.LP_ctrl= LP_ctrl{count};
    collected_fitmean_summary_stats{count}.NormSlopes_ctrl= NormSlopes_ctrl{count};
    collected_fitmean_summary_stats{count}.Slopes_ctrl= NormSlopes_ctrl{count};
    collected_fitmean_summary_stats{count}.meanResp_ctrl= meanResp_ctrl{count};
    if isfield(pooled_contactCaTrials_locdep{d}.fitmean,'L_LPI')
        collected_fitmean_summary_stats{count}.LPI_mani = LPI_mani{count}
        collected_fitmean_summary_stats{count}.PLoc_mani = PLoc_mani{count};
        collected_fitmean_summary_stats{count}.PTh_mani= PTh_mani{count};
        collected_fitmean_summary_stats{count}.LP_mani= LP_mani{count};
        collected_fitmean_summary_stats{count}.NormSlopes_mani= NormSlopes_mani{count};
        collected_fitmean_summary_stats{count}.Slopes_mani= Slopes_mani{count};
        collected_fitmean_summary_stats{count}.meanResp_mani= meanResp_mani{count};
    end
    %     info(count) = {summary.info};
    
end
data.LPI_ctrl=LPI_ctrl;
data.LPId_ctrl=LPId_ctrl;
data.PLoc_ctrl=PLoc_ctrl;
data.PTh_ctrl=PTh_ctrl;
data.TouchTh_ctrl=TouchTh_ctrl;
data.LP_ctrl = LP_ctrl;
data.NormSlopes_ctrl=NormSlopes_ctrl;
data.Slopes_ctrl=Slopes_ctrl;
data.meanResp_ctrl=meanResp_ctrl;

if isfield(pooled_contactCaTrials_locdep{d}.fitmean,'L_LPI')
    data.LPI_mani=LPI_mani;
    data.LPId_mani=LPId_mani;
    data.PLoc_mani=PLoc_mani;
    data.PTh_mani=PTh_mani;
    data.TouchTh_mani=TouchTh_mani;
    data.LP_mani = LP_mani;
    data.NormSlopes_mani=NormSlopes_mani;
    data.Slopes_mani=Slopes_mani;
    data.meanResp_mani=meanResp_mani;
end
folder = uigetdir;
cd (folder);
save('Fitmean Summary Data','data');
save('collected_fitmean_summary_stats','collected_fitmean_summary_stats');
%% adding Norm SLopes wrt ctrl mean and at the ctrl Prefered Loc

num_sessions = size(data.Slopes_ctrl,2);

for sess = 1: num_sessions
    num_dends = size(data.Slopes_ctrl{sess},1);
    mean_SlopesCTRL = mean(data.Slopes_ctrl{sess},2);
    tempmat = repmat(mean_SlopesCTRL,1,size(data.Slopes_ctrl{sess},2));
    data.NormSlopesnCTRL_ctrl{sess}=data.Slopes_ctrl{sess}./tempmat;
    if isfield(data,'LPI_mani')
        data.NormSlopesnCTRL_mani{sess}=data.Slopes_mani{sess}./tempmat;
    end
    
    if isfield(data,'LPI_mani')
        if ~PrefLocFixed
            [val,ind] = max(data.NormSlopesnCTRL_mani{sess}');
            data.LPInCTRL_mani{sess} = val';
        end
    end
    [val,ind] = max(data.NormSlopesnCTRL_ctrl{sess}');
    data.LPInCTRL_ctrl{sess} = val';
    
    if isfield(data,'LPI_mani')
        if PrefLocFixed
            for d = 1:num_dends
                data.LPInCTRL_mani{sess}(d,1) = data.NormSlopesnCTRL_mani{sess}(d,ind(d));
            end
        end
        
        
        [maxval,maxind] = max(data.meanResp_mani{sess}');
        [minval,minind] = min(data.meanResp_mani{sess}');
        data.diffmeanResp_mani{sess} = (maxval-minval)';
        if ~PrefLocFixed
            data.meanRespPrefLoc_mani{sess} = maxval';
        end
        [maxval,maxind] = max(data.meanResp_ctrl{sess}');
        [minval,minind] = min(data.meanResp_ctrl{sess}');
        data.diffmeanResp_ctrl{sess} = (maxval-minval)';
        data.meanRespPrefLoc_ctrl{sess} = maxval';
        if PrefLocFixed
            for d = 1:num_dends
                data.meanRespPrefLoc_mani{sess}(d,1) = data.meanResp_mani{sess}(d,maxind(d));
            end
            
        end
    else
        [maxval,maxind] = max(data.meanResp_ctrl{sess}');
        [minval,minind] = min(data.meanResp_ctrl{sess}');
        data.diffmeanResp_ctrl{sess} = (maxval-minval)';
        data.meanRespPrefLoc_ctrl{sess} = maxval';     
        
    end
    
    
end

% data.info=info;
folder = uigetdir;
cd (folder);
save('Fitmean Summary Data','data');
save('collected_fitmean_summary_stats','collected_fitmean_summary_stats');

