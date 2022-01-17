% combined_condition_file_Linus_binoriv_fixation
% Initiate conditions, example file for a single experiment

global SETTINGS


if ~exist('dyn','var') || dyn.trialNumber == 1
    
    
    
    experiments        = {'fixation training for binoriv task'};
    
    
    si_counter=0; % only important for several experiments
    for n_exp = 1:numel(experiments)
        experiment=experiments{n_exp};
        shuffle_conditions                  = 2; % 0, 1, 2 ???
        force_conditions                    = 3; % normal task 3, and 1 to repeat if he does mistake
        task.calibration                    = 0;
        SETTINGS.GUI_in_acquisition         = 0;
        SETTINGS.check_motion_jaw           = 0;
        SETTINGS.check_motion_body          = 0;
        SETTINGS.RewardSound                = 1;
        
        
        task.reward.time_neutral            = [0.15 0.15]; % s 
        task.rest_hand                      = [0 0]; % which hands on the sensor to start the trial
        task.check_screen_touching          = 1;
        
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
            'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0,'offset_con',0,'invert_con',0,'exact_excentricity_con_x',NaN,'exact_excentricity_con_y',NaN,'reward_con',1,'reward_sound_con',1,'rest_hands_con',1,'var_x',0,'var_y',0);
        
        
        
        switch experiment
            
            case 'fixation training for binoriv task'
                SETTINGS.GUI_in_acquisition         = 1;
                
                N_repetitions                       = 50; % repetitions of unique! combination
                
                % All fields are used to construct unique combinations
                     
                All.fixation_locations              = [1:4];
                All.fixation_color                  = [1:2];
                
                % Set corresponding values for the above conditions
                % fixation point positions, in deg
                pool_of_x = [-2.5 -2.5 2.5 2.5];
                pool_of_y = [-2.5 2.5 -2.5 2.5];
                
                % fixation point color
                pool_of_color = [128 0 0; 0 0 175];
                
        end
        
        % don't change, for randomization, make it a script
        all_fieldnames=fieldnames(All);
        N_total_conditions       =1;
        sequence_cell            ={};
        for FN=1:numel(all_fieldnames)
            N_total_conditions=N_total_conditions*numel(All.(all_fieldnames{FN}));
            sequence_cell=[sequence_cell, {All.(all_fieldnames{FN})}];
        end
        
        sequence_matrix_exp_temp          = repmat(combvec(sequence_cell{:}),1,N_repetitions);
        
        sequence_matrix_exp{n_exp}          = sequence_matrix_exp_temp;
        ordered_sequence_indexes_exp{n_exp} = (1:N_total_conditions*N_repetitions) + si_counter;
        si_counter                          = numel(ordered_sequence_indexes_exp{n_exp}) +si_counter;
        
    end % for each experiment
    
    
    sequence_matrix          = [sequence_matrix_exp{:}];
    
    
    ordered_sequence_indexes = 1:(numel([ordered_sequence_indexes_exp{:}]));
end


%% Shuffling conditions, don't change, make it a script
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

% don't change, for randomization, make it a script
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
end

% This is for sending it to TDT
for field_index=1:numel(all_fieldnames)
    Current_con.(all_fieldnames{field_index})=sequence_matrix(field_index,custom_trial_condition);
    dyn.trial_classifier(field_index) = abs(round(Current_con.(all_fieldnames{field_index})));
end



%% CHOICE\INSTRUCTED
task.choice                 = 0;

%% TYPE
task.type                   = 1;

%% EFFECTOR
task.effector               = 0;

%% REACH hand
task.reach_hand             = 1;


%% TIMING

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
task.timing.fix_time_hold               = 1;
task.timing.fix_time_hold_var           = 2;
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



%% RADIUS & SIZES

task.eye.fix.size       = 0.25;
task.eye.fix.radius     = 5;
task.eye.tar(1).size    = 1;
task.eye.tar(1).radius  = 5;

task.hnd.fix.radius     = 8;
task.hnd.fix.size       = 6;
task.hnd.tar(1).size    = 4;
task.hnd.tar(1).radius  = 7;

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg


%% POSITIONS

% if SETTINGS.take_angles_con
%     current_angle=pool_of_angles(Current_con.angle_cases); %
%     tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
%     tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);
% else
%     tar_dis_x   = Current_con.exact_excentricity_con_x;
%     tar_dis_y   = Current_con.exact_excentricity_con_y;
% end

task.eye.fix.x = pool_of_x(Current_con.fixation_locations);
task.eye.fix.y = pool_of_y(Current_con.fixation_locations);

task.hnd.fix.x = pool_of_x(Current_con.fixation_locations);
task.hnd.fix.y = pool_of_y(Current_con.fixation_locations);


task.eye.tar(1).x = 0;
task.eye.tar(1).y = 0;
task.eye.tar(2).x = 0;
task.eye.tar(2).y = 0;

task.hnd.tar(1).x = 0;
task.hnd.tar(1).y = 0;
task.hnd.tar(2).x = 0;
task.hnd.tar(2).y = 0;

% task.eye.cue                                        = task.eye.tar;
% task.hnd.cue                                        = task.hnd.tar;


%% COLORS

%fixation
% task.eye.fix.color_dim          = [128 0 0]; %
% task.eye.fix.color_bright       = [128 0 0];

task.eye.fix.color_dim          = pool_of_color(Current_con.fixation_color,:); 
task.eye.fix.color_bright       = pool_of_color(Current_con.fixation_color,:); 

% task.hnd_left.color_dim_fix         = [39 109 216];%[39 109 216] %grey 60 60 60
% task.hnd_left.color_bright_fix      = [119 230 253];%[119 230 253] % grey 110 110 110
% task.hnd_right.color_dim_fix        = [0 128 0];
% task.hnd_right.color_bright_fix     = [0 255 0];%[0 255 0]


% task.eye.tar(1).color_dim       = [128 0 0];  % 2.5 or 3
% task.eye.tar(1).color_bright    = [255 0 0];
% task.eye.tar(2).color_dim       = [128 0 0]; %  % 2.5 or 3
% task.eye.tar(2).color_bright    = [255 0 0];
% 
% task.hnd_right.color_dim        = [0 128 0]; %[0 128 0]
% task.hnd_right.color_bright     = [0 255 0]; %[0 255 0]
% task.hnd_right.color_cue_dim    = [0 128 0];
% task.hnd_right.color_cue_bright = [0 255 0];
% task.hnd_left.color_dim         = [39 109 216]; % [39 109 216]
% task.hnd_left.color_bright      = [119 230 253]; % [119 230 253]
% task.hnd_left.color_cue_dim     = [39 109 216];
% task.hnd_left.color_cue_bright  = [119 230 253];
% task.hnd_stay.color_dim         = [39 109 216];
% task.hnd_stay.color_bright      = [119 230 253];




