% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


%Ordered_sequence = repmat([1,2,3,4],1,200);
%Ordered_sequence = repmat([3,4],1,200);

Ordered_sequence = repmat([0],1,100);
% Ordered_sequence = repmat([7,8],1,700);
%Ordered_sequence = repmat([1,2],1,700);
%Ordered_sequence = repmat([5,6],1,700);
%Ordered_sequence = repmat([5,6],1,700);

shuffle_conditions=1;
if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence = Ordered_sequence;
elseif dyn.trialNumber == 1 && shuffle_conditions==1
    sequence = shuffle(Ordered_sequence);
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if sum([trial.success])==length(sequence),
        return
        %dyn.state = STATE.CLOSE;
    else
        custom_trial_condition = sequence(sum([trial.success])+1);
    end
else
    custom_trial_condition = sequence(1);
end

% custom_trial_condition = sequence(numel(trial));

task.vd = 32; % cm
task.override = 0;
task.calibration = 0;
task.force_target_location = 1;
task.extra_reward = 0;


task.timing.wait_for_reward = 0.2;
task.timing.ITI_success = 1;
task.timing.ITI_success_var = 0.5;
task.timing.ITI_fail    = 1;
task.timing.ITI_fail_var = 0.5;
    
task.reward.time_small       = [0.03 0.03];
task.reward.time_neutral     = [0.31 0.31];
task.reward.time_large       = [0.03 0.03];
task.eye.fix.radius = 3;
task.eye.fix.size = 0.5; % deg
task.eye.tar(1).radius = 3;
task.eye.tar(2).radius = 3;
task.hnd.fix.radius = 3;
task.hnd.fix.size = 3;
task.hnd.tar(1).size = 3; % deg
task.hnd.tar(2).size = 3; % deg
task.hnd.tar(1).radius = 3; % deg
task.hnd.tar(2).radius = 3; % deg


task.eye.fix.color_dim = [128 0 0]; %
task.eye.fix.color_bright = [255 0 0];
task.eye.tar(1).color_dim = [128 0 0];  % 2.5 or 3
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim = [128 0 0]; %  % 2.5 or 3
task.eye.tar(2).color_bright = [255 0 0];


task.hnd_right.color_dim = [0 128 0]; %
task.hnd_right.color_bright = [0 255 0];
task.hnd_left.color_dim    = [39 109 216]; %
task.hnd_left.color_bright = [119 230 253];


