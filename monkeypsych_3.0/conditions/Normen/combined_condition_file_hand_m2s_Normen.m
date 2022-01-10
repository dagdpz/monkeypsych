%% Initiate conditions
global SETTINGS
    SETTINGS.GUI_in_acquisition = 0;
    
    if ~exist('dyn','var') || dyn.trialNumber == 1
        % experiment        = {'calibration'};
        %experiment        = {'StartingPosition_Hand'};
        experiment        = 'Target_perip';
        
        PEST_ON                         = 0;
        task.rest_hand              = [0 0]; % only relevant for saccades
        
        All = struct(...
            'angle_cases',0, 'instructed_choice_con',0, 'type_con',0, 'effector_con',0, 'reach_hand_con',0, 'excentricities',0, 'stim_con',0, 'timing_con',0, 'size_con',0,...
            'shape_con',0, 'offset_con',0, 'exact_excentricity_con_x',NaN, 'exact_excentricity_con_y',NaN, 'colors_con',0, 'targets_con',0, 'reward_time',0, 'correct_choice_target', 0);
       
        switch experiment
            
            case 'calibration'
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.take_angles_con            = 1;
                task.shuffle_conditions          = 1;

                task.force_conditions                    = 1;
                N_repetitions                       = 200;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                pool_of_angles                      = [0]; %[20,0,340,200,180,160]; % angeles to present the target
                
                All.time_neutral                    = [0.06 ]; % 0.08 % Reward
                task.rest_hand                      = [0 0 ]; % left, right
                task.randomize_reach_hand           = 1;
                
                All.offset_con                      = 0;
                All.reach_hand_con                  = 1; %1
                All.effector_con                    = 0; %0
                All.type_con                        = 1; %1
                
                All.timing_con                      = 0;
                All.size_con                        = 31; % 0 = calibration
                All.instructed_choice_con           = [0 1];
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [15 ];
                    All.angle_cases                 = [1];
                end
                All.stim_con                        = 0;
                if PEST_ON==1
                    All.stim_con                    = 0;
                    PEST_hnd_or_eye                 = 'eye';
                    PEST_effector                   = 1;
                end
                
                
            case 'StartingPosition_Hand'
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.take_angles_con            = 1;
                
                task.force_conditions               = 1;
                N_repetitions                       = 200;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0; % position on the moitor
                pool_of_angles                      = [0, 180]; %[20,0,340,200,180,160]; % angeles to present the target
                
                All.time_neutral                    = [0.06 ]; % 0.08 % Reward
                task.rest_hand                      = [1 1 ]; % left, right
                task.randomize_reach_hand           = 1;
                
                All.offset_con                      = 0; %
                All.reach_hand_con                  = 1; %1
                All.effector_con                    = 1; %1 = Hand only
                All.type_con                        = 1; %1
                
                All.timing_con                      = 1; % fixation = 1
                All.size_con                        = 1; %%% RADIUS & SIZES ... fixation = 1
                All.instructed_choice_con           = [0 1];
                
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [15 ];
                    All.angle_cases                 = [1,2];
                end
                All.stim_con                        = 0;
                if PEST_ON==1
                    All.stim_con                    = 0;
                    PEST_hnd_or_eye                 = 'eye';
                    PEST_effector                   = 1;
                end
                
            case 'Target_perip'
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.take_angles_con            = 1;
                task.shuffle_conditions             = 1; %add afterwards

                task.force_conditions               = 0;
                N_repetitions                       = 1; % ???for each Condition??? 
            
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                fix_offset                          = 0; %add afterwards
               
                task.reward.time_neutral            = [0.13 0.13]; %Reward
                
                All.reach_hand_con                  = 2; % [1 2] both hands
                All.type_con                        = 2; % 2 = direct to the target
                All.effector_con                    = 1; % 1 handy only (no fixation point), 6 = free gaze hand(fixation point on the target) 
                task.rest_hand                      = [0 0]; %% [1 1]  only relevant for saccades
                All.offset_con                      = 0; %delay = 4
                All.targets_con                     = 1; % 0 - two targets, 1 - three targets

                pool_of_angles                      = [0,180]; % [0,180]

                All.timing_con                      = 8; %case is on the bottom of the function
                All.size_con                        = 2; %case is on the bottom of the function
                All.instructed_choice_con           = [1]; % [0] only inst, [1] only choice, [0 1] inst and choice 50%, [0 0 1] 64% inst 33% choice
                All.correct_choice_target           = 2; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct 
                All.colors_con                      = [1]; %[2 9:12];
                
                All.tar_dis_con                     = [12,13];     % target distribution add afterwards   
                All.shape_con                       = 1 ;%[10,11];%10;%9:12;%[5:8];%[1:4];%[9:12];%  %add afterwards
                All.mat_dis_con                     = 1;  %add afterwards       
                All.cue_pos_con                     = 1;  %add afterwards   
                multiple_targets_per_trial          = 0; %add afterwards
                ex_cue                              = 5;%7;%15;  %cue_excentricity %add afterwards 
                f_h                                 = fix_eye_y;
                fix_height                          = f_h;
                d_pos                               = 8;    %relative shift of target positions
                if ~SETTINGS.take_angles_con
                    All.exact_excentricity_con_x    = [-15 0 15];
                    All.exact_excentricity_con_y    = [-10 0 10];
                else
                    All.excentricities              = [13]; %[13]
                    All.angle_cases                 = [1];
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
        sequence_matrix          = repmat(CombVec(sequence_cell{:}),1,N_repetitions); % ACHTUNG: combvec
        ordered_sequence_indexes = 1:N_total_conditions*N_repetitions;
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
    fix_eye_x             = fix_offset;
