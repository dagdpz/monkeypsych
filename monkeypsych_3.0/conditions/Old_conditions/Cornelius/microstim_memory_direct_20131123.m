% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);
shuffle_conditions=1;

Ordered_sequence = repmat([1,2,3,4],1,200);
%  sequence = [1 1 1 1 1 1 1 1 1 1]; 
if dyn.trialNumber == 1 && shuffle_conditions==1
sequence = shuffle(Ordered_sequence);
elseif dyn.trialNumber == 1 && shuffle_conditions==0
sequence = Ordered_sequence;    
end
% sequence = [3 3 3 3 3 3 3 3 3 3];
    
if dyn.trialNumber > 1,
    custom_trial_condition = sequence(sum([trial.success])+1);
else
    custom_trial_condition = sequence(1);
end

switch custom_trial_condition
    case 1 % direct
        task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\linus_cornelius_0_1_2.txt';
        task.microstim.fraction = 0; % from 0 to 1        
        task.fraction_choice = 0.25;
        task.type = 2;
        task.effector = 0;
        task.timing.fix_time_hold = 1.2;
        task.timing.fix_time_hold_var = 0.8;
        task.timing.tar_time_hold = 0.5;
        task.eye.fix.radius = 3;
        task.eye.tar(1).radius = 3;
        task.eye.tar(2).radius = 3;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
        task.reward.time_neutral     = [0.12 0.12];
        
   case 2 % memory
        task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\linus_cornelius_0_1_2.txt';
        task.microstim.fraction = 0; % from 0 to 1
        task.fraction_choice = 0.25;
        task.type = 3;
        task.effector = 0;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.3;
        task.timing.cue_time_hold = 0.2;
        task.timing.cue_time_hold_var = 0;
        task.timing.tar_time_hold = 0.5;
        task.timing.mem_time_hold = 0.5; % 1.5 microstim
        task.timing.mem_time_hold_var = 0.5; % 0.5 microstim
        task.eye.tar(1).radius = 4;
        task.eye.tar(2).radius = 4;
        task.eye.fix.radius = 3;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
        task.reward.time_neutral     = [0.15 0.15];
        
    case 3 % direct reaches
        
        task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\linus_cornelius_0_1_2.txt';
        task.microstim.fraction = 0;
        task.type = 2; % 2 - direct reach 2.5! 2 for calib and 2.5 for memory training! reach task
        task.effector = 1; % 0 - eye, 1 - hand, 2 - coordinated eye-hand, 3 - saccade with central reach, 4 - reach with central fixation
        task.rest_sensors_ini_time = 1; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.fraction_choice = 0.25;
        task.hnd.tar(1).radius = 3; % deg 
        task.hnd.tar(2).radius = 3; % deg
        task.hnd.tar(1).size = 3; % deg
        task.hnd.tar(2).size = 3; % deg
        task.timing.grace_time_hand = 0;
        task.timing.fix_time_to_acquire_hnd = 2;
        task.timing.fix_time_hold = 1.2; 
        task.timing.fix_time_hold_var = 0.5;
        task.timing.tar_time_to_acquire_hnd = 1;
        task.timing.tar_time_hold = 0.5; 
        task.timing.tar_time_hold_var = 0.5; 
        task.reward.time_neutral     = [0.18 0.18];

end

