% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);

% sequence = repmat([1 2 3 4], 1, 30)
% sequence = [1 3 3 1 3 3 3];
sequence = [3 3 1 3 3 1];
% sequence = sequence(randperm(length(sequence)));
sequence = repmat(sequence, 1, 100);


if dyn.trialNumber > 1,
    custom_trial_condition = sequence(sum([trial.success])+1);
else
    custom_trial_condition = sequence(1);
end

task.reward.time_neutral     = [0.80 0.80]; % [0.06 0.06] for microstim

task.force_target_location = 1;

switch custom_trial_condition
    
    case 1 % fixation 
        
        task.type = 1;
        task.timing.fix_time_hold = 22; %22
        task.timing.fix_time_hold_var = 8; %10

        task.microstim.fraction = 0;
        
    case 2 % fixation with microstim
        
        task.type = 1;
        task.timing.fix_time_hold = 25;
        task.timing.fix_time_hold_var = 10;

        task.microstim.fraction = 0;
        task.microstim.state = [STATE.FIX_HOL];      
        task.microstim.start{1}    = [1] ;
        task.microstim.end{1}      = [2];
        
    case 3 % memory
        
        task.type = 3;
        task.timing.fix_time_hold = 10; %10;
        task.timing.fix_time_hold_var = 3; %4;
        task.timing.mem_time_hold = 10; %10;
        task.timing.mem_time_hold_var = 3; %4;
        task.timing.tar_time_hold = 2;
        task.timing.tar_time_hold_var = 2; %2;
        
        task.microstim.fraction = 0;
        
    case 4 % memory with microstim
        
        task.type = 3;
        task.timing.fix_time_hold = 10;
        task.timing.fix_time_hold_var = 5;
        task.timing.mem_time_hold = 10;
        task.timing.mem_time_hold_var = 5;
        task.timing.tar_time_hold = 3;
        task.timing.tar_time_hold_var = 2;
        
        task.microstim.fraction = 0;
        task.microstim.state = [STATE.MEM_PER];      
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [1];
end

