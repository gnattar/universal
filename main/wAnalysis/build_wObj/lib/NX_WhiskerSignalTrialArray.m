classdef NX_WhiskerSignalTrialArray
    
    %
    %
    properties
        mouseName;
        sessionName;
        ws_trials = {};
        pxPerMm = [];
        whiskerPadCoords = [];
        bar_time_window = [];
        theta_kappa_roi = [];
        Excluded_trials = [];
        contactDetectParam = struct([]);
        totalTouchKappaTrial = {}; % touch kappa change summed in each trial for each whiskers
        maxTouchKappaTrial = {}; % max touch kappa change in each trial for each whiskers.
        touchParam_trial = [];
    end
    
    properties (Dependent = true, SetAccess = private)% Dependent
        
        trajIDs
        nTrials
    end
    
    methods (Access = public)
        function obj = NX_WhiskerSignalTrialArray(sessionInfo,ws_trials)
            % ws_trials, a cell array of Whisker.WhiskerSignalTrial_NX
            if nargin > 0
                
                obj.ws_trials = ws_trials;
                %             obj.nTrials = length(ws_trials);
                if ~isempty(sessionInfo)
                    obj.mouseName = sessionInfo.mouseName;
                    obj.sessionName = sessionInfo.sessionName;
                    obj.pxPerMm = sessionInfo.pxPerMm;
