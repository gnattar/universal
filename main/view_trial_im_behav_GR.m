function view_bytrial()
figure('name','View Trials','numbertitle','off','color','w')
% allLickTimes = sesObj.behavArray.get_all_lick_times([]);
fig_export_dir = 'Single_Trial_Plottings_181851_22';
%%
yl_dff = [-50 350];
[fname,path]=uigetfile(pwd,'contact_CaTrials obj');
load([path fname],'-mat');
numtrials = size(obj.dff,2);
numrois= size(obj.dff,1);
for trNo = 1:numtrials

    clf
    roiNo = [1 3 5]; 

    % Get Ca signal and whisker variable in trials
    dffarray = obj(trNo).dff;
    dff = mean(dffarray,3);
    ts=[1:size(dffarray,2)]*obj(trNo).FrameTime;
    
    % Determine trial type
    soloTrNo =  obj(trNo).TrialName

    trType = obj(trNo).trialtype;
    wskNo = '2';
    ts_wsk = obj(trNo).ts_wsk;
    
    % Plot Ca signal trial
%     lickTime_trial = allLickTimes(allLickTimes(:,1)==trNo,3);
     licks=obj(trNo).licks;
     lickTime_trial = licks(licks >3);
%     barOnOff = [sesObj.behavArray.trials{trNo}.pinDescentOnsetTime, sesObj.behavArray.trials{trNo}.pinAscentOnsetTime+0.3];
      barOnOff = [1, 2.5+0.3];

    ha(1) = subaxis(5,1,1, 'MarginTop', 0.1);
    plot(ts, dff(trNo, :), 'k','linewidth',2)
    line([lickTime_trial'; lickTime_trial'], ...
        [zeros(1,length(lickTime_trial)); ones(1,length(lickTime_trial))*20],'color','m','linewidth',2)
    line([barOnOff; barOnOff], [0 0; 100 100], 'color','c','linewidth',2);
    ylabel('dF/F','fontsize',15)
    ylim(yl_dff);
%     title(sprintf('Trial %d, ROI %d, wsk %d, %s',trNo, roiNo, wskNo, trType), 'fontsize',20)
    title(sprintf('Trial %d, ROI mean(1 3 5), wsk %d, %s',trNo, wskNo, trType), 'fontsize',20)
    % Plot whisker velocity trial
    ha(2) = subaxis(5,1,2, 'sv', 0.05);
%     vel = sesObj.wsArray.wl_trials{trNo}.Velocity{wskNo};
    vel =  obj(trNo).velocity;  
    plot(ts_wsk, vel, 'r');
    ylabel('Velocity','fontsize',15)
    % Plot whisker setpoint trial
    ha(3) = subaxis(5,1,3, 'sv', 0.05);
%     setpt = sesObj.wsArray.wl_trials{trNo}.Setpoint{wskNo};
    setpt = obj(trNo).kappa;   
    plot(ts_wsk, setpt,'r');
%     ylabel('Setpoint','fontsize',15)
    ylabel('Kappa','fontsize',15)
    % Plot whisker amplitude trial
% % %     ha(4) = subaxis(5,1,4, 'sv', 0.05);
% % %     wAmp = sesObj.wsArray.wl_trials{trNo}.Amplitude{wskNo};
% % %     plot(ts_wsk, wAmp,'r');
% % %     ylabel('Amplitude','fontsize',15)
    ha(4) = subaxis(5,1,4, 'sv', 0.05);
    wAmp = obj(trNo).deltaKappa;
    plot(ts_wsk, wAmp,'r');
    ylabel('deltaKappa','fontsize',15)
    % Plot whisker theta angle trial
    ha(5) = subaxis(5,1,5, 'sv', 0.05);
%     theta = sesObj.wsArray.wl_trials{trNo}.theta{wskNo};
    theta=obj(trNo).theta;
    plot(ts_wsk, theta,'r');
    ylabel('Theta','fontsize',15)
    xlabel('Time (s)','fontsize',20)
    set(ha, 'box','off', 'xlim',[0 8])
    figure(gcf)
%     export_fig(fullfile(fig_export_dir, sprintf('ROI_%d_wsk_%d_Trial_%d',roiNo,wskNo,trNo)),gcf,'-png')
    export_fig(fullfile(fig_export_dir, sprintf('ROI_mean(1 3 5)_wsk_%d_Trial_%d',wskNo,trNo)),gcf,'-png');
end