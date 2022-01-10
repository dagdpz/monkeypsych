function [task, monkey_name, pathname] =  get_monkey_dev(monkey)
global SETTINGS
%% VERSION LOG
% version 1: first working version, Linus data from 20120317 to 20120417
% version 2: reward probability added, Linus data from 20120418 to **
% version 3: current version from 20160113, for usie with custom condition
% files
% task.software                       = 'C:\Projekte\fMRI-Touch\monkeypsych_3.0\monkeypsych_dev.m';
% task.version                        = 3;
% task.version_modified               = '20181212';

%%% !!!!!!
% delete all _phys, _ina, _microstim and _scanner settings?

SETTINGS.useSound                   = 1;
SETTINGS.SoundType                  = 'Beep'; %KK changed in the condition file
SETTINGS.TouchscreenSound           = 1;
SETTINGS.FixationBreakSound         = 1;
SETTINGS.WrongTargetSound           = 1;
SETTINGS.SensorsReleasedSound       = 1; % 0 in s2
SETTINGS.MonkeyMovedSound           = 1; % 0 in s1,s2
SETTINGS.RewardSound                = 1;
SETTINGS.FixationAcquisitionSound   = 0;
SETTINGS.AllowManualSkipping        = 0;
SETTINGS.special_error              = '';
SETTINGS.VisFeedback_rest_hand      = 0;
SETTINGS.allowMotionLate            = 0;

%% DEFAULT SETTINGS:

%% MICROSTIMULATION SETTINGS
task.microstim.fraction             = 0; % from 0 to 1
task.microstim.interval             = NaN;
task.microstim.state                = NaN;
task.microstim.start{1}             = NaN;
task.microstim.end{1}               = NaN;

%% BEHAVIORAL ENHANCEMENTS
task.extra_reward                   = 0;
task.force_target_location          = 0; % force same target after abort
task.force_hand                     = 0; % force same hand after abort
task.force_effector                 = 0;

%% INITIAL CHECKS
task.check_screen_touching          = 0;
task.rest_sensors_ini_time          = 1;
task.rest_hand                      = [0 0];
task.fraction_choice                = 0;
task.correct_choice_target          = [1 2];
task.custom_conditions              = '';
%task.condition_file                 = '\Sources\MATLAB\monkeypsych_3.0\conditions\default_conditions.txt'; % might remove at some point if only custom conditions used
%task.condition_file                 = '\Projekte\fMRI-Touch\monkeypsych_3.0\conditions\default_conditions.txt'; % might remove at some point if only custom conditions used

%% RANDOMIZATIONS
task.randomize_reach_hand           = 0;
task.randomize_reach_hand_ratio     = [0.5 0.5 0];
task.randomize_effector             = 0;
task.randomize_effector_ratio       = [0.5 0.5 0];

%% REWARD MODULATION
%task.reward_modulation_effector     = 2; % 1 - eye, 2 - hand, only important when  task.effector =2; (it refers to which effector is important for acquisition and reward amount )
task.fraction_reward_modulation     = 0;
task.fraction_reward_small          = 0.5;
task.reward.prob_neutral            = 1;
task.reward.prob_small              = 1;
task.reward.prob_neutral            = 1;
task.reward.prob_large              = 1;
task.reward.large_color             = [218 70 255]; % color of ring around red or green targets
task.reward.time_large              = [1 1]; % 0.18ml per hit at 11.3 volts
task.reward.small_color             = [47 130 255];
task.reward.time_small              = [0.1 0.1]; % 0.12ml per hit at 11.3 volts

% this is "loss" part of risky gamble,
if  task.reward.time_large(2) == 0, % leave black
    task.reward.large_color2        = [0 0 0];
