%
%
%
%
% DHO, 5/08.
%
%
%
%
classdef BehavTrial_gr < handle

    properties

        mouseName = '';
        sessionName = '';
        trialNum  = [];
        trialType = []; % 1 for go trial, 0 for no-go trial.
        trialCorrect = []; % 1 for correct, 0 for incorrect.
        trialEvents = [];
        useFlag   = 1; % set to 0 to mark bad trials.
        sessionType = '';
        extraITIOnErrorSetting = [];
        samplingPeriodTimeSetting = [];
        waterValveDuration = [];
        answerPeriodTimeSetting = []; % 2 sec minus samplingPeriodTimeSetting
        motorPosition = [];
        nogoPosition = [];
        goPosition = [];
        stimDelayTimeSetting = []; % added by NX
        protName = ''; % protocol name, added by NX
        waterValveDelay = [];
        Dprime = [];
        PercentCorrect = [];
        goPosition_mean = [];
        goPosition_runmean = [];
    end


    properties (Dependent = true, SetAccess = private)
        beamBreakTimes = []; 
        trialTriggerTimeEPHUS = [];
        trialTriggerTimeCamera = []; 
        rewardTime = []; % [startTime stopTime]
        airpuffTimes = {}; % Cell array of {[startTime1 stopTime1],[startTime2 stopTime2],...} 
        pinDescentOnsetTime = []; ;
        pinAscentOnsetTime = []; 
        
        samplingPeriodTime = []; % Retrieved from event matrix
        answerPeriodTime = []; % Retrieved from event matrix; maximum of 
                                % answerPeriodTimeSetting, but ends when mouse licks.
                                % Gives reaction time on Go trials from end
                                % of sampling/grace period.

        answerLickTime = []; % Empty if a miss or correct rejection.
        LickTimesPreAnswer = [];   % Licks after pole onset but before Answer period, added by NX
        LickTimesPostAnswer = [];  % Licks after the first counted Answer lick, added by NX
        trialStartTime = [];
        drinkingTime = []; % 2 s minus water valve time, to give mouse time to drink before proceeding w/ next trial.
        timeoutPeriodTimes = [];
        
        % Add:
        % RTFromEndOfSampling;
        % RTFromStartOfPinDescent;
    end

    methods (Access = public)
        function obj = BehavTrial_gr(solo_data, trial_num, useFlag)
%             (mouse_name, session_name, trial_num, trial_type,...
%                 trial_correct, trial_events, protName, varargin)
%             %         function obj = BehavTrial(mouse_name, session_name, trial_num, trial_type,...
            %                 trial_correct, trial_events, varargin)
            %
            %              VARARGIN:     useFlag, sessionType, extraITIOnErrorSetting,
            %              samplingPeriodTimeSetting, waterValveTimeSetting,
            %              motorPosition, nogoPosition, goPosition,
            %              stimDelayTimeSetting, answerPeriodTimeSetting
            %
                obj.mouseName = solo_data.mouse_name;
                obj.sessionName = solo_data.session_name;
                obj.trialNum  = trial_num;
                obj.trialType = solo_data.saved.SidesSection_previous_sides(trial_num) == 114; % 114 charcode for 'r', 108 for 'l'. 1 = S1 (go), 0 = S0 (nogo).
                obj.trialCorrect = solo_data.saved.([solo_data.protocol_name '_hit_history'])(trial_num);
                obj.trialEvents = solo_data.saved_history.RewardsSection_LastTrialEvents{trial_num};
                obj.protName = solo_data.protocol_name;
                obj.Dprime = solo_data.saved_history.AnalysisSection_Dprime{trial_num};
                obj.PercentCorrect = solo_data.saved_history.AnalysisSection_PercentCorrect{trial_num};
                
                
                obj.sessionType = solo_data.saved_history.SessionTypeSection_SessionType{trial_num};
                obj.extraITIOnErrorSetting = solo_data.saved_history.TimesSection_ExtraITIOnError{trial_num};
                obj.samplingPeriodTimeSetting = solo_data.saved_history.TimesSection_SamplingPeriodTime{trial_num};

                % obj.answerPeriodTimeSetting = 2 - obj.samplingPeriodTimeSetting;

                obj.waterValveDuration = solo_data.saved_history.ValvesSection_WaterValveTime{trial_num};
                obj.motorPosition = solo_data.saved_history.MotorsSection_motor_position{trial_num};
                obj.nogoPosition = solo_data.saved_history.MotorsSection_nogo_position{trial_num}; % In stepper motor steps.
                obj.goPosition = solo_data.saved_history.MotorsSection_go_position{trial_num};


                if isfield(solo_data.saved_history, 'TimesSection_pole_delay') % add by NX
                    obj.stimDelayTimeSetting = solo_data.saved_history.TimesSection_pole_delay{trial_num};
                else
                    obj.stimDelayTimeSetting = 0;
                end
                if isfield(solo_data.saved_history, 'TimesSection_WaterValveDelay')
                    wvd = solo_data.saved_history.TimesSection_WaterValveDelay{trial_num};
                    if ischar(wvd)
                        eventsMatrix = solo_data.saved_history.RewardsSection_LastTrialEvents{trial_num};
                        obj.waterValveDelay = eventsMatrix(find(eventsMatrix(:,1)==61,1,'last'),3)...
                            - eventsMatrix(find(eventsMatrix(:,1)==61,1,'first'),3);
                    else
                        obj.waterValveDelay = wvd;
                    end
                else
                    % PoleReractTime (instead of PoleRetractTime) is a typo in original protocol
                    obj.waterValveDelay = solo_data.saved_history.TimesSection_PoleReractTime{trial_num};
                end
                if isfield(solo_data.saved_history, 'TimesSection_AnswerPeriodTime') % add by NX
                    obj.answerPeriodTimeSetting = solo_data.saved_history.TimesSection_AnswerPeriodTime{trial_num};
                else
                    obj.answerPeriodTimeSetting = [];
                end
                if nargin>2
                    obj.useFlag   = useFlag; % set to 0 to mark bad trials.
                end
            end
        