end
fix_hnd_x             = fix_eye_x;

%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && task.shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (task.shuffle_conditions==1 || task.shuffle_conditions==2)
    sequence_indexes = Shuffle(ordered_sequence_indexes);    
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if task.force_conditions==1
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif task.force_conditions==2 
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
    elseif task.force_conditions==3 
        if trial(end-1).completed==1
            sequence_indexes=sequence_indexes(2:end);
        else
             sequence_indexes=Shuffle(sequence_indexes);
        end
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
end

%dyn.trial_classifier(1)=numel(All.tar_pos_con);
for field_index=1:numel(all_fieldnames)
    Current_con.(all_fieldnames{field_index})=sequence_matrix(field_index,custom_trial_condition);
    %dyn.trial_classifier(field_index+1) = Current_con.(all_fieldnames{field_index});
    dyn.trial_classifier(field_index) = abs(round(Current_con.(all_fieldnames{field_index})));
end


%% CHOICE\INSTRUCTED
task.choice                 = Current_con.instructed_choice_con;

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con; 

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con;

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;


%% STIMULATION timing
switch Current_con.stim_con
    case 0
        task.microstim.stim_on      = 0;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0] ;
        task.microstim.end{1}       = [0];
    case 1
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.12] ;
        task.microstim.end{1}       = [-0];
    case 2
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.08] ;
        task.microstim.end{1}       = [-0];
    case 3
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.04] ;
        task.microstim.end{1}       = [-0];
    case 4
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0] ;
        task.microstim.end{1}       = [0.2];
    case 5
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.04] ;
        task.microstim.end{1}       = [0.24];
    case 6
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
    case 7
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.12] ;
        task.microstim.end{1}       = [0.32];
    case 8
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.24] ;
        task.microstim.end{1}       = [0.44];
    case 9
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.CUE_ON];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
    case 10
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.MEM_PER];
        task.microstim.start{1}     = [-0.08] ;
        task.microstim.end{1}       = [0];
    case 11
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ_INV];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
end
%% TIMING

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
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
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
        
    case 1 %'fixation'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.8;
        task.timing.fix_time_hold_var           = 0;
        task.timing.cue_time_hold               = 0.3;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 1.5;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 1.5;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.2;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
        
    case 2 %'direct'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 3;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 2;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.5;
        task.timing.fix_time_hold_var           = 0.0;
        task.timing.cue_time_hold               = 0.28;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 3 %'memory stim'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.4;
        task.timing.fix_time_hold_var           = 0.3;
        task.timing.cue_time_hold               = 0.28;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0.2;
        task.timing.mem_time_hold_var           = 0.2;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.1;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 31 %'memory ephys'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 2.5;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 2;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.5;
        task.timing.fix_time_hold_var           = 0.0;
        task.timing.cue_time_hold               = 0.28;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 32 %'memory learning'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.3;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.2;
        task.timing.cue_time_hold_var           = 0.08;
        task.timing.mem_time_hold               = 0.5;
        task.timing.mem_time_hold_var           = 0.5;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 5 %'Match to sample'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts        
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 2;        
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;        
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 4;
        task.timing.tar_inv_time_to_acquire_hnd = 4;        
        task.timing.fix_time_to_acquire_eye     = 1;
        task.timing.tar_time_to_acquire_eye     = 10;
        task.timing.tar_inv_time_to_acquire_eye = 4; %3        
        task.timing.fix_time_hold               = 0.2;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.6;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0; %% 0.2
        task.timing.mem_time_hold_var           = 0; %% 0.3
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.6;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 8 %'Specific for nomen'
        
        
task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts

