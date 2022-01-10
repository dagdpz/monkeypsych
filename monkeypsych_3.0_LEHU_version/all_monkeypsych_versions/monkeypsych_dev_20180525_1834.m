function monkeypsych_dev(monkey)
% Last modified 20160118 LS
% 20120307  reaching and later eye mov, first working version
% 20120417  audio cue for success
% 20120418  introduced reward probabilty
% ...
% 20130423  memory task functional
% 20130505  added delay related errors
% 20151111  Dont even know where to start... Things have changed quite a bit

% 20151120  New function get_setup for ALL setup relevant information (including ports, pins, and GUI coordinates)
%           This changes subfunctions and external functions: get_touch, setup_pp, get_sensors_state, TouchDemo, CalibrateTouchScreen, reward_pump_calibration,

% TODO list
% implement reward modulation for eye targets
% make function copy_fields_with_exceptions for copying e.g. tar to cue
% thinks about updating offsets - when and how to record it
% reward modulation for all effector conditions
% dissociated memory tasks
close all;
%Priority([2]);
ListenChar(2);

global SETTINGS
global STATE
global IO

% session - one experimental day
% there are several runs in session
% there could be several blocks in each run
% there are several trials in each block

% SETTINGS - global setting which do not change during the session
% task - describes task parameters for each run, task does not change during the run
% trial - describes everything about current trial
% dyn - timing and acquisition info, changing from state to state
% par - stimuli info, per stimulus, changing from state to state

version_filename = dir([mfilename('fullpath') '.m']);
SETTINGS.matlab_version=datevec(version('-date'));
SETTINGS.version = ['monkeypsych_dev_' datestr(version_filename.datenum,'yyyymmdd') '_' datestr(version_filename.datenum,'HHMM')];

%% Setup and monkey specific settings
get_setup_dev; %setting pertain to setup-specific DAQ and display params
set(0,'DefaultFigurePosition',SETTINGS.DefaultFigurePosition);
[task monkey_name]  = get_monkey_dev(monkey);
SETTINGS.vd         = task.vd;
sequence_indexes    = 0;

conditions      = read_conditions([SETTINGS.BASE_PATH task.condition_file]);
task.conditions = conditions;
session_folder  = datestr(date,30);
session_folder  = session_folder(1:8);
DATA_PATH       = [SETTINGS.BASE_PATH '\Data\' monkey];
pathname        = [DATA_PATH filesep session_folder];

if ~exist(pathname,'dir'),
    mkdir(DATA_PATH,session_folder);
end

fileNumber  = 1;    % find a unique file name
while true
    filename = [monkey_name datestr(date,'yyyy-mm-dd') '_' num2str(fileNumber,'%02u')];
    if exist([pathname '\' filename '.mat'],'file') || exist([pathname '\' filename],'dir')
        fileNumber = fileNumber + 1;
    else
        break
    end
end
outFileMat = [pathname '\' filename '.mat'];
outFilefolder = [pathname '\' filename];

%% eye calibration
if exist([DATA_PATH filesep 'last_eyecal.mat'],'file'),
    disp(['Found previous eye calibation in ' DATA_PATH filesep 'last_eyecal.mat']);
    load([DATA_PATH filesep 'last_eyecal.mat']);
else
    eye_offset_x=0;eye_offset_y=0;eye_gain_x=0;eye_gain_y=0;
end
task.eye.offset_x = eye_offset_x; 
task.eye.offset_y = eye_offset_y;
task.eye.gain_x = eye_gain_x;
task.eye.gain_y = eye_gain_y;

SETTINGS.screen_uh_cm       = task.screen_uh_cm;
SETTINGS.screen_w_deg       = 2*atan((SETTINGS.screen_w_cm/2)/SETTINGS.vd)/(pi/180); 
SETTINGS.screen_lh_deg      = atan((SETTINGS.screen_h_cm - SETTINGS.screen_uh_cm)/SETTINGS.vd)/(pi/180);
SETTINGS.screen_uh_deg      = atan(SETTINGS.screen_uh_cm/SETTINGS.vd)/(pi/180); 
SETTINGS.screen_h_deg       = SETTINGS.screen_lh_deg + SETTINGS.screen_uh_deg;

%% program flow, etc
SETTINGS.durTrialMax                = 20;           % max trial duration [s]
SETTINGS.fsMatlab                   = 1000;         % matlab "sampling" frequency [Hz]
SETTINGS.timeStep                   = 1/SETTINGS.fsMatlab; % duration of one matlab itteration [s] // durTick
SETTINGS.figure_drawing_interval    = 100/1000; % s, update eye pos plot every ... s
SETTINGS.bufferSize                 = SETTINGS.durTrialMax * SETTINGS.fsMatlab;
SETTINGS.dyn.memoryBuffer           = single(nan(SETTINGS.bufferSize,11)); % buffer data before writing to file
SETTINGS.FlipSyncMode               = 0;   % 0: wait for screen refresh, 1,2: dont wait. See 'dontsync' in PTB Flip documentation.

%% Initialize I/O

%% DAQ Analog input (touching and motion detection)
if SETTINGS.ai, 
    if strcmp(SETTINGS.DAQ_card, 'nidaq')
        IO.ai = analoginput('nidaq','Dev1');    % initialize analog input
    else
        IO.ai = analoginput('mcc');    % initialize analogue input
    end 
    if SETTINGS.DAQSingleEnded
        set(IO.ai,'InputType','SingleEnded'); % for new NI card 6221
    end
    if SETTINGS.touchscreen && strcmp(SETTINGS.Motion_detection_interface,'DAQ')
        addchannel(IO.ai,SETTINGS.AI_channels(1));
        addchannel(IO.ai,SETTINGS.AI_channels(2));
        addchannel(IO.ai,SETTINGS.AI_channels(3));
        addchannel(IO.ai,SETTINGS.AI_channels(4));
        
        % indices for ai sample
        IO.hand_x	= 1;
        IO.hand_y	= 2;
        IO.jaw      = 3;
        IO.body     = 4;
    elseif strcmp(SETTINGS.Motion_detection_interface,'DAQ')
        addchannel(IO.ai,SETTINGS.AI_channels(3));
        addchannel(IO.ai,SETTINGS.AI_channels(4));
        % indices for ai sample
        IO.hand_x	= NaN;
        IO.hand_y	= NaN;
        IO.jaw		= 1;
        IO.body		= 2;
    elseif SETTINGS.touchscreen
        addchannel(IO.ai,SETTINGS.AI_channels(1));
        addchannel(IO.ai,SETTINGS.AI_channels(2));
        % indices for ai sample
        IO.hand_x	= 1;
        IO.hand_y	= 2;
        IO.jaw		= NaN;
        IO.body		= NaN;
    end
end

%% DAQ Analog output (microstim)
if SETTINGS.ao, 
    if strcmp(SETTINGS.DAQ_card, 'nidaq')        
        IO.ao = analogoutput('nidaq','Dev1');    % initialize analog input
    else
        IO.ao = analogoutput('mcc');    % initialize analogue input
    end
    addchannel(IO.ao, 0); % analog output for microstim
end


%% Parallel port, used for reward AND sensors (!) AND microstim
dyn.pp_reward_value=0;
if SETTINGS.useParallel
    SETTINGS.pp.ioObj = setup_pp;
    io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_reward,dyn.pp_reward_value); % make sure valve is closed
    
elseif SETTINGS.useSerial % use serial port instead of parallel port  
    SETTINGS.sp = serial(SETTINGS.serial_port); % scanner, use USB-serial port
    fopen(SETTINGS.sp);
    set(SETTINGS.sp,'DataTerminalReady','off');    
end

%% DAQ Digital/Parallel output (states to TDT)
if  SETTINGS.use_digital_to_TDT 
    if strcmp(SETTINGS.TDT_interface,'DAQ')
        IO.do = digitalio(SETTINGS.DAQ_card,'Dev1');
        addline(IO.do,0:7,SETTINGS.daq_digital_output_port_to_TDT,'out');
    elseif strcmp(SETTINGS.TDT_interface,'Parallel') && SETTINGS.useParallel
        io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_TDT,0); % make sure digital outputs are reset
    end
end

%% Feedback sound - test            Sounds('Reward')                 Sounds('Failure')
if SETTINGS.useSound && strcmp(SETTINGS.SoundType, 'Beep')
    InitializePsychSound(1);
    sampleRate = 8192;
    SETTINGS.audioPort = PsychPortAudio('Open', [], 1, 0, sampleRate,2,[],0.1,[],16);
    [~, ~, ~] = PsychPortAudio('FillBuffer', SETTINGS.audioPort, [0;0]);
    PsychPortAudio('Start', SETTINGS.audioPort);
elseif SETTINGS.useSound && strcmp(SETTINGS.SoundType, 'XBI_sounds') %KK
    InitializePsychSound(1);
    sampleRate = 44100 ;% freq, channels
    SETTINGS.audioPort = PsychPortAudio('Open', [], 1, 0, sampleRate,2,[],0.1,[],16);
    [~, ~, ~] = PsychPortAudio('FillBuffer', SETTINGS.audioPort, [0;0]);
    PsychPortAudio('Start', SETTINGS.audioPort);  
end

%% Initialize eyetracker
if SETTINGS.useVPacq && ~SETTINGS.useMouse && ~libisloaded('vpx');
    vpx_Initialize;
    if ~vpx_GetStatus(1)
        error('ViewPoint software is not running!')
    end
elseif SETTINGS.useViewAPI && ~SETTINGS.useMouse
    [pSystemInfoData, SETTINGS.pSampleData, pEventData, pAccuracyData, CalibrationData] = InitiViewXAPI();
    calllib(SETTINGS.ViewAPIlibrary, 'iV_SetLogger', int32(1), 'iViewXSDK_monkeypsych.txt')
    
    disp('Connect to iViewX (eyetracking-server)')
    ret = calllib(SETTINGS.ViewAPIlibrary, 'iV_Connect', '192.168.1.2', int32(4444), '192.168.1.1', int32(5555));
    switch ret
        case 104
            msgbox('Could not establish connection. Check if Eye Tracker is running', 'Connection Error', 'modal');
        case 105
            msgbox('Could not establish connection. Check the communication Ports', 'Connection Error', 'modal');
        case 123
            msgbox('Could not establish connection. Another Process is blocking the communication Ports', 'Connection Error', 'modal');
        case 200
            msgbox('Could not establish connection. Check if Eye Tracker is installed and running', 'Connection Error', 'modal');
        otherwise
            msgbox('Could not establish connection', 'Connection Error', 'modal');
    end
     disp('Get System Info Data')
    calllib(SETTINGS.ViewAPIlibrary, 'iV_GetSystemInfo', pSystemInfoData)
    get(pSystemInfoData, 'Value')


	% ---------------------------------------------------------------------------- 
	% ---- start the calibration and validation process 
	% ---------------------------------------------------------------------------- 

    disp('Show Accuracy')
    calllib(SETTINGS.ViewAPIlibrary, 'iV_GetAccuracy', pAccuracyData, int32(0))
    get(pAccuracyData, 'Value')
end

%% Initialize Psychophysic toolbox
Screen('Preference', 'VisualDebugLevel', 1);
[SETTINGS.window, SETTINGS.screenSize] = Screen(SETTINGS.whichScreen, 'Openwindow', [],[],[],[],[],6);     % put 'window' on complete screen
Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);               % fill whole screen black
Screen(SETTINGS.window,'Flip');

%% Open graphics ("GUIs")
if SETTINGS.GUI
    dyn.GUI_fig_handle=figure('Name','Online GUI','Position',SETTINGS.GUI_coordinates,'Renderer', 'Painters');
    set(gca,'Ylim',[-SETTINGS.screen_lh_deg SETTINGS.screen_uh_deg],'Xlim',[-SETTINGS.screen_w_deg/2 SETTINGS.screen_w_deg/2],'XLimMode','manual','YLimMode','manual');
    if SETTINGS.matlab_version(1)>=2014
        dyn.eye_position_handle = line(-1000,-1000,'Color','r','Marker','o','XlimInclude','off','YLimInclude','off');%'background');
        dyn.hnd_position_handle = line(-1000,-1000,'Color','g','Marker','o','XlimInclude','off','YLimInclude','off');%,'background');
    else
        dyn.eye_position_handle = line(-1000,-1000,'Color','r','Marker','o','XlimInclude','off','YLimInclude','off','EraseMode','xor');%'background');
        dyn.hnd_position_handle = line(-1000,-1000,'Color','g','Marker','o','XlimInclude','off','YLimInclude','off','EraseMode','xor');%,'background');
    end
    hold on; drawnow;
    
    if SETTINGS.ITI_GUI
        figure('Name','ITI GUI','Position',SETTINGS.ITI_GUI_coordinates);
        set(gca,'Xlim',[0 SETTINGS.ITI_GUI_time_limit],'XLimMode','manual');
        drawnow;
        set(0, 'currentfigure', dyn.GUI_fig_handle);
    end
end


%% Prepare for the main loop
dyn.state                   = 1; % INI_TRI
dyn.previousState           = NaN;
dyn.counterLine             = 0;
dyn.trialNumber             = 0;
dyn.trialNumberInitiated    = 0;
dyn.trialNumberFinished     = 0;
dyn.trialNumberCompleted    = 0;

dyn.choice_l                = 0;
dyn.choice_r                = 0;
dyn.choice_l_microstim      = 0;
dyn.choice_r_microstim      = 0;

task.overriding.radius      = 0;
task.overriding.positions   = 0;
task.overriding.vpx_point   = 0;
task.overriding.type        = 0;
task.overriding.effector    = 0;
task.overriding.reach_hand  = 0;
task.overriding.reward      = 0;
task.overriding.improvers   = 0;

%% state machine (NOT defined in get_monkey_dev)

STATE.INI_TRI                       = 1; % initialize trial
STATE.FIX_ACQ                       = 2; % fixation acquisition
STATE.FIX_HOL                       = 3; % fixation hold
STATE.TAR_ACQ                       = 4; % target acquisition
STATE.TAR_HOL                       = 5; % target hold
STATE.CUE_ON                        = 6; % cue on
STATE.MEM_PER                       = 7; % memory period
STATE.DEL_PER                       = 8; % delay period
STATE.TAR_ACQ_INV                   = 9; % target acquisition invisible
STATE.TAR_HOL_INV                   = 10; % target hold invisible
STATE.MAT_ACQ                       = 11; % target acquisition in sample to match
STATE.MAT_HOL                       = 12; % target acquisition in sample to match
STATE.MAT_ACQ_MSK                   = 13; % target acquisition in sample to match
STATE.MAT_HOL_MSK                   = 14; % target acquisition in sample to match
STATE.SEN_RET                       = 15; % return to sensors for poffenberger
STATE.FIX_PER                       = 16; % return to sensors for poffenberger
STATE.MSK_HOL                       = 17; % mask for delayed M2S
STATE.ABORT                         = 19;
STATE.SUCCESS                       = 20;
STATE.REWARD                        = 21;
STATE.ITI                           = 50;
STATE.CLOSE                         = 99;

if length(unique(cell2mat(struct2cell(STATE)))) ~= length(struct2cell(STATE)),
    error('Non-unique states, exiting!!!');
end

%% Synchronize with scanner
if SETTINGS.interface_with_scanner 
    disp('Waiting for a key or trigger to start...');
    
    dyn.trialNumber = 1;
    run(task.custom_conditions);
    dyn.trialNumber = 0;
    
    par_eye = aux_FillPar(task.eye.fix.shape, [task.eye.fix(1).x  task.eye.fix(1).y task.eye.fix(1).size  task.eye.fix(1).radius 0], task.eye.fix.color_bright); % present central fixation before run starts so monkeys are focused
    aux_PrepareStimuli(par_eye(1));
    Screen(SETTINGS.window,'Flip');
    
    switch SETTINGS.interface_with_scanner
        case 1 % UMG
            pause;
            
        case 2 % DPZ
            while true
                bit_state = double(get_sensors_state(SETTINGS.pp,SETTINGS.sensor_pins(5)));
                %bit_state = bitget(uint8(io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_inp)),SETTINGS.n_bit+1);
                if  bit_state,
                    disp('Scanner trigger received...')
                    fprintf('Task will start in %d seconds...',SETTINGS.skip_volumes*SETTINGS.TR)
                    break;
                end
            end
    end    
    
    WaitSecs(SETTINGS.skip_volumes*SETTINGS.TR); % e.g. 8 s omit 4 2-sec volumes (for a 10 min run, ie 20 blocks x 30sec, use 304 2-sec volumes)
    
else
    SETTINGS.skip_volumes	= NaN;
    SETTINGS.TR             = NaN;
    SETTINGS.run_volumes	= NaN;
end

%% MAIN LOOP

