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

% Calibration
%     esperimentazione = {'calibration'};  

% Fixation
%    esperimentazione = {'fixation'}; 

% Match-to-sample
% one options 
%esperimentazione = {'instructed direct saccades'};

% mixed one or two options 
%esperimentazione = {'choice target-distractor direct saccades horizontal','instructed direct saccades'};

% keep the stay option
esperimentazione = {'choice target-distractor direct saccades horizontal'};
%esperimentazione = {'choice target-distractor direct saccades horizontal', 'instructed direct saccades'};

%esperimentazione = {'instructed direct saccades'};

%%

    for n_exp = 1:numel(esperimentazione)
        experiment=esperimentazione{n_exp};
        task.calibration                    = 0;
        SETTINGS.GUI_in_acquisition         = 0;
        PEST_ON                             = 0;
        task.rest_hand                      = [0 1]; %left right
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct(...
            'angle_cases',0, 'instructed_choice_con',0, 'type_con',0, 'effector_con',0, 'reach_hand_con',0, 'excentricities',0, 'stim_con',0, 'timing_con',0, 'size_con',0,...
            'shape_con',0, 'offset_con',0, 'exact_excentricity_con_x',NaN, 'exact_excentricity_con_y',NaN, 'colors_con',0, 'targets_con',0, 'reward_time',0, 'correct_choice_target', 0,...
            'differenceBetweenSamples', NaN,'rotations', NaN,'difficultyLevel_rotation',NaN, 'target_Right',NaN);
        %% Tasks       
        % general settings
        SETTINGS.check_motion_jaw           = 0;
        SETTINGS.check_motion_body          = 0;
        SETTINGS.MonkeyMovedSound           = 0;
        SETTINGS.FixationBreakSound         = 0;
        SETTINGS.WrongTargetSound           = 1;


        
        fix_eye_y                           = 0;
        fix_hnd_y                           = 0;
        
        All.offset_con                      = 0; % offset of fixation spot (x dimension)
        All.effector_con                    = 1; % 1 - hand
        All.stim_con                        = 0;
        All.reach_hand_con                  = 2; % 2=right 1= links, [1,2] = alterniered
        All.type_con                        = 9;
        All.timing_con                      = 1;
        All.size_con                        = 2;
        All.colors_con                      = 1; % same
        All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct

        
        task.force_conditions               = 0; % 0 - trial will not be repeated, 1 - trial will be repeated immediately, 2 - trial will be put back into the pool of trials
        force_conditions_mode               = 'success'; % %'success' 'target selected'
        task.shuffle_conditions             = 1;
     % Match-to-sample stimulus: rotation defines the sample & rotationDifference defines the distractor/NonSample   
%          All.differenceBetweenSamples        = 20 ;%90; 45;
%          difficultyLevels                    = [2 1]; %easy to difficult
%          All.rotations                       = 10:All.differenceBetweenSamples:50; %10 different samples %18:All.differenceBetweenSamples:54
%          All.rotationDifference              = 40 ;% [90] All.differenceBetweenSamples*difficultyLevels;
         
