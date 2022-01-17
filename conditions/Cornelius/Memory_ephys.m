%% Initiate conditions
global SETTINGS
    
    
if ~exist('dyn','var') || dyn.trialNumber == 1   

experiment='Memory saccades_training';     
%experiment='Memory saccades';    
    
    % Presettings (not to change here !)
    
    task.shuffle_conditions              = 1;
    task.calibration                = 0;
    %SETTINGS.GUI_in_acquisition     = 1;
    SETTINGS.check_motion_jaw       = 0;
    SETTINGS.check_motion_body      = 0;
    PEST_ON                         = 0;
    task.rest_hand                  = [0 0]; 
    multiple_targets_per_trial      = 0;
    
    
    % Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
    All=struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
        'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0);
             
    switch experiment 
                      
        case 'Memory saccades'
            SETTINGS.check_motion_jaw       = 0;                
            task.force_conditions                = 2;            
            N_repetitions                   = 10;
            task.reward.time_neutral        = [0.06 0.06]; % 0.6s -> 0.2ml per hit
            task.rest_hand                  = [0 0];             
            
            fix_eye_y                       = 0;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            %pool_of_angles                  =[20,0,340,200,180,160]; 
            
            pool_of_angles              =[20,0,340,270,90,160,180,200]; 
            
            All.type_con                    = 3; 
            All.effector_con                = 0;
            All.timing_con                  = 31;
            All.size_con                    = 3;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [12,24];   
            %All.excentricities              = [12];   
            %All.angle_cases                 = [1,2,3,4,5,6]; 
            All.angle_cases                 = [1,2,3,6,7,8];   
            All.stim_con                    = [0];    
            
        case 'Memory saccades_training'
            SETTINGS.check_motion_jaw       = 0;                
            task.force_conditions                = 1;            
            N_repetitions                   = 20;
            task.reward.time_neutral        = [0.06 0.06]; % 0.6s -> 0.2ml per hit
            task.rest_hand                  = [0 0];             
            
            fix_eye_y                       = 0;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            %pool_of_angles                  =[20,0,340,200,180,160]; 
            
            pool_of_angles                  =[20,0,340,270,90,160,180,200]; 
            
            All.type_con                    = 3; 
            All.effector_con                = 0;
            All.timing_con                  = 31;
            All.size_con                    = 32;
            All.instructed_choice_con       = [0];
            All.excentricities              = [12,24];   
            %All.excentricities              = [12];   
            %All.angle_cases                 = [1,2,3,4,5,6]; 
            All.angle_cases                 = [1,2,3,6,7,8];   
            All.stim_con                    = [0];    
            
    end
    
    all_fieldnames=fieldnames(All);
    N_total_conditions       =1;
    sequence_cell            ={};
    for FN=1:numel(all_fieldnames)
        N_total_conditions=N_total_conditions*numel(All.(all_fieldnames{FN}));
            sequence_cell=[sequence_cell, {All.(all_fieldnames{FN})}];
    end
    sequence_matrix          = repmat(combvec(sequence_cell{:}),1,N_repetitions);
    ordered_sequence_indexes = 1:N_total_conditions*N_repetitions;
end



fix_eye_x             = fix_offset;
fix_hnd_x             = fix_eye_x;

%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && task.shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (task.shuffle_conditions==1 || task.shuffle_conditions==2)
    sequence_indexes = Shuffle(ordered_sequence_indexes);    
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if task.force_conditions==1
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif task.force_conditions==2 
        if trial(end-1).success==1
            sequence_indexes=sequence_indexes(2:end);
        else
             sequence_indexes=Shuffle(sequence_indexes);
        end
        if numel(sequence_indexes)==0         
            dyn.state = STATE.CLOSE; return
        else
        custom_trial_condition = sequence_indexes(1);
        end
    elseif task.force_conditions==3 
        if trial(end-1).completed==1
            sequence_indexes=sequence_indexes(2:end);
        else
             sequence_indexes=Shuffle(sequence_indexes);
        end
        if numel(sequence_indexes)==0         
            dyn.state = STATE.CLOSE; return
        else
        custom_trial_condition = sequence_indexes(1);
        end
    else        
        if numel(trial)-1==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(numel(trial));
        end
    end
