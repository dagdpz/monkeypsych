%% Initiate conditions
global SETTINGS
%

if ~exist('dyn','var') || dyn.trialNumber == 1
    
 
    
 % esperimentazione        = {'calibration'};
    % esperimentazione     = {'Direct_Sac'};
    % esperimentazione      = {'Delay_Sac'};
    % esperimentazione        = {'Delay diss_saccade'};par_eye
% esperimentazione        = {'Delay free_gaze'};
% esperimentazione        = {'Delay free_gaze','rest','Delay free_gaze','rest'};
 esperimentazione        = {'rest'};
    add_4_deg_randomization = 0;
    si_counter=0;
    for n_exp = 1:numel(esperimentazione)
        experiment=esperimentazione{n_exp};
        shuffle_conditions                  = 2;
        force_conditions                    = 3;
        task.calibration                    = 0;
        SETTINGS.GUI_in_acquisition         = 0;
        SETTINGS.check_motion_jaw           = 0;
        SETTINGS.check_motion_body          = 0;
        SETTINGS.RewardSound                = 1;
        PEST_ON                             = 0;
        multiple_targets_per_trial          = 0;
%         fix_eye_y                           = -2.5;
%         fix_hnd_y                           = -6.5;
%         pool_of_angles                      = [40,0,320,220,180,140]; %[20,0,340,200,180,160];
        
        fix_eye_y                           = -8;
        fix_hnd_y                           = -12;
        pool_of_angles                      = [40,0,320,220,180,140]; %[20,0,340,200,180,160];