SETTINGS.time_start=GetSecs;
while true
    clear par_eye par_hnd
    dyn.states_onset = GetSecs - SETTINGS.time_start;
    switch dyn.state
        
        case STATE.INI_TRI
        %% STATE.INI_TRI
        if SETTINGS.INItrialSound
           Beeper_PsychPortAudio(SETTINGS.audioPort,1600, 0.5, 0.2);
        end
            dyn.memoryBuffer    = SETTINGS.dyn.memoryBuffer; %preallocate memory buffer...
            dyn.trialNumber     = dyn.trialNumber + 1;
            dyn.force_trial_end = false;
            trial(dyn.trialNumber).states       = []; %#ok<*AGROW> % list of states in the trial
            trial(dyn.trialNumber).states_onset = []; % list of state onsets in the trial
            trial(dyn.trialNumber).n            = dyn.trialNumber;
            trial(dyn.trialNumber).timestamp    = datevec(datestr(now)); % y m d h m s
            trial(dyn.trialNumber).force_hand   = 0;
            trial(dyn.trialNumber).completed    = 0;
            trial(dyn.trialNumber).manual_success    = 0;
                        
            fprintf('trial %d ',dyn.trialNumber);
            
            dyn.microstim_start             = NaN;
            dyn.microstim_end               = NaN;
            dyn.target_selected             = [NaN NaN]; % first eye, second hand
            dyn.eye_targets_inspected       = NaN; % for M2S exploration tasks
            dyn.hand_targets_inspected      = NaN; % for M2S exploration tasks
            dyn.n_target_inspected          = 0;    % for M2S exploration tasks
            dyn.time_spent_exploring        = 0; % for M2S exploration tasks
            dyn.cues_presented              = 0;
            dyn.stay_condition              = 0; % for Poffenberger
            dyn.abort_code                  = 'NO ABORT';
            dyn.completed                   = 0;
            
            %% buffer manual inputs
            if any([task.overriding.radius,task.overriding.positions,task.overriding.type,task.overriding.effector,task.overriding.reach_hand,task.overriding.reward,task.overriding.improvers] == 1),
                manual_inputs.eye_fix_rad           =task.eye.fix.radius;
                manual_inputs.eye_tar_rad          =task.eye.tar(1).radius;
                manual_inputs.eye_fix_x             =task.eye.fix.x;
                manual_inputs.eye_fix_y             =task.eye.fix.y;
                manual_inputs.eye_tar1_x            =task.eye.tar(1).x;
                manual_inputs.eye_tar1_y            =task.eye.tar(1).y;
                manual_inputs.type                  =task.type;
                manual_inputs.effector              =task.effector;
                manual_inputs.reach_hand            =task.reach_hand;
                manual_inputs.reward_time_neutral   =task.reward.time_neutral;
                manual_inputs.force_target_location =task.force_target_location;
                manual_inputs.extra_reward          =task.extra_reward;
                manual_inputs.condition             =0;
                manual_inputs.vpx_calibration_point =task.overriding.vpx_point;
            end
            
            %% select fix/tar condition: target locations from position conditions file (overwritten from custom conditions)
            [condition] = aux_SelectCondtion(conditions);
            
            task.condition      =condition(1);
            task.eye.fix.x      =condition(2);
            task.eye.fix.y      =condition(3);
            task.eye.tar(1).x   =condition(4);
            task.eye.tar(1).y   =condition(5);
            task.eye.tar(2).x   =condition(6);
            task.eye.tar(2).y   =condition(7);
            task.hnd.fix.x      =condition(8);
            
            task.hnd.fix.y      =condition(9);
            task.hnd.tar(1).x   =condition(10);
            task.hnd.tar(1).y   =condition(11);
            task.hnd.tar(2).x   =condition(12);
            task.hnd.tar(2).y   =condition(13);
            
            task.eye.cue(1).x   =condition(4);
            task.eye.cue(1).y   =condition(5);
            task.eye.cue(2).x   =condition(6);
            task.eye.cue(2).y   =condition(7);
            task.hnd.cue(1).x   =condition(10);
            task.hnd.cue(1).y   =condition(11);
            task.hnd.cue(2).x   =condition(12);
            task.hnd.cue(2).y   =condition(13);
                                    
            %% RANDOMIZATIONS (overwritten with custom_conditions)
                        
            if task.randomize_effector, % Randomize effector
                if dyn.trialNumber > 1,
                    if trial(dyn.trialNumber-1).success || task.force_effector == 0,
                        task.effector = randsample([0 1 2],1,true,task.randomize_effector_ratio); % Randomize effector
                        trial(dyn.trialNumber).force_effector = 0;
                    else % repeat same effector until successful
                        trial(dyn.trialNumber).force_effector = 1;
                    end
                end
            end
                        
            if task.randomize_reach_hand, % Randomize reach_hand
                if dyn.trialNumber > 1,
                    if trial(dyn.trialNumber-1).success || task.force_hand == 0,
                        task.reach_hand = randsample([1 2 3],1,true,task.randomize_reach_hand_ratio); % Randomize hand used
                        trial(dyn.trialNumber).force_hand = 0;
                    else % repeat same hand/color until successful
                        trial(dyn.trialNumber).force_hand = 1;
                    end
                end
            end % of if randomize reach_hand
            
            
            task.choice = rand < task.fraction_choice; % choice randomization
            task.reward_modulation = rand < task.fraction_reward_modulation; % reward modulation randomization
            
            force_small_reward = 0; % present small instr. reward if monkey failed on previous instr. small reward
            if dyn.trialNumber > 1,
                if ~trial(dyn.trialNumber-1).choice && trial(dyn.trialNumber-1).reward_size==1 && ~trial(dyn.trialNumber-1).success
                    force_small_reward = 1;
                    task.choice = 0;
                    task.reward_modulation = 1;
                end
            end
            trial(dyn.trialNumber).force_small_reward = force_small_reward;
            task.small_reward = rand < task.fraction_reward_small || force_small_reward;
            
            %% MICROSTIM
            task.microstim.stim_on = rand < task.microstim.fraction;
                                    
            %% CUSTOM CONDITION SELECTION
            dyn.trial_classifier        = 250; 
            if ~isempty(task.custom_conditions)
                run(task.custom_conditions);
                fprintf('task %.1f ctc %d ',task.type,custom_trial_condition);
            end
            
            %% sending trialinfo to TDT
            send_trialinfo_to_TDT(IO,dyn,fileNumber);
            
            %% MICROSTIM
            trial(dyn.trialNumber).microstim = task.microstim.stim_on;
            if trial(dyn.trialNumber).microstim,
                
                trial(dyn.trialNumber).microstim_interval = task.microstim.interval;
                
                % select in which state microstim
                microstim_state_idx = randsample(length(task.microstim.state),1);
                trial(dyn.trialNumber).microstim_state =  task.microstim.state(microstim_state_idx);
                
                % select timing
                microstim_timing_idx = randsample(length(task.microstim.start{microstim_state_idx}),1);
                trial(dyn.trialNumber).microstim_start  = task.microstim.start{microstim_state_idx}(microstim_timing_idx);
                trial(dyn.trialNumber).microstim_end    = task.microstim.end{microstim_state_idx}(microstim_timing_idx);
                
                fprintf(' microstim in %d @ %.3f-%.3f s ',trial(dyn.trialNumber).microstim_state,trial(dyn.trialNumber).microstim_start,trial(dyn.trialNumber).microstim_end);
                
            else
                trial(dyn.trialNumber).microstim_interval = NaN;
                trial(dyn.trialNumber).microstim_state = NaN;
                trial(dyn.trialNumber).microstim_start = NaN;
                trial(dyn.trialNumber).microstim_end = NaN;
            end
            
            %% Override with manual inputs
            if task.overriding.radius == 1,
                task.eye.fix.radius             = manual_inputs.eye_fix_rad;
                for t = 1:numel(task.eye.tar)
                    task.eye.tar(t).radius = manual_inputs.eye_tar_rad;
                end
                
            end
            if task.overriding.positions == 1,
                task.eye.fix.x                  = manual_inputs.eye_fix_x;
                task.eye.fix.y                  = manual_inputs.eye_fix_y;
                task.eye.tar(1).x               = manual_inputs.eye_tar1_x;
                task.eye.tar(1).y               = manual_inputs.eye_tar1_y;                
                task.eye.cue(1).x               = manual_inputs.eye_tar1_x;
                task.eye.cue(1).y               = manual_inputs.eye_tar1_y;                
                task.condition                  = manual_inputs.condition ;
            end
            if task.overriding.type==1
                task.type                       = manual_inputs.type;
            end
            if task.overriding.effector==1
                task.effector                   = manual_inputs.effector;
            end
            if task.overriding.reach_hand==1
                task.reach_hand                 = manual_inputs.reach_hand;
            end
            if task.overriding.reward==1
                task.reward.time_neutral        = manual_inputs.reward_time_neutral;
            end
            if task.overriding.improvers==1
                task.force_target_location      = manual_inputs.force_target_location;
                task.extra_reward               = manual_inputs.extra_reward;
            end            
            if ~task.overriding.vpx_point==0,
                trial(dyn.trialNumber).vpx_calibration_point=manual_inputs.vpx_calibration_point ;
            end
            
            %% Assign task parameters to trial
            trial(dyn.trialNumber).type                 = task.type;
            trial(dyn.trialNumber).effector             = task.effector;         % (0/1/2) % eye / hand / both
            trial(dyn.trialNumber).rest_hand            = task.rest_hand;
            trial(dyn.trialNumber).reach_hand           = task.reach_hand;
            trial(dyn.trialNumber).hand_choice          = (task.reach_hand==3);
            trial(dyn.trialNumber).choice               = task.choice;
            trial(dyn.trialNumber).reward_modulation    = task.reward_modulation;
            trial(dyn.trialNumber).small_reward         = task.small_reward;
            
            trial(dyn.trialNumber).condition      = task.condition;
            trial(dyn.trialNumber).eye.fix.pos    = [task.eye.fix.x task.eye.fix.y task.eye.fix.size  task.eye.fix.radius 0];
            trial(dyn.trialNumber).hnd.fix.pos    = [task.hnd.fix.x task.hnd.fix.y task.hnd.fix.size  task.hnd.fix.radius 1];
            trial(dyn.trialNumber).eye.fix.shape  = task.eye.fix.shape;
            trial(dyn.trialNumber).hnd.fix.shape  = task.hnd.fix.shape;
            
            %% Assign reward values to targets in this trial
            if task.reward_modulation
                if task.small_reward,
                    
                    trial(dyn.trialNumber).reward_size              = 1; % tar1 is "small"
                    
                    trial(dyn.trialNumber).hnd.tar(1).ringColor     = task.reward.small_color;
                    trial(dyn.trialNumber).hnd.tar(1).ringColor2    = [];
                    trial(dyn.trialNumber).hnd.tar(2).ringColor     = task.reward.large_color;
                    trial(dyn.trialNumber).hnd.tar(2).ringColor2    = task.reward.large_color2;
                    
                    trial(dyn.trialNumber).hnd.tar(1).reward        = 1;
                    trial(dyn.trialNumber).hnd.tar(2).reward        = 3;
                    
                    trial(dyn.trialNumber).hnd.tar(1).reward_time   = task.reward.time_small;
                    trial(dyn.trialNumber).hnd.tar(1).reward_prob   = task.reward.prob_small;
                    trial(dyn.trialNumber).hnd.tar(2).reward_time   = task.reward.time_large;
                    trial(dyn.trialNumber).hnd.tar(2).reward_prob   = task.reward.prob_large;
                    
                    trial(dyn.trialNumber).eye.tar(1).ringColor     = task.reward.small_color;
                    trial(dyn.trialNumber).eye.tar(1).ringColor2    = [];
                    trial(dyn.trialNumber).eye.tar(2).ringColor     = task.reward.large_color;
                    trial(dyn.trialNumber).eye.tar(2).ringColor2    = task.reward.large_color2;
                    
                    trial(dyn.trialNumber).eye.tar(1).reward        = 1;
                    trial(dyn.trialNumber).eye.tar(2).reward        = 3;
                    
                    trial(dyn.trialNumber).eye.tar(1).reward_time   = task.reward.time_small;
                    trial(dyn.trialNumber).eye.tar(1).reward_prob   = task.reward.prob_small;
                    trial(dyn.trialNumber).eye.tar(2).reward_time   = task.reward.time_large;
                    trial(dyn.trialNumber).eye.tar(2).reward_prob   = task.reward.prob_large;
                    
                    
                else
                    trial(dyn.trialNumber).reward_size              = 3; % tar1 is "large"
                    trial(dyn.trialNumber).hnd.tar(1).ringColor     = task.reward.large_color;
                    trial(dyn.trialNumber).hnd.tar(1).ringColor2    = task.reward.large_color2;
                    trial(dyn.trialNumber).hnd.tar(2).ringColor     = task.reward.small_color;
                    trial(dyn.trialNumber).hnd.tar(2).ringColor2    = [];
                    
                    trial(dyn.trialNumber).hnd.tar(1).reward        = 3;
                    trial(dyn.trialNumber).hnd.tar(2).reward        = 1;
                    
                    trial(dyn.trialNumber).hnd.tar(1).reward_time   = task.reward.time_large;
                    trial(dyn.trialNumber).hnd.tar(1).reward_prob   = task.reward.prob_large;
                    
                    trial(dyn.trialNumber).hnd.tar(2).reward_time   = task.reward.time_small;
                    trial(dyn.trialNumber).hnd.tar(2).reward_prob   = task.reward.prob_small;
                    
                    trial(dyn.trialNumber).eye.tar(1).ringColor     = task.reward.large_color;
                    trial(dyn.trialNumber).eye.tar(1).ringColor2    = task.reward.large_color2;
                    trial(dyn.trialNumber).eye.tar(2).ringColor     = task.reward.small_color;
                    trial(dyn.trialNumber).eye.tar(2).ringColor2    = [];
                    
                    trial(dyn.trialNumber).eye.tar(1).reward        = 3;
                    trial(dyn.trialNumber).eye.tar(2).reward        = 1;
                    
                    trial(dyn.trialNumber).eye.tar(1).reward_time   = task.reward.time_large;
                    trial(dyn.trialNumber).eye.tar(1).reward_prob   = task.reward.prob_large;
                    
                    trial(dyn.trialNumber).eye.tar(2).reward_time   = task.reward.time_small;
                    trial(dyn.trialNumber).eye.tar(2).reward_prob   = task.reward.prob_small;
                    
                end
            
            trial(dyn.trialNumber).hnd.cue(1).ringColor  = trial(dyn.trialNumber).hnd.tar(1).ringColor;
            trial(dyn.trialNumber).hnd.cue(2).ringColor  = trial(dyn.trialNumber).hnd.tar(2).ringColor;
            trial(dyn.trialNumber).hnd.cue(1).ringColor2 = trial(dyn.trialNumber).hnd.tar(1).ringColor2;
            trial(dyn.trialNumber).hnd.cue(2).ringColor2 = trial(dyn.trialNumber).hnd.tar(2).ringColor2;
            
            trial(dyn.trialNumber).eye.cue(1).ringColor  = trial(dyn.trialNumber).eye.tar(1).ringColor;
            trial(dyn.trialNumber).eye.cue(2).ringColor  = trial(dyn.trialNumber).eye.tar(2).ringColor;
            trial(dyn.trialNumber).eye.cue(1).ringColor2 = trial(dyn.trialNumber).eye.tar(1).ringColor2;
            trial(dyn.trialNumber).eye.cue(2).ringColor2 = trial(dyn.trialNumber).eye.tar(2).ringColor2;
                
            end 
            
            if ~task.reward_modulation % no reward modulation
                trial(dyn.trialNumber).reward_size = 2;
                for t = 1:numel(task.eye.tar) % assign values for each target
                    trial(dyn.trialNumber).eye.tar(t).ringColor         = [];
                    trial(dyn.trialNumber).eye.tar(t).ringColor2        = [];
                    trial(dyn.trialNumber).eye.cue(t).ringColor         = [];
                    trial(dyn.trialNumber).eye.cue(t).ringColor2        = [];
                    trial(dyn.trialNumber).eye.tar(t).reward            = 2;
                    trial(dyn.trialNumber).eye.tar(t).reward_time       = task.reward.time_neutral;
                    trial(dyn.trialNumber).eye.tar(t).reward_prob       = task.reward.prob_neutral;
                end
                
                for t = 1:numel(task.hnd.tar)
                    trial(dyn.trialNumber).hnd.tar(t).ringColor         = [];
                    trial(dyn.trialNumber).hnd.tar(t).ringColor2        = [];
                    trial(dyn.trialNumber).hnd.cue(t).ringColor         = [];
                    trial(dyn.trialNumber).hnd.cue(t).ringColor2        = [];
                    trial(dyn.trialNumber).hnd.tar(t).reward            = 2;
                    trial(dyn.trialNumber).hnd.tar(t).reward_time       = task.reward.time_neutral;
                    trial(dyn.trialNumber).hnd.tar(t).reward_prob       = task.reward.prob_neutral;
                end                
            end
                        
            if task.force_target_location, % force the location of the movement target
                if dyn.trialNumber > 1,
                    if ~trial(dyn.trialNumber-1).success                        
                        trial(dyn.trialNumber).eye = trial(dyn.trialNumber-1).eye;
                        trial(dyn.trialNumber).hnd = trial(dyn.trialNumber-1).hnd;
                    end
                end
            end
              
            if isfield(task,'rings_only_on_cues') && task.rings_only_on_cues==1 % for cuing reward only on the cues, especially for M2S task
                [trial(dyn.trialNumber).hnd.tar.ringColor]         = deal([]);
                [trial(dyn.trialNumber).hnd.tar.ringColor2]        = deal([]);
                [trial(dyn.trialNumber).eye.tar.ringColor]         = deal([]);
                [trial(dyn.trialNumber).eye.tar.ringColor2]        = deal([]);
            end
            
            if task.extra_reward % increase reward time if previous trial was successful (for hnd only?)
                if dyn.trialNumber > 1,
                    if trial(dyn.trialNumber-1).success
                        trial(dyn.trialNumber).hnd.tar(1).reward_time   = task.reward.time_neutral+(task.reward.time_neutral*0.5);
                        trial(dyn.trialNumber).extra_reward = 1;
                        if dyn.trialNumber > 2,
                            if trial(dyn.trialNumber-1).success && trial(dyn.trialNumber-2).success
                                trial(dyn.trialNumber).hnd.tar(1).reward_time   = task.reward.time_neutral+(task.reward.time_neutral*1);
                                trial(dyn.trialNumber).extra_reward = 2;
                            end
                        end
                    end
                end
            end
            
            %% Assign hand target colors according to demanded hand
            switch task.reach_hand
                case 0 % stay condition
                    task.hnd.fix.color_dim      = task.hnd_stay.color_dim_fix;
                    task.hnd.fix.color_bright   = task.hnd_stay.color_bright_fix;
                    [task.hnd.tar.color_dim]    = deal(task.hnd_stay.color_dim);
                    [task.hnd.tar.color_bright] = deal(task.hnd_stay.color_bright);
                    
                case 1 % left
                    task.hnd.fix.color_dim      = task.hnd_left.color_dim_fix;
                    task.hnd.fix.color_bright   = task.hnd_left.color_bright_fix;
                    [task.hnd.tar.color_dim]    = deal(task.hnd_left.color_dim);
                    [task.hnd.tar.color_bright] = deal(task.hnd_left.color_bright);
                    
                case 2 % right
                    task.hnd.fix.color_dim      = task.hnd_right.color_dim_fix;
                    task.hnd.fix.color_bright   = task.hnd_right.color_bright_fix;
                    [task.hnd.tar.color_dim]    = deal(task.hnd_right.color_dim);
                    [task.hnd.tar.color_bright] = deal(task.hnd_right.color_bright);
                    
                case 3 % either hand, both colors                    
                    task.hnd.fix.color_dim      = [task.hnd_right.color_dim_fix;task.hnd_left.color_dim_fix];
                    task.hnd.fix.color_bright   = [task.hnd_right.color_bright_fix;task.hnd_left.color_bright_fix];
                    [task.hnd.tar.color_dim]    = deal([task.hnd_right.color_dim;task.hnd_left.color_dim]);
                    [task.hnd.tar.color_bright] = deal([task.hnd_right.color_bright;task.hnd_left.color_bright]);
                    
            end
            if isfield(task.hnd_right,'color_cue') && isfield(task.hnd_left,'color_cue')
                switch task.reach_hand
                    case 0 % stay condition
                        [task.hnd.cue.color_dim]    = deal(task.hnd_stay.color_dim);
                        [task.hnd.cue.color_bright] = deal(task.hnd_stay.color_bright);
                        
                    case 1 % left
                        [task.hnd.cue.color_dim]    = deal(task.hnd_left.color_cue);
                        [task.hnd.cue.color_bright] = deal(task.hnd_left.color_cue);
                        
                    case 2 % right
                        [task.hnd.cue.color_dim]    = deal(task.hnd_right.color_cue);
                        [task.hnd.cue.color_bright] = deal(task.hnd_right.color_cue);
                        
                    case 3 % either hand, both colors
                        [task.hnd.cue.color_dim]    = deal([task.hnd_right.color_cue;task.hnd_left.color_cue]);
                        [task.hnd.cue.color_bright] = deal([task.hnd_right.color_cue;task.hnd_left.color_cue]);
                        
                end
            end
                        
            %% Number of targets and cues assignment (especially for CHOICE AND EFFECTORS!)
            dyn.n_eye_tar=numel(task.eye.tar);
            dyn.n_eye_cue=numel(task.eye.cue);
            dyn.n_eye_fix=numel(task.eye.fix);
            dyn.n_hnd_tar=numel(task.hnd.tar);
            dyn.n_hnd_cue=numel(task.hnd.cue);
            dyn.n_hnd_fix=numel(task.hnd.fix);
            if task.type<5 || task.type>=9
                if ~task.choice
                    dyn.n_eye_tar=1;
                    dyn.n_hnd_tar=1;
                end
            end
            
            if ~task.choice
                dyn.n_eye_cue=1;
                dyn.n_hnd_cue=1;
            end
            
            switch task.effector
                case 0 % eye
                    dyn.n_hnd_tar=0;
                    dyn.n_hnd_cue=0;
                    dyn.n_hnd_fix=0;
                    
                    dyn.tar_selected_ind = 1;
                    dyn.effector = 'eye';
                    
                case 1 % free gaze reach
                    dyn.n_eye_tar=0;
                    dyn.n_eye_cue=0;
                    dyn.n_eye_fix=0;
                    
                    dyn.tar_selected_ind = 2;
                    dyn.effector = 'hnd';
                    
                case 2 % joint movement eye and hand
                    
                    dyn.tar_selected_ind = 1;
                    dyn.effector = 'eye';
                case 3 % dissociated saccade
                    dyn.n_hnd_tar=1; % fixation spot counts as target
                    dyn.n_hnd_cue=0;
                    
                    dyn.tar_selected_ind = 1;
                    dyn.effector = 'eye';
                    
                case 4 % dissociated reach
                    dyn.n_eye_tar=1; % fixation spot counts as target
                    dyn.n_eye_cue=0;
                    
                    dyn.tar_selected_ind = 2;
                    dyn.effector = 'hnd';
                    
                case 6 % free gaze reach with initial eye fixation
                    dyn.n_eye_tar=0; % not even fixation spot in target acquisition
                    dyn.n_eye_cue=0;
                    
                    dyn.tar_selected_ind = 2;  
                    dyn.effector = 'hnd';
            end
            
            %% each stimulus on the screen is defined as below: [x y size radius effector]
            for n_obj=1:dyn.n_eye_tar % n_obj=1:max(dyn.n_eye_tar,2) % just to keep the same format as in previous versions, at least two targets are always defined
                trial(dyn.trialNumber).eye.tar(n_obj).pos   = [task.eye.tar(n_obj).x task.eye.tar(n_obj).y task.eye.tar(n_obj).size  task.eye.tar(n_obj).radius 0];
                trial(dyn.trialNumber).eye.tar(n_obj).shape = task.eye.tar(n_obj).shape;
                if task.effector==4
                    trial(dyn.trialNumber).eye.tar(n_obj).color_dim = task.eye.fix(1).color_bright;
                end
            end
            for n_obj=1:dyn.n_hnd_tar % n_obj=1:max(dyn.n_hnd_tar,2) %
                trial(dyn.trialNumber).hnd.tar(n_obj).pos   = [task.hnd.tar(n_obj).x task.hnd.tar(n_obj).y task.hnd.tar(n_obj).size  task.hnd.tar(n_obj).radius 1];
                trial(dyn.trialNumber).hnd.tar(n_obj).shape = task.hnd.tar(n_obj).shape;
                if task.effector==3
                    trial(dyn.trialNumber).hnd.tar(n_obj).color_dim = task.hnd.fix(1).color_bright;
                end
            end
            for n_obj=1:dyn.n_eye_cue % n_obj=1:max(dyn.n_eye_cue,2) %
                trial(dyn.trialNumber).eye.cue(n_obj).pos   = [task.eye.cue(n_obj).x task.eye.cue(n_obj).y task.eye.tar(n_obj).size  task.eye.tar(n_obj).radius 0];
                trial(dyn.trialNumber).eye.cue(n_obj).shape = task.eye.cue(n_obj).shape;
            end
            for n_obj=1:dyn.n_hnd_cue % n_obj=1:max(dyn.n_hnd_cue,2) %
                trial(dyn.trialNumber).hnd.cue(n_obj).pos   = [task.hnd.cue(n_obj).x task.hnd.cue(n_obj).y task.hnd.tar(n_obj).size  task.hnd.tar(n_obj).radius 1];
                trial(dyn.trialNumber).hnd.cue(n_obj).shape = task.hnd.cue(n_obj).shape;
            end
            
            trial(dyn.trialNumber).task                 = task;
                        
            %% CHECK CONDITIONS TO START THE TRIAL
            
            % Check that the monkey is not moving
            if SETTINGS.check_motion_jaw || SETTINGS.check_motion_body
                while any(aux_GetMonkeyMotion),
                    disp('waiting for motion to end');
                    WaitSecs(0.01);
                    if KbCheck                                  % check keyboard
                        [~,~,keyCode,~] = KbCheck;
                        if any(find(keyCode)==27) % Esc
                            success = false;
                            dyn.previousState = dyn.state;
                            dyn.state         = STATE.CLOSE;
                            break;
                        end
                    end
                end
            end
            
            
            % Check that the monkey is not touching the srceen, wait until he does not
            if task.check_screen_touching 
                while 1
                    [x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task); % in deg
                    if touching,
                        disp('touched touchscreen in initialize! - aborting');
                        if SETTINGS.useSound && SETTINGS.TouchscreenSound
                            Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2); Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2);
                            WaitSecs(0.01);
                        else
                        end
                    else
                        break;
                    end
                end
            end
            
            % check if monkey is touching the sensors, wait until he does
            if any(task.rest_hand) 
                sensors_ini_correct_time=-Inf;
                wait4sensors_iteration = 0;
                dyn.duration=0.001;
                while 1 % wait until sensors are correctly touched
                    %[x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task); % in deg
                    
                    [success,dyn,task,sen1,sen2]=wait_while_recording_state(task,dyn);
                    holding_individual_sensors_correctly = [~((task.rest_hand-[sen1 sen2])>0)]; % see aux_CheckSensors
                    
                    if ~all(holding_individual_sensors_correctly),
                        sensors_ini_correct_time=-Inf;
                    end
                    
                    switch mat2str(double(holding_individual_sensors_correctly))
                        case '[0 1]'
                            dyn.duration=0.01;
                            if ~wait4sensors_iteration,
                                fprintf('does not hold the rest sensor 1 - waiting!');
                            end
                            wait4sensors_iteration = wait4sensors_iteration + 1;
                        case '[1 0]'
                            dyn.duration=0.01;
                            if ~wait4sensors_iteration,
                                fprintf('does not hold the rest sensor 2 - waiting!');
                            end
                            wait4sensors_iteration = wait4sensors_iteration + 1;
                        case '[0 0]'
                            dyn.duration=0.01;
                            if ~wait4sensors_iteration,
                                fprintf('does not hold the rest both sensors - waiting!');
                            end
                            wait4sensors_iteration = wait4sensors_iteration + 1;
                            
                        case '[1 1]' % both sensors correct, proceed
                            dyn.duration=0.001;
                            if sensors_ini_correct_time==-Inf
                                sensors_ini_correct_time = GetSecs;
                                wait4sensors_iteration = 0;
                            end
                            if GetSecs >= sensors_ini_correct_time+task.rest_sensors_ini_time || dyn.state==STATE.CLOSE;
                                break;
                            end
                    end
                    if mod(wait4sensors_iteration,2*(1/dyn.duration)) == 2*(1/dyn.duration)-1
                        Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
                        Screen(SETTINGS.window,'Flip');
                    end
                end % of while % wait until sensors are correctly touched
                
            end % of any(task.rest_hand)
            
            success         = true;
            
            
            %% Draw GUI
            dyn.correct_choice_target = trial(dyn.trialNumber).task.correct_choice_target;
            dyn.hnd_color=nanmean([task.hnd.fix.color_bright],1);
            if SETTINGS.GUI
                set(0, 'currentfigure', dyn.GUI_fig_handle);
                ang=0:0.02:2*pi;
                %aux_draw_GUI_targets(dyn,trial,eff,pha,ang)
                aux_draw_GUI_targets(dyn,trial,'eye','fix',ang)
                aux_draw_GUI_targets(dyn,trial,'eye','tar',ang)
                aux_draw_GUI_targets(dyn,trial,'eye','cue',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','fix',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','tar',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','cue',ang)
                if any(~isnan(task.hnd.fix.color_bright))
                    set(dyn.hnd_position_handle,'Color',nanmean([task.hnd.fix.color_bright],1)/255);
                end
            end
            
            if SETTINGS.useSound && SETTINGS.FixationAcquisitionSound
                Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2); Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2);
                WaitSecs(0.01); %WHY??
            end
            
        case STATE.FIX_ACQ  % fixation acquisition
            if dyn.n_eye_fix==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix==0;par_hnd = struct([]);end;
            
            for n_obj=1:dyn.n_eye_fix
                par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.fix(n_obj).shape, trial(dyn.trialNumber).eye.fix(n_obj).pos, task.eye.fix(n_obj).color_dim);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.fix(n_obj).shape, trial(dyn.trialNumber).hnd.fix(n_obj).pos, task.hnd.fix(n_obj).color_dim);
            end
            
            temp_effector = task.effector;
            if ismember(trial(dyn.trialNumber).effector,[2,3,4,6])
                task.effector = 2;
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            
            task.effector = temp_effector;
            trial(dyn.trialNumber).reach_hand = dyn.hand_selected;
            if trial(dyn.trialNumber).effector==5
                trial(dyn.trialNumber).reach_hand = task.reach_hand;
            end
            if success;
                dyn.trialNumberInitiated = dyn.trialNumberInitiated + 1;
            end
            
        case STATE.FIX_HOL %  fixation holding_with_change_of_color
            if dyn.n_eye_fix==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix==0;par_hnd = struct([]);end;
            for n_obj=1:dyn.n_eye_fix
                par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.fix(n_obj).shape, trial(dyn.trialNumber).eye.fix(n_obj).pos, task.eye.fix(n_obj).color_bright);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.fix(n_obj).shape, trial(dyn.trialNumber).hnd.fix(n_obj).pos, task.hnd.fix(n_obj).color_bright);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            if task.type > 1,
                dyn.target_selected = [NaN NaN];
            end
            
        case STATE.FIX_PER %  fixation holding after cue state, and return to cue state!!
            switch trial(dyn.trialNumber).effector
                case {0,5}
                    par_eye(1) = aux_FillPar(trial(dyn.trialNumber).eye.fix.shape, trial(dyn.trialNumber).eye.fix.pos, task.eye.fix.color_bright);
                    par_hnd = struct([]);
                case 1
                    par_hnd(1) = aux_FillPar(trial(dyn.trialNumber).hnd.fix.shape, trial(dyn.trialNumber).hnd.fix.pos, task.hnd.fix.color_bright);
                    par_eye = struct([]);
                case {2,3,4,6}
                    par_eye(1) = aux_FillPar(trial(dyn.trialNumber).eye.fix.shape, trial(dyn.trialNumber).eye.fix.pos, task.eye.fix.color_bright);
                    par_hnd(1) = aux_FillPar(trial(dyn.trialNumber).hnd.fix.shape, trial(dyn.trialNumber).hnd.fix.pos, task.hnd.fix.color_bright);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
            if success==1;
                success=-1;
                trial(dyn.trialNumber).hnd.cue=circshift(trial(dyn.trialNumber).hnd.cue,[0,-1]);
                trial(dyn.trialNumber).eye.cue=circshift(trial(dyn.trialNumber).eye.cue,[0,-1]);
                dyn.cues_presented=dyn.cues_presented+1;
                if dyn.cues_presented==numel(trial(dyn.trialNumber).eye.cue)
                    success=1;
                end
            end
            
            if task.type > 1,
                dyn.target_selected = [NaN NaN];
            end
            
        case STATE.TAR_ACQ  % target acquisition
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            
            if all(isnan(dyn.target_selected)) % still no target has been selected (e.g. in task.type = 2)
                for n_obj=1:dyn.n_eye_tar
                    par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.tar(n_obj).shape, trial(dyn.trialNumber).eye.tar(n_obj).pos, task.eye.tar(n_obj).color_dim, ...
                        trial(dyn.trialNumber).eye.tar(n_obj).ringColor, trial(dyn.trialNumber).eye.tar(n_obj).reward_prob,trial(dyn.trialNumber).eye.tar(n_obj).ringColor2);
                end
                for n_obj=1:dyn.n_hnd_tar
                    par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_obj).shape, trial(dyn.trialNumber).hnd.tar(n_obj).pos, task.hnd.tar(n_obj).color_dim, ...
                        trial(dyn.trialNumber).hnd.tar(n_obj).ringColor, trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob,trial(dyn.trialNumber).hnd.tar(n_obj).ringColor2);
                end
            else
                if ~isnan(dyn.target_selected(1))
                    par_eye = aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_dim, ...
                        trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).reward_prob,trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor2);
                else
                    par_eye = struct([]);
                end
                if ~isnan(dyn.target_selected(2))
                    par_hnd = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_dim,...
                        trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).reward_prob,trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor2);
                else
                    par_hnd = struct([]);
                end
            end
            
            %overwriting target color for fixation in dissociated tasks
            switch trial(dyn.trialNumber).effector
                case 3 % bright hnd fixation spot for dissociated memory saccades
                    clear par_hnd
                    for n_obj=1:dyn.n_hnd_tar
                        par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_obj).shape, trial(dyn.trialNumber).hnd.tar(n_obj).pos, task.hnd.fix(1).color_bright, ...
                            trial(dyn.trialNumber).hnd.tar(n_obj).ringColor, trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob,trial(dyn.trialNumber).hnd.tar(n_obj).ringColor2);
                    end
                case 4 % bright eye fixation spot for dissociated memory reaches
                    clear par_eye
                    for n_obj=1:dyn.n_eye_tar
                        par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.tar(n_obj).shape, trial(dyn.trialNumber).eye.tar(n_obj).pos, task.eye.fix(1).color_bright, ...
                            trial(dyn.trialNumber).eye.tar(n_obj).ringColor, trial(dyn.trialNumber).eye.tar(n_obj).reward_prob,trial(dyn.trialNumber).eye.tar(n_obj).ringColor2);
                    end
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.stay_condition      = 0;
            
            if trial(dyn.trialNumber).reach_hand==0
                dyn.stay_condition = 1;
            end
            if trial(dyn.trialNumber).effector==5
                trial(dyn.trialNumber).reach_hand = dyn.hand_selected;
            end
            
        case STATE.SEN_RET
            % check target selected -> defined by sensors....
            par_eye = aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_bright, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).reward_prob,...
                trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor2);
            par_hnd = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_dim, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).reward_prob,...
                trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor2);
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.TAR_HOL %  target holding_with_change_of_color
            if ~isnan(dyn.target_selected(1))
                par_eye = aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_bright, ...
                    trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).reward_prob,trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor2);
            elseif dyn.n_eye_tar>0
                for n_obj=1:dyn.n_eye_tar
                    par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.tar(n_obj).shape, trial(dyn.trialNumber).eye.tar(n_obj).pos, task.eye.fix(1).color_bright, ...
                        trial(dyn.trialNumber).eye.tar(n_obj).ringColor, trial(dyn.trialNumber).eye.tar(n_obj).reward_prob,trial(dyn.trialNumber).eye.tar(n_obj).ringColor2);
                end
            else
                par_eye = struct([]);
            end
            
            if ~isnan(dyn.target_selected(2))
                par_hnd = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_bright,...
                    trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).reward_prob,trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor2);
            elseif dyn.n_hnd_tar>0
                for n_obj=1:dyn.n_hnd_tar
                    par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_obj).shape, trial(dyn.trialNumber).hnd.tar(n_obj).pos, task.hnd.fix(1).color_bright, ...
                        trial(dyn.trialNumber).hnd.tar(n_obj).ringColor, trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob,trial(dyn.trialNumber).hnd.tar(n_obj).ringColor2);
                end
            else
                par_hnd = struct([]);
            end
            
            %             % DO NOT DELETE THE COMMENTED CODE BELOW:
            %             % if we want to leave non-selected target on the screen (as in effort study of Dominiguez Vargas et al. 2012, ...),
            %             %             comment out "clear par_eye par_hnd % show and brighten selected only" above and uncomment the code below
            %             %             switch trial(dyn.trialNumber).effector
            %             %                 case 0
            %             %                     par_eye(dyn.target_selected(1)) = aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_bright,...
            %             %                         trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).reward_prob,...
            %             %                         trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor2);
            %             %
            %             %                 case 1
            %             %                     par_hnd(dyn.target_selected(2)) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_bright,...
            %             %                         trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).reward_prob,...
            %             %                         trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor2);
            %             %
            %             %                 case {2,3,4}
            %             %                     par_eye(dyn.target_selected(1)) = aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_bright,...
            %             %                         trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).reward_prob,...
            %             %                         trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).ringColor2);
            %             %                     par_hnd(dyn.target_selected(2)) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_bright,...
            %             %                         trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).reward_prob,...
            %             %                         trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).ringColor2);
            %             %             end
            %             % END OF DO NOT DELETE THE COMMENTED CODE BELOW
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
%             dyn.tar.HT = [dyn.HTeye dyn.HThnd];
            
        case STATE.MAT_ACQ_MSK  % masked target acquisition in match-to-sample
            current_shape.mode='circle';
            
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            
            for n_target=1:dyn.n_eye_tar
                par_eye(n_target) = aux_FillPar(current_shape, [trial(dyn.trialNumber).eye.tar(n_target).pos(1:2) task.eye.fix.size trial(dyn.trialNumber).eye.tar(n_target).pos(4:5)],...
                    task.eye.tar(n_target).color_dim,[],1,[0 0 0]);
            end
            for n_target=1:dyn.n_hnd_tar
                par_hnd(n_target) = aux_FillPar(current_shape, [trial(dyn.trialNumber).hnd.tar(n_target).pos(1:2) task.hnd.fix.size trial(dyn.trialNumber).hnd.tar(n_target).pos(4:5)],...
                    task.hnd.tar(n_target).color_dim,[],1,[0 0 0]);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.time_spent_exploring = dyn.time_spent_exploring+dyn.time_spent_in_state;
            
        case STATE.MAT_ACQ  % target acquisition in match-to-sample
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            for n_target=1:dyn.n_eye_tar
                par_eye(n_target) = aux_FillPar(trial(dyn.trialNumber).eye.tar(n_target).shape, trial(dyn.trialNumber).eye.tar(n_target).pos, task.eye.tar(n_target).color_dim,[],1,[0 0 0]);
            end
            for n_target=1:dyn.n_hnd_tar
                par_hnd(n_target) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_target).shape, trial(dyn.trialNumber).hnd.tar(n_target).pos, task.hnd.tar(n_target).color_dim,[],1,[0 0 0]);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.time_spent_exploring = dyn.time_spent_exploring+dyn.time_spent_in_state;
            
        case STATE.MAT_HOL  % target hold in match-to-sample
            if ~isnan(dyn.target_selected(1))
                for n_target=1:dyn.n_eye_tar
                    par_eye(n_target) = aux_FillPar(trial(dyn.trialNumber).eye.tar(n_target).shape, trial(dyn.trialNumber).eye.tar(n_target).pos, task.eye.tar(n_target).color_dim,[],1,[0 0 0]);
                end
                par_eye(dyn.target_selected(1))=aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_bright,[],1,[0 0 0]);
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                for n_target=1:dyn.n_hnd_tar
                    par_hnd(n_target) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_target).shape, trial(dyn.trialNumber).hnd.tar(n_target).pos, task.hnd.tar(n_target).color_dim,[],1,[0 0 0]);
                end
                par_hnd(dyn.target_selected(2)) =aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_bright,[],1,[0 0 0]);
            else
                par_hnd = struct([]);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            dyn.time_spent_exploring = dyn.time_spent_exploring+dyn.time_spent_in_state;
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
            dyn.n_target_inspected=dyn.n_target_inspected+1;
            dyn.eye_targets_inspected(dyn.n_target_inspected)  = dyn.target_selected(1);
            dyn.hand_targets_inspected(dyn.n_target_inspected) = dyn.target_selected(2);
            if success==0
                dyn.target_selected(1)=NaN;
                dyn.target_selected(2)=NaN;
                success=-1; % Going back one state
            end
            
        case STATE.MAT_HOL_MSK  % target hold in match-to-sample
            current_shape.mode='circle';
            
            if ~isnan(dyn.target_selected(1))
                for n_target=1:dyn.n_eye_tar
                    par_eye(n_target) = aux_FillPar(current_shape, [trial(dyn.trialNumber).eye.tar(n_target).pos(1:2) task.eye.fix.size trial(dyn.trialNumber).eye.tar(n_target).pos(4:5)],...
                        task.eye.tar(n_target).color_dim,[],1,[0 0 0]);
                end
                par_eye(dyn.target_selected(1))=aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, task.eye.tar(dyn.target_selected(1)).color_bright,[],1,[0 0 0]);
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                for n_target=1:dyn.n_hnd_tar
                    par_hnd(n_target) = aux_FillPar(current_shape, [trial(dyn.trialNumber).hnd.tar(n_target).pos(1:2), task.hnd.fix.size, trial(dyn.trialNumber).hnd.tar(n_target).pos(4:5)], task.hnd.tar(n_target).color_dim,[],1,[0 0 0]);
                end
                par_hnd(dyn.target_selected(2)) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, task.hnd.tar(dyn.target_selected(2)).color_bright,[],1,[0 0 0]);
            else
                par_hnd = struct([]);
            end
            
            dyn.duration             = get_state_duration(task,trial,dyn);
            dyn.time_spent_exploring = dyn.time_spent_exploring+dyn.time_spent_in_state;
            [success,dyn,task]       = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
            dyn.n_target_inspected=dyn.n_target_inspected+1;
            dyn.eye_targets_inspected(dyn.n_target_inspected)  = dyn.target_selected(1);
            dyn.hand_targets_inspected(dyn.n_target_inspected) = dyn.target_selected(2);
            if success==0
                dyn.target_selected(1)=NaN;
                dyn.target_selected(2)=NaN;
                success=-1;
            end
            
        case {STATE.CUE_ON , STATE.DEL_PER} 
            if dyn.n_eye_fix+dyn.n_eye_cue==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix+dyn.n_hnd_cue==0;par_hnd = struct([]);end;
            
            for n_obj=1:dyn.n_eye_fix
                par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.fix(n_obj).shape, trial(dyn.trialNumber).eye.fix(n_obj).pos, task.eye.fix(n_obj).color_bright);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.fix(n_obj).shape, trial(dyn.trialNumber).hnd.fix(n_obj).pos, task.hnd.fix(n_obj).color_bright);
            end
            for n_obj=1:dyn.n_eye_cue
                par_eye(n_obj+dyn.n_eye_fix) =aux_FillPar(trial(dyn.trialNumber).eye.cue(n_obj).shape, trial(dyn.trialNumber).eye.cue(n_obj).pos, task.eye.cue(n_obj).color_dim,...
                    trial(dyn.trialNumber).eye.cue(n_obj).ringColor, trial(dyn.trialNumber).eye.tar(n_obj).reward_prob,trial(dyn.trialNumber).eye.cue(n_obj).ringColor2);
            end
            for n_obj=1:dyn.n_hnd_cue
                par_hnd(n_obj+dyn.n_hnd_fix) =aux_FillPar(trial(dyn.trialNumber).hnd.cue(n_obj).shape, trial(dyn.trialNumber).hnd.cue(n_obj).pos, task.hnd.cue(n_obj).color_dim,...
                    trial(dyn.trialNumber).hnd.cue(n_obj).ringColor, trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob,trial(dyn.trialNumber).hnd.cue(n_obj).ringColor2);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.MSK_HOL %KK: Match-to-sample task
            if dyn.n_eye_fix+dyn.n_eye_cue==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix+dyn.n_hnd_cue==0;par_hnd = struct([]);end;
            
            for n_obj=1:dyn.n_eye_fix
                par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.fix(n_obj).shape, trial(dyn.trialNumber).eye.fix(n_obj).pos, task.eye.fix(n_obj).color_bright);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.fix(n_obj).shape, trial(dyn.trialNumber).hnd.fix(n_obj).pos, task.hnd.fix(n_obj).color_bright);
            end
            
            for n_obj=1:dyn.n_eye_cue
                temp_shape=trial(dyn.trialNumber).eye.cue(n_obj).shape;
                temp_shape.mode='bar_masked';
                par_eye(n_obj+dyn.n_eye_fix) =aux_FillPar(temp_shape, trial(dyn.trialNumber).eye.cue(n_obj).pos, task.eye.cue(n_obj).color_dim,...
                    trial(dyn.trialNumber).eye.cue(n_obj).ringColor, trial(dyn.trialNumber).eye.tar(n_obj).reward_prob,trial(dyn.trialNumber).eye.cue(n_obj).ringColor2);
            end
            for n_obj=1:dyn.n_hnd_cue
                temp_shape=trial(dyn.trialNumber).hnd.cue(n_obj).shape;
                temp_shape.mode='bar_masked';
                par_hnd(n_obj+dyn.n_hnd_fix) =aux_FillPar(temp_shape, trial(dyn.trialNumber).hnd.cue(n_obj).pos, task.hnd.cue(n_obj).color_dim,...
                    trial(dyn.trialNumber).hnd.cue(n_obj).ringColor, trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob,trial(dyn.trialNumber).hnd.cue(n_obj).ringColor2);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
           
        case STATE.MEM_PER
            if dyn.n_eye_fix==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix==0;par_hnd = struct([]);end;
            for n_obj=1:dyn.n_eye_fix
                par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.fix(n_obj).shape, trial(dyn.trialNumber).eye.fix(n_obj).pos, task.eye.fix(n_obj).color_bright);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.fix(n_obj).shape, trial(dyn.trialNumber).hnd.fix(n_obj).pos, task.hnd.fix(n_obj).color_bright);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.TAR_ACQ_INV  % target acquisition invisible
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            for n_obj=1:dyn.n_eye_tar
                if trial(dyn.trialNumber).effector == 4 % bright eye fixation spot for dissociated memory reaches
                    eye_tar_color = task.eye.fix(1).color_bright;
                else
                    eye_tar_color = task.eye.tar(n_obj).color_inv;
                end
                par_eye(n_obj) = aux_FillPar(trial(dyn.trialNumber).eye.tar(n_obj).shape, trial(dyn.trialNumber).eye.tar(n_obj).pos, eye_tar_color, ...
                    eye_tar_color, trial(dyn.trialNumber).eye.tar(n_obj).reward_prob,eye_tar_color);
            end
            for n_obj=1:dyn.n_hnd_tar
                 if trial(dyn.trialNumber).effector == 3 % bright hnd fixation spot for dissociated memory saccades
                    hnd_tar_color = task.hnd.fix(1).color_bright;
                else
                    hnd_tar_color = task.hnd.tar(n_obj).color_inv;
                 end
                par_hnd(n_obj) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_obj).shape, trial(dyn.trialNumber).hnd.tar(n_obj).pos, hnd_tar_color, ...
                    hnd_tar_color, trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob,hnd_tar_color);
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
                    
        case STATE.TAR_HOL_INV            
            if ~isnan(dyn.target_selected(1))
                if trial(dyn.trialNumber).effector == 4 % bright eye fixation spot for dissociated memory reaches
                    eye_tar_color = task.eye.fix(1).color_bright;
                else
                    eye_tar_color = task.eye.tar(dyn.target_selected(1)).color_inv;
                end
                par_eye = aux_FillPar(trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).shape, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos, eye_tar_color, ...
                    eye_tar_color, trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).reward_prob,eye_tar_color);
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                if trial(dyn.trialNumber).effector == 3 % bright eye fixation spot for dissociated memory reaches
                    hnd_tar_color = task.hnd.fix(1).color_bright;
                else
                    hnd_tar_color = task.hnd.tar(dyn.target_selected(2)).color_inv;
                end
                par_hnd = aux_FillPar(trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).shape, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos, hnd_tar_color,...
                    hnd_tar_color, trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).reward_prob,hnd_tar_color);
            else
                par_hnd = struct([]);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
                
        case STATE.ABORT % abort
            dyn.abort_code = get_abort_code(dyn);
            h = findobj('Tag','Targets');
            if ~isempty(h),
                delete(h),
            end
            dyn.trial_outcome = 0;
            trial(dyn.trialNumber).aborted_state = dyn.previousState;
            trial(dyn.trialNumber).aborted_state_duration = dyn.time_spent_in_state;
            trial(dyn.trialNumber).abort_code = dyn.abort_code;
            trial(dyn.trialNumber).success = 0;
            trial(dyn.trialNumber).target_selected = dyn.target_selected;
            trial(dyn.trialNumber).eye_targets_inspected = dyn.eye_targets_inspected;
            trial(dyn.trialNumber).hand_targets_inspected = dyn.hand_targets_inspected;
            trial(dyn.trialNumber).rewarded = 0;
            trial(dyn.trialNumber).reward_time = 0;
            trial(dyn.trialNumber).reward_prob = -1;
            trial(dyn.trialNumber).reward_selected = 0;
            
            % play not nice sound to monkey
            if SETTINGS.useSound && SETTINGS.WrongTargetSound && trial(dyn.trialNumber).completed == 1 && strcmp(SETTINGS.SoundType, 'Beep'),
                Beeper_PsychPortAudio(SETTINGS.audioPort,120, 0.5, 0.2);
            elseif  SETTINGS.useSound && SETTINGS.WrongTargetSound && trial(dyn.trialNumber).completed == 1 && strcmp(SETTINGS.SoundType, 'XBI_sounds'),
                Sounds('Failure'); %KK

            end
            if SETTINGS.useSound && SETTINGS.FixationBreakSound && (dyn.previousState==STATE.CUE_ON || dyn.previousState==STATE.MEM_PER)
                Beeper_PsychPortAudio(SETTINGS.audioPort,1600, 0.5, 0.2);
                Beeper_PsychPortAudio(SETTINGS.audioPort,1600, 0.5, 0.2);
            end
            
            Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
            Screen(SETTINGS.window,'Flip');
            send_to_TDT(IO,dyn.state);
            if SETTINGS.GUI,
                %set(0, 'currentfigure', dyn.GUI_fig_handle);
                aux_make_all_targets_invisible
            end
            dyn.states_onset = GetSecs - SETTINGS.time_start;
            fprintf([' ' trial(dyn.trialNumber).abort_code]);
            success = 1;
                        
        case STATE.SUCCESS % success
            dyn.abort_code = get_abort_code(dyn);
            send_to_TDT(IO,dyn.state);
