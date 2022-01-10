% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


%Ordered_sequence = repmat([1,2,3,4],1,200);
%Ordered_sequence = repmat([3,4],1,200);

Ordered_sequence = repmat([0],1,1000);
%Ordered_sequence = repmat([0],1,1000);
%Ordered_sequence = repmat([2],1,700);
%Ordered_sequence = repmat([-1],1,300);
%Ordered_sequence = repmat([9,10],1,700);
%Ordered_sequence = repmat([11,12],1,700);

%Ordered_sequence = repmat([9,10],1,700);
%Ordered_sequence = repmat([7,8,9,10],1,700);
%Ordered_sequence = repmat([1,2],1,700);
%Ordered_sequence = repmat([1],1,700);
%Ordered_sequence = repmat([5,6],1,100);


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

% General settings
task.vd = 32; % cm
%task.override = 0;
task.calibration = 0;
task.force_target_location = 0;
task.extra_reward = 0;


% Reward
task.reward.time_small       = [0.03 0.03];
%task.reward.time_neutral     = [0.5 0.5];
task.reward.time_large       = [0.03 0.03];

% Timing

task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts

task.timing.wait_for_reward = 0.2;
task.timing.ITI_success = 1.5;
task.timing.ITI_success_var = 0;
task.timing.ITI_fail    = 3;
task.timing.ITI_fail_var = 0;

task.timing.grace_time_eye = 0;
task.timing.grace_time_hand = 0;
task.timing.fix_time_to_acquire_hnd = 1.5;
task.timing.tar_time_to_acquire_hnd = 1;
task.timing.tar_inv_time_to_acquire_hnd = 1;
task.timing.fix_time_to_acquire_eye = 0.5;
task.timing.tar_inv_time_to_acquire_eye = 0.4; %3
task.timing.tar_time_to_acquire_eye = 0.5;

%Sizes
eyefixationradius = 3;
eyetargetradius   = 3;
hndfixationradius = 3;
hndtargetradius   = 3;
task.eye.fix.size = 0.5; % deg
task.eye.tar(1).size = 0.5; % deg
task.eye.tar(2).size = 0.5; % deg