task.timing.wait_for_reward             = 0.2;
task.timing.ITI_success                 = 0.2;
task.timing.ITI_success_var             = 0;
task.timing.ITI_fail                    = 1; %TIME OUT
task.timing.ITI_fail_var                = 0;

task.timing.grace_time_eye              = 0.0;
task.timing.grace_time_hand             = 0.0;

task.timing.fix_time_to_acquire_hnd     = 1;
task.timing.tar_time_to_acquire_hnd     = 1.5;
task.timing.tar_inv_time_to_acquire_hnd = 2;

task.timing.fix_time_to_acquire_eye     = 0.5;
task.timing.tar_time_to_acquire_eye     = 0.5;
task.timing.tar_inv_time_to_acquire_eye = 0.5; %3

task.timing.fix_time_hold               = 0.1;%???
task.timing.fix_time_hold_var           = 0;
task.timing.cue_time_hold               = 0.5;
task.timing.cue_time_hold_var           = 0;
task.timing.mem_time_hold               = 0;  %target disappeared until Go
task.timing.mem_time_hold_var           = 0;
task.timing.del_time_hold               = 0; % delay
task.timing.del_time_hold_var           = 0; 
task.timing.tar_inv_time_hold           = 0;% target is invisiable
task.timing.tar_inv_time_hold_var       = 0;
task.timing.tar_time_hold               = 0.1;
task.timing.tar_time_hold_var           = 0.0;
        
        
end




%% RADIUS & SIZES

if task.type==5 || task.type==6 
task.eye=rmfield(task.eye,'tar');
task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    case 0 %'calibration'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 100;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
    case 1 %'fixation'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5; 
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;  
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
    case 2 %'direct'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 0.5;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 0.5;
        task.hnd.tar(1).radius  = 4;
    case 3 %'memory'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 5;
        task.hnd.tar(1).size    = 5;
        task.hnd.tar(1).radius  = 5;
        
    case 32 %'memory learning'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 3;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 4;        
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 5;
        task.hnd.tar(1).size    = 5;
        task.hnd.tar(1).radius  = 5;
        
    case 5 %'match to sample'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 2;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 2;
        task.hnd.tar(1).radius  = 4;
        
    case 8 %'RF mapping'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 1;
        task.eye.tar(1).radius  = 1;        
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 1;
        task.hnd.tar(1).radius  = 1;
end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

%% POSITIONS
    current_angle=pool_of_angles(Current_con.angle_cases); %
    tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
    tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);
    
    tar_dis_1x = + tar_dis_x;
    tar_dis_1y = + tar_dis_y;
    tar_dis_2x = - tar_dis_x;
    tar_dis_2y = + tar_dis_y;
        
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
        
elseif     multiple_targets_per_trial == 3; % 18 positions for match to sample saccades(!)
        ex_LR = Current_con.excentricities;
        All_positions_right= Shuffle({ [ex_LR,f_h],[ex_LR,f_h]});
        All_positions_left = Shuffle({[-ex_LR,f_h],[-ex_LR,f_h]});
        tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;       
        
elseif     multiple_targets_per_trial == 4; % 18 positions for match to sample saccades(!)
        ex_LR = Current_con.excentricities;
        All_positions_right= Shuffle({ [ex_LR,f_h+5],[ex_LR,f_h-5]});
        All_positions_left = Shuffle({[-ex_LR,f_h+5],[-ex_LR,f_h-5]});
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
task.eye.fix.color_dim       = [128 0 0]; %
task.eye.fix.color_bright    = [255 0 0];
task.eye.tar(1).color_dim    = [128 0 0];  % 2.5 or 3
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim    = [128 0 0]; %  % 2.5 or 3
task.eye.tar(2).color_bright = [255 0 0];