%                     obj=get_totTouchKappa_trial(obj);
                    %             obj.bar_time_window = ws_trials{1}.bar_time_win;
                else
                    obj.mouseName = ws_trials{1}.mouseName;%GRchange
                    obj.sessionName = ws_trials{1}.sessionName';%GRchange
                    obj.pxPerMm = ws_trials{1}.pxPerMm;
                    obj=get_totTouchKappa_trial(obj);

                end
            end
            return 
        end
        
        function obj = get_totTouchKappa_trial(obj)
            % total kappa change from touch for each whiskers, compute from
            % the peak kappa change in each touch epoch
            
            tot_ka = cell(1, length(obj.trajIDs));
            max_ka = cell(1, length(obj.trajIDs));
            
            for wNo = 1:length(obj.trajIDs)
                for k  =1:obj.nTrials
                    k
                    cont_params = obj.ws_trials{k}.contact_params{wNo};
                    
                    if ~isempty(cont_params)
                        
                        peak_deltaKappa{k} = cellfun(@(x) x.peakDeltaKappa, obj.ws_trials{k}.contact_params{wNo});
                    else
                        peak_deltaKappa{k} = 0;
                    end
                    tot_ka{wNo}(k) = sum(peak_deltaKappa{k});% removed abs
                    max_ka{wNo}(k) = max(peak_deltaKappa{k}); % removed abs
                end
            end
            obj.totalTouchKappaTrial = tot_ka;
            obj.maxTouchKappaTrial = max_ka;
        end
        
        function [var_aligned, new_ts] = get_aligned_var_array(obj, wNo, trialInds, varName, align_option)
            % [var_aligned, new_ts] = get_aligned_var_array(obj, wNo, trialInds, varName, align_option)
            % Produce matrix of whisker variables aligned to specified
            % event time.
            % varName, 'Amplitude', 'theta' etc. 
            
            switch align_option
                case 'touch'
                    t_aln_trial = obj.get_first_touch_time_trial;
                    t_aln_mean = nanmean(t_aln_trial);
                case 'trial'
                    t_aln_trial = zeros(1, obj.nTrials);
                    t_aln_mean = 0;
            end
            
            if isempty(trialInds)
                trialInds = 1: obj.nTrials;
                ntrials = obj.nTrials;
            else
                ntrials = length(trialInds);
            end
            
            new_ts = (1:4000)*.002 - t_aln_mean;  %
            
            var_aligned = nan(ntrials, length(new_ts));
            
            for i = 1:ntrials
                ts = obj.ws_trials{i}.time{wNo};
                wVar_trial = obj.ws_trials{i}.(varName){wNo};
                temp_ts = ts - t_aln_trial(i); %     % ........... Use this for Active Touch trials
                
                [~, whichI] = histc(temp_ts, new_ts);
                
                var_aligned(i, whichI(whichI~=0)) = wVar_trial(whichI ~= 0);
            end
            
        end
            
        
        function obj = get_touchParam_trial(obj)
            % total kappa change from touch for each whiskers, compute from
            % the peak kappa change in each touch epoch
            
            touchParam.totKappa = cell(1, length(obj.trajIDs));
            touchParam.maxKappa = cell(1, length(obj.trajIDs));
            touchParam.totKappaProtraction = cell(1, length(obj.trajIDs));
            touchParam.totKappaRetraction = cell(1, length(obj.trajIDs));
            touchParam.numTouchProtraction = cell(1, length(obj.trajIDs));
            touchParam.numTouchRetraction = cell(1, length(obj.trajIDs));
            touchParam.totTouchDurationProtraction = cell(1, length(obj.trajIDs));
            touchParam.totTouchDurationRetraction = cell(1, length(obj.trajIDs));
            
            for wNo = 1:length(obj.trajIDs)
                h_waitbar = waitbar(0,'getting touchParam for trial 0');
                for k  =1:obj.nTrials
                    waitbar(k/obj.nTrials, h_waitbar, sprintf('getting touchParams for wNo %d, trial %d',wNo, k));
                    cont_params = obj.ws_trials{k}.contact_params{wNo};
                    if ~isempty(cont_params)
                        peak_deltaKappa{k} = cellfun(@(x) x.peakDeltaKappa, obj.ws_trials{k}.contact_params{wNo});
                        cont_duration{k} = cellfun(@(x) x.contactDuration, obj.ws_trials{k}.contact_params{wNo});
                    else
                        peak_deltaKappa{k} = 0;
                        cont_duration{k} = 0;
                    end
                    % inds of touch with protraction or retraction
                    if ~isempty(obj.ws_trials{k}.contact_direct)
                        proInds = find(obj.ws_trials{k}.contact_direct{wNo} == 1);
                        retInds = find(obj.ws_trials{k}.contact_direct{wNo} == 0);
                    else
                        proInds = [];
                        retInds = [];
                    end
                    
                    touchParam.totKappa{wNo}(k) = sum(abs(peak_deltaKappa{k}));
                    touchParam.maxKappa{wNo}(k) = max(abs(peak_deltaKappa{k}));
                    touchParam.totKappaProtraction{wNo}(k) = sum(abs(peak_deltaKappa{k}(proInds))); 
                    touchParam.totKappaRetraction{wNo}(k) = sum(abs(peak_deltaKappa{k}(retInds)));
                    
                    touchParam.numTouchProtraction{wNo}(k) = length(proInds);
                    touchParam.numTouchRetraction{wNo}(k) = length(retInds);
                    
                    touchParam.totTouchDurationProtraction{wNo}(k) = sum(cont_duration{k}(proInds));
                    touchParam.totTouchDurationRetraction{wNo}(k) = sum(cont_duration{k}(retInds));
                end
                close(h_waitbar);
            end
            obj.touchParam_trial = touchParam;
        end
        
        function r = get_cont_theta_trial(obj)
            r = cell(1, length(obj.trajIDs));
            for wNo = 1:length(obj.trajIDs)
                for k = 1:obj.nTrials
                    cont_params = obj.ws_trials{k}.contact_params{wNo};
                    if ~isempty(cont_params)
                        wskPos{k} = cellfun(@(x) x.setPointCont_mean, obj.ws_trials{k}.contact_params{wNo});
                    else
                        wskPos{k} = NaN;
                    end
                    r{wNo}(k) = mean(wskPos{k});
                end
            end
        end
        
        function inds = get_touch_trial_inds(obj,trajID)
            % get the tial inds for trials with touch from pecified whisker
            %       or all whiskers.
            % trajID, traced whisker ID, e.g., 0, 1, or 2 ... If not given,
            %       consider all whiskers.
            % 
            all_tids = obj.ws_trials{1}.trajectoryIDs;
            if nargin < 2
                wsk_num = (1:length(all_tids));
            else
                wsk_num = find(all_tids == trajID);
            end
            contacts_trials = cellfun(@(x) x.contacts(wsk_num), obj.ws_trials, 'UniformOutput', false);
            n_tch_tot = cellfun(@(x) numel([x{:}]), contacts_trials);
            inds = find(n_tch_tot > 0);
        end
        
        
        function t = get_first_touch_time_trial(obj, trialNums, trajID, touch_direct)
            % t = get_first_touch_time_trial(obj, trajID)
            % if trajID = [] or not provided, use all whiskers.
            t = nan(obj.nTrials, 1);
            all_tids = obj.ws_trials{1}.trajectoryIDs;
            
            if nargin < 2 || isempty(trialNums)
                trialNums = 1:obj.nTrials;
            end
            if nargin < 3 || isempty(trajID)
                wsk_num = (1:length(all_tids));
            else
                wsk_num = find(all_tids == trajID);
            end
            
            if nargin < 4 || isempty(touch_direct)
                touch_direct = [0 1];
            end
            
            for ii = 1:obj.nTrials
                % Combine touch epochs for all whiksers
                t0_wsk = nan(1,length(wsk_num));
                for j = 1:length(wsk_num)
                    contacts = obj.ws_trials{ii}.contacts{wsk_num(j)};
                    if ~isempty(contacts)
                        ts = obj.ws_trials{ii}.time{wsk_num(j)};
                        if ~isempty(obj.ws_trials{ii}.contact_direct)
                            contact_direct_wsk_trial = obj.ws_trials{ii}.contact_direct{wsk_num(j)};
                            cont_id = find(ismember(contact_direct_wsk_trial, touch_direct),1,'first');
                        else
                            cont_id = 1;
                        end
                        if ~isempty(cont_id)
                            t0_wsk(j) = ts(contacts{cont_id}(1));
                        end
                            
                    end
                end
                if ~isempty(t0_wsk)
                    t(ii) = min(t0_wsk);
                end
            end
        end
        
        
        function inds_TD = get_trial_inds_touch_direction(obj, wNo)
            % Trial index for the 2 touch directions
            % inds_TD, a struct for a sinle trajID, or a cell array with struct as each
            % element for multi trajIDs.
            %             if nargin > 2 && length(trajIDs) < 2
            %                 inds_TD = struct([]);
            %             elseif nargin > 2 && length(trajIDs)>=2
            %                 inds_TD = cell(1,length(trajIDs));
            %             else
            %                 trajIDs = obj.trajIDs;
            %                 inds_TD = cell(1,length(trajIDs));
            %             end
            inds_TD = struct([]);
            %             wNo = find(obj.trajIDs == trajIDs(i));
            direc = nan(1,obj.nTrials);
            if ~isempty(obj.touchParam_trial)
                totProtractionKappa = obj.touchParam_trial.totKappaProtraction{wNo};
                totRetractionKappa = obj.touchParam_trial.totKappaRetraction{wNo};
                for j = 1: obj.nTrials
                    if totProtractionKappa(j) > totRetractionKappa(j) && totProtractionKappa(j) > 0
                        direc(j) = 1;
                    elseif totRetractionKappa(j) > totProtractionKappa(j) && totRetractionKappa(j) > 0
                        direc(j) = 0;
                    else
                        direc(j) = NaN;
                    end
                end
                
            else
                for j = 1:obj.nTrials
                    if ~isempty(obj.ws_trials{j}.contact_params{wNo})
                        %                         vel = cellfun(@(x) x.vel, obj.ws_trials{j}.contact_params{i});
                        retPeakKappa = cellfun(@(x) x.retPeakKappa, obj.ws_trials{j}.contact_params{wNo});
                        proPeakKappa = cellfun(@(x) x.proPeakKappa, obj.ws_trials{j}.contact_params{wNo});
                        if isnan(nanmean(abs(retPeakKappa))) || nanmean(abs(proPeakKappa)) > nanmean(abs(retPeakKappa))
                            direc(j) = 1; % protraction trial
                        else
                            direc(j) = 0; % retraction trial
                        end
                        %                         direc(j) = abs(nansum(proPeakKappa)) > abs(nansum(retPeakKappa));
                        %                         direc(j) = sum(~isnan(proPeakKappa)) > sum(~isnan(retPeakKappa));
                        % 1 for protraction, 2 for retraction
                        %                         if length(obj.ws_trials{j}.contact_params{wNo})>=3 % only consider the first 3 contacts
                        % %                             direc(j) = sum(vel(1:3)>0) >= 0; % true for net protraction
                        %                             direc(j) = abs(nansum(proPeakKappa(1:3))) > abs(nansum(retPeakKappa(1:3)));
                        %                         else
                        % %                             direc(j) = vel(1) >= 0; % true for protraction
                        %                             direc(j) = ~isnan(proPeakKappa(1));
                        %                         end
                    else
                        direc(j) = NaN;
                    end
                end
            end
            inds_TD(1).protraction = find(direc==1);
            inds_TD(1).retraction = find(direc==0);
            
        end
        
        function out = get_bar_x_distance_from_whisker_pad(obj, varargin)
            % varargin{1}, trial_inds, put [] to get access to the 3rd argument
            % varargin{2}, whiskerPadCoords
            if nargin > 1 & ~isempty(varargin{1})
                trial_inds = varargin{1};
            else
                trial_inds = 1:obj.nTrials;
            end
            if nargin > 2
                wp = varargin{2};
            elseif isempty(obj.whiskerPadCoords)
                error('whiskerPadCoords is empty!');
            else
                wp = obj.whiskerPadCoords;
            end
            if ~isempty(obj.ws_trials{1}.bar_pos_trial)
                bar_x = cellfun(@(x) x.bar_pos_trial(1), obj.ws_trials(trial_inds));
            else
                bar_x = cellfun(@(x) mode(x.barPos(800:1500,2)), obj.ws_trials(trial_inds));
            end
            out = (bar_x - wp(1))/obj.pxPerMm; % in mm
        end
        
        function [ha,hParams] = view_contacts(obj,trialNo, tid, plotParams,h_fig)
            if nargin < 4 || isempty(plotParams)
                plotParams = {'distToBar','deltaKappa','theta'};
            end
            if nargin < 5
                
            hfig = figure('Position',[700    10   750   750],'Name',sprintf('Whisker %d, trial %d',tid,trialNo),...
                    'NumberTitle','off');
            
            else
                figure(h_fig);
                set(h_fig,'Name',sprintf('Whisker %d, trial %d',tid,trialNo),...
                    'NumberTitle','off');
            end
            wNo = find(obj.trajIDs == tid);
            inds_contact = obj.ws_trials{trialNo}.contacts{wNo};
            if ~isempty(obj.ws_trials{trialNo}.contact_direct)
                contact_direct = obj.ws_trials{trialNo}.contact_direct{wNo};
            end
            x1 = cellfun(@(x) x(1), inds_contact);
            x2 = cellfun(@(x) x(end), inds_contact);
            x = [x1; x1; x2; x2];
            for i = 1:length(plotParams)
                if ~ismember(plotParams{i}, properties(obj.ws_trials{trialNo}))
                    continue
                end
                ha(i) = subplot(length(plotParams),1,i);
                hold on;
                hParams(i) = plot(obj.ws_trials{trialNo}.(plotParams{i}){wNo},'.-');
                yl = get(gca,'YLim');
