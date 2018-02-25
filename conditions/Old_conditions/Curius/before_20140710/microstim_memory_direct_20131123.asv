% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);

%  sequence = [1 1 1 1 1 1 1 1 1 1]; 

sequence = repmat([1 2],1,200);
% sequence = [3 3 3 3 3 3 3 3 3 3];
    
if dyn.trialNumber > 1,
    custom_trial_condition = sequence(sum([trial.success])+1);
else
    custom_trial_condition = sequence(1);
end

%task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim

switch custom_trial_condition
    case 1 % direct
        task.type = 2;
        task.microstim.fraction = 0.5; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 2.2;
        task.timing.fix_time_hold_var = 0.7;
        task.timing.tar_time_hold = 0.5;
        task.reward.time_neutral     = [0.04 0.04];
        
        %task.eye.fix.radius = 4;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
   case 2 % memory
        task.type = 3;
        task.microstim.fraction = 0.5; % from 0 to 1
        task.microstim.state = [STATE.TAR_ACQ_INV];
        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 0.5;
        task.timing.fix_time_hold_var = 0.2;
        task.timing.tar_time_hold = 0.5;
        task.reward.time_neutral     = [0.04 0.04];
        
        %task.eye.fix.radius = 4;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];

end

