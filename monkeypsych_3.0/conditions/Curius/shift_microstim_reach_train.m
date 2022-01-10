% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


N_stim_conditions=18;
N_position_conditions=6;
N_total_conditions=N_stim_conditions*N_position_conditions;
%  Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions, 2:N_stim_conditions:N_total_conditions],1,15);  % saccade baselines
Ordered_sequence = repmat([9:N_stim_conditions:N_total_conditions, 10:N_stim_conditions:N_total_conditions],1,15); % reach baselines


% Ordered_sequence = repmat([9:N_stim_conditions:N_total_conditions,10:N_stim_conditions:N_total_conditions,11:N_stim_conditions:N_total_conditions,...
%                           12:N_stim_conditions:N_total_conditions,13:N_stim_conditions:N_total_conditions,14:N_stim_conditions:N_total_conditions,...
%                           15:N_stim_conditions:N_total_conditions,16:N_stim_conditions:N_total_conditions,17:N_stim_conditions:N_total_conditions,...
%                           18:N_stim_conditions:N_total_conditions],1,5);   % All reach conditions

% Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions,2:N_stim_conditions:N_total_conditions,3:N_stim_conditions:N_total_conditions,...
%                            4:N_stim_conditions:N_total_conditions,5:N_stim_conditions:N_total_conditions,6:N_stim_conditions:N_total_conditions,...
%                            7:N_stim_conditions:N_total_conditions,8:N_stim_conditions:N_total_conditions],1,5);   % All saccade conditions

% Ordered_sequence = repmat([1:N_total_conditions],1,5); % All conditions

task.shuffle_conditions=1;
if dyn.trialNumber == 1 && task.shuffle_conditions==1
    sequence = shuffle(Ordered_sequence);
elseif dyn.trialNumber == 1 && task.shuffle_conditions==0
    sequence = Ordered_sequence;
end


if dyn.trialNumber > 1,
    if sum([trial.success])+1>length(sequence),
        dyn.state = STATE.CLOSE;
    else
        custom_trial_condition = sequence(sum([trial.success])+1);
    end
else
    custom_trial_condition = sequence(1);
end


reward_time_saccades    = [0.4 0.4];
reward_time_reaches     = [0.5 0.5];
task.rest_hand = [1 1];

task.reach_hand = 2;

task.eye.fix.color_dim = [128 0 0]; %
task.eye.fix.color_bright = [255 0 0];

fix_eye_x=0;
fix_hnd_x=0;
fix_eye_y=20;
fix_hnd_y=16;
tar_dis_x_at_0      = 24;
tar_dis_x_high_low  = 22.5526;
tar_dis_y_high_low  = 8.2085;


task.eye.fix.x      = fix_eye_x;
task.eye.fix.y      = fix_eye_y;
task.hnd.fix.x      = fix_hnd_x;
task.hnd.fix.y      = fix_hnd_y;


task.eye.fix.radius = 5;
task.eye.tar(1).radius = 5;  % deg
task.eye.tar(2).radius = 5;  % deg

task.hnd.fix.radius = 4;
task.hnd.tar(1).radius = 4;  % deg
task.hnd.tar(2).radius = 4;  % deg
task.hnd.fix.size = 4;
task.hnd.tar(1).size = 4;  % deg
task.hnd.tar(2).size = 4;  % deg


% task timing
task.microstim.interval = 1;

task.timing.grace_time_eye = 0;
task.timing.grace_time_hand = 0;
task.timing.fix_time_to_acquire_eye = 0.5;
task.timing.fix_time_to_acquire_hnd = 1;
task.timing.fix_time_hold = 0.4; % 0.5 microstim
task.timing.fix_time_hold_var = 0.3; % 0.5 microstim
task.timing.tar_time_to_acquire_eye = 0.5;
task.timing.tar_time_to_acquire_hnd = 1.5;
task.timing.tar_time_hold = 0.5;
task.timing.tar_time_hold_var = 0;

task.timing.wait_for_reward = 0.2;
task.timing.ITI_success = 1; % 1 microstim
task.timing.ITI_success_var = 0;
task.timing.ITI_fail    = 1;
task.timing.ITI_fail_var = 0;



%task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim
switch custom_trial_condition
    case num2cell([1:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Base
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([2:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Base
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([3:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Stim -0.08 (to GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([4:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Stim -0.08 (to GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([5:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Stim 0.00 (at GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([6:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Stim 0.00 (at GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([7:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Ins. Stim 0.08 (from GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([8:N_stim_conditions:N_total_conditions])                     % Sacc, Dir. Cho. Stim 0.08 (from GO)
        task.reward.time_neutral     = reward_time_saccades;
        task.effector = 0;
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
        
    case num2cell([9:N_stim_conditions:N_total_conditions])                     % Reach-Right_hand, Dir. Ins. Base
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([10:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Base
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 0; % from 0 to 1
    case num2cell([11:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim -0.08 (to GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([12:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim -0.08 (to GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
    case num2cell([13:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim 0.00 (at GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([14:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim 0.00 (at GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([15:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim 0.08 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([16:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim 0.08 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([17:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Ins. Stim 0.24 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.24] ;
        task.microstim.end{1}      = [0.44];
    case num2cell([18:N_stim_conditions:N_total_conditions])                    % Reach-Right_hand, Dir. Cho. Stim 0.24 (from GO) 
        task.reward.time_neutral     = reward_time_reaches;
        task.effector = 4;        
        task.type = 2;
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
% fix_eye_x
% task.eye.tar(1).x
% task.eye.tar(2).x

