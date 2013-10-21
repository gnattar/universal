function Batch_process_multi_session_whisker_data_GR4(data_base_dir, varargin)
%% Batch processing multi session whisker data


 cd(data_base_dir);
% date_dir = dir('20*');
% for i = 1:length(date_dir)
%     cd(date_dir(i).name);
    results_save_dir = pwd;

    fn_sessionInfo = dir('SessionInfo*');
    subses_dir = dir('whisker_data/201*');
    if length(fn_sessionInfo) > 0
        for ii = 1:length(fn_sessionInfo)
            cd(['whisker_data' filesep subses_dir(ii).name])
            % if this directory is already done, move on
            if exist('processing_done','dir')
                cd(results_save_dir);
                continue
            end
            load(fullfile(results_save_dir,fn_sessionInfo(ii).name));
            %% Can be excuded independently for individual sessions.
            % uncomment the following, and change the directory
            % results_save_dir = '/Volumes/DATA_RAID_0_ext/2P-Imaging_Data/anm146969_nx/2011_09_14/';
            extrap_distance_in_pix = 13;
            sessionName = sessionInfo.sessionName;
%%%            barTimeWindow = [sessionInfo.behavArray.trials{1}.pinDescentOnsetTime sessionInfo.behavArray.trials{1}.pinAscentOnsetTime + 0.4]; %GRchange
% % %             bar_coords = sessionInfo.barCoords;

            barTimeWindow = sessionInfo.bar_time_window;
            bar_coords = sessionInfo.bar_coords;
            imageDim = sessionInfo.whiskerImageDim;
            animalName = sessionInfo.mouseName;
            theta_kappa_roi = sessionInfo.theta_kappa_roi;
            trajectory_IDs = sessionInfo.whisker_trajIDs;

               batch_processing_whisker_file_dir(animalName, sessionName, extrap_distance_in_pix,...
                   theta_kappa_roi, trajectory_IDs, results_save_dir, imageDim, bar_coords, barTimeWindow,sessionInfo);
               mkdir(['whisker_data' filesep subses_dir(ii).name filesep 'processing_done']);
           end
       end
    cd(data_base_dir);


function batch_processing_whisker_file_dir(animalName, sessionName, extrap_distance_in_pix,...
            theta_kappa_roi, trajectory_IDs, results_save_dir, imageDim, bar_coords, barTimeWindow,sessionInfo)
%%
% clearvars -except kk results_save_dir sessionName extrap_distance_in_pix d theta_kappa_roi animalName

% barOnset = cellfun(@(x) x.pinDescentOnsetTime, imArray.SoloTrials);
% barOffset = cellfun(@(x) x.pinAscentOnsetTime, imArray.SoloTrials);
% 
if matlabpool('size')<1
    matlabpool open 12
end

if ~exist(fullfile(results_save_dir, sprintf('wsArray_%s.mat',sessionName)),'file')
    if ~exist(fullfile(results_save_dir,sprintf('wSigTrials_%s_%s.mat',animalName,sessionName)), 'file')
        wst_files = dir('*WST.mat');
        whiskers_files = dir('*.whiskers');
        if length(wst_files) < length(whiskers_files)
            
            Whisker.makeAllDirectory_WhiskerTrial(pwd,trajectory_IDs,'barRadius',12,'barPosOffset',[0 0],'faceSideInImage','top',...
                'protractionDirection','leftward','pxPerMm',25.7,'framePeriodInSec',.002,'imagePixelDimsXY',imageDim,...
                'mouseName',animalName,'sessionName',sessionName);
            
            Whisker.makeAllDirectory_WhiskerSignalTrial(pwd,'polyRoiInPix',[0  200],'follicleExtrapDistInPix',extrap_distance_in_pix); % If want to calculate forces, use ''follicleExtrapDistInPix' argument.
            wst_files = dir('*WST.mat');
        end
        
%         wst_files(imArray.excluded_fileNo) = [];
        wSigTrials = cell(1,length(wst_files));

        
        parfor i=1:length(wSigTrials) %length(wst_files),
              fprintf('-----------Start processing trial %d --------------------------\n',i);
           
            wst = load(wst_files(i).name);
           
            wSigTrials{i} = Whisker.WhiskerSignalTrial_NX(wst.ws);
          
            if ~isempty(bar_coords)
               
                wSigTrials{i}.bar_pos_trial = bar_coords(i,:);
            end
            wSigTrials{i}.bar_time_win = barTimeWindow; % sessionInfo.bar_time_window;
            theta_kappa_roi_array = {trajectory_IDs};
            for k=1:length(trajectory_IDs),
                tid = trajectory_IDs(k);
                
                if ~isempty(bar_coords)
                    
                    wSigTrials{i} = wSigTrials{i}.get_distToBar(tid);   