else
    custom_trial_condition = sequence_indexes(1);
end

%dyn.trial_classifier(1)=numel(All.tar_pos_con);
for field_index=1:numel(all_fieldnames)
    Current_con.(all_fieldnames{field_index})=sequence_matrix(field_index,custom_trial_condition);
    %dyn.trial_classifier(field_index+1) = Current_con.(all_fieldnames{field_index});
    dyn.trial_classifier(field_index) = abs(round(Current_con.(all_fieldnames{field_index})));
end

%% CHOICE\INSTRUCTED
task.choice                 = Current_con.instructed_choice_con;

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con; 

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;

%% STIMULATION timing
switch Current_con.stim_con
    case 0
        task.microstim.stim_on      = 0;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0] ;
        task.microstim.end{1}       = [0];
end

%% TIMING
switch Current_con.timing_con
    case 31 %'memory ephys'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.4;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.5;
        task.timing.fix_time_hold_var           = 0.0;
        task.timing.cue_time_hold               = 0.28;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0.5;
        task.timing.mem_time_hold_var           = 0.5;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.3;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 32 %'memory learning'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;
        task.timing.fix_time_to_acquire_hnd     = 1;
        task.timing.tar_time_to_acquire_hnd     = 1.5;
        task.timing.tar_inv_time_to_acquire_hnd = 2;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.3;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.2;
        task.timing.cue_time_hold_var           = 0.08;
        task.timing.mem_time_hold               = 0.5;
        task.timing.mem_time_hold_var           = 0.5;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
          
        
end

%% RADIUS & SIZES

if task.type==5 || task.type==6 
task.eye=rmfield(task.eye,'tar');
task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    case 3 %'memory'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 5;
        task.hnd.tar(1).size    = 5;
        task.hnd.tar(1).radius  = 5;
        
    case 32 %'memory learning'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 3;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 4;        
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 5;
        task.hnd.tar(1).size    = 5;
        task.hnd.tar(1).radius  = 5;
end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

%% POSITIONS
    current_angle=pool_of_angles(Current_con.angle_cases); %
    tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
    tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);
    
    tar_dis_1x = + tar_dis_x;
    tar_dis_1y = + tar_dis_y;
    tar_dis_2x = - tar_dis_x;
    tar_dis_2y = + tar_dis_y;
  
if task.type==1
    
    task.eye.fix.x    = fix_eye_x  + tar_dis_1x;
    task.eye.fix.y    = fix_eye_y  + tar_dis_1y;
    task.hnd.fix.x    = fix_hnd_x  + tar_dis_1x;
    task.hnd.fix.y    = fix_hnd_y  + tar_dis_1y;
else
    
    task.eye.fix.x    = fix_eye_x;
    task.eye.fix.y    = fix_eye_y;
    task.hnd.fix.x    = fix_hnd_x;
    task.hnd.fix.y    = fix_hnd_y;
end

if task.effector==3
    
    task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
    task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
    task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
    task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;    
    
    task.hnd.tar(1).x = fix_hnd_x;
    task.hnd.tar(1).y = fix_hnd_y;
    task.hnd.tar(2).x = fix_hnd_x;
    task.hnd.tar(2).y = fix_hnd_y;
elseif task.effector==4 || task.effector==6
    
    task.eye.tar(1).x = fix_eye_x;
    task.eye.tar(1).y = fix_eye_y;
    task.eye.tar(2).x = fix_eye_x;
    task.eye.tar(2).y = fix_eye_y;    
    
    task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
    task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
    task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
    task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
else
    
    task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
    task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
    task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
    task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;    
    
    task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
    task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
    task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
    task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
end


