%% Initiate conditions
if ~exist('dyn','var') || dyn.trialNumber == 1
    shuffle_conditions=0;
    force_conditions=1;
    
    N_repetitions=20;
    task.reward.time_neutral    = [0.4 0.4]; 
    task.rest_hand              = [0 0]; % only relevant for saccades
    
    All_type_effector_con           = 0;
    All_timing_con                  = 0;
    All_size_con                    = 0;
    All_instructed_choice_con       = 1;
    All_tar_pos_con                 = 1:6;
    All_stim_con                    = 1;
    
    All_cue_pos_con     = 1;
    All_shape_con       = 1;
    
    N_total_conditions       = numel(All_type_effector_con)*numel(All_timing_con)*numel(All_size_con)*numel(All_instructed_choice_con)*numel(All_tar_pos_con)*numel(All_stim_con)*numel(All_cue_pos_con)*numel(All_shape_con);
    sequence_matrix          = repmat(combvec(All_type_effector_con,All_timing_con,All_size_con,All_instructed_choice_con,All_tar_pos_con,All_stim_con,All_cue_pos_con,All_shape_con),1,N_repetitions);
    ordered_sequence_indexes = 1:N_total_conditions*N_repetitions;
end



fix_eye_x             = 0;
fix_hnd_x             = 0;
fix_eye_y             = 20;
fix_hnd_y             = 17;
tar_excentricity      = 20;
tar_angle             = 20; %in degrees


%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (shuffle_conditions==1 || shuffle_conditions==2)
    sequence_indexes = Shuffle(ordered_sequence_indexes);    
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if force_conditions==1
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif force_conditions==2 
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


type_con    =sequence_matrix(1,custom_trial_condition);
timing_con  =sequence_matrix(2,custom_trial_condition);
size_con    =sequence_matrix(3,custom_trial_condition);
choice_con  =sequence_matrix(4,custom_trial_condition);
tar_pos_con =sequence_matrix(5,custom_trial_condition);
stim_con    =sequence_matrix(6,custom_trial_condition);
cue_pos_con =sequence_matrix(7,custom_trial_condition);
shape_con   =sequence_matrix(8,custom_trial_condition);

%% CHOICE\INSTRUCTED
switch choice_con
    case 1
        task.choice=0;
    case 2
        task.choice=1;
end

%% TYPE

% default presettings
task.calibration                    = 0;

switch type_con
    case 0 % calibration
        task.calibration            = 1;        
        task.type                   = 2;
        task.effector               = 0;       
        
    case 1 % fixation saccades       
        task.type                   = 1;
        task.effector               = 0;
        
    case 2 % fixation saccades
        task.type                   = 1;
        task.effector               = 1;
        
    case 3 % direct saccades
        task.type                   = 2;
        task.effector               = 0;   
        
    case 4 % memory saccades
        task.type                   = 3;
        task.effector               = 0;   
        
    case 5 % direct reaches left hand
        task.type                   = 2; 
        task.effector               = 1;    
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 6 % direct reaches right hand
        task.type                   = 2; 
        task.effector               = 1; 
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 7 % memory reaches left hand
        task.type                   = 3; 
        task.effector               = 1;     
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 8 % memory reaches right hand
        task.type                   = 3; 
        task.effector               = 1;    
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 9 % dissociated direct reaches left
        task.type                   = 2; 
        task.effector               = 4;     
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 10 % dissociated direct reaches right
        task.type                   = 2; 
        task.effector               = 4;     
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 11 % dissociated memory reaches left
        task.type                   = 3; 
        task.effector               = 4;   
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 12 % dissociated memory reaches right
        task.type                   = 3; 
        task.effector               = 4;     
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 13 % dissociated memory reaches left learning task
        task.type                   = 2.5; 
        task.effector               = 4;   
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 14 % dissociated memory reaches right learning task
        task.type                   = 2.5; 
        task.effector               = 4;   
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
                     
    case 15 % dissociated direct saccades left
        task.type                   = 2; 
        task.effector               = 3;   
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 16 % dissociated direct saccades right
        task.type                   = 2; 
        task.effector               = 3;   
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 17 % dissociated memory saccades left
        task.type                   = 3; 
        task.effector               = 3;    
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 18 % dissociated memory saccades right
        task.type                   = 3; 
        task.effector               = 3; 
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 19 % dissociated memory saccades left learning task
        task.type                   = 2.5; 
        task.effector               = 3;     
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 20 % dissociated memory saccades right learning task
        task.type                   = 2.5; 
        task.effector               = 3;     
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
        
    case 21 % direct reach with fixation spot left hand
        task.type                   = 2; 
        task.effector               = 6;     
        task.reach_hand             = 1;
        task.rest_hand              = [1 1];
        
    case 22 % direct reach with fixation spot right hand
        task.type                   = 2; 
        task.effector               = 6;     
        task.reach_hand             = 2;
        task.rest_hand              = [1 1];
end

%% STIMULATION timing
switch stim_con
    case 1
        task.microstim.stim_on      = 0;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0] ;
        task.microstim.end{1}       = [0];
    case 2
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.12] ;
        task.microstim.end{1}       = [-0];
    case 3
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.08] ;
        task.microstim.end{1}       = [-0];
    case 4
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.04] ;
        task.microstim.end{1}       = [-0];
    case 5
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0] ;
        task.microstim.end{1}       = [0.2];
    case 6
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.04] ;
        task.microstim.end{1}       = [0.24];
    case 7
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
    case 8
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.12] ;
        task.microstim.end{1}       = [0.32];
    case 9
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.24] ;
        task.microstim.end{1}       = [0.44];
