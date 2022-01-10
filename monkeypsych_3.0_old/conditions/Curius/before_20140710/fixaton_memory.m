% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);

sequence = [1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4 1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4 1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4 1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4];

if dyn.trialNumber > 1,
    custom_trial_condition = sequence(sum([trial.success])+1);
else
    custom_trial_condition = 1;
end

task.reward.time_neutral     = [0.9 0.9]; % [0.06 0.06] for microstim

switch custom_trial_condition
    
    case 1 % fixation 
        
        task.type = 1;
        task.timing.fix_time_hold = 35;
        
        task.microstim.fraction = 0;
        
    case 2 % fixation with microstim
        
        task.type = 1;
        task.timing.fix_time_hold = 35;
        
        task.microstim.fraction = 0;
        task.microstim.state = [STATE.FIX_HOL];      
        task.microstim.start{1}    = [1] ;
        task.microstim.end{1}      = [2];
        
    case 3 % memory
        
        task.type = 3;
        task.timing.fix_time_hold = 12;
        task.timing.mem_time_hold = 15;
        task.timing.tar_time_hold = 8;
        
        task.microstim.fraction = 0;
        
    case 4 % memory with microstim
        
        task.type = 3;
        task.timing.fix_time_hold = 12;
        task.timing.mem_time_hold = 15;
        task.timing.tar_time_hold = 8;
        
        task.microstim.fraction = 0;
        task.microstim.state = [STATE.MEM_PER];      
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [1];
end

