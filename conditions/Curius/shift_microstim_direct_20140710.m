% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


N_stim_conditions=16;
N_position_conditions=6;
N_total_conditions=N_stim_conditions*N_position_conditions;

% Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions, 9:N_stim_conditions:N_total_conditions],1,15); % baselines
Ordered_sequence = repmat([1:N_total_conditions],1,5);

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


% if dyn.trialNumber > 1,
%     if numel([trial.success])+1>length(sequence),
%         dyn.state = STATE.CLOSE;
%     else
%         custom_trial_condition = sequence(numel([trial.success])+1);
%     end
% else
%     custom_trial_condition = sequence(1);
% end

task.reward.time_neutral     = [0.4 0.4];
task.microstim.interval = 1;
task.timing.fix_time_hold = 0.5;
task.timing.fix_time_hold_var = 0.2;
task.timing.tar_time_hold = 0.5;
task.eye.fix.color_dim = [128 0 0]; %
task.eye.fix.color_bright = [255 0 0];
% task.eye.tar(1).color_dim = [6 0 0]; %
% task.eye.tar(1).color_bright = [255 0 0];
% task.eye.tar(2).color_dim = [6 0 0]; %
% task.eye.tar(2).color_bright = [255 0 0];


        task.timing.ITI_success = 1; % 1 microstim
        task.timing.ITI_success_var = 0;
        task.timing.ITI_fail    = 1;
        task.timing.ITI_fail_var = 0;

fix_offset=0;
fix_y=20;


task.eye.fix.x      = fix_offset; 
task.eye.fix.y      = fix_y; 
task.effector = 0;
task.rest_hand = [0 0];

task.eye.fix.radius = 5;
task.eye.tar(1).radius = 5;  % deg
task.eye.tar(2).radius = 5;  % deg

%task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim
switch custom_trial_condition
    case num2cell([1:N_stim_conditions:N_total_conditions]) % instructed baseline
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 0; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0] ;
        task.microstim.end{1}      = [-0];
    case num2cell([2:N_stim_conditions:N_total_conditions]) % instructed direct in hold
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.12] ;
        task.microstim.end{1}      = [-0];             
    case num2cell([3:N_stim_conditions:N_total_conditions]) % instructed direct in hold
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];        
    case num2cell([4:N_stim_conditions:N_total_conditions]) % instructed direct in hold
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.04] ;
        task.microstim.end{1}      = [-0];
    case num2cell([5:N_stim_conditions:N_total_conditions]) % instructed direct in acquisition
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([6:N_stim_conditions:N_total_conditions]) % instructed direct in acquisition
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.04] ;
        task.microstim.end{1}      = [0.24];
    case num2cell([7:N_stim_conditions:N_total_conditions]) % instructed direct in acquisition
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([8:N_stim_conditions:N_total_conditions]) % instructed direct in acquisition
        task.type = 2;
        task.choice=0;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.12] ;
        task.microstim.end{1}      = [0.32]; 
    case num2cell([9:N_stim_conditions:N_total_conditions]) % choice baseline
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 0; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0] ;
        task.microstim.end{1}      = [-0];
    case num2cell([10:N_stim_conditions:N_total_conditions]) % choice direct in hold
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.12] ;
        task.microstim.end{1}      = [-0];             
    case num2cell([11:N_stim_conditions:N_total_conditions]) % choice direct in hold
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];        
    case num2cell([12:N_stim_conditions:N_total_conditions]) % choice direct in hold
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.04] ;
        task.microstim.end{1}      = [-0];
    case num2cell([13:N_stim_conditions:N_total_conditions]) % choice direct in acquisition
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
    case num2cell([14:N_stim_conditions:N_total_conditions]) % choice direct in acquisition
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.04] ;
        task.microstim.end{1}      = [0.24];
    case num2cell([15:N_stim_conditions:N_total_conditions]) % choice direct in acquisition
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
    case num2cell([16:N_stim_conditions:N_total_conditions]) % choice direct in acquisition
        task.type = 2;
        task.choice=1;
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.12] ;
        task.microstim.end{1}      = [0.32];        
end

switch custom_trial_condition
    case  num2cell([1:N_stim_conditions])
        task.eye.tar(1).x = 24 + fix_offset;
        task.eye.tar(1).y = fix_y;
        task.eye.tar(2).x = -24 + fix_offset;
        task.eye.tar(2).y = fix_y;
    case num2cell([(N_stim_conditions+1):N_stim_conditions*2])
        task.eye.tar(1).x = 22.5526 + fix_offset;
        task.eye.tar(1).y = fix_y + 8.2085;
        task.eye.tar(2).x = -22.5526 + fix_offset;
        task.eye.tar(2).y = fix_y + 8.2085;
    case num2cell([(N_stim_conditions*2+1):N_stim_conditions*3])
        task.eye.tar(1).x = 22.5526 + fix_offset;
        task.eye.tar(1).y = fix_y - 8.2085;
        task.eye.tar(2).x = -22.5526 + fix_offset;
        task.eye.tar(2).y = fix_y - 8.2085;
    case num2cell([(N_stim_conditions*3+1):N_stim_conditions*4])
        task.eye.tar(1).x = -24 + fix_offset;
        task.eye.tar(1).y = fix_y; %% 11.7915;
        task.eye.tar(2).x = 24 + fix_offset;
        task.eye.tar(2).y = fix_y; %% 11.7915;
    case num2cell([(N_stim_conditions*4+1):N_stim_conditions*5])
        task.eye.tar(1).x = -22.5526 + fix_offset;
        task.eye.tar(1).y = fix_y + 8.2085;
        task.eye.tar(2).x = 22.5526 + fix_offset;
        task.eye.tar(2).y = fix_y + 8.2085;
    case num2cell([(N_stim_conditions*5+1):N_stim_conditions*6])
        task.eye.tar(1).x = -22.5526 + fix_offset;
        task.eye.tar(1).y = fix_y - 8.2085;
        task.eye.tar(2).x = 22.5526 + fix_offset;
        task.eye.tar(2).y = fix_y - 8.2085;
end
% fix_offset
% task.eye.tar(1).x
% task.eye.tar(2).x