end

%% TIMING

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

task.timing.fix_time_hold               = 0.2;
task.timing.fix_time_hold_var           = 0.2;
task.timing.cue_time_hold               = 0.5;
task.timing.cue_time_hold_var           = 0;
task.timing.mem_time_hold               = 0; 
task.timing.mem_time_hold_var           = 0;
task.timing.del_time_hold               = 0;
task.timing.del_time_hold_var           = 0; 
task.timing.tar_inv_time_hold           = 0;
task.timing.tar_inv_time_hold_var       = 0;
task.timing.tar_time_hold               = 0.7;
task.timing.tar_time_hold_var           = 0.0;

switch timing_con
    case 0 % 'calibration'
        task.timing.fix_time_hold           = 0.8;
        task.timing.fix_time_hold_var       = 0.2;
        task.timing.tar_time_hold           = 1;
        task.timing.tar_time_hold_var       = 0.5;
    case 1 %'fixation'
        task.timing.fix_time_hold           = 1;
        task.timing.fix_time_hold_var       = 0;
        task.timing.ITI_success             = 0.3;
        task.timing.ITI_success_var         = 0;
        task.timing.ITI_fail                = 3;
        task.timing.ITI_fail_var            = 0;
    case 2 %'direct'
        task.timing.fix_time_hold           = 0.4;
        task.timing.fix_time_hold_var       = 0.3;
        task.timing.tar_time_hold           = 0.5;
        task.timing.tar_time_hold_var       = 0;
    case 3 %'memory'            
        task.timing.fix_time_hold           = 0.5;
        task.timing.fix_time_hold_var       = 0.3;
        task.timing.cue_time_hold           = 0.2;
        task.timing.cue_time_hold_var       = 0;
        task.timing.mem_time_hold           = 0.5; % 1.5 microstim
        task.timing.mem_time_hold_var       = 0.5; % 0.5 microstim
        task.timing.del_time_hold           = 0.5; % 1.5 microstim
        task.timing.del_time_hold_var       = 0.5; % 0.5 microstim
        task.timing.tar_inv_time_hold       = 0.3;
        task.timing.tar_inv_time_hold_var   = 0.2;
        task.timing.tar_time_hold           = 0.2;
        task.timing.tar_time_hold_var       = 0.3;
end

%% RADIUS & SIZES


switch size_con
    case 0 %'calibration'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 20;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 3;
        task.hnd.tar(1).radius  = 3;
    case 1 %'fixation'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 3; 
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 3;  
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 3;
        task.hnd.tar(1).radius  = 3;
    case 2 %'direct'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 0.5;        
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 3;
        task.hnd.tar(1).radius  = 3;
    case 3 %'memory'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 4;        
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 5;
        task.hnd.tar(1).size    = 5;
        task.hnd.tar(1).radius  = 5;
end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

%% POSITIONS
tar_dis_x_high_low  = tar_excentricity*cos(tar_angle*2*pi/360); 
tar_dis_y_high_low  = tar_excentricity*sin(tar_angle*2*pi/360); 
switch tar_pos_con % So far, 6 target positions, to be extended...
    case  1 % Horizontal right
        tar_dis_1x = + tar_excentricity;
        tar_dis_1y = + 0;
        tar_dis_2x = - tar_excentricity;
        tar_dis_2y = + 0;
        
    case 2 % Horizontal left
        tar_dis_1x = - tar_excentricity;
        tar_dis_1y = + 0;
        tar_dis_2x = + tar_excentricity;
        tar_dis_2y = + 0;
        
    case 3 % Upper right
        tar_dis_1x = + tar_dis_x_high_low;
        tar_dis_1y = + tar_dis_y_high_low;
        tar_dis_2x = - tar_dis_x_high_low;
        tar_dis_2y = + tar_dis_y_high_low;      
        
    case 4 % Upper left
        tar_dis_1x = - tar_dis_x_high_low;
        tar_dis_1y = + tar_dis_y_high_low;
        tar_dis_2x = + tar_dis_x_high_low;
        tar_dis_2y = + tar_dis_y_high_low; 
        
    case 5 % Lower right
        tar_dis_1x = + tar_dis_x_high_low;
        tar_dis_1y = - tar_dis_y_high_low;
        tar_dis_2x = - tar_dis_x_high_low;
        tar_dis_2y = - tar_dis_y_high_low; 
        
    case 6 % Lower left
        tar_dis_1x = - tar_dis_x_high_low;
        tar_dis_1y = - tar_dis_y_high_low;
        tar_dis_2x = + tar_dis_x_high_low;
        tar_dis_2y = - tar_dis_y_high_low; 
        
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

%% CUE assignment (Positions and colors !)
task.eye.cue=task.eye.tar;
task.hnd.cue=task.hnd.tar;

if task.effector==0 || task.effector==1 || task.effector==2
    task.eye.cue(1).color_dim       = [80 50 50];
    task.eye.cue(1).color_bright    = [80 50 50];
    task.eye.cue(2).color_dim       = [80 50 50];
    task.eye.cue(2).color_bright    = [80 50 50];
end

