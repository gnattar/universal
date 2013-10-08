%
%
%
%
% DHO, 5/08.
%
%
%
%
classdef BehavTrial < handle

    properties

        mouseName = '';
        sessionName = '';
        trialNum  = [];
        trialType = []; % 1 for go trial, 0 for no-go trial.
        trialCorrect = []; % 1 for correct, 0 for incorrect.
        trialEvents = [];
        nextTrialEvents = []; % Need to store trialEvents for next trial because licks in state 35 will largely
                              % be associated with next trial.
        useFlag   = 1; % set to 0 to mark bad trials.
        sessionType = '';
        extraITIOnErrorSetting = [];
        samplingPeriodTimeSetting = [];
        waterValveTimeSetting = [];
        answerPeriodTimeSetting = []; % 2 sec minus samplingPeriodTimeSetting
        motorPosition = [];
        nogoPosition = [];
        goPosition = [];

    end


    properties (Dependent = true, SetAccess = private)
        beamBreakTimes = [];    % Note that the last trial acquired in Solo will lack beambreaks
                                % occuring during the subsequent inter-trial-interval (i.e. state 35).
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
        trialStartTime = [];
        drinkingTime = []; % 2 s minus water valve time, to give mouse time to drink before proceeding w/ next trial.
        timeoutPeriodTimes = [];
        
        % Add:
        % RTFromEndOfSampling;
        % RTFromStartOfPinDescent;
    end

    methods (Access = public)
        function obj = BehavTrial(mouse_name, session_name, trial_num, trial_type,...
                trial_correct, trial_events, next_trial_events, varargin)
            %         function obj = BehavTrial(mouse_name, session_name, trial_num, trial_type,...
            %                 trial_correct, trial_events, next_trial_events, varargin)
            %
            %              VARARGIN:     useFlag, sessionType, extraITIOnErrorSetting,
            %              samplingPeriodTimeSetting, waterValveTimeSetting,
            %              motorPosition, nogoPosition, goPosition
            %
            if nargin > 0
                obj.mouseName = mouse_name;
                obj.sessionName = session_name;
                obj.trialNum  = trial_num;
                obj.trialType = trial_type; % 1 for go trial, 0 for no-go trial.
                obj.trialCorrect = trial_correct; % 1 for correct, 0 for incorrect.
                obj.trialEvents = trial_events;
                obj.nextTrialEvents = next_trial_events;
            end
            
            if nargin > 7
                obj.useFlag   = varargin{1}; % set to 0 to mark bad trials.
                obj.sessionType = varargin{2};
                obj.extraITIOnErrorSetting = varargin{3};
                obj.samplingPeriodTimeSetting = varargin{4};

                obj.answerPeriodTimeSetting = 2 - obj.samplingPeriodTimeSetting;

                obj.waterValveTimeSetting = varargin{5};
                obj.motorPosition = varargin{6};
                obj.nogoPosition = varargin{7};
                obj.goPosition = varargin{8};
            end
        end
               
        function plot_trial_events(obj)
            cla
            ymin = 0; ymax = 7; lw = 5; barw=.25;
            
            x = [obj.pinDescentOnsetTime, obj.pinAscentOnsetTime]; 
            if numel(x) < 2
                return % If Solo was stopped/started sometimes the pinAscentOnsetTime is missing
            end
%             y = 6*ones(size(x));
%             plot(x, y, 'k-','LineWidth',lw); hold on            
            xx=[x(1) x(2) x(2) x(1)]; yy= 5 + [-barw -barw barw barw]; hold on
            patch(xx,yy, 0.6*[1 1 1],'FaceAlpha',0.5,'LineStyle','none');

%             x = obj.samplingPeriodTime; 
% %             y = 5*ones(size(x));
% %             plot(x, y, 'c-','LineWidth',lw); hold on
%             xx=[x(1) x(2) x(2) x(1)]; yy= 5 + [-barw -barw barw barw];
%             patch(xx,yy, 'c','LineStyle','none');
            
            x = obj.answerPeriodTime; 
%             y = 4*ones(size(x));
%             plot(x, y, 'g-','LineWidth',lw); hold on
            xx=[x(1) x(2) x(2) x(1)]; yy= 4 + [-barw -barw barw barw]; 
            patch(xx,yy, 'k','LineStyle','none');
            
            x = obj.beamBreakTimes; 
            y = 3*ones(size(x));
            plot(x, y, 'mo','MarkerSize',9)
            
            if ~isempty(obj.rewardTime)
                x = [obj.rewardTime(1), obj.rewardTime(2)]; 