%         fix_eye_y                           = -2;
%         fix_hnd_y                           = -5;
%         pool_of_angles                      = [20,0,340,160,180,200];
        
        
        task.reward.time_neutral            = [0.25 0.25]; % 0.6s -> 0.2ml per hit
        task.rest_hand                      = [0 0]; % which hands on the sensor to start the trial
        task.check_screen_touching          = 1;
        %% IMPORTANT TO CHECK!!!
        if strcmp(experiment,'calibration') || strcmp(experiment,'Baseline stim project direct saccades') || strcmp(experiment,'Baseline stim project memory saccades')
            SETTINGS.take_angles_con        = 1;
        else
            SETTINGS.take_angles_con        = 0;
        end
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
            'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0,'offset_con',0,'invert_con',0,'exact_excentricity_con_x',NaN,'exact_excentricity_con_y',NaN,'reward_con',1,'reward_sound_con',1,'rest_hands_con',1,'var_x',0,'var_y',0);
        
        
        
        switch experiment
            
            case 'calibration'
                SETTINGS.GUI_in_acquisition         = 1;
                SETTINGS.take_angles_con            = 1;
                
                N_repetitions                       = 100;
                
                task.calibration                    = 1;
                %task.reward.time_neutral            = [0.1 0.1];
                reward_time                         =  0.26;
                task.rest_hand                      = [0 0];
                All.rest_hands_con                  = 0;

                All.offset_con                      = 0;
                All.reach_hand_con                  = 2;
                All.type_con                        = 1;
                All.effector_con                    = 0;
                All.reach_hand_con                  = 2;
                All.timing_con                      = 0;
                All.size_con                        = 0;
                All.instructed_choice_con           = 0;
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-24 -12 12 24];
                    All.exact_excentricity_con_y    = [20 0 -20];
                else
                    All.excentricities              = 12;
                    All.angle_cases                 = [1,2,3,4,5,6];
                end
                PEST_ON                             = 0;
                SETTINGS.GUI_in_acquisition         = 1;
                
            case 'rest'
                SETTINGS.take_angles_con            = 1;
                N_repetitions                       = 47; %47 36 %100
                task.rest_hand                      = [0 0];

                All.offset_con                      = 0;
                All.reach_hand_con                  = 2;
                All.type_con                        = 1;
                All.effector_con                    = 0;
                All.timing_con                      = 3; % rest
                All.size_con                        = 3; % rest
                All.instructed_choice_con           = 0;
                All.var_x                           = 0;
                All.var_y                           = 0;
                All.reward_con                      = 0;
                All.reward_sound_con                = 0;
                All.rest_hands_con                  = 0;
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = 0;
                    All.exact_excentricity_con_y    = 1;
                else
                    All.excentricities              = 2;
                    All.angle_cases                 = 1;
                end
                
                
            case 'Delay_Sac'
                SETTINGS.take_angles_con            = 1;
                
                N_repetitions                       = 10; % N trials for each condition
                
                All.offset_con                      = 0;
                All.reach_hand_con                  = [0];
                All.type_con                        = 4; % 2 direct  % 3 memory  % 4 delay
                All.effector_con                    = 0; % 0 only eye  % 1 only hand  % 3 dissociated saccade %4 dissociated reach  %6 free gaze reach
                All.timing_con                      = 2; %timing
                All.size_con                        = 2; % target size
                All.instructed_choice_con           = [0];%[0 1]
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [15];
                    All.angle_cases                 = [1,2,3,4,5,6];
                end
                All.stim_con                        = 0;
                if PEST_ON==1
                    All.stim_con                    = 0;
                    PEST_hnd_or_eye                 = 'eye';
                    PEST_effector                   = 1;
                end
                
            case 'Delay free_gaze'
    SETTINGS.VisFeedback_rest_hand = 1;
    task.hnd.ini(1).x = 0;
    task.hnd.ini(2).x = task.hnd.ini(1).x;
    task.hnd.ini(1).y = -12;
    task.hnd.ini(2).y = task.hnd.ini(1).y;
    task.hnd.ini(1).shape = 'square_frame';
    task.hnd.ini(2).shape = 'square';

    task.hnd.ini(1).size = 1;
    task.hnd.ini(2).size = task.hnd.ini(1).size;
    task.hnd.ini(1).color = [60 60 60];
    task.hnd.ini(2).color = task.hnd.ini(1).color;
  
                SETTINGS.take_angles_con            = 1;
                SETTINGS.check_motion_jaw           = 0;
                
                N_repetitions                       = 10;%5
                
                
                %task.reward.time_neutral            = [0.24 0.24]; % 0.2s -> 0.2ml per hit
                reward_time                         =  0.24;
                task.rest_hand                      = [1 1]; % which hands on the sensor to start the trial

                % All.offset_con                      = [-15 0 15];
                All.offset_con                      = 0;
                All.reach_hand_con                  = [1 2]; % 1 left 2 right hand
                All.type_con                        = 4;
                All.effector_con                    = 6; %6
                
                
                All.timing_con                      = 31;
                All.size_con                        = 2;
                All.instructed_choice_con           = [0 1]; %  0 instr  1 choice
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [15]; % 16
                    All.angle_cases                 = [1,2,3,4,5,6]; %1,2,3,4,5,6
                end
                All.stim_con                        = 0;
                if PEST_ON==1
                    All.stim_con                    = 0;
                    PEST_hnd_or_eye                 = 'eye';
                    PEST_effector                   = 1;
                end
                
            case 'Direct_Sac'
                SETTINGS.take_angles_con            = 1;
                
                N_repetitions                       = 10; % N trials for each condition
                
                %task.reward.time_neutral            = [0.2 0.2]; % 0.6s -> 0.2ml per hit
                reward_time                         =  0.2;
                task.rest_hand                      = [0 0];
                
                All.offset_con                      = 0;
                All.reach_hand_con                  = [0];
                All.type_con                        = 2;
                All.effector_con                    = 0; % 3 4 6
                All.timing_con                      = 1; %timing
                All.size_con                        = 1; % target size
                All.instructed_choice_con           = [0];
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [12];
                    All.angle_cases                 = [1,2,3];
                end
                All.stim_con                        = 0;
                if PEST_ON==1
                    All.stim_con                    = 0;
                    PEST_hnd_or_eye                 = 'eye';
                    PEST_effector                   = 1;
                end
                
            case 'Delay diss_saccade'
                SETTINGS.take_angles_con            = 1;
                
                N_repetitions                       = 10;
                
                
                %task.reward.time_neutral            = [0.2 0.2]; % 0.6s -> 0.2ml per hit
                reward_time                         =  0.2;
                task.rest_hand                      = [1 1];
                
                All.offset_con                      = 0;
                All.reach_hand_con                  = [1 2];
                All.type_con                        = 4;
                All.effector_con                    = 3;
                All.timing_con                      = 31;  % 31 or 33
                All.size_con                        = 20;
                All.instructed_choice_con           = [0 1];
                All.var_x                           = 0;
                All.var_y                           = 0;
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [15]; % 16
                    All.angle_cases                 = [1,2,3,4,5,6];
                end
                All.stim_con                        = 0;
                if PEST_ON==1
                    All.stim_con                    = 0;
                    PEST_hnd_or_eye                 = 'eye';
                    PEST_effector                   = 1;
                end
                
                
                
                
                
        end
        
        all_fieldnames=fieldnames(All);
        N_total_conditions       =1;
        sequence_cell            ={};
        for FN=1:numel(all_fieldnames)
            N_total_conditions=N_total_conditions*numel(All.(all_fieldnames{FN}));
            sequence_cell=[sequence_cell, {All.(all_fieldnames{FN})}];
        end
        
        sequence_matrix_exp_temp          = repmat(combvec(sequence_cell{:}),1,N_repetitions);
        
        
        idx_var_x=find(ismember(all_fieldnames,'var_x'));
        idx_var_y=find(ismember(all_fieldnames,'var_y'));
        if add_4_deg_randomization
            for ii=1:size(sequence_matrix_exp_temp,2)
                sequence_matrix_exp_temp(idx_var_x,ii)=sequence_matrix_exp_temp(idx_var_x,ii)+((rand()-0.5)*8);
                sequence_matrix_exp_temp(idx_var_y,ii)=sequence_matrix_exp_temp(idx_var_y,ii)+((rand()-0.5)*8);
            end
        end
        
        sequence_matrix_exp{n_exp}          = sequence_matrix_exp_temp;
        ordered_sequence_indexes_exp{n_exp} = (1:N_total_conditions*N_repetitions) + si_counter;
        si_counter                          = numel(ordered_sequence_indexes_exp{n_exp}) +si_counter;
    end
    
    
    sequence_matrix          = [sequence_matrix_exp{:}];
    idx_exact_x=ismember(all_fieldnames,'exact_excentricity_con_x');
    idx_exact_y=ismember(all_fieldnames,'exact_excentricity_con_y');
    conditions_to_remove=(sequence_matrix(idx_exact_y,:)==0 & sequence_matrix(idx_exact_x,:)==0);
    sequence_matrix(:,conditions_to_remove)=[];
    
    
    
    ordered_sequence_indexes = 1:(numel([ordered_sequence_indexes_exp{:}])-sum(conditions_to_remove));