switch custom_trial_condition
    case 0 % calibration
        %task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\Cornelius_cal.txt'; % NEW POSITIONS FOR CALIBRATION
        task.type = 2; % 1 fixation 2 - center out 2.5 training for memory 3 memory
        task.effector = 0;
        task.rest_hand = [0 0];
        task.rest_sensors_ini_time = 0; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.fix_time_hold = 0.5;
        task.reward.time_neutral     = [0.09 0.09];
        
        % Timing
        task.timing.grace_time_eye = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_hold = 1;
        task.timing.fix_time_hold_var = 0.5;
        task.timing.tar_time_to_acquire_eye = 0.5;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
        task.timing.wait_for_reward = 0.2;
        
        % Ttarget  size and color
        task.eye.fix.radius = 50;
        task.eye.tar(1).radius = 10;  % deg
        task.eye.tar(2).radius = 10; % deg
        
    case 1 % direct saccades
        task.type = 2;
        task.effector = 0;
        %task.rest_hand = [1 1];
        task.rest_hand = [0 0];
        task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.04 0.04];
        
        %Timing
        task.timing.grace_time_eye = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_hold = 1.2;
        task.timing.fix_time_hold_var = 0.8;
        task.timing.tar_time_to_acquire_eye = 0.5;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
        
        %target size and colors
        task.eye.fix.radius = 3;
        task.eye.tar(1).radius = 3;
        task.eye.tar(2).radius = 3;
        
    case 2 % memory saccades
        task.type = 3;
        task.effector = 0;
        %task.rest_hand = [1 1];
        
        task.rest_hand = [0 0];
        task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.06 0.06];
        
        % Timing
        task.timing.grace_time_eye = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.3;
        task.timing.cue_time_hold = 0.2;
        task.timing.cue_time_hold_var = 0;
        task.timing.mem_time_hold = 0.5; % 1.5 microstim
        task.timing.mem_time_hold_var = 0.5; % 0.5 microstim
        task.timing.tar_inv_time_to_acquire_eye = 0.4; %3
        task.timing.tar_inv_time_hold = 0.3;
        task.timing.tar_inv_time_hold_var = 0.2;
        task.timing.tar_time_to_acquire_eye = 0.5;
        task.timing.tar_time_hold = 0.2;
        task.timing.tar_time_hold_var = 0.3;
        
        %Target size and colors
        task.eye.tar(1).radius = 5;
        task.eye.tar(2).radius = 5;
        task.eye.fix.radius = 3;
        
        
    case 3 % direct reaches left hand
        
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.15 0.15];
        
        % Timing
        task.timing.grace_time_hand = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_to_acquire_hnd = 1.5;
        task.timing.fix_time_hold = 1.2;
        task.timing.fix_time_hold_var = 0.8;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
        
        %Target size and colors
        task.hnd.fix.radius = 2;
        task.hnd.fix.size = 2;
        task.hnd.tar(1).radius = 2; % deg
        task.hnd.tar(2).radius = 2; % deg
        task.hnd.tar(1).size = 2; % deg
        task.hnd.tar(2).size = 2; % deg
        
    case 4 % direct reaches right hand
        
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.rest_hand = [1 1];
        task.reach_hand = 2;
        task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.15 0.15];
        
        % Timing
        task.timing.grace_time_hand = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_to_acquire_hnd = 1.5;
        task.timing.fix_time_hold = 1.2;
        task.timing.fix_time_hold_var = 0.8;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
        
        %Target size and colors
        task.hnd.fix.radius = 2;
        task.hnd.fix.size = 2;
        task.hnd.tar(1).radius = 2; % deg
        task.hnd.tar(2).radius = 2; % deg
        task.hnd.tar(1).size = 2; % deg
        task.hnd.tar(2).size = 2; % deg
        
    case 5 % memory reaches left hand
        task.type = 3; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.rest_sensors_ini_time = 1; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.23 0.23];
        
        % Timing
        task.timing.grace_time_hand = 0;
        task.timing.fix_time_to_acquire_hnd = 1.5;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.3;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.cue_time_hold = 0.2;
        task.timing.cue_time_hold_var = 0;
        task.timing.mem_time_hold = 0.5;
        task.timing.mem_time_hold_var = 0.5;
        
        % to be modified back
        task.timing.tar_inv_time_hold = 0.3;
        task.timing.tar_inv_time_hold_var = 0.2;
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.2;
        task.timing.tar_time_hold_var = 0.3;
        
        % target size and colors
        task.hnd.fix.radius = 3;
        task.hnd.fix.size = 3;
        task.hnd.tar(1).radius = 4; % deg
        task.hnd.tar(2).radius = 4; % deg
        task.hnd.tar(1).size = 4; % deg
        task.hnd.tar(2).size = 4; % deg
        
    case 6 % memory reaches right hand
        task.type = 3; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 2;
        task.rest_hand = [1 1];
        task.rest_sensors_ini_time = 1; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.23 0.23];
        
        % Timing
        task.timing.grace_time_hand = 0;
        task.timing.fix_time_to_acquire_hnd = 1.5;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.3;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.cue_time_hold = 0.2;
        task.timing.cue_time_hold_var = 0;
        task.timing.mem_time_hold = 0.5;
        task.timing.mem_time_hold_var = 0.5;
        
        % to be modified back
        task.timing.tar_inv_time_hold = 0.3;
        task.timing.tar_inv_time_hold_var = 0.2;
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.2;
        task.timing.tar_time_hold_var = 0.3;
        
        % target size and colors
        task.hnd.fix.radius = 3;
        task.hnd.fix.size = 3;
        task.hnd.tar(1).radius = 4; % deg
        task.hnd.tar(2).radius = 4; % deg
        task.hnd.tar(1).size = 4; % deg
        task.hnd.tar(2).size = 4; % deg
        
    case 7 % dissociated direct reaches left
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.rest_sensors_ini_time = 1; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.24 0.24];
        
        % Timing
        task.timing.grace_time_hand = 0;
        task.timing.grace_time_eye = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_to_acquire_hnd = 1.5;
        
        %modify again....
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.5;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.tar_time_to_acquire_eye = 0.5;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
        
        % to be modified back
        task.timing.tar_inv_time_hold = 0.3;
        task.timing.tar_inv_time_hold_var = 0.2;
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.2;
        task.timing.tar_time_hold_var = 0.3;
        
        % target size and colors
        task.hnd.fix.radius = 3;
        task.hnd.fix.size = 3;
        task.hnd.tar(1).radius = 4; % deg
        task.hnd.tar(2).radius = 4; % deg
        task.hnd.tar(1).size = 4; % deg
        task.hnd.tar(2).size = 4; % deg
        
        task.eye.fix.radius = 4;
        task.eye.tar(1).radius = 4;  % deg
        task.eye.tar(2).radius = 4; % deg
        
    case 8 % dissociated direct reaches right
        
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 2;
        task.rest_hand = [1 1];
        task.rest_sensors_ini_time = 1; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.reward.time_neutral     = [0.24 0.24];
        
        % Timing
        task.timing.grace_time_hand = 0;
        task.timing.grace_time_eye = 0;
        task.timing.fix_time_to_acquire_eye = 0.5;
        task.timing.fix_time_to_acquire_hnd = 1.5;
        
        %modify again....
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.5;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.tar_time_to_acquire_eye = 0.5;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
        
        % to be modified back
        task.timing.tar_inv_time_hold = 0.3;
        task.timing.tar_inv_time_hold_var = 0.2;
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.2;
        task.timing.tar_time_hold_var = 0.3;
        
        % target size and colors
        task.hnd.fix.radius = 3;
        task.hnd.fix.size = 3;
        task.hnd.tar(1).radius = 4; % deg
        task.hnd.tar(2).radius = 4; % deg
        task.hnd.tar(1).size = 4; % deg
        task.hnd.tar(2).size = 4; % deg
        
        task.eye.fix.radius = 4;
        task.eye.tar(1).radius = 4;  % deg
        task.eye.tar(2).radius = 4; % deg
        
