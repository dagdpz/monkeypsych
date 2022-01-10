% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


N_stim_conditions=18;
N_position_conditions=6;
N_total_conditions=N_stim_conditions*N_position_conditions;
%Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions, 2:N_stim_conditions:N_total_conditions],1,20);  % saccade baselines
Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions],1,20);  % saccade baselines
% Ordered_sequence = repmat([9:N_stim_conditions:N_total_conditions, 10:N_stim_conditions:N_total_conditions],1,30); % reach baselines


% Ordered_sequence = repmat([9:N_stim_conditions:N_total_conditions,10:N_stim_conditions:N_total_conditions,11:N_stim_conditions:N_total_conditions,...
%                           12:N_stim_conditions:N_total_conditions,13:N_stim_conditions:N_total_conditions,14:N_stim_conditions:N_total_conditions,...
%                           15:N_stim_conditions:N_total_conditions,16:N_stim_conditions:N_total_conditions,17:N_stim_conditions:N_total_conditions,...
%                           18:N_stim_conditions:N_total_conditions],1,5);   % All reach conditions
% 
% Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions,2:N_stim_conditions:N_total_conditions,3:N_stim_conditions:N_total_conditions,...
%                            4:N_stim_conditions:N_total_conditions,5:N_stim_conditions:N_total_conditions,6:N_stim_conditions:N_total_conditions,...
%                            7:N_stim_conditions:N_total_conditions,8:N_stim_conditions:N_total_conditions],1,5);   % All saccade conditions

% Ordered_sequence = repmat([1:N_total_conditions],1,5); % All conditions

shuffle_conditions=1;
force_conditions=1;

if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence = Ordered_sequence;
elseif dyn.trialNumber == 1 && shuffle_conditions==1
    sequence = Shuffle(Ordered_sequence);
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if force_conditions==1
        if sum([trial.success])==length(sequence),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif force_conditions==2 
        if trial(end-1).success==1
            sequence=sequence(2:end);
        else
             sequence=Shuffle(sequence);
        end
        if numel(sequence)==0         
            dyn.state = STATE.CLOSE; return
        else
        custom_trial_condition = sequence(1);
        end
    else        
        if numel(trial)-1==length(sequence),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence(numel(trial));
        end
    end
else
    custom_trial_condition = sequence(1);
end

reward_time_saccades    = [0.8 0.8];
reward_time_reaches     = [0.9 0.9];
task.type = 3;
task.rest_hand = [0 0];

task.eye.fix.color_dim = [128 0 0]; %
task.eye.fix.color_bright = [255 0 0];

fix_eye_x=10;
fix_hnd_x=10;
fix_eye_y=18;
fix_hnd_y=15;
% tar_dis_x_at_0      = 24;
% tar_dis_x_high_low  = 22.5526;
% tar_dis_y_high_low  = 8.2085;
tar_dis_x_at_0      = 20;
tar_dis_x_high_low  = 17;
tar_dis_y_high_low  = 8;


task.eye.fix.x      = fix_eye_x;
task.eye.fix.y      = fix_eye_y;
task.hnd.fix.x      = fix_hnd_x;
task.hnd.fix.y      = fix_hnd_y;

reach_radius=4;
task.eye.fix.radius = 4;
task.eye.tar(1).radius = 4;  % deg
task.eye.tar(2).radius = 4;  % deg

task.hnd.fix.radius = reach_radius;
task.hnd.tar(1).radius = reach_radius;  % deg
task.hnd.tar(2).radius = reach_radius;  % deg
task.hnd.fix.size = reach_radius;
task.hnd.tar(1).size = reach_radius;  % deg
task.hnd.tar(2).size = reach_radius;  % deg


% task timing
task.microstim.interval = 1;

task.timing.grace_time_eye = 0;
task.timing.grace_time_hand = 0;
task.timing.fix_time_to_acquire_eye = 0.5;
task.timing.fix_time_to_acquire_hnd = 1;
task.timing.fix_time_hold = 0.4; % 0.5 microstim
task.timing.fix_time_hold_var = 0.3; % 0.5 microstim


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
         