end


%% PEST
if PEST_ON==1
    stepsize_min          = 0.3;
    fix_limits            = [-40+Current_con.excentricities 40-Current_con.excentricities];
    
    if exist('dyn','var') && dyn.trialNumber > 1
        selected_target_t=trial(dyn.trialNumber-1).target_selected(PEST_effector);
        if isempty(selected_target_t) || isnan(selected_target_t) || trial(dyn.trialNumber-1).success==0 || trial(dyn.trialNumber-1).choice==0
            r_chosen(dyn.trialNumber-1)=false;
            l_chosen(dyn.trialNumber-1)=false;
        else
            r_chosen(dyn.trialNumber-1)=[trial(dyn.trialNumber-1).(PEST_hnd_or_eye).tar(selected_target_t).pos(1) - trial(dyn.trialNumber-1).(PEST_hnd_or_eye).fix.pos(1)]>0;
            l_chosen(dyn.trialNumber-1)=[trial(dyn.trialNumber-1).(PEST_hnd_or_eye).tar(selected_target_t).pos(1) - trial(dyn.trialNumber-1).(PEST_hnd_or_eye).fix.pos(1)]<0;
        end
        any_chosen_idx=find(any([r_chosen; l_chosen],1));
    else
        any_chosen_idx=[];
    end
    if numel(any_chosen_idx)>1
        preferred_behaviour=any(r_chosen(any_chosen_idx(end-1:end))) && any(l_chosen(any_chosen_idx(end-1:end)));
        if r_chosen(dyn.trialNumber-1) || l_chosen(dyn.trialNumber-1)
            [fix_eye_x stepsize] = PEST(fix_eye_x,fix_limits,r_chosen(dyn.trialNumber-1),preferred_behaviour,stepsize,stepsize_min);
        end
    else
        stepsize              = 1;
        fix_eye_x             = 0;
    end
    PEST_list(dyn.trialNumber)=fix_eye_x;
    %stepsize
    %PEST_list
    if stepsize<=stepsize_min
        dyn.state = STATE.CLOSE;
        PEST_list
        return
    end
else
    %    fix_eye_x             = fix_offset;
end


%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
    shuffled_sequence_indexes_exp=ordered_sequence_indexes_exp;
