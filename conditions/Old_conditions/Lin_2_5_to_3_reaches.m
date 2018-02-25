Ordered_sequence = repmat([3],1,40);




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

switch custom_trial_condition
    case 1
        task.type = 2.5;
        task.effector = 4;
        task.reward.time_neutral     = [0.7 0.7]; 
       
        task.hnd_right.color_dim = [0 10 0]; 
        task.hnd_right.color_bright = [0 255 0];
        task.hnd_left.color_dim = [4 11 21]; %
        task.hnd_left.color_bright = [12 23 25];
        
        switch task.reach_hand
            case 2 % right
                task.hnd.fix.color_dim  = [0 128 0];
                task.hnd.fix.color_bright  = [0 255 0];
                [task.hnd.tar.color_dim] = deal(task.hnd_right.color_dim);
                [task.hnd.tar.color_bright] = deal(task.hnd_right.color_bright);
            case 1 % left
                task.hnd.fix.color_dim  = [0 0 128];
                task.hnd.fix.color_bright  = [0 0 255];
                [task.hnd.tar.color_dim] = deal(task.hnd_left.color_dim);
                [task.hnd.tar.color_bright] = deal(task.hnd_left.color_bright);
        end
        
        task.hnd.cue(1).color_dim       = [0 128 0];
        task.hnd.cue(1).color_bright    = [0 255 0];
        task.hnd.cue(2).color_dim       = [0 128 0];
        task.hnd.cue(2).color_bright    = [0 255 0];
        
        task.eye.fix.radius = 5;
        task.eye.tar(1).radius = 5;
        task.eye.tar(2).radius = 5;
        
        
    case 2
        task.type = 3;
        task.effector = 4;
        task.reward.time_neutral     = [0.9 0.9]; 
        
        task.hnd_right.color_dim = [0 128 0]; 
        task.hnd_right.color_bright = [0 255 0];
        task.hnd_left.color_dim = [4 11 21]; %
        task.hnd_left.color_bright = [12 23 25];

        switch task.reach_hand
            case 2 % right
                task.hnd.fix.color_dim  = [0 128 0];
                task.hnd.fix.color_bright  = [0 255 0];
                [task.hnd.tar.color_dim] = deal(task.hnd_right.color_dim);
                [task.hnd.tar.color_bright] = deal(task.hnd_right.color_bright);
            case 1 % left
                task.hnd.fix.color_dim  = [0 0 128];
                task.hnd.fix.color_bright  = [0 0 255];
                [task.hnd.tar.color_dim] = deal(task.hnd_left.color_dim);
                [task.hnd.tar.color_bright] = deal(task.hnd_left.color_bright);
        end
        
        task.hnd.cue(1).color_dim       = [0 128 0];
        task.hnd.cue(1).color_bright    = [0 255 0];
        task.hnd.cue(2).color_dim       = [0 128 0];
        task.hnd.cue(2).color_bright    = [0 255 0];
        
        task.eye.fix.radius = 5;
        task.eye.tar(1).radius = 5;
        task.eye.tar(2).radius = 5;
        
    case 3
        task.type = 4;
        task.effector = 4;
        task.reward.time_neutral     = [0.6 0.6]; 
        task.hnd_right.color_dim = [0 128 0]; 
        task.hnd_right.color_bright = [0 255 0];
        task.hnd_left.color_dim = [4 11 21]; %
        task.hnd_left.color_bright = [12 23 25];

        switch task.reach_hand
            case 2 % right
                task.hnd.fix.color_dim  = [0 128 0];
                task.hnd.fix.color_bright  = [0 255 0];
                [task.hnd.tar.color_dim] = deal(task.hnd_right.color_dim);
                [task.hnd.tar.color_bright] = deal(task.hnd_right.color_bright);
            case 1 % left
                task.hnd.fix.color_dim  = [0 0 128];
                task.hnd.fix.color_bright  = [0 0 255];
                [task.hnd.tar.color_dim] = deal(task.hnd_left.color_dim);
                [task.hnd.tar.color_bright] = deal(task.hnd_left.color_bright);
        end
        
        task.hnd.cue(1).color_dim       = [0 128 0];
        task.hnd.cue(1).color_bright    = [0 255 0];
        task.hnd.cue(2).color_dim       = [0 128 0];
        task.hnd.cue(2).color_bright    = [0 255 0];
        
        task.eye.fix.radius = 5;
        task.eye.tar(1).radius = 5;
        task.eye.tar(2).radius = 5;
end