%                 y = repmat([yl(1); yl(2); yl(2); yl(1)],[1,size(x,2)]);
%                 patch(x,y,'k','FaceAlpha',0.3,'EdgeColor','none');
                for ii = 1:size(x,2)
                    if contact_direct(ii) == 1 % protraction touch
                        clr_touch = 'g';% [.4  1  .4];
                    else
                        clr_touch = 'r';%[1  .4  .4];
                    end
                    y = [yl(1); yl(2); yl(2); yl(1)];
                    patch(x(:,ii), y, clr_touch, 'FaceAlph', 0.3, 'EdgeColor', 'none');
                end
                ylabel(plotParams{i},'FontSize',18);
                set(gca,'FontSize',13);
            end
        end
        
        function [] = recompute_kappa_theta_roi(obj,theta_kappa_roi)
            % refer to Whisker.WhiskerSignalTrial.recompute_cached_mean_theta_kappa
            % kappa_theta_roi, 1x4 double, [theta_radial_window  kappa_radial_window] 
            % for all whiskers or a cell array with element for each
            % whisker.
            % 
            obj.theta_kappa_roi = theta_kappa_roi;
            for i = 1:obj.nTrials
                obj.ws_trials{i}.recompute_cached_mean_theta_kappa(theta_kappa_roi);
                fprintf('%d trials done',i);
            end
        end
        
        
        function barPos_colors = get_barDistX_colorCode(obj)
            % Get x-difference between bar location and whisker pad center
            barDistX = obj.get_bar_x_distance_from_whisker_pad;
            % % only trials with touch are considered
            barDistX_u = unique(barDistX);
            
            color_lim = [-8 12]; %[min(barPosTouch) max(barPosTouch)];
            
            cm = jet;
            clr_map = cm(15:58,:);
            
            colors = color_mapping_nx(barDistX_u, color_lim, clr_map);
            
            barPos_colors = arrayfun(@(x) colors(barDistX_u==x,:), barDistX, 'UniformOutput',false);
        end
        
        
        
        function plot_contact_detection(obj,trialNo,trajID,varargin)
            wNo = find(obj.trajIDs == trajID);
            ws = obj.ws_trials{trialNo};
            if ~isempty(varargin) && ishandle(varargin{1})
                fig_view_cont = varargin{1};
                set(gcf,'Name',sprintf('Contact detection results,trial %d,whisker%d',trialNo,wNo));
            else
                fig_view_cont = figure('Position',[440    34   660   750],'Name',sprintf('Contact detection results,trial %d,whisker%d',trialNo,wNo),'Color','w');
            end
            ts = ws.time{wNo};
            if length(varargin) >= 2
                time_window = varargin{2};
                fr_inds = find(ts > time_window(1) & ts < time_window(2));
            else
                time_window = [];
                fr_inds = 1:length(ts);
            end
            
            figure(fig_view_cont);
            ha(1) = subaxis(3,1,1,'MT',0.05,'SV',0.03);
            ha(2) = subaxis(3,1,2,'SV',0.03);
            ha(3) = subaxis(3,1,3,'SV',0.03);
            wParams = {'deltaKappa','distToBar','theta'};
            contact_inds = ws.contacts{wNo};
            contact_direct = ws.contact_direct{wNo};
            
            for k = 1:length(ha)
                axes(ha(k));
                plot(ts(fr_inds), ws.(wParams{k}){wNo}(fr_inds),'.-');
                set(get(ha(k),'YLabel'),'String',wParams{k},'FontSize',15);
                set(ha(k),'FontSize',13, 'Box','off');
            end
            
            if ~isempty(contact_inds)
                for k = 1:length(ha)
                    axes(ha(k));
                    for i=1:length(contact_inds)
                        x = ts([contact_inds{i}(1) contact_inds{i}(1) contact_inds{i}(end) contact_inds{i}(end)]);
                        yl = get(gca,'YLim');
                        y = [yl(1) yl(2) yl(2) yl(1)];
                        % Coloring the patch based on contact direction
                        if contact_direct(i) == 1, % protraction
                            clr = [0.5 1 0.5];
                        else
                            clr = [1 0.5 0.5];
                        end
                        hpch(i) = patch(x,y ,clr,'EdgeColor','none');
                    end
                    
                    alpha(hpch,0.5);
                end
                
                %                 end
            end
        end
        
        function [contact_inds, contact_direct] = Contact_detection_single (obj, trialNo, wNo, param)
            % [contact_inds, contact_direct] = Contact_detection_single (obj, trialNo, wNo, param)
            % param, with fields:
            %   KappThresh, e.g., [0.3 1.8]
            %   DistThresh_prior, e.g., 1, more restricted than DistThresh
            %   DistThresh, e.g., [0 1.5]
            if isfield(param, 'bar_time_window')
                btw = param.bar_time_window;
            else
                btw = obj.bar_time_window;
            end
            ws = obj.ws_trials{trialNo};
            barPos = ws.bar_pos_trial;
            barRadiusInPx = ws.barRadius;
            ts = ws.time{wNo};
            d2bar = ws.distToBar{wNo}./obj.pxPerMm;
            deltaKappa = ws.deltaKappa{wNo};
            tip_coords = ws.get_tip_coords(obj.trajIDs(wNo));
            
            barFrInds = find(ts > btw(1) & ts < btw(2));
            
            KaThresh = param.KappaThresh;
            threshDist0 = param.DistThresh_prior;
            threshDist = param.DistThresh;
            
            [contact_inds, contact_direct] = whisker_contact_detector_auto_thresh( d2bar, deltaKappa, barFrInds, KaThresh, threshDist0, threshDist);
            
            
        end
        
        function obj = Contact_detection_session(obj, param)
            h_wait = waitbar(0, 'Perform Contact detection ...');
            for trNo = 1 : obj.nTrials
                for wNo = 1:length(obj.trajIDs)
                    if obj.ws_trials{trNo}.useFlag ~= 0
                        % Check useFlag. Some trials may be not usable due
                        % to whisker tracing error.
                        [contact_inds, contact_direct] = obj.Contact_detection_single(trNo, wNo, param);
                        obj.ws_trials{trNo}.contacts{wNo} = contact_inds;
                        obj.ws_trials{trNo}.contact_direct{wNo} = contact_direct;
                    else
                        obj.ws_trials{trNo}.contacts{wNo} = [];
                        obj.ws_trials{trNo}.contact_direct{wNo} = NaN;
                    end
                end
                waitbar(trNo/obj.nTrials, h_wait, sprintf('Contact detection, %d / %d trials done ...', trNo, obj.nTrials));
            end
            delete(h_wait);
        end
      
        
        function r = saveobj(obj)
            r.mouseName = obj.mouseName;
            r.sessionName = obj.sessionName;
            r.pxPerMm = obj.pxPerMm;
            r.whiskerPadCoords = obj.whiskerPadCoords;
            r.bar_time_window = obj.bar_time_window;
            r.theta_kappa_roi = obj.theta_kappa_roi;
            r.Excluded_trials = obj.Excluded_trials;
            r.contactDetectParam = obj.contactDetectParam;
            r.totalTouchKappaTrial = obj.totalTouchKappaTrial;
            r.maxTouchKappaTrial = obj.maxTouchKappaTrial;
            r.touchParam_trial = obj.touchParam_trial;
            wSigTrials = obj.ws_trials;
            obj.ws_trials = {};
            r.ws_trials = {}; % obj.ws_trials; %
            save_WST = 'y'; %input('Save WhiskerSignalTrials? ','s');
            if strcmpi(save_WST, 'y')
                save(sprintf('wSigTrials_%s_%s',r.mouseName,r.sessionName),'wSigTrials');
                fprintf('WhiskerSignalTrials also saved to wSigTrials_%s_%s\n',r.mouseName,r.sessionName);
            else
                fprintf('Warning: WhiskerSignalTrials NOT saved! ');
            end
            
        end
        
