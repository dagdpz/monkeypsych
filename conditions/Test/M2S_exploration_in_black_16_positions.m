%% Initiate conditions
global SETTINGS

            task.reward.time_neutral        = [0.2 0.2];    
if ~exist('dyn','var') || dyn.trialNumber == 1   
      
experiment='Match to sample saccades' ;  
%experiment='Match to sample saccades random locations';

    % Presettings (not to change here !)
    
    task.shuffle_conditions              = 1;
    task.calibration                = 0;
    %SETTINGS.GUI_in_acquisition     = 1;
    SETTINGS.check_motion_jaw       = 0;
    SETTINGS.check_motion_body      = 0;
    %PEST_ON                         = 0;
    task.rest_hand                  = [0 0]; 
    multiple_targets_per_trial      = 0;
    
    % Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
    All=struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
        'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0);
             
    switch experiment
        
        case 'Match to sample saccades'
            SETTINGS.GUI_in_acquisition     = 1;
            task.force_conditions                = 3;
            multiple_targets_per_trial      = 1; 
            
            task.correct_choice_target      = [1];
            N_repetitions                   = 2;        % 1 repetition -> 96 trials
            %task.reward.time_neutral        = [0.14 0.14];
            task.rest_hand                  = [0 0];
            
            fix_eye_y             = -2;
            fix_hnd_y             = 0;
            fix_offset            = 0;
            tar_angle             = 20; %in degrees
            pool_of_angles        = [60,0,340,160,180,200];%% 20 instead of 60 so far!
            %             tar_excentricity      = 16; %excentricity of center of target array LR
            %             tar_angle             = 20; %in degrees
            
            f_h                   = fix_eye_y;
            fix_height            = f_h;
            d_pos                 = 8;    % relative shift of target positions
            ex_cue                = 18;   % cue_excentricity
            ex_BT                 = 9;
            
            All.type_con                    = 6;
            All.effector_con                = 0;
            All.timing_con                  = 5;
            All.size_con                    = 5;
            All.color_con                   = 3; %3 !!!
            
            % CUE NUMBER
            All.instructed_choice_con       = 0; % 0 is one cue, 1 is two cues
            %All.tar_pos_con                 = 99;
            All.excentricities              = [8]; % & 20! the eccentricity is randomly chosen to be 12 or 20
            All.angle_cases                 = [1];
            All.tar_dis_con                 = [1:6]; 
            All.mat_dis_con                 = 1;      % triangle pointing randomly left or right
            All.cue_pos_con                 = 1:2;      % right and left cue
            %All.shape_con                   = [1,3,6,8,10,11,3,6,10,11];    % target and distractor distribution
            All.shape_con                   = [1:12];    % [3,6,10,11];% target and distractor distribution
            %PEST_ON=0;
            
            % THINGS TO CHANGE
            adjusted_curvature              = -1;      % change curvature here
            % TIMING
            % change timing for training: line 270
            % make red dots to cue the position: line 411
            % target size: line 300
        
        case 'Match to sample training'
            SETTINGS.GUI_in_acquisition     = 1;
            task.force_conditions                = 2;
            multiple_targets_per_trial      = 1; 
            
            task.correct_choice_target      = [1];
            N_repetitions                   = 2;        % 1 repetition -> 96 trials
            %task.reward.time_neutral        = [0.14 0.14];
            task.rest_hand                  = [0 0];
            
            fix_eye_y             = -1;
            fix_hnd_y             = 0;
            fix_offset            = 0;
            tar_angle             = 20; %in degrees
            pool_of_angles        = [60,0,340,160,180,200];%% 20 instead of 60 so far!
            %             tar_excentricity      = 16; %excentricity of center of target array LR
            %             tar_angle             = 20; %in degrees
            
            f_h                   = fix_eye_y;
            fix_height            = f_h;
            d_pos                 = 8;    % relative shift of target positions
            ex_cue                = 20;   % cue_excentricity
            %ex_BT                 = 8;
            ex_BT                 = 8;
            
            All.type_con                    = 6;
            All.effector_con                = 0;
            All.timing_con                  = 5;
            All.size_con                    = 5;
            All.color_con                   = 3; %3 !!!
            
            % CUE NUMBER
            All.instructed_choice_con       = 0; % 0 is one cue, 1 is two cues
            %All.tar_pos_con                 = 99;
            All.excentricities              = [8]; % & 20! the eccentricity is randomly chosen to be 12 or 20
            All.angle_cases                 = [1];
            All.tar_dis_con                 = [1:6]; 
            All.mat_dis_con                 = 1;      % triangle pointing randomly left or right
            All.cue_pos_con                 = 1:2;      % right and left cue
            %All.shape_con                   = [1,3,6,8,10,11,3,6,10,11];    % target and distractor distribution
            All.shape_con                   = [1:12];    % [3,6,10,11];% target and distractor distribution
            %PEST_ON=0;
            
            % THINGS TO CHANGE
            adjusted_curvature              = -1;      % change curvature here
            % TIMING
            % change timing for training: line 270
            % make red dots to cue the position: line 411
            % target size: line 300
    end
    
    all_fieldnames=fieldnames(All); 
    N_total_conditions       =1;
    sequence_cell            ={};
    for FN=1:numel(all_fieldnames)
        N_total_conditions=N_total_conditions*numel(All.(all_fieldnames{FN}));
            sequence_cell=[sequence_cell, {All.(all_fieldnames{FN})}];
    end
    sequence_matrix          = repmat(CombVec(sequence_cell{:}),1,N_repetitions);
    
    % part to continue a session that was aborted 
    SETTINGS.continue_sequence=0;
    SETTINGS.file_to_continue_sequence='C:\Users\admin\Desktop\Alex\Data\HumanM2S\20150828\MS12015-08-28_04.mat';
    if SETTINGS.continue_sequence
        load(SETTINGS.file_to_continue_sequence,'sequence_indexes')
        ordered_sequence_indexes = sequence_indexes;
    else
        ordered_sequence_indexes = 1:N_total_conditions*N_repetitions;
    end
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
        % semi-forced_2: if trial is uncompleted, the condition is put back into the pool
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
    case 1
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.12] ;
        task.microstim.end{1}       = [-0];
    case 2
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.08] ;
        task.microstim.end{1}       = [-0];
    case 3
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.04] ;
        task.microstim.end{1}       = [-0];
    case 4
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0] ;
        task.microstim.end{1}       = [0.2];
    case 5
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.04] ;
        task.microstim.end{1}       = [0.24];
    case 6
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
    case 7
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.12] ;
        task.microstim.end{1}       = [0.32];
    case 8
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.24] ;
        task.microstim.end{1}       = [0.44];
    case 9
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.CUE_ON];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
    case 10
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.MEM_PER];
        task.microstim.start{1}     = [-0.08] ;
        task.microstim.end{1}       = [0];
    case 11
        task.microstim.stim_on      = 1; 
        task.microstim.state        = [STATE.TAR_ACQ_INV];
        task.microstim.start{1}     = [0.08] ;
        task.microstim.end{1}       = [0.28];
