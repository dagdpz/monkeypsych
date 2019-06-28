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
 %    esperimentazione = {'calibration'};  

% Fixation
 %  esperimentazione = {'fixation'}; 
   
% Direct saccades
 % esperimentazione = {'instructed direct saccades', 'choice target-target direct saccades horizontal', 'choice target-target direct saccades diagonal'};
% Single peripheral stimulus
%     esperimentazione = {'instructed direct saccades'};
%     esperimentazione = {'single distractor direct saccades'};
% Choice
%     esperimentazione = {'choice target-distractor direct saccades horizontal'};
%     esperimentazione = {'choice target-distractor direct saccades diagonal'};
%     esperimentazione = {'choice distractor-distractor direct saccades horizontal'};
%     esperimentazione = {'choice distractor-distractor direct saccades diagonal'};
%     esperimentazione = {'choice target-target direct saccades horizontal'};
%     esperimentazione = {'choice target-target direct saccades diagonal'};
% Combinations   
%    esperimentazione = {'instructed direct saccades','single distractor direct saccades'}; % only single-stimulus conditions
%    esperimentazione = {'instructed direct saccades','single distractor direct saccades','choice target-distractor direct saccades horizontal','choice target-distractor direct saccades diagonal', ...
%        'choice distractor-distractor direct saccades horizontal','choice distractor-distractor direct saccades diagonal' }; % only single-stimulus conditions

%     color discrimination (determination of distractor color)
%     esperimentazione = {'choice target-distractor direct saccades horizontal','choice target-distractor direct saccades diagonal',...
%                         'choice distractor-distractor direct saccades horizontal','choice distractor-distractor direct saccades diagonal',...
%                         'choice target-target direct saccades horizontal','choice target-target direct saccades diagonal'};
%     esperimentazione = {'choice target-distractor direct saccades horizontal','choice distractor-distractor direct saccades horizontal',...
%                         'choice target-target direct saccades horizontal'};
%Experiment
 esperimentazione = {'choice target-distractor direct saccades horizontal','choice target-distractor direct saccades diagonal',...
                         'choice distractor-distractor direct saccades horizontal','choice distractor-distractor direct saccades diagonal',...
                         'choice target-target direct saccades horizontal','choice target-target direct saccades diagonal',...
                         'instructed direct saccades','single distractor direct saccades'};