%         All.differenceBetweenSamples        = 4;
%         difficultyLevels                    = [5 4 ];
%         All.rotations                       = 18:All.differenceBetweenSamples:54; %10 different samples
%         All.rotationDifference              = All.differenceBetweenSamples*difficultyLevels;
        All.differenceBetweenSamples        = 45 ;%90; 45;
        difficultyLevels                    = [2 1]; %easy to difficult
        All.rotations                       = 0:All.differenceBetweenSamples:135; %10 different samples %18:All.differenceBetweenSamples:54
        All.rotationDifference              = 45 ;% [90] All.differenceBetweenSamples*difficultyLevels;
     
     % Where does the stimulus appear?
        All.excentricities                  = [10];
        SETTINGS.take_angles_con            = 1;
        pool_of_angles                      = [0 180]; %[0,30,330, 180,150,210] [0,20,340, 180,160,200] % [right-mid right-up right-bottom left-mid left-up left-bottom]       
        All.angle_cases                     = [1,2]; %[1,2,3,4,5,6];
        angle_cases_singleOption            = All.angle_cases;
        angle_cases_twoOptions              = All.angle_cases(1);
     


     % TimeOut & Reward 
        All.reward_time                     = 0.32; %0.2 
        N_repetitions                       = 20; % long: 3; short: 2x1; 1x1;
        
        %Microstimulation
        stim_con_direct                     = 0  ; %   [0 5 7 9] [0 1 2 3]; % stimulation: 0 - no stimulation, 5 - 250ms before "go",7 - 100ms before "go", 3 - 50ms before "go"

        switch experiment
            
            case 'calibration'
                
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.check_motion_body          = 0;                
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0];
                All.excentricities                  = [0];
                All.angle_cases                     = [1];
                
                task.force_conditions               = 1;
                force_conditions_mode               = 'success'; %'success'
                task.shuffle_conditions             = 0;
                N_repetitions                       = 100;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                
                All.reward_time                     = 0.09; %
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = 1; % fixation
                All.timing_con                      = 0;
                All.size_con                        = 0;
                All.instructed_choice_con           = [0];
                All.stim_con                        = 0;
                
            case 'fixation'
                
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.check_motion_body          = 0;
                
                SETTINGS.take_angles_con            = 1;
                pool_of_angles                      = [0];
                All.excentricities                  = [0];
                All.angle_cases                     = [1];
                
                task.force_conditions               = 1;
                force_conditions_mode               = 'success';
                N_repetitions                       = 10;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = -10;
                
                All.reward_time                     = 0.1; %
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = 1; % fixation
                All.timing_con                      = 0;
                All.size_con                        = 2;
                All.instructed_choice_con           = [0];
                All.stim_con                        = [0 4]; % 0 4 - no stimulation, 4 - 500ms after beginning of fixation hold
                
             case 'choice target-distractor direct saccades horizontal'
                All.instructed_choice_con           = 1;
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 2;
                All.angle_cases                     = angle_cases_twoOptions;
                All.stim_con                        = stim_con_direct; %Microsimulation                
                All.target_Right                    = [0,1];
            case 'instructed direct saccades'
                All.instructed_choice_con           = 0;
                All.targets_con                     = 0; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_singleOption;
                All.stim_con                        = stim_con_direct;                
                All.target_Right                    = [1];
                All.reward_time                     = 0.16;

            case 'choice target-distractor direct saccades horizontal With Sample Presentation'
                All.instructed_choice_con           = 0;
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_singleOption;
                All.stim_con                        = stim_con_direct;                
                All.target_Right                    = [0,1];
                All.reward_time                     = 0.25;

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
    
    if  n_exp == 0 % pseudo-randomization for fMRI tasks
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
    else
        sequence_matrix          = [sequence_matrix_exp{:}];
        idx_exact_x=ismember(all_fieldnames,'exact_excentricity_con_x');
        idx_exact_y=ismember(all_fieldnames,'exact_excentricity_con_y');
        conditions_to_remove=(sequence_matrix(idx_exact_y,:)==0 & sequence_matrix(idx_exact_x,:)==0);
        sequence_matrix(:,conditions_to_remove)=[];
        ordered_sequence_indexes = 1:(numel([ordered_sequence_indexes_exp{:}])-sum(conditions_to_remove));
        
                % forward & backward approach for the choice of the non-match

%         if All.type_con == 9 || All.type_con == 10
%             IndRotationDiff = find(~cellfun(@isempty, strfind(all_fieldnames, 'rotationDifference')));
%             IndRotation = find(~cellfun(@isempty, strfind(all_fieldnames, 'rotations')));
% 
%         for ind_sequence_matrix = 1: size(sequence_matrix,2)
%         if (sequence_matrix(IndRotation,ind_sequence_matrix) + sequence_matrix(IndRotationDiff,ind_sequence_matrix))> 54
%             sequence_matrix(IndRotationDiff,ind_sequence_matrix) = -sequence_matrix(IndRotationDiff,ind_sequence_matrix);
%         end
%         end
%         end
    end
end

%% Shuffling conditions
if ~exist('dyn','var') || (dyn.trialNumber == 1 && task.shuffle_conditions==0)
    sequence_indexes = ordered_sequence_indexes;