%                     wSigTrials{i} = wSigTrials{i}.mean_theta_kappa_near_bar(tid)
                end
                theta_kappa_roi_array{k+1} = theta_kappa_roi;
            end
                 
%                 wSigTrials{i} =
%                  wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa({trajectory_IDs,theta_kappa_roi}); %%GRchange
                
%                 wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa({trajectory_IDs,theta_kappa_roi,theta_kappa_roi,theta_kappa_roi}); %%GRchange
                wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa(theta_kappa_roi_array); %%GRchange multi whisker
                wSigTrials{i} = wSigTrials{i}.recompute_cached_follicle_coords(extrap_distance_in_pix);

        end
    else
        cd(results_save_dir);
        load(sprintf('wSigTrials_%s_%s.mat',animalName,sessionName));
        %%parfor
       parfor i=1:length(wSigTrials) %length(wst_files),
            wSigTrials{i}.bar_pos_trial = bar_coords(i,:);
            wSigTrials{i}.bar_time_win = barTimeWindow; % sessionInfo.bar_time_window;
            theta_kappa_roi_array = {trajectory_IDs};

            for k=1:length(trajectory_IDs),
                tid = trajectory_IDs(k);
                if ~isempty(bar_coords)
                    wSigTrials{i}= wSigTrials{i}.get_distToBar(tid);
%                      wSigTrials{i} = wSigTrials{i}.mean_theta_kappa_near_bar(tid)
                end
                theta_kappa_roi_array{k+1} = theta_kappa_roi;
            end
%                 wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa({trajectory_IDs, theta_kappa_roi,theta_kappa_roi,theta_kappa_roi});
                wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa(theta_kappa_roi_array); %% GR change multiwhisker
                wSigTrials{i} = wSigTrials{i}.recompute_cached_follicle_coords(extrap_distance_in_pix);
                
        %% add totalTouchKappaTrial and thetaenvelope here
                
                
        end
    end
    wsArray = NX_WhiskerSignalTrialArray(sessionInfo,wSigTrials);
    wsArray.ws_trials = wSigTrials;
    wsArray.theta_kappa_roi = theta_kappa_roi;
    wsArray.bar_time_window  = barTimeWindow;
%     wsArray.nTrials = length(wSigTrials);
else
    %
    cd(results_save_dir);
    temp = load(fullfile(results_save_dir, sprintf('wsArray_%s.mat',sessionName)));
    s = fieldnames(temp);
    wsArray = temp.(s{1});
    wSigTrials = wsArray.ws_trials;
%     if wsArray.nTrials ~= imArray.nTrials
%         wSigTrials(imArray.excluded_fileNo) = [];
%     end
    if isempty(wsArray.theta_kappa_roi) || ~iscell(wsArray.theta_kappa_roi)
        wsArray.theta_kappa_roi = theta_kappa_roi;
    end
    %
    parfor i=1:length(wSigTrials) %length(wst_files),
         fprintf('-----------Start processing trial %d --------------------------\n',i);
        if ~isempty(wsArray.bar_time_window)
            wSigTrials{i}.bar_time_win = wsArray.bar_time_window;
        else
            wSigTrials{i}.bar_time_win = barTimeWindow; % sessionInfo.bar_time_window;
        end
        theta_kappa_roi_array = {trajectory_IDs};
        for k=1:length(trajectory_IDs),
            tid = trajectory_IDs(k);
            if ~isempty(bar_coords)
                wSigTrials{i} = wSigTrials{i}.get_distToBar(tid);            
%                 wSigTrials{i} = wSigTrials{i}.mean_theta_kappa_near_bar(tid);
            end
            theta_kappa_roi_array{k+1}= wsArray.theta_kappa_roi;
        end    
            
