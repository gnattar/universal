%
%
%
%
% DHO, 5/08.
%
% STILL MUST IMPLEMENT JOINING SOLO FILES!!
%
%

classdef BehavTrialArray < handle

    properties
        mouseName = '';
        sessionName = '';
        sessionType = '';
        trim = [2 20]; % The number of trials to trim from beginning and end.  
        performanceRegion = []; % Beginning and ending behavioral trial numbers for block of trials in which mouse is performing.
        trials = {};
    end

    properties (Dependent = true)
        trialNums
        hitTrialNums
        hitTrialInds
        missTrialNums
        missTrialInds
        falseAlarmTrialNums
        falseAlarmTrialInds
        correctRejectionTrialNums
        correctRejectionTrialInds
        trialTypes
        trialCorrects
        trimmedTrialNums 
        fractionCorrect
    end
    
    methods (Access = public)
        function obj = BehavTrialArray(x, session_name)
            %
            % function obj = BehavTrialArray(x, session_name)
            %
            % Input argument 'x' is either Solo file name string or
            % a structure from loaded Solo file.
            %
            %   For now stores ONLY DISCRIM TRIALS. IF THIS CHANGES, NEED
            %   TO MAKE DEPENDENT TRIALTYPES ACCOUNT FOR IT.  ALSO OTHER
            %   DEPENDENTS.
            %
            if nargin > 0
                if ischar(x)
                    x = load(x);
                end


                obj.mouseName = x.saved.SavingSection_MouseName;
                obj.sessionName = session_name;

                n_trials = length(x.saved_history.RewardsSection_LastTrialEvents);
                n=1;
                for k=1:n_trials

                    % Required arguments to BehavTrial():
                    mouse_name = x.saved_history.SavingSection_MouseName{k};
                    trial_num = x.saved_history.AnalysisSection_NumTrials{k};
                    trial_type = x.saved.SidesSection_previous_sides(k) == 114; % 114 charcode for 'r', 108 for 'l'. 1 = S1 (go), 0 = S0 (nogo).
                    trial_correct = x.saved.poles_discobj_hit_history(k);
                    trial_events = x.saved_history.RewardsSection_LastTrialEvents{k};
                    
                    if k==n_trials
                        next_trial_events = [];
                    else
                        next_trial_events = x.saved_history.RewardsSection_LastTrialEvents{k+1};
                    end
                    
                    % Optional arguments to BehavTrial():
                    use_flag = 1; % Should implement setting this via 'trim' property.
                    session_type = x.saved_history.SessionTypeSection_SessionType{k};
                    extra_ITI_on_error = x.saved_history.TimesSection_ExtraITIOnError{k};
                    sampling_period_time = x.saved_history.TimesSection_SamplingPeriodTime{k}; %AnswerPeriodTime is 2 sec minus SamplingPeriodTime.
                    water_valve_time = x.saved_history.ValvesSection_WaterValveTime{k};
                    if isfield(x.saved_history, 'MotorsSection_motor_position')
                        motor_position = x.saved_history.MotorsSection_motor_position{k}; % In stepper motor steps.
                    else
                        motor_position = [];
                    end
                    nogo_position = x.saved_history.MotorsSection_nogo_position{k}; % In stepper motor steps.
                    go_position = x.saved_history.MotorsSection_go_position{k}; % In stepper motor steps.

                    if ismember(session_type, {'Discrim','Program-Timed-Discrim'})  % For now limit only to Discrim trials
                        % 'Program-Timed-Discrim' was old name for
                        % 'Discrim'.
                         behav_trial = Solo.BehavTrial(mouse_name, session_name, trial_num, trial_type,...
                            trial_correct, trial_events, next_trial_events, use_flag, session_type, extra_ITI_on_error,...
                            sampling_period_time, water_valve_time,...
                            motor_position, nogo_position, go_position);
                        
                        % In very rare cases, there are trials (a) scored as hits for which there is no
                        % answer lick and reward; or (b) with nothing but state 35 and state 40 entries. 
                        %  These are presumably due to stopping and starting Solo at odd times.
                        % Here we exclude these trials:
                        if behav_trial.trialType==1 && behav_trial.trialCorrect==1 && isempty(behav_trial.answerLickTime)
                            disp(['Found trial (trial_num=' num2str(trial_num) ' scored as hit with no answerlick times---excluding.'])
                        elseif isempty(behav_trial.pinAscentOnsetTime)
                            disp(['Found empty pinAscentOnsetTime for trial_num=' num2str(trial_num) '---excluding.'])
                        else
                            obj.trials{n} = behav_trial;
                            n=n+1;
                        end
                    end
                end
            end
        end

        function r = length(obj)
            r = length(obj.trials);
        end
  
