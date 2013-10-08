function [contact_inds, contact_direct] = Contact_detection_session_auto(wsArray, param)
%
% Using same parameters for all whiskers and all trials.
% param, contact detection parameters, with fields: 
%        threshDistToBarCenter
%        thresh_deltaKappa
%        bar_time_window
% kappaThresh_prior: [a b c], minimal threshold for Kappa change for different whiskers (stiffness)

nTrials = wsArray.nTrials;
% if isempty(bar_time_window)
%     btw = wsArray.bar_time_window;
% else
%     btw = bar_time_window;
% end
% 
%if isempty(param.bar_time_window) 
%     if ~isempty(wsArray.bar_time_window)
%         btw = repmat({wsArray.bar_time_window} , nTrials, 1);
%     else
%         btw = cellfun(@(x) x.bar_time_win, wsArray.ws_trials,'UniformOutput',false);
%     end
% else
%     if ~iscell(param.bar_time_window)
%         btw = repmat({param.bar_time_window} , nTrials, 1);
%     else
%         btw = param.bar_time_window;
%     end
% end

if isempty(param.bar_time_window) 
    btw = wsArray.bar_time_window;
    
else
    btw = param.bar_time_window;
end 

 hw = waitbar(0, sprintf('Contact detection for whole session...')); 

for i = 1:nTrials
    %%
    ws = wsArray.ws_trials{i};
    contact_inds{i} = cell(1, length(wsArray.trajIDs));
    contact_direct{i} = cell(1, length(wsArray.trajIDs));
%     if ws.useFlag == 0
%         continue
%     end
    %%
    barPos = ws.bar_pos_trial; 
%     barRadiusInPx = ws.barRadius;
    barRadiusInPx = 13;
     poletime = ws.bar_time_win;
    if isempty(poletime)
        poletime = [.9,2.5];
    end    
    for k = 1: length(wsArray.trajIDs)
        ts = ws.time{k};
        d2bar = ws.distToBar{k}./wsArray.pxPerMm;
% % %         kappa       = ws.kappa{k};
% % %         k0 = kappa(ws.time{k}> poletime(1) & ws.time{k} < poletime(2));
% % %         baseKappa = nanmean ( kappa ( ( abs(k0) < prctile(abs(k0),10 ) ) ) );
% % %         deltaKappa = (kappa - baseKappa)*1000; % in 1/meter       
        deltaKappa = ws.deltaKappa{k};
        tip_coords = ws.get_tip_coords(wsArray.trajIDs(k));
        barFrInds = find(ts > btw(1) & ts < btw(2));        
        threshDist = param.threshDistToBarCenter; % {k}(i,:);
        threshDist = param.threshDistToBarCenter;
        threshKappa = param.thresh_deltaKappa;
        threshDist0 = 2.5;
%         fprintf('Trial %d, wNo %d\t', i, k);
        if(isempty(barFrInds))
            contact_inds{i}{k}=[];
            contact_direct{i}{k} =[]; 
            ['Check tracker files for trial '  wsArray.ws_trials{1,i}.trackerFileName ' for whisker ' num2str(k)]
            continue
        else   
%             [contact_inds{i}{k}, contact_direct{i}{k}] = whisker_contact_detector_auto_thresh( d2bar, deltaKappa, barFrInds,KaThresh, [], threshDist);
             (['Trial' num2str(i) ' calling whisker_contact_detector_auto_thresh'])
             [contact_inds{i}{k}, contact_direct{i}{k}] = whisker_contact_detector_auto_thresh( d2bar, deltaKappa, barFrInds, threshKappa,threshDist0,threshDist,ts);

%         contact_inds{i}{k} = whisker_contact_detector4 ( d2bar, deltaKappa, ...
%             barFrInds, threshDist, threshKappa,barPos,tip_coords,barRadiusInPx,ts);


        end
    end
     waitbar(i/wsArray.nTrials, hw, sprintf('Contact detection %d trials', i));

end
 delete(hw);