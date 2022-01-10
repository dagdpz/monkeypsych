%% Initiate conditions
global SETTINGS
    
    
if ~exist('dyn','var') || dyn.trialNumber == 1   

experiment='calibration' ;  
%experiment='Memory reaches' ;  

%experiment='vpx_calibration' ; 
%experiment='Learning memory saccades' ;      
%experiment='Match to sample saccades' ; 

%experiment='Learning memory saccades' ; 
%experiment='dissociated test' ; 
%experiment='Match to sample saccades' ;         
%experiment='Learning memory saccades';   %lini
%     %experiment='RF mapping memory saccades';    
%  experiment='Baseline stim project direct saccades';    %lini
%  experiment='Baseline stim project memory saccades';    %lini
%  experiment='Baseline stim project direct reaches';   
%   experiment='Baseline stim project memory dissociated reaches';   

%experiment='Match to sample saccades'; 
%   experiment='Baseline stim project memory saccades';
%     experiment='RF Mapping'; 
    % Presettings (not to change here !)
    
    task.shuffle_conditions         = 1;
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
        
        % replace fix_eye_y with task.reference_height_deg
        case 'vpx_calibration'
            SETTINGS.vpx_calibration    = 1;
            n_calibration_points        = 36;
            
            SETTINGS.check_motion_jaw   = 0;  
            SETTINGS.GUI_in_acquisition = 1;
            task.shuffle_conditions          = 1;
            task.force_conditions            = 0;
            task.calibration            = 1;
            
            N_repetitions               = 1;
            task.reward.time_neutral    = [0.03 0.03]; 
            task.rest_hand              = [0 0];         
            
            fix_eye_y                   = 0;
            fix_hnd_y                   = 10;
            fix_offset                  = 0;
            tar_angle                   = 20; %in degrees
            
            
            
%             tar_excentricity            = 20;
%             tar_angle                   = 20; %in degrees
            pool_of_angles              =[1:36];
            
            All.type_con                    = 1; 
            All.effector_con                = 0;
            All.reach_hand_con              = 2;
            All.timing_con                  = 10;
            All.size_con                    = 10;
            
            All.excentricities              = [20];   
           All.angle_cases                 = [1:6:31,2:6:32,3:6:33,4:6:34,5:6:35];    
            %All.angle_cases                 = [1:16];    
            
            %All.tar_pos_con                 = [1,2,5:8];      
            PEST_ON                         = 0;            
            SETTINGS.GUI_in_acquisition     = 1;
            
            vpx_SendCommandString(['calibration_points',blanks(1),num2str(n_calibration_points)]);            
            vpx_SendCommandString('calibration_snapMode ON');
            vpx_SendCommandString('calibration_autoIncrement ON');
        case 'calibration'
            SETTINGS.check_motion_jaw       = 0;  
            SETTINGS.GUI_in_acquisition     = 1;
            task.shuffle_conditions          = 1;
            task.force_conditions            = 2;
            task.calibration            = 1;
            
            N_repetitions               = 2;
            task.reward.time_neutral    = [0.03 0.03]; 
            task.rest_hand              = [0 0];         
            
            %fix_eye_y                   = 0;
            fix_eye_y                   = 0;
            fix_hnd_y                   = 10;
            fix_offset                  = 0;
            tar_angle                   = 20; %in degrees
%             tar_excentricity            = 20;
%             tar_angle                   = 20; %in degrees
            %pool_of_angles              =[17.5,0,342.5,162.5,180,197.5]; 
            pool_of_angles              =[19.8,0,340.2,160.2,180,199.8]; 
            
            All.type_con                    = 2; 
            All.effector_con                = 0;
            All.reach_hand_con              = 2;
            All.timing_con                  = 0;
            All.size_con                    = 0;
            
            %All.excentricities              = [25.2];   
            All.excentricities              = [28.4];   
            All.angle_cases                 = [1,3,4,6];    
            
            %All.tar_pos_con                 = [1,2,5:8];      
            PEST_ON                         = 0;            
            SETTINGS.GUI_in_acquisition     = 1;
            
        case 'dissociated test'
            SETTINGS.check_motion_jaw       = 0;  
            SETTINGS.GUI_in_acquisition     = 1;
            task.shuffle_conditions          = 1;
            task.force_conditions            = 1;
            task.calibration            = 0;
            
            N_repetitions               = 2;
            task.reward.time_neutral    = [0.03 0.03]; 
            task.rest_hand              = [0 0];         
            
            fix_eye_y                   = 0;
            fix_hnd_y                   = -4;
            fix_offset                  = 0;
            tar_angle                   = 20; %in degrees
