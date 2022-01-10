% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


N_stim_conditions=2;
N_position_conditions=6;
N_total_conditions=N_stim_conditions*N_position_conditions;

%  Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions, 9:N_stim_conditions:N_total_conditions],1,15); % baselines
 Ordered_sequence = repmat([1:N_total_conditions],1,40);

task.shuffle_conditions=1;
if dyn.trialNumber == 1 && task.shuffle_conditions==1
    sequence = shuffle(Ordered_sequence);
elseif dyn.trialNumber == 1 && task.shuffle_conditions==0
    sequence = Ordered_sequence;
end

if dyn.trialNumber > 1,
    if numel(trial)>length(sequence),
        dyn.state = STATE.CLOSE;
    else
        custom_trial_condition = sequence(numel(trial));
    end
else
    custom_trial_condition = sequence(1);
end


%Timing
task.reward.time_neutral            = [0.3 0.3];
task.timing.fix_time_hold           = 0.5;
task.timing.fix_time_hold_var       = 0;
task.timing.fix_time_to_acquire_eye = 0.5;
task.timing.grace_time_eye          = 0;
task.timing.ITI_success             = 0.5;
task.timing.ITI_success_var         = 2;
task.timing.ITI_fail                = 0.5;
task.timing.ITI_fail_var            = 2;

%Colors
hue_level=6;
task.eye.fix.color_dim              = [hue_level 0 0]; %
task.eye.fix.color_bright           = [hue_level 0 0];

% stim off
task.microstim.stim_on      = 0;
task.microstim.state        = [STATE.FIX_HOL];
task.microstim.start{1}     = [-0] ;
task.microstim.end{1}       = [-0];

task.type   = 1;
task.choice = 0;

task.effector = 0;
task.rest_hand = [0 0];
task.eye.fix.radius = 5;

% Positions        
fix_x_offset=0;
fix_y_offset=20;
switch custom_trial_condition
    case  num2cell([1:N_stim_conditions])
        task.eye.fix.x = 24       + fix_x_offset;
        task.eye.fix.y =            fix_y_offset;
    case num2cell([(N_stim_conditions+1):N_stim_conditions*2])
        task.eye.fix.x = 22.5526  + fix_x_offset;
        task.eye.fix.y = 8.2085   + fix_y_offset;
    case num2cell([(N_stim_conditions*2+1):N_stim_conditions*3])
        task.eye.fix.x = 22.5526  + fix_x_offset;
        task.eye.fix.y = -8.2085  + fix_y_offset;
    case num2cell([(N_stim_conditions*3+1):N_stim_conditions*4])
        task.eye.fix.x = -24      + fix_x_offset;
        task.eye.fix.y =            fix_y_offset; 
    case num2cell([(N_stim_conditions*4+1):N_stim_conditions*5])
        task.eye.fix.x = -22.5526 + fix_x_offset;
        task.eye.fix.y = 8.2085   + fix_y_offset;
    case num2cell([(N_stim_conditions*5+1):N_stim_conditions*6])
        task.eye.fix.x = -22.5526 + fix_x_offset;
        task.eye.fix.y = -8.2085  + fix_y_offset;
end

switch custom_trial_condition
    case num2cell([1:N_stim_conditions:N_total_conditions]) % no stim
        task.microstim.stim_on = 0; % from 0 to 1
        task.microstim.state = [STATE.FIX_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0];
    case num2cell([2:N_stim_conditions:N_total_conditions]) % stim
        task.microstim.stim_on = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];            
end