else % something else other than black
    % IRA change here if needed ( select one of those below,
    % comment out the rest
    % orange
    task.reward.large_color2        = [255 140 0];
    % yellow
    % task.reward.large_color       = [255 255 0];
end

%% COLOR DEFINITIONS
task.hnd_stay.color_dim_fix         = [127 127 0];
task.hnd_stay.color_bright_fix      = [255 255 0];
task.hnd_left.color_dim_fix         = [39 109 216];
task.hnd_left.color_bright_fix      = [119 230 253];
task.hnd_right.color_dim_fix        = [0 128 0];
task.hnd_right.color_bright_fix     = [0 255 0];%[0 255 0]
task.hnd_right.color_dim            = [0 128 0]; %[0 128 0]
task.hnd_right.color_bright         = [0 255 0];
task.hnd_left.color_dim             = [39 109 216]; %
task.hnd_left.color_bright          = [119 230 253];
task.hnd_right.color_cue            = [0 128 0]; %[50 80 50]; %%isoluminance?
task.hnd_left.color_cue             = [39 109 216]; %[64 77 80];
task.reach_hand                     = 1; % left hand

%% TARGET SHAPE DEFINITIONS
task.eye.fix.shape                  = 'circle'; % 'circle', 'square'
task.hnd.fix.shape                  = 'circle'; % 'circle', 'square'

task.hnd.tar(1).shape               = 'circle';
task.hnd.tar(2).shape               = 'circle';
task.eye.tar(1).shape               = 'circle';
task.eye.tar(2).shape               = 'circle';

task.hnd.tar(1).color_inv           = SETTINGS.BG_COLOR;
task.hnd.tar(2).color_inv           = SETTINGS.BG_COLOR;
task.eye.tar(1).color_inv           = SETTINGS.BG_COLOR;
task.eye.tar(2).color_inv           = SETTINGS.BG_COLOR;

task.hnd.cue(1).shape               = 'circle';
task.hnd.cue(2).shape               = 'circle';
task.eye.cue(1).shape               = 'circle';
task.eye.cue(2).shape               = 'circle';

task.rings_only_on_cues             = 0;
task.CueAuditiv                     = 0; %%??

task.eye.fi2=struct([]);
task.eye.ta2=struct([]);
task.hnd.fi2=struct([]);
task.hnd.ta2=struct([]);
task.eye.cuA=struct([]);

%% timing?? everything 0 as default, needs to be defined in the custom condition file
task.timing.grace_time_hand             = 0;
task.timing.grace_time_eye              = 0;
task.timing.fix_time_to_acquire_eye     = 0;
task.timing.fix_time_to_acquire_hnd     = 0;
task.timing.tar_time_to_acquire_eye     = 0;
task.timing.tar_time_to_acquire_hnd     = 0;
task.timing.tar_inv_time_to_acquire_eye = 0; 
task.timing.tar_inv_time_to_acquire_hnd = 0; 
task.timing.ta2_time_to_acquire_eye     = 0;
task.timing.ta2_time_to_acquire_hnd     = 0;

task.timing.fix_time_hold               = 0; 
task.timing.fix_time_hold_var           = 0;
task.timing.cue_time_hold               = 0; 
task.timing.cue_time_hold_var           = 0;
task.timing.cue_auditiv_time_hold       = 0;
task.timing.cue_auditiv_time_hold_var   = 0;
task.timing.mem_time_hold               = 0; 
task.timing.mem_time_hold_var           = 0;
task.timing.del_time_hold               = 0;
task.timing.del_time_hold_var           = 0;
task.timing.msk_time_hold               = 0;
task.timing.msk_time_hold_var           = 0;

task.timing.tar_inv_time_hold           = 0;
task.timing.tar_inv_time_hold_var       = 0;
task.timing.tar_time_hold               = 0; % target hold time
task.timing.tar_time_hold_var           = 0;
task.timing.ta2_time_hold               = 0;
task.timing.ta2_time_hold_var           = 0;
task.timing.wait_for_reward             = 0; %%??
task.timing.reward_time_sensors         = 0; %% new Pinocchio thing

task.timing.ITI_success                 = 0;
task.timing.ITI_success_var             = 0;
task.timing.ITI_incorrect_completed     = 0;
task.timing.ITI_fail_var                = 0;
task.timing.ITI_fail                    = 0;
        
        
%% MONKEY DEFINITIONS
switch monkey
    
    case 'Test'
        monkey_name                 = 'IVSfK';
        pathname                    = 'C:\Data\Test';
        task.vd                     = 32; %89 %32
        task.screen_uh_cm           = 12; % % defines position of screen center point over y axis (should be half of screen heigth in cm)
        
        
        SETTINGS.useMouse                   = 1;         % 0: use mouse instead of eye position
        SETTINGS.useVPacq                   = 0;         % 1: allow ViewPoint toolbox
        SETTINGS.UseMouseAsTouch = 1;
        %% Peter
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Peter\UMG_abstract_cue_reaches_saccades.m';
        %% magnus
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Magnus\eye_hand_and_rest_blocks_Mag.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Magnus\combined_condition_file_eye_hand_Mag.m';
%         %% cornelius
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\M2S_exploration_in_black.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\M2S_exploration_in_black_8_positions.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\M2S_2targets_exploration_in_black.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\Memory_ephys.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\standard_tasks.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\combined_condition_file_Cornelius_distractor_task_full.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\combined_condition_file_perceptual_Instructed_free_distractor.m';
%         %% pinocchio
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Pinocchio\fixation_file_pinocchio';
%         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Pinocchio\combined_condition_file_pinocchio';
%         %% Bacchus
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Bacchus\fixation_file_Bacchus';
%         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Bacchus\combined_condition_file_Bacchus_MRI';
%         
%         
%         %% Linus
%         %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_eye_hand';
%         %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_stim';
%         %         %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_phys';
%         %% Curius
%         
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_distractorM2S'; %% fixation spot above cue?
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_distractor_task_full.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\standard_tasks';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_distractor_task.m';
%         
%         
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Bacchus\fixation_file_Bacchus';
%         
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\standard_tasks';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_perceptual_Instructed_free_distractor';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_setup_sacc';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\Detection_microstim_direct.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\microstim_fixation_20140710.m';
%         task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_MRI';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_setup_sacc';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_Curius_distractor_task_full';
        
        %% Norman
        
        % task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_eye_hand';
        % task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\standard_tasks';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S';
        
        %  task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Wagering_2Wager';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Wagering_2Wager_InterleavedTones';
        
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Fi2';
        
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_Norman_distractorM2S_Samplestays';
        %  task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Wagering';
        
%         task.vd                     = 36; %32 chair 2 %30; chair 1 % cm
%         task.screen_uh_cm           = 6; %32 chair 2 %30; chair 1 % cm
%         SETTINGS.SoundType                  = 'XBI_sounds';
%     
    
    case 'Peter'
        monkey_name                 = 'LEHU_';
        pathname                    = 'D:\Data\Peter';
        
        switch SETTINGS.setup
            case 50
                task.vd                     = 32; %89 %32
                task.screen_uh_cm           = 12; % % defines position of screen center point over y axis (should be half of screen heigth in cm)
            case 51
                task.vd                     = 89; %89 %32
                task.screen_uh_cm           = 12; % % defines position of screen center point over y axis (should be half of screen heigth in cm)
        end
        
        task.custom_conditions      = 'C:\Projekte\fMRI-reach-decision\monkeypsych_3.0\conditions\Peter\frd_symbolic_cue_combined_condition_file.m';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Peter\DPZ_abstract_cue_reaches_saccades.m'; Version for DPZ
    case 'Magnus'
        monkey_name                 = 'Mag';
        pathname                    = 'D:\Data\Magnus';
        switch SETTINGS.setup
            case 1
                task.vd                     = 29;
                task.screen_uh_cm           = 10;
            case 2
                task.vd                     = 32;
                task.screen_uh_cm           = 10;
            case 3
                task.vd                     = 29;
                task.screen_uh_cm           = 10;
        end
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\combined_condition_file_eye_hand_Mag.m';
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Magnus\eye_hand_and_rest_blocks_Mag.m';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\standard_tasks';
        
    case 'Magnus_phys'
        monkey_name                 = 'Mag';
        pathname                    = 'D:\Data\Magnus_phys';
        %% setup 2
        task.vd                     = 28;
        task.screen_uh_cm           = 6;
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\combined_condition_file_eye_hand_Mag.m';
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Magnus\eye_hand_and_rest_blocks_Mag.m';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\standard_tasks';
        
    case 'Bexter'
        monkey_name                 = 'Bex';
        pathname                    = 'D:\Data\Bexter';
        task.vd                     = 32;
        task.screen_uh_cm           = 10;
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Bexter\fixation_file_bexter.m';
        
        
        
    case 'HumanNeglect'
        
        monkey_name         = 'SU1';
        pathname            = 'C:\Users\admin\Desktop\monkeypsych_20151111';
        task.condition_file = '\Sources\MATLAB\monkeypsych\conditions\linus_cornelius_0_1_2.txt';
        %task.custom_conditions      = '';
        task.custom_conditions      = 'C:\Users\admin\Desktop\monkeypsych_20151111\Sources\MATLAB\monkeypsych\conditions\combined_condition_file_eye_hand.m';
        task.vd = 50; % cm
        task.screen_uh_cm           = 4; %32 chair 2 %30; chair 1 % cm
        
    case 'Norman'
        monkey_name                 = 'Nor';
        pathname                    = 'D:\Data\Norman';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_eye_hand';
        % task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\standard_tasks';
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S';
        
        %  task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Wagering_2Wager';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Wagering_2Wager_InterleavedTones';
        
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Fi2';
        
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_Norman_distractorM2S_Samplestays';
        %  task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Norman\combined_condition_file_M2S_Wagering';
        
        SETTINGS.AntiAlisingValue       = 2;
        SETTINGS.SoundType                  = 'XBI_sounds';
        task.vd                     = 42;
        task.screen_uh_cm           = 9.5;
        
    case 'Cornelius'
        monkey_name                 = 'Cor';
        pathname                    = 'D:\Data\Cornelius';
        SETTINGS.SoundType          = 'XBI_sounds';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\standard_tasks';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\combined_condition_file_perceptual_Instructed_free_distractor';
        %task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\combined_condition_file_Cornelius_distractorM2S';
        %task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\combined_condition_file_eye_hand';
        
        switch SETTINGS.setup
            case 1
                task.vd                     = 42; %32 30 %chair 2 %chair 1 % cm
                %task.vd                     = 30.1; %32 chair 2 %30; chair 1 % cm
                task.screen_uh_cm           = 9.5; %32 chair 2 %30; chair 1 % cm
            case 2
                task.vd                     =37; %32 30 %chair 2 %chair 1 % cm
                %task.vd                     = 30.1; %32 chair 2 %30; chair 1 % cm
                task.screen_uh_cm           = 9.5; %32 chair 2 %30; chair 1 % cm
            case 3
                task.vd                     = 42; %32 30 %chair 2 %chair 1 % cm
                %task.vd                     = 30.1; %32 chair 2 %30; chair 1 % cm
                task.screen_uh_cm           = 9.5; %32 chair 2 %30; chair 1 % cm
        end
        
    case 'Cornelius_phys'
        monkey_name                 = 'Cor';
        pathname                    = 'D:\Data\Cornelius_phys';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\standard_tasks';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\Memory_ephys';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\M2S_exploration_in_black_8_positions';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\M2S_2targets_exploration_in_black';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Cornelius\M2S_exploration_in_black';
        
        switch SETTINGS.setup
            case 1
                task.vd                     = 36; %32 chair 2 %30; chair 1 % cm
                task.screen_uh_cm           = 6; %32 chair 2 %30; chair 1 % cm
            case 2
                task.vd                     = 36; %32 chair 2 %30; chair 1 % cm
                task.screen_uh_cm           = 6; %32 chair 2 %30; chair 1 % cm
            case 3
                task.vd                     = 36; %32 chair 2 %30; chair 1 % cm
                task.screen_uh_cm           = 6; %32 chair 2 %30; chair 1 % cm
        end
        
    case 'Curius'
        monkey_name                 = 'Cur';
        pathname                    = 'D:\Data\Curius';
        SETTINGS.SoundType          = 'XBI_sounds';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\standard_tasks';
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Curius\combined_condition_file_perceptual_Instructed_free_distractor';
        % task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\combined_condition_file_Curius_setup_sacc';
        %task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\combined_condition_file_Curius_distractor_task_full';
        %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\Detection_microstim_direct.m';
        %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\microstim_fixation_20140710.m';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\combined_condition_file.m';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\combined_condition_file_Curius_MRI';
        
        switch SETTINGS.setup
            case 1
                task.vd                     = 42; % chair 1: 29, chair 2: 32, MRI 2: 54
                task.screen_uh_cm           = 9.5;  % chair 1 and 2: 6, MRI 2: 14
            case 2
                task.vd                     = 28;
                task.screen_uh_cm           = 9.5;
            case 3
                task.vd                     = 30;
                task.screen_uh_cm           = 7;
        end
        %
        %     case 'Curius_phys'
        %         monkey_name                 = 'Cur';
        %         pathname                    = '\Data\Curius_phys';
        %         task.custom_conditions      = '';
        %         switch SETTINGS.setup
        %             case 1
        %                 task.vd                     = 31.5;
        %                 task.screen_uh_cm           = 20;
        %             case 2
        %                 task.vd                     = 31.5;
        %                 task.screen_uh_cm           = 20;
        %             case 3
        %                 task.vd                     = 31.5;
        %                 task.screen_uh_cm           = 20;
        %         end
        %
        %     case 'Curius_microstim'
        %         monkey_name                 = 'Cur';
        %         pathname                    = '\Data\Curius_microstim';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\combined_condition_file.m';
        %         task.vd = 31.5;
        %         task.screen_uh_cm           = 20;
        %         %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\Detection_microstim_direct.m';
        %         %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\microstim_fixation_20140710.m';
        %
        %     case 'Curius_scanner'
        %         monkey_name                 = 'Cur';
        %         pathname                    = '\Data\Curius';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\Curius\combined_condition_file_Curius_MRI';
        %         task.vd                     = 65;
        %         task.screen_uh_cm           = 20;
        
    case 'TestTDT'
        
    case 'HumanM2S'
        monkey_name                 = 'DW1';
        pathname                    = 'C:\Data\HumanM2S';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\HumanM2S\calibration_task';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\HumanM2S\M2S_exploration';
        task.vd                     = 30; %32 30 %chair 2 %chair 1 % cm
        task.screen_uh_cm           = 16; %32 chair 2 %30; chair 1 % cm
        
    case 'Linus'
        monkey_name                 = 'Lin';
        pathname                    = '\Data\Linus';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_eye_hand';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_stim';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_phys';
        task.vd                     = 29.5;
        task.screen_uh_cm           = 6;
        
        
        switch SETTINGS.setup
            case 1
                task.vd                     = 29.5;
                task.screen_uh_cm           = 6;
            case 2
                task.vd                     = 29.5;
                task.screen_uh_cm           = 6;
            case 3
                task.vd                     = 29.5;
                task.screen_uh_cm           = 6;
        end
        
        %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_flaffy';
        %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_lin_training';
        %
        %     case 'Linus_phys'
        %         monkey_name                 = 'Lin';
        %         pathname                    = '\Data\Linus_phys';
        %         %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_phys';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_eye_hand';
        %         task.vd                     = 29.5;
        %         task.screen_uh_cm           = 6;
        %
        %     case 'Linus_microstim'
        %         monkey_name                 = 'Lin';
        %         pathname                    = '\Data\Linus_microstim';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_stim';
        %         task.vd                     = 29.5;
        %         task.screen_uh_cm           = 6;
        %         %         task.custom_conditions        = '\Sources\MATLAB\monkeypsych_2.0\conditions\Linus\microstim_fixation_20140710';
        %
        %     case 'Linus_ina'
        %         monkey_name                 = 'Lin';
        %         pathname                    = '\Data\Linus_ina';
        %         %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_phys';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_eye_hand';
        %         task.vd                     = 29.5;
        %         task.screen_uh_cm           = 6;
        
        
    case 'Bacchus'
        monkey_name                 = 'Bac';
        pathname                    = 'D:\Data\Bacchus';
        %task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Bacchus\combined_condition_file_Bacchus_MRI';
        task.custom_conditions      = 'D:\Sources\MATLAB\monkeypsych_3.0\conditions\Bacchus\fixation_file_Bacchus';
        task.vd                     = 33; %55
        task.screen_uh_cm           = 16;
        
        switch SETTINGS.setup
            case 0  % scanner UMG monkeys
            case 1
                task.vd                     = 52.5; %55
                task.screen_uh_cm           = 16;
            case 2
                task.vd                     = 52.5; %55
                task.screen_uh_cm           = 16;
            case 3
                task.vd                     = 33; %55
                task.screen_uh_cm           = 16;
            case 4 % scanner DPZ monkeys
                task.vd                     = 60;
                task.screen_uh_cm           = 20;
        end
        %     case 'Bacchus_MRI'
        %         monkey_name                 = 'Bac';
        %         pathname                    = '\Data\Bacchus';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_Bacchus_MRI';
        %         task.vd                     = 52.5; %55
        %         task.screen_uh_cm           = 16;
        %
        %     case 'Bacchus_scanner' % DPZ scanner
        %         monkey_name                 = 'Bac';
        %         pathname                    = '\Data\Bacchus';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_2.0\conditions\combined_condition_file_Bacchus_MRI';
        %         task.vd                     = 60;
        %         task.screen_uh_cm           = 20;
        
    case 'Pinocchio'
        monkey_name                 = 'Pin';
        pathname                    = 'D:\Data\Pinocchio';
        %         task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Pinocchio\combined_condition_file_pinocchio';
        task.custom_conditions      = '\Sources\MATLAB\monkeypsych_3.0\conditions\Pinocchio\fixation_file_pinocchio';
        task.vd                     = 36; %32 chair 2 %30; chair 1 % cm
        task.screen_uh_cm           = 6; %32 chair 2 %30; chair 1 % cm
        SETTINGS.SoundType                  = 'XBI_sounds';
        
end