%% Initiate conditions
global SETTINGS
    
if ~exist('dyn','var') || dyn.trialNumber == 1   
      
experiment='Match to sample saccades' ;    

    % Presettings (not to change here !)
    
    shuffle_conditions              = 1;
    task.calibration                = 0;
    SETTINGS.GUI_in_acquisition     = 0;
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
            force_conditions                = 3;
            multiple_targets_per_trial      = 0;
            
            target_color                    = [128 0 0];% [0 0 0]
            N_repetitions                   = 1;        % 1 repetition -> 96 trials
            task.reward.time_neutral        = [0.0 0.0];
            task.rest_hand                  = [0 0];
            
            fix_eye_y             = 0;
            fix_hnd_y             = 16;
            fix_offset            = 0;
            tar_angle             = 20; %in degrees
            pool_of_angles        = [20,0,340,160,180,200];
            %             tar_excentricity      = 16; %excentricity of center of target array LR
            %             tar_angle             = 20; %in degrees
            
            f_h                   = fix_eye_y;
            fix_height            = f_h;
            d_pos                 = 8;    % relative shift of target positions
            ex_cue                = 15;   % cue_excentricity
            
            
            All.type_con                    = 6;
            All.effector_con                = 0;
            All.timing_con                  = 5;
            All.size_con                    = 5;
            All.instructed_choice_con       = 1; % 1 is two cues, 0 is one cue
            %All.tar_pos_con                 = 99;
            All.excentricities              = [10];
            All.angle_cases                 = [1];
            All.tar_dis_con                 = 0; 
            All.mat_dis_con                 = 1:6;      % triangle pointing randomly left or right
            All.cue_pos_con                 = 1:2;      % right and left cue
            All.shape_con                   = [1:8];    % target and distractor distribution
            %PEST_ON=0;
            % THINGS TO CHANGE
            adjusted_curvature              = -0.17;      % change curvature here
            
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

%% PEST
% if PEST_ON==1
%     stepsize_min          = 0.3;
%     fix_limits            = [-40+Current_con.excentricities 40-Current_con.excentricities];
%     
%     if exist('dyn','var') && dyn.trialNumber > 1
%         selected_target_t=trial(dyn.trialNumber-1).target_selected(PEST_effector);
%         if isempty(selected_target_t) || isnan(selected_target_t) || trial(dyn.trialNumber-1).success==0 || trial(dyn.trialNumber-1).choice==0
%             r_chosen(dyn.trialNumber-1)=false;
%             l_chosen(dyn.trialNumber-1)=false;
%         else
%             r_chosen(dyn.trialNumber-1)=[trial(dyn.trialNumber-1).(PEST_hnd_or_eye).tar(selected_target_t).pos(1) - trial(dyn.trialNumber-1).(PEST_hnd_or_eye).fix.pos(1)]>0;
%             l_chosen(dyn.trialNumber-1)=[trial(dyn.trialNumber-1).(PEST_hnd_or_eye).tar(selected_target_t).pos(1) - trial(dyn.trialNumber-1).(PEST_hnd_or_eye).fix.pos(1)]<0;
%         end
%         any_chosen_idx=find(any([r_chosen; l_chosen],1));
%     else
%         any_chosen_idx=[];
%     end    
%     if numel(any_chosen_idx)>1
%         preferred_behaviour=any(r_chosen(any_chosen_idx(end-1:end))) && any(l_chosen(any_chosen_idx(end-1:end)));
%         if r_chosen(dyn.trialNumber-1) || l_chosen(dyn.trialNumber-1)
%             [fix_eye_x stepsize] = PEST(fix_eye_x,fix_limits,r_chosen(dyn.trialNumber-1),preferred_behaviour,stepsize,stepsize_min);
%         end
%     else
%         stepsize              = 1;
%         fix_eye_x             = 0;
%     end
%     PEST_list(dyn.trialNumber)=fix_eye_x;
%              %stepsize
%              %PEST_list
%     if stepsize<=stepsize_min
%             dyn.state = STATE.CLOSE; 
%             PEST_list
%             return
%     end
% else
%     fix_eye_x             = fix_offset;
% end
fix_eye_x             = fix_offset;
fix_hnd_x             = fix_eye_x;

