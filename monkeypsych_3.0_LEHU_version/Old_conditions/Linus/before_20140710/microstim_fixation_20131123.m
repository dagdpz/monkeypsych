% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);

  sequence = repmat([1],1,10);

if dyn.trialNumber > 1,
    if sum([trial.success])==length(sequence),
        dyn.state = STATE.CLOSE;
    else
        custom_trial_condition = sequence(sum([trial.success])+1);
    end
else
    custom_trial_condition = sequence(1);
end

task.reward.time_neutral     = [0.1 0.1]; % [0.06 0.06] for microstim

switch custom_trial_condition
    case 1 % % short trials for finding evoked sacade amplitude (SA) and current threshold
        task.type = 1;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [0.5] ;
        task.microstim.end{1}      = [1];
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 1;
        task.reward.time_neutral     = [0.1 0.1];
        
        task.eye.fix.radius = 10;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
   case 2 % long trials for finding evoked saccade amplitude for five different positions (0,SA,-SA,2*SA,-2*SA), 
          % 2 currents above threshold, 1 subthreshold (maybe we still see accumulation)
        task.type = 1;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [0.5] ;
        task.microstim.end{1}      = [4];
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 4;
        task.reward.time_neutral     = [0.1 0.1];
        
        task.eye.fix.radius = 10;
        task.eye.fix.color_dim = [128 0 0]; %
        task.eye.fix.color_bright = [255 0 0];
    case 3 % long trials for finding evoked saccade amplitude for exploration (not supressing saccades)
        task.type = 1;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.state = [STATE.FIX_HOL];
        task.microstim.start{1}    = [0.5] ;
        task.microstim.end{1}      = [4];
        task.microstim.interval = 1;
        task.timing.fix_time_hold = 4;
        task.reward.time_neutral     = [0.03 0.03];
        
        task.eye.fix.radius = 200;
        task.eye.fix.color_dim = [0 0 0];
        task.eye.fix.color_bright = [0 0 0];
end

