function Wagering_20141105(name_subject)

if nargin < 1,
    name_subject = 'Test'; % name of the subject
end

global SETTINGS
global dyn_wager

% SAVING FUNCTION'S NAME AND SETTING IMAGES PATH (PLACE IMAGES IN THE FOLDER IMAGES INSIDE THIS FUNCTION'S FOLDER)
SETTINGS.fname                           = mfilename;
fname_size                               = size(SETTINGS.fname);
fpath                                    = mfilename('fullpath');
SETTINGS.fpath                           = fpath(1:end-fname_size(2));
path_images                              = [SETTINGS.fpath 'images\'];

% SETUP
SETTINGS.setup                           = 'psychophysics'; % 'psychophysics', 'setup_1', 'UMG'

switch SETTINGS.setup
    
    
    case 'psychophysics'
        screen_number = 1;
    case'setup_1'
        screen_number = 2;
    case'UMG'
        screen_number = 1;
        javapath = [PsychtoolboxRoot 'PsychJava'];
        javaaddpath(javapath);
end

%TASK
SETTINGS.wager                           = 1; % 0 = inactive, 1 = active
SETTINGS.pre_or_post                     = 0; % 0 = random, 1 = pre_wagering, 2 = post_wagering
SETTINGS.proportion_wager                = [50 50]; % [pre-wagering and post-wagering]
present_feedback                         = 0; % 0 = inactive, 1 = active
punish_error_percentage                  = 0;
punish_error_specific                    = 0; % 0 = inactive, 1 = active
SETTINGS.rot_deg_prop(1).family          = [3 3 3 4 4 4 4 5 5 5 5 5]; % (array length = 12 * 3 families) = 36
SETTINGS.rot_deg_prop(2).family          = [2 2 2 3 3 3 3 3 3 4 4 4];
SETTINGS.rot_deg_prop(3).family          = [1 1 1 1 1 2 2 2 2 3 3 3];
SETTINGS.n_trials                        = (length(SETTINGS.rot_deg_prop(1).family)*3)*10; % last number = 2 (n_trials = 72) % last number = 3 (n_trials = 108) % last number = 4 (n_trials = 144) % last number = 5 (n_trials = 180) 
SETTINGS.family_matrix                   = Shuffle(repmat(1:3,1,(SETTINGS.n_trials/3)));

awesome_degree_matrix_generator;

%EFFECTOR
SETTINGS.button_or_sensor                = 'sensors'; % 'buttons' or 'sensors'
SETTINGS.inp_out                         = 'parallel'; % 'parallel' if using parallel port and 'serial' if using serial port

%TIMING
SETTINGS.base_rest_HT                    = .5;
SETTINGS.rand_rest_HT                    = .5;
SETTINGS.ITI_base                        = .5; %
SETTINGS.brain_volume_time               = 1; % seconds needed for 1 brain volume
SETTINGS.number_of_volumes_holding       = 1; %number of volumes the subject should hold the rest buttons after he comes back from the movement

SETTINGS.time_present_sample             = 1; %1
SETTINGS.time_present_match_to_sample    = 1.5; % 1.5
SETTINGS.time_present_earnings           = 2; % 2.5 money subject won or lost and total amount of money
SETTINGS.time_present_errors             = 0.8; % break fixation and bad use of the buttons
SETTINGS.present_visual_feedback         = 0.3; % green square around selected wager
SETTINGS.time_process_sample             = 1; %2
SETTINGS.time_process_match_to_sample    = 1; %2
SETTINGS.time_process_wager_or_control   = 1; %2
SETTINGS.time_back_match_to_sample       = 0.3; %allowed time to come back after selecting match-to-sample
SETTINGS.allowed_wager_time              = 3; %3
SETTINGS.time_both_buttons_release       = 0.3; % time you can keep buttons without being pressed after selecting something through button release

%EYES
SETTINGS.checking_eye_fixation           = 'active'; % 'active' checking eye fixation and presenting red fixation spot; 'inactive' not checking eye fixation and not presenting red fixation spot
SETTINGS.recording_eye_position          = 0; % 1 = active and 0 = inactive
SETTINGS.eye_fixation_radius             = 3; % deg

% OTHER SETTINGS
SETTINGS.grace_time_nonsample_or_mts     = 0.4;
SETTINGS.grace_time                      = SETTINGS.grace_time_nonsample_or_mts;
SETTINGS.grace_time_sample               = 0.05;
SETTINGS.grace_time_match_sample         = 0.05;
SETTINGS.dist_extra_right                = 85; % with this we have in psychophysics PC an excentricity of 9 degree
SETTINGS.dist_extra_left                 =-SETTINGS.dist_extra_right;
SETTINGS.size_images                     = 120;
SETTINGS.dist_extra_right_text           = -190;
SETTINGS.dist_extra_left_text            = 120;

% SETTINGS.total_trial_time                = [SETTINGS.time_present_sample + SETTINGS.time_present_match_to_sample + ...
%                                          SETTINGS.time_process_sample + SETTINGS.time_process_match_to_sample + (2*SETTINGS.time_process_wager_or_control) + ...
%                                          SETTINGS.time_back_match_to_sample + SETTINGS.time_present_earnings + ...
%                                          (2*SETTINGS.allowed_wager_time) + SETTINGS.time_present_errors];

SETTINGS.rot_family1                     = 4.5;
SETTINGS.rot_family1_1                   = 4*SETTINGS.rot_family1;
SETTINGS.rot_family1_2                   = 5*SETTINGS.rot_family1;
SETTINGS.rot_family1_3                   = 6*SETTINGS.rot_family1;
SETTINGS.rot_family1_4                   = 7*SETTINGS.rot_family1;
SETTINGS.rot_family1_5                   = 8*SETTINGS.rot_family1;
SETTINGS.rot_family1_6                   = 9*SETTINGS.rot_family1;
SETTINGS.rot_family1_7                   = 10*SETTINGS.rot_family1;
SETTINGS.rot_family1_8                   = 11*SETTINGS.rot_family1;
SETTINGS.rot_family1_9                   = 12*SETTINGS.rot_family1;
SETTINGS.rot_family1_10                  = 13*SETTINGS.rot_family1;

SETTINGS.rot_family2                     = 4.5;
SETTINGS.rot_family2_1                   = 4*SETTINGS.rot_family2;
SETTINGS.rot_family2_2                   = 5*SETTINGS.rot_family2;
SETTINGS.rot_family2_3                   = 6*SETTINGS.rot_family2;
SETTINGS.rot_family2_4                   = 7*SETTINGS.rot_family2;
SETTINGS.rot_family2_5                   = 8*SETTINGS.rot_family2;
SETTINGS.rot_family2_6                   = 9*SETTINGS.rot_family2;
SETTINGS.rot_family2_7                   = 10*SETTINGS.rot_family2;
SETTINGS.rot_family2_8                   = 11*SETTINGS.rot_family2;
SETTINGS.rot_family2_9                   = 12*SETTINGS.rot_family2;
SETTINGS.rot_family2_10                  = 13*SETTINGS.rot_family2;

SETTINGS.rot_family3                     = 4.5;
SETTINGS.rot_family3_1                   = 4*SETTINGS.rot_family3;
SETTINGS.rot_family3_2                   = 5*SETTINGS.rot_family3;
SETTINGS.rot_family3_3                   = 6*SETTINGS.rot_family3;
SETTINGS.rot_family3_4                   = 7*SETTINGS.rot_family3;
SETTINGS.rot_family3_5                   = 8*SETTINGS.rot_family3;
SETTINGS.rot_family3_6                   = 9*SETTINGS.rot_family3;
SETTINGS.rot_family3_7                   = 10*SETTINGS.rot_family3;
SETTINGS.rot_family3_8                   = 11*SETTINGS.rot_family3;
SETTINGS.rot_family3_9                   = 12*SETTINGS.rot_family3;
SETTINGS.rot_family3_10                  = 13*SETTINGS.rot_family3;

SETTINGS.gray_cue_color                  = [20 20 20];
SETTINGS.green_color                     = [0 250 0];
SETTINGS.blue_color                      = [0 0 250];
SETTINGS.red_fix_dim                     = [160 0 0];
SETTINGS.red_fix_bright1                 = [250 0 0];
SETTINGS.red_fix_bright2                 = [250 0 0];
SETTINGS.white_color                     = [255 255 255];
SETTINGS.yellow_color                    = [255 255 0];
SETTINGS.control_color                   = [255 120 0]/4;
SETTINGS.gray_wager_color                = [150 150 150];
SETTINGS.gray_rectangular                = {SETTINGS.gray_wager_color, SETTINGS.gray_wager_color/3};

SETTINGS.size_rectangular                = 30;
SETTINGS.size_oval                       = 5;
SETTINGS.size_text                       = 20;
SETTINGS.H_L_size_text                   = 80;
SETTINGS.wager_1                         = '2';
SETTINGS.wager_2                         = '5';
SETTINGS.wager_3                         = '8';
SETTINGS.wager_4                         = '11';
SETTINGS.wager_5                         = '14';
SETTINGS.wager_6                         = '17';
SETTINGS.baseline_value                  = 10;
SETTINGS.sum_payment_matrix_incorrect    = 0.03;
SETTINGS.sum_payment_matrix_correct      = 0;
SETTINGS.excentricity_wager_position1    = 3;
SETTINGS.excentricity_wager_position2    = 3.5;
SETTINGS.excentricity_wager_position3    = 4;
SETTINGS.excentricity_wager_position4    = 6;
SETTINGS.excentricity_wager_position5    = 6.5;
SETTINGS.excentricity_wager_position6    = 7;

Screen('Preference', 'VisualDebugLevel', 1); % black PTB welcome screen
[SETTINGS.window, SETTINGS.screenSize] = Screen(screen_number, 'OpenWindow');     % put 'window' on complete screen
Screen('FillRect', SETTINGS.window, [0 0 0]);               % fill whole screen black
Screen(SETTINGS.window,'Flip');

switch SETTINGS.button_or_sensor
    case 'buttons'
        ListenChar(2); % value of 2 will enable listening, additionally any output of keypresses to Matlab windows is suppressed
end

%% Paths' names

common_path = 'Data\Human\';

% Save subjects' data
path_save_UMG                       = ['C:\' common_path];
path_save                           = ['D:\' common_path];

% Eye's information
path_eye_UMG                        = ['C:\' common_path 'last_eyecal.mat'];
path_eye                            = ['D:\' common_path 'last_eyecal.mat'];

switch SETTINGS.setup
    case'UMG'
        path_eye  = path_eye_UMG;
        path_save = path_save_UMG;
end

%% Setting parallel port

switch SETTINGS.inp_out
    case 'parallel'
        global cogent
        %create IO32 interface object
        clear io32;
        cogent.io.ioObj = io32;
        %install the inpout32.dll driver
        %status = 0 if installation successful
        cogent.io.status = io32(cogent.io.ioObj);
        if(cogent.io.status ~= 0);
            disp('inpout32 installation failed!')
        else
            disp('inpout32 (re)installation successful.');
        end
        in.address = hex2dec('379');   % parallel port input address
    case 'serial'
end


%% Specific settings for each setup

switch SETTINGS.setup
    
    case 'psychophysics'
        SETTINGS.vd           = 50;
        SETTINGS.screen_w_pix = 1600;
        SETTINGS.screen_h_pix = 1200;
        SETTINGS.screen_w_cm  = 41;
        SETTINGS.screen_h_cm  = 30.5;
        
    case'setup_1'
        SETTINGS.vd           = 55;
        SETTINGS.screen_w_pix = 1920;
        SETTINGS.screen_h_pix = 1080;
        SETTINGS.screen_w_cm  = 59.5;
        SETTINGS.screen_h_cm  = 33;
        
    case'UMG'
        SETTINGS.vd           = 50;
        SETTINGS.screen_w_pix = 1024;
        SETTINGS.screen_h_pix = 768;
        SETTINGS.screen_w_cm  = 41;
        SETTINGS.screen_h_cm  = 30.5;
end

SETTINGS.screen_w_deg = cm2deg(SETTINGS.vd,SETTINGS.screen_w_cm);
SETTINGS.screen_h_deg = cm2deg(SETTINGS.vd,SETTINGS.screen_h_cm);

dyn_wager.Position1        = [SETTINGS.excentricity_wager_position1*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2-SETTINGS.size_rectangular/2 SETTINGS.excentricity_wager_position1*SETTINGS.screen_w_pix/10+SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular/2];
dyn_wager.Position2        = [SETTINGS.excentricity_wager_position2*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/2 SETTINGS.screen_h_pix/2-SETTINGS.size_rectangular/2 SETTINGS.excentricity_wager_position2*SETTINGS.screen_w_pix/10+SETTINGS.size_rectangular/2 SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular/2];
dyn_wager.Position3        = [SETTINGS.excentricity_wager_position3*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2-SETTINGS.size_rectangular/2 SETTINGS.excentricity_wager_position3*SETTINGS.screen_w_pix/10+SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular/2];
dyn_wager.Position4        = [SETTINGS.excentricity_wager_position4*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2-SETTINGS.size_rectangular/2 SETTINGS.excentricity_wager_position4*SETTINGS.screen_w_pix/10+SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular/2];
dyn_wager.Position5        = [SETTINGS.excentricity_wager_position5*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/2 SETTINGS.screen_h_pix/2-SETTINGS.size_rectangular/2 SETTINGS.excentricity_wager_position5*SETTINGS.screen_w_pix/10+SETTINGS.size_rectangular/2 SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular/2];
dyn_wager.Position6        = [SETTINGS.excentricity_wager_position6*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2-SETTINGS.size_rectangular/2 SETTINGS.excentricity_wager_position6*SETTINGS.screen_w_pix/10+SETTINGS.size_rectangular/2   SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular/2];
dyn_wager.Position_all     = {dyn_wager.Position1 dyn_wager.Position2 dyn_wager.Position3 dyn_wager.Position4 dyn_wager.Position5 dyn_wager.Position6};
dyn_wager.Position_wager_h = [SETTINGS.screen_h_pix/2+SETTINGS.size_rectangular*1.5];

%% General Settings

Trial                       = 0;
Trial_family_1              = 0;
Trial_family_2              = 0;
Trial_family_3              = 0;
count_correct_selection     = 0;
count_incorrect_selection   = 0;
decision_left               = 0;
decision_right              = 0;
amount_rectangular          = 0;
button_release              = 0;
button_press                = 0;
grey_a                      = 2;
grey_b                      = 2;
frame                       = 0;
color                       = 0;
unsuccess                   = 0;
baseline_value              = SETTINGS.baseline_value;
SETTINGS.control_or_wager   = NaN;
deg                         = NaN;

%% Checking eye fixation

switch SETTINGS.checking_eye_fixation
    
    case 'active'
        SETTINGS.check_eye = 1;
        allow_grace_time   = 1;
    case 'inactive'
        SETTINGS.check_eye = 0;
        allow_grace_time   = 0;
        SETTINGS.red_fix_dim = [0 0 0];
        SETTINGS.red_fix_bright1 = [20 20 20];
        SETTINGS.red_fix_bright2 = [0 0 0];
end

%% Buttons or sensors input numbers

% make sure to define same buttons in get_hands_state subfunction
switch SETTINGS.setup
    case 'psychophysics'
        SETTINGS.no_button    = 152;
        SETTINGS.left_button  = 184;
        SETTINGS.right_button = 24;
        SETTINGS.rest_buttons = 56;
    case 'setup_1'
        SETTINGS.no_button    = 128;
        SETTINGS.left_button  = 144;
        SETTINGS.right_button = 0;
        SETTINGS.rest_buttons = 16;
    case 'UMG'
        SETTINGS.no_button    = 0;
        SETTINGS.left_button  = 1;
        SETTINGS.right_button = 2;
        SETTINGS.rest_buttons = 5;
end


%% Checking eye position

switch SETTINGS.checking_eye_fixation
    case 'active';
        if ~libisloaded('vpx'); % Initialize eyetracker
            vpx_Initialize;
            if ~vpx_GetStatus(1)
                error('ViewPoint software is not running!')
            end
        end
        figure(1);
        switch SETTINGS.setup
            case 'psychophysics'
                set(gcf,'Name','Eye Position','Position',[-665 131 560 420]);% Setups 1 & 2
                set(gca,'Ylim',[-SETTINGS.screen_h_deg/2 SETTINGS.screen_h_deg/2],'Xlim',[-SETTINGS.screen_w_deg/2 SETTINGS.screen_w_deg/2],'XLimMode','manual','YLimMode','manual');
            case 'setup_1'
                set(gcf,'Name','Eye Position','Position',[900 -600 700 700*SETTINGS.screen_h_pix/SETTINGS.screen_w_pix]); % Setups 1 & 2
                set(gca,'Ylim',[-SETTINGS.screen_h_deg/2 SETTINGS.screen_h_deg/2],'Xlim',[-SETTINGS.screen_w_deg/2 SETTINGS.screen_w_deg/2],'XLimMode','manual','YLimMode','manual');
            case 'UMG'
                set(gcf,'Name','Eye Position','Position',[450 50 500 500]);% Setups 1 & 2
                %set(gca,'Ylim',[-SETTINGS.screen_h_deg/2 SETTINGS.screen_h_deg/2],'Xlim',[-SETTINGS.screen_w_deg/2 SETTINGS.screen_w_deg/2],'XLimMode','manual','YLimMode','manual');
                set(gca,'Ylim',[-1 1],'Xlim',[-1 1],'XLimMode','manual','YLimMode','manual');
        end
        drawnow;
        hold on;
end

load(path_eye);

SETTINGS.eye_gain_x = eye_gain_x;
SETTINGS.eye_gain_y = eye_gain_y;

fileNumber  = 1;
pathname    = path_save;

while true
    filename = [name_subject '_' datestr(date,'yyyy-mm-dd') '_' num2str(fileNumber,'%02u')];
    if exist([pathname '\' filename '.mat'])
        fileNumber = fileNumber + 1;
    else
        break
    end
end

outFileMat = [pathname '\' filename '.mat'];

%% In MRI, wait for the trigger

switch SETTINGS.setup
    case 'UMG'
        disp('Waiting scanner trigger...');
        switch SETTINGS.species, case 'humans',
            text='Please wait for start of the run...';
            Screen('FillRect', SETTINGS.window, [0 0 0]);               % fill whole screen black
            Screen('DrawText',SETTINGS.window,text, SETTINGS.screen_w_pix/3,SETTINGS.screen_h_pix/2, [100 100 100]);
            Screen(SETTINGS.window,'Flip');
        end
        while 1
            [~,~,keyCode,~] = KbCheck;
            if keyCode(57)
                disp(sprintf('Starting task in %.2f seconds',SETTINGS.brain_volume_time*4));
                switch SETTINGS.species, case 'humans',
                    text=(sprintf('Starting task in %.2f seconds',SETTINGS.brain_volume_time*4));% 'Starting task!';
                    Screen('FillRect', SETTINGS.window, [0 0 0]);               % fill whole screen black
                    Screen('DrawText',SETTINGS.window,text, SETTINGS.screen_w_pix/3,SETTINGS.screen_h_pix/2, [100 100 100]);
                    Screen(SETTINGS.window,'Flip');
                end
                break;
            end
        end
        WaitSecs(SETTINGS.brain_volume_time*4);
end

dyn_wager.position_rest         = [SETTINGS.screen_w_pix/2-50 SETTINGS.screen_h_pix/2-50 SETTINGS.screen_w_pix/2+50 SETTINGS.screen_h_pix/2+50];
dyn_wager.position_fixation     = [SETTINGS.screen_w_pix/2-7 SETTINGS.screen_h_pix/2-7 SETTINGS.screen_w_pix/2+7 SETTINGS.screen_h_pix/2+7];


%% MAIN LOOP

RunStartTime = GetSecs;
SETTINGS.RunStartTime = RunStartTime;

if SETTINGS.wager
    Screen('TextSize', SETTINGS.window, SETTINGS.size_text);
    DrawFormattedText(SETTINGS.window,['You are starting with ' num2str(baseline_value) '�'],'center','center',[0 180 0]);
    DrawFormattedText(SETTINGS.window,'Good luck!!!','center', (SETTINGS.screen_h_pix/2)+50,[0 180 0]);
    Screen(SETTINGS.window,'Flip');
    WaitSecs(SETTINGS.time_present_earnings);
end


while 1
    
    cla; hold on;
    
    %% Modifying parameters online
    
    if KbCheck
        [~,~,keyCode,~] = KbCheck;
        if keyCode(27)  % Esc
            break;
        end
        if keyCode(112) % F1 this is because ESC doesn't work with 2 other buttons
            break;
        end
        if keyCode(113) % F2 activates or inactivates punish error
            prompt = {'Punish Error (%)'};
            dlg_title = 'Parameters';
            num_lines = 1;
            def = {num2str(punish_error_percentage)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                punish_error_percentage=str2num(answer{1});
            end
        end
        if keyCode(114) % F3 -  modifies grace time sample
            prompt = {'Grace time sample'};
            dlg_title = 'Parameters';
            num_lines = 1;
            def = {num2str(SETTINGS.grace_time_sample)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                SETTINGS.grace_time_sample=str2num(answer{1});
            end
        end
        if keyCode(116) % F5 -  modifies grace time match-to-sample
            prompt = {'Grace time match-to-sample'};
            dlg_title = 'Parameters';
            num_lines = 1;
            def = {num2str(SETTINGS.grace_time_match_sample)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                SETTINGS.grace_time_match_sample=str2num(answer{1});
            end
        end  
        if keyCode(117) % F6 -  modifies grace time match-to-sample
            prompt = {'Grace time'};
            dlg_title = 'Parameters';
            num_lines = 1;
            def = {num2str(SETTINGS.grace_time_nonsample_or_mts)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                SETTINGS.grace_time_nonsample_or_mts=str2num(answer{1});
            end
        end  
    end
    
    %% Images
    
    Trial = Trial+1; % Trial number
    
    family = SETTINGS.family_matrix(1);
    
    switch family
        case 1
            img_planet0 = imread([path_images 'family_1.jpg']);
            img_planet1 = imrotate(img_planet0,SETTINGS.rot_family1_1,'crop');
            img_planet2 = imrotate(img_planet0,SETTINGS.rot_family1_2,'crop');
            img_planet3 = imrotate(img_planet0,SETTINGS.rot_family1_3,'crop');
            img_planet4 = imrotate(img_planet0,SETTINGS.rot_family1_4,'crop');
            img_planet5 = imrotate(img_planet0,SETTINGS.rot_family1_5,'crop');
            img_planet6 = imrotate(img_planet0,SETTINGS.rot_family1_6,'crop');
            img_planet7 = imrotate(img_planet0,SETTINGS.rot_family1_7,'crop');
            img_planet8 = imrotate(img_planet0,SETTINGS.rot_family1_8,'crop');
            img_planet9 = imrotate(img_planet0,SETTINGS.rot_family1_9,'crop');
            img_planet10= imrotate(img_planet0,SETTINGS.rot_family1_10,'crop');
        case 2
            img_planet0 = imread([path_images 'family_2.jpg']);
            img_planet1 = imrotate(img_planet0,SETTINGS.rot_family2_1,'crop');
            img_planet2 = imrotate(img_planet0,SETTINGS.rot_family2_2,'crop');
            img_planet3 = imrotate(img_planet0,SETTINGS.rot_family2_3,'crop');
            img_planet4 = imrotate(img_planet0,SETTINGS.rot_family2_4,'crop');
            img_planet5 = imrotate(img_planet0,SETTINGS.rot_family2_5,'crop');
            img_planet6 = imrotate(img_planet0,SETTINGS.rot_family2_6,'crop');
            img_planet7 = imrotate(img_planet0,SETTINGS.rot_family2_7,'crop');
            img_planet8 = imrotate(img_planet0,SETTINGS.rot_family2_8,'crop');
            img_planet9 = imrotate(img_planet0,SETTINGS.rot_family2_9,'crop');
            img_planet10= imrotate(img_planet0,SETTINGS.rot_family2_10,'crop');
        case 3
            img_planet0 = imread([path_images 'family_3.jpg']);
            img_planet1 = imrotate(img_planet0,SETTINGS.rot_family3_1,'crop');
            img_planet2 = imrotate(img_planet0,SETTINGS.rot_family3_2,'crop');
            img_planet3 = imrotate(img_planet0,SETTINGS.rot_family3_3,'crop');
            img_planet4 = imrotate(img_planet0,SETTINGS.rot_family3_4,'crop');
            img_planet5 = imrotate(img_planet0,SETTINGS.rot_family3_5,'crop');
            img_planet6 = imrotate(img_planet0,SETTINGS.rot_family3_6,'crop');
            img_planet7 = imrotate(img_planet0,SETTINGS.rot_family3_7,'crop');
            img_planet8 = imrotate(img_planet0,SETTINGS.rot_family3_8,'crop');
            img_planet9 = imrotate(img_planet0,SETTINGS.rot_family3_9,'crop');
            img_planet10= imrotate(img_planet0,SETTINGS.rot_family3_10,'crop');
    end
    
    planet1 = imresize(img_planet1,[SETTINGS.size_images SETTINGS.size_images]);
    planet2 = imresize(img_planet2,[SETTINGS.size_images SETTINGS.size_images]);
    planet3 = imresize(img_planet3,[SETTINGS.size_images SETTINGS.size_images]);
    planet4 = imresize(img_planet4,[SETTINGS.size_images SETTINGS.size_images]);
    planet5 = imresize(img_planet5,[SETTINGS.size_images SETTINGS.size_images]);
    planet6 = imresize(img_planet6,[SETTINGS.size_images SETTINGS.size_images]);
    planet7 = imresize(img_planet7,[SETTINGS.size_images SETTINGS.size_images]);
    planet8 = imresize(img_planet8,[SETTINGS.size_images SETTINGS.size_images]);
    planet9 = imresize(img_planet9,[SETTINGS.size_images SETTINGS.size_images]);
    planet10= imresize(img_planet10,[SETTINGS.size_images SETTINGS.size_images]);
    
    img(1) = Screen('MakeTexture', SETTINGS.window, planet1);
    img(2) = Screen('MakeTexture', SETTINGS.window, planet2);
    img(3) = Screen('MakeTexture', SETTINGS.window, planet3);
    img(4) = Screen('MakeTexture', SETTINGS.window, planet4);
    img(5) = Screen('MakeTexture', SETTINGS.window, planet5);
    img(6) = Screen('MakeTexture', SETTINGS.window, planet6);
    img(7) = Screen('MakeTexture', SETTINGS.window, planet7);
    img(8) = Screen('MakeTexture', SETTINGS.window, planet8);
    img(9) = Screen('MakeTexture', SETTINGS.window, planet9);
    img(10)= Screen('MakeTexture', SETTINGS.window, planet10);
       
    if family == 1
        Trial_family_1            = Trial_family_1+1;
        sample                    = SETTINGS.matrix_experiment(1).family(1,1);
        nonsample                 = SETTINGS.matrix_experiment(1).family(1,2);
        SETTINGS.control_or_wager = SETTINGS.matrix_experiment(1).family(1,3);
    elseif family == 2
        Trial_family_2            = Trial_family_2+1;
        sample                    = SETTINGS.matrix_experiment(2).family(1,1);
        nonsample                 = SETTINGS.matrix_experiment(2).family(1,2);
        SETTINGS.control_or_wager = SETTINGS.matrix_experiment(2).family(1,3);
    elseif family == 3
        Trial_family_3            = Trial_family_3+1;
        sample                    = SETTINGS.matrix_experiment(3).family(1,1);
        nonsample                 = SETTINGS.matrix_experiment(3).family(1,2);
        SETTINGS.control_or_wager = SETTINGS.matrix_experiment(3).family(1,3);
    end
    
    %% Defining values to analyze data      
    
    unsuccess                 = 0;
    rest_sensor_hold_success  = 0;
    subject_got_sample        = 0;
    check_loaded_eye_position = 0;
    eye_position_changed      = 0;
    low_wager_right           = 0;
    high_wager_right          = 0;
    Wager_selected            = 0;
    right_match_to_sample     = 0;
    left_match_to_sample      = 0;
    match_to_sample_selected  = 0;
    correct_selection         = 0;
    ms_side                   = 0;
    right_control             = 0;
    left_control              = 0;
    control_selected          = 0;
    text_feedback             = NaN;
    wager_control_completed   = 0;
    amount_rectangular_wagering1 = 0;
    amount_rectangular_wagering2 = 0;
    decision_left_wagering1      = 0;
    decision_left_wagering2      = 0;
    side_low_wager               = 0;
    punished                     = 0;
    Amount_clicks                = 0;  
    Amount_clicks_wagering1      = 0;
    Amount_clicks_wagering2      = 0;
    value_choosen_punishment     = 0;
    
    time_pressed_rest                         =NaN;
    time_pressed_rest_run                     =NaN;
    time_sample_appeared                      =NaN;
    time_sample_appeared_run                  =NaN;
    Time_subject_got_sample                   =NaN;
    Time_subject_got_sample_run               =NaN;
    time_matchtosample_appeared               =NaN;
    time_matchtosample_appeared_run           =NaN;
    time_match_to_sample_selected             =NaN;
    time_match_to_sample_selected_run         =NaN;
    reward_time_run                           =NaN;
    time_controlsample_appeared               =NaN;
    time_controlsample_appeared_run           =NaN;
    time_control_selected                     =NaN;
    time_control_selected_run                 =NaN;
    wagering_or_controll_wagering1            =NaN;
    wagering_or_controll_wagering2            =NaN;
    Wager_time_decided                        =NaN;
    Wager_time_decided_wagering1              =NaN;
    Wager_time_decided_wagering2              =NaN;
    time_match_to_sample_end                  =NaN;
    value_choosen                             =NaN;
    wager_choosen                             =NaN;
    Wager_start_time                          =NaN;
    Wager_start_time_wagering1                =NaN;
    Wager_start_time_wagering2                =NaN;
    Wager_time_decided_highvslow              =NaN;
    Wager_time_decided_highvslow_1            =NaN;
    Wager_time_decided_highvslow_1_run        =NaN;
    Wager_time_decided_highvslow_2            =NaN;
    Wager_time_decided_highvslow_2_run        =NaN;
    Wager_start_time_wagering1_run            =NaN;
    Wager_start_time_wagering2_run            =NaN;
    Wager_time_decided_wagering1_run          =NaN;
    Wager_time_decided_wagering2_run          =NaN;
    time_punished                             =NaN;
    time_presented_feedback                   =NaN;
    time_presented_feedback_run               =NaN;
    time_punished_run                         =NaN;
    low_wager_right_pre                       =NaN;
    high_wager_right_pre                      =NaN;
    low_wager_right_post                      =NaN;
    high_wager_right_post                     =NaN;
    side_low_wager_pre                        =NaN;
    side_low_wager_post                       =NaN;
    
    dyn_wager.control_condition               = 0;
    dyn_wager.instructed_cue                  = 0;
    dyn_wager.instructed_cue_left             = 0;
    
    
    %% Start presenting visual cues
    
    Screen('FrameRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest,10);
    Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_dim,dyn_wager.position_fixation);
    Screen(SETTINGS.window,'Flip');
    
    Trial_start_time = GetSecs;
    Trial_start_time_run = Trial_start_time-RunStartTime;
    
    
    while 1
        if get_hands_state == SETTINGS.rest_buttons && ~check_fixation(eye_offset_x,eye_offset_y)
            % touching sensors, not yet fixating
            Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
            Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_dim,dyn_wager.position_fixation);
            Screen(SETTINGS.window,'Flip');
        elseif get_hands_state ~= SETTINGS.rest_buttons && check_fixation(eye_offset_x,eye_offset_y)
            % not touching sensors, fixating
            Screen('FrameRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest,10);
            Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright2,dyn_wager.position_fixation);
            Screen(SETTINGS.window,'Flip');
        elseif get_hands_state ~= SETTINGS.rest_buttons && ~check_fixation(eye_offset_x,eye_offset_y),
            % not touching, not fixating
            Screen('FrameRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest,10);
            Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_dim,dyn_wager.position_fixation);
            Screen(SETTINGS.window,'Flip');
        elseif get_hands_state == SETTINGS.rest_buttons && check_fixation(eye_offset_x,eye_offset_y)
            break;
        end
        [eye_offset_x eye_offset_y eye_position_changed] = calibrating_eyes(eye_offset_x,eye_offset_y,eye_position_changed);
        if KbCheck
            [~,~,keyCode,~] = KbCheck;
            if keyCode(112) % F1 % this is because ESC doesn't work with 2 other buttons
                break;
            end
            if keyCode(27) % Esc
                break;
            end
        end
    end
    
    %% Rest hand inputs activated and correct eye fixation
    
    Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
    Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
    Screen(SETTINGS.window,'Flip');
    
    rest_HT = SETTINGS.base_rest_HT+rand*SETTINGS.rand_rest_HT; % Holding time for rest hand inputs
    
    time_pressed_rest = GetSecs;
    time_pressed_rest_run = time_pressed_rest - RunStartTime;
    
    eye_position_changed = 0;
    
    while 1
        [eye_offset_x eye_offset_y eye_position_changed] = calibrating_eyes(eye_offset_x,eye_offset_y,eye_position_changed);
        if get_hands_state~= SETTINGS.rest_buttons; % Cancell if subject releases the rest hand inputs
            [unsuccess] = failure4;
            break;
        end
        if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time); % Cancell if subject look away from the allowed fixation area
            [unsuccess] = failure6;
            break;
        end
        if GetSecs - time_pressed_rest > rest_HT % Determine Holding Time for rest hand inputs
            rest_sensor_hold_success = 1;
            break;
        end
    end
    
    %% INITIAL POSITION CORRECT, EVERING READY FOR SAMPLE PRESENTATION
    
    if rest_sensor_hold_success, % continue to target hand input
        
        position_sample = [SETTINGS.screen_w_pix/2-SETTINGS.size_images/2 SETTINGS.screen_h_pix/2-SETTINGS.size_images/2 SETTINGS.screen_w_pix/2+SETTINGS.size_images/2 SETTINGS.screen_h_pix/2+SETTINGS.size_images/2];
        
        Screen('DrawTexture',SETTINGS.window,img(sample),[0 0 SETTINGS.size_images SETTINGS.size_images], position_sample);
        Screen(SETTINGS.window,'Flip');
        
        time_sample_appeared = GetSecs;
        time_sample_appeared_run = time_sample_appeared - RunStartTime;
        
        %% PRESENT SAMPLE
        
        SETTINGS.grace_time = SETTINGS.grace_time_sample;
        
        while true
            if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time)
                [unsuccess] = failure6;
                break;
            end
            if get_hands_state ~= SETTINGS.rest_buttons
                [unsuccess] = failure4;
                break;
            end
            if (GetSecs - time_sample_appeared) > SETTINGS.time_present_sample % Abort trial if no movement was initiated in allowed time
                Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
                Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
                Screen(SETTINGS.window,'Flip');
                Time_subject_got_sample = GetSecs;
                Time_subject_got_sample_run = Time_subject_got_sample - RunStartTime;
                subject_got_sample = 1;
                break;
            end
        end
        
        SETTINGS.grace_time = SETTINGS.grace_time_nonsample_or_mts;
        
        
        %% Recording BOLD Signal related to the sample aquisition
        
        eye_position_changed = 0;
        
        if subject_got_sample,
            last_event_time  = GetSecs;
            time_record_BOLD = SETTINGS.time_process_sample;
            [unsuccess] = bold_record(last_event_time,time_record_BOLD,eye_offset_x,eye_offset_y,eye_position_changed,allow_grace_time);
        end
        
        %% FIRST WAGER OR CONTROL  
        
        if SETTINGS.wager
            
            if SETTINGS.pre_or_post ==1 % always post wagering
                SETTINGS.control_or_wager = 1;
            elseif SETTINGS.pre_or_post ==2 % always pre wagering
                SETTINGS.control_or_wager = 2;              
            end
            
            switch SETTINGS.control_or_wager
                case 1 % control
                    dyn_wager.control_condition = 1;
                    dyn_wager.instructed_cue = randsample([1 2 3 4 5 6], 1, true, [100/6 100/6 100/6 100/6 100/6 100/6]);
                    if  dyn_wager.instructed_cue>3
                        dyn_wager.instructed_cue_left = -1;
                    else
                        dyn_wager.instructed_cue_left = 1;
                    end
                    
                case 2 % wagering
                    dyn_wager.control_condition = 0;
            end
            
            if ~unsuccess
                [side_low_wager low_wager_right high_wager_right]=position_wager_high_low;
                low_wager_right_pre= low_wager_right;
                high_wager_right_pre= high_wager_right;
                side_low_wager_pre= side_low_wager;
                wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
                Wager_start_time = GetSecs;
                Wager_start_time_wagering1 = GetSecs;
                Wager_start_time_wagering1_run = Wager_start_time_wagering1 - RunStartTime;
            end
            
            while ~unsuccess
                if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time), % if subject look away from the allowed fixation area
                    [unsuccess] = failure6;
                    break;
                end
                if get_hands_state == SETTINGS.no_button, % Prevent subject of releasing also the RIGHT hand of the rest hand input
                    [unsuccess] = failure5;
                    break;
                end
                if GetSecs - Wager_start_time_wagering1 >= SETTINGS.allowed_wager_time;
                    [unsuccess] = failure10;
                    break;
                end
                if get_hands_state ~= SETTINGS.rest_buttons
                    [Amount_clicks Wager_time_decided_highvslow wager_choosen value_choosen unsuccess amount_rectangular decision_left wager_control_completed Wager_time_decided] = wager(Amount_clicks,Wager_time_decided,wager_choosen,low_wager_right,value_choosen,Wager_start_time,eye_offset_x,eye_offset_y,allow_grace_time);
                    break;
                end
            end
            amount_rectangular_wagering1=amount_rectangular;
            wagering_or_controll_wagering1=dyn_wager.control_condition;
            decision_left_wagering1= decision_left;
            Wager_time_decided_wagering1= Wager_time_decided;
            Wager_time_decided_wagering1_run= Wager_time_decided_wagering1 - RunStartTime;
            Wager_time_decided_highvslow_1 = Wager_time_decided_highvslow;
            Wager_time_decided_highvslow_1_run =  Wager_time_decided_highvslow_1 - RunStartTime;
            Amount_clicks_wagering1= Amount_clicks;
            
            %% Recording BOLD Signal related to first wager or control selection
            
            eye_position_changed = 0;
            
            if ~unsuccess
                last_event_time = GetSecs;
                time_record_BOLD = SETTINGS.time_process_wager_or_control;
                [unsuccess] = bold_record(last_event_time,time_record_BOLD,eye_offset_x,eye_offset_y,eye_position_changed,allow_grace_time);
            end
            
        end
        
        %% PRESENT MATCH-TO-SAMPLE OPTIONS
        
        SETTINGS.grace_time = SETTINGS.grace_time_match_sample;
        
        if ~unsuccess
            
            ms_side = randsample([1 2], 1, true, [50 50]);
            
            if ms_side == 2
                ms_counter_side = 1;
                extra_side = SETTINGS.dist_extra_right;
                extra_counter_side = SETTINGS.dist_extra_left;
            else
                ms_counter_side = 2;
                extra_side = SETTINGS.dist_extra_left;
                extra_counter_side = SETTINGS.dist_extra_right;
            end
            
            position_msample        = [(ms_side*(SETTINGS.screen_w_pix/3))+extra_side-SETTINGS.size_images/2 SETTINGS.screen_h_pix/2-SETTINGS.size_images/2 (ms_side*(SETTINGS.screen_w_pix/3))+extra_side+SETTINGS.size_images/2 SETTINGS.screen_h_pix/2+SETTINGS.size_images/2]; % match-to-sample is always ms_side
            position_nonmsample     = [(ms_counter_side*(SETTINGS.screen_w_pix/3))+extra_counter_side-SETTINGS.size_images/2 SETTINGS.screen_h_pix/2-SETTINGS.size_images/2 (ms_counter_side*(SETTINGS.screen_w_pix/3))+extra_counter_side+SETTINGS.size_images/2 SETTINGS.screen_h_pix/2+SETTINGS.size_images/2];
            
            Screen('DrawTexture',SETTINGS.window,img(sample(1)),[0 0 SETTINGS.size_images SETTINGS.size_images], position_msample);
            Screen('DrawTexture',SETTINGS.window,img(nonsample),[0 0 SETTINGS.size_images SETTINGS.size_images], position_nonmsample);
            Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
            Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
            Screen(SETTINGS.window,'Flip');
            
            time_matchtosample_appeared = GetSecs;
            time_matchtosample_appeared_run = time_matchtosample_appeared - RunStartTime;
            
            while true
                if get_hands_state == SETTINGS.left_button % Subject chose the left match-to-sample
                    left_match_to_sample = 1;
                    match_to_sample_selected = 1;
                    time_match_to_sample_selected = GetSecs;
                    time_match_to_sample_end = GetSecs;
                    time_match_to_sample_selected_run = time_match_to_sample_selected - RunStartTime;
                    Screen('DrawTexture',SETTINGS.window,img(sample),[0 0 SETTINGS.size_images SETTINGS.size_images], position_msample);
                    Screen('DrawTexture',SETTINGS.window,img(nonsample),[0 0 SETTINGS.size_images SETTINGS.size_images], position_nonmsample);
                    Screen('FrameRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest,10);
                    Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
                    Screen(SETTINGS.window,'Flip');
                    break;
                end
                
                if get_hands_state == SETTINGS.right_button % Subject chose the right match-to-sample
                    right_match_to_sample = 1;
                    match_to_sample_selected = 1;
                    time_match_to_sample_selected = GetSecs;
                    time_match_to_sample_end = GetSecs;
                    time_match_to_sample_selected_run = time_match_to_sample_selected - RunStartTime;
                    Screen('DrawTexture',SETTINGS.window,img(sample),[0 0 SETTINGS.size_images SETTINGS.size_images], position_msample);
                    Screen('DrawTexture',SETTINGS.window,img(nonsample),[0 0 SETTINGS.size_images SETTINGS.size_images], position_nonmsample);
                    Screen('FrameRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest,10);
                    Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
                    Screen(SETTINGS.window,'Flip');
                    break;
                end
                if (GetSecs - time_matchtosample_appeared) > SETTINGS.time_present_match_to_sample % Abort trial if no target is selected in allowed Reaction Time
                    [unsuccess] = failure1;
                    time_match_to_sample_end = GetSecs;
                    break;
                end
                if get_hands_state == SETTINGS.no_button % Prevent subject of releasing also the RIGHT hand of the rest hand input
                    [unsuccess] = failure5;
                    time_match_to_sample_end = GetSecs;
                    break;
                end
                if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time) % if subject look away from the allowed fixation area
                    [unsuccess] = failure6;
                    time_match_to_sample_end = GetSecs;
                    break;
                end
            end
            
            while 1
                if get_hands_state == SETTINGS.no_button
                    [unsuccess] = failure3; % both button released after match-to-sample
                    break;
                elseif GetSecs - time_match_to_sample_end > SETTINGS.time_both_buttons_release
                    break;
                end
            end
        end
        
        while ~unsuccess
            if get_hands_state == SETTINGS.rest_buttons
                Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
                Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
                Screen(SETTINGS.window,'Flip');
                break;
            end
            if GetSecs - time_match_to_sample_selected > SETTINGS.time_back_match_to_sample % Abort trial if no target is pressed in allowed Reaction Time
                [unsuccess] = failure1; %too slow
                break;
            end
        end
        
        SETTINGS.grace_time = SETTINGS.grace_time_nonsample_or_mts;
        
        %% Recording BOLD Signal related to the match-to-sample selection
        
        eye_position_changed = 0;
        
        if ~unsuccess
            last_event_time = GetSecs;
            time_record_BOLD = SETTINGS.time_process_match_to_sample;
            [unsuccess] = bold_record(last_event_time,time_record_BOLD,eye_offset_x,eye_offset_y,eye_position_changed,allow_grace_time);
        end
        
        
        %% SECOND WAGER OR CONTROL
        
        if SETTINGS.wager
            
            if SETTINGS.control_or_wager == 1 % first wager_or_control was control
                dyn_wager.control_condition   = 0;
                dyn_wager.instructed_cue_left = 0;
            elseif SETTINGS.control_or_wager == 2 % first wager_or_control was wagering
                dyn_wager.control_condition = 1;
                dyn_wager.instructed_cue = randsample([1 2 3 4 5 6], 1, true, [100/6 100/6 100/6 100/6 100/6 100/6]);
                if  dyn_wager.instructed_cue>3
                    dyn_wager.instructed_cue_left = -1;
                else
                    dyn_wager.instructed_cue_left = 1;
                end
            end
            
            if ~unsuccess
                [side_low_wager low_wager_right high_wager_right]=position_wager_high_low;
                low_wager_right_post= low_wager_right;
                high_wager_right_post= high_wager_right;
                side_low_wager_post= side_low_wager;
                wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
                Wager_start_time = GetSecs;
                Wager_start_time_wagering2 = GetSecs;
                Wager_start_time_wagering2_run = Wager_start_time_wagering2 - RunStartTime;
            end
            
            while ~unsuccess
                if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time), % if subject look away from the allowed fixation area
                    [unsuccess] = failure6;
                    break;
                end
                if get_hands_state == SETTINGS.no_button, % Prevent subject of releasing also the RIGHT hand of the rest hand input
                    [unsuccess] = failure5;
                    break;
                end
                if GetSecs - Wager_start_time_wagering2 >= SETTINGS.allowed_wager_time; % Prevent subject of releasing also the RIGHT hand of the rest hand input
                    [unsuccess] = failure10;
                    break;
                end
                if get_hands_state ~= SETTINGS.rest_buttons
                    [Amount_clicks Wager_time_decided_highvslow wager_choosen value_choosen unsuccess amount_rectangular decision_left wager_control_completed Wager_time_decided] = wager(Amount_clicks,Wager_time_decided,wager_choosen,low_wager_right,value_choosen,Wager_start_time,eye_offset_x,eye_offset_y,allow_grace_time);
                    break;
                end
            end
            amount_rectangular_wagering2=amount_rectangular;
            wagering_or_controll_wagering2=dyn_wager.control_condition;
            decision_left_wagering2= decision_left;
            Wager_time_decided_wagering2= Wager_time_decided;
            Wager_time_decided_wagering2_run= Wager_time_decided_wagering2 - RunStartTime;
            Wager_time_decided_highvslow_2= Wager_time_decided_highvslow;
            Wager_time_decided_highvslow_2_run =  Wager_time_decided_highvslow_2 - RunStartTime;
            Amount_clicks_wagering2= Amount_clicks;
            
            %% Recording BOLD Signal related to the match-to-sample selection
            
            eye_position_changed = 0;
            
            if ~unsuccess
                last_event_time = GetSecs;
                time_record_BOLD = SETTINGS.time_process_wager_or_control;
                [unsuccess] = bold_record(last_event_time,time_record_BOLD,eye_offset_x,eye_offset_y,eye_position_changed,allow_grace_time);
            end
            
        end
        
        %% PRESENT FEED-BACK
        if ~unsuccess
            % correct selection
            if (ms_side == 1 && left_match_to_sample == 1) || (ms_side == 2 && right_match_to_sample == 1),
                correct_selection = 1;
                count_correct_selection = count_correct_selection+1;
                if SETTINGS.wager
                    baseline_value = baseline_value + (value_choosen+SETTINGS.sum_payment_matrix_correct);   
                    if present_feedback,
                        DrawFormattedText(SETTINGS.window,['You won ' num2str(value_choosen) '�'],'center','center',[0 255 0]);
                        %DrawFormattedText(SETTINGS.window,['Now you have ' num2str(baseline_value) '�'],'center',(SETTINGS.screen_h_pix/2)+50,[0 255 0]);
                        Screen(SETTINGS.window,'Flip');
                        time_presented_feedback = GetSecs;
                        time_presented_feedback_run= time_presented_feedback - RunStartTime;
                        WaitSecs(SETTINGS.time_present_earnings);
                    end
                else
                    DrawFormattedText(SETTINGS.window,'Correct','center','center',[0 255 0]);
                    Screen(SETTINGS.window,'Flip');
                     time_presented_feedback = GetSecs;
                     time_presented_feedback_run= time_presented_feedback - RunStartTime;
                    WaitSecs(SETTINGS.time_present_earnings);
                end                
            end
            % incorrect selection
            if (ms_side == 1 && right_match_to_sample == 1) || (ms_side == 2 && left_match_to_sample == 1),
                count_incorrect_selection = count_incorrect_selection+1;
                unsuccess=2;
                if SETTINGS.wager
                    if wager_choosen> 3
                        baseline_value = baseline_value - (value_choosen+SETTINGS.sum_payment_matrix_incorrect);
                    else
                        baseline_value = baseline_value - (value_choosen);
                    end
                    
                    if present_feedback,
                        DrawFormattedText(SETTINGS.window,['You lost ' num2str(value_choosen) '�'],'center','center',[255 0 0]);
                        %DrawFormattedText(SETTINGS.window,['Now you have ' num2str(baseline_value) '�'],'center',(SETTINGS.screen_h_pix/2)+50,[255 0 0]);
                        Screen(SETTINGS.window,'Flip');
                         time_presented_feedback = GetSecs;
                         time_presented_feedback_run= time_presented_feedback - RunStartTime;
                        WaitSecs(SETTINGS.time_present_earnings);
                    end
                else
                    DrawFormattedText(SETTINGS.window,'incorrect','center','center',[255 0 0]);
                    Screen(SETTINGS.window,'Flip');
                     time_presented_feedback = GetSecs;
                     time_presented_feedback_run= time_presented_feedback - RunStartTime;
                    WaitSecs(SETTINGS.time_present_earnings);
                end
            end
        end
        
        deg = abs(nonsample-sample);
        
        if unsuccess ~= 2 && unsuccess ~=0 && Trial>30
            if (count_correct_selection+count_incorrect_selection)/Trial < punish_error_percentage
                value_choosen_punishment = ((str2num(SETTINGS.wager_4))/100);
                punished=1;
                time_punished = GetSecs;
                time_punished_run = time_punished - RunStartTime;
            elseif deg<3 && ~isnan(time_matchtosample_appeared) && punish_error_specific
                if SETTINGS.control_or_wager == 2
                    value_choosen_punishment = value_choosen;
                else
                    value_choosen_punishment = ((str2num(SETTINGS.wager_1))/100);
                end
                punished=1;
                time_punished = GetSecs;
                time_punished_run = time_punished - RunStartTime;
            end
            if punished
                baseline_value = baseline_value - value_choosen_punishment;
                DrawFormattedText(SETTINGS.window,['You lost ' num2str(value_choosen_punishment) '�'],'center','center',[255 0 0]);
                Screen(SETTINGS.window,'Flip');
                WaitSecs(SETTINGS.time_present_earnings);
            end
        end
        
    end
    
    
    Trial_finish_time = GetSecs;
    Trial_finish_time_run = GetSecs-RunStartTime;
    
    if SETTINGS.wager
        if SETTINGS.control_or_wager==1 
            text_task = 'post';
        else
            text_task = 'pre';
        end
    else
        text_task = 'non';
    end
    
    if family == 1
        text_family = 'easy';
    elseif family == 2
        text_family = 'medium';
    elseif family == 3
        text_family = 'hard';
    end
    
    fprintf('T: %d \t Sel: \t %d Error: %.2f \t P: %d \t Psel: %d \t U: %d \t tot: %.2f \t Wag: %.2f \t Deg: %d \t Fam: %s \t t: %s \t grace: %.2f \n', ...
        Trial, count_correct_selection+count_incorrect_selection, (count_correct_selection/(count_correct_selection+count_incorrect_selection))-(count_correct_selection/Trial),round((count_correct_selection/Trial)*100),round((count_correct_selection/(count_correct_selection+count_incorrect_selection)*100)), unsuccess, baseline_value, value_choosen, deg, text_family, text_task, SETTINGS.grace_time);
    
    Screen(SETTINGS.window,'Flip');
    WaitSecs(SETTINGS.ITI_base); % ITI
    
    
    %% SAVE DATA
    
    trial(Trial).Trial                                     =Trial;
    trial(Trial).family                                    =family;
    trial(Trial).sample                                    =sample;
    trial(Trial).nonsample                                 =nonsample;
    trial(Trial).unsuccess                                 =unsuccess;
    trial(Trial).rest_sensor_hold_success                  =rest_sensor_hold_success;
    trial(Trial).rest_HT                                   =rest_HT;
    trial(Trial).eye_position_changed                      =eye_position_changed;
    trial(Trial).check_loaded_eye_position                 =check_loaded_eye_position;
    trial(Trial).correct_selection                         =correct_selection;
    trial(Trial).text_feedback                             =text_feedback;
    trial(Trial).ms_side                                   =ms_side;
    trial(Trial).low_wager_right_pre                       =low_wager_right_pre;
    trial(Trial).side_low_wager_pre                        =side_low_wager_pre;
    trial(Trial).high_wager_right_pre                      =high_wager_right_pre;
    trial(Trial).low_wager_right_post                      =low_wager_right_post;
    trial(Trial).side_low_wager_post                       =side_low_wager_post;
    trial(Trial).high_wager_right_post                     =high_wager_right_post;
    trial(Trial).subject_got_sample                        =subject_got_sample;
    trial(Trial).Wager_selected                            =Wager_selected;
    trial(Trial).right_match_to_sample                     =right_match_to_sample;
    trial(Trial).left_match_to_sample                      =left_match_to_sample;
    trial(Trial).match_to_sample_selected                  =match_to_sample_selected;
    trial(Trial).right_control                             =right_control;
    trial(Trial).left_control                              =left_control;
    trial(Trial).control_selected                          =control_selected;
    trial(Trial).amount_rectangular_wagering1              =amount_rectangular_wagering1;
    trial(Trial).amount_rectangular_wagering2              =amount_rectangular_wagering2;
    trial(Trial).wagering_or_controll_wagering1            =wagering_or_controll_wagering1;
    trial(Trial).wagering_or_controll_wagering2            =wagering_or_controll_wagering2;
    trial(Trial).instructed_cue                            =dyn_wager.instructed_cue;
    trial(Trial).value_choosen                             =value_choosen;
    trial(Trial).baseline_value                            =baseline_value;
    trial(Trial).wager_choosen                             =wager_choosen;
    trial(Trial).present_feedback                          =present_feedback;
    trial(Trial).punish_error_percentage                   =punish_error_percentage;
    trial(Trial).punished                                  =punished;
    trial(Trial).Amount_clicks_wagering1                   =Amount_clicks_wagering1;
    trial(Trial).Amount_clicks_wagering2                   =Amount_clicks_wagering2;
    trial(Trial).value_choosen_punishment                  =value_choosen_punishment;                    
    
    trial(Trial).Trial_start_time                          =Trial_start_time;
    trial(Trial).Trial_start_time_run                      =Trial_start_time_run;
    trial(Trial).time_pressed_rest                         =time_pressed_rest;
    trial(Trial).time_pressed_rest_run                     =time_pressed_rest_run;
    trial(Trial).time_sample_appeared_run                  =time_sample_appeared_run;
    trial(Trial).time_sample_appeared_run                  =time_sample_appeared_run;
    trial(Trial).Time_subject_got_sample                   =Time_subject_got_sample;
    trial(Trial).Time_subject_got_sample_run               =Time_subject_got_sample_run;
    trial(Trial).time_controlsample_appeared               =time_controlsample_appeared;
    trial(Trial).time_controlsample_appeared_run           =time_controlsample_appeared_run;
    trial(Trial).time_control_selected                     =time_control_selected;
    trial(Trial).time_control_selected_run                 =time_control_selected_run;
    trial(Trial).time_matchtosample_appeared               =time_matchtosample_appeared;
    trial(Trial).time_matchtosample_appeared_run           =time_matchtosample_appeared_run;
    trial(Trial).time_match_to_sample_selected             =time_match_to_sample_selected;
    trial(Trial).time_match_to_sample_selected_run         =time_match_to_sample_selected_run;
    trial(Trial).reward_time_run                           =reward_time_run;
    trial(Trial).Trial_finish_time                         =Trial_finish_time;
    trial(Trial).Trial_finish_time_run                     =Trial_finish_time_run;
    trial(Trial).Wager_time_decided_wagering1              =Wager_time_decided_wagering1;
    trial(Trial).Wager_time_decided_wagering1_run          =Wager_time_decided_wagering1_run;
    trial(Trial).Wager_time_decided_wagering2              =Wager_time_decided_wagering2;
    trial(Trial).Wager_time_decided_wagering2_run          =Wager_time_decided_wagering2_run;
    trial(Trial).Wager_start_time                          =Wager_start_time;
    trial(Trial).Wager_start_time_wagering1                =Wager_start_time_wagering1;
    trial(Trial).Wager_start_time_wagering1_run            =Wager_start_time_wagering1_run;
    trial(Trial).Wager_start_time_wagering2                =Wager_start_time_wagering2;
    trial(Trial).Wager_start_time_wagering2_run            =Wager_start_time_wagering2_run;
    trial(Trial).Wager_time_decided_highvslow_1            =Wager_time_decided_highvslow_1;
    trial(Trial).Wager_time_decided_highvslow_1_run        =Wager_time_decided_highvslow_1_run;
    trial(Trial).Wager_time_decided_highvslow_2            =Wager_time_decided_highvslow_2;
    trial(Trial).Wager_time_decided_highvslow_2_run        =Wager_time_decided_highvslow_2_run;
    trial(Trial).time_punished                             =time_punished;
    trial(Trial).time_punished_run                         =time_punished_run;
    trial(Trial).time_presented_feedback                   =time_presented_feedback;
    trial(Trial).time_presented_feedback_run               =time_presented_feedback_run;

    
    if Trial > 1,
        save(outFileMat,'trial','-append');
    else
        save(outFileMat,'trial','SETTINGS');
    end
    
    switch SETTINGS.setup
        case 'UMG'
            if GetSecs - RunStartTime > 600;
                break;
            end
    end
    
    if unsuccess==0 || unsuccess==2
        SETTINGS.family_matrix=SETTINGS.family_matrix(2:end);
        if family == 1
            SETTINGS.matrix_experiment(1).family = SETTINGS.matrix_experiment(1).family(2:end,:);
        elseif family == 2
            SETTINGS.matrix_experiment(2).family = SETTINGS.matrix_experiment(2).family(2:end,:);
        elseif family == 3
            SETTINGS.matrix_experiment(3).family = SETTINGS.matrix_experiment(3).family(2:end,:);
        end
    else 
       SETTINGS.family_matrix= Shuffle(SETTINGS.family_matrix);
        if family ==1 
           SETTINGS.matrix_experiment(1).family= SETTINGS.matrix_experiment(1).family(randperm(end),:);
        elseif family == 2
           SETTINGS.matrix_experiment(2).family= SETTINGS.matrix_experiment(2).family(randperm(end),:);
        elseif family == 3
           SETTINGS.matrix_experiment(3).family= SETTINGS.matrix_experiment(3).family(randperm(end),:);
        end
    end
    
    
    
    if isempty(SETTINGS.family_matrix)
        break;
    end
    
    if length(SETTINGS.family_matrix) == ((SETTINGS.n_trials)/2)
        while 1
            DrawFormattedText(SETTINGS.window,'PAUSE','center','center',[255 255 255]);
            DrawFormattedText(SETTINGS.window,['Now you have ' num2str(baseline_value) '�'],'center',(SETTINGS.screen_h_pix/2)+50,[255 255 255]);
            Screen(SETTINGS.window,'Flip');
            if KbCheck
                [~,~,keyCode,~] = KbCheck;
                if keyCode(13)  % Enter
                    Screen(SETTINGS.window,'Flip');
                    break;
                end
            end
        end
    end
    
end

switch SETTINGS.button_or_sensor,
    case 'buttons'
        ListenChar(0); % will turn off character listening and reset the buffer which holds the captured characters
end

save([path_eye],'eye_offset_x','eye_offset_y','eye_gain_x','eye_gain_y');

fprintf(['\nSaved eye calibration\n']);

Screen('CloseAll');


function awesome_degree_matrix_generator

global SETTINGS

deg(1).rot(1).sample                     = [1 2];
deg(1).rot(2).sample                     = [2 3];
deg(1).rot(3).sample                     = [3 4];
deg(1).rot(4).sample                     = [4 5];
deg(1).rot(5).sample                     = [5 6];
deg(1).rot(6).sample                     = [6 7];
deg(1).rot(7).sample                     = [7 8];
deg(1).rot(8).sample                     = [8 9];
deg(1).rot(9).sample                     = [9 10]; 
deg(1).rot(10).sample                    = [10 9];

deg(2).rot(1).sample                     = [1 3];
deg(2).rot(2).sample                     = [2 4];
deg(2).rot(3).sample                     = [3 5];
deg(2).rot(4).sample                     = [4 6];
deg(2).rot(5).sample                     = [5 7];
deg(2).rot(6).sample                     = [6 8];
deg(2).rot(7).sample                     = [7 9];
deg(2).rot(8).sample                     = [8 6];%
deg(2).rot(9).sample                     = [9 7];%
deg(2).rot(10).sample                    = [10 8];

deg(3).rot(1).sample                     = [1 4];
deg(3).rot(2).sample                     = [2 5];
deg(3).rot(3).sample                     = [3 6];
deg(3).rot(4).sample                     = [4 7];
deg(3).rot(5).sample                     = [5 8];
deg(3).rot(6).sample                     = [6 9];
deg(3).rot(7).sample                     = [7 10];
deg(3).rot(8).sample                     = [8 5];%
deg(3).rot(9).sample                     = [9 6];%
deg(3).rot(10).sample                    = [10 7];%

deg(4).rot(1).sample                     = [1 5];
deg(4).rot(2).sample                     = [2 6];
deg(4).rot(3).sample                     = [3 7];
deg(4).rot(4).sample                     = [4 8];
deg(4).rot(5).sample                     = [5 9];
deg(4).rot(6).sample                     = [6 10];
deg(4).rot(7).sample                     = [7 3];%
deg(4).rot(8).sample                     = [8 4];%
deg(4).rot(9).sample                     = [9 5];%
deg(4).rot(10).sample                    = [10 6];%

deg(5).rot(1).sample                     = [1 6];
deg(5).rot(2).sample                     = [2 7];
deg(5).rot(3).sample                     = [3 8];
deg(5).rot(4).sample                     = [4 9];
deg(5).rot(5).sample                     = [5 10];
deg(5).rot(6).sample                     = [6 1];%
deg(5).rot(7).sample                     = [7 2];%
deg(5).rot(8).sample                     = [8 3];%
deg(5).rot(9).sample                     = [9 4];%
deg(5).rot(10).sample                    = [10 5];%

for f = 1:3   
    
    matrix_1 = [];
    
    size_deg1 = size(deg(1).rot);
    size_deg1 = size_deg1(2);
    
    for n = 1:size_deg1
        matrix_1 = [deg(1).rot(n).sample; matrix_1];
    end
    
    matrix_2 = [];
    
    size_deg2 = size(deg(2).rot);
    size_deg2 = size_deg2(2);
    
    for n = 1:size_deg2
        matrix_2 = [deg(2).rot(n).sample; matrix_2];
    end
    
    matrix_3 = [];
    
    size_deg3 = size(deg(3).rot);
    size_deg3 = size_deg3(2);
    
    for n = 1:size_deg3
        matrix_3 = [deg(3).rot(n).sample; matrix_3];
    end
    
    matrix_4 = [];
    
    size_deg4 = size(deg(4).rot);
    size_deg4 = size_deg4(2);
    
    for n = 1:size_deg4
        matrix_4 = [deg(4).rot(n).sample; matrix_4];
    end
    
    matrix_5 = [];
    
    size_deg5 = size(deg(5).rot);
    size_deg5 = size_deg5(2);
    
    for n = 1:size_deg5
        matrix_5 = [deg(5).rot(n).sample; matrix_5];
    end
    
    rot_deg_matrix = Shuffle(repmat(SETTINGS.rot_deg_prop(f).family,1,((SETTINGS.n_trials/3)/(length(SETTINGS.rot_deg_prop(f).family)))));
    
    matrix_experiment(f).family = [];
    
    for c = 1:length(rot_deg_matrix)
        
        if rot_deg_matrix(c) == 1
            matrix_exp = matrix_1(randi(size_deg1),:);
        elseif rot_deg_matrix(c) == 2
            matrix_exp = matrix_2(randi(size_deg2),:);
        elseif rot_deg_matrix(c) == 3
            matrix_exp = matrix_3(randi(size_deg3),:);
        elseif rot_deg_matrix(c) == 4
            matrix_exp = matrix_4(randi(size_deg4),:);
        elseif rot_deg_matrix(c) == 5
            matrix_exp = matrix_5(randi(size_deg5),:);
        end
        
        matrix_experiment(f).family = [matrix_experiment(f).family; matrix_exp];
        
    end
    
    SETTINGS.matrix_experiment(f).family      = matrix_experiment(f).family;
    matrix_family_pre                         = Shuffle(repmat(1:2,1,(length(SETTINGS.matrix_experiment(f).family)/2)));
    matrix_family_pre                         = matrix_family_pre';
    SETTINGS.matrix_experiment(f).family(:,3) = matrix_family_pre;   
    
   
end

function [eye_offset_x eye_offset_y eye_position_changed] = calibrating_eyes(eye_offset_x, eye_offset_y,eye_position_changed)

global SETTINGS

if KbCheck
    [~,~,keyCode,~] = KbCheck;
    if keyCode(115) && ~eye_position_changed  %F4
        disp(sprintf(' Updating offsets %.2f %.2f', SETTINGS.x, SETTINGS.y));
        eye_offset_x = eye_offset_x + (0 - SETTINGS.x);
        eye_offset_y = eye_offset_y + (0 - SETTINGS.y);
        eye_position_changed = 1;
    end
end

function hand_status = get_hands_state

global SETTINGS

switch SETTINGS.button_or_sensor
    
    case 'sensors'
        in.address = hex2dec('379');
        hand_status = inp(in.address);
        
    case 'buttons'
        
        [~,~,keyCode,~] = KbCheck;
        
        button_idx = [49 52 50 51]; % [left right target_left target_right]
        
        switch mat2str(keyCode(button_idx))
            
            case '[0 0 0 0]'
                hand_status = SETTINGS.no_button;
            case '[0 1 0 0]'
                hand_status = SETTINGS.left_button;
            case '[1 0 0 0]'
                hand_status = SETTINGS.right_button;
            case '[1 1 0 0]'
                hand_status = SETTINGS.rest_buttons;
            otherwise
                hand_status = SETTINGS.no_button;
        end
        
end

function is_fixating = check_fixation(eye_offset_x,eye_offset_y,allow_grace_time)
persistent LastFigureUpdateTime
persistent LastOutWindowTime

global SETTINGS

if nargin < 3, % for BLINK
    allow_grace_time = 0;
end

if isempty(LastFigureUpdateTime), LastFigureUpdateTime = GetSecs; end;

x0 = 0;
y0 = 0;
r = SETTINGS.eye_fixation_radius; % deg

if SETTINGS.check_eye == 0,
    is_fixating = 1;
    x = 0;
    y = 0;
elseif SETTINGS.check_eye
    [x,y]=vpx_GetGazePointSmoothed;
    x = SETTINGS.eye_gain_x*x + eye_offset_x;
    y = SETTINGS.eye_gain_y*y + eye_offset_y;
    if sqrt(((x0 - x))^2 + (y0 - y)^2) < r
        is_fixating = 1;
        LastOutWindowTime = 0;
    else
        is_fixating = 0;
    end
    if allow_grace_time && ~is_fixating % outside
        if ~LastOutWindowTime, % was fixating previously, first sample out of the window
            LastOutWindowTime = GetSecs;
        end
        if GetSecs - LastOutWindowTime < SETTINGS.grace_time
            is_fixating = 1;
        end
    end
    if (~is_fixating && LastFigureUpdateTime > .1) || (~is_fixating && force_plot_eye)
        ang=0:0.02:2*pi;
        xp=r*cos(ang);
        yp=r*sin(ang);
        plot(x0+xp,y0+yp);
        plot(x,y,'kx');
        drawnow;
    elseif GetSecs - LastFigureUpdateTime > .1 % figure update rate
        ang=0:0.02:2*pi;
        xp=r*cos(ang);
        yp=r*sin(ang);
        plot(x0+xp,y0+yp);
        plot(x,y,'r.');
        % hold off;
        drawnow;
        LastFigureUpdateTime = GetSecs;
    end
    
    
end

SETTINGS.x = x;
SETTINGS.y = y;

function [side_low_wager low_wager_right high_wager_right] = position_wager_high_low

global SETTINGS
global dyn_wager

side_low_wager = randsample([1 3], 1, true, [50 50]);

if side_low_wager == 3, %means that the low wagers are presented on the right side
    side_high_wager = 1;
    extra_side = SETTINGS.dist_extra_right_text;
    extra_counter_side = SETTINGS.dist_extra_left_text;
    low_wager_right=1; % the low wager is on the right side (FOR DATA SAVING)
    high_wager_right=0; %the high wager is on the left side
    dyn_wager.Position_wager_1_w= [SETTINGS.excentricity_wager_position6*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_2_w= [SETTINGS.excentricity_wager_position5*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_3_w= [SETTINGS.excentricity_wager_position4*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_4_w= [SETTINGS.excentricity_wager_position3*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_5_w= [SETTINGS.excentricity_wager_position2*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_6_w= [SETTINGS.excentricity_wager_position1*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
else
    side_high_wager = 3;
    extra_side = SETTINGS.dist_extra_left_text;
    extra_counter_side = SETTINGS.dist_extra_right_text;
    low_wager_right=0;
    high_wager_right=1;
    dyn_wager.Position_wager_1_w= [SETTINGS.excentricity_wager_position1*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_2_w= [SETTINGS.excentricity_wager_position2*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_3_w= [SETTINGS.excentricity_wager_position3*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_4_w= [SETTINGS.excentricity_wager_position4*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_5_w= [SETTINGS.excentricity_wager_position5*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
    dyn_wager.Position_wager_6_w= [SETTINGS.excentricity_wager_position6*SETTINGS.screen_w_pix/10-SETTINGS.size_rectangular/3];
end

dyn_wager.position_low       = [(side_low_wager*(SETTINGS.screen_w_pix/4))+extra_side]; % match-to-sample is always side_low_wager
dyn_wager.position_high      = [(side_high_wager*(SETTINGS.screen_w_pix/4))+extra_counter_side];

function wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)

global SETTINGS
global dyn_wager

Screen('TextSize', SETTINGS.window, SETTINGS.H_L_size_text);
Screen('DrawText', SETTINGS.window, 'L', dyn_wager.position_low, SETTINGS.screen_h_pix/3 ,SETTINGS.white_color);
Screen('DrawText', SETTINGS.window, 'H', dyn_wager.position_high, SETTINGS.screen_h_pix/3 ,SETTINGS.white_color);
Screen('FillRect', SETTINGS.window, SETTINGS.gray_rectangular{grey_a}, dyn_wager.Position1, SETTINGS.size_rectangular);
Screen('FillRect', SETTINGS.window, SETTINGS.gray_rectangular{grey_a}, dyn_wager.Position2, SETTINGS.size_rectangular);
Screen('FillRect', SETTINGS.window, SETTINGS.gray_rectangular{grey_a}, dyn_wager.Position3, SETTINGS.size_rectangular);
Screen('FillRect', SETTINGS.window, SETTINGS.gray_rectangular{grey_b}, dyn_wager.Position4, SETTINGS.size_rectangular);
Screen('FillRect', SETTINGS.window, SETTINGS.gray_rectangular{grey_b}, dyn_wager.Position5, SETTINGS.size_rectangular);
Screen('FillRect', SETTINGS.window, SETTINGS.gray_rectangular{grey_b}, dyn_wager.Position6, SETTINGS.size_rectangular);

if dyn_wager.control_condition==1;
    Screen('FillRect', SETTINGS.window, SETTINGS.blue_color, dyn_wager.Position_all{dyn_wager.instructed_cue}, SETTINGS.size_oval);
end

if frame ==1; % show just the frame
    Screen('FrameRect', SETTINGS.window, color, dyn_wager.Position_all{amount_rectangular}, 3);
elseif frame == 2; % show the filled rectangular
    Screen('FillRect', SETTINGS.window, color, dyn_wager.Position_all{amount_rectangular},SETTINGS.size_rectangular);
end

Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright2,dyn_wager.position_fixation);
Screen('TextSize', SETTINGS.window, SETTINGS.size_text);

Screen('DrawText', SETTINGS.window, SETTINGS.wager_1, dyn_wager.Position_wager_1_w, dyn_wager.Position_wager_h ,SETTINGS.white_color);
Screen('DrawText', SETTINGS.window, SETTINGS.wager_2, dyn_wager.Position_wager_2_w, dyn_wager.Position_wager_h ,SETTINGS.white_color);
Screen('DrawText', SETTINGS.window, SETTINGS.wager_3, dyn_wager.Position_wager_3_w, dyn_wager.Position_wager_h ,SETTINGS.white_color);
Screen('DrawText', SETTINGS.window, SETTINGS.wager_4, dyn_wager.Position_wager_4_w, dyn_wager.Position_wager_h ,SETTINGS.white_color);
Screen('DrawText', SETTINGS.window, SETTINGS.wager_5, dyn_wager.Position_wager_5_w, dyn_wager.Position_wager_h ,SETTINGS.white_color);
Screen('DrawText', SETTINGS.window, SETTINGS.wager_6, dyn_wager.Position_wager_6_w, dyn_wager.Position_wager_h ,SETTINGS.white_color);


Screen(SETTINGS.window,'Flip');

function [Amount_clicks Wager_time_decided_highvslow wager_choosen value_choosen unsuccess amount_rectangular decision_left wager_control_completed Wager_time_decided] = wager(Amount_clicks,Wager_time_decided,wager_choosen,low_wager_right,value_choosen,Wager_start_time,eye_offset_x,eye_offset_y,allow_grace_time)

global SETTINGS
global dyn_wager

wager_control_completed = 0;
unsuccess=0;
button_press   = 1;
button_release = 0;
number_yellow = randsample([1 2 3], 1, true, [33 33 34]);

SETTINGS.gray_rectangular= {SETTINGS.gray_wager_color, SETTINGS.gray_wager_color/3};

if get_hands_state == SETTINGS.no_button,
    [unsuccess]=failure5;
elseif get_hands_state == SETTINGS.right_button;
    rectangular_side = 3;
    decision_left= -1;
    grey_a=2;
    grey_b=1;
    Wager_time_decided = GetSecs;
    Wager_time_decided_highvslow = GetSecs;
elseif get_hands_state == SETTINGS.left_button;
    rectangular_side = 0;
    decision_left= 1;
    grey_a=1;
    grey_b=2;
    Wager_time_decided = GetSecs;
    Wager_time_decided_highvslow = GetSecs;
end

if decision_left == -1 && dyn_wager.instructed_cue_left == 1;
    [unsuccess]= failure8;
elseif decision_left == 1 && dyn_wager.instructed_cue_left == -1;
    [unsuccess]= failure8;
end

if number_yellow == 1;
    amount_rectangular=1+rectangular_side;
elseif number_yellow == 2;
    amount_rectangular=2+rectangular_side;
else
    amount_rectangular=3+rectangular_side;
end

if ~unsuccess
    color = SETTINGS.yellow_color;
    frame = 1;
    wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
end

while get_hands_state ~= SETTINGS.rest_buttons
    if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time), % if subject look away from the allowed fixation area
        [unsuccess]=failure6;
        break;
    end
    if get_hands_state == SETTINGS.no_button, % Prevent subject of releasing also the RIGHT hand of the rest hand input
        [unsuccess]=failure5;
        break;
    end
    if get_hands_state == SETTINGS.rest_buttons
        color = SETTINGS.yellow_color;
        frame = 2;
        wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
        button_press = 0;
        button_release = 1;
        break;
    end
end

while true
    
    [unsuccess]=failure7(decision_left, get_hands_state, unsuccess);
    if unsuccess==7
        break;
    elseif unsuccess==8
        break;
    elseif unsuccess==6
        break;
    elseif unsuccess==5
        break;
    elseif ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time), % if subject look away from the allowed fixation area
        [unsuccess]=failure6;
        break;
    end
    if get_hands_state == SETTINGS.no_button, % Prevent subject of releasing also the RIGHT hand of the rest hand input
        [unsuccess]=failure5;
        break;
    end
    
    if get_hands_state ~= SETTINGS.rest_buttons
        if decision_left == 1;
            if get_hands_state == SETTINGS.left_button && button_release == 1; % Prevent subject of releasing also the RIGHT hand of the rest hand input
                amount_rectangular= amount_rectangular-1;
                button_release = 0;
                button_press   = 1;
                if amount_rectangular < 1;
                    amount_rectangular= 3;
                end
            end
        elseif  decision_left== -1;
            if get_hands_state == SETTINGS.right_button && button_release == 1; % Prevent subject of releasing also the RIGHT hand of the rest hand input
                button_release = 0;
                button_press   = 1;
                amount_rectangular= amount_rectangular+1;
                if amount_rectangular > 6;
                    amount_rectangular= 4;
                end
            end
        end
        frame=1;
        color=SETTINGS.yellow_color;
        wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
        Wager_time_decided = GetSecs;
        Amount_clicks= Amount_clicks+1;
    end

    
    if get_hands_state == SETTINGS.rest_buttons && button_press == 1;% Prevent subject of releasing also the RIGHT hand of the rest hand input
        button_release = 1;
        button_press = 0;
        frame=2;
        color=SETTINGS.yellow_color;
        wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
    end
    
    if GetSecs - Wager_start_time >= SETTINGS.allowed_wager_time; % Prevent subject of releasing also the RIGHT hand of the rest hand input
        frame=1;
        color=SETTINGS.green_color;
        wagering_graphic(grey_a,grey_b,amount_rectangular,frame,color)
        wager_control_completed = 1;
        WaitSecs(SETTINGS.present_visual_feedback);
        break;
    end
end

if dyn_wager.control_condition ==0 && unsuccess == 0;
    if low_wager_right==1
        if amount_rectangular ==1
            value_choosen = (str2num(SETTINGS.wager_6))/100;
            wager_choosen= 6;
        elseif amount_rectangular ==2
            value_choosen = (str2num(SETTINGS.wager_5))/100;
            wager_choosen= 5;
        elseif amount_rectangular ==3
            value_choosen = (str2num(SETTINGS.wager_4))/100;
            wager_choosen= 4;
        elseif amount_rectangular ==4
            value_choosen = (str2num(SETTINGS.wager_3))/100;
            wager_choosen= 3;
        elseif amount_rectangular ==5
            value_choosen = (str2num(SETTINGS.wager_2))/100;
            wager_choosen= 2;
        elseif amount_rectangular ==6
            value_choosen = (str2num(SETTINGS.wager_1))/100;
            wager_choosen= 1;
        end
    elseif low_wager_right==0
        if amount_rectangular ==1
            value_choosen = (str2num(SETTINGS.wager_1))/100;
            wager_choosen= 1;
        elseif amount_rectangular ==2
            value_choosen = (str2num(SETTINGS.wager_2))/100;
            wager_choosen= 2;
        elseif amount_rectangular ==3
            value_choosen = (str2num(SETTINGS.wager_3))/100;
            wager_choosen= 3;
        elseif amount_rectangular ==4
            value_choosen = (str2num(SETTINGS.wager_4))/100;
            wager_choosen= 4;
        elseif amount_rectangular ==5
            value_choosen = (str2num(SETTINGS.wager_5))/100;
            wager_choosen= 5;
        elseif amount_rectangular ==6
            value_choosen = (str2num(SETTINGS.wager_6))/100;
            wager_choosen= 6;
        end
    end
end

if dyn_wager.control_condition && unsuccess == 0;
    if dyn_wager.instructed_cue  ~= amount_rectangular
        [unsuccess] = failure9;
    end
end

function [unsuccess] = bold_record(last_event_time,time_record_BOLD,eye_offset_x,eye_offset_y,eye_position_changed,allow_grace_time)

global SETTINGS
global dyn_wager

Screen('FillRect', SETTINGS.window, SETTINGS.gray_cue_color,dyn_wager.position_rest);
Screen('FillOval', SETTINGS.window, SETTINGS.red_fix_bright1,dyn_wager.position_fixation);
Screen(SETTINGS.window,'Flip');

unsuccess = 0;

% SETTINGS.grace_time = SETTINGS.grace_time+SETTINGS.grace_time_sample;

while 1,
    if KbCheck
        [~,~,keyCode,~] = KbCheck;
        if keyCode(112) % F1 % this is because ESC doesn't work with 2 other buttons
            break;
        end
        if keyCode(27) % Esc
            break;
        end
    end
    [eye_offset_x eye_offset_y eye_position_changed] = calibrating_eyes(eye_offset_x,eye_offset_y,eye_position_changed);
    if ~check_fixation(eye_offset_x,eye_offset_y,allow_grace_time),
        DrawFormattedText(SETTINGS.window,'You broke fixation!','center','center',SETTINGS.white_color); Screen(SETTINGS.window,'Flip'); WaitSecs(1);
        unsuccess=6;
        Screen(SETTINGS.window,'Flip');
        break;
    end
    if get_hands_state ~= SETTINGS.rest_buttons
        [unsuccess]=failure4;
        Screen(SETTINGS.window,'Flip');
        break;
    end
    if GetSecs - last_event_time > time_record_BOLD,
        break;
    end
end

function [unsuccess] = failure1

global SETTINGS

unsuccess=1; % the participant reacted to slow during match-to-sample
DrawFormattedText(SETTINGS.window,'You were too slow!','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure3

global SETTINGS

unsuccess=3; %the participant released both buttons after responding to the mtach to samples, like very fast changing his mind
DrawFormattedText(SETTINGS.window,'Do not release both buttons!','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure4

global SETTINGS

unsuccess=4; %participant release to early his buttons
DrawFormattedText(SETTINGS.window,'Do not release the buttons yet!','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure5

global SETTINGS

unsuccess=5;
DrawFormattedText(SETTINGS.window,'Do not release both buttons!','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure6

global SETTINGS

unsuccess=6;
DrawFormattedText(SETTINGS.window,'You broke fixation!','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure7(decision_left, get_hands_state, unsuccess)

global SETTINGS

if get_hands_state == SETTINGS.right_button && decision_left == 1
    unsuccess=7; % false hand wagering
    DrawFormattedText(SETTINGS.window,'You used the wrong hand','center','center',SETTINGS.white_color, SETTINGS.size_text);
    Screen(SETTINGS.window,'Flip');
    WaitSecs(SETTINGS.time_present_errors);
elseif  get_hands_state == SETTINGS.left_button && decision_left == -1
    unsuccess=7;
    DrawFormattedText(SETTINGS.window,'You used the wrong hand','center','center',SETTINGS.white_color, SETTINGS.size_text);
    Screen(SETTINGS.window,'Flip');
    WaitSecs(SETTINGS.time_present_errors);
else
    unsuccess = unsuccess;
end

function [unsuccess] = failure8

global SETTINGS

unsuccess=8; % false hand during controll condition
DrawFormattedText(SETTINGS.window,'You used the wrong hand','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure9

global SETTINGS

unsuccess=9; %
DrawFormattedText(SETTINGS.window,'You have not choosen the cue','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);

function [unsuccess] = failure10

global SETTINGS

unsuccess=10; % the participant reacted to slow during wagering
DrawFormattedText(SETTINGS.window,'You were too slow!','center','center',SETTINGS.white_color, SETTINGS.size_text);
Screen(SETTINGS.window,'Flip');
WaitSecs(SETTINGS.time_present_errors);
