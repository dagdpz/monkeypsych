%% Effectors
% 0 eye
% 1 free gaze reach
% 2 joint movement eye and hand
% 3 dissociated saccade
% 4 dissociated reach
% 5 Poffenberger task (MRI buttons)
% 6 free gaze reach with initial eye fixation

%% Task types
% 1 fixation
% 2 direct saccade
% 3 memory saccade

%% Task settings

if ~exist('dyn','var') || dyn.trialNumber == 1
    
    % esperimentazione        = {'calibration'};
    % esperimentazione        = {'fixation'};
    esperimentazione        = {'memory saccades'};
    % esperimentazione        = {'direct saccades'};
    
    
    for n_exp = 1:numel(esperimentazione)
        experiment=esperimentazione{n_exp};
        task.calibration                    = 0;
        SETTINGS.GUI_in_acquisition         = 0;
        PEST_ON                             = 0;
        task.rest_hand                      = [0 0];
        multiple_targets_per_trial          = 0;
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
            'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0,'offset_con',0,'invert_con',0,'exact_excentricity_con_x',NaN,'exact_excentricity_con_y',NaN,'colors_con',0,'targets_con',2,'tar_pos_con',0);
        
        %% Tasks
        switch experiment
            
            case 'calibration'
                
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.check_motion_body          = 0;                
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0];
                All.excentricities                  = [0];
                All.angle_cases                     = [1];
                
                task.force_conditions                    = 1;
                task.shuffle_conditions                  = 0;
                N_repetitions                       = 100;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                
                task.reward.time_neutral            = [0.08 0.08]; %
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = 1; % fixation
                All.timing_con                      = 0;
                All.size_con                        = 0;
                All.instructed_choice_con           = [0];
                All.stim_con                        = 0;
                
            case 'fixation'
                
                SETTINGS.check_motion_jaw           = 1;
                SETTINGS.check_motion_body          = 1;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0];
                All.excentricities              = [0];
                All.angle_cases                 = [1];
                
                task.force_conditions                    = 1; % 1: error trial will be repeated right away, 2: missed condition will be put back into the pool of trials
                task.shuffle_conditions                  = 1; % 0: fixed order (needed for pseudo-randomization for fMRI), 1: randomize conditions
                       
                task.reward.time_neutral            = [0.85 0.85];
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % 0: eye
                All.type_con                        = [1]; % 1: fixation, 3: memory
                All.timing_con                      = 1; % case 1 of task timing
                All.size_con                        = 1; % case 1 of stimulus size and radius
                All.instructed_choice_con           = [0];
                All.stim_con                        = 0; % 0: no stimulation
                
                N_repetitions                       = 12;
                
            case 'memory saccades'    
                
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.check_motion_body          = 0;
                
                fix_eye_y                           = -10;
                fix_hnd_y                           = 0;
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0,30,150,180,210,330];
                All.excentricities                  = [15];
                All.angle_cases                     = [1,4]; %[1,2,3,4,5,6];
                
                task.force_conditions                    = 0;
                task.shuffle_conditions                  = 1;
                
                task.reward.time_neutral            = [0.1 0.1]; %
                task.correct_choice_target          = [1]; % number of the correct target in choice (only necessary if choice is not free choice), e.g. target 1
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = [3];
                All.timing_con                      = [2];
                All.size_con                        = 3;
                All.instructed_choice_con           = [1];
                All.stim_con                        = 0;
                
                All.colors_con                      = 1;
                All.targets_con                     = 3; % 2 - two targets, 3 - three targets
                All.shape_con                       = 0;
                
                N_repetitions                       = 10;
                
            case 'direct saccades' % USED FOR TESTING
                
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.check_motion_body          = 0;
                
                fix_eye_y                           = -10;
                fix_hnd_y                           = 0;
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0,30,150,180,210,330];
                All.excentricities                  = [15];
                All.angle_cases                     = [1,2,3,4,5,6]; %[1,2,3,4,5,6];
                
                task.force_conditions                    = 0;
                task.shuffle_conditions                  = 1;
                
                task.reward.time_neutral            = [0.1 0.1]; %
                task.correct_choice_target          = 1; % number of the correct target in choice (only necessary if choice is not free choice), e.g. target 1
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = [2];
                All.timing_con                      = [3];
                All.size_con                        = 3;
                All.instructed_choice_con           = [1];
                All.stim_con                        = 0;
                
                All.colors_con                      = 1;
                All.targets_con                     = 3; % 2 - two targets, 3 - three targets
                All.shape_con                       = 0;
                
                N_repetitions                       = 10;
                
        end
        
        %% create trial sequence
        all_fieldnames=fieldnames(All);
        N_total_conditions       =1;
        sequence_cell            ={};
        for FN=1:numel(all_fieldnames)
            N_total_conditions=N_total_conditions*numel(All.(all_fieldnames{FN}));
            sequence_cell=[sequence_cell, {All.(all_fieldnames{FN})}];
        end
        
        sequence_matrix_exp{n_exp}          = repmat(combvec(sequence_cell{:}),1,N_repetitions);
        ordered_sequence_indexes_exp{n_exp} = 1:N_total_conditions*N_repetitions;
    end
    
    if n_exp == 1
        sequence_matrix          = [sequence_matrix_exp{:}];
        idx_exact_x=ismember(all_fieldnames,'exact_excentricity_con_x');
        idx_exact_y=ismember(all_fieldnames,'exact_excentricity_con_y');
        conditions_to_remove=(sequence_matrix(idx_exact_y,:)==0 & sequence_matrix(idx_exact_x,:)==0);
        sequence_matrix(:,conditions_to_remove)=[];
        ordered_sequence_indexes = 1:(numel([ordered_sequence_indexes_exp{:}])-sum(conditions_to_remove));
        
    elseif n_exp == 2 % pseudo-randomization for fMRI tasks
        sequence_indexes_exp_shuff = cellfun(@(x) x(randperm(length(x))), ordered_sequence_indexes_exp, 'UniformOutput',0);
        
        ntrials = cellfun(@(x) size(x,2),sequence_indexes_exp_shuff);
        if ntrials(1)/ntrials(2) == 1
            s = [1 2];
        else
            s = [find(ntrials == min(ntrials)) repmat(find(ntrials == max(ntrials)),1,ntrials(ntrials == max(ntrials))/ntrials(ntrials == min(ntrials)))];
        end        
        s = repmat(s,1,6/size(s,2));       
        seq = repmat(s(randperm(length(s))),1,size([sequence_matrix_exp{:}],2)/length(s));
        count = cell(1,2);
        count{1} = 0; count{2} = 0;
        sequence_matrix = zeros(length(all_fieldnames),length(seq));
        for n = 1:length(seq)
            count{seq(n)} = count{seq(n)}+1;
            sequence_matrix(:,n) = sequence_matrix_exp{seq(n)}(:,sequence_indexes_exp_shuff{seq(n)}(count{seq(n)}));
        end
        ordered_sequence_indexes = 1:size(sequence_matrix,2);
    end