%         function obj = aux_loadobj(obj, forceReload)
%             % wSigTrials could not be loaded correctely with newer version
%             % of Matlab. Use this function to reload.
%             
%             if forceReload == 1 || isempty(obj.ws_trials)
%                 fn = sprintf('wSigTrials_%s_%s.mat',obj.mouseName,obj.sessionName);
%                 if exist(fn,'file')
%                     load(fn);
%                 else
%                    [fn pth] = uigetfile('*.mat','Load WhiskerSignalTrial');
%                    cd(pth);
%                    load(fullfile(pth,fn));
%                 end
%                 
%                 obj.ws_trials = wSigTrials;
%             end
% %             disp(wst{1});
%             
%         end
        
        function obj = remove_trials(obj, trial_num_remove)
            obj.ws_trials(trial_num_remove) = [];
            
        end
    end
    
    
   
    
    methods  % Dependent
        
        function value = get.nTrials(obj)
            value = length(obj.ws_trials);
        end
        
        function value = get.trajIDs(obj)
            value = obj.ws_trials{1}.trajectoryIDs;
        end
       
    end
    
    methods (Static = true)
        function obj = loadobj(a)
            obj = NX_WhiskerSignalTrialArray;
            obj.mouseName = a.mouseName;
            obj.sessionName = a.sessionName;
            obj.pxPerMm = a.pxPerMm;
            obj.whiskerPadCoords = a.whiskerPadCoords;
            obj.bar_time_window = a.bar_time_window;
            obj.theta_kappa_roi = a.theta_kappa_roi;
            
            if isfield(a,'Excluded_trials')
                obj.Excluded_trials = a.Excluded_trials;
            end
            if isfield(a, 'contactDetectParam')
                obj.contactDetectParam = a.contactDetectParam;
            end
            if isfield(a, 'touchParam_trial')
                obj.touchParam_trial = a.touchParam_trial;
                obj.totalTouchKappaTrial = a.totalTouchKappaTrial;
                obj.maxTouchKappaTrial = a.maxTouchKappaTrial;
            end
%             obj.ws_trials = a.ws_trials;
            if isempty(a.ws_trials)
                fn = sprintf('wSigTrials_%s_%s.mat',a.mouseName,a.sessionName);
                if exist(fn,'file')
                    load(fn);
                else
                   [fn pth] = uigetfile('*.mat','Load WhiskerSignalTrial');
                   cd(pth);
                   load(fullfile(pth,fn));
                end
                wst = wSigTrials;
            else
                wst = a.ws_trials;
            end
            % Simple assignment of obj.wl_trials = a.wl_trials does not
            % correctly load the data. Use the following loop seemed fixed the issue.
            for j = 1:length(wst)
                temp_obj = wst{j};
                obj.ws_trials{j} = temp_obj;
            end
        end
    end
    
end