%             h = findobj('Tag','Targets');
%             if ~isempty(h),
%                 delete(h),
%             end
            if SETTINGS.GUI,
                %set(0, 'currentfigure', dyn.GUI_fig_handle);
                aux_make_all_targets_invisible
            end
            trial(dyn.trialNumber).aborted_state = -1;
            trial(dyn.trialNumber).aborted_state_duration = -1;
            trial(dyn.trialNumber).abort_code = dyn.abort_code;
            trial(dyn.trialNumber).success = 1;
            trial(dyn.trialNumber).completed = 1;
            trial(dyn.trialNumber).target_selected = dyn.target_selected;
            trial(dyn.trialNumber).eye_targets_inspected = dyn.eye_targets_inspected;
            trial(dyn.trialNumber).hand_targets_inspected = dyn.hand_targets_inspected;
            
            % Decide about reward...
            % Do not reward if reward probability is zero or "secondary"
            % reward for "risky" targets is zero
            
            if trial(dyn.trialNumber).effector < 2, % eye or hand
                % use target_selected(1) or target_selected(2) according to current effector
                if trial(dyn.trialNumber).target_selected(trial(dyn.trialNumber).effector+1) == 1,
                    trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(1).reward;
                    trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(1).reward_prob;
                    reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
                    trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(1).reward_time(reward_idx);
                    
                else
                    trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(2).reward;
                    trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(2).reward_prob;
                    reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
                    trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(2).reward_time(reward_idx);
                end
                
            else % both eye and hand, decide based on which effector to determine reward
                if trial(dyn.trialNumber).target_selected(task.reward_modulation_effector) == 1,
                    trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(1).reward;
                    trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(1).reward_prob;
                    reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
                    trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(1).reward_time(reward_idx);
                    
                else
                    trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(2).reward;
                    trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(2).reward_prob;
                    reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
                    trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(2).reward_time(reward_idx);
                end
            end
            
            dyn.trial_outcome = 1;
            dyn.trialNumberFinished = dyn.trialNumberFinished + 1;
            
            % play nice sound to monkey
            if SETTINGS.useSound && SETTINGS.RewardSound && strcmp(SETTINGS.SoundType, 'Beep')
               Beeper_PsychPortAudio(SETTINGS.audioPort,200, 0.5, 0.2);
            elseif SETTINGS.useSound && SETTINGS.RewardSound && strcmp(SETTINGS.SoundType, 'XBI_sounds')
               Sounds('Reward') ;     %KK                      
            end
            
            Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
            Screen(SETTINGS.window,'Flip');
            
        case STATE.REWARD % reward
            send_to_TDT(IO,dyn.state);
            
            dyn.duration=trial(dyn.trialNumber).task.timing.wait_for_reward;
            [success,dyn,task]=wait_while_recording_state(task,dyn);
            
            if trial(dyn.trialNumber).reward_time > 0,
                trial(dyn.trialNumber).rewarded = 1;
                if SETTINGS.useParallel || SETTINGS.useSerial
                    dyn.duration=trial(dyn.trialNumber).reward_time;
                     if SETTINGS.useSound && SETTINGS.RewardSound && strcmp(SETTINGS.SoundType, 'XBI_sounds')
                            Sounds('Reward') ;   %KK                        

                     end
                    [success,dyn,task]=aux_DispenseReward(task,dyn);
                end
            else
                trial(dyn.trialNumber).rewarded = 0;
            end
            
        case STATE.ITI  % ITI            
            if ~isnan(dyn.microstim_start)
                % update this in case it was randomized timing with alignment to the end of a state
                trial(dyn.trialNumber).microstim_start  = dyn.microstim_start;
                trial(dyn.trialNumber).microstim_end    = dyn.microstim_end;
            end
            
            clear par
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = ITI_state(task,dyn,IO);
            
            % Write data to file
            dyn.memoryBuffer = dyn.memoryBuffer(1:dyn.counterLine,:);  % truncate and transpose
            
            trial(dyn.trialNumber).tSample_from_time_start=dyn.memoryBuffer(:,1);
            trial(dyn.trialNumber).trial_number=dyn.memoryBuffer(:,2);
            trial(dyn.trialNumber).state=dyn.memoryBuffer(:,3);
            trial(dyn.trialNumber).x_hnd=dyn.memoryBuffer(:,4);
            trial(dyn.trialNumber).y_hnd=dyn.memoryBuffer(:,5);
            trial(dyn.trialNumber).x_eye=dyn.memoryBuffer(:,6);
            trial(dyn.trialNumber).y_eye=dyn.memoryBuffer(:,7);
            trial(dyn.trialNumber).sen_L=dyn.memoryBuffer(:,8);
            trial(dyn.trialNumber).sen_R=dyn.memoryBuffer(:,9);
            trial(dyn.trialNumber).jaw=dyn.memoryBuffer(:,10);
            trial(dyn.trialNumber).body=dyn.memoryBuffer(:,11);
            trial(dyn.trialNumber).counter=dyn.counterLine;
            
            dyn.memoryBuffer    = single(nan(SETTINGS.bufferSize,11));    % reset memoryBuffer
            dyn.counterLine     = 0;
            
            current_trial=trial(dyn.trialNumber);
            if ~exist(outFilefolder,'dir'),
                mkdir(pathname,filename);
            end
            if dyn.trialNumber > 1,
                save([outFilefolder filesep filename '_' num2str(dyn.trialNumber,'%04u')],'current_trial','sequence_indexes');
            else
                save([outFilefolder filesep filename '_' num2str(dyn.trialNumber,'%04u')],'SETTINGS','task','current_trial','sequence_indexes');
            end
            
        %% Display