elseif dyn.trialNumber == 1 && (shuffle_conditions==1)
    sequence_indexes = Shuffle(ordered_sequence_indexes);
    shuffled_sequence_indexes_exp=ordered_sequence_indexes_exp;
elseif dyn.trialNumber == 1 && (shuffle_conditions==2) %% shuffling within experiment (for blocked designs!)
    
    shuffled_sequence_indexes_exp = cellfun(@Shuffle,ordered_sequence_indexes_exp,'UniformOutput',false);
    sequence_indexes = [shuffled_sequence_indexes_exp{:}];
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if force_conditions==1
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        
    elseif force_conditions==2 % semi-forced: if trial is unsuccessful, the condition is put back into the pool
        if trial(end-1).success==1
            sequence_indexes=sequence_indexes(2:end);
        else
            sequence_indexes=Shuffle(sequence_indexes);
        end
        if numel(sequence_indexes)==0
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(1);
        end
    elseif force_conditions==3  %% semi-forced, but keeping blocks
        if trial(end-1).success==1
            if isempty(shuffled_sequence_indexes_exp{1}) && numel(shuffled_sequence_indexes_exp)>1
                shuffled_sequence_indexes_exp=shuffled_sequence_indexes_exp(2:end);
            end
            shuffled_sequence_indexes_exp{1}(1)=[];
        else
            shuffled_sequence_indexes_exp = cellfun(@Shuffle,shuffled_sequence_indexes_exp,'UniformOutput',false);
        end
        sequence_indexes = [shuffled_sequence_indexes_exp{:}];
        if numel(sequence_indexes)==0
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(1);
        end
    else
        if numel(trial)-1==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(numel(trial));
        end
    end
else
    custom_trial_condition = sequence_indexes(1);
    
    
    
    
    %     %% bar plot for conditions
    %
    % conditions_to_plot=1:6;
    %
    % sequence_matrix_inverted=sequence_matrix';
    % unique_sequence=unique(sequence_matrix_inverted(:,conditions_to_plot),'rows');
    % current_con_index=find(ismember(unique_sequence,sequence_matrix_inverted(sequence_indexes(1),conditions_to_plot),'rows'));
    % experiment_fieldnames=all_fieldnames(conditions_to_plot);
    %
    % cond=1:6;
    %
    % idx_con=ismember(cond,current_con_index);
    % if dyn.trialNumber==1
    %     hist_cond=[0 0 0 0 0 0];
    % else
    %     hist_cond=hist_cond+idx_con;
    % end
    %
    % figure
    % bar(1:6, hist_cond)
    % % for n=1:numel(experiment_fieldnames)
    % %     FN=experiment_fieldnames{n};
    % %    All_experiment.(FN) = unique(unique_sequence(:,n));
    % % end
    
    
    
    
end

%dyn.trial_classifier(1)=numel(All.tar_pos_con);
for field_index=1:numel(all_fieldnames)
    Current_con.(all_fieldnames{field_index})=sequence_matrix(field_index,custom_trial_condition);
    %dyn.trial_classifier(field_index+1) = Current_con.(all_fieldnames{field_index});
    dyn.trial_classifier(field_index) = abs(round(Current_con.(all_fieldnames{field_index})));
end


%% Fixation offset
fix_eye_x             = Current_con.offset_con;
fix_hnd_x             = fix_eye_x;

%% CHOICE\INSTRUCTED
task.choice                 = Current_con.instructed_choice_con;

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con;

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;

%% reward
if Current_con.reward_con==0
    task.reward.time_neutral            = [0 0];
elseif Current_con.reward_con==1
    task.reward.time_neutral            = [reward_time reward_time];
end
if Current_con.reward_sound_con==0
        SETTINGS.RewardSound                = 0;
elseif Current_con.reward_sound_con==1
        SETTINGS.RewardSound                = 1;
end

if Current_con.rest_hands_con==0        
        task.rest_hand                      = [0 0];
elseif Current_con.rest_hands_con==1
        task.rest_hand                      = [1 1];
end


