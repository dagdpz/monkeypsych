% use this to override task and randomizations with custom trial conditions
% custom_trial_condition = randsample([1 2],1,true,[0.5 0.5]);


%Ordered_sequence = repmat([1:24],1,10);

%Ordered_sequence = repmat([1:2],1,10); % cue pos 1
%Ordered_sequence = repmat([13:24],1,10); % cue pos 2

%Ordered_sequence = repmat([1:6,13:18],1,10); % shape 1
%Ordered_sequence = repmat([7:12,19:24],1,10); % shape 2


N_shape_con=24;
%N_shape_con=2;

N_cue_pos=2;
N_tar_pos=4;

N_total_conditions=N_tar_pos*N_cue_pos*N_shape_con;

% Ordered_sequence = repmat([1:N_stim_conditions:N_total_conditions, 9:N_stim_conditions:N_total_conditions],1,15); % baselines
Ordered_sequence = repmat([1:N_total_conditions],1,1);
%Ordered_sequence = repmat([1,2,7,8,13,14,19,20],1,5); % LR
%Ordered_sequence = repmat([3:6,9:12,15:18,21:24],1,5); % TB

shuffle_conditions=1;
force_conditions=2;

if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence = Ordered_sequence;
elseif dyn.trialNumber == 1 && shuffle_conditions==1
    sequence = Shuffle(Ordered_sequence);
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if force_conditions==1
        if sum([trial.success])==length(sequence),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif force_conditions==2 
        if trial(end-1).success==1
            sequence=sequence(2:end);
        else
             sequence=Shuffle(sequence);
        end
        if numel(sequence)==0         
            dyn.state = STATE.CLOSE; return
        else
        custom_trial_condition = sequence(1);
        end
    else        
        if numel(trial)-1==length(sequence),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence(numel(trial));
        end
    end
else
    custom_trial_condition = sequence(1);
end

% General settings
task.type = 6;
task.effector = 0;
task.rest_hand = [0 0];
fix_height=21; %20 for eyes
ex_LR=18; %excentricity of targets LR
ex_UP=0;
ex_Down=13;
ex_cue=15;

%Sizes
eyefixationradius = 4;
eyetargetradius   = 5;
hndfixationradius = 3;
hndtargetradius   = 4;

task.reward.time_neutral     = [0.6 0.6];
task.n_targets=4;
        
task.choice = 0;
task.reward_modulation=0;       
task.small_reward=0;

task.vd = 32; % cm
task.calibration = 0;
task.force_target_location = 0;
task.extra_reward = 0;

% Reward
task.reward.time_small       = [0.03 0.03];
task.reward.time_large       = [0.03 0.03];

% Timing

task.rest_sensors_ini_time = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts

task.timing.wait_for_reward = 0.2;
task.timing.ITI_success     = 0.3;
task.timing.ITI_success_var = 0;
task.timing.ITI_fail        = 1;
task.timing.ITI_fail_var    = 0;

task.timing.grace_time_eye = 0;
task.timing.grace_time_hand = 0;

task.timing.fix_time_to_acquire_hnd     = 1.5;
task.timing.tar_time_to_acquire_hnd     = 4;
task.timing.tar_inv_time_to_acquire_hnd = 4;

task.timing.fix_time_to_acquire_eye     = 1;
task.timing.tar_inv_time_to_acquire_eye = 4; %3
task.timing.tar_time_to_acquire_eye     = 10;

task.timing.del_time_hold           = 0;
task.timing.del_time_hold_var       = 0;

task.timing.fix_time_hold           = 0.2;
task.timing.fix_time_hold_var       = 0.2;
task.timing.cue_time_hold           = 0.5;
task.timing.cue_time_hold_var       = 0;
task.timing.mem_time_hold           = 0; 
task.timing.mem_time_hold_var       = 0; 
task.timing.tar_inv_time_hold       = 0;
task.timing.tar_inv_time_hold_var   = 0;
task.timing.tar_time_hold           = 0.5;
task.timing.tar_time_hold_var       = 0.0;



% Colors
task.eye.fix.color_dim       = [128 0 0]; %
task.eye.fix.color_bright    = [255 0 0];
task.eye.tar(1).color_dim    = [128 0 0];  % 2.5 or 3
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim    = [128 0 0]; %  % 2.5 or 3
task.eye.tar(2).color_bright = [255 0 0];

task.hnd_right.color_dim    = [0 128 0]; %
task.hnd_right.color_bright = [0 255 0];
task.hnd_left.color_dim     = [39 109 216]; %
task.hnd_left.color_bright  = [119 230 253];
task.hnd_stay.color_dim     = [128 129 0];
task.hnd_stay.color_bright  = [255 255 0];