% %                      
% esperimentazione = { 'choice target-target direct saccades horizontal','choice target-target direct saccades diagonal', 'instructed direct saccades' };
% % % Psychophysic
% esperimentazione = {'choice target-distractor direct saccades horizontal','choice target-distractor direct saccades diagonal',...
%                         'choice distractor-distractor direct saccades horizontal','choice distractor-distractor direct saccades diagonal'};
%%
% Memory saccades
% Single peripheral stimulus
%     esperimentazione = {'instructed memory saccades'};
%     esperimentazione = {'single distractor memory saccades'};
% Choice
%     esperimentazione = {'choice target-distractor memory saccades horizontal'};
%     esperimentazione = {'choice target-distractor memory saccades diagonal'};
%     esperimentazione = {'choice distractor-distractor memory saccades horizontal'};
%     esperimentazione = {'choice distractor-distractor memory saccades diagonal'};
%     esperimentazione = {'choice target-target memory saccades horizontal'};
%     esperimentazione = {'choice target-target memory saccades diagonal'};
% Combinations
%     esperimentazione = {'instructed memory saccades','single distractor memory saccades'}; % only single-stimulus conditions
%
%     color discrimination (determination of distractor color)
%     esperimentazione = {'choice target-distractor memory saccades horizontal','choice target-distractor memory saccades diagonal',...
%                         'choice distractor-distractor memory saccades horizontal','choice distractor-distractor memory saccades diagonal',...
%                         'choice target-target memory saccades horizontal','choice target-target memory saccades diagonal'};
%     esperimentazione = {'choice target-distractor memory saccades horizontal','choice distractor-distractor memory saccades horizontal',...
%                         'choice target-target memory saccades horizontal'};
%     esperimentazione = {'choice target-distractor memory saccades horizontal','choice target-distractor memory saccades diagonal',...
%         'choice distractor-distractor memory saccades diagonal','choice distractor-distractor memory saccades horizontal'};
    SETTINGS.AntiAlisingValue       = 3;
    SETTINGS.VisFeedback_rest_hand  = 1;
    task.hnd.ini(1).x = 0;
    task.hnd.ini(2).x = task.hnd.ini(1).x;
    task.hnd.ini(1).y = 0;
    task.hnd.ini(2).y = task.hnd.ini(1).y;
    task.hnd.ini(1).shape = 'square_frame';
    task.hnd.ini(2).shape = 'square';

    task.hnd.ini(1).size = 1;
    task.hnd.ini(2).size = task.hnd.ini(1).size;
    task.hnd.ini(1).color = [60 60 60];
    task.hnd.ini(2).color = task.hnd.ini(1).color;

    for n_exp = 1:numel(esperimentazione)
        experiment=esperimentazione{n_exp};
        task.calibration                    = 0;
        SETTINGS.GUI_in_acquisition         = 0;
        PEST_ON                             = 0;
        task.rest_hand                      = [0 0];
        
        %% Order of fields here defines the order of parameters to be sent to TDT as the trial_classifiers
        All = struct(...
            'angle_cases',0, 'instructed_choice_con',0, 'type_con',0, 'effector_con',0, 'reach_hand_con',0, 'excentricities',0, 'stim_con',0, 'timing_con',0, 'size_con',0,...
            'shape_con',0, 'offset_con',0, 'exact_excentricity_con_x',NaN, 'exact_excentricity_con_y',NaN, 'colors_con',0, 'targets_con',0, 'reward_time',0, 'correct_choice_target', 0);
        
        %% Tasks
        
        % general settings
        SETTINGS.check_motion_jaw           = 0;
        SETTINGS.check_motion_body          = 0;
        SETTINGS.MonkeyMovedSound           = 0;
        SETTINGS.FixationBreakSound         = 0;
        SETTINGS.WrongTargetSound           = 0;
        
        fix_eye_y                           = 0;
        fix_hnd_y                           = 0;
        
        task.force_conditions               = 2; % 0 - trial will not be repeated, 1 - trial will be repeated immediately, 2 - trial will be put back into the pool of trials
        force_conditions_mode               = 'target selected'; %'target selected'; %'success' 'target selected'
        task.shuffle_conditions             = 1;
        
        pool_of_angles                      = [0,20,340, 180,160,200]; %[0,30,330, 180,150,210] [0,20,340, 180,160,200] % [right-mid right-up right-bottom left-mid left-up left-bottom]
        All.excentricities                  = [20];
        
        All.angle_cases                     = [1,2,3,4,5,6]; %[1,2,3,4,5,6];
        angle_cases_tardist_horz            = All.angle_cases;
        angle_cases_tardist_diag            = [2 3 5 6];
        angle_cases_samesame_horz           = All.angle_cases(1:3);
        angle_cases_samesame_diag           = All.angle_cases(2:3);
        
        All.offset_con                      = 0; % offset of fixation spot (x dimension)
        All.effector_con                    = 0; % 0 - eye
        All.stim_con                        = 0;
        
        reward_memory                       = 0.14;
        reward_direct                       = 0.3; %0.14;
        
        colors_tardist                      = [1 8 ];  % [1 8]  psychphysic curve: [1 5:8]
        colors_distdist                     = [2 12]; % [2 12] [2 9:12]
        colors_dist                         = [4 16]; % [4 16] [4 13:16];
        
        stim_con_direct                     = [0 ]  ; %   [5 7 8] [0 1 2 3]; % stimulation: 0 - no stimulation, 5 - 250ms before "go",7 - 100ms before "go", 3 - 50ms before "go"
        stim_con_memory                     = 0;
        
        N_repetitions_single                = 3; % long: 5; short: 2x2; 1x1;
        N_repetitions_choice                = 3; % long: 3; short: 2x1; 1x1;
        
        switch experiment
            
            case 'calibration'
                
                SETTINGS.check_motion_jaw           = 0;
                SETTINGS.check_motion_body          = 0;                
                
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
                
                pool_of_angles                      = [0];
                All.excentricities                  = [0];
                All.angle_cases                     = [1];
                
                task.force_conditions               = 1;
                force_conditions_mode               = 'success';
                N_repetitions                       = 10;
                
                fix_eye_y                           = 0;
                fix_hnd_y                           = 0;
                
                All.reward_time                     = 0.10; %
                
                All.offset_con                      = 0; % offset of fixation spot
                All.effector_con                    = 0; % effector
                All.type_con                        = 1; % fixation
                All.timing_con                      = 0;
                All.size_con                        = 2;
                All.instructed_choice_con           = [0];
                All.stim_con                        = [0 4]; % 0 4 - no stimulation, 4 - 500ms after beginning of fixation hold
                
            case 'choice target-distractor memory saccades horizontal'
                
                All.reward_time                     = reward_memory; %
                
                All.type_con                        = [3];
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct             
                All.colors_con                      = colors_tardist; % [1 5:8]
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_tardist_horz;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-distractor memory saccades diagonal'
                
                All.reward_time                     = reward_memory; %
                
                All.type_con                        = [3];
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = colors_tardist; % [1 5:8]
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_tardist_diag;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-distractor direct saccades horizontal'
                
                All.reward_time                     = reward_direct; %               

                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct 
                All.colors_con                      = colors_tardist; %[1 5 6 7 8];
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_tardist_horz;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-distractor direct saccades diagonal'
                
                All.reward_time                     = reward_direct; %
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = colors_tardist; %[1 5 6 7 8];
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_tardist_diag;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice distractor-distractor memory saccades horizontal'
                
                All.reward_time                     = reward_memory; %                

                All.type_con                        = 3;
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 3; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct 
                All.colors_con                      = colors_distdist; % [2 9:12]
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_horz;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice distractor-distractor memory saccades diagonal'
                
                All.reward_time                     = reward_memory; %
                
                All.type_con                        = 3;
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 3; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = colors_distdist; % [2 9:12]
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_diag;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice distractor-distractor direct saccades horizontal'
                
                All.reward_time                     = reward_direct; %                
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 3; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct 
                All.colors_con                      = colors_distdist; %[2 9:12];
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_horz;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice distractor-distractor direct saccades diagonal'
                
                All.reward_time                     = reward_direct; %
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 3; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = colors_distdist; %[2 9:12];
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_diag;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-target memory saccades horizontal'
                
                All.reward_time                     = reward_memory; %                
                
                All.type_con                        = 3;
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 0; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct 
                All.colors_con                      = 0;
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_horz;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-target memory saccades diagonal'
                
                All.reward_time                     = reward_memory; %
                
                All.type_con                        = 3;
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 0; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = 0;
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_diag; % only upper and lower positions
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-target direct saccades horizontal'
                
                All.reward_time                     = reward_direct; %
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 0; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = 0;
                All.targets_con                     = 1; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_horz;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'choice target-target direct saccades diagonal'
                
                All.reward_time                     = reward_direct; %
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 0; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = 0;
                All.targets_con                     = 2; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 1;
                All.angle_cases                     = angle_cases_samesame_diag;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_choice;
                
            case 'instructed memory saccades'
                
                All.reward_time                     = reward_memory; %
                
                All.type_con                        = [3];
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = [3];
                All.targets_con                     = 0; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 0;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_single;
                
            case 'instructed direct saccades'
                
                All.reward_time                     = reward_direct; %
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 1; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = 3;
                All.targets_con                     = 0; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 0;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_single;
                
            case 'single distractor memory saccades'
                
                All.reward_time                     = reward_memory; %
                
                All.type_con                        = [3];
                All.timing_con                      = 1;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 2; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = colors_dist;
                All.targets_con                     = 0; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 0;
                All.stim_con                        = stim_con_memory;
                
                N_repetitions                       = N_repetitions_single;
                
            case 'single distractor direct saccades'
                
                All.reward_time                     = reward_direct; %
                
                All.type_con                        = 2;
                All.timing_con                      = 2;
                All.size_con                        = 1;
                All.instructed_choice_con           = [1];
                All.correct_choice_target           = 2; % 0 - targets #1 and #2 correct, 1 - target #1 correct, 2 - target #2 correct, 3 - target #3 correct
                All.colors_con                      = colors_dist; %[4 13:16];
                All.targets_con                     = 0; % 0 - one peripheral stimulus, 1 - two peripheral stimuli horizontal, 2 - two peripheral stimuli diagonal
                All.shape_con                       = 0;
                All.stim_con                        = stim_con_direct;
                
                N_repetitions                       = N_repetitions_single;
                
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