task.hnd_right.color_dim    = [0 128 0]; %
task.hnd_right.color_bright = [0 255 0];
task.hnd_right.color_cue    = [50 80 50];
task.hnd_left.color_dim     = [39 109 216]; %
task.hnd_left.color_bright  = [119 230 253];
task.hnd_left.color_cue     = [64 77 80];
task.hnd_stay.color_dim     = [128 129 0];
task.hnd_stay.color_bright  = [255 255 0];

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
%all_curv=[0.6,0.3,-0.4,-0.6];
all_curv=[-0.9,-0.9,-0.9,-0.2];
convex_sides=repmat({'LR'},1,task.n_targets);
all_sides={'LR','L','R','LR'};
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
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(3),repmat(all_curv(4),1,task.n_targets-3)]);
        convex_sides=[all_sides(1),all_sides(2),all_sides(3),repmat(all_sides(4),1,task.n_targets-3)];
    case 6
        task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(4),repmat(all_curv(3),1,task.n_targets-3)]);
        convex_sides=[all_sides(2),all_sides(1),all_sides(4),repmat(all_sides(3),1,task.n_targets-3)];
    case 7 % fro cornz learning
        task.convexities=num2cell([all_curv(3),all_curv(4),all_curv(1),repmat(all_curv(2),1,task.n_targets-3)]);
        convex_sides=[all_sides(3),all_sides(4),all_sides(1),repmat(all_sides(2),1,task.n_targets-3)];
    case 8
        task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(2),repmat(all_curv(1),1,task.n_targets-3)]);
        convex_sides=[all_sides(4),all_sides(3),all_sides(2),repmat(all_sides(1),1,task.n_targets-3)];
        
    case 9 % fro cornz learning
        task.convexities=num2cell([all_curv(1),all_curv(4),all_curv(3),repmat(all_curv(1),1,task.n_targets-3)]);
        convex_sides=[all_sides(1),all_sides(4),all_sides(3),repmat(all_sides(2),1,task.n_targets-3)];
    case 10
        task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(4),repmat(all_curv(1),1,task.n_targets-3)]);
        convex_sides=[all_sides(2),all_sides(3),all_sides(4),repmat(all_sides(1),1,task.n_targets-3)];
    case 11 % fro cornz learning
        task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(1),repmat(all_curv(4),1,task.n_targets-3)]);
        convex_sides=[all_sides(3),all_sides(2),all_sides(1),repmat(all_sides(4),1,task.n_targets-3)];
    case 12
        task.convexities=num2cell([all_curv(4),all_curv(1),all_curv(2),repmat(all_curv(3),1,task.n_targets-3)]);
        convex_sides=[all_sides(4),all_sides(1),all_sides(2),repmat(all_sides(3),1,task.n_targets-3)];
%     case 5 % fro cornz learning
%         task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
%     case 6
%         task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
%     case 7 % fro cornz learning
%         task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(3),all_curv(3),all_curv(randi([3,4],[1,task.n_targets-4]))]);
%     case 8
%         task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(2),all_curv(2),all_curv(randi([1,2],[1,task.n_targets-4]))]);
%     case 9 % fro cornz learning
%         task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(1),all_curv(4)]);
%     case 10
%         task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(4),all_curv(1)]);
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
    n_left=1;
    n_right=1;
    if match_left
        task.tar_pos{1}=All_positions_left{n_left};
        n_left=n_left+1;
    else
        task.tar_pos{1}=All_positions_right{n_right};
        n_right=n_right+1;
    end
    if distractor_left
        task.tar_pos{2}=All_positions_left{n_left};
        n_left=n_left+1;
    else
        task.tar_pos{2}=All_positions_right{n_right};
        n_right=n_right+1;
    end
    for n_target=3:task.n_targets
        if n_target+match_left+distractor_left-2<=N_targets_left
            task.tar_pos{n_target}=All_positions_left{n_left};
        n_left=n_left+1;
        else
            task.tar_pos{n_target}=All_positions_right{n_right};
        n_right=n_right+1;
        end
    end
   
    
    for n_target=1:task.n_targets
        task.eye.tar(n_target).size         = task.eye.tar(1).size;
        task.eye.tar(n_target).radius       = task.eye.tar(1).radius;
        task.hnd.tar(n_target).size         = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius       = task.hnd.tar(1).radius;
        task.eye.tar(n_target).color_dim    = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor = [];
        task.eye.tar(n_target).ringColor2 = [0 0 0];
        task.eye.tar(n_target).reward_prob = 1;
        task.eye.tar(n_target).shape.mode = 'convex';
        task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
        task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor = [];
        task.hnd.tar(n_target).ringColor2 = [0 0 0];
        task.hnd.tar(n_target).reward_prob = 1;
        task.hnd.tar(n_target).shape.mode = 'convex';
        task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
        task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x = task.tar_pos{n_target}(1);
        task.eye.tar(n_target).y = task.tar_pos{n_target}(2);
        task.hnd.tar(n_target).x = task.tar_pos{n_target}(1);
        task.hnd.tar(n_target).y = task.tar_pos{n_target}(2);
        
    end    
