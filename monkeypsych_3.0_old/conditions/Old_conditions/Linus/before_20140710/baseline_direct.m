% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


Ordered_sequence = repmat([2],1,500);
% Ordered_sequence = repmat([2],1,100);

shuffle_conditions=1;
if dyn.trialNumber == 1 && shuffle_conditions==1
    sequence = shuffle(Ordered_sequence);
elseif dyn.trialNumber == 1 && shuffle_conditions==0
    sequence = Ordered_sequence;
end

if dyn.trialNumber > 1,
    if sum([trial.success])==length(sequence),
        dyn.state = STATE.CLOSE;
    else
        custom_trial_condition = sequence(sum([trial.success])+1);
    end
else
    custom_trial_condition = sequence(1);
end

%task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim

switch custom_trial_condition
    case 1 % direct with different stimulation window timings
        task.type = 2;
        task.microstim.fraction = 0; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.2 -0.16 -0.12 -0.08 -0.04] ;
        task.microstim.end{1}      = [-0 -0 -0 -0 -0];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        task.reward.time_neutral     = [0.1 0.1];
        
        %task.eye.fix.radius = 4;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
    case 2 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 0; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0 0.04 0.08 0.12] ;
        task.microstim.end{1}      = [0.2 0.24 0.28 0.32];
        
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        task.reward.time_neutral     = [0.15 0.15];
        
        %task.eye.fix.radius = 4;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
end