switch Current_con.correct_choice_target;
    case 0 % target #1 and target #2 correct
        task.correct_choice_target  = [1 2];
    case 1 % target #1 correct
        task.correct_choice_target  = 1;
    case 2 % target #2 correct
        task.correct_choice_target  = 2;
    case 3 % target #3 correct
        task.correct_choice_target  = 3;        
end

%% TYPE
task.type                   = Current_con.type_con;

%% EFFECTOR
task.effector               = Current_con.effector_con;

%% REACH hand
task.reach_hand             = Current_con.reach_hand_con;

%% TASK TIMING

% general timing
task.timing.grace_time_eye          = 0;
task.timing.fix_time_to_acquire_eye = 0.5; % 0.5
task.timing.tar_time_to_acquire_eye = 0.5; % 0.5
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
        
    case 1 % choice memory saccades
        
        task.timing.fix_time_hold               = 0.5; %0.5 duration of initial fixation
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.2; % duration of the cue
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0.7; %  duration of the memory period
        task.timing.mem_time_hold_var           = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %0.5
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0;  
        task.timing.tar_time_hold               = 0.3; % target hold time
        task.timing.tar_time_hold_var           = 0; 
        
    case 2 % choice direct saccades
        
        task.timing.fix_time_hold               = 0.5;%0.5
        task.timing.fix_time_hold_var           = 0.4; %0.4
        task.timing.tar_time_hold               = 0.5; %% 0.5
        task.timing.tar_time_hold_var           = 0.0;
        