%             special_error = ''; % 'ABORT_EYE_CUE_ON_STATE';
%             special_error_count =  sum(strcmp( special_error, cat(2,{trial.abort_code})));
            if ~isempty(SETTINGS.special_error)
                special_error_count =  sum(strcmp( SETTINGS.special_error, cat(2,{trial.abort_code})));
            else special_error_count = NaN;
            end
        
            if trial(dyn.trialNumber).success
                fprintf(' success (%d %d %d %d  %s %d)\n', dyn.trialNumber, dyn.trialNumberInitiated, dyn.trialNumberCompleted, dyn.trialNumberFinished, SETTINGS.special_error, special_error_count);
            else
                fprintf(' failure (%d %d %d %d  %s %d)\n', dyn.trialNumber, dyn.trialNumberInitiated, dyn.trialNumberCompleted, dyn.trialNumberFinished, SETTINGS.special_error, special_error_count);
            end
            
            if trial(dyn.trialNumber).success && trial(dyn.trialNumber).choice,
                switch trial(dyn.trialNumber).effector,
                    case {0,2,3} % eye, both
                        selected_position_x = trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).pos(1)-trial(dyn.trialNumber).eye.fix.pos(1);
                    case {1,4,6} % hand
                        selected_position_x = trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).pos(1)-trial(dyn.trialNumber).eye.fix.pos(1);
                end
                if trial(dyn.trialNumber).microstim
                    if selected_position_x < 0,
                        dyn.choice_l_microstim = dyn.choice_l_microstim + 1;
                    else
                        dyn.choice_r_microstim = dyn.choice_r_microstim + 1;
                    end
                else % no microstim
                    if selected_position_x < 0,
                        dyn.choice_l = dyn.choice_l + 1;
                    else
                        dyn.choice_r = dyn.choice_r + 1;
                    end
                end
                
                fprintf(' || control L/R %.2f microstim L/R %.2f || \n',dyn.choice_l/dyn.choice_r,dyn.choice_l_microstim/dyn.choice_r_microstim);
            end
            
            %% ITI GUI
            if SETTINGS.ITI_GUI,
                
                n = dyn.trialNumber;                
                idx = find(trial(n).state>STATE.FIX_ACQ & trial(n).state<STATE.REWARD,1);
                if ~isempty(idx),
                    time_axis = trial(n).tSample_from_time_start - trial(n).tSample_from_time_start(1);
                    time_state_change = time_axis([0; diff(trial(n).state)]~=0)';
                    figure(2); clf;
                    subplot(2,1,1);
                    plot(time_axis,trial(n).x_eye,'g');
                    set(gca,'Xlim',[0 SETTINGS.ITI_GUI_time_limit],'XLimMode','manual');
                    ig_add_multiple_vertical_lines(time_state_change,'Color','r');
                    
                    if trial(n).microstim && ~isempty(time_axis(trial(n).state == trial(n).microstim_state))
                        stimulated_state=time_axis(trial(n).state==trial(n).microstim_state);
                        stimulation_onset=trial(n).microstim_start+stimulated_state(1);
                        ylim = get(gca,'Ylim');
                        xlim = get(gca,'Xlim');
                        if xlim(2)>stimulation_onset+0.2
                            rectangle('Position',[stimulation_onset ylim(1) 0.2 ylim(2)-ylim(1)],'EdgeColor','c','LineWidth',2,'LineStyle','--')
                        else
                            line([stimulation_onset; stimulation_onset], ylim,'Color','c','LineWidth',2,'LineStyle','--');
                        end
                    end
                    
                    title(sprintf('trial %d suc. %d choice %d microstim %d',[trial(n).n trial(n).success trial(n).choice...
                        trial(n).microstim]))
                    
                    subplot(2,1,2);
                    plot(time_axis,trial(n).y_eye,'m');
                    set(gca,'Xlim',[0 SETTINGS.ITI_GUI_time_limit],'XLimMode','manual');
                    ig_add_multiple_vertical_lines(time_state_change,'Color','r');
                    
                    if trial(n).microstim && ~isempty(time_axis(trial(n).state == trial(n).microstim_state))
                        stimulated_state=time_axis(trial(n).state==trial(n).microstim_state);
                        stimulation_onset=trial(n).microstim_start+stimulated_state(1);
                        %stimulation_end=trial(n).microstim_end+stimulated_state(1);
                        %t=stimulation_onset;
                        ylim = get(gca,'Ylim');
                        xlim = get(gca,'Xlim');
                        if xlim(2)>stimulation_onset+0.2
                            rectangle('Position',[stimulation_onset ylim(1) 0.2 ylim(2)-ylim(1)],'EdgeColor','c','LineWidth',2,'LineStyle','--')
                        else
                            line([stimulation_onset; stimulation_onset], ylim,'Color','c','LineWidth',2,'LineStyle','--');
                        end
                    end
                    
                    drawnow;
                    figure(1);
                end
            end
            
        case STATE.CLOSE % close gracefully
            send_to_TDT(IO,dyn.state);
            eye_offset_x = task.eye.offset_x;
            eye_offset_y = task.eye.offset_y;
            eye_gain_x = task.eye.gain_x;
            eye_gain_y = task.eye.gain_y;
            save([DATA_PATH filesep 'last_eyecal.mat'],'eye_offset_x','eye_offset_y','eye_gain_x','eye_gain_y');
            fprintf('\nSaved eye calibration to %s\n',DATA_PATH);
            
            if isfield(trial,'state') && ~isempty(trial(1).state)
                if ~exist(outFilefolder,'dir'),
                    mkdir(pathname,filename);
                end
                if dyn.trialNumber == 1
                    current_trial=trial;
                    save([outFilefolder filesep filename '_' num2str(dyn.trialNumber,'%04u')],'SETTINGS','task','current_trial','sequence_indexes');
                end
                combine_trials_from_single_matfiles(pathname,filename);
                fprintf('\nNow closing. Data saved to:\n');disp(outFileMat);
            end
            
            if SETTINGS.useSerial,
                fclose(SETTINGS.sp);
            end
            
            if SETTINGS.useSound
                PsychPortAudio('Close', SETTINGS.audioPort);
            end
            autosave_changed_monkeypsych;
            Screen('CloseAll');
            sca;             % clear screen
            
            ListenChar(0);
            return;
            
        otherwise
            error('this state should not occur');
            ListenChar(0);
    end
    
    
    trial(dyn.trialNumber).states = [trial(dyn.trialNumber).states dyn.state];
    trial(dyn.trialNumber).states_onset = [trial(dyn.trialNumber).states_onset dyn.states_onset];
%     if dyn.force_trial_end && success
%         dyn.state               = STATE.SUCCESS;
%         dyn.force_trial_end     = false;
%         trial(dyn.trialNumber).completed = dyn.completed;             
%         trial(dyn.trialNumber).manual_success    = 1;
%     elseif dyn.force_trial_end && ~success
%         dyn.state               = STATE.ABORT;
%         dyn.force_trial_end     = false;
%         trial(dyn.trialNumber).completed = dyn.completed;
%         trial(dyn.trialNumber).manual_success    = 1;
%     else
        dyn.state               = state_transition(task,success,dyn.state);
        
        if dyn.state==STATE.SUCCESS
            trial(dyn.trialNumber).completed = 1;
            dyn.completed = 1;
            dyn.trialNumberCompleted = dyn.trialNumberCompleted + 1;
            if ~any(trial(dyn.trialNumber).task.correct_choice_target == dyn.target_selected(dyn.tar_selected_ind)) % for eye and hand targets
                dyn.state=STATE.ABORT;
            end
        end
    %end
    if dyn.state==STATE.INI_TRI && SETTINGS.interface_with_scanner && ((GetSecs-SETTINGS.time_start) > SETTINGS.run_volumes*SETTINGS.TR),
        dyn.state = STATE.CLOSE;
    end