elseif dyn.trialNumber == 1 && (task.shuffle_conditions==1)
    sequence_indexes = Shuffle(ordered_sequence_indexes);
    
    %% forward & backward approach for the choice of the non-match 
    %(sequence_matrix(IndRotation,:) + sequence_matrix(IndRotationDiff,:))
    if All.type_con == 9 || All.type_con == 10
        IndRotationDiff = find(~cellfun(@isempty, strfind(all_fieldnames, 'rotationDifference')));
        IndRotation = find(~cellfun(@isempty, strfind(all_fieldnames, 'rotations')));
        VecRand =  Shuffle([repmat(1,size(sequence_matrix,2)/2,1)'  repmat(-1,size(sequence_matrix,2)/2,1)']);
        sequence_matrix(IndRotationDiff,:) = VecRand.*sequence_matrix(IndRotationDiff,:);
%         for ind_sequence_matrix = 1: size(sequence_matrix,2)
%             if (sequence_matrix(IndRotation,ind_sequence_matrix) + sequence_matrix(IndRotationDiff,ind_sequence_matrix))> 54
%                 sequence_matrix(IndRotationDiff,ind_sequence_matrix) = -sequence_matrix(IndRotationDiff,ind_sequence_matrix);
%             end
%             if (sequence_matrix(IndRotation,ind_sequence_matrix) + sequence_matrix(IndRotationDiff,ind_sequence_matrix))< 18
%                 sequence_matrix(IndRotationDiff,ind_sequence_matrix) = -sequence_matrix(IndRotationDiff,ind_sequence_matrix);
%             end
%         end
        
    end
end

%% Force conditions
if exist('dyn','var') && dyn.trialNumber > 1,
    if task.force_conditions==1 % error trial will be repeated
        switch force_conditions_mode % success as criterion to repeat a trial or not
            case 'success'
                if sum([trial.success])==length(sequence_indexes), 
                    dyn.state = STATE.CLOSE; return
                else
                    custom_trial_condition = sequence_indexes(sum([trial.success])+1);
                end
            case 'target selected' % selection of a target as criterion to repeat a trial or not
                targ_selected = arrayfun(@(x) ~isnan(x.target_selected(1)),trial,'uni',1);
                if sum(targ_selected)==length(sequence_indexes),          
                    dyn.state = STATE.CLOSE; return
                else
                    custom_trial_condition = sequence_indexes(sum(targ_selected)+1);
                end
        end
    elseif task.force_conditions==2 % semi-forced: if trial is not successful, the condition is put back into the pool
        switch force_conditions_mode % success as criterion to put a trial back in pool or not
            case 'success'
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
            case 'target selected' % selection of a target as criterion to put a trial back in pool or not
                if ~isnan(trial(end-1).target_selected(1))                 
                    sequence_indexes=sequence_indexes(2:end);
                else
                    sequence_indexes=Shuffle(sequence_indexes);
                end
                if numel(sequence_indexes)==0
                    dyn.state = STATE.CLOSE; return
                else
                    custom_trial_condition = sequence_indexes(1);
                end
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


%% REWARD TIME
task.reward.time_neutral    = repmat(Current_con.reward_time,1,2);

%% FIXATION OFFSET
fix_eye_x             = Current_con.offset_con;
fix_hnd_x             = fix_eye_x;

%% CHOICE\INSTRUCTED
task.choice                 = Current_con.instructed_choice_con;
task.correct_choice_target  = Current_con.correct_choice_target ;

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con;

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;

%% TASK TIMING

% general timing
task.timing.grace_time_eye          = 0;
task.timing.grace_time_hand         = 0; 
task.timing.fix_time_to_acquire_eye = 0.5; % 0.5
task.timing.fix_time_to_acquire_hnd = 5; % 0.5
task.timing.wait_for_reward         = 0.5;
task.timing.ITI_success             = 1.5;
task.timing.ITI_success_var         = 0;
task.timing.ITI_fail                = 1; %uncompleted errors
task.timing.ITI_fail_var            = 0;
task.timing.ITI_incorrect_completed = 1.5;