end

%% SHAPES of fixation spot and targets

task.eye.fix.shape                  = 'circle'; % 'circle', 'square'
task.hnd.fix.shape                  = 'circle'; % 'circle', 'square'

switch Current_con.shape_con
    
    case 0 % one peripheral target, one fixation target
        
        task.eye.tar(1).shape               = 'circle';
        task.eye.tar(2).shape               = 'circle';
        task.hnd.tar(1).shape               = 'circle';
        task.hnd.tar(2).shape               = 'circle';       
        
        task.eye.cue(1).shape               = 'circle';
        task.eye.cue(2).shape               = 'circle';
        task.hnd.cue(1).shape               = 'circle';
        task.hnd.cue(2).shape               = 'circle';
        
    case 1 % two peripheral targets, one fixation target
        
        task.eye.tar(1).shape               = 'circle';
        task.eye.tar(2).shape               = 'circle';
        task.eye.tar(3).shape               = 'circle';
        task.hnd.tar(1).shape               = 'circle';
        task.hnd.tar(2).shape               = 'circle';
        task.hnd.tar(3).shape               = 'circle';
        
        task.eye.cue(1).shape               = 'circle';
        task.eye.cue(2).shape               = 'circle';
        task.eye.cue(3).shape               = 'circle';
        task.hnd.cue(1).shape               = 'circle';
        task.hnd.cue(2).shape               = 'circle';
        task.hnd.cue(3).shape               = 'circle';
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
        
    case 1 % saccades
        
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5; %5
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5; %5
        
        task.hnd.fix.radius     = 4; %4
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;   
        
    case 2 %'fixation'
        task.eye.fix.size       = 0.25;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.25;
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

if Current_con.targets_con == 1 || Current_con.targets_con == 2
    
    task.eye.tar(3).size    = task.eye.tar(1).size;
    task.hnd.tar(3).size    = task.hnd.tar(1).size ; % deg
    task.eye.tar(3).radius  = task.eye.tar(1).radius;
    task.hnd.tar(3).radius  = task.hnd.tar(1).radius; % deg
    
end