%         function delete(obj)
%             % Don't need any special cleaning up.
%         end

                
        function plot_trial_events(obj)
            cla
            ymin = 0; ymax = 7; lw = 5;
            
            x = [obj.pinDescentOnsetTime, obj.pinAscentOnsetTime]; 
            y = 6*ones(size(x));
            plot(x, y, 'k-','LineWidth',lw); hold on
            
            x = obj.samplingPeriodTime; 
            y = 5*ones(size(x));
            plot(x, y, 'y-','LineWidth',lw); hold on
            
            x = obj.answerPeriodTime; 
            y = 4*ones(size(x));
            plot(x, y, 'g-','LineWidth',lw); hold on
            
            x = obj.beamBreakTimes; 
            y = 3*ones(size(x));
            plot(x, y, 'ko','MarkerSize',9)
            
            if ~isempty(obj.rewardTime)
                x = [obj.rewardTime(1), obj.rewardTime(2)]; 
                y = 2*ones(size(x));
                plot(x, y, 'b-','LineWidth',lw)
            end
            
            p = obj.airpuffTimes;
            if ~isempty(p)
                for k=1:length(p)
                    puff_times = p{k};
                    x = puff_times; 
                    y = ones(size(x));
                    plot(x, y, 'r-','LineWidth',lw)
                end
            end
            ylim([ymin ymax]);
            
            if (obj.pinAscentOnsetTime) > 5
                xlim([0, obj.pinAscentOnsetTime + 0.1])
            else
                xlim([0 5])
            end
            
%             xlm = get(gca, 'XLim');
%             if xlm(2) < 5
%                 xlim([0 5])
%             end
            
            set(gca, 'YTick', 1:6,'YTickLabel', {'Airpuff','Water valve','Beam breaks', 'Answer period', 'Grace period','Pin valve'},...
                'FontSize', 15, 'TickDir','out','Box','off')
            xlabel('Sec','FontSize',15)
            set(gcf,'Color','white')
            
            
            if obj.trialType==1
                trial_type_string = 'Go';
            else
                trial_type_string = 'Nogo';
            end
            
            if obj.trialCorrect==1
                score_string = 'Correct';
            else
                score_string = 'Incorrect';
            end

            title(['TrialNum=' int2str(obj.trialNum) ...
                ', ' trial_type_string ', ' score_string])
            