end

%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && task.shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (task.shuffle_conditions==1)
    sequence_indexes = Shuffle(ordered_sequence_indexes);
end

%% Force conditions
if exist('dyn','var') && dyn.trialNumber > 1,
    if task.force_conditions==1 % error trial will be repeated
        if sum([trial.success])==length(sequence_indexes),
            dyn.state = STATE.CLOSE; return
        else
            custom_trial_condition = sequence_indexes(sum([trial.success])+1);
        end
        
    elseif task.force_conditions==2 % semi-forced: if trial is not successful, the condition is put back into the pool
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


%% Fixation offset
fix_eye_x             = Current_con.offset_con;
fix_hnd_x             = fix_eye_x;

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

%% TASK TIMING

% general timing
task.timing.grace_time_eye          = 0;
task.timing.fix_time_to_acquire_eye = 0.5;
task.timing.tar_time_to_acquire_eye = 1;
task.timing.wait_for_reward         = 0.5;
task.timing.ITI_success             = 2;
task.timing.ITI_success_var         = 0;
task.timing.ITI_fail                = 1;
task.timing.ITI_fail_var            = 0;
task.timing.ITI_incorrect_completed = 1;

switch Current_con.timing_con
    case 0 % 'calibration'
        
        task.timing.grace_time_eye              = 0;
        task.timing.ITI_success                 = 2;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 0;                
        task.timing.fix_time_hold               = 2;
        task.timing.fix_time_hold_var           = 0;
        
    case 1 %'fixation'       
          
        task.timing.fix_time_hold       = 0.5; % minimum duration of fixation trials
        task.timing.fix_time_hold_var   = 0.5;
        
    case 2 %'memory saccades'
        
        task.timing.fix_time_hold               = 1; % duration of initial fixation
        task.timing.fix_time_hold_var           = 0;
        task.timing.cue_time_hold               = 0.5; % duration of the cue
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 1; % duration of the memory period
        task.timing.mem_time_hold_var           = 0;
        task.timing.tar_time_to_acquire_eye     = 0;
        task.timing.tar_inv_time_to_acquire_eye = 2;
        task.timing.tar_inv_time_hold           = 0.3;
        task.timing.tar_inv_time_hold_var       = 0;  
        task.timing.tar_time_hold               = 1; % target hold time
        task.timing.tar_time_hold_var           = 0;  
        
    case 3 %'direct saccades'
        
        task.timing.fix_time_hold               = 1;
        task.timing.fix_time_hold_var           = 0;
        task.timing.tar_time_hold               = 0.3;
        task.timing.tar_time_hold_var           = 0.0;
        
