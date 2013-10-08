%
%
%
% Subclass for Sandy Kuhlman's control experiment.
% DHO, 8/09.
%
%

classdef BehavTrialArray_SKControl < Solo.BehavTrialArray
    
    
    
    methods (Access = public)
        function obj = BehavTrialArray_SKControl(x, session_name)
            %
            % function obj = BehavTrialArray_SKControl(x, session_name)
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
                    trial_correct = x.saved.poles_SKControlobj_hit_history(k);
                    trial_events = x.saved_history.RewardsSection_LastTrialEvents{k};
                    
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
                    
                    if ismember(session_type, {'Discrim'})  % For now limit only to Discrim trials
                        behav_trial = Solo.BehavTrial(mouse_name, session_name, trial_num, trial_type,...
                            trial_correct, trial_events, use_flag, session_type, extra_ITI_on_error,...
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
    end
end