end

%% State functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function state_duration = get_state_duration(task,trial,dyn)

global STATE

switch dyn.state
    
    case STATE.INI_TRI % initial fixation
        state_duration = 0;
        
    case STATE.FIX_ACQ 
        switch trial(dyn.trialNumber).effector
            case {0, 5}
                state_duration = task.timing.fix_time_to_acquire_eye;
            case {1}
                state_duration = task.timing.fix_time_to_acquire_hnd;
            case {2,3,4,6}
                state_duration = max(task.timing.fix_time_to_acquire_eye,task.timing.fix_time_to_acquire_hnd);
        end
        
    case STATE.FIX_HOL 
        state_duration = task.timing.fix_time_hold + rand*task.timing.fix_time_hold_var;
        
        
    case STATE.TAR_ACQ 
        switch trial(dyn.trialNumber).effector
            case 0
                state_duration = task.timing.tar_time_to_acquire_eye;
            case {1,5,6}
                state_duration = task.timing.tar_time_to_acquire_hnd;
            case {2,3,4}
                state_duration = max(task.timing.tar_time_to_acquire_eye,task.timing.tar_time_to_acquire_hnd);
        end
        
    case STATE.TAR_HOL 
        state_duration = task.timing.tar_time_hold + rand*task.timing.tar_time_hold_var;
        
    case STATE.CUE_ON 
        state_duration = task.timing.cue_time_hold + rand*task.timing.cue_time_hold_var;
        
    case STATE.MEM_PER 
        state_duration = task.timing.mem_time_hold + rand*task.timing.mem_time_hold_var;
        
    case STATE.DEL_PER 
        state_duration = task.timing.del_time_hold + rand*task.timing.del_time_hold_var;
        
    case STATE.MSK_HOL 
        state_duration = task.timing.msk_time_hold + rand*task.timing.msk_time_hold_var;
        
    case STATE.TAR_ACQ_INV 
        switch trial(dyn.trialNumber).effector
            case 0
                state_duration = task.timing.tar_inv_time_to_acquire_eye;
            case {1,5,6}
                state_duration = task.timing.tar_inv_time_to_acquire_hnd;
            case {2,3,4}
                state_duration = max(task.timing.tar_inv_time_to_acquire_eye,task.timing.tar_inv_time_to_acquire_hnd);
        end
        
    case STATE.TAR_HOL_INV 
        state_duration = task.timing.tar_inv_time_hold + rand*task.timing.tar_inv_time_hold_var;
        
    case STATE.MAT_ACQ 
        switch trial(dyn.trialNumber).effector
            case 0
                state_duration = task.timing.tar_time_to_acquire_eye-dyn.time_spent_exploring;
            case {1,5,6}
                state_duration = task.timing.tar_time_to_acquire_hnd-dyn.time_spent_exploring;
            case {2,3,4}
                state_duration = max(task.timing.tar_time_to_acquire_eye,task.timing.tar_time_to_acquire_hnd)-dyn.time_spent_exploring;
        end
        
    case STATE.MAT_ACQ_MSK 
        switch trial(dyn.trialNumber).effector
            case 0
                state_duration = task.timing.tar_time_to_acquire_eye-dyn.time_spent_exploring;
            case {1,5,6}
                state_duration = task.timing.tar_time_to_acquire_hnd-dyn.time_spent_exploring;
            case {2,3,4}
                state_duration = max(task.timing.tar_time_to_acquire_eye,task.timing.tar_time_to_acquire_hnd)-dyn.time_spent_exploring;
        end
        
    case STATE.SEN_RET
        state_duration = task.timing.tar_time_to_acquire_hnd;
        
    case STATE.MAT_HOL
        state_duration = task.timing.tar_time_hold + rand*task.timing.tar_time_hold_var;
        
    case STATE.MAT_HOL_MSK 
        state_duration = task.timing.tar_time_hold + rand*task.timing.tar_time_hold_var;
        
    case STATE.FIX_PER
        state_duration = task.timing.del_time_hold + rand*task.timing.del_time_hold_var;
        
    case STATE.ITI
        if trial(dyn.trialNumber).success            
            state_duration = task.timing.ITI_success + rand*task.timing.ITI_success_var;
        elseif trial(dyn.trialNumber).completed
            state_duration = task.timing.ITI_incorrect_completed + rand*task.timing.ITI_fail_var;
        else
            state_duration = task.timing.ITI_fail + rand*task.timing.ITI_fail_var;
        end
end

function new_state = state_transition(task,success,current_state)

global STATE

if ~success,
    new_state = STATE.ABORT;
elseif current_state == STATE.ABORT,
    new_state = STATE.ITI;
elseif current_state == STATE.ITI,
    new_state = STATE.INI_TRI;
elseif current_state == STATE.CLOSE,
    new_state = STATE.CLOSE;
else
    
    switch task.type
        
        case 1 % fixation
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 2 % direct saccade/reach
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.TAR_ACQ  STATE.TAR_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 2.5 % direct saccade/reach with "cue" distractor congruent with target
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MEM_PER  ...
                STATE.TAR_ACQ  STATE.TAR_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
        case 3 % memory response
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MEM_PER  STATE.TAR_ACQ_INV  STATE.TAR_HOL_INV ...
                STATE.TAR_ACQ  STATE.TAR_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 4 % delay response
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.DEL_PER  ...
                STATE.TAR_ACQ  STATE.TAR_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 5 % Match-to-sample task
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MEM_PER  ...
                STATE.MAT_ACQ  STATE.MAT_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 6 % Match-to-sample task with masked targets
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MEM_PER  ...
                STATE.MAT_ACQ_MSK  STATE.MAT_HOL_MSK  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 7 % Poffenberger
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.TAR_ACQ STATE.SEN_RET STATE.DEL_PER STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
        case 8 % Multiple cue flashes for RF checking
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.FIX_PER STATE.SUCCESS  STATE.REWARD  STATE.ITI];
        case 9 % delayed Match-to-sample with backward masking (IN FUTURE with Wagering)
             task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MSK_HOL  STATE.MEM_PER...
                STATE.TAR_ACQ  STATE.TAR_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
            
    end
    
    if success==1
        current_state_idx = find(current_state == task_states);
        new_state = task_states(current_state_idx + 1);
    elseif success==-1
        current_state_idx = find(current_state == task_states);
        new_state = task_states(current_state_idx -1);
    end
    
end

function abort_code = get_abort_code(dyn)
% Returns specific abort code based on combination of state in which abort occurred, and behavioral markers
% This function is called from acquire_state and hold_state
% dyn.time_spent_in_state - in case of abort, tells duration of state prior to abort

global STATE
% Behavioral markers: eye, hand, sen1, sen2, jaw, body
bm_eye = 1; bm_hnd = 2; bm_sen1 = 3; bm_sen2 = 4; bm_jaw = 5; bm_body = 6;
beh_markers = dyn.beh_markers;
abort_code = 'UNKNOWN ERROR CODE';


ABORT_JAW = 'ABORT_JAW';
ABORT_BODY = 'ABORT_BODY';

ABORT_USE_INCORRECT_HAND = 'ABORT_USE_INCORRECT_HAND'; % in the initial fixation acquisition

ABORT_DIRTY_SENSORS = 'ABORT_DIRTY_SENSORS';
ABORT_WRONG_TARGET_SELECTED  = 'ABORT_WRONG_TARGET_SELECTED';

ABORT_RELEASE_SENSOR_HOLD_STATE = 'ABORT_RELEASE_SENSOR_HOLD_STATE';

ABORT_EYE_FIX_ACQ_STATE = 'ABORT_EYE_FIX_ACQ_STATE';
ABORT_HND_FIX_ACQ_STATE = 'ABORT_HND_FIX_ACQ_STATE';

ABORT_EYE_FIX_HOLD_STATE = 'ABORT_EYE_FIX_HOLD_STATE';
ABORT_HND_FIX_HOLD_STATE = 'ABORT_HND_FIX_HOLD_STATE';

ABORT_EYE_TAR_ACQ_STATE = 'ABORT_EYE_TAR_ACQ_STATE';
ABORT_HND_TAR_ACQ_STATE = 'ABORT_HND_TAR_ACQ_STATE';

ABORT_EYE_TAR_HOLD_STATE = 'ABORT_EYE_TAR_HOLD_STATE';
ABORT_HND_TAR_HOLD_STATE = 'ABORT_HND_TAR_HOLD_STATE';


ABORT_EYE_TAR_ACQ_INV_STATE = 'ABORT_EYE_TAR_ACQ_INV_STATE'; %
ABORT_HND_TAR_ACQ_INV_STATE = 'ABORT_HND_TAR_ACQ_INV_STATE'; %

ABORT_EYE_TAR_HOLD_INV_STATE = 'ABORT_EYE_TAR_HOLD_INV_STATE'; %
ABORT_HND_TAR_HOLD_INV_STATE = 'ABORT_HND_TAR_HOLD_INV_STATE'; %

ABORT_EYE_CUE_ON_STATE = 'ABORT_EYE_CUE_ON_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset
ABORT_HND_CUE_ON_STATE = 'ABORT_HND_CUE_ON_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset

ABORT_EYE_MEM_PER_STATE = 'ABORT_EYE_MEM_PER_STATE'; %% if time spent in state < 200 ms, error is 'ABORT_EYE_CUE_ON_STATE', otherwise error is 'ABORT_EYE_MEM_PER_STATE'
ABORT_HND_MEM_PER_STATE = 'ABORT_HND_MEM_PER_STATE'; %% if time spent in state < 200 ms, error is 'ABORT_EYE_CUE_ON_STATE', otherwise error is 'ABORT_EYE_MEM_PER_STATE'

ABORT_EYE_DEL_PER_STATE = 'ABORT_EYE_DEL_PER_STATE';
ABORT_HND_DEL_PER_STATE = 'ABORT_HND_DEL_PER_STATE';

ABORT_EYE_MSK_HOLD_STATE = 'ABORT_EYE_MSK_HOLD_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset
ABORT_HND_MSK_HOLD_STATE = 'ABORT_HND_MSK_HOLD_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset


if dyn.state~=STATE.ABORT,
    abort_code = 'NO ABORT';
else
    if ~beh_markers(bm_jaw)
        abort_code = ABORT_JAW;
    elseif ~beh_markers(bm_body)
        abort_code = ABORT_BODY;
    elseif (~beh_markers(bm_sen1) || ~beh_markers(bm_sen2)) && ~(~beh_markers(bm_sen1) && ~beh_markers(bm_sen2)) && ...
            (dyn.previousState==STATE.FIX_ACQ) %% || (dyn.previousState==STATE.TAR_ACQ && task.effector==5)), !!
        abort_code = ABORT_USE_INCORRECT_HAND;
    elseif (~beh_markers(bm_sen1) || ~beh_markers(bm_sen2))&& ~(~beh_markers(bm_sen1) && ~beh_markers(bm_sen2)),
        abort_code = ABORT_RELEASE_SENSOR_HOLD_STATE;
    elseif (~beh_markers(bm_sen1) && ~beh_markers(bm_sen2)),
        abort_code = ABORT_DIRTY_SENSORS;
    elseif dyn.completed
        abort_code = ABORT_WRONG_TARGET_SELECTED;
    else
        switch dyn.previousState % state in which abort occurred
            
            
            case STATE.FIX_ACQ
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FIX_ACQ_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FIX_ACQ_STATE;
                end
                
            case STATE.FIX_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FIX_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FIX_HOLD_STATE;
                end
                
            case STATE.FIX_PER
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FIX_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FIX_HOLD_STATE;
                end
                
            case STATE.TAR_ACQ
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_ACQ_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_ACQ_STATE;
                end
                
            case STATE.TAR_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_HOLD_STATE;
                end
                
            case STATE.MAT_ACQ
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_ACQ_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_ACQ_STATE;
                end
                
            case STATE.MAT_ACQ_MSK
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_ACQ_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_ACQ_STATE;
                end
                
            case STATE.MAT_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_HOLD_STATE;
                end
                
            case STATE.MAT_HOL_MSK
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_HOLD_STATE;
                end
                
            case STATE.TAR_ACQ_INV
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_ACQ_INV_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_ACQ_INV_STATE;
                end
                
            case STATE.TAR_HOL_INV
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_HOLD_INV_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_HOLD_INV_STATE;
                end
                
            case STATE.CUE_ON
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_CUE_ON_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_CUE_ON_STATE;
                end
                
            case STATE.MSK_HOL % KK:Mask for the M2S-task
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_MSK_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_MSK_HOLD_STATE;
                end
                
            case STATE.MEM_PER
                
                if ~beh_markers(bm_eye) && dyn.time_spent_in_state < 0.2,
                    abort_code = ABORT_EYE_CUE_ON_STATE;
                elseif ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_MEM_PER_STATE;
                elseif ~beh_markers(bm_hnd) && dyn.time_spent_in_state < 0.2,
                    abort_code = ABORT_HND_CUE_ON_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_MEM_PER_STATE;
                end
                
            case STATE.DEL_PER
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_DEL_PER_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_DEL_PER_STATE;
                end
                %         otherwise
                %             abort_code = 'UNKNOWN ERROR CODE';
        end
        
    end
    
end

function [success,dyn,task]  = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO)
%%

global SETTINGS STATE

if trial(dyn.trialNumber).microstim && trial(dyn.trialNumber).microstim_state == dyn.state && trial(dyn.trialNumber).microstim_start < 0,
    % reference microstim to end of the state
    trial(dyn.trialNumber).microstim_start  = dyn.duration + trial(dyn.trialNumber).microstim_start;
    trial(dyn.trialNumber).microstim_end    = dyn.duration + trial(dyn.trialNumber).microstim_end;
    dyn.microstim_start = trial(dyn.trialNumber).microstim_start;
    dyn.microstim_end   = trial(dyn.trialNumber).microstim_end;
end

dyn.hand_selected = NaN;
success         = false;
hold_success    = true; % hold for other effector for dissociated eye-hand tasks

dyn.counterTimeSteps = 1;
n_obj_eye = length(par_eye);
n_obj_hnd = length(par_hnd);


if SETTINGS.GUI
    tag_invisible='cue';
    tag_invisible2='cue';
    switch dyn.state
        case STATE.FIX_ACQ
            tag_visible='fix';
        case STATE.TAR_ACQ
            tag_visible='tar';
            tag_invisible='fix';
        case STATE.TAR_ACQ_INV
            tag_visible='tar';
            tag_invisible='fix';
            tag_invisible2='cue';
        case STATE.MAT_ACQ
            tag_visible='tar';
            tag_invisible='fix';
            tag_invisible2='cue';
        case STATE.MAT_ACQ_MSK
            tag_visible='tar';
            tag_invisible='fix';
            tag_invisible2='cue';
    end
    if n_obj_eye>0
        aux_make_targets_visible(['eye' tag_visible 'Size'])
        aux_make_targets_visible(['eye' tag_visible 'Radius'])
        aux_make_targets_visible(['eye' tag_visible 'correct'])
        aux_make_targets_invisible(['eye' tag_invisible 'Size'])
        aux_make_targets_invisible(['eye' tag_invisible 'Radius'])
        aux_make_targets_invisible(['eye' tag_invisible 'correct'])
        aux_make_targets_invisible(['eye' tag_invisible2 'Size'])
        aux_make_targets_invisible(['eye' tag_invisible2 'Radius'])
        aux_make_targets_invisible(['eye' tag_invisible2 'correct'])
    end
    if n_obj_hnd>0
        aux_make_targets_visible(['hnd' tag_visible 'Size'])
        aux_make_targets_visible(['hnd' tag_visible 'Radius'])
        aux_make_targets_visible(['hnd' tag_visible 'correct'])
        aux_make_targets_invisible(['hnd' tag_invisible 'Size'])
        aux_make_targets_invisible(['hnd' tag_invisible 'Radius'])
        aux_make_targets_invisible(['hnd' tag_invisible 'correct'])
        aux_make_targets_invisible(['hnd' tag_invisible2 'Size'])
        aux_make_targets_invisible(['hnd' tag_invisible2 'Radius'])
        aux_make_targets_invisible(['hnd' tag_invisible2 'correct'])
    end
    drawnow;
end

for obj = 1:n_obj_hnd
    aux_PrepareStimuli(par_hnd(obj));
end
for obj = 1:n_obj_eye
    aux_PrepareStimuli(par_eye(obj));
end

% Behavioral markers: eye, hand, sen1, sen2, jaw, body
bm_eye = 1; bm_hnd = 2; bm_sen1 = 3; bm_sen2 = 4; bm_jaw = 5; bm_body = 6;
beh_markers = ones(1,6);

Screen(SETTINGS.window,'Flip');
send_to_TDT(IO,dyn.state);

tEnterState      = GetSecs;
dyn.states_onset = tEnterState - SETTINGS.time_start;

tPreviousEyeHandUpdate = 0;
tPreviousPulseDelivery = 0; % for microstim

eye_acq = 0;
hnd_acq = 0;

tLeaveFixationEye   = 0;
tLeaveFixationHnd   = 0;



