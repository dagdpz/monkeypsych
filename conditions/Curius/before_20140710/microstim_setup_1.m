% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);

%sequence = [1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4 1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4 1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4 1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4  1 2 3 4];
sequence = [1 1 1 1 1  2 2 2 2 2 2 2 2 2 2  3 3 3 3 3  4 4 4 4 4 4 4 4 4 4 ...
            1 1 1 1 1  2 2 2 2 2 2 2 2 2 2  3 3 3 3 3  4 4 4 4 4 4 4 4 4 4 ...
            1 1 1 1 1  2 2 2 2 2 2 2 2 2 2  3 3 3 3 3  4 4 4 4 4 4 4 4 4 4 ...
            1 1 1 1 1  2 2 2 2 2 2 2 2 2 2  3 3 3 3 3  4 4 4 4 4 4 4 4 4 4 ...
            1 1 1 1 1  2 2 2 2 2 2 2 2 2 2  3 3 3 3 3  4 4 4 4 4 4 4 4 4 4];
%     sequence = [1 2 3 4 1 2 3 4];
if dyn.trialNumber > 1,
    custom_trial_condition = sequence(sum([trial.success])+1);
else
    custom_trial_condition = 1;
end

task.reward.time_neutral     = [0.06 0.06]; % [0.06 0.06] for microstim

switch custom_trial_condition
    
    case 1 % instructed no microstim 
        %task.fraction_choice=0;
        task.choice=0;
        task.microstim.fraction = 0; % from 0 to 1
        
    case 2 % instructed with microstim
        %task.fraction_choice=0;
        task.choice=0;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.interval = 1; % s, how often to produce train
        task.microstim.state = [STATE.TAR_ACQ];
%         task.microstim.state = [STATE.TAR_HOL];

        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
        
    case 3 % choice no microstim 
        %task.fraction_choice=1;
        task.choice=1;
        task.microstim.fraction = 0; % from 0 to 1
        
        
    case 4 % choice with microstim 
        %task.fraction_choice=1;
        task.choice=1;
        task.microstim.fraction = 1; % from 0 to 1
        task.microstim.interval = 1; % s, how often to produce train
        task.microstim.state = [STATE.TAR_ACQ];
%         task.microstim.state = [STATE.TAR_HOL];

        task.microstim.start{1}    = [0] ;
        task.microstim.end{1}      = [0.2];
end