end

%% TIMING
switch Current_con.timing_con
        
    case 5 %'Match to sample'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts        
        task.timing.wait_for_reward             = 0.5;
        task.timing.ITI_success                 = 2;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_incorrect_completed     = 3;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;        
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;        
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 10;
        task.timing.tar_inv_time_to_acquire_hnd = 10;        
        task.timing.fix_time_to_acquire_eye     = 1;
        task.timing.tar_time_to_acquire_eye     = 10;  % time to explore the black screen; 12 for the experiment
        task.timing.tar_inv_time_to_acquire_eye = 10;  
        task.timing.fix_time_hold               = 0.3; % fixation time
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 1; % cue time
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0.3;%0.3; % memory period
        task.timing.mem_time_hold_var           = 0.5;%0.5; % memory period variance
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 1; % selection time
        task.timing.tar_time_hold_var           = 0.0;
    
end

%% RADIUS & SIZES

if task.type==5 || task.type==6 
task.eye=rmfield(task.eye,'tar');
task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    
    case 5 %'match to sample'
%         task.eye.fix.size       = 0.5;
%         task.eye.fix.radius     = 5;
%         task.eye.tar(1).size    = 2;   % target size
%         task.eye.tar(1).radius  = 5;   % fixation radius    
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 4.5;
        task.eye.tar(1).size    = 2;   % target size
        task.eye.tar(1).radius  = 4.5;   % fixation radius    
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 2;
        task.hnd.tar(1).radius  = 4;