%% TARGET POSITIONS

    current_angle=pool_of_angles(Current_con.angle_cases); %
    tar_dis_x   = Current_con.excentricities*cos(current_angle*2*pi/360);
    tar_dis_y   = Current_con.excentricities*sin(current_angle*2*pi/360);

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
switch Current_con.targets_con
    
    case 0 % one peripheral target, one fixation target (instructed)
        
        task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
        task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
        task.eye.tar(2).x = fix_eye_x;
        task.eye.tar(2).y = fix_eye_y;
        
    case 1 % two peripheral targets presented on a horizontal line either in the upper or lower hemifield or on the midline, one fixation target (choice)

        task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
        task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
        task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
        task.eye.tar(2).y = fix_eye_y  + tar_dis_2y;
        task.eye.tar(3).x = fix_eye_x;
        task.eye.tar(3).y = fix_eye_y; % + tar_dis_3y;
        
        task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
        task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
        task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
        task.hnd.tar(2).y = fix_hnd_y  + tar_dis_2y;
        task.hnd.tar(3).x = fix_hnd_x;
        task.hnd.tar(3).y = fix_hnd_y; % + tar_dis_3y;
        
    case 2 % two peripheral targets presented on a diagonal line, i.e. if one stimulus is up left the second stimulus is bottom right, one fixation target (choice)

        task.eye.tar(1).x = fix_eye_x  + tar_dis_1x;
        task.eye.tar(1).y = fix_eye_y  + tar_dis_1y;
        task.eye.tar(2).x = fix_eye_x  + tar_dis_2x;
        task.eye.tar(2).y = fix_eye_y  - tar_dis_2y;
        task.eye.tar(3).x = fix_eye_x;
        task.eye.tar(3).y = fix_eye_y;
        
        task.hnd.tar(1).x = fix_hnd_x  + tar_dis_1x;
        task.hnd.tar(1).y = fix_hnd_y  + tar_dis_1y;
        task.hnd.tar(2).x = fix_hnd_x  + tar_dis_2x;
        task.hnd.tar(2).y = fix_hnd_y  - tar_dis_2y;
        task.hnd.tar(3).x = fix_hnd_x;
        task.hnd.tar(3).y = fix_hnd_y;
end
        
%% COLORS of fixation spot and targets - see D:\Sources\color_luminance_measurements.txt for luminance

task.eye.fix.color_dim          = [128 0 0]; % [60 60 60]; % [128 0 0]
task.eye.fix.color_bright       = [255 0 0]; % [255 0 0]
      
switch Current_con.colors_con
    
    % conditions with basic distractor color
    case 0 % choice target-target saccades
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];         
        task.eye.tar(2).color_dim       = task.eye.tar(1).color_dim; % red target
        task.eye.tar(2).color_bright    = task.eye.tar(1).color_bright;
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
        % luminance test