end

if task.type==8 
    task.n_targets=size(All_positions,1);
    
    for n_target=1:task.n_targets
        task.eye.tar(n_target).size         = task.eye.tar(1).size;
        task.eye.tar(n_target).radius       = task.eye.tar(1).radius;
        task.hnd.tar(n_target).size         = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius       = task.hnd.tar(1).radius;
        task.eye.tar(n_target).color_dim    = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor = [];
        task.eye.tar(n_target).ringColor2 = [0 0 0];
        task.eye.tar(n_target).reward_prob = 1;
         task.eye.tar(n_target).shape = 'circle';
        %         task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
        %         task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor = [];
        task.hnd.tar(n_target).ringColor2 = [0 0 0];
        task.hnd.tar(n_target).reward_prob = 1;
        task.hnd.tar(n_target).shape = 'circle';
        %         task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
        %         task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x = All_positions{n_target}(1);
        task.eye.tar(n_target).y = All_positions{n_target}(2);
        task.hnd.tar(n_target).x = All_positions{n_target}(1);
        task.hnd.tar(n_target).y = All_positions{n_target}(2);
        
    end
end

%% CUE assignment (Positions and colors !)
task.eye.cue=task.eye.tar;
task.hnd.cue=task.hnd.tar;

switch Current_con.cue_pos_con
    case 1
        task.cue_pos  = {[-ex_cue,fix_height],[ex_cue,fix_height]}; 
    case 2
        task.cue_pos  = {[ex_cue,fix_height],[-ex_cue,fix_height]};
end

if task.effector==0 || task.effector==1 || task.effector==2
    task.eye.cue(1).color_dim       = [80 50 50];
    task.eye.cue(1).color_bright    = [80 50 50];
    task.eye.cue(2).color_dim       = [80 50 50];
    task.eye.cue(2).color_bright    = [80 50 50];
%         task.eye.cue(1).color_dim       = [128 0 0];
%         task.eye.cue(1).color_bright    = [128 0 0];
%         task.eye.cue(2).color_dim       = [128 0 0];
%         task.eye.cue(2).color_bright    = [128 0 0];
    
end

if task.type==5 || task.type==6 % match to sample... cue positions and colors differ from targets
    
    task.eye.cue(1).x    = task.cue_pos{1}(1);
    task.eye.cue(1).y    = task.cue_pos{1}(2);
    task.eye.cue(2).x    = task.cue_pos{2}(1);
    task.eye.cue(2).y    = task.cue_pos{2}(2);
    
    task.hnd.cue(1).x    = task.cue_pos{1}(1);
    task.hnd.cue(1).y    = task.cue_pos{1}(2);
    task.hnd.cue(2).x    = task.cue_pos{2}(1);
    task.hnd.cue(2).y    = task.cue_pos{2}(2);
    
%     task.eye.cue(1).color_dim       = [128 50 50];
%     task.eye.cue(1).color_bright    = [128 50 50];
%     task.eye.cue(2).color_dim       = [128 50 50];
%     task.eye.cue(2).color_bright    = [128 50 50];   
    
    task.eye.cue(1).color_dim       = [128 0 0];
    task.eye.cue(1).color_bright    = [128 0 0];
    task.eye.cue(2).color_dim       = [128 0 0];
    task.eye.cue(2).color_bright    = [128 0 0];      
end