%             title([obj.mouseName ', ' obj.sessionName ', ' 'TrialNum=' int2str(obj.trialNum) ...
%                 ', ' trial_type_string ', ' score_string])     
        end
    end

    methods % Dependent property methods; cannot have attributes.    
        
        function value = get.beamBreakTimes(obj)
            rowInd = find(obj.trialEvents(:,2)==1);
            if ~isempty(rowInd)
                value = obj.trialEvents(rowInd, 3) - obj.trialStartTime;
            else
                value = [];
            end
        end
        
        function value = get.rewardTime(obj)% State 43 entries and exits
            trial_events = obj.trialEvents;
            
            rowIndStart = find(trial_events(:,1)==43 & trial_events(:,2)==0, 1, 'first');
            rowIndStop = find(trial_events(:,1)==43 & trial_events(:,2)==3, 1, 'first'); % Timeout code = 3;

            if ~isempty(rowIndStart)
                value = [trial_events(rowIndStart, 3), trial_events(rowIndStop, 3)] - obj.trialStartTime;
            else
                value = [];
            end
        end
        
        function value = get.drinkingTime(obj)% State 44 entries and exits
            trial_events = obj.trialEvents;
            
            rowIndStart = find(trial_events(:,1)==44 & trial_events(:,2)==0, 1, 'first');
            rowIndStop = find(trial_events(:,1)==44 & trial_events(:,2)==3, 1, 'first'); % Timeout code = 3;

            if ~isempty(rowIndStart)
                value = [trial_events(rowIndStart, 3), trial_events(rowIndStop, 3)] - obj.trialStartTime;
            else
                value = [];
            end
        end
        
        function value = get.airpuffTimes(obj) % State 49 entries and exits.
            trial_events = obj.trialEvents;
            
            % Find first airpuff state entry, then first exit and pair them.  
            % Eliminate airpuff state event matrix entries (eg, licks in and out) 
            % already paired an any entries between paired entry/exit. 
            % Repeat until none are left.
            airpuff_events = trial_events(trial_events(:,1)==49,:);
            if isempty(airpuff_events)
                value = {};
            else
                num_exits = length(find(airpuff_events(:,2)==3));
                value = cell(1,num_exits);
                for k=1:num_exits
                    entry_ind = find(airpuff_events(:,2)==0, 1, 'first');
                    exit_ind = find(airpuff_events(:,2)==3, 1, 'first');
                    
                    entry_time = airpuff_events(entry_ind, 3);
                    exit_time = airpuff_events(exit_ind, 3);

                    value{k} = [entry_time, exit_time] - obj.trialStartTime;
                    airpuff_events = airpuff_events((exit_ind+1):end, :);
                end
            end
        end
        
        function value = get.timeoutPeriodTimes(obj) % State 45 entries and exits.
%             trial_events = obj.trialEvents;
%             
%             % Find first timeout period state entry, then first exit and pair them.  
%             % Eliminate timeout period state event matrix entries (eg, licks in and out) 
%             % already paired an any entries between paired entry/exit. 
%             % Repeat until none are left.
%             timeout_period_events = trial_events(trial_events(:,1)==45,:);
%             if isempty(timeout_period_events)
%                 value = {};
%             else
%                 num_exits = length(find(timeout_period_events(:,2)==3));
%                 value = cell(1,num_exits);
%                 for k=1:num_exits
%                     entry_ind = find(timeout_period_events(:,2)==0, 1, 'first');
%                     exit_ind = find(timeout_period_events(:,2)==3, 1, 'first');
%                     
%                     entry_time = timeout_period_events(entry_ind, 3);
%                     exit_time = timeout_period_events(exit_ind, 3);
% 
%                     value{k} = [entry_time, exit_time] - obj.trialStartTime;
%                     timeout_period_events = timeout_period_events((exit_ind+1):end, :);
%                 end
%             end
              value = [];
        end

        function value = get.samplingPeriodTime(obj)% State 41 entries and exits
            % can be computed from pinDescentOnsetTime and pinAscentOnsetTime in Detection protocol
            % 
            trial_events = obj.trialEvents;
            rowIndStart = find(trial_events(:,1)==41 & trial_events(:,2)==0, 1, 'first');
            rowIndStop = find(trial_events(:,1)==41 & trial_events(:,2)==3, 1, 'first'); % Timeout code = 3;
            if ~isempty(rowIndStart)
                value = [trial_events(rowIndStart, 3), trial_events(rowIndStop, 3)] - obj.trialStartTime;
            else
                value = [];
            end
        end
        
        function value = get.answerPeriodTime(obj)% State 42 entries and exits
            trial_events = obj.trialEvents;
            rowIndStart = find(trial_events(:,1)==42 & trial_events(:,2)==0, 1, 'first');
            rowIndStop = find(trial_events(:,1)==42 & ismember(trial_events(:,2), [1 2 3]), 1, 'first'); % Can exit via timeout, lick in, or lick out
            if ~isempty(rowIndStart)
                value = [trial_events(rowIndStart, 3), trial_events(rowIndStop, 3)] - obj.trialStartTime;
            else
                value = [];
            end
        end


        function value = get.pinDescentOnsetTime(obj) % State 41 entry
            protName = obj.protName; % Added by NX
            switch protName
                case 'poles_discobj'
                    pinEnterState = 41;
                case 'pole_detect_nxobj'
                    pinEnterState = 41;
                case {'pole_detect_nx2obj','pole_detect_nx4_2prigobj','pole_detect_gr_0obj'}
                    pinEnterState = 60;
            end
            rowInd = find(obj.trialEvents(:,1)== pinEnterState,1);
            if ~isempty(rowInd)
                value = obj.trialEvents(rowInd, 3) - obj.trialStartTime;
            else
                value = [];
            end
        end
          
        function value = get.pinAscentOnsetTime(obj) % State 48 entry
            protName = obj.protName;
            switch protName
                case 'poles_discobj'
                    pinLeaveState = 48;
                case 'pole_detect_nxobj'
                    pinLeaveState = 50;
                case {'pole_detect_nx2obj','pole_detect_nx4_2prigobj','pole_detect_gr_0obj'}
                    pinLeaveState = 61;
            end
            rowInd = find(obj.trialEvents(:,1)== pinLeaveState,1);
            if ~isempty(rowInd)
                value = obj.trialEvents(rowInd, 3) - obj.trialStartTime;
            else
                value = [];
            end
        end

        function value = get.trialTriggerTimeEPHUS(obj) % State 40 entry
            value = 0; %obj.trialStartTime;