if strcmp(experiment,'vpx_calibration')
    [x,y]=vpx_GetCalibrationStimulusPoint(Current_con.angle_cases);
    x_pix=x*SETTINGS.screenSize(3);
    y_pix=y*SETTINGS.screenSize(4);
    [x_deg, y_deg] = pix2deg_xy(x_pix, y_pix);
    
    task.eye.tar(1).x = x_deg;
    task.eye.tar(1).y = y_deg;
    task.eye.tar(2).x = x_deg;
    task.eye.tar(2).y = y_deg;    
    
    task.hnd.tar(1).x = x_deg;
    task.hnd.tar(1).y = y_deg;
    task.hnd.tar(2).x = x_deg;
    task.hnd.tar(2).y = y_deg;    
    
    task.eye.fix.x    = x_deg;
    task.eye.fix.y    = y_deg;
    task.hnd.fix.x    = x_deg;
    task.hnd.fix.y    = y_deg;
    
    trial(dyn.trialNumber).vpx_calibration_point=Current_con.angle_cases;
else
    
    trial(dyn.trialNumber).vpx_calibration_point=0;
end

%% COLORS
task.eye.fix.color_dim       = [128 0 0]; %
task.eye.fix.color_bright    = [255 0 0];
task.eye.tar(1).color_dim    = [128 0 0];  % 2.5 or 3
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim    = [128 0 0]; %  % 2.5 or 3
task.eye.tar(2).color_bright = [255 0 0];

task.hnd_right.color_dim    = [0 128 0]; %
task.hnd_right.color_bright = [0 255 0];
task.hnd_right.color_cue    = [50 80 50];
task.hnd_left.color_dim     = [39 109 216]; %
task.hnd_left.color_bright  = [119 230 253];
task.hnd_left.color_cue     = [64 77 80];
task.hnd_stay.color_dim     = [128 129 0];
task.hnd_stay.color_bright  = [255 255 0];

%% target distribution left right (for Match to sample)    
switch Current_con.tar_dis_con
    case 0
        N_targets_left=1;N_targets_right=1; % for non-m2s-tasks
    case 1
        N_targets_left=2;N_targets_right=7;
    case 2
        N_targets_left=7;N_targets_right=2;
    case 3
        N_targets_left=3;N_targets_right=6;
    case 4
        N_targets_left=6;N_targets_right=3;
    case 5 
        N_targets_left=4;N_targets_right=5;
    case 6
        N_targets_left=5;N_targets_right=4;  
    case 7 
        N_targets_left=2;N_targets_right=2;
    case 8 
        N_targets_left=3;N_targets_right=2;
    case 9
        N_targets_left=2;N_targets_right=3;  
    case 10 
        N_targets_left=2;N_targets_right=5;
    case 11 
        N_targets_left=5;N_targets_right=2;
    case 12 
        N_targets_left=3;N_targets_right=4;
    case 13 
        N_targets_left=4;N_targets_right=3;
    case 14 
        N_targets_left=1;N_targets_right=2;
    case 15 
        N_targets_left=2;N_targets_right=1;
end
task.n_targets=N_targets_left+N_targets_right;