task.timing.msk_time_hold=0.01; %0.3; %MASK
task.timing.msk_time_hold_var=0;


switch Current_con.timing_con
    case 0 % 'calibration'
        
        task.timing.grace_time_eye              = 0;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 2;
        task.timing.ITI_fail_var                = 0;                
        task.timing.fix_time_hold               = 2;
        task.timing.fix_time_hold_var           = 0;
        
    case 1 % choice 
        
        task.timing.fix_time_hold               = 0.2; % duration of initial fixation
        task.timing.fix_time_hold_var           = 0.1;
        task.timing.cue_time_hold               = 0.5; % duration of the cue
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0; %  duration of the memory period
        task.timing.mem_time_hold_var           = 0;
        task.timing.tar_time_to_acquire_eye     = 0;
        task.timing.tar_inv_time_to_acquire_eye = 0; %0.5
        task.timing.tar_time_to_acquire_hnd     = 1;
        task.timing.tar_inv_time_to_acquire_hnd = 0; %0.5
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;  
        task.timing.tar_time_hold               = 1; % target hold time
        task.timing.tar_time_hold_var           = 0.2; 
               
end

%% SHAPES of fixation spot and targets
task.eye.fix.shape                  = 'circle'; % 'circle', 'square'
task.hnd.fix.shape                  = 'circle'; % 'circle', 'square'

task.eye.cue(1).shape.mode               = 'circle';
task.hnd.cue(1).shape.mode               = 'circle_withBar';
task.hnd.tar(1).shape.mode               = 'circle_withBar';
task.hnd.tar(2).shape.mode               = 'circle_withBar';
task.hnd.tar(3).shape.mode               = 'circle_withBar';              
task.hnd.cue(1).shape.rotation           = Current_con.rotations;
task.hnd.tar(1).shape.rotation           = Current_con.rotations;
task.hnd.tar(2).shape.rotation           = Current_con.rotations + Current_con.rotationDifference;
task.hnd.tar(3).shape.rotation           = Current_con.rotations;  


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
        
    case 1 % saccades
        
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;       
        task.eye.tar(1).size    = 3;
        task.eye.tar(1).radius  = 5;
        task.hnd.tar(1).size    = 3;
        task.hnd.tar(1).radius  = 5;   


    case 2 
        task.eye.fix.size       = 0.25;
        task.eye.fix.radius     = 50;
        task.eye.tar(1).size    = 0.25;
        task.eye.tar(1).radius  = 50;
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 3; %size of the stimulus
        task.hnd.tar(1).size    = 3;
        task.hnd.tar(1).radius  = 5;
        
end

task.hnd.tar(2).size    = task.hnd.tar(1).size ; % deg
task.hnd.tar(2).radius  = task.hnd.tar(1).radius; % deg
task.hnd.tar(3).size    = task.hnd.tar(1).size ; % deg
task.hnd.tar(3).radius  = task.hnd.tar(1).radius; % deg

%size of the bar
task.hnd.tar(1).shape.BarSize_L    = task.hnd.tar(1).size ;%- 0.1;
task.hnd.tar(1).shape.BarSize_W    = 0.7;
task.hnd.tar(2).shape.BarSize_L    = task.hnd.tar(2).size ;%- 0.1;
task.hnd.tar(2).shape.BarSize_W    = task.hnd.tar(1).shape.BarSize_W; 
task.hnd.tar(3).shape.BarSize_L    = task.hnd.tar(3).size ;%- 0.1;
task.hnd.tar(3).shape.BarSize_W    = task.hnd.tar(1).shape.BarSize_W; 
    

%% COLORS of fixation spot and targets - see D:\Sources\color_luminance_measurements.txt for luminance
task.eye.fix.color_dim          = [0 255 0]; % [60 60 60]; % [128 0 0]
task.eye.fix.color_bright       = [0 255 0]; % [255 0 0]
 