end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

%% POSITIONS
%     current_angle=pool_of_angles(Current_con.angle_cases); %
%     tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
%     tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);
%     
%     tar_dis_1x = + tar_dis_x;
%     tar_dis_1y = + tar_dis_y;
%     tar_dis_2x = - tar_dis_x;
%     tar_dis_2y = + tar_dis_y;

    % placeholder variables for all 8 positions

ex_LR = 9;
    
left_top_close  = [fix_eye_x-ex_LR,fix_eye_y+ex_BT];
left_mid_close  = [fix_eye_x-ex_LR,fix_eye_y];
left_bot_close  = [fix_eye_x-ex_LR,fix_eye_y-ex_BT];
right_top_close = [fix_eye_x+ex_LR,fix_eye_y+ex_BT];
right_mid_close = [fix_eye_x+ex_LR,fix_eye_y];
right_bot_close = [fix_eye_x+ex_LR,fix_eye_y-ex_BT];

ex_LR = 18;
    
left_top_mid  = [fix_eye_x-ex_LR,fix_eye_y+ex_BT];
left_bot_mid  = [fix_eye_x-ex_LR,fix_eye_y-ex_BT];
right_top_mid = [fix_eye_x+ex_LR,fix_eye_y+ex_BT];
right_bot_mid = [fix_eye_x+ex_LR,fix_eye_y-ex_BT];

ex_LR = 27;
    
left_top_far  = [fix_eye_x-ex_LR,fix_eye_y+ex_BT];
left_mid_far  = [fix_eye_x-ex_LR,fix_eye_y];
left_bot_far  = [fix_eye_x-ex_LR,fix_eye_y-ex_BT];
right_top_far = [fix_eye_x+ex_LR,fix_eye_y+ex_BT];
right_mid_far = [fix_eye_x+ex_LR,fix_eye_y];
right_bot_far = [fix_eye_x+ex_LR,fix_eye_y-ex_BT];

if     multiple_targets_per_trial == 1; % 18 positions for match to sample saccades(!)
        ex_LR = Current_con.excentricities;
%         All_positions_left  = Shuffle({left_top_far, left_bot_far, left_top_close, left_bot_close});
%         All_positions_right = Shuffle({right_top_far, right_bot_far, right_bot_close,right_top_close});

        All_positions_left  = Shuffle({left_top_far, left_mid_far, left_bot_far, left_top_mid, left_bot_mid, left_top_close, left_mid_close, left_bot_close});
        All_positions_right  = Shuffle({right_top_far, right_mid_far, right_bot_far, right_top_mid, right_bot_mid, right_top_close, right_mid_close, right_bot_close});
        tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;     
end  

    task.eye.fix.x    = fix_eye_x;
    task.eye.fix.y    = fix_eye_y;
    task.hnd.fix.x    = fix_hnd_x;
    task.hnd.fix.y    = fix_hnd_y;

    
%     task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
%     task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
%     task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
%     task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;    
%     
%     task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
%     task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
%     task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
%     task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
% end

%% COLORS
switch Current_con.color_con
    case 1
            tar_color=[128 0 0];
    case 2        
            tar_color=[3 0 0];
    case 3
            tar_color=[0 0 0];            
    case 4
            tar_color=[randi([0,1])*20 0 0];     
end

task.eye.fix.color_dim       = [128 0 0]; 
task.eye.fix.color_bright    = [255 0 0];
task.eye.tar(1).color_dim    = tar_color;% [0 0 0];     % [128 0 0](red)
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim    = tar_color;% [0 0 0];     % [128 0 0](red)
task.eye.tar(2).color_bright = [255 0 0];