%             rowInd = find(obj.trialEvents(:,1)==40,1);
%             if ~isempty(rowInd)
%                 value = obj.trialEvents(rowInd, 3);
%             else
%                 value = [];
%             end
        end

        function value = get.trialTriggerTimeCamera(obj) % State 40 entry
             value = 0; %obj.trialStartTime;
%             rowInd = find(obj.trialEvents(:,1)==40,1);
%             if ~isempty(rowInd)
%                 value = obj.trialEvents(rowInd, 3);
%             else
%                 value = [];
%             end
        end
        
        function value = get.answerLickTime(obj) 
%             if obj.trialType==1 && obj.trialCorrect==1 % Hit 
%                 value = obj.rewardTime;  % differs from reward onset time by at most 1/6000 sec (period of RTLinux server).  
%                 if length(value) > 1 % Can be empty in rare trials (due to stopping/starting Solo) that will be excluded later when making BehavTrialArray.
%                     value = value(1);
%                 end
% %                 value = obj.rewardTime(1); % differs from reward onset time by at most 1/6000 sec (period of RTLinux server).
%             elseif obj.trialType==0 && obj.trialCorrect==0 % False Alarm.
%                 value = obj.airpuffTimes{1}(1); % differs from onset of first airpuff time by at most 1/6000 sec (period of RTLinux server).
%             else
%                 value = []; % leave empty if trial is a correct rejection or a miss.
%             end  

              % modified by NX - having 10 columns of state matrix on 2P rig
              trial_events = obj.trialEvents;
              rowIndStart = find(trial_events(:,1)==42 & trial_events(:,2)==0, 1, 'first');
              rowIndStop = find(trial_events(:,1)==42 & ismember(trial_events(:,2), [1 2 7]), 1, 'first'); %
              if ismember(trial_events(rowIndStop, 2), [1 2]) % exit by licking
                  value = trial_events(rowIndStop, 3)- obj.trialStartTime; 
              else                                            % exit by timeout
                  value = [];
              end
        end
        
        function value = get.LickTimesPreAnswer(obj)
            % Only count licks after pole onset
            value = [];
            trial_events = obj.trialEvents;
            poleOnsetTime = obj.pinDescentOnsetTime + obj.trialStartTime;
            rowIndStart = find(trial_events(:,3)>= poleOnsetTime, 1, 'first');
            rowIndStop = find(trial_events(:,1) == 42 & trial_events(:,2)==0, 1, 'first');
            for i = rowIndStart: rowIndStop
                if trial_events(i,2)== 1
                    value = [value trial_events(i,3)-obj.trialStartTime];
                end;
            end
        end
        
        function value = get.LickTimesPostAnswer(obj)
            % Licks after the first answer lick
            value = [];
            trial_events = obj.trialEvents;
            rowIndStart = find(trial_events(:,1) == 42 & trial_events(:,2)==0, 1, 'first') + 1;
            rowIndStop = find(trial_events(rowIndStart:end,1) ==35, 1, 'first');
            for i = rowIndStart: rowIndStop
                if trial_events(i,2)== 1
                    value = [value trial_events(i,3)-obj.trialStartTime];
                end;
            end
        end

        function value = get.trialStartTime(obj) % State 40 entry
            rowInd = find(obj.trialEvents(:,1)==40,1);
            if ~isempty(rowInd)
                value = obj.trialEvents(rowInd, 3);
            else
                value = [];
            end
        end
        
        
        %                 % Determine trial start time by finding State 40 entry:
%                 rowInd = find(obj.trialEvents(:,1)==40,1);
%                 if ~isempty(rowInd)
%                     obj.trialStartTime = obj.trialEvents(rowInd, 3);
%                 end


    end
end