%% target shapes (for Match to sample) 
%all_curv=[0.6,0.3,-0.4,-0.6];
all_curv=[-0.9,-0.9,-0.9,-0.2];
convex_sides=repmat({'LR'},1,task.n_targets);
all_sides={'LR','L','R','LR'};
switch Current_con.shape_con
    case 1
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
    case 2
        task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(randi([3,4],[1,task.n_targets-2]))]);
    case 3
        task.convexities=num2cell([all_curv(3),all_curv(4),all_curv(randi([1,2],[1,task.n_targets-2]))]);
    case 4
        task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
    case 5 % fro cornz learning
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(3),repmat(all_curv(4),1,task.n_targets-3)]);
        convex_sides=[all_sides(1),all_sides(2),all_sides(3),repmat(all_sides(4),1,task.n_targets-3)];
    case 6
        task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(4),repmat(all_curv(3),1,task.n_targets-3)]);
        convex_sides=[all_sides(2),all_sides(1),all_sides(4),repmat(all_sides(3),1,task.n_targets-3)];
    case 7 % fro cornz learning
        task.convexities=num2cell([all_curv(3),all_curv(4),all_curv(1),repmat(all_curv(2),1,task.n_targets-3)]);
        convex_sides=[all_sides(3),all_sides(4),all_sides(1),repmat(all_sides(2),1,task.n_targets-3)];
    case 8
        task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(2),repmat(all_curv(1),1,task.n_targets-3)]);
        convex_sides=[all_sides(4),all_sides(3),all_sides(2),repmat(all_sides(1),1,task.n_targets-3)];
        
    case 9 % fro cornz learning
        task.convexities=num2cell([all_curv(1),all_curv(4),all_curv(3),repmat(all_curv(1),1,task.n_targets-3)]);
        convex_sides=[all_sides(1),all_sides(4),all_sides(3),repmat(all_sides(2),1,task.n_targets-3)];
    case 10
        task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(4),repmat(all_curv(1),1,task.n_targets-3)]);
        convex_sides=[all_sides(2),all_sides(3),all_sides(4),repmat(all_sides(1),1,task.n_targets-3)];
    case 11 % fro cornz learning
        task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(1),repmat(all_curv(4),1,task.n_targets-3)]);
        convex_sides=[all_sides(3),all_sides(2),all_sides(1),repmat(all_sides(4),1,task.n_targets-3)];
    case 12
        task.convexities=num2cell([all_curv(4),all_curv(1),all_curv(2),repmat(all_curv(3),1,task.n_targets-3)]);
        convex_sides=[all_sides(4),all_sides(1),all_sides(2),repmat(all_sides(3),1,task.n_targets-3)];
%     case 5 % fro cornz learning
%         task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
%     case 6
%         task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
%     case 7 % fro cornz learning
%         task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(3),all_curv(3),all_curv(randi([3,4],[1,task.n_targets-4]))]);
%     case 8
%         task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(2),all_curv(2),all_curv(randi([1,2],[1,task.n_targets-4]))]);
%     case 9 % fro cornz learning
%         task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(1),all_curv(4)]);
%     case 10
%         task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(4),all_curv(1)]);
end

%% match and main distractor distribution (for Match to sample) 
switch Current_con.mat_dis_con
    case 1
        match_left=1; distractor_left=1;
    case 2
        match_left=1; distractor_left=0;
    case 3
        match_left=0; distractor_left=1;
    case 4
        match_left=0; distractor_left=0;    
end

if task.type==5 || task.type==6 
    if isfield(task,'tar_pos')
    rmfield(task,'tar_pos');
    end
    n_left=1;
    n_right=1;
    if match_left
        task.tar_pos{1}=All_positions_left{n_left};
        n_left=n_left+1;
    else
        task.tar_pos{1}=All_positions_right{n_right};
        n_right=n_right+1;
    end
    if distractor_left
        task.tar_pos{2}=All_positions_left{n_left};
        n_left=n_left+1;
    else
        task.tar_pos{2}=All_positions_right{n_right};
        n_right=n_right+1;
    end
    for n_target=3:task.n_targets
        if n_target+match_left+distractor_left-2<=N_targets_left
            task.tar_pos{n_target}=All_positions_left{n_left};
        n_left=n_left+1;
        else
            task.tar_pos{n_target}=All_positions_right{n_right};
        n_right=n_right+1;
        end
    end
   
    
    for n_target=1:task.n_targets
        task.eye.tar(n_target).size         = task.eye.tar(1).size;
        task.eye.tar(n_target).radius       = task.eye.tar(1).radius;
        task.hnd.tar(n_target).size         = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius       = task.hnd.tar(1).radius;
        task.eye.tar(n_target).color_dim    = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor = [];
        task.eye.tar(n_target).ringColor2 = [0 0 0];
        task.eye.tar(n_target).reward_prob = 1;
        task.eye.tar(n_target).shape.mode = 'convex';
        task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
        task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor = [];
        task.hnd.tar(n_target).ringColor2 = [0 0 0];
        task.hnd.tar(n_target).reward_prob = 1;
        task.hnd.tar(n_target).shape.mode = 'convex';
        task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
        task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x = task.tar_pos{n_target}(1);
        task.eye.tar(n_target).y = task.tar_pos{n_target}(2);
        task.hnd.tar(n_target).x = task.tar_pos{n_target}(1);
        task.hnd.tar(n_target).y = task.tar_pos{n_target}(2);
        
    end    
