if ~exist('dyn','var') || dyn.trialNumber == 1
    
%     esperimentazione        = {'calibration'};
    esperimentazione        = {'fixation' 'memory saccades'};
%     esperimentazione        = {'memory saccades'};
%     esperimentazione        = {'fixation'};
    
    
    for n_exp = 1:numel(esperimentazione)
        experiment=esperimentazione{n_exp};
        task.calibration                    = 0;
        SETTINGS.GUI_in_acquisition         = 0;
        PEST_ON                             = 0;
        task.rest_hand                      = [0 0];
        multiple_targets_per_trial          = 0;
        SETTINGS.MonkeyMovedSound           = 0;
        SETTINGS.FixationBreakSound         = 0;
        
        task.force_conditions                    = 1; % 1: error trial will be repeated right away, 2: missed condition will be put back into the pool of trials
        task.shuffle_conditions                  = 0; % 0: fixed order (needed for pseudo-randomization for fMRI), 1: randomize conditions
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct('angle_cases',0,'instructed_choice_con',0,'type_con',0,'effector_con',0,'reach_hand_con',0,'excentricities',0,'stim_con',0,'timing_con',0,'size_con',0,...
            'tar_dis_con',0,'mat_dis_con',0,'cue_pos_con',0,'shape_con',0,'offset_con',0,'invert_con',0,'exact_excentricity_con_x',NaN,'exact_excentricity_con_y',NaN,'reward_time',0);
        
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
                
                All.reward_time                     = 0.05; %
                                
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
       
                All.reward_time                     = 0.65;
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % 0: eye
                All.type_con                        = [1]; % 1: fixation, 3: memory
                All.timing_con                      = 1; % case 1 of task timing
                All.size_con                        = 1; % case 1 of stimulus size and radius
                All.instructed_choice_con           = [0];
                All.stim_con                        = 0; % 0: no stimulation
                
                N_repetitions                       = 12; % N_repetitions 'fixation': 12 - no choice, 24 - instructed/choice 1:1
                
            case 'memory saccades'
                
                SETTINGS.check_motion_jaw           = 1;
                SETTINGS.check_motion_body          = 1;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0,30,150,180,210,330];
                All.excentricities                  = [12];
                All.angle_cases                     = [1,2,3,4,5,6];
                             
                All.reward_time                     = 0.65; %
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = [3];
                All.timing_con                      = [2];
                All.size_con                        = 2;
                All.instructed_choice_con           = [0];
                All.stim_con                        = 0;
                
                N_repetitions                       = 4; % 1 - fixation/memory 2:1 , 2 - fixation/memory 1:1, 4 - fixation/memory 1:2, 6 - fixation/memory 1:3
                 
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
        count = cell(1,2); count{1} = 0; count{2} = 0;
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

%% Reward time
task.reward.time_neutral    = repmat(Current_con.reward_time,1,2);

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

% general timing for MRI
task.timing.grace_time_eye          = 0.3;
task.timing.fix_time_to_acquire_eye = 0.5;
task.timing.tar_time_to_acquire_eye = 0.5;
task.timing.wait_for_reward         = 1;
task.timing.ITI_success             = 5;
task.timing.ITI_success_var         = 0;
task.timing.ITI_fail                = 2;
task.timing.ITI_fail_var            = 0;

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
          
        task.timing.fix_time_hold       = 19.95; % 19.95 minimum duration of fixation trials
        task.timing.fix_time_hold_var   = 2.5;
        
    case 2 %'memory saccades'
        
        task.timing.fix_time_hold               = 9.25; % duration of initial fixation
        task.timing.fix_time_hold_var           = 1;
        task.timing.cue_time_hold               = 0.2; % duration of the cue
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 9.5; % duration of the memory period
        task.timing.mem_time_hold_var           = 1;
        task.timing.tar_time_hold               = 1.0; % target hold time
        task.timing.tar_time_hold_var           = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5;
        task.timing.tar_inv_time_hold           = 0.01;
        task.timing.tar_inv_time_hold_var       = 0;        
        
end

%% RADIUS & SIZES

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
        
        task.eye.fix.size       = 0.25; %0.25
        task.eye.fix.radius     = 4; %4
        task.eye.tar(1).size    = 0.25;
        task.eye.tar(1).radius  = 5;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
        
    case 2 %'memory saccades'
        task.eye.fix.size       = 0.25;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 0.5; %1
        task.eye.tar(1).radius  = 5;
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
end

task.eye.tar(2).size    = task.eye.tar(1).size;
task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.eye.tar(2).radius  = task.eye.tar(1).radius;
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg

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