%         task.eye.tar(2).color_dim       = [128 0 0]; 
%         task.eye.tar(2).color_bright    = [255 0 0];        
        
    case 1 % choice target-distractor saccades
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [60 60 0]; % yellow distractor, in setup 1 [123 123 0] same luminance as [255 0 0]
        task.eye.tar(2).color_bright    = [123 123 0];
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 2 % choice distractor-distractor saccades
        
        task.eye.tar(1).color_dim       = [60 60 0]; % yellow distractor
        task.eye.tar(1).color_bright    = [123 123 0];
        task.eye.tar(2).color_dim       = [60 60 0]; % yellow distractor
        task.eye.tar(2).color_bright    = [123 123 0];
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 3 % instructed saccades
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(2).color_bright    = [110 110 110];
        
        if numel(task.eye.tar) == 3
            task.eye.tar(3) = [];
        end
        
    case 4 % instructed saccades, only distractor
        
        task.eye.tar(1).color_dim       = [60 60 0]; % yellow distractor
        task.eye.tar(1).color_bright    = [123 123 0];
        task.eye.tar(2).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(2).color_bright    = [110 110 110];
        
        if numel(task.eye.tar) == 3
            task.eye.tar(3) = [];
        end
        
        
    % conditions with intermediate distractor colors
    case 5 % choice target-distractor saccades
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [126 30 0]; % distractor %95 59 0
        task.eye.tar(2).color_bright    = [220 40 0]; %185 90 0
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 6 
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [128 23 0]; % distractor %113 42 0
        task.eye.tar(2).color_bright    = [228 20 0]; %205 60 0
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 7
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [128 18 0]; % distractor
        task.eye.tar(2).color_bright    = [228 20 0];
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 8 
        
        task.eye.tar(1).color_dim       = [128 0 0]; % red target
        task.eye.tar(1).color_bright    = [255 0 0];
        task.eye.tar(2).color_dim       = [128 11 0]; % distractor  Corny: [128 11 0]
        task.eye.tar(2).color_bright    = [228 20 0];
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
        
    case 9 % choice distractor-distractor saccades
        
        task.eye.tar(1).color_dim       = [126 30 0]; % distractor
        task.eye.tar(1).color_bright    = [220 40 0];
        task.eye.tar(2).color_dim       = [126 30 0]; % distractor %95 59 0
        task.eye.tar(2).color_bright    = [220 40 0]; %185 90 0
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 10
        
        task.eye.tar(1).color_dim       = [128 23 0]; % distractor
        task.eye.tar(1).color_bright    = [228 20 0];
        task.eye.tar(2).color_dim       = [128 23 0]; % distractor %113 42 0
        task.eye.tar(2).color_bright    = [228 20 0]; %205 60 0
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 11 
        
        task.eye.tar(1).color_dim       = [128 18 0]; % distractor
        task.eye.tar(1).color_bright    = [228 20 0];
        task.eye.tar(2).color_dim       = [128 18 0]; % distractor %126 30 0
        task.eye.tar(2).color_bright    = [228 20 0]; %220 40 0
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
    case 12
        
        task.eye.tar(1).color_dim       = [128 11 0]; % distractor
        task.eye.tar(1).color_bright    = [228 20 0];
        task.eye.tar(2).color_dim       = [128 11 0]; % distractor %128 23 0
        task.eye.tar(2).color_bright    = [228 20 0]; % 228 20 0
        task.eye.tar(3).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(3).color_bright    = [110 110 110];
        
        
    case 13 % instructed saccades, only distractor
        
        task.eye.tar(1).color_dim       = [95 59 0]; % distractor
        task.eye.tar(1).color_bright    = [185 90 0];
        task.eye.tar(2).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(2).color_bright    = [110 110 110];
        
        if numel(task.eye.tar) == 3
            task.eye.tar(3) = [];
        end
        
    case 14
        
        task.eye.tar(1).color_dim       = [113 42 0]; % distractor
        task.eye.tar(1).color_bright    = [205 60 0];
        task.eye.tar(2).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(2).color_bright    = [110 110 110];
        
        if numel(task.eye.tar) == 3
            task.eye.tar(3) = [];
        end 
        
    case 15 
        
        task.eye.tar(1).color_dim       = [126 30 0]; % distractor
        task.eye.tar(1).color_bright    = [220 40 0];
        task.eye.tar(2).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(2).color_bright    = [110 110 110];
        
        if numel(task.eye.tar) == 3
            task.eye.tar(3) = [];
        end
        
    case 16
        
        task.eye.tar(1).color_dim       = [128 11 0]; % distractor for Curius[128 18 0]  %% distractor for Cornelius [128 11 0]
        task.eye.tar(1).color_bright    = [228 20 0];
        task.eye.tar(2).color_dim       = [60 60 60]; % fixation target
        task.eye.tar(2).color_bright    = [110 110 110];
        
        if numel(task.eye.tar) == 3
            task.eye.tar(3) = [];
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

% new colors dim
% [95 59 0]
% [113 42 0]
% [126 30 0]
% [128 23 0]

% new colors bright
% [185 90 0] for [95 59 0]
% [205 60 0] for [113 42 0]
% [220 40 0] for [126 30 0]
% [228 20 0] for [128 23 0]

%% CUE assignment: Positions and colors

% same positions as targets
task.eye.cue  = task.eye.tar;
task.hnd.cue  = task.hnd.tar;