%         function r = subset(trial_nums)
%             r = Solo.BehavTrialArray;
%             find
%             ind = find(obj.trialNums)
%             r.trials = obj.trials
%             
%         end
        function plot_scored_trials(obj, varargin)
            %
            % USAGE:
            % 1. plot_scored_trials(obj)
            % 2. plot_scored_trials(obj, marker_size)
            % 3. plot_scored_trials(obj, marker_size, font_size)
            %
            %
            if nargin==1 % just obj
                ms = 10; fs = 15;
            elseif nargin==2
                ms = varargin{1};
                fs = 15;
            elseif nargin==3
                ms = varargin{1};
                fs = varargin{2};
            else
                error('Too many input arguments')
            end
            
            hit_rej = intersect(obj.hitTrialNums,obj.trimmedTrialNums);
            miss_rej = intersect(obj.missTrialNums,obj.trimmedTrialNums);
            fa_rej = intersect(obj.falseAlarmTrialNums,obj.trimmedTrialNums);
            cr_rej = intersect(obj.correctRejectionTrialNums,obj.trimmedTrialNums);
    
            hit = setdiff(obj.hitTrialNums,obj.trimmedTrialNums);
            miss = setdiff(obj.missTrialNums,obj.trimmedTrialNums);
            fa = setdiff(obj.falseAlarmTrialNums,obj.trimmedTrialNums);
            cr = setdiff(obj.correctRejectionTrialNums,obj.trimmedTrialNums);
    
            if ~isempty(hit)
                plot(hit,zeros(size(hit))-.1, 'go', 'MarkerSize',ms); hold on 
            end
            if ~isempty(miss)
                plot(miss,zeros(size(miss))+.1, 'ro', 'MarkerSize',ms); hold on  
            end
            if ~isempty(fa)
                plot(fa,ones(size(fa))+.1, 'ro', 'MarkerSize',ms); hold on 
            end
            if ~isempty(cr)
                plot(cr,ones(size(cr))-.1, 'go', 'MarkerSize',ms); hold on  
            end
            
            if ~isempty(hit_rej)
                plot(hit_rej,zeros(size(hit_rej))-.1, 'ko', 'MarkerSize',ms); hold on 
            end
            if ~isempty(miss_rej)
                plot(miss_rej,zeros(size(miss_rej))+.1, 'ko', 'MarkerSize',ms); hold on  
            end
            if ~isempty(fa_rej)
                plot(fa_rej,ones(size(fa_rej))+.1, 'ko', 'MarkerSize',ms); hold on  
            end
            if ~isempty(cr_rej)
                plot(cr_rej,ones(size(cr_rej))-.1, 'ko', 'MarkerSize',ms); hold on 
            end
        
            xlabel('Trial','FontSize',fs);
            set(gca,'YTick',0:1,'YTickLabel',{'Go','Nogo'},'FontSize',fs,...
                'TickDir','out','Box','off');
            set(gcf,'Color','white')
            
            % Plot title but replace underscores with dashes since former 
            % gives subscripts in title():
            s = obj.sessionName;
            s(findstr(s,'_')) = '-';
            title(s)
        end
        
        function [percent_correct, varargout] = performance(obj, varargin)
            %
            % Solo.BehavTrialArray.performance
            %
            %
            % INPUT USAGES:
            % 1. [percent_correct, varargout] = performance(obj)
            %       Computes on all trials except those specified in 'trim' property.    
            % 2. [percent_correct, varargout] = performance(obj, range_of_trials)
            %       range_of_trials: Specifies range of trials on which to
            %       compute performance measures. Takes form: [first_trial_num last_trial_num].        
            %
            % OUTPUT USAGES:
            % 1. percent_correct = performance(obj)
            % 2. [percent_correct, hit_rate, false_alarm_rate] = performance(obj)
            % 3. [percent_correct, hit_rate, false_alarm_rate, dprime] = performance(obj)
            %
            %
            
            if nargin==1
               hit = setdiff(obj.hitTrialNums, obj.trimmedTrialNums);
               miss = setdiff(obj.missTrialNums, obj.trimmedTrialNums);
               fa = setdiff(obj.falseAlarmTrialNums, obj.trimmedTrialNums);
               cr = setdiff(obj.correctRejectionTrialNums, obj.trimmedTrialNums);
            elseif nargin==2
               trial_range = varargin{1}; 
               t = trial_range(1):trial_range(2);
               hit = intersect(obj.hitTrialNums, t);
               miss = intersect(obj.missTrialNums, t);
               fa = intersect(obj.falseAlarmTrialNums, t);
               cr = intersect(obj.correctRejectionTrialNums, t);
            else
                error('Too many input arguments')
            end
            
                
            num_s1 = length(hit) + length(miss);
            num_s0 = length(fa) + length(cr);
    
            percent_correct = (length(hit) + length(cr))/(num_s1 + num_s0);
            hit_rate = length(hit)/num_s1;
            false_alarm_rate = length(fa)/num_s0;
            
            
            if nargout==2
                varargout{1} = hit_rate;
            elseif nargout==3
                varargout{1} = hit_rate;
                varargout{2} = false_alarm_rate;
            elseif nargout==4
                varargout{1} = hit_rate;
                varargout{2} = false_alarm_rate;
                varargout{3} = Solo.dprime(hit_rate,false_alarm_rate,num_s1,num_s0);
            end
        end
        
        
        function r = get_all_lick_times(obj, trial_nums, varargin)
            %
            %     r = get_all_lick_times(obj, trial_nums, varargin)
            %
            %     If trial_nums is empty matrix ([]), all trials are included.
            %
            %     varargin{1} specifies optional vector of alignment times of the same size as trial_nums.
            %       Can be empty array ([]) placeholder in order to use varargin{2}.
            %
            %     varargin{2} specifies optional time window (in seconds; inclusive) to include licks
            %       from.  Licks outside this window are ignored. Can be either an
            %       1 X 2 vector with form [startTimeInSec endTimeInSec] in which
            %       case the window is applied to all trials, or an N x 2 matrix
            %       where N = length(trial_nums) that gives a separate window
            %       for each trial in trial_nums.
            %
            %     r is an N x 3 matrix where N is the number of licks, with form:
            %           [TrialCount BehavioralTrialNumber TimeOfLick].
            %
            trial_nums = trial_nums(ismember(trial_nums, obj.trialNums));
            invalid_trial_nums = setdiff(trial_nums, obj.trialNums);
            if ~isempty(invalid_trial_nums)
                disp(['Warning: requested trials ' num2str(invalid_trial_nums) 'do not exist in this BehavTrialArray.']);
            end
            if isempty(trial_nums)
                trial_nums = obj.trialNums;
            end

            ntrials = length(trial_nums);

            if nargin > 2 && ~isempty(varargin{1})
                alignmentTimes = varargin{1};
                if length(alignmentTimes) ~= ntrials
                    error('Alignment times vector must have same length as trial_nums argument.')
                end
            else
                alignmentTimes = zeros(ntrials,1);
            end

            restrictWindow = [];
            if nargin > 3
                restrictWindow = varargin{2};
                if length(restrictWindow)==2
                    restrictWindow = repmat([restrictWindow(1) restrictWindow(2)], [1 ntrials]);
                elseif length(restrictWindow) ~= ntrials
                    error('varargin{2} must be equal length as trial_nums')
                end
            end

            if isempty(restrictWindow)
                r = [];
                for k=1:ntrials
                    ind = find(obj.trialNums==trial_nums(k));
                    st = obj.trials{ind}.beamBreakTimes;
                    if ~isempty(st)
                        r = [r; repmat(k,size(st)), repmat(obj.trials{ind}.trialNum,size(st)), st - alignmentTimes(k)];
                    end
                end
            else
                r = [];
                for k=1:ntrials
                    ind = find(obj.trialNums==trial_nums(k));
                    st = obj.trials{ind}.beamBreakTimes;
                    st = st(st >= restrictWindow(k,1) & st <= restrictWindow(k,2));
                    if ~isempty(st)
                        r = [r; repmat(k,size(st)), repmat(obj.trials{ind}.trialNum,size(st)), st - alignmentTimes(k)];
                    end
                end
            end

        end
        
        function handles = plot_lick_raster(obj, trial_nums, varargin)
            %
            %   Plots all beam breaks as rasterplot. Will be in register
            %   from plot generated by plot_spike_raster, so can be plotted
            %   on the same axes (e.g., after "hold on" command).
            %
            %   Returns vector of handles to line objects that make up the
            %   raster tick marks.
            %
            %     [] = plot_lick_raster(obj, trial_nums, varargin)
            %
            %     If trial_nums is empty matrix ([]), all trials are included.
            %
            %     varargin{1} is one of two strings: 'BehavTrialNum', or 'Sequential', and
            %           specifies what values to plot on the y-axis.
            %
            %     varargin{2} specifies optional vector of alignment times of the same size as trial_nums.
            %           Can be empty matrix ([]) to get access to varargin{3}.
            %
            %     varargin{3}, if the string 'lines' is given, raster is plotted with
            %           vertical lines instead of dots.  Dots are the default.
            %
            %
            if nargin==2 % default is to plot in 'Sequential' mode.
                plotTypeString = 'Sequential';
                allLickTimes = obj.get_all_lick_times(trial_nums);
                plotSymType=0;
            elseif nargin==3
                plotTypeString = varargin{1};
                allLickTimes = obj.get_all_lick_times(trial_nums);
                plotSymType=0;
            elseif nargin==4
                plotTypeString = varargin{1};
                alignmentTimes = varargin{2};
                allLickTimes = obj.get_all_lick_times(trial_nums, alignmentTimes);
                plotSymType=0;
            elseif nargin==5
                plotTypeString = varargin{1};
                alignmentTimes = varargin{2};
                plotSymString = varargin{3};
                allLickTimes = obj.get_all_lick_times(trial_nums, alignmentTimes);
                if strcmp(plotSymString,'lines')
                    plotSymType=1; % plot with lines
                else
                    plotSymType=0; % plot with dots
                end
            else
                error('Too many inputs.')
            end

            % Leave error checking to get_all_spike_times().
            %             cla;
            fs=10;
            switch plotTypeString
                case 'BehavTrialNum'
                    if ~isempty(allLickTimes)
                        if plotSymType==0
                            handles = plot(allLickTimes(:,3), allLickTimes(:,2), 'm.');
                        else
                            x=allLickTimes(:,3);
                            y=allLickTimes(:,2);
                            yy = [y-.5 y+.5]';
                            xx = [x x]';
                            handles = line(xx,yy,'Color','magenta');
                        end
                    else
                        handles = [];
                    end
                    ylabel('Behavior trial number','FontSize',fs)
                    xlabel('Sec','FontSize',fs)

                case 'Sequential'
                    if ~isempty(allLickTimes)
                        if plotSymType==0
                            handles = plot(allLickTimes(:,3), allLickTimes(:,1), 'm.');
                        else
                            x=allLickTimes(:,3);
                            y=allLickTimes(:,1);
                            yy = [y-.5 y+.5]';
                            xx = [x x]';
                            handles = line(xx,yy,'Color','magenta');
                        end
                    else
                        handles = [];
                    end
                    ylabel('Trial number','FontSize',fs)
                    xlabel('Sec','FontSize',fs)

                otherwise
                    error('Invalid string argument.')
            end
        end

        function viewer(obj,varargin)
            %
            % USAGE:    viewer
            %                    
            %   This function must be called with no arguments. Signal selection
            %       and subsequent options are then chosen through the GUI.
            %
            %   Input arguments (in varargin) are reserved for internal, recursive
            %       use of this function.
            %
            %
            %
            if nargin==1 % Called with no arguments
                objname = inputname(1); % Command-line name of this instance of a BehavTrialArray.
                h=figure('Color','white'); ht = uitoolbar(h);
                a = .20:.05:0.95; b(:,:,1) = repmat(a,16,1)'; b(:,:,2) = repmat(a,16,1); b(:,:,3) = repmat(flipdim(a,2),16,1);
                bbutton = uipushtool(ht,'CData',b,'TooltipString','Back');
                fbutton = uipushtool(ht,'CData',b,'TooltipString','Forward','Separator','on');
                set(fbutton,'ClickedCallback',[objname '.viewer(''next'')'])
                set(bbutton,'ClickedCallback',[objname '.viewer(''last'')'])
                uimenu(h,'Label','Jump to trial','Separator','on','Callback',[objname '.viewer(''jumpToTrial'')']);
                        
                g = struct('sweepNum',1,'trialList','');               
                set(h,'UserData',g);

            else
                g = get(gcf,'UserData');
                if isempty(g) 
                    g = struct('sweepNum',1,'trialList','');
                end
                for j = 1:length(varargin);
                    argString = varargin{j};
                    switch argString
                        case 'next'
                            if g.sweepNum < length(obj)
                                g.sweepNum = g.sweepNum + 1;
                            end
                        case 'last'
                            if g.sweepNum > 1
                                g.sweepNum = g.sweepNum - 1;
                            end
                        case 'jumpToTrial'
                            if isempty(g.trialList)
                                nsweeps = obj.length;
                                g.trialList = cell(1,nsweeps);
                                for k=1:nsweeps
                                    g.trialList{k} = [int2str(k) ': trialNum=' int2str(obj.trialNums(k))];
                                end
                            end
                            [selection,ok]=listdlg('PromptString','Select a trial:','ListString',...
                                g.trialList,'SelectionMode','single');
                            if ~isempty(selection) && ok==1
                                g.sweepNum = selection;
                            end
                        otherwise
                            error('Invalid string argument.')
                    end
                end                
            end
            
            cla;
            
            obj.trials{g.sweepNum}.plot_trial_events;
            
            titleHandle = get(gca,'Title');
            titleString = get(titleHandle,'String'); 
            title([int2str(g.sweepNum) '/' int2str(obj.length) ', ' titleString]);
                       
            set(gcf,'UserData',g);
        end
        
        