%             wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa({trajectory_IDs, wsArray.theta_kappa_roi}); %GRchange removed {:} from theta_kappa_roi
            wSigTrials{i} = wSigTrials{i}.recompute_cached_mean_theta_kappa(theta_kappa_roi_array); % multiwhisker 

            wSigTrials{i} = wSigTrials{i}.recompute_cached_follicle_coords(extrap_distance_in_pix);
            
        
    end
    wsArray = NX_WhiskerSignalTrialArray(sessionInfo,wSigTrials);
    wsArray.ws_trials = wSigTrials;
    wsArray.nTrials = length(wSigTrials);
   
end

for ii = 1:length(wsArray.ws_trials)
    if max(cellfun(@(x) length(x), wsArray.ws_trials{ii}.time)) < 2000
        wsArray.ws_trials{ii}.useFlag = 0;
    end
end

wsArray.mouseName = animalName;
wsArray.sessionName = sessionName;
cd(results_save_dir);
save([results_save_dir filesep  sprintf('wsArray_%s', sessionName)], 'wsArray');
save(sprintf('wSigTrials_%s_%s',animalName,sessionName), 'wSigTrials');
%% adding this to sessObj
sessObj_found = dir('sessObj.mat');
if isempty(sessObj_found)
    sessObj = {};
    sessObj.wSigTrials = wSigTrials;
    save('sessObj','sessObj','-v7.3');
else
    load('sessObj.mat');
    sessObj.wSigTrials = wSigTrials;
    save('sessObj','sessObj','-v7.3');
end
matlabpool close
% % % % wsArray.whiskerPadCoords = sessionInfo.whiskerPadOrigin_nx;
% % % %% Touch detection. 
% % % % For air puff trials, no bar coordinates, and no touch detection.
% % % % if ~isempty(bar_coords)
% % %     contDet_param.threshDistToBarCenter = [.1   .55];%[.1   .55];
% % %     contDet_param.thresh_deltaKappa = [-0.1	0.1];
% % %     % contDet_param.bar_time_window = cellfun(@(x) x.bar_time_win, wsArray.ws_trials,'UniformOutput', false);
% % %     barTimeWindow = [1.0 2.5];
% % %     contDet_param.bar_time_window = barTimeWindow;
% % %     contact_inds = cell(wsArray.nTrials,1);
% % %     contact_direct = cell(wsArray.nTrials,1);
% % %     [contact_inds, contact_direct] = Contact_detection_session_auto(wsArray, contDet_param);
% % %     wsArray = NX_WhiskerSignalTrialArray([],wSigTrials);
% % % 
% % %     for i = 1:wsArray.nTrials
% % %         wsArray.ws_trials{i}.contacts = contact_inds{i};
% % %         wsArray.ws_trials{i}.contact_direct = contact_direct{i};
% % %         wsArray.ws_trials{i}.totalTouchKappaTrial = wsArray.totalTouchKappaTrial{1}(i);
% % %         wsArray.ws_trials{i}.maxTouchKappaTrial = wsArray.maxTouchKappaTrial{1}(i);
% % %     
% % %         inds = (wsArray.ws_trials{i}.distToBar{1} <  contDet_param.threshDistToBarCenter (2));
% % %         wsArray.ws_trials{i}.mThetaNearBar =mean(wsArray.ws_trials{i}.theta{1}(inds));
% % %         wsArray.ws_trials{i}.mKappaNearBar =mean(wsArray.ws_trials{i}.kappa{1}(inds));
% % %     end
% % % 
% % %     wSigTrials = wsArray.ws_trials;
% % % %     wSigTrials{i} = wSigTrials{i}.get_totTouchKappa_trial;
% % %     cd(results_save_dir);
% % %     %     save(sprintf('SessionInfo_%s.mat', sessionName{kk}), 'sessionInfo');
% % %     save(sprintf('wsArray_%s', sessionName), 'wsArray');
% % %     save(sprintf('wSigTrials_%s_%s',animalName,sessionName), 'wSigTrials');
% % %     fprintf('Results saved to: \n%s\n', results_save_dir);
% % %     
% % %     %% adding this to sessObj
% % %     sessObj_found = dir('sessObj.mat');
% % %     if isempty(sessObj_found)
% % %         sessObj = {};
% % %         sessObj.wSigTrials = wSigTrials;
% % %         save('sessObj','sessObj','-v7.3');
% % %     else
% % %         load('sessObj.mat');
% % %         sessObj.wSigTrials = wSigTrials;
% % %         save('sessObj','sessObj','-v7.3');
% % %     end
% % % 
% % %     
% % % % end
%%