task.hnd_stay.color_dim_fix         = [0 255 0]; %memory period
task.hnd_stay.color_bright_fix      = [0 255 0];
task.hnd_left.color_dim_fix         = [0 255 0];
task.hnd_left.color_bright_fix      = [0 255 0];
task.hnd_right.color_dim_fix        = [0 255 0];
task.hnd_right.color_bright_fix     = [0 255 0];
task.hnd_right.color_dim            = [0 255 0]; 
task.hnd_right.color_bright         = [0 255 0];
task.hnd_left.color_dim             = [0 255 0]; 
task.hnd_left.color_bright          = [0 255 0];
task.hnd_right.color_cue            = [0 255 0]; 
task.hnd_left.color_cue             = [0 255 0]; 

%% CUE assignment: Positions and colors
% same color & shape parameter as target
task.hnd.cue  = task.hnd.tar(1);

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
tar_dis_1y = + tar_dis_y -5;
tar_dis_2x = - tar_dis_x;
tar_dis_2y = + tar_dis_y -5;
tar_dis_3x = -5;
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
        task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
        task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
        task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
        task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
        task.hnd.tar(3).x = fix_hnd_x;
        task.hnd.tar(3).y = fix_hnd_y; % + tar_dis_3y;  

if Current_con.target_Right == 0
        task.hnd.tar(2).x = fix_hnd_x  + tar_dis_1x;
        task.hnd.tar(2).y = fix_hnd_y  + tar_dis_1y;
        task.hnd.tar(1).x = fix_hnd_x  + tar_dis_2x;
        task.hnd.tar(1).y = fix_hnd_y  + tar_dis_2y;   
end

        

%% CUE assignment: Positions
task.hnd.cue(1).x  = fix_hnd_x;
task.hnd.cue(1).y  = fix_hnd_y;


%% How many target should be presented?
% the file prepares three targets which could be shown on different
% positions

switch Current_con.targets_con 
  case 0
task.hnd.tar(3) = [];
task.hnd.tar(2) = [];
task.hnd.cue(1).shape.mode               = 'circle';
task.hnd.tar(1).shape.mode               = 'circle';
  case 1
task.hnd.tar(3) = [];      
  case 2
end     
%% STIMULATION timing
switch Current_con.stim_con
    
    % direct saccades
    case 0 % no stimulation
        task.microstim.stim_on      = 0;
        
    case 1 % 80ms before "go"          
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.08]; % -0.08 send trigger 80ms before end of fixation hold period
        task.microstim.end{1}       = [-0]; % no stimulation triggers after end of fixation hold period
        task.microstim.interval     = 1;
        
    case 2 % at "go"
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0]; % send trigger at beginning of target acquisition state
        task.microstim.end{1}       = [0.2]; % no stimulation triggers after 200ms after beginning of target acquisition state
        task.microstim.interval     = 1;
        
    case 3 % 80ms after "go"
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.08];
        task.microstim.end{1}       = [0.28];
        task.microstim.interval     = 1;
        
    case 4 % 500ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [0.5]; % send trigger 500ms after beginning of fixation hold period
        task.microstim.end{1}       = [0.7];
        task.microstim.interval     = 1;
        
    case 5 % 250ms before "go"          
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.25]; % -0.25 send trigger 250ms before end of fixation hold period
        task.microstim.end{1}       = [-0]; % no stimulation triggers after end of fixation hold period
        task.microstim.interval     = 1;
        
        
    case 6 % 150ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.15]; 
        task.microstim.end{1}       = [-0];
        task.microstim.interval     = 1;
        
    case 7 % 50ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.1]; 
        task.microstim.end{1}       = [-0];
        task.microstim.interval     = 1;
        
        
    case 8 % 150ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.FIX_HOL];
        task.microstim.start{1}     = [-0.05]; 
        task.microstim.end{1}       = [-0];
        task.microstim.interval     = 1;
        
        
    case 9% 50ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.05]; 
        task.microstim.end{1}       = [0.25];
        task.microstim.interval     = 1;
    case 11% 150ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.1]; 
        task.microstim.end{1}       = [0.3];
        task.microstim.interval     = 1;
    case 12% 150ms after beginning of fixation hold to check for evoked saccades
        task.microstim.stim_on      = 1;
        task.microstim.state        = [STATE.TAR_ACQ];
        task.microstim.start{1}     = [0.15]; 
        task.microstim.end{1}       = [0.35];
        task.microstim.interval     = 1;
end