%% TIMING
switch Current_con.timing_con
    case 0 % 'calibration'
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1; %1
        task.timing.tar_time_to_acquire_hnd     = 1.5; % 1.5
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5;
        task.timing.fix_time_hold               = 0.8;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.5;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0;
        
    case 1 %'direct'
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        task.timing.ITI_success                 = 2; % 3 inter trial interval
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 3; % 3 inter trial interval
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 0.7;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.7;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.8; % 0.5
        task.timing.fix_time_hold_var           = 0.5; % 0
        task.timing.cue_time_hold               = 0.300; % 0.28
        task.timing.cue_time_hold_var           = 0; % 0
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0.7; % 1
        task.timing.del_time_hold_var           = 0.5; % 0
        task.timing.tar_inv_time_hold           = 0.2;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 2 %'delay'
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        task.timing.ITI_success                 = 3; % 2 inter trial interval
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 4; % 3 inter trial interval
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 0.7;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 1.5;
        task.timing.tar_time_to_acquire_eye     = 0.8;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.4; % 0.5
        task.timing.fix_time_hold_var           = 0; % 0
        task.timing.cue_time_hold               = 0.300; % 0.28
        task.timing.cue_time_hold_var           = 0.1; % 0
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0.5; % 1
        task.timing.del_time_hold_var           = 0.2; % 0
        task.timing.tar_inv_time_hold           = 0.2;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.100;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 3 %'rest'
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        task.timing.ITI_success                 = 1; % 2 inter trial interval
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1; % 3 inter trial interval
        task.timing.ITI_fail_var                = 0;
        task.timing.fix_time_to_acquire_eye     = 1.5;
        task.timing.fix_time_hold               = 10; % 300
        task.timing.fix_time_hold_var           = 0; % 0
        
    case 31 %'memory ephys'  'Delay'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.3;
        task.timing.ITI_success                 = 2; % 3 inter trial interval
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 3; % 3 inter trial interval
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1.5;%1.5
        task.timing.tar_time_to_acquire_hnd     = 0.8; %0.8
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 1;%0.5
        task.timing.tar_time_to_acquire_eye     = 1;%0.5
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.5; % 0.5
        task.timing.fix_time_hold_var           = 0.1; % 0.5
        task.timing.cue_time_hold               = 0.3; % 0.28
        task.timing.cue_time_hold_var           = 0; % 0
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0.5; % 1
        task.timing.del_time_hold_var           = 0.1; % 0.5
        task.timing.tar_inv_time_hold           = 0.2;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.25;
        task.timing.tar_time_hold_var           = 0.0;
end

%% RADIUS & SIZES

if task.type==5 || task.type==6
    task.eye=rmfield(task.eye,'tar');
    task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    case 0 %'calibration'
        task.eye.fix.size       = 1;
        task.eye.fix.radius     = 10;
        task.eye.tar(1).size    = 1;
        task.eye.tar(1).radius  = 10;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
    case 1 %'direct'
        task.eye.fix.size       = 2;
        task.eye.fix.radius     = 7;
        task.eye.tar(1).size    = 2;
        task.eye.tar(1).radius  = 10;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 2 %'delay'
        task.eye.fix.size       = 1;
        task.eye.fix.radius     = 11;
        task.eye.tar(1).size    = 3;
        task.eye.tar(1).radius  = 7;
        
        task.hnd.fix.radius     = 8; %8
        task.hnd.fix.size       = 4; %4
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 8;
        
    case 3 %'rest'
        task.eye.fix.size       = 0;
        task.eye.fix.radius     = 300;
        task.eye.tar(1).size    = 0;
        task.eye.tar(1).radius  = 300;
        
        task.hnd.fix.radius     = 0;
        task.hnd.fix.size       = 0;
        task.hnd.tar(1).size    = 0;
        task.hnd.tar(1).radius  = 0;
        
end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

%% POSITIONS

if SETTINGS.take_angles_con
    current_angle=pool_of_angles(Current_con.angle_cases); %
    tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
    tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);
else
    tar_dis_x   = Current_con.exact_excentricity_con_x;
    tar_dis_y   = Current_con.exact_excentricity_con_y;
end

tar_dis_1x = + tar_dis_x + Current_con.var_x;
tar_dis_1y = + tar_dis_y + Current_con.var_y;
tar_dis_2x = - tar_dis_x + Current_con.var_x;  %%%%% CHANGE HERE TO (-) FOR SYMETRIC CONTRACTION EXPANSION OR (+) FOR SYMETRIC LEFT RIGHT
tar_dis_2y = + tar_dis_y + Current_con.var_y;