%             tar_excentricity            = 20;
%             tar_angle                   = 20; %in degrees
            pool_of_angles              =[20,0,340,160,180,200]; 
            
            All.type_con                    = 4; 
            All.effector_con                = 4;
            All.reach_hand_con              = 2;
            All.timing_con                  = 4;
            All.size_con                    = -1;
            
            All.excentricities              = [20];   
            All.angle_cases                 = [1,2,3,4,5,6];    
            
            %All.tar_pos_con                 = [1,2,5:8];      
            PEST_ON                         = 0;            
            SETTINGS.GUI_in_acquisition     = 1;
                
        case 'Baseline stim project direct saccades'
            SETTINGS.check_motion_jaw       = 1;            
            task.force_conditions                = 2;            
            N_repetitions                   = 10;
            task.reward.time_neutral        = [0.07 0.07];   % 0.45s -> 0.15ml per hit
            task.rest_hand                  = [0 0];      
            
            fix_eye_y                       = 20;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160]; 
            
            All.type_con                    = 2; 
            All.effector_con                = 0;
            All.timing_con                  = 2;
            All.size_con                    = 2;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [12,24];   
            All.angle_cases                 = [1,2,3,4,5,6];   
            All.stim_con                    = [0];  
            if PEST_ON==1
                All.stim_con                = 0;                
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end
            
        case 'Baseline stim project memory saccades'
            SETTINGS.check_motion_jaw       = 1;                
            task.force_conditions                = 2;            
            N_repetitions                   = 20;
            task.reward.time_neutral        = [0.08 0.08]; % 0.6s -> 0.2ml per hit
            task.rest_hand                  = [0 0];             
            
            fix_eye_y                       = 20;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160]; 
            
            All.type_con                    = 3; 
            All.effector_con                = 0;
            All.timing_con                  = 31;
            All.size_con                    = 3;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [12,24];   
            All.angle_cases                 = [1,2,3,4,5,6];  
            All.stim_con                    = [0];     
            if PEST_ON==1
                All.stim_con                = 0;            
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end
            
        case 'Baseline stim project direct reaches'
            SETTINGS.check_motion_jaw       = 1;            
            task.force_conditions                = 2;            
            N_repetitions                   = 10;
            task.reward.time_neutral        = [0.1 0.1];   % 0.45s -> 0.15ml per hit
            task.rest_hand                  = [1 1];      
            
            
            fix_eye_y                       = 20;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160]; 
            
            All.reach_hand_con              = 2;
            All.type_con                    = 2; 
            All.effector_con                = 6;
            All.timing_con                  = 2;
            All.size_con                    = 2;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [12,24];   
            All.angle_cases                 = [1,2,3,4,5,6];   
            All.stim_con                    = [0];  
            if PEST_ON==1
                All.stim_con                = 0;                
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end
            
        case 'Baseline stim project memory dissociated reaches '
            SETTINGS.check_motion_jaw       = 1;
            task.force_conditions                = 2;
            N_repetitions                   = 10;
            task.reward.time_neutral        = [0.2 0.2];   % 0.45s -> 0.15ml per hit
            task.rest_hand                  = [1 1];
            
            fix_eye_y                       = 20;
            fix_hnd_y                       = 15;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160];
            
            All.reach_hand_con              = 2;
            All.type_con                    = 3;
            All.effector_con                = 4;
            All.timing_con                  = 31;
            All.size_con                    = 3;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [12,24];
            All.angle_cases                 = [1,2,3,4,5,6];
            All.stim_con                    = [0];
            if PEST_ON==1
                All.stim_con                = 0;
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end
            
        case 'Learning memory saccades'
            SETTINGS.check_motion_jaw       = 0;                
            task.force_conditions                = 1;            
            N_repetitions                   = 50;
            task.reward.time_neutral        = [0.06 0.06]; % 0.6s -> 0.2ml per hit
            task.rest_hand                  = [0 0];             
            
            fix_eye_y                       = 0;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            %pool_of_angles                  =[20,0,340,200,180,160]; 
            
            pool_of_angles              =[17.5,0,342.5,162.5,180,197.5]; 
            
            All.type_con                    = 3; 
            All.effector_con                = 0;
            All.timing_con                  = 32;
            All.size_con                    = 32;
            All.instructed_choice_con       = [0];
            %All.excentricities              = [12,24];   
            All.excentricities              = [25.2];   
            %All.angle_cases                 = [1,2,3,4,5,6]; 
            All.angle_cases                 = [1,3,4,6];   
            All.stim_con                    = [0];     
            if PEST_ON==1
                All.stim_con                = 0;            
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end    
            
             
        case 'RF mapping memory reaches'
            
            task.force_conditions                =2;
            
            N_repetitions                   = 5;
            task.reward.time_neutral        = [0.1 0.1];
            task.rest_hand                  = [1 1];      
            
            fix_eye_y                       = 14;
            fix_hnd_y                       = 10;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  = [20,0,340,160,180,200]; 
            
            All.type_con                    = 3; 
            All.effector_con                = 1;
            All.reach_hand_con              = 2;
            All.timing_con                  = 2;
            All.size_con                    = 2;
            All.excentricities              = [12];   
            All.angle_cases                 = [1,2,3,4,5,6];       
            PEST_ON                         = 0;
            
        case 'RF mapping memory saccades'
            
            task.force_conditions                = 2;
            
            N_repetitions                   = 15;
            task.reward.time_neutral        = [0.07 0.07];
            task.rest_hand                  = [0 0];         
            
            fix_eye_y                       = 15;
            fix_hnd_y                       = 11;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,160,180,200]; 
            
            All.type_con                    = 3; 
            All.effector_con                = 0;
            All.timing_con                  = 3;
            All.size_con                    = 3;
            All.excentricities              = [24];   
            All.angle_cases                 = [1,2,3,4,5,6];   
            
        case 'Direct saccades stim'
            
            task.force_conditions                = 2;
            
            N_repetitions                   = 10;
            task.reward.time_neutral        = [0.04 0.04];  
            task.rest_hand                  = [0 0];       
            
            fix_eye_y                       = 20;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160]; 
            
            All.type_con                    = 2; 
            All.effector_con                = 0;
            All.timing_con                  = 2;
            All.size_con                    = 2;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [24];   
            All.angle_cases                 = [1,2,3,4,5,6];  
            All.stim_con                    = [0:7];  