task.hnd_right.color_dim    = [0 128 0]; 
task.hnd_right.color_bright = [0 255 0];
task.hnd_right.color_cue    = [50 80 50];
task.hnd_left.color_dim     = [39 109 216]; 
task.hnd_left.color_bright  = [119 230 253];
task.hnd_left.color_cue     = [64 77 80];
task.hnd_stay.color_dim     = [128 129 0];
task.hnd_stay.color_bright  = [255 255 0];

%% target distribution left right (for Match to sample)    
switch Current_con.tar_dis_con
    case 1 %
        N_targets_left=2;
        N_targets_right=1; 
        match_left=1;
    case 2
        N_targets_left=1;
        N_targets_right=2; 
        match_left=1;
    case 3 %
        N_targets_left=2;
        N_targets_right=1; 
        match_left=0;
    case 4 %
        N_targets_left=1;
        N_targets_right=2; 
        match_left=0;
    case 5 %
        N_targets_left=3;
        N_targets_right=0; 
        match_left=1;
    case 6
        N_targets_left=0;
        N_targets_right=3; 
        match_left=0;
end
task.n_targets=N_targets_left+N_targets_right;

%% target shapes (for Match to sample) 
%all_curv=[0.6,0.3,-0.4,-0.6];
%convex_sides=repmat({'LR'},1,task.n_targets);
% 
% all_curv=[adjusted_curvature,adjusted_curvature,adjusted_curvature,-0.2];
% all_sides={'LR','L','R','LR'};

% %all_curv=[-0.8,-0.6,-0.4,-0.2];
%all_curv=[-0.475,-0.4,0.4,0.5];
all_curv=[-0.33,-0.23,0.20,0.35];
all_sides={'LR','LR','LR','LR'};
% 
% all_curv=[-0.6,-0.4,-0.4,-0.7];
% all_sides={'LR','LR','TB','TB'};

switch Current_con.shape_con

    case 1
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(3)]);
        convex_sides=[all_sides(1),all_sides(2),all_sides(3)];
        distractor_convexity = all_curv(4);
        distractor_side = all_sides{4};        
    case 2
        task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(4)]);
        convex_sides=[all_sides(1),all_sides(2),all_sides(4)];
        distractor_convexity = all_curv(3);
        distractor_side = all_sides{3};
    case 3
        task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(3)]);
        convex_sides=[all_sides(2),all_sides(1),all_sides(3)];
        distractor_convexity = all_curv(4);
        distractor_side = all_sides{4};
    case 4
        task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(4)]);
        convex_sides=[all_sides(2),all_sides(1),all_sides(4)];
        distractor_convexity = all_curv(3);
        distractor_side = all_sides{3};
    case 5
        task.convexities=num2cell([all_curv(3),all_curv(1),all_curv(4)]);
        convex_sides=[all_sides(3),all_sides(1),all_sides(4)];
        distractor_convexity = all_curv(2);
        distractor_side = all_sides{2};
    case 6
        task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(4)]);
        convex_sides=[all_sides(3),all_sides(2),all_sides(4)];
        distractor_convexity = all_curv(1);
        distractor_side = all_sides{1};
    case 7
        task.convexities=num2cell([all_curv(4),all_curv(1),all_curv(3)]);
        convex_sides=[all_sides(4),all_sides(1),all_sides(3)];
        distractor_convexity = all_curv(2);
        distractor_side = all_sides{2};
    case 8
        task.convexities=num2cell([all_curv(4),all_curv(2),all_curv(3)]);
        convex_sides=[all_sides(4),all_sides(2),all_sides(3)];
        distractor_convexity = all_curv(1);
        distractor_side = all_sides{1};
    
     
    case 9
        task.convexities=num2cell([all_curv(1),all_curv(3),all_curv(4)]);
        convex_sides=[all_sides(1),all_sides(3),all_sides(4)];
        distractor_convexity = all_curv(2);
        distractor_side = all_sides{2};
    case 10
        task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(4)]);
        convex_sides=[all_sides(2),all_sides(3),all_sides(4)];
        distractor_convexity = all_curv(1);
        distractor_side = all_sides{1};
    case 11
        task.convexities=num2cell([all_curv(3),all_curv(1),all_curv(2)]);
        convex_sides=[all_sides(3),all_sides(1),all_sides(2)];
        distractor_convexity = all_curv(4);
        distractor_side = all_sides{4};
    case 12
        task.convexities=num2cell([all_curv(4),all_curv(1),all_curv(2)]);
        convex_sides=[all_sides(4),all_sides(1),all_sides(2)];
        distractor_convexity = all_curv(3);
        distractor_side = all_sides{3};  
 end

