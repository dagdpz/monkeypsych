% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);

sequence = [1 1 1 1 4 1 1 1 1 4 1 1 1 1 4 1 1 1 1 4]; % 4 4 5 4 4 5 4 4 5 4 4 5 4 4 5];
% sequence = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    
if dyn.trialNumber > 1,
    custom_trial_condition = sequence(sum([trial.success])+1);
else
    custom_trial_condition = 1;
end

task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim

switch custom_trial_condition
    case 0 % fixation microstim
        %task.fraction_choice=0;
        task.type = 1;
        task.microstim.fraction = 0; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [5];
        task.microstim.interval = 1.5;
    case 1 % fixation microstim
        %task.fraction_choice=0;
        task.type = 1;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [1] ;
        task.microstim.end{1}      = [5];
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 5;
        task.reward.time_neutral     = [0.1 0.1];
    case 2 % direct saccade microstim instructed
        %task.fraction_choice=0;
        task.type = 2;
        task.choice=0;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
        task.timing.fix_time_hold = 1;
        task.reward.time_neutral     = [0.05 0.05];
        
    case 3 % idirect saccade no microstim instructed
        %task.fraction_choice=0;
        task.type = 2;
        task.choice=0;
        task.microstim.fraction = 0; % from 0 to 1
        task.reward.time_neutral     = [0.05 0.05];
        task.timing.fix_time_hold = 1;
        
    case 4 % direct saccade microstim choice
        %task.fraction_choice=0;
        task.type = 2;
        task.choice=1;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
        task.timing.fix_time_hold = 1;
        task.reward.time_neutral     = [0.05 0.05];
        
    case 5 % idirect saccade no microstim choice
        %task.fraction_choice=0;
        task.type = 2;
        task.choice=1;
        task.microstim.fraction = 0; % from 0 to 1
        task.reward.time_neutral     = [0.05 0.05];
        task.timing.fix_time_hold = 1;
        
end