%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (shuffle_conditions==1 || shuffle_conditions==2)
    sequence_indexes = Shuffle(ordered_sequence_indexes);    
end
if exist('dyn','var') && dyn.trialNumber > 1,
    if force_conditions==1
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        % semi-forced: if trial is unsuccessful, the condition is put back into the pool
    elseif force_conditions==2
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
    elseif force_conditions==3
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
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;        
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;        
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 4;
        task.timing.tar_inv_time_to_acquire_hnd = 4;        
        task.timing.fix_time_to_acquire_eye     = 1;
        task.timing.tar_time_to_acquire_eye     = 15;
        task.timing.tar_inv_time_to_acquire_eye = 15;         
        task.timing.fix_time_hold               = 0.5; % fixation time
        task.timing.fix_time_hold_var           = 0;
        task.timing.cue_time_hold               = 0.6; % cue time
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0.3; % memory period
        task.timing.mem_time_hold_var           = 0.5; % memory period variance
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 1.5; % selection time
        task.timing.tar_time_hold_var           = 0.0;
    
end

%% RADIUS & SIZES

if task.type==5 || task.type==6 
task.eye=rmfield(task.eye,'tar');
task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    
    case 5 %'match to sample'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 2; % target size
        task.eye.tar(1).radius  = 5;   % fixation radius    
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 2.5;
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
    
    ex_LR = Current_con.excentricities * randi(2);
% if     multiple_targets_per_trial == 1; % 18 positions for match to sample saccades(!)
%         ex_LR = Current_con.excentricities;
%         All_positions_right= Shuffle({ [ex_LR,f_h], [ex_LR,f_h+d_pos], [ex_LR,f_h-d_pos], [ex_LR+d_pos,f_h], [ex_LR+d_pos,f_h+d_pos], [ex_LR+d_pos,f_h-d_pos], [ex_LR-d_pos,f_h], [ex_LR-d_pos,f_h+d_pos], [ex_LR-d_pos,f_h-d_pos]});
%         All_positions_left = Shuffle({[-ex_LR,f_h],[-ex_LR,f_h+d_pos],[-ex_LR,f_h-d_pos],[-ex_LR+d_pos,f_h],[-ex_LR+d_pos,f_h+d_pos],[-ex_LR+d_pos,f_h-d_pos],[-ex_LR-d_pos,f_h],[-ex_LR-d_pos,f_h+d_pos],[-ex_LR-d_pos,f_h-d_pos]});
%         tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;          
%         
% elseif multiple_targets_per_trial == 2 % Positions for RF mapping(!)
%         Used_pool_of_angles=pool_of_angles(All.angle_cases);
%         %Current_pool_of_excentircities = Current_con.excentricities;
%         
% %         All_positions_x=[];
% %         All_positions_y=[];
%         %for ex_idx=1:numel(Current_pool_of_excentircities)
%             All_positions_x=Current_con.excentricities*cos(Used_pool_of_angles*2*pi/360);
%             All_positions_y=Current_con.excentricities*sin(Used_pool_of_angles*2*pi/360);
%         %end
%         
%         All_positions_mat =[All_positions_x+ fix_offset;All_positions_y+ f_h]';        
%         All_positions     =num2cell(All_positions_mat,2);
%         if shuffle_angles_per_trial
%             All_positions = Shuffle(All_positions);
%         end
%         % + fix_offset
%         % + f_h
%         tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;    
%         
% elseif     multiple_targets_per_trial == 3; % 18 positions for match to sample saccades(!)
%         ex_LR = Current_con.excentricities;
%         All_positions_right= Shuffle({ [ex_LR,f_h],[ex_LR,f_h]});
%         All_positions_left = Shuffle({[-ex_LR,f_h],[-ex_LR,f_h]});
%         tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;       
%         
% elseif     multiple_targets_per_trial == 4; % 18 positions for match to sample saccades(!)
%         ex_LR = Current_con.excentricities;
%         All_positions_right= Shuffle({ [ex_LR,f_h+4],[ex_LR,f_h-4]});
%         All_positions_left = Shuffle({[-ex_LR,f_h+4],[-ex_LR,f_h-4]});
%         tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;     
% 
% end  

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