%% match and main distractor distribution (for Match to sample) 


% if multiple_targets_per_trial==0
%  Current_con.mat_dis_con=Current_con.mat_dis_con+(randi([0,1])*3);
% end

switch Current_con.mat_dis_con
    case 1
        %match_left=1;
    case 2
        %match_left=0;
end
% if N_targets_left==0
%     match_left=0;
% elseif N_targets_right==0
%     match_left=1;
% end


if task.type==5 || task.type==6 
    if multiple_targets_per_trial
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
        
        targets_to_assign=Shuffle(2:task.n_targets);
        for NN=2:task.n_targets %2:task.n_targets %
            n_target=targets_to_assign(NN-1); %2:task.n_targets %
            if NN+match_left-1<=N_targets_left
                task.tar_pos{n_target}=All_positions_left{n_left};
                n_left=n_left+1;
            else
                task.tar_pos{n_target}=All_positions_right{n_right};
                n_right=n_right+1;
            end
        end
    end
    % task.n_targets = 3 (all positions)
    for n_target=1:task.n_targets
        
        task.eye.tar(n_target).size         = task.eye.tar(1).size;
        task.eye.tar(n_target).radius       = task.eye.tar(1).radius;
        task.eye.tar(n_target).color_dim    = task.eye.tar(1).color_dim;
        task.eye.tar(n_target).color_bright = task.eye.tar(1).color_bright;
        
        task.eye.tar(n_target).ringColor = [];
        task.eye.tar(n_target).ringColor2 = [0 0 0];
        task.eye.tar(n_target).reward_prob = 1;
        task.eye.tar(n_target).shape.mode = 'convex';
        task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
        task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
        
        task.eye.tar(n_target).x = task.tar_pos{n_target}(1);
        task.eye.tar(n_target).y = task.tar_pos{n_target}(2);
        
        task.hnd.tar(n_target).size         = task.hnd.tar(1).size;
        task.hnd.tar(n_target).radius       = task.hnd.tar(1).radius;
        task.hnd.tar(n_target).ringColor = [];
        task.hnd.tar(n_target).ringColor2 = [0 0 0];
        task.hnd.tar(n_target).reward_prob = 1;
        task.hnd.tar(n_target).shape.mode = 'convex';
        task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
        task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
        task.hnd.tar(n_target).x = task.tar_pos{n_target}(1);
        task.hnd.tar(n_target).y = task.tar_pos{n_target}(2);
    end    
end

%% CUE assignment (Positions and colors !)
task.eye.cue=task.eye.tar;
task.eye.cue(1,2).shape.convexity   = distractor_convexity;
task.eye.cue(1,2).shape.convex_side = distractor_side;

task.hnd.cue=task.hnd.tar;
task.hnd.cue(1,2).shape.convexity   = distractor_convexity;
task.hnd.cue(1,2).shape.convex_side = distractor_side;

switch Current_con.cue_pos_con
    case 1
        task.cue_pos  = {[-ex_cue,fix_height],[ex_cue,fix_height]}; 
    case 2
        task.cue_pos  = {[ex_cue,fix_height],[-ex_cue,fix_height]};
end

if task.effector==0 || task.effector==1 || task.effector==2
    
    task.eye.cue(1).color_dim       = [128 0 0];
    task.eye.cue(1).color_bright    = [128 0 0];
    task.eye.cue(2).color_dim       = [128 0 0];
    task.eye.cue(2).color_bright    = [128 0 0];
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
    
    task.eye.cue(1).color_dim       = [128 0 0];
    task.eye.cue(1).color_bright    = [128 0 0];
    task.eye.cue(2).color_dim       = [128 0 0];
    task.eye.cue(2).color_bright    = [128 0 0];      
end

   