% Colors
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
    case -2 % eye calibration training...
        %task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\Cornelius_cal.txt'; % NEW POSITIONS FOR CALIBRATION
        task.type = 4; % 1 fixation 2 - center out 2.5 training for memory 3 memory
        task.effector = 0;
        task.rest_hand = [0 0];
        task.reward.time_neutral     = [0.4 0.4];
        task.reward_modulation=1;
        task.choice=1;
        
        current_timing_option='memory';
        eyefixationradius = 5;
        eyetargetradius   = 2;
    case -1 % eye calibration training...
        %task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\Cornelius_cal.txt'; % NEW POSITIONS FOR CALIBRATION
        task.type = 2; % 1 fixation 2 - center out 2.5 training for memory 3 memory
        task.effector = 0;
        task.rest_hand = [0 0];
        task.reward.time_neutral     = [0.4 0.4];
        
        current_timing_option='calibration';
        eyefixationradius = 5;
        eyetargetradius   = 2;
        
    case 0 % calibration
        %task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\Cornelius_cal.txt'; % NEW POSITIONS FOR CALIBRATION\
        task.calibration = 1;
        
        task.type = 2; % 1 fixation 2 - center out 2.5 training for memory 3 memory
        task.effector = 0;
        task.rest_hand = [0 0];
        task.reward.time_neutral     = [0.4 0.4];
        
        current_timing_option='calibration';
        eyefixationradius = 5000;
        eyetargetradius   = 5;
        task.calibration = 1;
        task.n_targets=1;
        task.position_set=randi(4);
        eye_fix_y=18;
        
        switch task.position_set
            case 1
                current_set={[-20,eye_fix_y]};
            case 2
                current_set={[20,eye_fix_y]};
            case 3
                current_set={[0,eye_fix_y-7]};
            case 4
                current_set={[0,eye_fix_y+7]};
        end
        
        task.hnd_positions=current_set;
        task.eye_positions=current_set;
        
        temp_pos_hnd=randsample(task.hnd_positions,task.n_targets);
        temp_pos_eye=randsample(task.eye_positions,task.n_targets);
    
    for n_target=1:task.n_targets
        task.eye.tar(n_target).x = temp_pos_eye{n_target}(1);
        task.eye.tar(n_target).y = temp_pos_eye{n_target}(2);
        task.hnd.tar(n_target).x = temp_pos_hnd{n_target}(1);
        task.hnd.tar(n_target).y = temp_pos_hnd{n_target}(2);     
        
    end
        
    case 1 % direct saccades
        task.type = 2;
        task.effector = 0;
        %task.rest_hand = [1 1];
        task.rest_hand = [0 0];
        task.reward.time_neutral     = [0.5 0.5];
        
        current_timing_option='direct';
        eyefixationradius = 4;
        eyetargetradius   = 4;
        
    case 2 % memory saccades
        task.type = 3;
        task.effector = 0;
        %task.rest_hand = [1 1];
        task.rest_hand = [0 0];
        task.reward.time_neutral     = [0.6 0.6];
        %task.reward.time_neutral     = [0.6 0.6];
        
        current_timing_option='memory';
        eyefixationradius = 3;
        eyetargetradius   = 4;
        task.choice=0;
    case 2.5 % memory saccades
        task.type = 3;
        task.effector = 0;
        task.rest_hand = [1 1];
        %task.rest_hand = [0 0];
        task.reward.time_neutral     = [0.9 0.9];
        %task.reward.time_neutral     = [2 2];
        
        current_timing_option='memory';
        eyefixationradius = 4;
        eyetargetradius   = 4;    
        task.choice=1;
    case 3 % direct reaches left hand
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [0.15 0.15];
        
        current_timing_option='direct';
        hndfixationradius = 2;
        hndtargetradius   = 2;
        
    case 4 % direct reaches right hand
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.rest_hand = [1 1];
        task.reach_hand = 2;
        task.reward.time_neutral     = [0.15 0.15];
        
        current_timing_option='direct';
        hndfixationradius = 2;
        hndtargetradius   = 2;
        
    case 5 % memory reaches left hand
        task.type = 3; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [1.1 1.1];
        
        current_timing_option='memory';
        hndfixationradius = 3;
        hndtargetradius   = 3;
        
    case 6 % memory reaches right hand
        task.type = 3; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 2;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [1.1 1.1];
        
        current_timing_option='memory';
        hndfixationradius = 3;
        hndtargetradius   = 3;
        
    case 7 % dissociated direct reaches left
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [0.8 0.8];
        
        current_timing_option='direct';
        eyefixationradius = 3.5;
        eyetargetradius   = 3.5;
        hndfixationradius = 3;
        hndtargetradius   = 4;
        
    case 8 % dissociated direct reaches right
        
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 2;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [0.8 0.8];
        
        current_timing_option='direct';
        eyefixationradius = 3.5;
        eyetargetradius   = 3.5;
        hndfixationradius = 3;
        hndtargetradius   = 4;
        
    case 9 % dissociated memory reaches left
        task.type = 3; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [1.1 1.1];
        
        current_timing_option='memory';
        eyefixationradius = 4;
        eyetargetradius   = 4;        
        hndfixationradius = 3;
        hndtargetradius   = 4;
        
    case 10 % dissociated memory reaches right
        task.type = 3; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 2;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [1.1 1.1];
        
        current_timing_option='memory';
        eyefixationradius = 4;
        eyetargetradius   = 4;        
        hndfixationradius = 3;
        hndtargetradius   = 4;
        
    case 11 % dissociated memory reaches left learning task
        task.type = 2.5; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 1;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [1.0 1.0];
        
        current_timing_option='memory';
        eyefixationradius = 5;
        eyetargetradius   = 5;
        hndfixationradius = 3;
        hndtargetradius   = 4;
        
    case 12 % dissociated memory reaches right learning task
        task.type = 2.5; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 4; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.reach_hand = 2;
        task.rest_hand = [1 1];
        task.reward.time_neutral     = [1.0 1.0];
        
        current_timing_option='memory';
        eyefixationradius = 5;
        eyetargetradius   = 5;
        hndfixationradius = 3;
        hndtargetradius   = 4;
end