%             All.stim_con                    = [1];   
            if PEST_ON==1
                All.stim_con                = 0;                
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end
            
        case 'Memory reaches'
            
            task.force_conditions                = 2;
            
            N_repetitions                   = 10;
            task.reward.time_neutral        = [0.1 0.1];  
            task.rest_hand                  = [1 1];              
            
            fix_eye_y                       = 0;
            fix_hnd_y                       = -4;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160]; 
            
            All.type_con                    = 1; 
            All.effector_con                = 1;
            All.timing_con                  = 3;
            All.size_con                    = 2;
            All.instructed_choice_con       = [0];
            All.excentricities              = [15];   
            All.angle_cases                 = [1,2,3,4,5,6];  
            All.stim_con                    = [0];  
            All.reach_hand_con              = [2];
%            All.stim_con                    = [0,2,9,10,11];    
            if PEST_ON==1
                All.stim_con                = 0;            
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end    
            
        case 'Memory saccades stim'
            
            task.force_conditions                = 2;
            
            N_repetitions                   = 5;
            task.reward.time_neutral        = [0.06 0.06];  
            task.rest_hand                  = [0 0];              
            
            fix_eye_y                       = 20;
            fix_hnd_y                       = 16;
            fix_offset                      = 0;
            tar_angle                       = 20; %in degrees
            pool_of_angles                  =[20,0,340,200,180,160]; 
            
            All.type_con                    = 2; 
            All.effector_con                = 0;
            All.timing_con                  = 3;
            All.size_con                    = 3;
            All.instructed_choice_con       = [0,1];
            All.excentricities              = [24];   
            All.angle_cases                 = [1,2,3,4,5,6];  
            All.stim_con                    = [0];  