if ismember(custom_trial_condition,[1:N_tar_pos:N_total_conditions])
    task.tar_pos = {[-ex_LR,fix_height-ex_Down],  [-ex_LR,fix_height+ex_UP],  [ex_LR,fix_height-ex_Down],   [ex_LR,fix_height+ex_UP]};
elseif ismember(custom_trial_condition,[2:N_tar_pos:N_total_conditions])
    task.tar_pos = {[-ex_LR,fix_height+ex_UP],  [-ex_LR,fix_height-ex_Down],	[ex_LR,fix_height-ex_Down],   [ex_LR,fix_height+ex_UP]};
elseif ismember(custom_trial_condition,[3:N_tar_pos:N_total_conditions])
    task.tar_pos = {[ex_LR,fix_height-ex_Down],   [ex_LR,fix_height+ex_UP],	[-ex_LR,fix_height-ex_Down],  [-ex_LR,fix_height+ex_UP]};
elseif ismember(custom_trial_condition,[4:N_tar_pos:N_total_conditions])
    task.tar_pos = {[ex_LR,fix_height+ex_UP],   [ex_LR,fix_height-ex_Down],   [-ex_LR,fix_height-ex_Down],  [-ex_LR,fix_height+ex_UP]};
end

% switch custom_trial_condition
%     case num2cell([1:N_tar_pos:N_total_conditions])
%         %task.tar_pos = {[-10,fix_height],[10,fix_height]};
%         task.tar_pos = {[-ex_LR,fix_height],[ex_LR,fix_height]};
%     case num2cell([2:N_tar_pos:N_total_conditions])
%         %task.tar_pos = {[10,fix_height],[-10,fix_height]};
%         task.tar_pos = {[ex_LR,fix_height],[-ex_LR,fix_height]};
%     case num2cell([3:N_tar_pos:N_total_conditions]) 
%         task.tar_pos = {[-ex_LR,fix_height-ex_UD],[-ex_LR,fix_height+ex_UD]};
%     case num2cell([4:N_tar_pos:N_total_conditions])
%         task.tar_pos = {[-ex_LR,fix_height+ex_UD],[-ex_LR,fix_height-ex_UD]};
%     case num2cell([5:N_tar_pos:N_total_conditions])
%         task.tar_pos = {[ex_LR,fix_height-ex_UD],[ex_LR,fix_height+ex_UD]};
%     case num2cell([6:N_tar_pos:N_total_conditions])
%         task.tar_pos = {[ex_LR,fix_height+ex_UD],[ex_LR,fix_height-ex_UD]};
% %     case {3,9,15,21} 
% %         task.tar_pos = {[-ex_LR*2,fix_height],[-ex_LR,fix_height]};
% %     case {4,10,16,22}
% %         task.tar_pos = {[-ex_LR*2,fix_height],[-ex_LR,fix_height]};
% %     case {5,11,17,23}
% %         task.tar_pos = {[ex_LR,fix_height],[ex_LR*2,fix_height]};
% %     case {6,12,18,24} 
% %         task.tar_pos = {[ex_LR*2,fix_height],[ex_LR,fix_height]};
% end
% if ismember(custom_trial_condition,[1:12])
%    task.cue_pos  = {[-ex_cue,fix_height],[ex_cue,fix_height]}; 
% elseif ismember(custom_trial_condition,[13:24])
%    task.cue_pos  = {[ex_cue,fix_height],[-ex_cue,fix_height]};   
% end
% task.cue_pos  = {[0,fix_height],[0,fix_height]}; 


if ismember(custom_trial_condition,[(0*N_total_conditions/N_cue_pos+1):(N_total_conditions/N_cue_pos)])
   task.cue_pos  = {[-ex_cue,fix_height],[ex_cue,fix_height]}; 
elseif ismember(custom_trial_condition,[(1*N_total_conditions/N_cue_pos+1):(2*N_total_conditions/N_cue_pos)])
   task.cue_pos  = {[ex_cue,fix_height],[-ex_cue,fix_height]};   
end


    convex_sides={'LR','LR','LR','LR'};
    
    conv1=0.3;
    conv2=0.6;
    conc1=-0.3;
    conc2=-0.6;
    
    
if ismember(custom_trial_condition,     [(0*N_tar_pos+1):1*N_tar_pos,((N_shape_con+0)*N_tar_pos+1):((N_shape_con+1)*N_tar_pos)])
    task.convexities={conc2,conc1,conv1,conv2};
elseif ismember(custom_trial_condition, [(1*N_tar_pos+1):2*N_tar_pos,((N_shape_con+1)*N_tar_pos+1):((N_shape_con+2)*N_tar_pos)])
    task.convexities={conc2,conc1,conv2,conv1};