end

%% SHAPES of fixation spot and targets

task.eye.fix.shape                  = 'circle'; % 'circle', 'square'
task.hnd.fix.shape                  = 'circle'; % 'circle', 'square'

switch Current_con.shape_con
    
    case 0 % all targets circles
        
        task.eye.tar(1).shape               = 'circle';
        task.eye.tar(2).shape               = 'circle';
        task.hnd.tar(1).shape               = 'circle';
        task.hnd.tar(2).shape               = 'circle';       
        
        task.eye.cue(1).shape               = 'circle';
        task.eye.cue(2).shape               = 'circle';
        task.hnd.cue(1).shape               = 'circle';
        task.hnd.cue(2).shape               = 'circle';
        
        
        if Current_con.targets_con == 3
            
            task.eye.tar(3).shape               = 'circle';
            task.hnd.tar(3).shape               = 'circle';
            
            task.eye.cue(3).shape               = 'circle';
            task.hnd.cue(3).shape               = 'circle';
            
        end
end

%% RADIUS and SIZES

if task.type==5 || task.type==6
    task.eye=rmfield(task.eye,'tar');
    task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    case 0 %'calibration'
        task.eye.fix.size       = 0.25;
        task.eye.fix.radius     = 30;
        task.eye.tar(1).size    = 0.25;
        task.eye.tar(1).radius  = 30;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 1 %'fixation'
        
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 4;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 2 %'memory saccades'
        
        task.eye.fix.size       = 1;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 1;
        task.eye.tar(1).radius  = 8;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 3 %'direct saccades'
        
        task.eye.fix.size       = 1; %0.5
        task.eye.fix.radius     = 8; 
        task.eye.tar(1).size    = 1;
        task.eye.tar(1).radius  = 8;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

if Current_con.targets_con == 3
    
    task.eye.tar(3).size    = task.eye.tar(1).size;
    task.hnd.tar(3).size    = task.hnd.tar(1).size ; % deg
    task.eye.tar(3).radius  = task.eye.tar(1).radius;
    task.hnd.tar(3).radius  = task.hnd.tar(1).radius; % deg
    
end

%% TARGET POSITIONS

if SETTINGS.take_angles_con
    current_angle=pool_of_angles(Current_con.angle_cases); %
    tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
    tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);
else
    tar_dis_x   = Current_con.exact_excentricity_con_x;
    tar_dis_y   = Current_con.exact_excentricity_con_y;
end

tar_dis_1x = + tar_dis_x;
tar_dis_1y = + tar_dis_y;
tar_dis_2x = - tar_dis_x;
tar_dis_2y = + tar_dis_y;
tar_dis_3x = 0;
tar_dis_3y = 10;

% fixation spot
if task.type==1 % fixation
    
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

% target positions
task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;

task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;

if  Current_con.targets_con == 3 % three targets

    task.eye.tar(3).x = fix_eye_x;
    task.eye.tar(3).y = fix_eye_y; % + tar_dis_3y;
    task.hnd.tar(3).x = fix_hnd_x;
    task.hnd.tar(3).y = fix_hnd_y; % + tar_dis_3y;
    
end
        
%% COLORS of fixation spot and targets

task.eye.fix.color_dim          = [50 50 50]; % [128 0 0]
task.eye.fix.color_bright       = [100 100 100]; % [255 0 0]
      
switch Current_con.colors_con
    case 0 % all targets red
        
        task.eye.tar(1).color_dim       = [128 0 0];
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = task.eye.tar(1).color_dim;
        task.eye.tar(2).color_bright    = task.eye.tar(1).color_bright;
        
        if Current_con.targets_con == 3
            
            task.eye.tar(3).color_dim       = task.eye.tar(1).color_dim;
            task.eye.tar(3).color_bright    = task.eye.tar(1).color_bright;
            
        end
        
    case 1 % different colors
        
        task.eye.tar(1).color_dim       = [128 0 0];
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [50 50 0];
        task.eye.tar(2).color_bright    = [123 123 0]; % in setup 1 same luminance as [255 0 0]
        
        if Current_con.targets_con == 3
            
            task.eye.tar(3).color_dim       = [30 30 30];
            task.eye.tar(3).color_bright    = [100 100 100];
            
        end
end
        