end


task.eye.cue = task.eye.tar;

% set params that differ between cue and tar
task.eye.cue(1).color_dim       = [80 50 50];
task.eye.cue(1).color_bright    = [80 50 50];
task.eye.cue(2).color_dim       = [80 50 50];
task.eye.cue(2).color_bright    = [80 50 50];

% set params that differ between cue and tar
task.hnd.cue(1).color_dim       = [50 50 50];
task.hnd.cue(1).color_bright    = [50 50 50];
task.hnd.cue(2).color_dim       = [50 50 50];
task.hnd.cue(2).color_bright    = [50 50 50];

switch task.reach_hand
    case 2 % right
        task.hnd.fix.color_dim  = task.hnd_right.color_dim;
        task.hnd.fix.color_bright  = task.hnd_right.color_bright;
        [task.hnd.tar.color_dim] = deal(task.hnd_right.color_dim);
        [task.hnd.tar.color_bright] = deal(task.hnd_right.color_bright);
        
    case 1 % left
        task.hnd.fix.color_dim  = task.hnd_left.color_dim;
        task.hnd.fix.color_bright  = task.hnd_left.color_bright;
        [task.hnd.tar.color_dim] = deal(task.hnd_left.color_dim);
        [task.hnd.tar.color_bright] = deal(task.hnd_left.color_bright);
end