% colors
switch Current_con.colors_con
    
    case 0 % choice target-target saccades 
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = task.eye.cue(1).color_dim;
        task.eye.cue(2).color_bright    = task.eye.cue(1).color_bright;
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 1 % choice target-distractor saccades
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = [60 60 0];
        task.eye.cue(2).color_bright    = [60 60 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
            
    case 2 % choice distractor-distractor saccades
        
        task.eye.cue(1).color_dim       = [60 60 0];
        task.eye.cue(1).color_bright    = [60 60 0];
        task.eye.cue(2).color_dim       = [60 60 0];
        task.eye.cue(2).color_bright    = [60 60 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 3 % instructed saccades
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = [110 110 110];
        task.eye.cue(2).color_bright    = [110 110 110];
        
        if numel(task.eye.cue) == 3
            task.eye.cue(3) = [];
        end
        
    case 4 % instructed saccades, only distractor
        
        task.eye.cue(1).color_dim       = [60 60 0];
        task.eye.cue(1).color_bright    = [60 60 0];
        task.eye.cue(2).color_dim       = [110 110 110];
        task.eye.cue(2).color_bright    = [110 110 110];
         
        if numel(task.eye.cue) == 3
            task.eye.cue(3) = [];
        end
        
        
        % conditions with intermediate distractor colors
    case 5 % choice target-distractor saccades
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = [126 30 0]; %95 59 0
        task.eye.cue(2).color_bright    = [126 30 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
    
    case 6
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = [128 23 0];
        task.eye.cue(2).color_bright    = [128 23 0]; %[113 42 0]
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 7 
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = [128 18 0]; %126 30 0
        task.eye.cue(2).color_bright    = [128 18 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 8
        
        task.eye.cue(1).color_dim       = [128 0 0];
        task.eye.cue(1).color_bright    = [128 0 0];
        task.eye.cue(2).color_dim       = [128 11 0]; %128 23 0
        task.eye.cue(2).color_bright    = [128 11 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
        
    case 9 % choice distractor-distractor saccades
        
        task.eye.cue(1).color_dim       = [126 30 0];
        task.eye.cue(1).color_bright    = [126 30 0];
        task.eye.cue(2).color_dim       = [126 30 0]; %95 59 0
        task.eye.cue(2).color_bright    = [126 30 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 10 
        
        task.eye.cue(1).color_dim       = [128 23 0];
        task.eye.cue(1).color_bright    = [128 23 0];
        task.eye.cue(2).color_dim       = [128 23 0]; %113 42 0
        task.eye.cue(2).color_bright    = [128 23 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 11
        
        task.eye.cue(1).color_dim       = [126 18 0];
        task.eye.cue(1).color_bright    = [126 18 0];
        task.eye.cue(2).color_dim       = [128 18 0]; %126 30 0
        task.eye.cue(2).color_bright    = [128 18 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
    case 12
        
        task.eye.cue(1).color_dim       = [128 11 0];
        task.eye.cue(1).color_bright    = [128 11 0];
        task.eye.cue(2).color_dim       = [128 11 0]; %128 23 0
        task.eye.cue(2).color_bright    = [128 11 0];
        task.eye.cue(3).color_dim       = [110 110 110];
        task.eye.cue(3).color_bright    = [110 110 110];
        
        
    case 13 % instructed saccades, only distractor
        
        task.eye.cue(1).color_dim       = [95 59 0];
        task.eye.cue(1).color_bright    = [95 59 0];
        task.eye.cue(2).color_dim       = [110 110 110];
        task.eye.cue(2).color_bright    = [110 110 110];
        
        if numel(task.eye.cue) == 3
            task.eye.cue(3) = [];
        end
        
    case 14
        
        task.eye.cue(1).color_dim       = [113 42 0];
        task.eye.cue(1).color_bright    = [113 42 0];
        task.eye.cue(2).color_dim       = [110 110 110];
        task.eye.cue(2).color_bright    = [110 110 110];
        
        if numel(task.eye.cue) == 3
            task.eye.cue(3) = [];
        end
        
    case 15
        
        task.eye.cue(1).color_dim       = [126 30 0];
        task.eye.cue(1).color_bright    = [126 30 0];
        task.eye.cue(2).color_dim       = [110 110 110];
        task.eye.cue(2).color_bright    = [110 110 110];
         
        if numel(task.eye.cue) == 3
            task.eye.cue(3) = [];
        end
        
    case 16
        
        task.eye.cue(1).color_dim       = [128 11 0];
        task.eye.cue(1).color_bright    = [128 11 0];
        task.eye.cue(2).color_dim       = [110 110 110];
        task.eye.cue(2).color_bright    = [110 110 110];
         
        if numel(task.eye.cue) == 3
            task.eye.cue(3) = [];
        end
        
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