% only important for tasks with effector hand
task.hnd_right.color_dim        = [0 128 0]; %
task.hnd_right.color_bright     = [0 255 0];
task.hnd_left.color_dim         = [39 109 216]; %
task.hnd_left.color_bright      = [119 230 253];
task.hnd_right.color_cue_dim    = [0 128 0];
task.hnd_right.color_cue_bright = [0 255 0];
task.hnd_left.color_cue_dim     = [39 109 216];
task.hnd_left.color_cue_bright  = [119 230 253];
task.hnd_stay.color_dim         = [128 129 0];
task.hnd_stay.color_bright      = [255 255 0];


%% CUE assignment: Positions and colors

% same positions as targets
task.eye.cue                                        = task.eye.tar;
task.hnd.cue                                        = task.hnd.tar;

% switch Current_con.cue_pos_con
%     case 1
%         task.cue_pos                                = {[-ex_cue,fix_height],[ex_cue,fix_height]};
%     case 2
%         task.cue_pos                                = {[ex_cue,fix_height],[-ex_cue,fix_height]};
% end

% colors
if task.effector==0 || task.effector==1 || task.effector==2
    task.eye.cue(1).color_dim                       = [128 0 0];
    task.eye.cue(1).color_bright                    = [128 0 0];
    task.eye.cue(2).color_dim                       = [50 50 0];
    task.eye.cue(2).color_bright                    = [50 50 0];
    
    if  Current_con.targets_con == 3 % three targets
        task.eye.cue(3).color_dim                       = [100 100 100];
        task.eye.cue(3).color_bright                    = [100 100 100];
    end
    
end