%         function [y, x] = moving_average_performance(obj, varargin)
% %             r = length(obj.trials);
%         end
        
        
    end
    
    methods % Dependent property methods; cannot have attributes.
        
        function value = get.trialNums(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialNum, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.trialTypes(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialType, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.trialCorrects(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialCorrect, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.fractionCorrect(obj)
            if ~isempty(obj.trials)
                value = mean(obj.trialCorrects);
            else
                value = [];
            end
        end
        
        function value = get.hitTrialNums(obj)
            if ~isempty(obj.trials)
                value = obj.trialNums(cellfun(@(x) x.trialType==1 && x.trialCorrect==1, obj.trials));
            else
                value = [];
            end
        end
        
        function value = get.hitTrialInds(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialType==1 && x.trialCorrect==1, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.missTrialNums(obj)
            if ~isempty(obj.trials)
                value = obj.trialNums(cellfun(@(x) x.trialType==1 && x.trialCorrect==0, obj.trials));
            else
                value = [];
            end
        end
      
        function value = get.missTrialInds(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialType==1 && x.trialCorrect==0, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.falseAlarmTrialNums(obj)
            if ~isempty(obj.trials)
                value = obj.trialNums(cellfun(@(x) x.trialType==0 && x.trialCorrect==0, obj.trials));
            else
                value = [];
            end
        end
        
        function value = get.falseAlarmTrialInds(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialType==0 && x.trialCorrect==0, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.correctRejectionTrialNums(obj)
            if ~isempty(obj.trials)
                value = obj.trialNums(cellfun(@(x) x.trialType==0 && x.trialCorrect==1, obj.trials));
            else
                value = [];
            end
        end
        
        function value = get.correctRejectionTrialInds(obj)
            if ~isempty(obj.trials)
                value = cellfun(@(x) x.trialType==0 && x.trialCorrect==1, obj.trials);
            else
                value = [];
            end
        end
        
        function value = get.trimmedTrialNums(obj) % Trim trials from start and end of session if needed
            value = [];
            ntrials = length(obj.trials);
            if obj.trim(1)>0 && obj.trim(2)>0
                ind = [1:obj.trim(1), ((ntrials-obj.trim(2))+1):ntrials]; 
                value = obj.trialNums(ind);
            elseif obj.trim(2)>0
                ind = ((ntrials-obj.trim(2))+1):ntrials;  
                value = obj.trialNums(ind);
            elseif obj.trim(1)>0
                ind = 1:obj.trim(1); 
                value = obj.trialNums(ind);
            end
        end
        
        function r = pinDescentOnsetTimes(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.pinDescentOnsetTime, obj.trials);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end

        function r = pinAscentOnsetTimes(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.pinAscentOnsetTime, obj.trials);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end

        function r = samplingPeriodTime(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.samplingPeriodTime, obj.trials,'UniformOutput',false);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end
        
        function r = answerPeriodTime(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.answerPeriodTime, obj.trials,'UniformOutput',false);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end
        
        function r = rewardTime(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.rewardTime, obj.trials,'UniformOutput',false);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end
        
        function r = airpuffTimes(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.airpuffTimes, obj.trials,'UniformOutput',false);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end
        
        function r = drinkingTime(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.drinkingTime, obj.trials,'UniformOutput',false);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end
        
        function r = timeoutPeriodTimes(obj,varargin)
            %
            % varargin: optional vector of trial numbers.
            %
            r = cellfun(@(x) x.timeoutPeriodTimes, obj.trials,'UniformOutput',false);
            if nargin>1
                r = r(ismember(obj.trialNums, varargin{1}));
            end
        end
        
        
    end
    
end