elseif ismember(custom_trial_condition, [(2*N_tar_pos+1):3*N_tar_pos,((N_shape_con+2)*N_tar_pos+1):((N_shape_con+3)*N_tar_pos)])
    task.convexities={conc2,conv1,conc1,conv2};
elseif ismember(custom_trial_condition, [(3*N_tar_pos+1):4*N_tar_pos,((N_shape_con+3)*N_tar_pos+1):((N_shape_con+4)*N_tar_pos)])
    task.convexities={conc2,conv1,conv2,conc1};
elseif ismember(custom_trial_condition, [(4*N_tar_pos+1):5*N_tar_pos,((N_shape_con+4)*N_tar_pos+1):((N_shape_con+5)*N_tar_pos)])
    task.convexities={conc2,conv2,conc1,conv1};
elseif ismember(custom_trial_condition, [(5*N_tar_pos+1):6*N_tar_pos,((N_shape_con+5)*N_tar_pos+1):((N_shape_con+6)*N_tar_pos)])
    task.convexities={conc2,conv2,conv1,conc1};
elseif ismember(custom_trial_condition, [(6*N_tar_pos+1):7*N_tar_pos,((N_shape_con+6)*N_tar_pos+1):((N_shape_con+7)*N_tar_pos)])
    task.convexities={conc1,conc2,conv1,conv2};
elseif ismember(custom_trial_condition, [(7*N_tar_pos+1):8*N_tar_pos,((N_shape_con+7)*N_tar_pos+1):((N_shape_con+8)*N_tar_pos)])
    task.convexities={conc1,conc2,conv2,conv1};
elseif ismember(custom_trial_condition, [(8*N_tar_pos+1):9*N_tar_pos,((N_shape_con+8)*N_tar_pos+1):((N_shape_con+9)*N_tar_pos)])
    task.convexities={conc1,conv1,conc2,conv2};
elseif ismember(custom_trial_condition, [(9*N_tar_pos+1):10*N_tar_pos,((N_shape_con+9)*N_tar_pos+1):((N_shape_con+10)*N_tar_pos)])
    task.convexities={conc1,conv1,conv2,conc2};
elseif ismember(custom_trial_condition, [(10*N_tar_pos+1):11*N_tar_pos,((N_shape_con+10)*N_tar_pos+1):((N_shape_con+11)*N_tar_pos)])
    task.convexities={conc1,conv2,conc2,conv1};
elseif ismember(custom_trial_condition, [(11*N_tar_pos+1):12*N_tar_pos,((N_shape_con+11)*N_tar_pos+1):((N_shape_con+12)*N_tar_pos)])
    task.convexities={conc1,conv2,conv1,conc2};
elseif ismember(custom_trial_condition, [(12*N_tar_pos+1):13*N_tar_pos,((N_shape_con+12)*N_tar_pos+1):((N_shape_con+13)*N_tar_pos)])
    task.convexities={conv1,conc2,conc1,conv2};
elseif ismember(custom_trial_condition, [(13*N_tar_pos+1):14*N_tar_pos,((N_shape_con+13)*N_tar_pos+1):((N_shape_con+14)*N_tar_pos)])
    task.convexities={conv1,conc2,conv2,conc1};
elseif ismember(custom_trial_condition, [(14*N_tar_pos+1):15*N_tar_pos,((N_shape_con+14)*N_tar_pos+1):((N_shape_con+15)*N_tar_pos)])
    task.convexities={conv1,conc1,conc2,conv2};
elseif ismember(custom_trial_condition, [(15*N_tar_pos+1):16*N_tar_pos,((N_shape_con+15)*N_tar_pos+1):((N_shape_con+16)*N_tar_pos)])
    task.convexities={conv1,conc1,conv2,conc2};
elseif ismember(custom_trial_condition, [(16*N_tar_pos+1):17*N_tar_pos,((N_shape_con+16)*N_tar_pos+1):((N_shape_con+17)*N_tar_pos)])
    task.convexities={conv1,conv2,conc2,conc1};
elseif ismember(custom_trial_condition, [(17*N_tar_pos+1):18*N_tar_pos,((N_shape_con+17)*N_tar_pos+1):((N_shape_con+18)*N_tar_pos)])
    task.convexities={conv1,conv2,conc1,conc2};
elseif ismember(custom_trial_condition, [(18*N_tar_pos+1):19*N_tar_pos,((N_shape_con+18)*N_tar_pos+1):((N_shape_con+19)*N_tar_pos)])
    task.convexities={conv2,conc2,conc1,conv1};
elseif ismember(custom_trial_condition, [(19*N_tar_pos+1):20*N_tar_pos,((N_shape_con+19)*N_tar_pos+1):((N_shape_con+20)*N_tar_pos)])
    task.convexities={conv2,conc2,conv1,conc1};