%            All.stim_con                    = [0,2,9,10,11];    
            if PEST_ON==1
                All.stim_con                = 0;            
                PEST_hnd_or_eye='eye';
                PEST_effector=1;
            end
        case 'Match to sample saccades'
            
            SETTINGS.GUI_in_acquisition     = 1;
            task.force_conditions                = 2;
            multiple_targets_per_trial      = 4;%1;3
            
            N_repetitions                   = 3;
            task.reward.time_neutral        = [0.13 0.13];
            task.rest_hand                  = [0 0];    
            
            fix_eye_y             = 18;
            fix_hnd_y             = 16;
            fix_offset            = 0;
            tar_angle             = 20; %in degrees
            pool_of_angles        = [20,0,340,160,180,200]; 
%             tar_excentricity      = 16; %excentricity of center of target array LR 
%             tar_angle             = 20; %in degrees
            
            f_h                   = fix_eye_y;
            fix_height            = f_h;
            d_pos                 = 8;    %relative shift of target positions
            ex_cue                = 7;%7;%15;  %cue_excentricity
            
            
            All.type_con                    = 6; 
            All.effector_con                = 0;
            All.timing_con                  = 5;
            All.size_con                    = 5;
            All.instructed_choice_con       = 0;
            %All.tar_pos_con                 = 99; 
            All.excentricities              = [16];   
            All.angle_cases                 = [1];          
            All.tar_dis_con                 = 7;%0;%[12,13];%[14,15];%[8,9];%[12,13];       
            All.mat_dis_con                 = 1:4;%2:3;%1:4;%2:3;   %2:3     
            All.cue_pos_con                 = 1:2;
            All.shape_con                   = 9:12;%[10,11];%10;%9:12;%[5:8];%[1:4];%[9:12];%
            PEST_ON=0;
        case 'RF Mapping'
            SETTINGS.check_motion_jaw       = 1;  
            shuffle_angles_per_trial        = 1;
            task.force_conditions                = 2; %0 for not forcing 
                                                 %1 forced to succeed to proceed in conditions 
                                                 %2 put back to the pool of conditions if error
            
            SETTINGS.GUI_in_acquisition     = 1;
            multiple_targets_per_trial      = 2;
            
            N_repetitions                   = 1;
            task.reward.time_neutral        = [0.04 0.04];
            task.rest_hand                  = [0 0];    
            
            fix_eye_y             = 18;
            fix_hnd_y             = 16;
            fix_offset            = 0;
            tar_angle             = 20; %in degrees
            pool_of_angles        = [20,0,340,200,180,160]; 