end

if task.type==8 
    task.n_targets=size(All_positions,1);
    
    for n_target=1:task.n_targets
        task.eye.tar(n_target).size         = task.eye.tar(1).size;
        task.eye.tar(n_target).radius       = task.eye.tar(1).radius;
        task.hnd.tar(n_target).size         = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius       = task.hnd.tar(1).radius;
        task.eye.tar(n_target).color_dim    = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor = [];
        task.eye.tar(n_target).ringColor2 = [0 0 0];
        task.eye.tar(n_target).reward_prob = 1;
         task.eye.tar(n_target).shape = 'circle';
        %         task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
        %         task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.hnd.tar(n_target).ringColor = [];
        task.hnd.tar(n_target).ringColor2 = [0 0 0];
        task.hnd.tar(n_target).reward_prob = 1;
        task.hnd.tar(n_target).shape = 'circle';
        %         task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
        %         task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x = All_positions{n_target}(1);
        task.eye.tar(n_target).y = All_positions{n_target}(2);
        task.hnd.tar(n_target).x = All_positions{n_target}(1);
        task.hnd.tar(n_target).y = All_positions{n_target}(2);
        
    end
end

%% CUE assignment (Positions and colors !)
task.eye.cue=task.eye.tar;
task.hnd.cue=task.hnd.tar;

switch Current_con.cue_pos_con
    case 1
        task.cue_pos  = {[-ex_cue,fix_height],[ex_cue,fix_height]}; 
    case 2
        task.cue_pos  = {[ex_cue,fix_height],[-ex_cue,fix_height]};
end

if task.effector==0 || task.effector==1 || task.effector==2
    task.eye.cue(1).color_dim       = [80 50 50];
    task.eye.cue(1).color_bright    = [80 50 50];
    task.eye.cue(2).color_dim       = [80 50 50];
    task.eye.cue(2).color_bright    = [80 50 50];
%         task.eye.cue(1).color_dim       = [128 0 0];
%         task.eye.cue(1).color_bright    = [128 0 0];
%         task.eye.cue(2).color_dim       = [128 0 0];
%         task.eye.cue(2).color_bright    = [128 0 0];
    
end

if task.type==5 || task.type==6 % match to sample... cue positions and colors differ from targets
    
    task.eye.cue(1).x    = task.cue_pos{1}(1);
    task.eye.cue(1).y    = task.cue_pos{1}(2);
    task.eye.cue(2).x    = task.cue_pos{2}(1);
    task.eye.cue(2).y    = task.cue_pos{2}(2);
    
    task.hnd.cue(1).x    = task.cue_pos{1}(1);
    task.hnd.cue(1).y    = task.cue_pos{1}(2);
    task.hnd.cue(2).x    = task.cue_pos{2}(1);
    task.hnd.cue(2).y    = task.cue_pos{2}(2);
    
%     task.eye.cue(1).color_dim       = [128 50 50];
%     task.eye.cue(1).color_bright    = [128 50 50];
%     task.eye.cue(2).color_dim       = [128 50 50];
%     task.eye.cue(2).color_bright    = [128 50 50];   
    
    task.eye.cue(1).color_dim       = [128 0 0];
    task.eye.cue(1).color_bright    = [128 0 0];
    task.eye.cue(2).color_dim       = [128 0 0];
    task.eye.cue(2).color_bright    = [128 0 0];      
end