elseif ismember(custom_trial_condition, [(20*N_tar_pos+1):21*N_tar_pos,((N_shape_con+20)*N_tar_pos+1):((N_shape_con+21)*N_tar_pos)])
    task.convexities={conv2,conc1,conc2,conv1};
elseif ismember(custom_trial_condition, [(21*N_tar_pos+1):22*N_tar_pos,((N_shape_con+21)*N_tar_pos+1):((N_shape_con+22)*N_tar_pos)])
    task.convexities={conv2,conc1,conv1,conc2};
elseif ismember(custom_trial_condition, [(22*N_tar_pos+1):23*N_tar_pos,((N_shape_con+22)*N_tar_pos+1):((N_shape_con+23)*N_tar_pos)])
    task.convexities={conv2,conv1,conc2,conc1};
elseif ismember(custom_trial_condition, [(23*N_tar_pos+1):24*N_tar_pos,((N_shape_con+23)*N_tar_pos+1):((N_shape_con+24)*N_tar_pos)])
    task.convexities={conv2,conv1,conc1,conc2};    
end







% 
% if ismember(custom_trial_condition,[1:6,13:18])
%     task.convexities={0.45,0.8};
%     convex_sides={'LR','LR'};
% elseif ismember(custom_trial_condition,[7:12,19:24])
%     task.convexities={0.8,0.45};
%     convex_sides={'LR','LR'};
% end


task.eye.fix.size   = 0.5; % deg
task.eye.fix.radius = eyefixationradius; % deg
task.hnd.fix.size   = hndfixationradius; % deg
task.hnd.fix.radius = hndfixationradius; % deg
task.eye.fix.x      = 0; 
task.eye.fix.y      = fix_height; 
task.hnd.fix.x      = 0; 
task.hnd.fix.y      = fix_height; 
            


    for n_target=1:task.n_targets
        task.eye.tar(n_target).size=2.5;
        task.eye.tar(n_target).radius=eyetargetradius;
        task.hnd.tar(n_target).size=2.5;
        task.hnd.tar(n_target).radius=hndtargetradius;
        task.eye.tar(n_target).color_dim = [128 50 50];
        task.eye.tar(n_target).color_bright = [255 0 0];
        
        task.eye.tar(n_target).ringColor = [];
        task.eye.tar(n_target).ringColor2 = [0 0 0];
        task.eye.tar(n_target).reward_prob = 1;
        task.eye.tar(n_target).shape.mode = 'convex';
        task.eye.tar(n_target).shape.convexity = task.convexities{n_target};
        task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor = [];
        task.hnd.tar(n_target).ringColor2 = [0 0 0];
        task.hnd.tar(n_target).reward_prob = 1;
        task.hnd.tar(n_target).shape.mode = 'convex';
        task.hnd.tar(n_target).shape.convexity = task.convexities{n_target};
        task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x = task.tar_pos{n_target}(1);
        task.eye.tar(n_target).y = task.tar_pos{n_target}(2);
        task.hnd.tar(n_target).x = task.tar_pos{n_target}(1);
        task.hnd.tar(n_target).y = task.tar_pos{n_target}(2);
        
    end

    


    
task.eye.cue = task.eye.tar;
task.hnd.cue = task.hnd.tar;

% Assigning cue positions and colors
task.eye.cue(1) = task.eye.tar(1);
task.eye.cue(2) = task.eye.tar(2);
task.hnd.cue(1) = task.hnd.tar(1);
task.hnd.cue(2) = task.hnd.tar(2);

task.eye.cue(1).x    = task.cue_pos{1}(1);
task.eye.cue(1).y    = task.cue_pos{1}(2);
task.eye.cue(2).x    = task.cue_pos{2}(1);
task.eye.cue(2).y    = task.cue_pos{2}(2);

task.hnd.cue(1).x    = task.cue_pos{1}(1);
task.hnd.cue(1).y    = task.cue_pos{1}(2);
task.hnd.cue(2).x    = task.cue_pos{2}(1);
task.hnd.cue(2).y    = task.cue_pos{2}(2);

% task.eye.cue(1).color_dim       = [80 50 50];
% task.eye.cue(1).color_bright    = [80 50 50];
% task.eye.cue(2).color_dim       = [80 50 50];
% task.eye.cue(2).color_bright    = [80 50 50]; 

task.eye.cue(1).color_dim       = [128 50 50];
task.eye.cue(1).color_bright    = [128 50 50];
task.eye.cue(2).color_dim       = [128 50 50];
task.eye.cue(2).color_bright    = [128 50 50];


%task.hnd_right.color_cue = [50 80 50];
%task.hnd_left.color_cue = [64 77 80];
%task.hnd_right.color_cue = [0 128 0]; %
%task.hnd_left.color_cue = [39 109 216]; %