if     multiple_targets_per_trial == 1; % 18 positions for match to sample saccades(!)
    ex_LR = Current_con.excentricities;
    All_positions_right= Shuffle({ [ex_LR,f_h], [ex_LR,f_h+d_pos], [ex_LR,f_h-d_pos], [ex_LR+d_pos,f_h], [ex_LR+d_pos,f_h+d_pos], [ex_LR+d_pos,f_h-d_pos], [ex_LR-d_pos,f_h], [ex_LR-d_pos,f_h+d_pos], [ex_LR-d_pos,f_h-d_pos]});
    All_positions_left = Shuffle({[-ex_LR,f_h],[-ex_LR,f_h+d_pos],[-ex_LR,f_h-d_pos],[-ex_LR+d_pos,f_h],[-ex_LR+d_pos,f_h+d_pos],[-ex_LR+d_pos,f_h-d_pos],[-ex_LR-d_pos,f_h],[-ex_LR-d_pos,f_h+d_pos],[-ex_LR-d_pos,f_h-d_pos]});
    tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;
    
elseif multiple_targets_per_trial == 2 % Positions for RF mapping(!)
    Used_pool_of_angles=pool_of_angles(All.angle_cases);
    %Current_pool_of_excentircities = Current_con.excentricities;
    
    %         All_positions_x=[];
    %         All_positions_y=[];
    %for ex_idx=1:numel(Current_pool_of_excentircities)
    All_positions_x=Current_con.excentricities*cos(Used_pool_of_angles*2*pi/360);
    All_positions_y=Current_con.excentricities*sin(Used_pool_of_angles*2*pi/360);
    %end
    
    All_positions_mat =[All_positions_x+ fix_offset;All_positions_y+ f_h]';
    All_positions     =num2cell(All_positions_mat,2);
    if shuffle_angles_per_trial
        All_positions = Shuffle(All_positions);
    end
    % + fix_offset
    % + f_h
    tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;
end

if task.type==1
    
    task.eye.fix.x    = fix_eye_x  + tar_dis_1x;
    task.eye.fix.y    = fix_eye_y  + tar_dis_1y;
    task.hnd.fix.x    = fix_hnd_x  + tar_dis_1x;
    task.hnd.fix.y    = fix_hnd_y  + tar_dis_1y;
else
    
    task.eye.fix.x    = fix_eye_x;
    task.eye.fix.y    = fix_eye_y;
    task.hnd.fix.x    = fix_hnd_x;
    task.hnd.fix.y    = fix_hnd_y;
end

if task.effector==3
    
    task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
    task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
    task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
    task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;
    
    task.hnd.tar(1).x = fix_hnd_x;
    task.hnd.tar(1).y = fix_hnd_y;
    task.hnd.tar(2).x = fix_hnd_x;
    task.hnd.tar(2).y = fix_hnd_y;
elseif task.effector==4 || task.effector==6
    
    task.eye.tar(1).x = fix_eye_x;
    task.eye.tar(1).y = fix_eye_y;
    task.eye.tar(2).x = fix_eye_x;
    task.eye.tar(2).y = fix_eye_y;
    
    task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
    task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
    task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
    task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
else
    
    task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
    task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
    task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
    task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;
    
    task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
    task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
    task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
    task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
end

%% COLORS
task.eye.fix.color_dim          = [128 0 0]; %
task.eye.fix.color_bright       = [255 0 0];
task.eye.tar(1).color_dim       = [128 0 0];  % 2.5 or 3
task.eye.tar(1).color_bright    = [255 0 0];
task.eye.tar(2).color_dim       = [128 0 0]; %  % 2.5 or 3
task.eye.tar(2).color_bright    = [255 0 0];

task.hnd_right.color_dim        = [0 128 0]; %[0 128 0]
task.hnd_right.color_bright     = [0 255 0]; %[0 255 0]
task.hnd_right.color_cue_dim    = [0 128 0];
task.hnd_right.color_cue_bright = [0 255 0];
task.hnd_left.color_dim         = [39 109 216]; %
task.hnd_left.color_bright      = [119 230 253];
task.hnd_left.color_cue_dim     = [39 109 216];
task.hnd_left.color_cue_bright  = [119 230 253];
task.hnd_stay.color_dim         = [128 129 0];
task.hnd_stay.color_bright      = [255 255 0];