while true
success         = false;
    tSample = GetSecs;
    
    
    eye_acq_current = 0;
    hnd_acq_current = 0;
    
    [x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task); % in deg
    
    switch task.effector,
        case 0 % eye
            
            %                         if touching
            %                             disp('touched touchscreen in acquisition! - aborting');
            %                             Beeper_PsychPortAudio(SETTINGS.audioPort,4000, [1], [.2]); Beeper_PsychPortAudio(SETTINGS.audioPort,4000, [1], [.2]);
            %                             success = false; % if out for long time, abort trial
            %                             dyn.previousState = dyn.state;
            %                             dyn.state   = STATE.ABORT;
            %                             dyn.aborted_effector = 0;
            %                         end
            
            
            for obj = 1:n_obj_eye
                if aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    success = true;
                    if isnan(dyn.target_selected(1)), dyn.target_selected(1) = obj; end
                end
            end
            hnd_acq = 1;
            
        case {1,6} % hand
            
            for obj = 1:n_obj_hnd
                if aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    success = true;
                    if isnan(dyn.target_selected(2)), dyn.target_selected(2) = obj; end
                end
            end
            eye_acq = 1;
            
        case 2 % both
            
            
            for obj = 1:n_obj_eye
                if aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    eye_acq_current = true;
                    if isnan(dyn.target_selected(1)), dyn.target_selected(1) = obj; end
                    if ~eye_acq, % eye acquired for the first time
                        eye_acq = 1;
                    end
                end
            end
            
            for obj = 1:n_obj_hnd
                if aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    hnd_acq_current = true;
                    if isnan(dyn.target_selected(2)), dyn.target_selected(2) = obj; end
                    if ~hnd_acq
                        hnd_acq = 1;
                    end
                end
            end
            if eye_acq_current && hnd_acq_current
                success = true;
            end
            
            
            
        case 3, %  saccade with central hold
            for obj = 1:n_obj_eye
                if aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    success = true;
                    if isnan(dyn.target_selected(1)),
                        dyn.target_selected(1) = obj;
                        dyn.target_selected(2) = 1; % dummy
                    end
                    eye_acq = 1;
                end
            end
            
            
        case 4, % reach with central fixation
            
            for obj = 1:n_obj_hnd
                if aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    success = true;
                    if isnan(dyn.target_selected(2)),
                        dyn.target_selected(2) = obj;
                        dyn.target_selected(1) = 1; % dummy
                    end
                    hnd_acq = 1;
                end
            end
            
        case 5, % reaching for sensors with central fixation
            if (sen3 || sen4 && dyn.state == STATE.TAR_ACQ) || (sen1 && sen2 && dyn.state == STATE.SEN_RET)
                success = true;
                if isnan(dyn.target_selected(2)) && dyn.state == STATE.TAR_ACQ,
                    temp_target=find([sen3 sen4]);
                    dyn.target_selected(2) = temp_target(1);
                    dyn.target_selected(1) = NaN; % dummy
                end
                %                 if sum ([sen1 sen2 sen3 sen4]) > 2  % 2014190: Aborting for dirty sensors
                %                     success = false;
                %                     beh_markers(bm_sen1) = false;
                %                     beh_markers(bm_sen2) = false;
                %                 end
                %fprintf('  RThnd=%4d',round((GetSecs-tEnterState)*1000));
                %dyn.RThnd=round((GetSecs-tEnterState)*1000);
                hnd_acq = 1;
            end
            
            
    end % of switch effector
    
    
    % update figure only every "SETTINGS.figure_drawing_interval"
    if SETTINGS.GUI && (tSample > tPreviousEyeHandUpdate + SETTINGS.figure_drawing_interval),
        tPreviousEyeHandUpdate = tSample;
        aux_DrawEyeHandPos(x_eye, y_eye, x_hnd, y_hnd, dyn, task);
    end
    
    dyn.counterLine = dyn.counterLine+1;
    dyn.memoryBuffer(dyn.counterLine,:) = [tSample-SETTINGS.time_start,dyn.trialNumber,dyn.state,x_hnd,y_hnd,x_eye,y_eye,sen1,sen2,sen3,sen4];
    
    
    %     if ~sen1,
    %             success = false;
    %             dyn.previousState = dyn.state;
    %             dyn.state   = STATE.ABORT;
    %             disp('sen1 is not activated');
    %             break;
    %     end
    
    
    
    
    if SETTINGS.check_motion_jaw || SETTINGS.check_motion_body
        is_moving = [~sen3 ~sen4];
        if ~(SETTINGS.allowMotionLate  && (dyn.state==STATE.TAR_HOL || dyn.state== STATE.TAR_HOL_INV)) % included by vlk 2.03.2018
            if is_moving(1) && SETTINGS.check_motion_jaw,
                success = false;
                dyn.previousState = dyn.state;
                % dyn.state   = STATE.ABORT;
                beh_markers(bm_jaw) = 0;
                aux_MonkeyMoved('jaw');
                break;
            end
            if is_moving(2) && SETTINGS.check_motion_body,
                success = false;
                dyn.previousState = dyn.state;
                % dyn.state   = STATE.ABORT;
                aux_MonkeyMoved('body');
                beh_markers(bm_body) = 0;
                break;
            end
        end   
    end
    
    if any(task.rest_hand)
        [holding_sensors_correctly holding_individual_sensors_correctly] = aux_CheckSensors(task,[sen1 sen2],trial,dyn);
        if ~holding_sensors_correctly, % monkey released one of the sensors, abort
            success = false;
            dyn.previousState = dyn.state;
            % dyn.state   = STATE.ABORT;
            fprintf(' released sensor(s), aborting');
            
            if SETTINGS.useSound && SETTINGS.SensorsReleasedSound
                Beeper_PsychPortAudio(SETTINGS.audioPort,100, 1,0.2);
            end
            
            beh_markers(bm_sen1) = holding_individual_sensors_correctly(1);
            beh_markers(bm_sen2) = holding_individual_sensors_correctly(2);
            dyn.hand_selected = find(~[sen1 sen2] & task.rest_hand);
            break;
        end
    end
    
    if task.effector == 3, % saccade, check the hand hold
        
        for obj = 1:n_obj_hnd
            
            if ~aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                
                if ~tLeaveFixationHnd
                    tLeaveFixationHnd = GetSecs;    % if just got out of fixation, initiate timer
                elseif GetSecs - tLeaveFixationHnd > task.timing.grace_time_hand
                    hold_success = false; % if out for long time, abort trial
                    dyn.previousState = dyn.state;
                    % dyn.state   = STATE.ABORT;
                    dyn.aborted_effector = 1;
                    beh_markers(bm_hnd) = 0;
                end
                
            elseif aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                tLeaveFixationHnd = 0;  % if inside, reset timer
            end
        end
        if ~hold_success, break, end;
        
    elseif task.effector == 4 || task.effector == 5, % reach, check the eye hold
        
        for obj = 1:n_obj_eye
            
            if ~aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                
                if SETTINGS.allowBlinksOnly && ~aux_IsDisplacedDown(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius)
                   hold_success = false; %  abort trial
                    dyn.previousState = dyn.state;
                    % dyn.state   = STATE.ABORT;
                    dyn.aborted_effector = 0;
                    beh_markers(bm_eye) = 0;
                else 
                    if ~tLeaveFixationEye
                        tLeaveFixationEye = GetSecs;    % if just got out of fixation, initiate timer
                    elseif GetSecs - tLeaveFixationEye > task.timing.grace_time_eye
                        hold_success = false; % if out for long time, abort trial
                        dyn.previousState = dyn.state;
                        % dyn.state   = STATE.ABORT;
                        dyn.aborted_effector = 0;
                        beh_markers(bm_eye) = 0;
                    end
                end
            elseif aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                tLeaveFixationEye = 0;  % if inside, reset timer
            end
        end
        if ~hold_success, break, end;
        
        
    end
    
    if success,        
        if  ~isnan(dyn.target_selected(dyn.tar_selected_ind)) && ...
                trial(dyn.trialNumber).task.(dyn.effector).tar(dyn.target_selected(dyn.tar_selected_ind)).x ==  trial(dyn.trialNumber).task.(dyn.effector).fix.x && ...
                trial(dyn.trialNumber).task.(dyn.effector).tar(dyn.target_selected(dyn.tar_selected_ind)).y == trial(dyn.trialNumber).task.(dyn.effector).fix.y && ... 
                GetSecs - tEnterState < dyn.duration % if target_selected is fixation target and time_to_acquire_eye is not over yet
            dyn.target_selected = [NaN NaN];
        else
            dyn.hand_selected = find(~[sen1 sen2] & task.rest_hand);
            break;
        end
    end
    
    if GetSecs > tEnterState + dyn.duration    	% check time
        dyn.previousState = dyn.state;
        if dyn.stay_condition
            success = true;
            dyn.hand_selected = 0;
            break
        else
            dyn.hand_selected = find(~[sen1 sen2] & task.rest_hand);
        end
        
        success = false;
        % dyn.state=STATE.ABORT;
        if eye_acq==0 && hnd_acq==0,
            dyn.aborted_effector = 2; % both never acquired
            beh_markers(bm_eye) = 0;
            beh_markers(bm_hnd) = 0;
        elseif eye_acq
            dyn.aborted_effector = 1; % hand
            beh_markers(bm_hnd) = 0;
        else
            dyn.aborted_effector = 0; % eye
            beh_markers(bm_eye) = 0;
        end
        
        fprintf(' aborted_effector %d  RT=%4d',dyn.aborted_effector, round((GetSecs-tEnterState)*1000));
        break
    end
    
    %         WaitSecs('Untiltime',tEnterState+timeStep*counterTimeSteps); % maintain matlab sampling rate (constant num samples)
    WaitSecs('Untiltime',tSample+SETTINGS.timeStep); % maintain matlab sampling rate
    dyn.counterTimeSteps=dyn.counterTimeSteps+1;
    
    
    if trial(dyn.trialNumber).microstim && trial(dyn.trialNumber).microstim_state == dyn.state ...
            && (tSample > tEnterState + trial(dyn.trialNumber).microstim_start) && (tSample < tEnterState + trial(dyn.trialNumber).microstim_end),
        if tSample > tPreviousPulseDelivery + trial(dyn.trialNumber).microstim_interval,  % send pulse only every "microstim_interval"
            tPreviousPulseDelivery = tSample;
            aux_produce_one_trigger(dyn);
%             fprintf(' microstim in %d @ %.3f s ',dyn.state,trial(dyn.trialNumber).microstim_start);
        end
    end
    
%     if SETTINGS.AllowManualSkipping && mod(dyn.counterTimeSteps,100)
%         [keyIsDown,~,keyCode] = KbCheck;
%         if keyIsDown
%             if any(find(keyCode)==38) % up
%                 dyn.completed=1;
%                 success = true;
%                 dyn.force_trial_end=true;
%                 break;
%             elseif any(find(keyCode)==40) % down
%                 dyn.completed=1;
%                 success = true;
%                 success = false;
%                 dyn.force_trial_end=true;
%                 break;
%             elseif any(find(keyCode)==39) %right same as anz kez unfortunately
%                 dyn.completed=0;
%                 success = false;
%                 dyn.force_trial_end=true;
%                 break;
%             elseif any(find(keyCode)==37) %left
%                 dyn.completed=0;
%                 success = false;
%                 dyn.force_trial_end=true;
%                 break;
%             end
%         end
%     end
    
end

dyn.time_spent_in_state = GetSecs - tEnterState;
dyn.beh_markers = beh_markers;

function [success,dyn,task]  = hold_state(task,par_eye,par_hnd,dyn,trial,IO)
%%

global SETTINGS STATE

if trial(dyn.trialNumber).microstim && trial(dyn.trialNumber).microstim_state == dyn.state && trial(dyn.trialNumber).microstim_start < 0,
    % reference microstim to end of the state
    trial(dyn.trialNumber).microstim_start = dyn.duration + trial(dyn.trialNumber).microstim_start;
    trial(dyn.trialNumber).microstim_end = dyn.duration + trial(dyn.trialNumber).microstim_end;
    dyn.microstim_start = trial(dyn.trialNumber).microstim_start;
    dyn.microstim_end   = trial(dyn.trialNumber).microstim_end;
end

success = true;
offset_updated  = false;
vpx_calibrated  = false;

dyn.counterTimeSteps = 1;

tLeaveFixationEye   = 0;
tLeaveFixationHnd   = 0;

n_obj_eye = length(par_eye);
n_obj_hnd = length(par_hnd);

if SETTINGS.GUI
    tag_visible='';
    tag_invisible='';
    switch dyn.state
        case STATE.FIX_HOL
        case STATE.CUE_ON
            tag_visible='cue';
        case STATE.MEM_PER
            tag_invisible='cue';
        case STATE.TAR_HOL
        case STATE.TAR_HOL_INV
        case STATE.MAT_HOL_MSK
    end
    if n_obj_eye>0
        aux_make_targets_visible(['eye' tag_visible 'Size'])
        aux_make_targets_visible(['eye' tag_visible 'Radius'])
        aux_make_targets_visible(['eye' tag_visible 'n1'])
        aux_make_targets_invisible(['eye' tag_invisible 'Size'])
        aux_make_targets_invisible(['eye' tag_invisible 'Radius'])
        aux_make_targets_invisible(['eye' tag_invisible 'n1'])
    end
    if n_obj_hnd>0
        aux_make_targets_visible(['hnd' tag_visible 'Size'])
        aux_make_targets_visible(['hnd' tag_visible 'Radius'])
        aux_make_targets_visible(['hnd' tag_visible 'n1'])
        aux_make_targets_invisible(['hnd' tag_invisible 'Size'])
        aux_make_targets_invisible(['hnd' tag_invisible 'Radius'])
        aux_make_targets_invisible(['hnd' tag_invisible 'n1'])
    end
    drawnow;
end

for obj = 1:n_obj_hnd
    aux_PrepareStimuli(par_hnd(obj));
end

for obj = n_obj_eye:-1:1 % 1:n_obj_eye % to present fix spot on top of central cue 1:n_obj_eye %
    aux_PrepareStimuli(par_eye(obj));
end

start_obj_eye=1;
start_obj_hnd=1;
if dyn.state == STATE.CUE_ON || dyn.state == STATE.DEL_PER, % check for holding only for the fixation objects
    if n_obj_eye, n_obj_eye = 1; end
    if n_obj_hnd, n_obj_hnd = 1; end
end

if dyn.state == STATE.MAT_HOL || dyn.state == STATE.MAT_HOL_MSK, % check for holding only for the selected object
    if n_obj_eye, n_obj_eye = dyn.target_selected(1); start_obj_eye = dyn.target_selected(1); end
    if n_obj_hnd, n_obj_hnd = dyn.target_selected(2); start_obj_hnd = dyn.target_selected(2); end
end

% Behavioral markers: eye, hand, sen1, sen2, jaw, body
bm_eye = 1; bm_hnd = 2; bm_sen1 = 3; bm_sen2 = 4; bm_jaw = 5; bm_body = 6;
beh_markers = ones(1,6);

% 2014190: Aborting for dirty sensors
if task.effector > 0 && all(task.rest_hand) && isempty(dyn.hand_selected)
    success = false;
    beh_markers(bm_sen1) = false;
    beh_markers(bm_sen2) = false;
end

Screen(SETTINGS.window,'Flip');
send_to_TDT(IO,dyn.state);

tEnterState      = GetSecs;
dyn.states_onset = tEnterState - SETTINGS.time_start;

tPreviousEyeHandUpdate= 0;
tPreviousPulseDelivery = 0; % for microstim



while true
    tSample = GetSecs;
    [x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task);
    dyn.counterLine = dyn.counterLine+1;
    dyn.memoryBuffer(dyn.counterLine,:) = [tSample-SETTINGS.time_start,dyn.trialNumber,dyn.state,x_hnd,y_hnd,x_eye,y_eye,sen1,sen2,sen3,sen4];
    
    
    
    switch task.effector,
        case 0 % eye
            
            
            if touching
                
                disp('touched touchscreen in hold! - aborting');
                if SETTINGS.useSound && SETTINGS.TouchscreenSound
                    Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2); Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2);
                    disp('SETTINGS.TouchscreenSound')
                end
                success = false; % if out for long time, abort trial
                dyn.previousState = dyn.state;
                dyn.aborted_effector = 1;
                beh_markers(bm_hnd) = 0;
            end
            
            
            for obj = start_obj_eye:n_obj_eye %obj = dyn.target_selected(1) %obj = 1:n_obj_eye Change 20140519
                
                if ~aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    
                    if SETTINGS.allowBlinksOnly && ~aux_IsDisplacedDown(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius)
                        success = false; %  abort trial
                        dyn.previousState = dyn.state;
                        % dyn.state   = STATE.ABORT;
                        dyn.aborted_effector = 0;
                        beh_markers(bm_eye) = 0;
                    else 
                        if ~tLeaveFixationEye
                            tLeaveFixationEye = GetSecs;    % if just got out of fixation, initiate timer
                            if tSample - tEnterState < 0.5,
                                success = false; % if out for long time, abort trial
                                dyn.previousState = dyn.state;
                                dyn.aborted_effector = 0;
                                beh_markers(bm_eye) = 0;
                                %dyn.HTeye = round((tLeaveFixationEye-tEnterState)*1000);
                            end
                        elseif GetSecs - tLeaveFixationEye > task.timing.grace_time_eye
                            success = false; % if out for long time, abort trial
                            dyn.previousState = dyn.state;
                            dyn.aborted_effector = 0;
                            beh_markers(bm_eye) = 0;
                        end    
                    end
                    
                elseif aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    tLeaveFixationEye = 0;  % if inside, reset timer
                end
            end
            
            
        case {1} % hand
            
            for obj = start_obj_hnd:n_obj_hnd %obj = dyn.target_selected(2) % obj = 1:n_obj_hnd Change 20140519
                
                if ~aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    
                    if ~tLeaveFixationHnd
                        tLeaveFixationHnd = GetSecs;    % if just got out of fixation, initiate timer
                    elseif GetSecs - tLeaveFixationHnd > task.timing.grace_time_hand
                        success = false; % if out for long time, abort trial
                        dyn.previousState = dyn.state;
                        dyn.aborted_effector = 1;
                        beh_markers(bm_hnd) = 0;
                    end
                    
                elseif aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    tLeaveFixationHnd = 0;  % if inside, reset timer
                end
            end
            
            
        case {2,3,4,6} % both
            for obj = start_obj_eye:n_obj_eye
                
                if ~aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    
                    if SETTINGS.allowBlinksOnly && ~aux_IsDisplacedDown(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius)
                        success = false; %  abort trial
                        dyn.previousState = dyn.state;
                        % dyn.state   = STATE.ABORT;
                        dyn.aborted_effector = 0;
                        beh_markers(bm_eye) = 0;
                    else 
                        if ~tLeaveFixationEye
                            tLeaveFixationEye = GetSecs;    % if just got out of fixation, initiate timer
                        elseif GetSecs - tLeaveFixationEye > task.timing.grace_time_eye
                            success = false; % if out for long time, abort trial
                            dyn.previousState = dyn.state;
                            dyn.aborted_effector = 0;
                            beh_markers(bm_eye) = 0;
                            fprintf('eye aborted HT=%4d',round((tLeaveFixationEye-tEnterState)*1000));
                        end
                    end
                elseif aux_IsWithinRadius(x_eye, y_eye, par_eye(obj).deg.x, par_eye(obj).deg.y, par_eye(obj).deg.radius),
                    tLeaveFixationEye = 0;  % if inside, reset timer
                end
            end
            
            for obj = start_obj_hnd:n_obj_hnd
                
                if ~aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    
                    if ~tLeaveFixationHnd
                        tLeaveFixationHnd = GetSecs;    % if just got out of fixation, initiate timer
                    elseif GetSecs - tLeaveFixationHnd > task.timing.grace_time_hand
                        success = false; % if out for long time, abort trial
                        dyn.previousState = dyn.state;
                        dyn.aborted_effector = 1;
                        beh_markers(bm_hnd) = 0;
                        fprintf('hnd aborted HT=%4d',round((tLeaveFixationHnd-tEnterState)*1000));
                    end
                    
                elseif aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj).deg.x, par_hnd(obj).deg.y, par_hnd(obj).deg.radius),
                    tLeaveFixationHnd = 0;  % if inside, reset timer
                end
            end
            
            
    end % of switch effector
    
    if ~success, break, end;
    
    % update figure only every "SETTINGS.figure_drawing_interval"
    if SETTINGS.GUI && (tSample > tPreviousEyeHandUpdate + SETTINGS.figure_drawing_interval),
        tPreviousEyeHandUpdate = tSample;
        aux_DrawEyeHandPos(x_eye, y_eye, x_hnd, y_hnd, dyn, task);
    end
    
    if SETTINGS.check_motion_jaw || SETTINGS.check_motion_body
        is_moving = [~sen3 ~sen4];
        if ~(SETTINGS.allowMotionLate  && (dyn.state==STATE.TAR_HOL || dyn.state== STATE.TAR_HOL_INV)) % included by vlk 2.03.2018
         
            if is_moving(1) && SETTINGS.check_motion_jaw,
                success = false;
                dyn.previousState = dyn.state;
                beh_markers(bm_jaw) = 0;
                aux_MonkeyMoved('jaw');
                break;
            end
            if is_moving(2) && SETTINGS.check_motion_body,
                success = false;
                dyn.previousState = dyn.state;
                beh_markers(bm_body) = 0;
                aux_MonkeyMoved('body');
                break;
            end
        end    
    end
    
    if any(task.rest_hand)
        [holding_sensors_correctly holding_individual_sensors_correctly] = aux_CheckSensors(task,[sen1 sen2],trial,dyn);
        if ~holding_sensors_correctly, % monkey released one of the sensors, abort
            success = false;
            dyn.previousState = dyn.state;
            beh_markers(bm_sen1) = holding_individual_sensors_correctly(1);
            beh_markers(bm_sen2) = holding_individual_sensors_correctly(2);
            fprintf(' released sensor(s), aborting');
            break;
        end
    end
    
    % check keyboard or automatic update
    if SETTINGS.automatic_offset_update && ~offset_updated && dyn.state==STATE.FIX_HOL && GetSecs > tEnterState + 0.2        
        startfromsample=max(dyn.counterLine-100,1);
        x_eye_corr=mode(dyn.memoryBuffer(startfromsample:dyn.counterLine,6));
        y_eye_corr=mode(dyn.memoryBuffer(startfromsample:dyn.counterLine,7));
        fprintf(' Updating offsets %.2f %.2f', x_eye_corr, y_eye_corr );
        task.eye.offset_x = task.eye.offset_x + (par_eye(1).deg.x - x_eye_corr);
        task.eye.offset_y = task.eye.offset_y + (par_eye(1).deg.y - y_eye_corr);
        offset_updated=true;
        
    elseif dyn.state==STATE.FIX_HOL || dyn.state==STATE.FIX_ACQ       
        if dyn.state==STATE.FIX_HOL && SETTINGS.vpx_calibration && ~vpx_calibrated && GetSecs > tEnterState + dyn.duration/2
            vpx_SendCommandString(['calibration_snap',blanks(1),num2str(trial(dyn.trialNumber).vpx_calibration_point)]);
            vpx_calibrated=true;
        end        
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            if SETTINGS.vpx_calibration && any(find(keyCode)==119) % F9
                vpx_SendCommandString(['calibration_snap',blanks(1),num2str(trial(dyn.trialNumber).vpx_calibration_point)]);
            elseif any(find(keyCode)==115) % F4
                fprintf(' Updating offsets %.2f %.2f', x_eye, y_eye );
                task.eye.offset_x = task.eye.offset_x + (par_eye(1).deg.x - x_eye);
                task.eye.offset_y = task.eye.offset_y + (par_eye(1).deg.y - y_eye);
                
            end
            while KbCheck; end
        end
    end
    
    if GetSecs > tEnterState + dyn.duration    	% check time -> holding successful
        success = true;
        dyn.previousState = dyn.state;
        break
    end
    
    if trial(dyn.trialNumber).microstim && trial(dyn.trialNumber).microstim_state == dyn.state ...
            && (tSample > tEnterState + trial(dyn.trialNumber).microstim_start) && (tSample < tEnterState + trial(dyn.trialNumber).microstim_end),
        if tSample > tPreviousPulseDelivery + trial(dyn.trialNumber).microstim_interval,  % send pulse only every 1 sec
            tPreviousPulseDelivery = tSample;
            aux_produce_one_trigger(dyn);