if multiple_targets_per_trial == 1; % 18 positions for match to sample saccades(!)
    ex_LR = Current_con.excentricities;
    All_positions_right= Shuffle({ [ex_LR,f_h], [ex_LR,f_h+d_pos], [ex_LR,f_h-d_pos], [ex_LR+d_pos,f_h], [ex_LR+d_pos,f_h+d_pos], [ex_LR+d_pos,f_h-d_pos], [ex_LR-d_pos,f_h], [ex_LR-d_pos,f_h+d_pos], [ex_LR-d_pos,f_h-d_pos]});
    All_positions_left = Shuffle({[-ex_LR,f_h],[-ex_LR,f_h+d_pos],[-ex_LR,f_h-d_pos],[-ex_LR+d_pos,f_h],[-ex_LR+d_pos,f_h+d_pos],[-ex_LR+d_pos,f_h-d_pos],[-ex_LR-d_pos,f_h],[-ex_LR-d_pos,f_h+d_pos],[-ex_LR-d_pos,f_h-d_pos]});
    tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;
    
elseif multiple_targets_per_trial == 2 % Positions for RF mapping(!)
    Used_pool_of_angles=pool_of_angles(All.angle_cases);
    %Current_pool_of_excentircities = Current_con.excentricities;
    
    %         All_positions_x=[];
    %         All_positions_y=[];
    %for ex_idx=1:numel(Current_pool_of_excentircities)
    All_positions_x=Current_con.excentricities*cos(Used_pool_of_angles*2*pi/360);
    All_positions_y=Current_con.excentricities*sin(Used_pool_of_angles*2*pi/360);
    %end
    
    All_positions_mat =[All_positions_x+ fix_offset;All_positions_y+ f_h]';
    All_positions     =num2cell(All_positions_mat,2);
    if shuffle_angles_per_trial
        All_positions = Shuffle(All_positions);
    end
    % + fix_offset
    % + f_h
    tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;
end

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

%% COLORS of fixation spot and targets
task.eye.fix.color_dim          = [128 0 0]; %
task.eye.fix.color_bright       = [255 0 0];

% luminance test
% task.eye.fix.color_dim          = [128 128 0]; %
% task.eye.fix.color_bright       = [123 123 0]; % same luminance as [255 0 0]
% task.eye.fix.color_dim          = [185 90 0]; %
% task.eye.fix.color_bright       = [185 90 0]; %

task.eye.tar(1).color_dim       = [128 0 0]; 
task.eye.tar(1).color_bright    = [255 0 0];
task.eye.tar(2).color_dim       = [128 0 0];  
task.eye.tar(2).color_bright    = [255 0 0];

task.hnd_right.color_dim        = [0 128 0]; 
task.hnd_right.color_bright     = [0 255 0];
task.hnd_left.color_dim         = [39 109 216]; 
task.hnd_left.color_bright      = [119 230 253];
task.hnd_right.color_cue_dim    = [0 128 0];
task.hnd_right.color_cue_bright = [0 255 0];
task.hnd_left.color_cue_dim     = [39 109 216];
task.hnd_left.color_cue_bright  = [119 230 253];
task.hnd_stay.color_dim         = [128 129 0];
task.hnd_stay.color_bright      = [255 255 0];


%% CUE assignment: Positions and colors
task.eye.cue                                        = task.eye.tar;
task.hnd.cue                                        = task.hnd.tar;

switch Current_con.cue_pos_con
    case 1
        task.cue_pos                                = {[-ex_cue,fix_height],[ex_cue,fix_height]};
    case 2
        task.cue_pos                                = {[ex_cue,fix_height],[-ex_cue,fix_height]};
end

if task.effector==0 || task.effector==1 || task.effector==2    
    task.eye.cue(1).color_dim                       = [90 50 50];
    task.eye.cue(1).color_bright                    = [90 50 50];
    task.eye.cue(2).color_dim                       = [90 50 50];
    task.eye.cue(2).color_bright                    = [90 50 50];
end

if task.type==5 || task.type==6 % match to sample... cue positions and colors differ from targets
    
    task.eye.cue(1).x                               = task.cue_pos{1}(1);
    task.eye.cue(1).y                               = task.cue_pos{1}(2);
    task.eye.cue(2).x                               = task.cue_pos{2}(1);
    task.eye.cue(2).y                               = task.cue_pos{2}(2);
    
    task.hnd.cue(1).x                               = task.cue_pos{1}(1);
    task.hnd.cue(1).y                               = task.cue_pos{1}(2);
    task.hnd.cue(2).x                               = task.cue_pos{2}(1);
    task.hnd.cue(2).y                               = task.cue_pos{2}(2);
    
    task.eye.cue(1).color_dim                       = [128 50 50];
    task.eye.cue(1).color_bright                    = [128 50 50];
    task.eye.cue(2).color_dim                       = [128 50 50];
    task.eye.cue(2).color_bright                    = [128 50 50];
end