%                 y = 2*ones(size(x));
%                 plot(x, y, 'b-','LineWidth',lw)
                xx=[x(1) x(2) x(2) x(1)]; yy= 2 + [-barw -barw barw barw]; 
                patch(xx,yy, [0 96 255]./255,'FaceAlpha',1,'LineStyle','none');
            end
            
            p = obj.airpuffTimes;
            if ~isempty(p)
                for k=1:length(p)
                    puff_times = p{k};
                    x = puff_times; 
%                     y = ones(size(x));
%                     plot(x, y, 'r-','LineWidth',lw)
                    xx=[x(1) x(2) x(2) x(1)]; yy= 1 + [-barw -barw barw barw]; 
                    patch(xx,yy, [255 159 0]./255,'FaceAlpha',1,'LineStyle','none');
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
            
            set(gca, 'YTick', 1:5,'YTickLabel', {'Airpuff','Water valve','Beam breaks', 'Answer period','Pin valve'},...
                'FontSize', 12, 'TickDir','out','Box','off')
            xlabel('Sec','FontSize',12)
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
            trialEntryInd = find(obj.trialEvents(:,1)==40,1,'first');
            breakInd = find(obj.trialEvents(:,2)==1); % Limit to events occurring after the entry to
            % to the current trial (state 40).
            breakInd = breakInd(breakInd >= trialEntryInd);
            breakTimes = obj.trialEvents(breakInd, 3) - obj.trialStartTime;
            
            % Add beam breaks occuring in the subsequent intertrial interval:
            if ~isempty(obj.nextTrialEvents)
                ITIOverInd = find(obj.nextTrialEvents(:,1)==40,1,'first');
                breakIndITI = find(obj.nextTrialEvents(:,2)==1); % Get all beam breaks assigned to next trial
                % And then restrict to those occuring before state 40 of next trial.
                % These are in the intertrial interval and we'll include them for the
                % present trial. Thus, there will be no beam breaks with negative
                % times when aligned on state 40 entry.
                breakIndITI = breakIndITI(breakIndITI < ITIOverInd); 
                breakTimesITI = obj.nextTrialEvents(breakIndITI, 3) - obj.trialStartTime;
                value = [breakTimes; breakTimesITI];
            else
                value = breakTimes;
            end
        end
        
%         function value = get.beamBreakTimes(obj)
%             rowInd = find(obj.trialEvents(:,2)==1);
%             if ~isempty(rowInd)
%                 value = obj.trialEvents(rowInd, 3) - obj.trialStartTime; 
%                 % Need to add obj.nextTrialEvents < state 40 breaks.
%                 % Note that the last trial acquired in Solo will lack beambreaks
%                 % occuring during the subsequent inter-trial-interval (i.e. state 35).
%             else
%                 value = [];
%             end
%         end
        
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
            trial_events = obj.trialEvents;
            
            % Find first timeout period state entry, then first exit and pair them.  
            % Eliminate timeout period state event matrix entries (eg, licks in and out) 
            % already paired an any entries between paired entry/exit. 
            % Repeat until none are left.
            timeout_period_events = trial_events(trial_events(:,1)==45,:);
            if isempty(timeout_period_events)
                value = {};
            else
                num_exits = length(find(timeout_period_events(:,2)==3));
                value = cell(1,num_exits);
                for k=1:num_exits
                    entry_ind = find(timeout_period_events(:,2)==0, 1, 'first');
                    exit_ind = find(timeout_period_events(:,2)==3, 1, 'first');
                    
                    entry_time = timeout_period_events(entry_ind, 3);
                    exit_time = timeout_period_events(exit_ind, 3);

                    value{k} = [entry_time, exit_time] - obj.trialStartTime;
                    timeout_period_events = timeout_period_events((exit_ind+1):end, :);
                end
            end
        end

        function value = get.samplingPeriodTime(obj)% State 41 entries and exits
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
            rowInd = find(obj.trialEvents(:,1)==41,1);
            if ~isempty(rowInd)
                value = obj.trialEvents(rowInd, 3) - obj.trialStartTime;
            else
                value = [];
            end
        end
          
        function value = get.pinAscentOnsetTime(obj) % State 48 entry
            rowInd = find(obj.trialEvents(:,1)==48,1);
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
            if obj.trialType==1 && obj.trialCorrect==1 % Hit 
                value = obj.rewardTime;  % differs from reward onset time by at most 1/6000 sec (period of RTLinux server).  
                if length(value) > 1 % Can be empty in rare trials (due to stopping/starting Solo) that will be excluded later when making BehavTrialArray.
                    value = value(1);
                end
%                 value = obj.rewardTime(1); % differs from reward onset time by at most 1/6000 sec (period of RTLinux server).
            elseif obj.trialType==0 && obj.trialCorrect==0 % False Alarm.
                value = obj.airpuffTimes{1}(1); % differs from onset of first airpuff time by at most 1/6000 sec (period of RTLinux server).
            else
                value = []; % leave empty if trial is a correct rejection or a miss.
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

    end
end