%% COLORS
% task.eye.fix.color_dim       = [128 0 0]; 
% task.eye.fix.color_bright    = [255 0 0];
task.eye.tar(1).color_dim    = target_color; %[0 0 0];     % was [128 0 0](red)
task.eye.tar(1).color_bright = [255 0 0];
task.eye.tar(2).color_dim    = target_color; %[0 0 0];     % was [128 0 0](red)
task.eye.tar(2).color_bright = [255 0 0];


if  trial.state == 7
    task.eye.fix.color_dim       = [0 128 0];
    task.eye.fix.color_bright    = [0 255 0];
else
    task.eye.fix.color_dim       = [128 0 0];
    task.eye.fix.color_bright    = [255 0 0];
end

% if task.timing.mem_time_hold_var > 0 && STATE.MEM_PER
%     task.eye.fix.color_dim       = [0 128 0];
%     task.eye.fix.color_bright    = [0 255 0];
% % else
% %     task.eye.fix.color_dim       = [128 0 0];
% %     task.eye.fix.color_bright    = [255 0 0];
% end

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
    case 0
        N_targets_left=2;
        N_targets_right=1; 
end
task.n_targets=N_targets_left+N_targets_right;

%% target shapes (for Match to sample) 
%all_curv=[0.6,0.3,-0.4,-0.6];
%convex_sides=repmat({'LR'},1,task.n_targets);

all_curv=[adjusted_curvature,adjusted_curvature,adjusted_curvature,-0.1];
all_sides={'R','L','LR','LR'};

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
        
 end

%% match and main distractor distribution (for Match to sample) 

% placeholder variables for all 6 positions
left_top = [-ex_LR*cos(60*pi/180),fix_height+ex_LR*sin(60*pi/180)];
left_mid = [-ex_LR,fix_height];
left_bot = [-ex_LR*cos(60*pi/180),fix_height-ex_LR*sin(60*pi/180)];
right_top = [ex_LR*cos(60*pi/180),fix_height+ex_LR*sin(60*pi/180)];
right_mid = [ex_LR,fix_height];
right_bot = [ex_LR*cos(60*pi/180),fix_height-ex_LR*sin(60*pi/180)];

%Current_con.mat_dis_con=Current_con.mat_dis_con+(randi([0,1])*3);

switch Current_con.mat_dis_con
        % right pointing triangles
        case 1 
            task.tar_pos = [{left_top},  Shuffle({left_bot,  right_mid})];
        case 2
            task.tar_pos = [{right_mid},  Shuffle({left_top,  left_bot})];
        case 3
            task.tar_pos = [{left_bot},  Shuffle({left_top,  right_mid})];
        % left pointing triangles
        case 4
            task.tar_pos = [{right_top},  Shuffle({right_bot,  left_mid})];
        case 5
            task.tar_pos = [{left_mid},  Shuffle({right_top,  right_bot})];
        case 6
            task.tar_pos = [{right_bot},  Shuffle({right_top,  left_mid})];
        
end

if task.type==5 || task.type==6 
%     if isfield(task,'tar_pos')
%     rmfield(task,'tar_pos');
%     end
%     n_left=1;
%     n_right=1;
%     if match_left
%         task.tar_pos{1}=All_positions_left{n_left};
%         n_left=n_left+1;
%     else
%         task.tar_pos{1}=All_positions_right{n_right};
%         n_right=n_right+1;
%     end
% %     if distractor_left
% %         task.tar_pos{2}=All_positions_left{2};
% %     else
% %         task.tar_pos{2}=All_positions_right{2};
% %     end
%     for n_target=2:task.n_targets
%         
%         if n_target+match_left-1<=N_targets_left
%             task.tar_pos{n_target}=All_positions_left{n_left};
%             n_left=n_left+1;
%         else
%             task.tar_pos{n_target}=All_positions_right{n_right};
%             n_right=n_right+1;
%         end
%         
%     end
   
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

   
