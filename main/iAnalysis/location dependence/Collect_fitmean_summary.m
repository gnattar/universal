function [collected_fitmean_summary_stats,data] = Collect_fitmean_summary()

collected_fitmean_summary_stats = {};
count=0;
def={'136','150322','self'};

LPI_ctrl = [];
LPI_mani=[];
LP_ctrl =[];
LP_mani=[];
PLoc_ctrl = [];
PLoc_mani=[];
PTh_ctrl=[];
PTh_mani=[];
TouchTh_ctrl=[];
TouchTh_mani=[];
NormSlopes_ctrl =[];
NormSlopes_mani =[];
info = {};

while(count>=0)
    [filename,pathName]=uigetfile('*_pooled_contactCaTrials_locdep_fitmean*.mat','Load fitmean.mat file');
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
        LP_ctrl{count}(d) = find(TouchTh_ctrl{count}(d,:) == PTh_ctrl{count}(d));
        s=pooled_contactCaTrials_locdep{d}.fitmean.NLslopes(:,1,1);
        NormSlopes_ctrl{count}(d,:) = s./mean(s);

        
        if isfield(pooled_contactCaTrials_locdep{d}.fitmean,'L_LPI')
            LPI_mani{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.L_LPI;
            PLoc_mani{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.L_LP_pos;
            PTh_mani{count}(d) = pooled_contactCaTrials_locdep{d}.fitmean.L_Pref_thetaattouch;
            TouchTh_mani{count}(d,:) = pooled_contactCaTrials_locdep{d}.fitmean.L_theta_at_touch(:)';
            LP_mani{count}(d) = find(TouchTh_mani{count}(d,:) == PTh_mani{count}(d));
            s=pooled_contactCaTrials_locdep{d}.fitmean.Lslopes(:,1,1);
            NormSlopes_mani{count}(d,:) = s./mean(s);
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
    if isfield(pooled_contactCaTrials_locdep{d}.fitmean,'L_LPI')
        collected_fitmean_summary_stats{count}.LPI_mani = LPI_mani{count}
        collected_fitmean_summary_stats{count}.PLoc_mani = PLoc_mani{count};
        collected_fitmean_summary_stats{count}.PTh_mani= PTh_mani{count};
        collected_fitmean_summary_stats{count}.LP_mani= LP_mani{count};
        collected_fitmean_summary_stats{count}.NormSlopes_mani= NormSlopes_mani{count};

    end
    %     info(count) = {summary.info};
    
end
data.LPI_ctrl=LPI_ctrl;
data.PLoc_ctrl=PLoc_ctrl;
data.PTh_ctrl=PTh_ctrl;
data.TouchTh_ctrl=TouchTh_ctrl;
data.LP_ctrl = LP_ctrl;
data.NormSlopes_ctrl=NormSlopes_ctrl;

data.LPI_mani=LPI_mani;
data.PLoc_mani=PLoc_mani;
data.PTh_mani=PTh_mani;
data.TouchTh_mani=TouchTh_mani;
data.LP_mani = LP_mani;
data.NormSlopes_mani=NormSlopes_mani;

% data.info=info;
folder = uigetdir;
cd (folder);
save('Fitmean Summary Data','data');
save('collected_fitmean_summary_stats','collected_fitmean_summary_stats');

%% plot stuff
LPI= cell2mat(data.LPI_ctrl)';
PTh= cell2mat(data.PTh_ctrl)';
PLoc= cell2mat(data.PLoc_ctrl)';
PTh= cell2mat(data.PTh_ctrl)';
NormS= cell2mat(data.NormSlopes_ctrl)';

figure; hold on;
count = 1;totaldends = length(LPI);
thetabins = [-50:5:50];
tempdata= nan(totaldends,length(thetabins));
for sess = 1: size(data.NormSlopes_ctrl,2)
dends = size(data.NormSlopes_ctrl{sess},1);
for d = 1:dends
    touch_th = data.TouchTh_ctrl{sess}(d,:);
    Pref_touch_th = data.PTh_ctrl{sess}(d);
    temp = touch_th-Pref_touch_th;
    x = 5.*round(temp/5); % rounding to nearest 5
    y = data.NormSlopes_ctrl{sess}(d,:);
    
    plot(x,y,'o-','color',[.5 .5 .5],'linewidth',.2); hold on;
    for t = 1:length(x)        
        tempdata (count,find(thetabins==x(t))) = y(t);
    end
    count = count+1;
end
end
hold on;h= errorbar(thetabins,nanmean(tempdata),nanstd(tempdata)./sqrt(nansum(tempdata)),'ko-')
set(h,'linewidth',2,'markersize',6);
 axis([-50 50 0 6]); 
xlabel('dTheta (deg from max)','Fontsize',10);
ylabel('Norm. Slope dFF vs |dK|','Fontsize',10);
set(gca,'Fontsize',16,'Xtick',[-50:10:50]);


figure;hist(PTh,[-30:5:30],'plot');
xlabel('Prefered Touch theta (deg)','Fontsize',10);title('Pref Touch Theta Dist');
set(gca,'Fontsize',16,'Xtick',[-30:10:30]);
figure;hist(LPI,[.5:.5:6],'plot')
xlabel('Loc Pref Index','Fontsize',10);title('Loc Pref Ind Dist');
set(gca,'Fontsize',16);

