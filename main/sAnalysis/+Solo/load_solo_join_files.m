function r = load_solo_join_files(x,y,trim)
%
% For use when computer crash forces saving a single behavioral session in two files.
%  x and y are file name strings.
%  trim has form: [begintrim endtrim]
% DHO 6/07.
%

if isa(x,'char') & isa(y,'char')
    x = load(x); y = load(y);
end

if isa(x,'struct') & isa(y,'struct')

    r = x;

    
    r.saved.poles_discobj_hit_history = [r.saved.poles_discobj_hit_history; y.saved.poles_discobj_hit_history];
    r.saved.SidesSection_previous_sides = [r.saved.SidesSection_previous_sides(1:(end-1)) y.saved.SidesSection_previous_sides];
   
    
    
    r.saved_history.SavingSection_MouseName = [r.saved_history.SavingSection_MouseName; y.saved_history.SavingSection_MouseName];
    
    if isfield(r.saved,'SavingSection_Weight')
        r.saved_history.SavingSection_Weight = [r.saved_history.SavingSection_Weight; y.saved_history.SavingSection_Weight];
    elseif isfield(r.saved,'SavingSection_WeightBeforeExp')
        r.saved_history.SavingSection_WeightBeforeExp = [r.saved_history.SavingSection_WeightBeforeExp; y.saved_history.SavingSection_WeightBeforeExp];
        r.saved_history.SavingSection_WeightAfterExp = [r.saved_history.SavingSection_WeightAfterExp; y.saved_history.SavingSection_WeightAfterExp];
    end

    
    r.saved_history.SavingSection_HeadFixed = [r.saved_history.SavingSection_HeadFixed; y.saved_history.SavingSection_HeadFixed];
    r.saved_history.SavingSection_Lighting = [r.saved_history.SavingSection_Lighting; y.saved_history.SavingSection_Lighting];
    
    if isfield(r.saved, 'SavingSection_AirpuffPressure')
        r.saved_history.SavingSection_AirpuffPressure = [r.saved_history.SavingSection_AirpuffPressure; y.saved_history.SavingSection_AirpuffPressure];
    elseif isfield(r.saved, 'SavingSection_Punishment')
        r.saved_history.SavingSection_Punishment = [r.saved_history.SavingSection_Punishment; y.saved_history.SavingSection_Punishment];
    end

    if isfield(r.saved, 'saved.NotesSection_notes')
        r.saved.NotesSection_notes = [r.saved.NotesSection_notes; y.saved.NotesSection_notes];
    end
    
%     NotesSection_notes
    
    r.saved_history.SavingSection_sectiontitle = [r.saved_history.SavingSection_sectiontitle; y.saved_history.SavingSection_sectiontitle];
    r.saved_history.SessionTypeSection_SessionType = [r.saved_history.SessionTypeSection_SessionType; y.saved_history.SessionTypeSection_SessionType];
    r.saved_history.SessionTypeSection_title = [r.saved_history.SessionTypeSection_title; y.saved_history.SessionTypeSection_title];
    r.saved_history.TimesSection_ExtraITIOnError = [r.saved_history.TimesSection_ExtraITIOnError; y.saved_history.TimesSection_ExtraITIOnError];
    r.saved_history.TimesSection_title = [r.saved_history.TimesSection_title; y.saved_history.TimesSection_title];
    r.saved_history.ValvesSection_WaterValveTime = [r.saved_history.ValvesSection_WaterValveTime; y.saved_history.ValvesSection_WaterValveTime];
    r.saved_history.ValvesSection_title = [r.saved_history.ValvesSection_title; y.saved_history.ValvesSection_title];
    r.saved_history.SidesSection_MaxSame = [r.saved_history.SidesSection_MaxSame; y.saved_history.SidesSection_MaxSame];
    if isfield(r.saved, 'SidesSection_LeftProb')
        r.saved_history.SidesSection_LeftProb = [r.saved_history.SidesSection_LeftProb; y.saved_history.SidesSection_LeftProb];
    else
        r.saved_history.SidesSection_NoGoProb = [r.saved_history.SidesSection_NoGoProb; y.saved_history.SidesSection_NoGoProb];
    end
    r.saved_history.SidesSection_sidestitle = [r.saved_history.SidesSection_sidestitle; y.saved_history.SidesSection_sidestitle];
    r.saved_history.SidesSection_ntrials = [r.saved_history.SidesSection_ntrials; y.saved_history.SidesSection_ntrials];
    r.saved_history.SMControlSection_sm_control_show = [r.saved_history.SMControlSection_sm_control_show; y.saved_history.SMControlSection_sm_control_show];
    r.saved_history.SMControlSection_sectiontitle = [r.saved_history.SMControlSection_sectiontitle; y.saved_history.SMControlSection_sectiontitle];
    r.saved_history.MotorsSection_motor_show = [r.saved_history.MotorsSection_motor_show; y.saved_history.MotorsSection_motor_show];
    r.saved_history.MotorsSection_sectiontitle = [r.saved_history.MotorsSection_sectiontitle; y.saved_history.MotorsSection_sectiontitle];

    if isfield(r.saved, 'MotorsSection_right_motor_position')
        r.saved_history.MotorsSection_right_motor_position = [r.saved_history.MotorsSection_right_motor_position; y.saved_history.MotorsSection_right_motor_position];
        r.saved_history.MotorsSection_left_motor_position = [r.saved_history.MotorsSection_left_motor_position; y.saved_history.MotorsSection_left_motor_position];
    else
        r.saved_history.MotorsSection_motor_position = [r.saved_history.MotorsSection_motor_position; y.saved_history.MotorsSection_motor_position];
    end
    r.saved_history.poles_discobj_prot_title = [r.saved_history.poles_discobj_prot_title; y.saved_history.poles_discobj_prot_title];
    r.saved_history.RewardsSection_LastTrialEvents = [r.saved_history.RewardsSection_LastTrialEvents; y.saved_history.RewardsSection_LastTrialEvents];
    
else
    error('Wrong input argument types---must be 2 file names or 2 loaded session file structures.')
end


r.trim = trim; 