%% target distribution left right (for Match to sample)
switch Current_con.tar_dis_con
    case 0
        N_targets_left=1;N_targets_right=1; % for non-m2s-tasks
    case 1
        N_targets_left=2;N_targets_right=7;
    case 2
        N_targets_left=7;N_targets_right=2;
    case 3
        N_targets_left=3;N_targets_right=6;
    case 4
        N_targets_left=6;N_targets_right=3;
    case 5
        N_targets_left=4;N_targets_right=5;
    case 6
        N_targets_left=5;N_targets_right=4;
    case 7
        N_targets_left=2;N_targets_right=2;
    case 8
        N_targets_left=3;N_targets_right=2;
    case 9
        N_targets_left=2;N_targets_right=3;
    case 10
        N_targets_left=2;N_targets_right=5;
    case 11
        N_targets_left=5;N_targets_right=2;
    case 12
        N_targets_left=3;N_targets_right=4;
    case 13
        N_targets_left=4;N_targets_right=3;
    case 14
        N_targets_left=1;N_targets_right=2;
    case 15
        N_targets_left=2;N_targets_right=1;
end
task.n_targets=N_targets_left+N_targets_right;

%% target shapes (for Match to sample)
all_curv=[0.6,0.3,-0.3,-0.6];
convex_sides=repmat({'LR'},1,task.n_targets);
switch Current_con.shape_con
    case 1
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
    case 2
        task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(randi([3,4],[1,task.n_targets-2]))]);
    case 3
        task.convexities=num2cell([all_curv(3),all_curv(4),all_curv(randi([1,2],[1,task.n_targets-2]))]);
    case 4
        task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
    case 5 % fro cornz learning
        task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
    case 6
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
    case 7 % fro cornz learning
        task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(3),all_curv(3),all_curv(randi([3,4],[1,task.n_targets-4]))]);
    case 8
        task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(2),all_curv(2),all_curv(randi([1,2],[1,task.n_targets-4]))]);
    case 9 % fro cornz learning
        task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(1),all_curv(4)]);
    case 10
        task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(4),all_curv(1)]);
end

%% match and main distractor distribution (for Match to sample)
switch Current_con.mat_dis_con
    case 1
        match_left=1; distractor_left=1;
    case 2
        match_left=1; distractor_left=0;
    case 3
        match_left=0; distractor_left=1;
    case 4
        match_left=0; distractor_left=0;
end

if task.type==5 || task.type==6
    if isfield(task,'tar_pos')
        rmfield(task,'tar_pos');
    end
    if match_left
        task.tar_pos{1}=All_positions_left{1};
    else
        task.tar_pos{1}=All_positions_right{1};
    end
    if distractor_left
        task.tar_pos{2}=All_positions_left{2};
    else
        task.tar_pos{2}=All_positions_right{2};
    end
    for n_target=3:task.n_targets
        if n_target+match_left+distractor_left-2<=N_targets_left
            task.tar_pos{n_target}=All_positions_left{n_target};
        else
            task.tar_pos{n_target}=All_positions_right{n_target};
        end
    end
    
    
    for n_target                                    = 1:task.n_targets
        task.eye.tar(n_target).size                 = task.eye.tar(1).size;
        task.eye.tar(n_target).radius               = task.eye.tar(1).radius;
        task.hnd.tar(n_target).size                 = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius               = task.hnd.tar(1).radius;
        task.eye.tar(n_target).color_dim            = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright         = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor            = [];
        task.eye.tar(n_target).ringColor2           = [0 0 0];
        task.eye.tar(n_target).reward_prob          = 1;
        task.eye.tar(n_target).shape.mode           = 'convex';
        task.eye.tar(n_target).shape.convexity      = task.convexities{n_target};
        task.eye.tar(n_target).shape.convex_side    = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor            = [];
        task.hnd.tar(n_target).ringColor2           = [0 0 0];
        task.hnd.tar(n_target).reward_prob          = 1;
        task.hnd.tar(n_target).shape.mode           = 'convex';
        task.hnd.tar(n_target).shape.convexity      = task.convexities{n_target};
        task.hnd.tar(n_target).shape.convex_side    = convex_sides{n_target};
        
        task.eye.tar(n_target).x                    = task.tar_pos{n_target}(1);
        task.eye.tar(n_target).y                    = task.tar_pos{n_target}(2);
        task.hnd.tar(n_target).x                    = task.tar_pos{n_target}(1);
        task.hnd.tar(n_target).y                    = task.tar_pos{n_target}(2);
        
    end
end