%% important for Match to sample task
% target distribution left right
% switch Current_con.tar_dis_con
%     case 0
%         N_targets_left=1;N_targets_right=1; % for non-m2s-tasks
% end
% task.n_targets=N_targets_left+N_targets_right;
% 
% % target shapes
% all_curv=[0.6,0.3,-0.3,-0.6];
% convex_sides=repmat({'LR'},1,task.n_targets);
% switch Current_con.shape_con
%     case 1
%         task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
%     case 2
%         task.convexities=num2cell([all_curv(2),all_curv(1),all_curv(randi([3,4],[1,task.n_targets-2]))]);
%     case 3
%         task.convexities=num2cell([all_curv(3),all_curv(4),all_curv(randi([1,2],[1,task.n_targets-2]))]);
%     case 4
%         task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
%     case 5
%         task.convexities=num2cell([all_curv(4),all_curv(3),all_curv(randi([1,2],[1,task.n_targets-2]))]);
%     case 6
%         task.convexities=num2cell([all_curv(1),all_curv(2),all_curv(randi([3,4],[1,task.n_targets-2]))]);
%     case 7
%         task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(3),all_curv(3),all_curv(randi([3,4],[1,task.n_targets-4]))]);
%     case 8
%         task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(2),all_curv(2),all_curv(randi([1,2],[1,task.n_targets-4]))]);
%     case 9
%         task.convexities=num2cell([all_curv(2),all_curv(3),all_curv(1),all_curv(4)]);
%     case 10
%         task.convexities=num2cell([all_curv(3),all_curv(2),all_curv(4),all_curv(1)]);
% end
% 
% % match and main distractor distribution
% switch Current_con.mat_dis_con
%     case 1
%         match_left=1; distractor_left=1;
%     case 2
%         match_left=1; distractor_left=0;
%     case 3
%         match_left=0; distractor_left=1;
%     case 4
%         match_left=0; distractor_left=0;
% end
% 
% if task.type==5 || task.type==6
%     if isfield(task,'tar_pos')
%         rmfield(task,'tar_pos');
%     end
%     if match_left
%         task.tar_pos{1}=All_positions_left{1};
%     else
%         task.tar_pos{1}=All_positions_right{1};
%     end
%     if distractor_left
%         task.tar_pos{2}=All_positions_left{2};
%     else
%         task.tar_pos{2}=All_positions_right{2};
%     end
%     for n_target=3:task.n_targets
%         if n_target+match_left+distractor_left-2<=N_targets_left
%             task.tar_pos{n_target}=All_positions_left{n_target};
%         else
%             task.tar_pos{n_target}=All_positions_right{n_target};
%         end
%     end
%     
%     
%     for n_target                                    = 1:task.n_targets
%         task.eye.tar(n_target).size                 = task.eye.tar(1).size;
%         task.eye.tar(n_target).radius               = task.eye.tar(1).radius;
%         task.hnd.tar(n_target).size                 = task.hnd.tar(1).size;
%         task.hnd.tar(n_target).radius               = task.hnd.tar(1).radius;
%         task.eye.tar(n_target).color_dim            = task.eye.tar(1).color_dim;
%         task.eye.tar(n_target).color_bright         = task.eye.tar(1).color_bright;
%         
%         task.eye.tar(n_target).ringColor            = [];
%         task.eye.tar(n_target).ringColor2           = [0 0 0];
%         task.eye.tar(n_target).reward_prob          = 1;
%         task.eye.tar(n_target).shape.mode           = 'convex';
%         task.eye.tar(n_target).shape.convexity      = task.convexities{n_target};
%         task.eye.tar(n_target).shape.convex_side    = convex_sides{n_target};
%         
%         task.hnd.tar(n_target).ringColor            = [];
%         task.hnd.tar(n_target).ringColor2           = [0 0 0];
%         task.hnd.tar(n_target).reward_prob          = 1;
%         task.hnd.tar(n_target).shape.mode           = 'convex';
%         task.hnd.tar(n_target).shape.convexity      = task.convexities{n_target};
%         task.hnd.tar(n_target).shape.convex_side    = convex_sides{n_target};
%         
%         task.eye.tar(n_target).x                    = task.tar_pos{n_target}(1);
%         task.eye.tar(n_target).y                    = task.tar_pos{n_target}(2);
%         task.hnd.tar(n_target).x                    = task.tar_pos{n_target}(1);
%         task.hnd.tar(n_target).y                    = task.tar_pos{n_target}(2);
%         
%     end
% end
% 
% if task.type==8
%     task.n_targets                              =size(All_positions,1);
%     
%     for n_target=1:task.n_targets
%         task.eye.tar(n_target).size                 = task.eye.tar(1).size;
%         task.eye.tar(n_target).radius               = task.eye.tar(1).radius;
%         task.hnd.tar(n_target).size                 = task.hnd.tar(1).size;
%         task.hnd.tar(n_target).radius               = task.hnd.tar(1).radius;
%         task.eye.tar(n_target).color_dim            = task.eye.tar(1).color_dim;
%         task.eye.tar(n_target).color_bright         = task.eye.tar(1).color_bright;
%         
%         task.eye.tar(n_target).ringColor            = [];
%         task.eye.tar(n_target).ringColor2           = [0 0 0];
%         task.eye.tar(n_target).reward_prob          = 1;
%         task.eye.tar(n_target).shape                = 'circle';
%         %         task.eye.tar(n_target).shape.convexity   = task.convexities{n_target};
%         %         task.eye.tar(n_target).shape.convex_side = convex_sides{n_target};
%         
%         task.hnd.tar(n_target).ringColor            = [];
%         task.hnd.tar(n_target).ringColor2           = [0 0 0];
%         task.hnd.tar(n_target).reward_prob          = 1;
%         task.hnd.tar(n_target).shape                = 'circle';
%         %         task.hnd.tar(n_target).shape.convexity   = task.convexities{n_target};
%         %         task.hnd.tar(n_target).shape.convex_side = convex_sides{n_target};
%         
%         task.eye.tar(n_target).x                    = All_positions{n_target}(1);
%         task.eye.tar(n_target).y                    = All_positions{n_target}(2);
%         task.hnd.tar(n_target).x                    = All_positions{n_target}(1);
%         task.hnd.tar(n_target).y                    = All_positions{n_target}(2);
%         
%     end
% end
% 
% 
% 
% 
% %% Inverting fixation and target
% if Current_con.invert_con == 1
%     temp_eye_fix_x                                  = task.eye.fix.x;
%     temp_eye_fix_y                                  = task.eye.fix.y;
%     temp_hnd_fix_x                                  = task.hnd.fix.x;
%     temp_hnd_fix_y                                  = task.hnd.fix.y;
%     
%     task.eye.fix.x                                  = task.eye.tar(1).x;
%     task.eye.fix.y                                  = task.eye.tar(1).y;
%     task.hnd.fix.x                                  = task.hnd.tar(1).x;
%     task.hnd.fix.y                                  = task.hnd.tar(1).y;
%     
%     task.eye.tar(1).x                               = temp_eye_fix_x;
%     task.eye.tar(1).y                               = temp_eye_fix_y;
%     task.hnd.tar(1).x                               = temp_hnd_fix_x;
%     task.hnd.tar(1).y                               = temp_hnd_fix_y;
%     
%     task.eye.cue(1).x                               = temp_eye_fix_x;
%     task.eye.cue(1).y                               = temp_eye_fix_y;
%     
%     task.hnd.cue(1).x                               = temp_hnd_fix_x;
%     task.hnd.cue(1).y                               = temp_hnd_fix_y;
% end