%             fprintf(' microstim in %d @ %.3f s ',dyn.state,trial(dyn.trialNumber).microstim_start);
        end
    end
    %         WaitSecs('Untiltime',tEnterState+timeStep*counterTimeSteps); % maintain matlab sampling rate (constant num samples)
    WaitSecs('Untiltime',tSample+SETTINGS.timeStep); % maintain matlab sampling rate
    dyn.counterTimeSteps=dyn.counterTimeSteps+1;
    
    
    if SETTINGS.AllowManualSkipping && mod(dyn.counterTimeSteps,100)
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            if any(find(keyCode)==30) % space
                dyn.completed = 1;
                success = true;
                dyn.previousState = dyn.state;
                break;
            elseif any(find(keyCode)==39) %right
                dyn.completed = 1;
                success = true;
                dyn.previousState = dyn.state;
                break;
            elseif any(find(keyCode)==37) %left
                dyn.completed = 0;
                success = true;
                dyn.previousState = dyn.state;
                break;
             end
         end
     end
end
dyn.time_spent_in_state = GetSecs - tEnterState;
dyn.beh_markers = beh_markers;

function [success,dyn,task]  = ITI_state(task,dyn,IO)
global SETTINGS
Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
Screen(SETTINGS.window,'Flip');
send_to_TDT(IO,dyn.state);
dyn.states_onset = GetSecs - SETTINGS.time_start;
[success,dyn,task]=wait_while_recording_state(task,dyn);

if SETTINGS.GUI,
    set(0, 'currentfigure', dyn.GUI_fig_handle);
    cla;
    if SETTINGS.matlab_version(1)>=2014
        dyn.eye_position_handle = line(0,0,'Color','r','Marker','o','XlimInclude','off','YLimInclude','off');%'background');
        dyn.hnd_position_handle = line(0,0,'Color','g','Marker','o','XlimInclude','off','YLimInclude','off');%,'background');
    else
        dyn.eye_position_handle = line(-1000,-1000,'Color','r','Marker','o','XlimInclude','off','YLimInclude','off','EraseMode','xor');%'background');
        dyn.hnd_position_handle = line(-1000,-1000,'Color','g','Marker','o','XlimInclude','off','YLimInclude','off','EraseMode','xor');%,'background');
    end
   hold on; drawnow;%cla; % clear each trial
end

function [success,dyn,task,sen1,sen2] = wait_while_recording_state(task,dyn)
global SETTINGS STATE

dyn.counterTimeSteps = 1;