%             tar_excentricity      = 16; %excentricity of center of target array LR 
%             tar_angle             = 20; %in degrees
            
            f_h                   = fix_eye_y;
            fix_height            = f_h;
            d_pos                 = 5;    %relative shift of target positions
            ex_cue                = 15;  %cue_excentricity
            
            
            All.type_con                    = 8; 
            All.effector_con                = 0;
            All.timing_con                  = 8;
            All.size_con                    = 5;
            All.instructed_choice_con       = 0;
            %All.tar_pos_con                 = 99; 
            All.excentricities              = [15,30];   
            All.angle_cases                 = [1,2,3,4,5,6];          
            All.tar_dis_con                 = [12,13];%[14,15];%[8,9];%[12,13];       
            All.mat_dis_con                 = 1:4;        
            All.cue_pos_con                 = 1:2;
            All.shape_con                   = [1:4];%[1:4];%[5:8];[1:4];%
            PEST_ON=0;
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
if PEST_ON==1
    stepsize_min          = 0.3;
    fix_limits            = [-40+Current_con.excentricities 40-Current_con.excentricities];
    
    if exist('dyn','var') && dyn.trialNumber > 1
        selected_target_t=trial(dyn.trialNumber-1).target_selected(PEST_effector);
        if isempty(selected_target_t) || isnan(selected_target_t) || trial(dyn.trialNumber-1).success==0 || trial(dyn.trialNumber-1).choice==0
            r_chosen(dyn.trialNumber-1)=false;
            l_chosen(dyn.trialNumber-1)=false;
        else
            r_chosen(dyn.trialNumber-1)=[trial(dyn.trialNumber-1).(PEST_hnd_or_eye).tar(selected_target_t).pos(1) - trial(dyn.trialNumber-1).(PEST_hnd_or_eye).fix.pos(1)]>0;
            l_chosen(dyn.trialNumber-1)=[trial(dyn.trialNumber-1).(PEST_hnd_or_eye).tar(selected_target_t).pos(1) - trial(dyn.trialNumber-1).(PEST_hnd_or_eye).fix.pos(1)]<0;
        end
        any_chosen_idx=find(any([r_chosen; l_chosen],1));
    else
        any_chosen_idx=[];
    end    
    if numel(any_chosen_idx)>1
        preferred_behaviour=any(r_chosen(any_chosen_idx(end-1:end))) && any(l_chosen(any_chosen_idx(end-1:end)));
        if r_chosen(dyn.trialNumber-1) || l_chosen(dyn.trialNumber-1)
            [fix_eye_x stepsize] = PEST(fix_eye_x,fix_limits,r_chosen(dyn.trialNumber-1),preferred_behaviour,stepsize,stepsize_min);
        end
    else
        stepsize              = 1;
        fix_eye_x             = 0;
    end
    PEST_list(dyn.trialNumber)=fix_eye_x;
             %stepsize
             %PEST_list
    if stepsize<=stepsize_min
            dyn.state = STATE.CLOSE; 
            PEST_list
            return
    end
else
    fix_eye_x             = fix_offset;
end
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
    case 0 % 'calibration'
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
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 0.8;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.5;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0;
        
    case 10 % 'vpx calibration'
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
        task.timing.tar_inv_time_to_acquire_hnd = 1;
        task.timing.fix_time_to_acquire_eye     = 0.5;
        task.timing.tar_time_to_acquire_eye     = 0.5;
        task.timing.tar_inv_time_to_acquire_eye = 0.5; %3
        task.timing.fix_time_hold               = 1.2;
        task.timing.fix_time_hold_var           = 0;
        task.timing.cue_time_hold               = 0.5;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0;
        
    case 1 %'fixation'
        
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
        task.timing.fix_time_hold               = 0.8;
        task.timing.fix_time_hold_var           = 0;
        task.timing.cue_time_hold               = 0.3;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 1.5;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 1.5;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.2;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
        
    case 2 %'direct'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 3;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 2;
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
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 3 %'memory stim'
        
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
        task.timing.fix_time_hold               = 0.4;
        task.timing.fix_time_hold_var           = 0.3;
        task.timing.cue_time_hold               = 0.28;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0.2;
        task.timing.mem_time_hold_var           = 0.2;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.1;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 31 %'memory ephys'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 2.5;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 2;
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
        task.timing.mem_time_hold               = 1;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0.1;
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
        
    case 4 %'delay'
        
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
        task.timing.del_time_hold               = 0.5;
        task.timing.del_time_hold_var           = 0.5;
        task.timing.tar_inv_time_hold           = 0.1;
        task.timing.tar_inv_time_hold_var       = 0.0;
        task.timing.tar_time_hold               = 0.5;
        task.timing.tar_time_hold_var           = 0.0;
        
        
    case 5 %'Match to sample'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts        
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 1;
        task.timing.ITI_fail_var                = 2;        
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;        
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 4;
        task.timing.tar_inv_time_to_acquire_hnd = 4;        
        task.timing.fix_time_to_acquire_eye     = 1;
        task.timing.tar_time_to_acquire_eye     = 10;
        task.timing.tar_inv_time_to_acquire_eye = 4; %3        
        task.timing.fix_time_hold               = 0.2;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.6;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0; %% 0.2
        task.timing.mem_time_hold_var           = 0; %% 0.3
        task.timing.del_time_hold               = 0;
        task.timing.del_time_hold_var           = 0;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.6;
        task.timing.tar_time_hold_var           = 0.0;
        
    case 8 %'RF Mapping'
        
        task.rest_sensors_ini_time              = 0.5; % s, time to hold sensor(s) in initialize_trial before trial starts        
        task.timing.wait_for_reward             = 0.2;
        task.timing.ITI_success                 = 1;
        task.timing.ITI_success_var             = 0;
        task.timing.ITI_fail                    = 4;
        task.timing.ITI_fail_var                = 0;        
        task.timing.grace_time_eye              = 0;
        task.timing.grace_time_hand             = 0;        
        task.timing.fix_time_to_acquire_hnd     = 1.5;
        task.timing.tar_time_to_acquire_hnd     = 4;
        task.timing.tar_inv_time_to_acquire_hnd = 4;        
        task.timing.fix_time_to_acquire_eye     = 1;
        task.timing.tar_time_to_acquire_eye     = 10;
        task.timing.tar_inv_time_to_acquire_eye = 4; %3        
        task.timing.fix_time_hold               = 0.2;
        task.timing.fix_time_hold_var           = 0.2;
        task.timing.cue_time_hold               = 0.5;
        task.timing.cue_time_hold_var           = 0;
        task.timing.mem_time_hold               = 0;
        task.timing.mem_time_hold_var           = 0;
        task.timing.del_time_hold               = 0.2;
        task.timing.del_time_hold_var           = 0.2;
        task.timing.tar_inv_time_hold           = 0;
        task.timing.tar_inv_time_hold_var       = 0;
        task.timing.tar_time_hold               = 0.7;
        task.timing.tar_time_hold_var           = 0.0;
        
        