task.timing.tar_time_to_acquire_eye = 0.5;
task.timing.tar_time_to_acquire_hnd = 1.5;
task.timing.tar_inv_time_to_acquire_eye = 2; %3
task.timing.tar_inv_time_to_acquire_hnd = 2;

% Reward
task.reward.time_small       = [0.03 0.03];
task.reward.time_large       = [0.03 0.03];



% Timing

task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts

task.timing.wait_for_reward = 0.2;
task.timing.ITI_success = 0.3;
task.timing.ITI_success_var = 0;
task.timing.ITI_fail    = 2;
task.timing.ITI_fail_var = 0;

task.timing.del_time_hold           = 0;
task.timing.del_time_hold_var       = 0;
task.timing.wait_for_reward = 0.2;

reach_hand_required = randi(2);
reach_effector=1;
%task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim
switch custom_trial_condition
    case num2cell([1:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Base
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;        
        task.choice=0;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([2:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Base
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=1;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([3:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Stim -0.08 (to GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([4:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Stim -0.08 (to GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([5:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Stim 0.00 (at GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([6:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Stim 0.00 (at GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([7:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Stim 0.08 (from GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([8:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Stim 0.08 (from GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
        
    case num2cell([9:N_stim_conditions:N_total_conditions])                     % Reach-Right_hand, Dir. Ins. Base
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=0;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([10:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Base
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=1;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([11:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim -0.08 (to GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([12:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim -0.08 (to GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([13:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim 0.00 (at GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([14:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim 0.00 (at GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([15:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim 0.08 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([16:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim 0.08 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([17:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim 0.24 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector4;
        task.reach_hand = reach_hand_required;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.24] ;
        task.microstim.end{1}      = [0.44];
    case num2cell([18:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim 0.24 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = reach_effector;
        task.reach_hand = reach_hand_required;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.24] ;
        task.microstim.end{1}      = [0.44];
end

task.eye.tar(1).x = fix_eye_x;
task.eye.tar(1).y = fix_eye_y;
task.eye.tar(2).x = fix_eye_x;
task.eye.tar(2).y = fix_eye_y;
switch custom_trial_condition
    case  num2cell([1:N_stim_conditions])
        switch task.effector
            case 0
                task.eye.tar(1).x = fix_eye_x + tar_dis_x_at_0;
                task.eye.tar(1).y = fix_eye_y;
                task.eye.tar(2).x = fix_eye_x - tar_dis_x_at_0;
                task.eye.tar(2).y = fix_eye_y;
            case 1
                task.hnd.tar(1).x = fix_hnd_x + tar_dis_x_at_0;
                task.hnd.tar(1).y = fix_hnd_y;
                task.hnd.tar(2).x = fix_hnd_x - tar_dis_x_at_0;
                task.hnd.tar(2).y = fix_hnd_y;
            case 4
                task.hnd.tar(1).x = fix_hnd_x + tar_dis_x_at_0;
                task.hnd.tar(1).y = fix_hnd_y;
                task.hnd.tar(2).x = fix_hnd_x - tar_dis_x_at_0;
                task.hnd.tar(2).y = fix_hnd_y;
        end
    case num2cell([(N_stim_conditions+1):N_stim_conditions*2])
        switch task.effector
            case 0
                task.eye.tar(1).x = fix_eye_x  + tar_dis_x_high_low;
                task.eye.tar(1).y = fix_eye_y  + tar_dis_y_high_low;
                task.eye.tar(2).x = fix_eye_x  - tar_dis_x_high_low;
                task.eye.tar(2).y = fix_eye_y  + tar_dis_y_high_low;
            case 1
                task.hnd.tar(1).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  + tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  + tar_dis_y_high_low;
            case 4
                task.hnd.tar(1).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  + tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  + tar_dis_y_high_low;
        end
    case num2cell([(N_stim_conditions*2+1):N_stim_conditions*3])
        switch task.effector
            case 0
                task.eye.tar(1).x = fix_eye_x  + tar_dis_x_high_low;
                task.eye.tar(1).y = fix_eye_y  - tar_dis_y_high_low;
                task.eye.tar(2).x = fix_eye_x  - tar_dis_x_high_low;
                task.eye.tar(2).y = fix_eye_y  - tar_dis_y_high_low;
            case 1
                task.hnd.tar(1).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  - tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  - tar_dis_y_high_low;
            case 4
                task.hnd.tar(1).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  - tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  - tar_dis_y_high_low;
        end
    case num2cell([(N_stim_conditions*3+1):N_stim_conditions*4])
        switch task.effector
            case 0
                task.eye.tar(1).x = fix_eye_x - tar_dis_x_at_0;
                task.eye.tar(1).y = fix_eye_y; 
                task.eye.tar(2).x = fix_eye_x + tar_dis_x_at_0;
                task.eye.tar(2).y = fix_eye_y;
            case 1
                task.hnd.tar(1).x = fix_hnd_x - tar_dis_x_at_0;
                task.hnd.tar(1).y = fix_hnd_y; 
                task.hnd.tar(2).x = fix_hnd_x + tar_dis_x_at_0;
                task.hnd.tar(2).y = fix_hnd_y; 
            case 4
                task.hnd.tar(1).x = fix_hnd_x - tar_dis_x_at_0;
                task.hnd.tar(1).y = fix_hnd_y; 
                task.hnd.tar(2).x = fix_hnd_x + tar_dis_x_at_0;
                task.hnd.tar(2).y = fix_hnd_y; 
        end
    case num2cell([(N_stim_conditions*4+1):N_stim_conditions*5])
        switch task.effector
            case 0
                task.eye.tar(1).x = fix_eye_x  - tar_dis_x_high_low;
                task.eye.tar(1).y = fix_eye_y  + tar_dis_y_high_low;
                task.eye.tar(2).x = fix_eye_x  + tar_dis_x_high_low;
                task.eye.tar(2).y = fix_eye_y  + tar_dis_y_high_low;
            case 1
                task.hnd.tar(1).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  + tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  + tar_dis_y_high_low;
            case 4
                task.hnd.tar(1).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  + tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  + tar_dis_y_high_low;
        end
    case num2cell([(N_stim_conditions*5+1):N_stim_conditions*6])
        switch task.effector
            case 0
                task.eye.tar(1).x = fix_eye_x  - tar_dis_x_high_low;
                task.eye.tar(1).y = fix_eye_y  - tar_dis_y_high_low;
                task.eye.tar(2).x = fix_eye_x  + tar_dis_x_high_low;
                task.eye.tar(2).y = fix_eye_y  - tar_dis_y_high_low;
            case 1
                task.hnd.tar(1).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  - tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  - tar_dis_y_high_low;
            case 4
                task.hnd.tar(1).x = fix_hnd_x  - tar_dis_x_high_low;
                task.hnd.tar(1).y = fix_hnd_y  - tar_dis_y_high_low;
                task.hnd.tar(2).x = fix_hnd_x  + tar_dis_x_high_low;
                task.hnd.tar(2).y = fix_hnd_y  - tar_dis_y_high_low;
        end
end

task.hnd_right.color_dim    = [0 128 0]; %
task.hnd_right.color_bright = [0 255 0];
task.hnd_left.color_dim     = [39 109 216]; %
task.hnd_left.color_bright  = [119 230 253];
task.hnd_stay.color_dim     = [128 129 0];
task.hnd_stay.color_bright  = [255 255 0];
task.hnd_right.color_cue    = [50 80 50];
task.hnd_left.color_cue     = [64 77 80];

task.eye.cue=task.eye.tar;
task.hnd.cue=task.hnd.tar;

% Colors
task.eye.fix.color_dim       = [128 0 0]; %
task.eye.fix.color_bright    = [255 0 0];
task.eye.tar(1).color_dim    = [128 0 0];  % 2.5 or 3
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim    = [128 0 0]; %  % 2.5 or 3
task.eye.tar(2).color_bright = [255 0 0];

if task.effector==0 || task.effector==1 || task.effector==2
    task.eye.cue(1).color_dim       = [80 50 50];
    task.eye.cue(1).color_bright    = [80 50 50];
    task.eye.cue(2).color_dim       = [80 50 50];
    task.eye.cue(2).color_bright    = [80 50 50];
end