tEnterState      = GetSecs;
tPreviousEyeHandUpdate = 0;
while true
    tSample = GetSecs;
    
    [x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task);
    
    dyn.counterLine = dyn.counterLine+1;
    dyn.memoryBuffer(dyn.counterLine,:) = [tSample-SETTINGS.time_start,dyn.trialNumber,dyn.state,x_hnd,y_hnd,x_eye,y_eye,sen1,sen2,sen3,sen4];
    
    % update figure only every "SETTINGS.figure_drawing_interval"
    if SETTINGS.GUI && (tSample > tPreviousEyeHandUpdate + SETTINGS.figure_drawing_interval),
        tPreviousEyeHandUpdate = tSample;
        aux_DrawEyeHandPos(x_eye, y_eye, x_hnd, y_hnd, dyn, task);
    end
    
    if (dyn.state == STATE.ITI || dyn.state == STATE.INI_TRI) && KbCheck
        [~,~,keyCode,~] = KbCheck;
        if any(find(keyCode)==27) % Esc
            success = true;
            dyn.previousState = dyn.state;
            dyn.state   = STATE.CLOSE;
            sen1 =1;
            sen2 =1;
            %holding = -1;
            break
        end
    end
    
    if dyn.state == STATE.ITI && KbCheck                                 % check keyboard
        [~,~,keyCode,~] = KbCheck;
        ListenChar(0);
        
        if any(find(keyCode)==112) % F1
            prompt = {'x offset','y offset','x gain', 'y gain'};
            dlg_title = 'Calibration parameters';
            num_lines = 1;
            
            def = {num2str(task.eye.offset_x),num2str(task.eye.offset_y),num2str(task.eye.gain_x),num2str(task.eye.gain_y)};
            answer = MP_inputdlg(SETTINGS.matlab_version,prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                task.eye.offset_x=str2double(answer{1});
                task.eye.offset_y=str2double(answer{2});
                task.eye.gain_x=str2double(answer{3});
                task.eye.gain_y=str2double(answer{4});
            end
        end
        
        if any(find(keyCode)==113) % F2
            if SETTINGS.vpx_calibration
                prompt = {'override viewpoint calibration point'};
                dlg_title = 'View Point Calibration menu';
                num_lines = 1;
                def = {'0'};
                answer = MP_inputdlg(SETTINGS.matlab_version,prompt,dlg_title,num_lines,def);
                
                if ~isempty(answer)
                    task.overriding.positions=~str2double(answer{1})==0;
                    task.overriding.vpx_calibration_point=str2double(answer{1});
                    [x,y]=vpx_GetCalibrationStimulusPoint(str2double(answer{1}));
                    x_pix=x*SETTINGS.screenSize(3);
                    y_pix=y*SETTINGS.screenSize(4);
                    [x_deg, y_deg] = pix2deg_xy(x_pix, y_pix);
                    task.eye.fix.x=x_deg;
                    task.eye.fix.y=y_deg;
                    task.eye.tar(1).x=x_deg;
                    task.eye.tar(1).y=y_deg;
                end
                
            else
                prompt = {'override radius from custom conditions','fix radius','tar radius'};
                dlg_title = 'Parameters';
                num_lines = 1;
                
                def = {'0',num2str(task.eye.fix.radius),num2str(task.eye.tar(1).radius)};
                answer = MP_inputdlg(SETTINGS.matlab_version,prompt,dlg_title,num_lines,def);
                if ~isempty(answer)
                    task.overriding.radius=str2double(answer{1});
                    task.eye.fix.radius=str2double(answer{2});
                    task.eye.tar(1).radius=str2double(answer{3});
                    %task.eye.tar(2).radius=str2double(answer{3});
                end
            end
        end
        
        if any(find(keyCode)==114) % F3
            prompt = {'override positions','fixation point position x','fixation point position y', 'tar position x','tar position y'};
            dlg_title = 'Parameters';
            num_lines = 1;
            
            def = {'1',num2str(task.eye.fix.x),num2str(task.eye.fix.y),num2str(task.eye.tar(1).x),num2str(task.eye.tar(1).y)};
            answer = MP_inputdlg(SETTINGS.matlab_version,prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                task.overriding.positions=str2double(answer{1});
                task.eye.fix.x=str2double(answer{2});
                task.eye.fix.y=str2double(answer{3});
                task.eye.tar(1).x=str2double(answer{4});
                task.eye.tar(1).y=str2double(answer{5});
                drawnow;
            end
            
        end
        
        if any(find(keyCode)==116) % F5
            prompt = {'override type from custom conditions','task type','override effector from custom conditions','task effector',...
                'override reach hand from custom conditions or randomization','task reach hand','override reward from custom conditions','reward amount'};
            dlg_title = 'Parameters';
            num_lines = 1;
            
            def = {'0',num2str(task.type),'0',num2str(task.effector),'0',num2str(task.reach_hand),'0',num2str(task.reward.time_neutral)};
            answer = MP_inputdlg(SETTINGS.matlab_version,prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                task.overriding.type=str2double(answer{1});
                task.type=str2double(answer{2});
                task.overriding.effector=str2double(answer{3});
                task.effector=str2double(answer{4});
                task.overriding.reach_hand=str2double(answer{5});
                task.reach_hand=str2double(answer{6});
                task.overriding.reward=str2double(answer{7});
                task.reward.time_neutral=str2num(answer{8});
            end
            
        end
        
        if any(find(keyCode)==117) % F6
            prompt = {'override behavioral improvers from custom conditions','force previous target position if unsuccessful','provide extra reward if previously successful'};
            dlg_title = 'Behavioral improvers';
            num_lines = 1;
            
            def = {'0',num2str(task.force_target_location),num2str(task.extra_reward)};
            answer = MP_inputdlg(SETTINGS.matlab_version,prompt,dlg_title,num_lines,def);
            if ~isempty(answer)
                task.overriding.improvers=str2double(answer{1});
                task.force_target_location=str2double(answer{2});
                task.extra_reward=str2double(answer{3});
            end
        end
        ListenChar(2);
    end
    
    if task.overriding.positions==1
        task.force_target_location=0;
    end
    %         WaitSecs('Untiltime',tEnterState+timeStep*counterTimeSteps); % maintain matlab sampling rate (constant num samples)
    WaitSecs('Untiltime',tSample+SETTINGS.timeStep); % maintain matlab sampling rate % TODO
    dyn.counterTimeSteps=dyn.counterTimeSteps+1;
        
    if GetSecs > tEnterState + dyn.duration    	% check time
        success = true;
        break;
    end
end


%% Auxililary functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aux_draw_GUI_targets(dyn,trial,eff,pha,ang)
%global STATE
if ~dyn.(['n_' eff '_' pha])==0
    for obj=1:numel(trial(dyn.trialNumber).(eff).(pha))
        if isempty(trial(dyn.trialNumber).(eff).(pha)(obj).pos) % necessary, because the structure is there due to the reward modulation part (even if targets are not used).
            continue;
        end
        x=trial(dyn.trialNumber).(eff).(pha)(obj).pos(1);
        y=trial(dyn.trialNumber).(eff).(pha)(obj).pos(2);
        
        r1=trial(dyn.trialNumber).(eff).(pha)(obj).pos(3);
        r2=trial(dyn.trialNumber).(eff).(pha)(obj).pos(4);
        
        x1=r1*cos(ang);
        y1=r1*sin(ang);
        x2=r2*cos(ang);
        y2=r2*sin(ang);
        if isstruct(trial(dyn.trialNumber).(eff).(pha)(obj).shape) && ...
                strcmp(trial(dyn.trialNumber).(eff).(pha)(obj).shape.mode,'convex')
            obj_pointList=CalculateConvexPointList([0 0],r1,trial(dyn.trialNumber).(eff).(pha)(obj).shape.convexity,trial(dyn.trialNumber).(eff).(pha)(obj).shape.convex_side);
            pointList=[obj_pointList;obj_pointList(1,:)];
            x1=pointList(:,1)';
            y1=pointList(:,2)';
        end
        %% color!
        RGB_color=[255 0 0]/255;
        if strcmp(eff,'hnd')
           RGB_color=dyn.hnd_color/255;
        end
        if ismember(obj,dyn.correct_choice_target)
            plot(x,y,'*','color',[0 0 0],'Tag',[eff pha 'correct'],'Visible','off');
        end
        %RGB_color=nanmean([task.(eff).fix.color_bright],1)/255;
        plot(x+x1,y+y1,'color',RGB_color,'Tag',[eff pha 'Size'],'Visible','off');
        plot(x+x2,y+y2,'color',RGB_color,'linestyle',':','Tag',[eff pha 'Radius'],'Visible','off');        
    end
end

function aux_make_all_targets_invisible
for tags_invisible={'tar','fix','cue'}
    tag_invisible=tags_invisible{:};
    aux_make_targets_invisible(['eye' tag_invisible 'Size']);
    aux_make_targets_invisible(['eye' tag_invisible 'Radius']);
    aux_make_targets_invisible(['eye' tag_invisible 'correct']);
    aux_make_targets_invisible(['hnd' tag_invisible 'Size']);
    aux_make_targets_invisible(['hnd' tag_invisible 'Radius']);
    aux_make_targets_invisible(['hnd' tag_invisible 'correct']);
end
drawnow;

function aux_make_targets_visible(tags)
h = findobj('Tag',tags);
set(h,'Visible','on');

function aux_make_targets_invisible(tags)
h = findobj('Tag',tags);
set(h,'Visible','off');

function aux_DrawEyeHandPos(x_eye,y_eye,x_hnd,y_hnd, dyn, task)
% plot eye and hand position
global SETTINGS
if ~isnan(x_eye),
    set(dyn.eye_position_handle,'XData',x_eye,'YData',y_eye);
end
if ~isnan(x_hnd),
    set(dyn.hnd_position_handle,'XData',x_hnd,'YData',y_hnd);
end
if SETTINGS.matlab_version(1)>=2014
drawnow update
end

function [x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task)
global IO SETTINGS

if SETTINGS.useParallel
    sen = double(get_sensors_state(SETTINGS.pp,SETTINGS.sensor_pins));
    sen1 = sen(1);
    sen2 = sen(2);
    sen3 = sen(3);
    sen4 = sen(4);
    % this condition is not ideal, because it's rather setup specific than
    % dependent on the number of sensor pins. Sensor pins itself is
    % misleading because it only refers to parallel port
    if numel(SETTINGS.sensor_pins) > 4 % scanner DPZ with additional pin for scanner trigger
        sen3 = ~sen3; % sen(3) = 1 if jaw is moving, sen(3) = 0 if there is no jaw motion, sen(4) always 1 because no body motion detector connected
    end
else
    sen1 = 1;
    sen2 = 1;
    sen3 = 1;
    sen4 = 1;
end

if SETTINGS.ai
data = getsample(IO.ai);
else
data=NaN;
end

[x_eye y_eye] = aux_GetCalibratedEyePos(task);
[x_hnd y_hnd touching] = aux_GetCalibratedHndPos(data);


if SETTINGS.ai && strcmp(SETTINGS.Motion_detection_interface,'DAQ')
    sen3 = data(IO.jaw)  >= 5;
    sen4 = data(IO.body) >= 5;
end

function [x,y] = aux_GetCalibratedEyePos(task)
%% get raw eye position (from 0 to 1 in ViewPoint "camera field of view")
global SETTINGS

if SETTINGS.useVPacq
    [x,y]=vpx_GetGazePointSmoothed;
    x = task.eye.gain_x*x + task.eye.offset_x;
    y = task.eye.gain_y*y + task.eye.offset_y;
    % arcs
    x = atan(x*30/SETTINGS.vd*pi/180)*180/pi;
    y = atan(y*30/SETTINGS.vd*pi/180)*180/pi;
    % real angles (gain factor 0.5)
%     x = atan(x/SETTINGS.vd)*180/pi;
%     y = atan(y/SETTINGS.vd)*180/pi;
elseif SETTINGS.useViewAPI
    calllib(SETTINGS.ViewAPIlibrary, 'iV_GetSample', SETTINGS.pSampleData);
    Smp = libstruct('SampleStruct', SETTINGS.pSampleData);
    x = Smp.leftEye.gazeX*SETTINGS.screen_w_cm/SETTINGS.screen_w_pix;
    y = Smp.leftEye.gazeY*SETTINGS.screen_h_cm/SETTINGS.screen_h_pix;
    
    x = task.eye.gain_x*x + task.eye.offset_x;
    y = task.eye.gain_y*y + task.eye.offset_y;
    % arcs
    x = atan(x*30/SETTINGS.vd*pi/180)*180/pi;
    y = atan(y*30/SETTINGS.vd*pi/180)*180/pi;
elseif SETTINGS.useMouse
    %mouseposition = get(0,'PointerLocation');
    
    [a,b,~,~,valuators,~]=GetMouse(SETTINGS.window,1);
    mouseposition=[a -b];
    x_M=(mouseposition(1)-SETTINGS.screen_w_pix/2)*SETTINGS.screen_w_cm/SETTINGS.screen_w_pix;
    y_M=(mouseposition(2)+SETTINGS.screen_h_pix*(SETTINGS.screen_uh_cm)/SETTINGS.screen_h_cm)*SETTINGS.screen_h_cm/SETTINGS.screen_h_pix;
    %y_M=(mouseposition(2)-SETTINGS.screen_h_pix*(SETTINGS.screen_h_cm-SETTINGS.screen_uh_cm)/SETTINGS.screen_h_cm)*SETTINGS.screen_h_cm/SETTINGS.screen_h_pix;
    x = atan(x_M/task.vd)*180/pi;
    y = atan(y_M/task.vd)*180/pi;
    
else
    x = NaN;
    y = NaN;
end

function [x,y, touching] = aux_GetCalibratedHndPos(data)
%% get hand position (from 0 to 1)
global SETTINGS

if SETTINGS.touchscreen && SETTINGS.ai
    x = round(data(1)*SETTINGS.touchscreen_calibration.x_gain + SETTINGS.touchscreen_calibration.x_offset);
    y = round(data(2)*SETTINGS.touchscreen_calibration.y_gain + SETTINGS.touchscreen_calibration.y_offset);
    if data(1) < SETTINGS.touchscreen_calibration.x_threshold || data(2) < SETTINGS.touchscreen_calibration.y_threshold
        touching = false;
        x = nan;
        y = nan;
    else
        touching = true;
    end
    [x, y] = pix2deg_xy(x, y);
else
    x = NaN;
    y = NaN;
    touching = 0;
end

function is_within = aux_IsWithinRadius(x,y,x0,y0,r)
%% check if (x,y) is within radius r centered on (x0,y0)
is_within = 0;

if sqrt(((x0 - x))^2 + (y0 - y)^2) < r
    is_within = 1;
end

function is_down = aux_IsDisplacedDown(x,y,x0,y0,r)
%% check if (x,y) is within a rectangle of width 2*r, located below the point (x0,y0)
is_down = 0;

if abs(x0 - x) < r && y < y0 
    is_down = 1;
end

function [is_moving] = aux_GetMonkeyMotion
% now only used for initiate trial...
global IO SETTINGS
if strcmp(SETTINGS.Motion_detection_interface,'DAQ')
    data = getsample(IO.ai);
    is_moving_jaw = data(IO.jaw) < 5;
    is_moving_body = data(IO.body) < 5;
    is_moving = [is_moving_jaw is_moving_body];
else
    sen = double(get_sensors_state(SETTINGS.pp,SETTINGS.sensor_pins));
    if numel(SETTINGS.sensor_pins) > 4 % scanner DPZ with additional pin for scanner trigger
        is_moving = [sen(3) ~sen(4)]; % sen(3) = 1 if jaw is moving, sen(3) = 0 if there is no jaw motion, sen(4) always 1 because no body motion detector connected
    else
        is_moving = [~sen(3) ~sen(4)]; % setups
    end
end

function aux_MonkeyMoved(body_part)
global SETTINGS
disp([' ' body_part ' moved!']);
Screen(SETTINGS.window,'Flip');
if SETTINGS.useSound && SETTINGS.MonkeyMovedSound
    Beeper_PsychPortAudio(SETTINGS.audioPort,5000, 1, 0.2);
end
WaitSecs(1);

function [holding_sensors_correctly holding_individual_sensors_correctly] = aux_CheckSensors(task,sen,trial,dyn)

% construct sensor target matrix (what state sensors should be if behavior is correct) based on
%  task.reach_hand
%  task.rest_hand
%  task.effector

sen=sen(1:2);
tar_mat = task.rest_hand; % target matrix:
switch task.effector
    case {1,2,3,4,5,6} % reach is involved
        if trial(dyn.trialNumber).reach_hand==3, % either hand, decision between hands
            % Special case: here tar_mat is [0 1] or [1 0], because any of the sensors can be released but only one at the time
            holding_sensors_correctly = sum(sen)>0; % at least one sensor should be held
            holding_individual_sensors_correctly = [holding_sensors_correctly holding_sensors_correctly];
            % in case both sensors are released, both are designated "incorrect" in the hand decision case
        elseif trial(dyn.trialNumber).reach_hand==0, % stay condition
            holding_sensors_correctly = all(sen)>0; % both sensors should be held
            holding_individual_sensors_correctly = [holding_sensors_correctly holding_sensors_correctly];
            
        else %
            tar_mat(trial(dyn.trialNumber).reach_hand) = 0;
            holding_sensors_correctly = ~any((tar_mat-sen)>0);
            holding_individual_sensors_correctly = ~((tar_mat-sen)>0);
        end
        
    case 0 % saccade only
        holding_sensors_correctly = ~any((tar_mat-sen)>0);
        holding_individual_sensors_correctly = ~((tar_mat-sen)>0);
end


function rect = aux_pr2rect(pos,rad)
%% Creates PTB rect coordinates (x1,y1,x2,y2) from one or several points and corresponding radii.
% pos ([x y]' x n)
% rad (1 x n)

if isempty(pos) || isempty(rad)
    rect = [0 0 0 0];   % input check
    return
end
if numel(rad)==1
    rect = repmat(pos,2,1) + repmat([-1 -1 1 1]'*rad,1,size(pos,2));
% elseif numel(rad)== 4 %KK
%     rect = repmat(pos,2,1) +  [-1 -1 1 1]'.*rad';
else
    rect = repmat(pos,2,1) +  [-1 -1 1 1]'.*rad';
    %rect = repmat(pos,2,1) + [-1 -1 1 1]'*rad;
end

function [success,dyn,task]=aux_DispenseReward(task,dyn)
%% Makes monkey happy
global SETTINGS
if SETTINGS.useParallel
   pp=SETTINGS.pp;
    %io32(pp.ioObj,pp.address_out_reward,255);
    dyn.pp_reward_value=dyn.pp_reward_value+SETTINGS.pp.value_out_reward;
    io32(pp.ioObj,pp.address_out_reward,dyn.pp_reward_value); % open reward valve
    [success,dyn,task]=wait_while_recording_state(task,dyn);
    dyn.pp_reward_value=dyn.pp_reward_value-SETTINGS.pp.value_out_reward;
    io32(pp.ioObj,pp.address_out_reward,dyn.pp_reward_value);    % close reward valve
elseif SETTINGS.useSerial % use serial port instead of parallel port
    sp=SETTINGS.sp;
    set(sp,'DataTerminalReady','on');
    [success,dyn,task]=wait_while_recording_state(task,dyn);
    set(sp,'DataTerminalReady','off');
end
   

function par = aux_FillPar(shape,stim,stimColor,ringColor,rewardProb, ringColor2)
% stim positioning info comes here in deg

%global SETTINGS

if nargin < 4,
    ringColor = [];
end

if nargin < 5,
    rewardProb = 1;
end

if nargin < 6,
    ringColor2 = [0 0 0];
end

% keep the values in deg for experimenter GUI plotting
par.deg.x              = stim(1);
par.deg.y              = stim(2);
par.deg.size           = stim(3);
par.deg.radius         = stim(4);

% convert to pixels for PTB display
x_rad = stim(1)*pi/180;
y_rad = stim(2)*pi/180;
par.offset_deg = atan(sqrt(tan(x_rad)^2 + tan(y_rad)^2));
stim(3)= deg2pix_withOffset (stim(3),par.offset_deg);
stim(4)= deg2pix_withOffset (stim(3),par.offset_deg);

[stim(1) stim(2)] = deg2pix_xy(stim(1), stim(2));


% %%KK
par.pix.x              = stim(1);
par.pix.y              = stim(2);
par.pix.size           = stim(3);
% stim(3)= deg2pix(stim(3));
% stim(4)= deg2pix(stim(4));

par.stimRect       = aux_pr2rect([stim(1)  stim(2)]', stim(3));
par.x              = stim(1);
par.y              = stim(2);
par.stimColor      = stimColor;
par.size           = stim(3);
par.ringColor      = ringColor;
par.ringColor2     = ringColor2; % complementary arc for gambles
% par.radius         = stim(3);
% par.radius         = stim(3)/(SETTINGS.screen_h_pix);%*0.9);
par.arcAngle       = 360 - rewardProb*360;
par.effector       = stim(5);
par.shape          = shape;

function aux_PrepareStimuli(par)

global SETTINGS
if isstruct(par.shape)
    shape=par.shape.mode;
else
    shape=par.shape;
end
switch shape
    case 'convex'
        pointList=CalculateConvexPointList([par.x par.y],par.size,par.shape.convexity,par.shape.convex_side);
        isConvex = sign(par.shape.convexity)/2+0.5;
        Screen('FillPoly', SETTINGS.window,par.stimColor, pointList,isConvex);
    case 'bar_masked' %KK
        
        number_of_rects                 = 15;
        Screen('FillOval', SETTINGS.window, par.stimColor, par.stimRect);
        img = ones(20,100);
        texture = Screen('MakeTexture', SETTINGS.window, img);
        
        BarSizePix1= deg2pix_withOffset (par.shape.BarSize_L,par.offset_deg);
        BarSizePix2= deg2pix_withOffset (par.shape.BarSize_W,par.offset_deg);
        
        rectBar = [BarSizePix2 BarSizePix1 BarSizePix2 BarSizePix1];
        stimRect_Bar       = aux_pr2rect([par.x  par.y]', rectBar); 
        Screen('DrawTextures',SETTINGS.window, texture,[], stimRect_Bar, par.shape.rotation);      
       
        Msk_BarSizePix1= deg2pix_withOffset (par.shape.BarSize_L + 0.3 ,par.offset_deg);
        Msk_BarSizePix2= deg2pix_withOffset (par.shape.BarSize_W - 0.3,par.offset_deg);
        
        rectBar = [Msk_BarSizePix2 Msk_BarSizePix1 Msk_BarSizePix2 Msk_BarSizePix1];
        stimRect_Bar       = aux_pr2rect([par.x  par.y]', rectBar);
        rand_rect  = Shuffle(repmat([1,2,3],1,number_of_rects/3));
      
        c = 1;
       for n = 1:number_of_rects 
         if  rand_rect(n) == 3 
          par.shape.Msk_rotation1 = par.shape.rotation + randi([5,180]) ;
          Screen('DrawTextures',SETTINGS.window, texture,[], stimRect_Bar, par.shape.Msk_rotation1);
          elseif  rand_rect(n) == 1 
          Sign =  randi([-1,1]) ;
          Place =  randi([10,50]) ;
          Screen('DrawTextures',SETTINGS.window, texture,[], stimRect_Bar - Place*Sign, 0);
          elseif  rand_rect(n) == 2
          Sign =  randi([-1,1]) ;
          
          if c < 3
           Place =  randi([25,45]) ;

          elseif c > 3
           Place =  randi([45,55]) ;
          end
          c = c +1;
          Screen('DrawTextures',SETTINGS.window, texture,[], (stimRect_Bar - ([0 Place 0 Place  ]'*Sign)), 90);
       end
       end

    case 'circle_withBar'  %KK
        BarSizePix1= deg2pix_withOffset (par.shape.BarSize_L,par.offset_deg);
        BarSizePix2= deg2pix_withOffset (par.shape.BarSize_W,par.offset_deg);
        
        rectBar = [BarSizePix2 BarSizePix1 BarSizePix2 BarSizePix1];
        stimRect_Bar       = aux_pr2rect([par.x  par.y]', rectBar);
        
        Screen('FillOval', SETTINGS.window, par.stimColor, par.stimRect);
        img = ones(20,100);
        texture = Screen('MakeTexture', SETTINGS.window, img);
        Screen('DrawTextures',SETTINGS.window, texture,[], stimRect_Bar, par.shape.rotation);

    case 'circle'
        if size(par.stimColor,1)==2 %% hand selection targets, 20140603
            Screen('FillArc',SETTINGS.window,par.stimColor(1,:),par.stimRect,0,360)
            n_splits=6; %even number
            sectorangle=360/n_splits;
            for k=0:2:n_splits-2
                if mod(n_splits/2,2)==0
                    starting_angle=k*sectorangle;
                else
                    starting_angle=k*sectorangle+sectorangle/2;
                end
                Screen('FillArc',SETTINGS.window,par.stimColor(2,:),par.stimRect,starting_angle,sectorangle)
            end
        else
            Screen('FillOval', SETTINGS.window, par.stimColor, par.stimRect);
        end
    case 'square'
        Screen('FillRect', SETTINGS.window, par.stimColor, par.stimRect);
    case 'triangle';
        pointList=CalculateTrianglePointList([par.x par.y],par.size);
        Screen('FillPoly', SETTINGS.window,par.stimColor, pointList);
        
end


if ~isempty(par.ringColor)
    Screen('FrameOval', SETTINGS.window, par.ringColor, par.stimRect,7,7);
end

if par.arcAngle > 0,
    % cover part of the ring with black arc
    Screen('FrameArc', SETTINGS.window, par.ringColor2,par.stimRect,par.arcAngle,par.arcAngle,7,7);
    %Screen('FrameArc', SETTINGS.window, [128 128 128],par.stimRect,par.arcAngle,par.arcAngle,1,1);
    Screen('FrameArc', SETTINGS.window, [128 128 128],par.stimRect + [0;0;1;1],par.arcAngle,par.arcAngle,1,1);
end

function pointList=CalculateConvexPointList(center,a_ellipse,convexity,convex_sides)
convexity_sign=sign(convexity);
b_ellipse=abs(convexity)*a_ellipse;
b_ellipse_reference=0.2*a_ellipse;

steps_for_interpolation=100;
euclidian_distance=(-a_ellipse):2*a_ellipse/steps_for_interpolation:(a_ellipse);
%corner_positions=[-1,-1;1,-1;1,1;-1,1].*a_ellipse;

Half_circle_Area=a_ellipse^2*pi/2;
rect_b=(Half_circle_Area-a_ellipse*b_ellipse*pi*convexity_sign/2)/(2*a_ellipse);
rect_b_reference=(Half_circle_Area-a_ellipse*b_ellipse_reference*pi*convexity_sign/2)/(2*a_ellipse);
%rect_ratio=Half_circle_Area/(2*a_ellipse^2);

tmp_bow_parameter=sqrt((b_ellipse)^2.*(1-euclidian_distance'.^2/a_ellipse^2));
tmp_bow_reference=sqrt((b_ellipse_reference)^2.*(1-euclidian_distance'.^2/a_ellipse^2));

bow_vector=[euclidian_distance',(tmp_bow_parameter.*convexity_sign.*-1-rect_b)];
bow_vector_reference=[euclidian_distance',(tmp_bow_reference.*convexity_sign.*-1-rect_b_reference)];
         
if strcmp(convex_sides,'LR')|| strcmp(convex_sides,'R') || strcmp(convex_sides,'L')
   bow_vector=[bow_vector(:,2)*-1,bow_vector(:,1)];
   bow_vector_reference=[bow_vector_reference(:,2)*-1,bow_vector_reference(:,1)];
   %corner_positions=[corner_positions(:,1)*rect_ratio,corner_positions(:,2)];
else
   %corner_positions=[corner_positions(:,1),corner_positions(:,2)*rect_ratio];
end

switch convex_sides
    case 'T'       
        pointList=[bow_vector;bow_vector_reference*-1];
    case 'B'       
        pointList=[bow_vector_reference;bow_vector*-1];
    case 'TB'
        pointList=[bow_vector;bow_vector*-1];
    case 'R'       
        pointList=[bow_vector;bow_vector_reference*-1];
    case 'L'       
        pointList=[bow_vector_reference;bow_vector*-1];   
    case 'LR'
        pointList=[bow_vector;bow_vector*-1];
end
%Position_correction=[(max(pointList(:,1))+min(pointList(:,1)))/2,(max(pointList(:,2))+min(pointList(:,2)))/2];
%pointList=pointList+repmat(center-Position_correction,size(pointList,1),1);
pointList=pointList+repmat(center,size(pointList,1),1);

function pointList=CalculateTrianglePointList(center,side_length)
s=side_length*2;
h=sqrt(3)/2*s;
k=s.^2/(4*h)-h;
pointList(1,:) = center - [s/2 k];
pointList(2,:) = center - [-s/2 k];
pointList(3,:) = center - [0 k-h];

function condition = aux_SelectCondtion(conditions)
n_condition = randperm(size(conditions,1));
condition = conditions(n_condition(1),:);

function tPulseDelivery = aux_produce_one_trigger(dyn,pulse_duration)
global IO
global SETTINGS
if nargin < 3,
    pulse_duration = 0.005;
end

if strcmp(SETTINGS.microstim_interface,'DAQ') % microstim as analog output
    
    % fprintf(' microstim pulse ');
    putsample(IO.ao,5);
    tPulseDelivery = GetSecs;
    WaitSecs(pulse_duration);
    putsample(IO.ao,0);
    
else % microstim as digital output through parallel port
    dyn.pp_reward_value=dyn.pp_reward_value+SETTINGS.pp.value_out_microstim;
    io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_reward,dyn.pp_reward_value); % send microstim trigger/pulse
    tPulseDelivery = GetSecs;
    io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_reward,dyn.pp_reward_value-SETTINGS.pp.value_out_microstim); % stop microstim trigger/pulse
end

function send_to_TDT(IO,state)
global SETTINGS
if  SETTINGS.use_digital_to_TDT  %%% digital state information output to recording system for synchronization TDT
    %     while true % for triggering the digital output
    %         n_bit=5;
    %         datum = io32(SETTINGS.pp.ioObj,pp.address_inp);
    %         trigger_on=bitget(uint8(datum),n_bit);
    %         if trigger_on
    %             io32(SETTINGS.pp.ioObj,pp.address_out_reward,8);
    %             break
    %         end
    %     end
    if strcmp(SETTINGS.TDT_interface,'DAQ')
        putvalue(IO.do,state);
    elseif strcmp(SETTINGS.TDT_interface,'Parallel') && SETTINGS.useParallel
        io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_TDT,state); 
    end
end

function send_trialinfo_to_TDT(IO,dyn,fileNumber)
global SETTINGS
if  SETTINGS.use_digital_to_TDT  %%% digital state information output to recording system for synchronization TDT
    %     while true % for triggering the digital output
    %         n_bit=5;
    %         datum = io32(SETTINGS.pp.ioObj,pp.address_inp);
    %         trigger_on=bitget(uint8(datum),n_bit);
    %         if trigger_on
    %             io32(SETTINGS.pp.ioObj,pp.address_out_reward,8);
    %             break
    %         end
    %     end
    
    date_to_send=clock;
    date_to_send(1)=mod(date_to_send(1),100);
    trialNumberpart1=floor(dyn.trialNumber/100);
    trialNumberpart2=mod(dyn.trialNumber,100);
    run_to_send=fileNumber;
    
    SETTINGS.stopper_INI_trial=252;
    SETTINGS.stopper_end_trial=253;
    SETTINGS.stopper_no_change=254;
    SETTINGS.stopper_INI_states=255;
    pulseduration=0.001;
    
    stopper_control=0;
    send_to_TDT(IO,SETTINGS.stopper_INI_trial);
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,date_to_send(1));
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,date_to_send(2));
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,date_to_send(3));
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,date_to_send(4));
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,date_to_send(5));
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,date_to_send(6));
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,run_to_send);
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,trialNumberpart1);
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    send_to_TDT(IO,trialNumberpart2);
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_no_change);
    WaitSecs(pulseduration);
    for idx_classifier=1:numel(dyn.trial_classifier)
        send_to_TDT(IO, dyn.trial_classifier(idx_classifier));
        WaitSecs(pulseduration);
        send_to_TDT(IO,SETTINGS.stopper_no_change);
        WaitSecs(pulseduration);
    end
    send_to_TDT(IO,SETTINGS.stopper_end_trial);
    WaitSecs(pulseduration);
    send_to_TDT(IO,stopper_control); % to control if digital connections are working: all off, all on
    WaitSecs(pulseduration);
    send_to_TDT(IO,SETTINGS.stopper_INI_states);
    WaitSecs(pulseduration);
    send_to_TDT(IO,dyn.state);
    WaitSecs(pulseduration);
end

function Beeper_PsychPortAudio(pahandle, frequency, fVolume, durationSec)
% function Beeper(frequency, [fVolume], [durationSec]);
%
% Play a beep sound.  Default is 400 Hz for .15 sec.
% frequency can be a number, or else the string 'high', 'med', or 'low'.
%
% fVolume - normalized to range of 0 - 1.  Default is 0.4;
% Warning:  1 is the maximum volume and is often very loud!
%
% Funny name is because Matlab 6 contains a built-in function called "beep".
%
% 2006-02-15 - cburns
%   -   Added fVolume param
%   -   Swapped parameter order
%
% 2006-02-02 - cburns
%   -   Scaled down the volume of the sound to match the system volume better.  It was at maximum volume.
%       Would scare you enough to rip the bite bar off it's mount!
%       And switched to useing the sound() function, instead of the soundsc() function
%       which, by default, maximizes the volume.
%   -   Update, using the PsychToolbox Snd function which should return immediately.
%       Were experiencing delays with sound function
%
% 12/2/00 Backus - original version

if ~exist('frequency', 'var')
    frequency = 400;
end

if ~exist('durationSec', 'var')
    durationSec = 0.15;
end

if ~exist('fVolume', 'var')
    fVolume = 0.4;
else
    % Clamp if necessary
    if (fVolume > 1.0)
        fVolume = 1.0;
    elseif (fVolume < 0)
        fVolume = 0;
    end
end

if ischar(frequency)
    if strcmpi(frequency, 'high'); frequency = 1000;
    elseif strcmpi(frequency, 'med'); frequency = 400;
    elseif strcmpi(frequency, 'medium'); frequency = 400;
    elseif strcmpi(frequency, 'low'); frequency = 220;
    end
end

sampleRate = 8192;

nSample = sampleRate*durationSec;
soundVec = sin(2*pi*frequency*(1:nSample)/sampleRate);

% Scale down the volume
soundVec = soundVec * fVolume;

[~, ~, ~] = PsychPortAudio('FillBuffer', pahandle, [soundVec;soundVec]);
PsychPortAudio('Start', pahandle);

function combine_trials_from_single_matfiles(folder,subfolder)
global SETTINGS

subfolder_dir=dir([folder filesep subfolder filesep '*_*.mat']); % checking only for mat files in the specified subfolder
subfolder_content={subfolder_dir.name};
subfolder_content=sort(subfolder_content);

for file_index=1:numel(subfolder_content)
    load([folder filesep subfolder filesep subfolder_content{file_index}]);
    if file_index==numel(subfolder_content) && (~isfield(current_trial,'state') || isempty(current_trial.state))
        break;
    end
    trial(file_index)=current_trial;
end

if exist('trial','var')
    save([folder filesep subfolder],'SETTINGS','task','trial','sequence_indexes');
end
rmdir([folder filesep subfolder],'s');
% saving to the server as well !
if ~isdir([SETTINGS.dag_drive folder(3:end)]) % ~isdir([SETTINGS.dag_drive filesep 'dag' folder(3:end)])
    mkdir([SETTINGS.dag_drive folder(3:end-8)],folder(end-7:end))% mkdir([SETTINGS.dag_drive filesep 'dag'  folder(3:end-8)],folder(end-7:end)    
end
if exist('trial','var')
    save([SETTINGS.dag_drive folder(3:end) filesep subfolder],'SETTINGS','task','trial','sequence_indexes'); % save([SETTINGS.dag_drive filesep 'dag'  folder(3:end) filesep subfolder],'SETTINGS','task','trial','sequence_indexes');
end

function autosave_changed_monkeypsych
global SETTINGS
%current_version=SETTINGS.version;
fullpath = [mfilename('fullpath') '.m'];
folder_idx=strfind(fullpath,filesep);
path = fullpath(1:folder_idx(end));
if exist([path 'last_used_version.mat'],'file')
    load([path 'last_used_version.mat']);
else
    mp_version='';
end
if ~strcmp(SETTINGS.version,mp_version)
    mp_version=SETTINGS.version;
    save([path filesep 'last_used_version.mat'],'mp_version');
    if ~exist([path filesep 'all_monkeypsych_versions'],'dir')
       mkdir(path,'all_monkeypsych_versions') 
    end
    copyfile(fullpath,[path filesep 'all_monkeypsych_versions' filesep SETTINGS.version '.m']);
end