if task.type==8
    task.n_targets                              =size(All_positions,1);
    
    for n_target=1:task.n_targets
        task.eye.tar(n_target).size                 = task.eye.tar(1).size;
        task.eye.tar(n_target).radius               = task.eye.tar(1).radius;
        task.hnd.tar(n_target).size                 = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius               = task.hnd.tar(1).radius;
        task.eye.tar(n_target).color_dim            = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright         = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor            = [];
        task.eye.tar(n_target).ringColor2           = [0 0 0];
        task.eye.tar(n_target).reward_prob          = 1;
        task.eye.tar(n_target).shape                = 'circle';
        %         task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
        %         task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor            = [];
        task.hnd.tar(n_target).ringColor2           = [0 0 0];
        task.hnd.tar(n_target).reward_prob          = 1;
        task.hnd.tar(n_target).shape                = 'circle';
        %         task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
        %         task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x                    = All_positions{n_target}(1);
        task.eye.tar(n_target).y                    = All_positions{n_target}(2);
        task.hnd.tar(n_target).x                    = All_positions{n_target}(1);
        task.hnd.tar(n_target).y                    = All_positions{n_target}(2);
        
    end
end

%% CUE assignment (Positions and colors !)
task.eye.cue                                        = task.eye.tar;
task.hnd.cue                                        = task.hnd.tar;

switch Current_con.cue_pos_con
    case 1
        task.cue_pos                                = {[-ex_cue,fix_height],[ex_cue,fix_height]};
    case 2
        task.cue_pos                                = {[ex_cue,fix_height],[-ex_cue,fix_height]};
end

if task.effector==0 || task.effector==1 || task.effector==2
    %         task.eye.cue(1).color_dim       = [80 50 50];
    %         task.eye.cue(1).color_bright    = [80 50 50];
    %         task.eye.cue(2).color_dim       = [80 50 50];
    %         task.eye.cue(2).color_bright    = [80 50 50];
    
    task.eye.cue(1).color_dim                       = [128 0 0];
    task.eye.cue(1).color_bright                    = [255 0 0];
    task.eye.cue(2).color_dim                       = [128 0 0];
    task.eye.cue(2).color_bright                    = [255 0 0];
end

if task.type==5 || task.type==6 % match to sample... cue positions and colors differ from targets
    
    task.eye.cue(1).x                               = task.cue_pos{1}(1);
    task.eye.cue(1).y                               = task.cue_pos{1}(2);
    task.eye.cue(2).x                               = task.cue_pos{2}(1);
    task.eye.cue(2).y                               = task.cue_pos{2}(2);
    
    task.hnd.cue(1).x                               = task.cue_pos{1}(1);
    task.hnd.cue(1).y                               = task.cue_pos{1}(2);
    task.hnd.cue(2).x                               = task.cue_pos{2}(1);
    task.hnd.cue(2).y                               = task.cue_pos{2}(2);
    
    task.eye.cue(1).color_dim                       = [128 50 50];
    task.eye.cue(1).color_bright                    = [128 50 50];
    task.eye.cue(2).color_dim                       = [128 50 50];
    task.eye.cue(2).color_bright                    = [128 50 50];
end

%% Inverting fixation and target
if Current_con.invert_con == 1
    temp_eye_fix_x                                  = task.eye.fix.x;
    temp_eye_fix_y                                  = task.eye.fix.y;
    temp_hnd_fix_x                                  = task.hnd.fix.x;
    temp_hnd_fix_y                                  = task.hnd.fix.y;
    
    task.eye.fix.x                                  = task.eye.tar(1).x;
    task.eye.fix.y                                  = task.eye.tar(1).y;
    task.hnd.fix.x                                  = task.hnd.tar(1).x;
    task.hnd.fix.y                                  = task.hnd.tar(1).y;
    
    task.eye.tar(1).x                               = temp_eye_fix_x;
    task.eye.tar(1).y                               = temp_eye_fix_y;
    task.hnd.tar(1).x                               = temp_hnd_fix_x;
    task.hnd.tar(1).y                               = temp_hnd_fix_y;
    
    task.eye.cue(1).x                               = temp_eye_fix_x;
    task.eye.cue(1).y                               = temp_eye_fix_y;
    
    task.hnd.cue(1).x                               = temp_hnd_fix_x;
    task.hnd.cue(1).y                               = temp_hnd_fix_y;
end