% Correct size assignment
task.eye.fix.radius     = eyefixationradius;
task.eye.tar(1).radius  = eyetargetradius;
task.eye.tar(2).radius  = eyetargetradius;
task.hnd.fix.radius     = hndfixationradius;
task.hnd.fix.size       = hndfixationradius;
task.hnd.tar(1).size    = hndtargetradius; % deg
task.hnd.tar(2).size    = hndtargetradius; % deg
task.hnd.tar(1).radius  = hndtargetradius; % deg
task.hnd.tar(2).radius  = hndtargetradius; % deg


task.hnd_right.color_cue    = [50 80 50];
task.hnd_left.color_cue     = [64 77 80];

% TIMING
switch current_timing_option
    case 'memory'
        task.timing.del_time_hold = 1;
        task.timing.del_time_hold_var = 0.3;
        
        
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.3;
        task.timing.cue_time_hold = 0.2;
        task.timing.cue_time_hold_var = 0;
        task.timing.mem_time_hold = 0.5; % 1.5 microstim
        task.timing.mem_time_hold_var = 0.5; % 0.5 microstim
        task.timing.tar_inv_time_hold = 0.3;
        task.timing.tar_inv_time_hold_var = 0.2;
         task.timing.tar_time_hold = 0.2;
         task.timing.tar_time_hold_var = 0.3;
         
         
%         task.timing.tar_inv_time_hold = 0.2;
%         task.timing.tar_inv_time_hold_var = 0.1;
%         task.timing.tar_time_hold = 0.2;
%         task.timing.tar_time_hold_var = 0.1;
    case 'direct'
        task.timing.fix_time_hold = 1.2;
        task.timing.fix_time_hold_var = 0.8;
        task.timing.tar_time_hold = 0.5;
        task.timing.tar_time_hold_var = 0.5;
    case 'calibration'
        task.timing.fix_time_hold = 0.8;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 1;
        task.timing.tar_time_hold_var = 0.5;
end

% %COLORS
% 
% task.eye.cue = task.eye.tar;
% task.hnd.cue = task.hnd.tar;
% 
% % Cue Color assignment
% task.eye.cue(1).color_dim       = [80 50 50];
% task.eye.cue(1).color_bright    = [80 50 50];
% task.eye.cue(2).color_dim       = [80 50 50];
% task.eye.cue(2).color_bright    = [80 50 50];
% 
% 
% if ismember(custom_trial_condition,[9,10,11,12])
%     task.eye.cue(1).color_dim       = [255 0 0];
%     task.eye.cue(1).color_bright    = [255 0 0];
%     task.eye.cue(2).color_dim       = [255 0 0];
%     task.eye.cue(2).color_bright    = [255 0 0];
% end
% 
% % Reach hand color assignment
% switch task.reach_hand
%     case 2 % right
%         task.hnd.fix.color_dim  = task.hnd_right.color_dim;
%         task.hnd.fix.color_bright  = task.hnd_right.color_bright;
%         [task.hnd.tar.color_dim] = deal(task.hnd_right.color_dim);
%         [task.hnd.tar.color_bright] = deal(task.hnd_right.color_bright);
%         task.hnd.cue(1).color_dim       = [50 80 50];
%         task.hnd.cue(1).color_bright    = [50 80 50];
%         task.hnd.cue(2).color_dim       = [50 80 50];
%         task.hnd.cue(2).color_bright    = [50 80 50];
%         if ismember(custom_trial_condition,[11,12])            
%             task.hnd.tar(1).color_dim       = [0 1 0];
%             task.hnd.tar(2).color_dim       = [0 1 0];
%         end
%     case 1 % left
%         task.hnd.fix.color_dim  = task.hnd_left.color_dim;
%         task.hnd.fix.color_bright  = task.hnd_left.color_bright;
%         [task.hnd.tar.color_dim] = deal(task.hnd_left.color_dim);
%         [task.hnd.tar.color_bright] = deal(task.hnd_left.color_bright);
%         task.hnd.cue(1).color_dim       = [64 77 80];
%         task.hnd.cue(1).color_bright    = [64 77 80];
%         task.hnd.cue(2).color_dim       = [64 77 80];
%         task.hnd.cue(2).color_bright    = [64 77 80];
%         if ismember(custom_trial_condition,[11,12])
%             task.hnd.tar(1).color_dim       = [0 1 1];
%             task.hnd.tar(2).color_dim       = [0 1 1];
%         end
% end