end

%% RADIUS & SIZES

if task.type==5 || task.type==6 
task.eye=rmfield(task.eye,'tar');
task.hnd=rmfield(task.hnd,'tar');
end

switch Current_con.size_con
    case -1 %'TEST'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 1000;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 1000;        
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
    case 0 %'calibration'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 100;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
    case 10 %'vpx_calibration'
        task.eye.fix.size       = 0.25;
        task.eye.fix.radius     = 100;
        task.eye.tar(1).size    = 0.25;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 4;
        task.hnd.fix.size       = 4;
        task.hnd.tar(1).size    = 4;
        task.hnd.tar(1).radius  = 4;
    case 1 %'fixation'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5; 
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;  
        
        task.hnd.fix.radius     = 2;
        task.hnd.fix.size       = 2;
        task.hnd.tar(1).size    = 2;
        task.hnd.tar(1).radius  = 2;
    case 2 %'direct'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 2.7;
        task.hnd.fix.size       = 2.7;
        task.hnd.tar(1).size    = 2.7;
        task.hnd.tar(1).radius  = 2.7;
    case 3 %'memory'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 0.5;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 5;
        task.hnd.fix.size       = 2;
        task.hnd.tar(1).size    = 2;
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
        
    case 5 %'match to sample'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 5;
        task.eye.tar(1).size    = 2;
        task.eye.tar(1).radius  = 5;        
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 2;
        task.hnd.tar(1).radius  = 4;
        
    case 8 %'RF mapping'
        task.eye.fix.size       = 0.5;
        task.eye.fix.radius     = 4;
        task.eye.tar(1).size    = 1;
        task.eye.tar(1).radius  = 1;        
        
        task.hnd.fix.radius     = 3;
        task.hnd.fix.size       = 3;
        task.hnd.tar(1).size    = 1;
        task.hnd.tar(1).radius  = 1;
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
        
if     multiple_targets_per_trial == 1; % 18 positions for match to sample saccades(!)
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
        
elseif     multiple_targets_per_trial == 3; % 18 positions for match to sample saccades(!)
        ex_LR = Current_con.excentricities;
        All_positions_right= Shuffle({ [ex_LR,f_h],[ex_LR,f_h]});
        All_positions_left = Shuffle({[-ex_LR,f_h],[-ex_LR,f_h]});
        tar_dis_1x = 0; tar_dis_1y = 0; tar_dis_2x = 0; tar_dis_2y = 0;       
        
elseif     multiple_targets_per_trial == 4; % 18 positions for match to sample saccades(!)
        ex_LR = Current_con.excentricities;
        All_positions_right= Shuffle({ [ex_LR,f_h+5],[ex_LR,f_h-5]});
        All_positions_left = Shuffle({[-ex_LR,f_h+5],[-ex_LR,f_h-5]});
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


