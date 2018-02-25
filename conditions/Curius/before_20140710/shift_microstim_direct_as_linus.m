% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


% Ordered_sequence = repmat([1 1 1 2 3 4 5 6 7],1,50);
% Ordered_sequence = repmat([1],1,150);
% Ordered_sequence = repmat([2],1,120);
% Ordered_sequence = repmat([2],1,30);
% Ordered_sequence = repmat([1 1 1 2 3 4 5 6 7 8 9 10 11 12],1,30);
% Ordered_sequence = repmat([2 3 4 5 6 7 8 9 10 11 12],1,30);
Ordered_sequence = repmat([1],1,100);

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

task.reward.time_neutral     = [0.08 0.08];
task.eye.fix.color_dim = [128 0 0]; %
task.eye.fix.color_bright = [255 0 0];
%task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim

switch custom_trial_condition
    case 1 % baseline
        task.type = 2;
        task.microstim.fraction = 0; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0] ;
        task.microstim.end{1}      = [-0];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 2 % direct with different stimulation window timings
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.08] ;
        task.microstim.end{1}      = [-0];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 3 % direct with different stimulation window timings
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [-0.04] ;
        task.microstim.end{1}      = [-0];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 4 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 5 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.04] ;
        task.microstim.end{1}      = [0.24];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 6 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.08] ;
        task.microstim.end{1}      = [0.28];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 7 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.1] ;
        task.microstim.end{1}      = [0.3];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 8 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.11] ;
        task.microstim.end{1}      = [0.31];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 9 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.12] ;
        task.microstim.end{1}      = [0.32];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 10 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.13] ;
        task.microstim.end{1}      = [0.33];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 11 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.14] ;
        task.microstim.end{1}      = [0.34];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        
    case 12 % direct in acquisition
        task.type = 2;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0.15] ;
        task.microstim.end{1}      = [0.35];
        
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        

        
end

