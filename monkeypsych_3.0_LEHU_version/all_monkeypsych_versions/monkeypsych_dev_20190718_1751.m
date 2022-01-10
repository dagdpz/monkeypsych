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

% 20190620 Substantial restructuring of aux_FillPar, and how stimuli get defined, reward modulation rework,
%           Removal of task.condition_file, SETTINGS.BASE_PATH, and several unnecessary fields
%
%           This changes subfunctions and external functions: get_touch, setup_pp, get_sensors_state, TouchDemo, CalibrateTouchScreen, reward_pump_calibration,
% TODO list
% implement reward modulation for eye targets
% make function copy_fields_with_exceptions for copying e.g. tar to cue
% thinks about updating offsets - when and how to record it
% reward modulation for all effector conditions
% dissociated memory tasks
close all;
Priority(2);

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
[task monkey_name DATA_PATH]  = get_monkey_dev(monkey);
SETTINGS.vd         = task.vd;
sequence_indexes    = 0;

% conditions      = read_conditions([SETTINGS.BASE_PATH task.condition_file]);
% task.conditions = conditions;
session_folder  = datestr(date,30);
session_folder  = session_folder(1:8);
%DATA_PATH       = [SETTINGS.BASE_PATH '\Data\' monkey];
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
    eye_offset_x=0;eye_offset_y=0;eye_gain_x=1;eye_gain_y=1;
end
task.eye.offset_x = eye_offset_x;
task.eye.offset_y = eye_offset_y;
task.eye.gain_x   = eye_gain_x;
task.eye.gain_y   = eye_gain_y;

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
if  SETTINGS.useSound && strcmp(SETTINGS.SoundType, 'Beep')
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
[SETTINGS.window, SETTINGS.screenSize] = Screen(SETTINGS.whichScreen, 'Openwindow', [ ],[],[],[],[],SETTINGS.AntiAlisingValue); % 3     % put 'window' on complete screen
Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR); % fill whole screen black
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
STATE.CUE_ON_AUDITIV                = 22; % cue on
STATE.TA2_ACQ                       = 23; % cue on
STATE.TA2_HOL                       = 24; % cue on
STATE.FI2_ACQ                       = 25; % cue on
STATE.FI2_HOL                       = 26; % cue on
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
    switch task.effector
        case {0,3}
            dyn.effector='eye';
        case {1,2,4,5,6}
            dyn.effector='hnd';
    end
    displaybackground(SETTINGS,task,dyn)
    par_temp=task.eye.fix;
    par_temp.color=par_temp.color_bright;
    par_temp.pos=[par_temp.x par_temp.y par_temp.size  par_temp.radius 1];
    par = aux_FillPar(par_temp);
    aux_PrepareStimuli(par);
    Screen(SETTINGS.window,'Flip');
    
    switch SETTINGS.interface_with_scanner
        
        case 1 % UMG
            %pause;
            ScannerStarted = false;
            while ScannerStarted  == false
                [pressed,~,keyCode] = KbCheck;
                if pressed
                    %if find(keyCode) ==  57 || find(keyCode) ==  53
                    if find(keyCode) ==  double('9')
                        ScannerStarted = true;
                    end
                end
            end
            
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

ListenChar(2);
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
            dyn.target2_selected            = [NaN NaN]; % first eye, second hand
            dyn.eye_targets_inspected       = NaN; % for M2S exploration tasks
            dyn.hand_targets_inspected      = NaN; % for M2S exploration tasks
            dyn.n_target_inspected          = 0;    % for M2S exploration tasks
            dyn.time_spent_exploring        = 0; % for M2S exploration tasks
            dyn.cues_presented              = 0;
            dyn.stay_condition              = 0; % for Poffenberger
            dyn.abort_code                  = 'NO ABORT';
            dyn.completed                   = 0;
            dyn.tar_struct                  = 'tar'  ; %KK
            dyn.fix_struct                  = 'fix'  ; %KK
            dyn.cue_color                   = [NaN NaN NaN]; %MP for bexter task
            %
            %             task.eye.fix.radiusShape='circle';
            %             task.hnd.fix.radiusShape='circle';
            %             task.eye.tar(1).radiusShape='circle';
            %             task.hnd.tar(1).radiusShape='circle';
            %             task.eye.tar(2).radiusShape='circle';
            %             task.hnd.tar(2).radiusShape='circle';
            %             task.eye.cue(1).radiusShape='circle';
            %             task.hnd.cue(1).radiusShape='circle';
            %             task.eye.cue(2).radiusShape='circle';
            %             task.hnd.cue(2).radiusShape='circle';
            %
            %             task.eye.cue(1).ringColor=[];
            %             task.eye.tar(1).ringColor=[];
            %             task.hnd.cue(1).ringColor=[];
            %             task.hnd.tar(1).ringColor=[];
            
            
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
                trial(dyn.trialNumber).microstim_interval   = task.microstim.interval;
                % select in which state microstim
                microstim_state_idx = randsample(length(task.microstim.state),1);
                trial(dyn.trialNumber).microstim_state =  task.microstim.state(microstim_state_idx);
                % select timing
                microstim_timing_idx = randsample(length(task.microstim.start{microstim_state_idx}),1);
                trial(dyn.trialNumber).microstim_start      = task.microstim.start{microstim_state_idx}(microstim_timing_idx);
                trial(dyn.trialNumber).microstim_end        = task.microstim.end{microstim_state_idx}(microstim_timing_idx);
                
                fprintf(' microstim in %d @ %.3f-%.3f s ',trial(dyn.trialNumber).microstim_state,trial(dyn.trialNumber).microstim_start,trial(dyn.trialNumber).microstim_end);
            else
                trial(dyn.trialNumber).microstim_interval   = NaN;
                trial(dyn.trialNumber).microstim_state      = NaN;
                trial(dyn.trialNumber).microstim_start      = NaN;
                trial(dyn.trialNumber).microstim_end        = NaN;
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
                %task.condition                  = manual_inputs.condition ;
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
            trial(dyn.trialNumber).CueAuditiv           = task.CueAuditiv;
            
            %% Assign reward values to targets in this trial... this we will remove
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
            
            
            if task.force_target_location, % force the location of the movement target
                if dyn.trialNumber > 1,
                    if ~trial(dyn.trialNumber-1).success
                        trial(dyn.trialNumber).eye = trial(dyn.trialNumber-1).eye;
                        trial(dyn.trialNumber).hnd = trial(dyn.trialNumber-1).hnd;
                    end
                end
            end
            
            if isfield(task,'rings_only_on_cues') && task.rings_only_on_cues==1 % for cuing reward only on the cues, especially for M2S task
                [task.hnd.tar.ringColor]         = deal([]);
                [task.hnd.tar.ringColor2]        = deal([]);
                [task.eye.tar.ringColor]         = deal([]);
                [task.eye.tar.ringColor2]        = deal([]);
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
            
            %MP, shuffle cue color for bexter task
            %             if task.type == 11
            %                 rand_colors = rand(1);
            %                 if rand_colors < 0.66
            %                     [task.hnd.cue.color_dim]    = deal(task.hnd_right.color_cue_dim);
            %                 else
            %                     [task.hnd.cue.color_dim]    = deal(task.hnd_left.color_cue_dim);
            %                 end
            %                 dyn.cue_color = [task.hnd.cue.color_dim];
            %             end
            
            task.eye.fix.pos=[task.eye.fix.x task.eye.fix.y task.eye.fix.size task.eye.fix.radius 1]; %% legacy for analysis
            task.hnd.fix.pos=[task.hnd.fix.x task.hnd.fix.y task.hnd.fix.size task.hnd.fix.radius 1]; %% legacy for analysis
%             task.eye.fi2.pos=[task.eye.fi2.x task.eye.fi2.y task.eye.fi2.size task.eye.fi2.radius 1]; %% legacy for analysis
%             task.hnd.fi2.pos=[task.hnd.fi2.x task.hnd.fi2.y task.hnd.fi2.size task.hnd.fi2.radius 1]; %% legacy for analysis
                
            trial(dyn.trialNumber).eye.fix = task.eye.fix;
            trial(dyn.trialNumber).hnd.fix = task.hnd.fix;
            trial(dyn.trialNumber).eye.fi2 = task.eye.fi2;
            trial(dyn.trialNumber).hnd.fi2 = task.hnd.fi2;
            
            %% Number of targets and cues assignment (especially for CHOICE AND EFFECTORS!)
            dyn.n_eye_tar=numel(task.eye.tar);
            dyn.n_eye_ta2=numel(task.eye.ta2);
            dyn.n_eye_cue=numel(task.eye.cue);
            dyn.n_eye_cuA=numel(task.eye.cuA);
            dyn.n_eye_fix=numel(task.eye.fix);
            dyn.n_eye_fi2=numel(task.eye.fi2);
            dyn.n_hnd_tar=numel(task.hnd.tar);
            dyn.n_hnd_ta2=numel(task.hnd.ta2);
            dyn.n_hnd_cue=numel(task.hnd.cue);
            %dyn.n_hnd_cuA=numel(task.hnd.cuA);
            dyn.n_hnd_fix=numel(task.hnd.fix);
            dyn.n_hnd_fi2=numel(task.hnd.fi2);
            
            if task.type<5 || task.type>=10 %% basically this is only for Lukas match to sample task
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
                    dyn.n_hnd_tar = 0;
                    dyn.n_hnd_cue = 0;
                    dyn.n_hnd_fix = 0;
                    dyn.tar_selected_ind = 1;
                    dyn.ta2_selected_ind = 1;
                    dyn.effector  = 'eye';
                    
                case 1 % free gaze reach
                    dyn.n_eye_tar = 0;
                    dyn.n_eye_cue = 0;
                    dyn.n_eye_fix = 0;
                    dyn.tar_selected_ind = 2;
                    dyn.ta2_selected_ind = 2;
                    dyn.effector  = 'hnd';
                    
                case 2 % joint movement eye and hand
                    dyn.tar_selected_ind = 1;
                    dyn.effector = 'eye';
                    
                case 3 % dissociated saccade
                    dyn.n_hnd_tar = 1; % fixation spot counts as target
                    dyn.n_hnd_cue = 0;
                    dyn.tar_selected_ind = 1;
                    dyn.effector  = 'eye';
                    
                case 4 % dissociated reach
                    dyn.n_eye_tar = 1; % fixation spot counts as target
                    dyn.n_eye_cue = 0;
                    dyn.tar_selected_ind = 2;
                    dyn.effector  = 'hnd';
                    
                case 6 % free gaze reach with initial eye fixation
                    dyn.n_eye_tar=0; % not even fixation spot in target acquisition
                    dyn.n_eye_cue=0;
                    dyn.n_eye_cue=0;
                    dyn.tar_selected_ind = 2;
                    dyn.ta2_selected_ind = 2;
                    dyn.effector = 'hnd';
            end
            
            %%% super annoying part, no reward modulation
            if ~task.reward_modulation
                trial(dyn.trialNumber).reward_size = 2;
                for n_obj=1:dyn.n_eye_tar % assign values for each target
                    task.eye.tar(n_obj).reward         = 2;
                    task.eye.tar(n_obj).reward_time    = task.reward.time_neutral;
                    task.eye.tar(n_obj).reward_prob    = task.reward.prob_neutral;
                end
                for n_obj=1:dyn.n_hnd_tar % assign values for each target
                    task.hnd.tar(n_obj).reward         = 2;
                    task.hnd.tar(n_obj).reward_time    = task.reward.time_neutral;
                    task.hnd.tar(n_obj).reward_prob    = task.reward.prob_neutral;
                end
            end
            
            %% assign task to current trial (redundant? NO, becasue n_targets and n_cues are limited here!)
            %% dim color set to bright fixation color for dissociated tasks...
            %% target structure for fixation effector in dissociated tasks taken over from fix !
            for n_obj=1:dyn.n_eye_tar
                task.eye.tar(n_obj).pos=[task.eye.tar(n_obj).x task.eye.tar(n_obj).y task.eye.tar(n_obj).size task.eye.tar(n_obj).radius 1]; %% legacy for analysis
                trial(dyn.trialNumber).eye.tar(n_obj) = task.eye.tar(n_obj);
                if task.effector==4
                    trial(dyn.trialNumber).eye.tar= task.eye.fix;
                    trial(dyn.trialNumber).eye.tar(n_obj).color_dim = task.eye.fix(1).color_bright;
                end
            end
            for n_obj=1:dyn.n_hnd_tar
                task.hnd.tar(n_obj).pos=[task.hnd.tar(n_obj).x task.hnd.tar(n_obj).y task.hnd.tar(n_obj).size task.hnd.tar(n_obj).radius 2]; %% legacy for analysis
                trial(dyn.trialNumber).hnd.tar(n_obj) = task.hnd.tar(n_obj);
                if task.effector==3
                    trial(dyn.trialNumber).hnd.tar = task.hnd.fix;
                    trial(dyn.trialNumber).hnd.tar(n_obj).color_dim = task.hnd.fix(1).color_bright;
                end
            end
            for n_obj=1:dyn.n_eye_ta2
                task.eye.ta2(n_obj).pos=[task.eye.ta2(n_obj).x task.eye.ta2(n_obj).y task.eye.ta2(n_obj).size task.eye.ta2(n_obj).radius 1]; %% legacy for analysis
                trial(dyn.trialNumber).eye.ta2(n_obj) = task.eye.ta2(n_obj);
                if task.effector==4
                    trial(dyn.trialNumber).eye.ta2 = task.eye.fix;
                    trial(dyn.trialNumber).eye.ta2(n_obj).color_dim = task.eye.fix(1).color_bright;
                end
            end
            for n_obj=1:dyn.n_hnd_ta2
                task.hnd.ta2(n_obj).pos=[task.hnd.ta2(n_obj).x task.hnd.ta2(n_obj).y task.hnd.ta2(n_obj).size task.hnd.ta2(n_obj).radius 2]; %% legacy for analysis
                trial(dyn.trialNumber).hnd.ta2(n_obj) = task.hnd.ta2(n_obj);
                if task.effector==3
                    trial(dyn.trialNumber).hnd.ta2 = task.hnd.fix;
                    trial(dyn.trialNumber).hnd.ta2(n_obj).color_dim = task.hnd.fix(1).color_bright;
                end
            end
            for n_obj=1:dyn.n_eye_cue
                task.eye.cue(n_obj).pos=[task.eye.cue(n_obj).x task.eye.cue(n_obj).y task.eye.cue(n_obj).size task.eye.cue(n_obj).radius 1]; %% legacy for analysis
                trial(dyn.trialNumber).eye.cue(n_obj) = task.eye.cue(n_obj);
            end
            for n_obj=1:dyn.n_hnd_cue
                task.hnd.cue(n_obj).pos=[task.hnd.cue(n_obj).x task.hnd.cue(n_obj).y task.hnd.cue(n_obj).size task.hnd.cue(n_obj).radius 2]; %% legacy for analysis
                trial(dyn.trialNumber).hnd.cue(n_obj) = task.hnd.cue(n_obj);
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
                    [success,dyn,task,sen1,sen2]=wait_while_recording_state(task,dyn);
                    
                    holding_individual_sensors_correctly = [~((task.rest_hand-[sen1 sen2])>0)]; % see aux_CheckSensors
                    if ~all(holding_individual_sensors_correctly),
                        sensors_ini_correct_time=-Inf;
                        n_ini=1;
                    else
                        n_ini=2;
                    end
                    if SETTINGS.VisFeedback_rest_hand
                        par_temp=task.hnd.ini(n_ini);
                        %par_temp.pos=[task.hnd.ini(n_ini).x,task.hnd.ini(n_ini).y,task.hnd.ini(n_ini).size,0,0];
                        
                        displaybackground(SETTINGS,task,dyn)
                        par_hnd = aux_FillPar(par_temp);
                        aux_PrepareStimuli(par_hnd);
                        Screen(SETTINGS.window,'Flip');
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
                                if task.timing.reward_time_sensors>0
                                    dyn.duration = task.timing.reward_time_sensors;
                                    [success,dyn,task]=aux_DispenseReward(task,dyn);
                                end
                                break;
                            end
                            
                    end
                    if mod(wait4sensors_iteration,2*(1/dyn.duration)) == 2*(1/dyn.duration)-1 %start new trial after X time
                        Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
                        displaybackground(SETTINGS,task,dyn)
                        if strcmp(mat2str(double(holding_individual_sensors_correctly)),'[1 1]')
                            n_ini = 2;
                        else
                            n_ini = 1;
                        end
                        if SETTINGS.VisFeedback_rest_hand
                            par_temp=task.hnd.ini(n_ini);
                            %par_temp.pos=[task.hnd.ini(n_ini).x,task.hnd.ini(n_ini).y,task.hnd.ini(n_ini).size,0,0];
                            par_hnd = aux_FillPar(par_temp);
                            aux_PrepareStimuli(par_hnd);
                        end
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
                aux_draw_GUI_targets(dyn,trial,'eye','fi2',ang)
                aux_draw_GUI_targets(dyn,trial,'eye','tar',ang)
                aux_draw_GUI_targets(dyn,trial,'eye','ta2',ang)
                aux_draw_GUI_targets(dyn,trial,'eye','cue',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','fix',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','fi2',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','tar',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','ta2',ang)
                aux_draw_GUI_targets(dyn,trial,'hnd','cue',ang)
                if any(~isnan(task.hnd.fix.color_bright))
                    set(dyn.hnd_position_handle,'Color',nanmean([task.hnd.fix.color_bright],1)/255);
                end
            end
            
            if SETTINGS.useSound && SETTINGS.FixationAcquisitionSound
                Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2); Beeper_PsychPortAudio(SETTINGS.audioPort,4000, 1, 0.2);
            end
            
        case STATE.FIX_ACQ  % fixation acquisition
            if dyn.n_eye_fix==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix==0;par_hnd = struct([]);end;
            
            for n_obj=1:dyn.n_eye_fix
                par_temp=trial(dyn.trialNumber).eye.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fix(n_obj).color_dim;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_temp=trial(dyn.trialNumber).hnd.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fix(n_obj).color_dim;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            
            temp_effector = task.effector;
            if ismember(task.effector,[2,3,4,6])
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
                par_temp=trial(dyn.trialNumber).eye.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fix(n_obj).color_bright;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_temp=trial(dyn.trialNumber).hnd.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fix(n_obj).color_bright;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            if task.type > 1,
                dyn.target_selected = [NaN NaN];
            end
            
        case STATE.FI2_ACQ  % fixation acquisition
            dyn.target_selected = [NaN NaN];
            dyn.fix_struct = 'fi2';
            if dyn.n_eye_fi2==0;par_eye = struct([]);end;
            if dyn.n_hnd_fi2==0;par_hnd = struct([]);end;
            
            for n_obj=1:dyn.n_eye_fi2
                par_temp=trial(dyn.trialNumber).eye.fi2(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fi2(n_obj).color_dim;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fi2
                par_temp=trial(dyn.trialNumber).hnd.fi2(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fi2(n_obj).color_dim;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            
            temp_effector = task.effector;
            if ismember(task.effector,[2,3,4,6])
                task.effector = 2;
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            
            task.effector = temp_effector;
            trial(dyn.trialNumber).reach_hand = dyn.hand_selected;
            
            
        case STATE.FI2_HOL %  fixation holding_with_change_of_color
            dyn.fix_struct = 'fi2';
            if dyn.n_eye_fi2==0;par_eye = struct([]);end;
            if dyn.n_hnd_fi2==0;par_hnd = struct([]);end;
            for n_obj=1:dyn.n_eye_fi2
                par_temp=trial(dyn.trialNumber).eye.fi2(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fi2(n_obj).color_bright;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fi2
                par_temp=trial(dyn.trialNumber).hnd.fi2(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fi2(n_obj).color_bright;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            if task.type > 1,
                dyn.target_selected = [NaN NaN];
            end
            %dyn.target_selected = Temp;
            %                 if success
            %                     dyn.duration = task.reward_time_fix2;
            %                     [success,dyn,task]=aux_DispenseReward(task,dyn);
            %                 elseif success == 0
            %
            %
            %                 end
        case STATE.FIX_PER %  fixation holding after cue state, and return to cue state!! IGNORE FOR NOW
            switch trial(dyn.trialNumber).effector
                case {0,5}
                    par_temp = trial(dyn.trialNumber).eye.fix;
                    par_temp.color = trial(dyn.trialNumber).eye.fix.color_bright;
                    par_eye = aux_FillPar(par_temp);
                    par_hnd = struct([]);
                case 1
                    par_temp = trial(dyn.trialNumber).hnd.fix;
                    par_temp.color = trial(dyn.trialNumber).hnd.fix.color_bright;
                    par_hnd = aux_FillPar(par_temp);
                    par_eye = struct([]);
                case {2,3,4,6}
                    par_temp = trial(dyn.trialNumber).eye.fix;
                    par_temp.color = trial(dyn.trialNumber).eye.fix.color_bright;
                    par_eye = aux_FillPar(par_temp);
                    par_temp = trial(dyn.trialNumber).hnd.fix;
                    par_temp.color = trial(dyn.trialNumber).hnd.fix.color_bright;
                    par_hnd = aux_FillPar(par_temp);
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
                    par_temp=trial(dyn.trialNumber).eye.tar(n_obj);
                    par_temp.color=trial(dyn.trialNumber).eye.tar(n_obj).color_dim;
                    par_eye(n_obj) = aux_FillPar(par_temp);
                end
                for n_obj=1:dyn.n_hnd_tar
                    par_temp=trial(dyn.trialNumber).hnd.tar(n_obj);
                    par_temp.color=trial(dyn.trialNumber).hnd.tar(n_obj).color_dim;
                    par_hnd(n_obj) = aux_FillPar(par_temp);
                end
            else
                if ~isnan(dyn.target_selected(1))
                    par_temp=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1));
                    par_temp.color=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).color_dim;
                    par_eye = aux_FillPar(par_temp);
                else
                    par_eye = struct([]);
                end
                if ~isnan(dyn.target_selected(2))
                    par_temp=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2));
                    par_temp.color=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).color_dim;
                    par_hnd = aux_FillPar(par_temp);
                else
                    par_hnd = struct([]);
                end
            end
            
            %overwriting target color for fixation in dissociated tasks
            %             switch trial(dyn.trialNumber).effector
            %                 case 3 % bright hnd fixation spot for dissociated memory saccades
            %                     clear par_hnd
            %                     for n_obj=1:dyn.n_hnd_tar
            %                         par_temp=trial(dyn.trialNumber).hnd.tar(n_obj);
            %                         par_temp.color=trial(dyn.trialNumber).hnd.fix(1).color_bright;
            %                         par_hnd(n_obj) = aux_FillPar(par_temp);
            %                     end
            %                 case 4 % bright eye fixation spot for dissociated memory reaches
            %                     clear par_eye
            %                     for n_obj=1:dyn.n_eye_tar
            %                         par_temp=trial(dyn.trialNumber).eye.tar(n_obj);
            %                         par_temp.color=trial(dyn.trialNumber).eye.fix(1).color_bright;
            %                         par_eye(n_obj) = aux_FillPar(par_temp);
            %                     end
            %             end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.stay_condition      = 0;
            
            if trial(dyn.trialNumber).reach_hand==0
                dyn.stay_condition = 1;
            end
            if trial(dyn.trialNumber).effector==5
                trial(dyn.trialNumber).reach_hand = dyn.hand_selected;
            end
            
        case STATE.SEN_RET  %% IGNORE FOR NOW !!!!!!!!!!!!!!
            % check target selected -> defined by sensors....
            par_temp=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1));
            par_temp.color=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).color_bright;
            par_eye = aux_FillPar(par_temp);
            par_temp=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2));
            par_temp.color=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(21)).color_bright;
            par_hnd = aux_FillPar(par_temp);
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.TAR_HOL %  target holding_with_change_of_color
            
            if ~isnan(dyn.target_selected(1))
                par_temp=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1));
                par_temp.color=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).color_bright;
                par_eye = aux_FillPar(par_temp);
%             elseif dyn.n_eye_tar>0 % dissociated
%                 for n_obj=1:dyn.n_eye_tar
%                     par_temp=trial(dyn.trialNumber).eye.tar(n_obj);
%                     par_temp.color=trial(dyn.trialNumber).eye.fix(1).color_bright;
%                     par_eye(n_obj) = aux_FillPar(par_temp);
%                 end
            else
                par_eye = struct([]);
            end
            
            if ~isnan(dyn.target_selected(2))
                par_temp=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2));
                par_temp.color=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).color_bright;
                par_hnd = aux_FillPar(par_temp);
%             elseif dyn.n_hnd_tar>0 %% dissociated
%                 for n_obj=1:dyn.n_hnd_tar
%                     par_temp=trial(dyn.trialNumber).hnd.tar(n_obj);
%                     par_temp.color=trial(dyn.trialNumber).hnd.fix(1).color_bright;
%                     par_hnd(n_obj) = aux_FillPar(par_temp);
%                 end
            else
                par_hnd = struct([]);
            end
            %% THIS WILL HAVE TO BE DELETED!
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
            temp_target_selected = dyn.target_selected;
            %             if task.type == 10 %KK reward for training norman
            %                 if dyn.target_selected(dyn.tar_selected_ind) == 1 %correct & blue (2)
            %                                 dyn.duration= 0.001;
            %                 [success,dyn,task]=aux_DispenseReward(task,dyn)  ;
            %                 end
            %             end
        case STATE.TA2_ACQ  % target acquisition
            dyn.tar_struct = 'ta2';
            if all(isnan(dyn.target_selected)) % can this be the case?
                for n_obj=1:dyn.n_eye_ta2
                    par_temp=trial(dyn.trialNumber).eye.ta2(n_obj);
                    par_temp.color=trial(dyn.trialNumber).eye.ta2(n_obj).color_dim;
                    par_eye(n_obj) = aux_FillPar(par_temp);
                end
                for n_obj=1:dyn.n_hnd_ta2
                    par_temp=trial(dyn.trialNumber).hnd.ta2(n_obj);
                    par_temp.color=trial(dyn.trialNumber).hnd.ta2(n_obj).color_dim;
                    par_hnd(n_obj) = aux_FillPar(par_temp);
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
        case STATE.TA2_HOL %  target holding_with_change_of_color
            dyn.tar_struct = 'ta2';
            
            if ~isnan(dyn.target_selected(1))
                par_temp=trial(dyn.trialNumber).eye.ta2(dyn.target_selected(1));
                par_temp.color=trial(dyn.trialNumber).eye.ta2(dyn.target_selected(1)).color_bright;
                par_eye = aux_FillPar(par_temp);
            elseif dyn.n_eye_tar>0
                for n_obj=1:dyn.n_eye_tar
                    par_temp=trial(dyn.trialNumber).eye.ta2(n_obj);
                    par_temp.color=trial(dyn.trialNumber).eye.fix(1).color_bright;
                    par_eye(n_obj) = aux_FillPar(par_temp);
                end
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                par_temp=trial(dyn.trialNumber).hnd.ta2(dyn.target_selected(2));
                par_temp.color=trial(dyn.trialNumber).hnd.ta2(dyn.target_selected(2)).color_bright;
                par_hnd = aux_FillPar(par_temp);
            elseif dyn.n_hnd_ta2>0
                for n_obj=1:dyn.n_hnd_ta2
                    par_temp=trial(dyn.trialNumber).hnd.ta2(n_obj);
                    par_temp.color=trial(dyn.trialNumber).hnd.fix(1).color_bright;
                    par_hnd(n_obj) = aux_FillPar(par_temp);
                end
            else
                par_hnd = struct([]);
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.target2_selected = dyn.target_selected ;
            dyn.target_selected = temp_target_selected ;
        case {STATE.CUE_ON_AUDITIV}
            % either a reward/error tone /none tone is displayed
            % visuel: same as in target-hold period
            % hand movement:none
            
            par_hnd = struct([]);par_eye = struct([]);
            if trial(dyn.trialNumber).CueAuditiv == 1
                if any(trial(dyn.trialNumber).task.correct_choice_target == dyn.target_selected(dyn.tar_selected_ind)) % for eye and hand targets
                    if SETTINGS.useSound  && strcmp(SETTINGS.SoundType, 'Beep')
                        Beeper_PsychPortAudio(SETTINGS.audioPort,200, 0.5, 0.2);
                    elseif SETTINGS.useSound && strcmp(SETTINGS.SoundType, 'XBI_sounds')
                        PsychPortAudio('Volume', SETTINGS.audioPort, 0.3);
                        Sounds('Reward') ;
                    end
                elseif ~any(trial(dyn.trialNumber).task.correct_choice_target == dyn.target_selected(dyn.tar_selected_ind))
                    if SETTINGS.useSound && strcmp(SETTINGS.SoundType, 'Beep'),
                        Beeper_PsychPortAudio(SETTINGS.audioPort,120, 0.5, 0.2);
                    elseif  SETTINGS.useSound && strcmp(SETTINGS.SoundType, 'XBI_sounds'),
                        PsychPortAudio('Volume', SETTINGS.audioPort, 0.1);
                        
                        Sounds('Failure');
                    end
                end
            elseif   task.type == 12 %Zurna
                %information from the success state
                if SETTINGS.useSound  && strcmp(SETTINGS.SoundType, 'Beep')
                    if trial(dyn.trialNumber).CueAuditiv  == 1
                        Beeper_PsychPortAudio(SETTINGS.audioPort,500, 0.5, 0.2);
                    elseif trial(dyn.trialNumber).CueAuditiv  == 0
                        Beeper_PsychPortAudio(SETTINGS.audioPort,1000, 0.5, 0.2);
                    end
                end
                %trial(dyn.trialNumber).success                  = 1;
                reward_idx = 1 ;
                trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(2).reward_time(reward_idx);
                trial(dyn.trialNumber).completed = 1;
                %dyn.completed = 1;
                %dyn.trialNumberCompleted = dyn.trialNumberCompleted + 1;
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.MAT_ACQ_MSK  % masked target acquisition in match-to-sample
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            
            for n_target=1:dyn.n_eye_tar
                par_temp = trial(dyn.trialNumber).eye.tar(n_target);
                par_temp.color = trial(dyn.trialNumber).eye.tar(n_target).color_dim;
                par_temp.size  = trial(dyn.trialNumber).eye.fix.size;
                par_temp.shape = trial(dyn.trialNumber).eye.fix.shape;
                par_eye(n_target)= aux_FillPar(par_temp);
            end
            for n_target=1:dyn.n_hnd_tar
                par_temp = trial(dyn.trialNumber).hnd.tar(n_target);
                par_temp.color = trial(dyn.trialNumber).hnd.tar(n_target).color_dim;
                par_temp.size  = trial(dyn.trialNumber).hnd.fix.size;
                par_temp.shape = trial(dyn.trialNumber).hnd.fix.shape;
                par_hnd(n_target)= aux_FillPar(par_temp);
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.time_spent_exploring = dyn.time_spent_exploring+dyn.time_spent_in_state;
            
        case STATE.MAT_ACQ  % target acquisition in match-to-sample
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            for n_target=1:dyn.n_eye_tar
                par_temp = trial(dyn.trialNumber).eye.tar(n_target);
                par_temp.color = trial(dyn.trialNumber).eye.tar(n_target).color_dim;
                par_eye(n_target)= aux_FillPar(par_temp);
            end
            for n_target=1:dyn.n_hnd_tar
                par_temp = trial(dyn.trialNumber).hnd.tar(n_target);
                par_temp.color = trial(dyn.trialNumber).hnd.tar(n_target).color_dim;
                par_hnd(n_target)= aux_FillPar(par_temp);
                %                 par_hnd(n_target) = aux_FillPar(trial(dyn.trialNumber).hnd.tar(n_target).shape, trial(dyn.trialNumber).hnd.tar(n_target).pos, task.hnd.tar(n_target).color_dim,[],1,[0 0 0]);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            dyn.time_spent_exploring = dyn.time_spent_exploring+dyn.time_spent_in_state;
            
        case STATE.MAT_HOL  % target hold in match-to-sample
            if ~isnan(dyn.target_selected(1))
                for n_target=1:dyn.n_eye_tar
                    par_temp = trial(dyn.trialNumber).eye.tar(n_target);
                    if n_target==dyn.target_selected(1)
                        par_temp.color = trial(dyn.trialNumber).eye.tar(n_target).color_bright;
                    else
                        par_temp.color = trial(dyn.trialNumber).eye.tar(n_target).color_dim;
                    end
                    par_eye(n_target)= aux_FillPar(par_temp);
                end
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                for n_target=1:dyn.n_hnd_tar
                    par_temp = trial(dyn.trialNumber).hnd.tar(n_target);
                    if n_target==dyn.target_selected(2)
                        par_temp.color = trial(dyn.trialNumber).hnd.tar(n_target).color_bright;
                    else
                        par_temp.color = trial(dyn.trialNumber).hnd.tar(n_target).color_dim;
                    end
                    par_hnd(n_target)= aux_FillPar(par_temp);
                end
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
            if ~isnan(dyn.target_selected(1))
                for n_target=1:dyn.n_eye_tar
                    par_temp = trial(dyn.trialNumber).eye.tar(n_target);
                    if n_target==dyn.target_selected(1)
                        par_temp.color = trial(dyn.trialNumber).eye.tar(n_target).color_bright;
                    else
                        par_temp.color = trial(dyn.trialNumber).eye.tar(n_target).color_dim;
                        par_temp.shape.mode='circle';
                        par_temp.size=trial(dyn.trialNumber).eye.fix.size;
                    end
                    par_eye(n_target)= aux_FillPar(par_temp);
                end
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                for n_target=1:dyn.n_hnd_tar
                    par_temp = trial(dyn.trialNumber).hnd.tar(n_target);
                    if n_target==dyn.target_selected(2)
                        par_temp.color = trial(dyn.trialNumber).hnd.tar(n_target).color_bright;
                    else
                        par_temp.color = trial(dyn.trialNumber).hnd.tar(n_target).color_dim;
                        par_temp.shape.mode='circle';
                        par_temp.size=trial(dyn.trialNumber).hnd.fix.size;
                    end
                    par_hnd(n_target)= aux_FillPar(par_temp);
                end
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
                par_temp=trial(dyn.trialNumber).eye.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fix(n_obj).color_bright;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_temp=trial(dyn.trialNumber).hnd.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fix(n_obj).color_bright;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_eye_cue
                par_temp=trial(dyn.trialNumber).eye.cue(n_obj);
                %                par_temp.reward_prob=trial(dyn.trialNumber).eye.tar(n_obj).reward_prob; %% needed? (taking reward prob from tar)
                par_temp.color=trial(dyn.trialNumber).eye.cue(n_obj).color_dim;
                par_eye(n_obj+dyn.n_eye_fix) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_cue
                par_temp=trial(dyn.trialNumber).hnd.cue(n_obj);
                %                par_temp.reward_prob=trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob; %% needed? (taking reward prob from tar)
                par_temp.color=trial(dyn.trialNumber).hnd.cue(n_obj).color_dim;
                par_hnd(n_obj+dyn.n_hnd_fix) = aux_FillPar(par_temp);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.MSK_HOL %KK: Match-to-sample task
            if dyn.n_eye_fix+dyn.n_eye_cue==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix+dyn.n_hnd_cue==0;par_hnd = struct([]);end;
            
            for n_obj=1:dyn.n_eye_fix
                par_temp=trial(dyn.trialNumber).eye.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fix(n_obj).color_bright;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_temp=trial(dyn.trialNumber).hnd.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fix(n_obj).color_bright;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            
            for n_obj=1:dyn.n_eye_cue
                par_temp=trial(dyn.trialNumber).eye.cue(n_obj);
                par_temp.reward_prob=trial(dyn.trialNumber).eye.tar(n_obj).reward_prob; %% needed? (taking reward prob from tar)
                par_temp.shape.mode='bar_masked';
                par_temp.color=trial(dyn.trialNumber).eye.cue(n_obj).color_dim;
                par_eye(n_obj+dyn.n_eye_fix) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_cue
                par_temp=trial(dyn.trialNumber).hnd.cue(n_obj);
                par_temp.reward_prob=trial(dyn.trialNumber).hnd.tar(n_obj).reward_prob; %% needed? (taking reward prob from tar)
                par_temp.shape.mode='bar_masked';
                par_temp.color=trial(dyn.trialNumber).hnd.cue(n_obj).color_dim;
                par_hnd(n_obj+dyn.n_hnd_fix) = aux_FillPar(par_temp);
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.MEM_PER
            if dyn.n_eye_fix==0;par_eye = struct([]);end;
            if dyn.n_hnd_fix==0;par_hnd = struct([]);end;
            for n_obj=1:dyn.n_eye_fix
                par_temp=trial(dyn.trialNumber).eye.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).eye.fix(n_obj).color_bright;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_fix
                par_temp=trial(dyn.trialNumber).hnd.fix(n_obj);
                par_temp.color=trial(dyn.trialNumber).hnd.fix(n_obj).color_bright;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.TAR_ACQ_INV  % target acquisition invisible
            if dyn.n_eye_tar==0;par_eye = struct([]);end;
            if dyn.n_hnd_tar==0;par_hnd = struct([]);end;
            for n_obj=1:dyn.n_eye_tar
                par_temp=trial(dyn.trialNumber).eye.tar(n_obj);
                if trial(dyn.trialNumber).effector == 4 % bright eye fixation spot for dissociated memory reaches
                    eye_tar_color = trial(dyn.trialNumber).eye.fix(1).color_bright;
                else
                    eye_tar_color = trial(dyn.trialNumber).eye.tar(n_obj).color_inv;
                end
                par_temp.color=eye_tar_color;
                par_temp.ringColor=eye_tar_color;
                par_temp.ringColor2=eye_tar_color;
                par_eye(n_obj) = aux_FillPar(par_temp);
            end
            for n_obj=1:dyn.n_hnd_tar
                par_temp=trial(dyn.trialNumber).hnd.tar(n_obj);
                if trial(dyn.trialNumber).effector == 3 % bright hnd fixation spot for dissociated memory saccades
                    hnd_tar_color = trial(dyn.trialNumber).hnd.fix(1).color_bright;
                else
                    hnd_tar_color = trial(dyn.trialNumber).hnd.tar(n_obj).color_inv;
                end
                par_temp.color=hnd_tar_color;
                par_temp.ringColor=hnd_tar_color;
                par_temp.ringColor2=hnd_tar_color;
                par_hnd(n_obj) = aux_FillPar(par_temp);
            end
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.TAR_HOL_INV
            if ~isnan(dyn.target_selected(1))
                par_temp=trial(dyn.trialNumber).eye.tar(dyn.target_selected(1));
                if trial(dyn.trialNumber).effector == 4 % bright eye fixation spot for dissociated memory reaches
                    eye_tar_color = trial(dyn.trialNumber).eye.fix(1).color_bright;
                else
                    eye_tar_color = trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).color_inv;
                end
                par_temp.color=eye_tar_color;
                par_temp.ringColor=eye_tar_color;
                par_temp.ringColor2=eye_tar_color;
                par_eye = aux_FillPar(par_temp);
            else
                par_eye = struct([]);
            end
            if ~isnan(dyn.target_selected(2))
                par_temp=trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2));
                if trial(dyn.trialNumber).effector == 3 % bright hnd fixation spot for dissociated memory saccades
                    hnd_tar_color = trial(dyn.trialNumber).hnd.fix(1).color_bright;
                else
                    hnd_tar_color = trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).color_inv;
                end
                par_temp.color=hnd_tar_color;
                par_temp.ringColor=hnd_tar_color;
                par_temp.ringColor2=hnd_tar_color;
                par_hnd = aux_FillPar(par_temp);
            else
                par_hnd = struct([]);
            end
            
            dyn.duration            = get_state_duration(task,trial,dyn);
            [success,dyn,task]      = hold_state(task,par_eye,par_hnd,dyn,trial,IO);
            
        case STATE.ABORT % abort
            [dyn.abort_code dyn.abort_message]= get_abort_code(dyn);
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
            trial(dyn.trialNumber).target2_selected = dyn.target2_selected;
            trial(dyn.trialNumber).eye_targets_inspected = dyn.eye_targets_inspected;
            trial(dyn.trialNumber).hand_targets_inspected = dyn.hand_targets_inspected;
            trial(dyn.trialNumber).rewarded = 0;
            trial(dyn.trialNumber).reward_time = 0;
            trial(dyn.trialNumber).reward_prob = -1;
            trial(dyn.trialNumber).reward_selected = 0;
            
            % play not nice sound to monkey
            if  SETTINGS.useSound && SETTINGS.WrongTargetSound && trial(dyn.trialNumber).completed == 1 && strcmp(SETTINGS.SoundType, 'Beep')&& task.type ~= 10 ,
                Beeper_PsychPortAudio(SETTINGS.audioPort,120, 0.5, 0.2);
            elseif  SETTINGS.useSound && SETTINGS.WrongTargetSound && trial(dyn.trialNumber).completed == 1 && strcmp(SETTINGS.SoundType, 'XBI_sounds')&& task.type ~= 10 ,
                PsychPortAudio('Volume', SETTINGS.audioPort, 1);
                Sounds('Failure'); %KK
            end
            if SETTINGS.useSound && SETTINGS.FixationBreakSound && (dyn.previousState==STATE.CUE_ON || dyn.previousState==STATE.MEM_PER)
                Beeper_PsychPortAudio(SETTINGS.audioPort,1600, 0.5, 0.2);
                Beeper_PsychPortAudio(SETTINGS.audioPort,1600, 0.5, 0.2);
            end
            
            Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
            displaybackground(SETTINGS,task,dyn)
            Screen(SETTINGS.window,'Flip');
            send_to_TDT(IO,dyn.state);
            if SETTINGS.GUI,
                aux_make_all_targets_invisible
            end
            dyn.states_onset = GetSecs - SETTINGS.time_start;
            fprintf([' ' trial(dyn.trialNumber).abort_code]);
            success = 1;
            
        case STATE.SUCCESS % success
            [dyn.abort_code dyn.abort_message]= get_abort_code(dyn);
            send_to_TDT(IO,dyn.state);
            if SETTINGS.GUI,
                aux_make_all_targets_invisible
            end
            trial(dyn.trialNumber).aborted_state            = -1;
            trial(dyn.trialNumber).aborted_state_duration   = -1;
            trial(dyn.trialNumber).abort_code               = dyn.abort_code;
            trial(dyn.trialNumber).success                  = 1;
            trial(dyn.trialNumber).completed                = 1;
            trial(dyn.trialNumber).target_selected          = dyn.target_selected;
            trial(dyn.trialNumber).target2_selected         = dyn.target2_selected;
            trial(dyn.trialNumber).eye_targets_inspected    = dyn.eye_targets_inspected;
            trial(dyn.trialNumber).hand_targets_inspected   = dyn.hand_targets_inspected;
            
            
            %% Decide about reward...
            % Do not reward if reward probability is zero or "secondary" reward for "risky" targets is zero
            
            %             if trial(dyn.trialNumber).effector < 2, % eye or hand
            %                 % use target_selected(1) or target_selected(2) according to current effector
            %                 if trial(dyn.trialNumber).target_selected(trial(dyn.trialNumber).effector+1) == 1,
            %                     trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(1).reward;
            %                     trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(1).reward_prob;
            %                     reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
            %                     trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(1).reward_time(reward_idx);
            %                 else
            %                     trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(2).reward;
            %                     trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(2).reward_prob;
            %                     reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
            %                     trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(2).reward_time(reward_idx);
            %                 end
            %
            %             else % both eye and hand, decide based on which effector to determine reward
            %                 if trial(dyn.trialNumber).target_selected(task.reward_modulation_effector) == 1,
            %                     trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(1).reward;
            %                     trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(1).reward_prob;
            %                     reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
            %                     trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(1).reward_time(reward_idx);
            %                 else
            %                     trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).hnd.tar(2).reward;
            %                     trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).hnd.tar(2).reward_prob;
            %                     reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
            %                     trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).hnd.tar(2).reward_time(reward_idx);
            %                 end
            %             end
            tar_selected=dyn.target_selected(dyn.tar_selected_ind);
            trial(dyn.trialNumber).reward_selected = trial(dyn.trialNumber).(dyn.effector).tar(tar_selected).reward;
            trial(dyn.trialNumber).reward_prob = trial(dyn.trialNumber).(dyn.effector).tar(tar_selected).reward_prob;
            reward_idx = 2 - (rand<=trial(dyn.trialNumber).reward_prob); % take first or secondary reward for specific target
            trial(dyn.trialNumber).reward_time = trial(dyn.trialNumber).(dyn.effector).tar(tar_selected).reward_time(reward_idx);
            
            dyn.trial_outcome = 1;
            dyn.trialNumberFinished = dyn.trialNumberFinished + 1;
            
            % play nice sound to monkey
            if SETTINGS.useSound && SETTINGS.RewardSound && strcmp(SETTINGS.SoundType, 'Beep')&& task.type ~= 10 &&  task.type ~= 12
                Beeper_PsychPortAudio(SETTINGS.audioPort,200, 0.5, 0.2);
            elseif SETTINGS.useSound && SETTINGS.RewardSound && strcmp(SETTINGS.SoundType, 'XBI_sounds')&& task.type ~= 10
                PsychPortAudio('Volume', SETTINGS.audioPort, 1);
                Sounds('Reward') ;     %KK
            end
            
            Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
            displaybackground(SETTINGS,task,dyn)
            Screen(SETTINGS.window,'Flip');
            
        case STATE.REWARD % reward
            send_to_TDT(IO,dyn.state);
            if task.type == 10 && ~all(isnan(dyn.target2_selected))
                if trial(dyn.trialNumber).success
                    Row_PayoffMatrix = 1;
                elseif trial(dyn.trialNumber).success == 0
                    Row_PayoffMatrix = 2;
                else
                    Row_PayoffMatrix = 0;
                    trial(dyn.trialNumber).reward_time = 0.01;
                end
                trial(dyn.trialNumber).reward_time = task.PayoffMatrix(Row_PayoffMatrix,dyn.target2_selected(dyn.ta2_selected_ind));
            end
            
            %% Feedback sounds for wagering
            if task.type == 10
                PsychPortAudio('Volume', SETTINGS.audioPort, 0.7);
                
                if trial(dyn.trialNumber).CueAuditiv == 0 % three wagers where the middle is not rewarded
                    if trial(dyn.trialNumber).success && dyn.target2_selected(dyn.ta2_selected_ind) == 2 %correct & blue (2)
                        Sounds('Reward') ;
                    elseif trial(dyn.trialNumber).success && dyn.target2_selected(dyn.ta2_selected_ind) == 1 %correct & yellow (1)
                        Sounds('Failure');
                    elseif trial(dyn.trialNumber).success == 0 && dyn.target2_selected(dyn.ta2_selected_ind) == 1 %incorrect & yellow (1)
                        Sounds('Reward') ;
                    elseif trial(dyn.trialNumber).success  == 0 && dyn.target2_selected(dyn.ta2_selected_ind) == 2 %incorrect & blue (2)
                        Sounds('Failure');
                    end
                    
                else % two  wagers
                    if trial(dyn.trialNumber).success && dyn.target2_selected(dyn.ta2_selected_ind) == 2 %correct & blue (2)
                        Sounds('Reward') ;
                    elseif trial(dyn.trialNumber).success && dyn.target2_selected(dyn.ta2_selected_ind) == 1 %correct & yellow (1)
                        Sounds('Failure');
                    elseif trial(dyn.trialNumber).success == 0 && dyn.target2_selected(dyn.ta2_selected_ind) == 1 %incorrect & yellow (1)
                        Sounds('Reward') ;
                    elseif trial(dyn.trialNumber).success  == 0 && dyn.target2_selected(dyn.ta2_selected_ind) == 2 %incorrect & blue (2)
                        Sounds('Failure');
                    end
                end
                
            end
            
            
            if trial(dyn.trialNumber).reward_time > 0
                trial(dyn.trialNumber).rewarded = 1;
                if SETTINGS.useParallel || SETTINGS.useSerial
                    dyn.duration=trial(dyn.trialNumber).task.timing.wait_for_reward;
                    [success,dyn,task]=wait_while_recording_state(task,dyn);
                    dyn.duration=trial(dyn.trialNumber).reward_time;
                    [success,dyn,task]=aux_DispenseReward(task,dyn);
                end
            elseif   trial(dyn.trialNumber).reward_time == 0
                trial(dyn.trialNumber).rewarded = 0;
                dyn.duration=trial(dyn.trialNumber).task.timing.wait_for_reward;
                [success,dyn,task]=wait_while_recording_state(task,dyn);
            else    % TIMEOUT
                trial(dyn.trialNumber).rewarded = 0;
                dyn.duration=-1*trial(dyn.trialNumber).reward_time +trial(dyn.trialNumber).task.timing.wait_for_reward;
                [success,dyn,task]=wait_while_recording_state(task,dyn);
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
            
            %% Write data to file
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
                        selected_position_x = trial(dyn.trialNumber).eye.tar(dyn.target_selected(1)).x-trial(dyn.trialNumber).eye.fix.x;
                    case {1,4,6} % hand
                        selected_position_x = trial(dyn.trialNumber).hnd.tar(dyn.target_selected(2)).x-trial(dyn.trialNumber).eye.fix.x;
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
                
                % fprintf(' || control L/R %.2f microstim L/R %.2f || \n',dyn.choice_l/dyn.choice_r,dyn.choice_l_microstim/dyn.choice_r_microstim);
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
                    plot(time_axis,trial(n).x_eye,'g'); hold on;
                    plot(time_axis,trial(n).x_hnd,'Color',[0 0.5 0]);
                    
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
                    
                    title(sprintf('trial %d suc. %d choice %d microstim %d',[trial(n).n trial(n).success trial(n).choice trial(n).microstim]));
                    
                    subplot(2,1,2);
                    plot(time_axis,trial(n).y_eye,'m'); hold on;
                    plot(time_axis,trial(n).y_hnd,'Color',[0.3 0 0.3]);
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
    %% in task.type = 10, incorrect target selection goes to STATE.ABORT and afterwards it should go to STATE.REWARD
    
    if dyn.state==STATE.ABORT && dyn.completed && task.type == 10     %% KKK
        dyn.state=STATE.REWARD;
    elseif dyn.state==STATE.CUE_ON_AUDITIV && task.type == 12  %Zurna
        if trial(dyn.trialNumber).reward_time  ~= 0
            dyn.state=STATE.SUCCESS;
        elseif task.reward.time_neutral(1) == 0
            dyn.state =   STATE.SUCCESS;
            trial(dyn.trialNumber).rewarded = 0;
        end
    else
        dyn.state               = state_transition(task,success,dyn.state);
    end
    
    if dyn.state==STATE.SUCCESS
        trial(dyn.trialNumber).completed = 1;
        dyn.completed = 1;
        dyn.trialNumberCompleted = dyn.trialNumberCompleted + 1;
        if task.type ~= 11 && task.type ~= 12 %Zurna
            if ~any(trial(dyn.trialNumber).task.correct_choice_target == dyn.target_selected(dyn.tar_selected_ind)) % for eye and hand targets
                dyn.state=STATE.ABORT;
            end
        end
    end
    
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
        
    case STATE.FI2_ACQ
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
        
    case STATE.FI2_HOL
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
    case STATE.TA2_ACQ
        switch trial(dyn.trialNumber).effector
            case 0
                state_duration = task.timing.ta2_time_to_acquire_eye;
            case {1,5,6}
                state_duration = task.timing.ta2_time_to_acquire_hnd;
            case {2,3,4}
                state_duration = max(task.timing.ta2_time_to_acquire_eye,task.timing.ta2_time_to_acquire_hnd);
        end
    case STATE.TA2_HOL
        state_duration = task.timing.ta2_time_hold + rand*task.timing.ta2_time_hold_var;
        
    case STATE.TAR_HOL
        state_duration = task.timing.tar_time_hold + rand*task.timing.tar_time_hold_var;
    case STATE.CUE_ON
        state_duration = task.timing.cue_time_hold + rand*task.timing.cue_time_hold_var;
    case STATE.CUE_ON_AUDITIV
        state_duration = task.timing.cue_auditiv_time_hold + rand*task.timing.cue_auditiv_time_hold_var;
    case STATE.MEM_PER
        state_duration = task.timing.mem_time_hold + rand*task.timing.mem_time_hold_var;
        
    case STATE.DEL_PER
        state_duration = task.timing.del_time_hold + rand*task.timing.del_time_hold_var;
        
    case STATE.MSK_HOL
        state_duration = task.timing.msk_time_hold + rand*task.timing.msk_time_hold_var;
        
    case STATE.TAR_ACQ_INV
        switch trial(dyn.trialNumber).effector
            case {0,3} % 0 PN
                state_duration = task.timing.tar_inv_time_to_acquire_eye;
            case {1,5,6,4} % {1,5,6} PN
                state_duration = task.timing.tar_inv_time_to_acquire_hnd;
            case {2} % {2,3,4} PN
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

%% state functions
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
        case 9 % delayed Match-to-sample with backward masking
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MSK_HOL ...
                STATE.TAR_ACQ  STATE.TAR_HOL  STATE.SUCCESS STATE.REWARD  STATE.ITI];
        case 10 % delayed Match-to-sample with backward masking with Wagering
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.MSK_HOL ...
                STATE.TAR_ACQ  STATE.TAR_HOL STATE.CUE_ON_AUDITIV STATE.FI2_ACQ  STATE.FI2_HOL  STATE.TA2_ACQ  STATE.TA2_HOL  STATE.SUCCESS  STATE.REWARD  STATE.ITI];
        case 11 % Fixation with cue (no target selection, maintain fixation)
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ  STATE.FIX_HOL  STATE.CUE_ON  STATE.DEL_PER  ...
                STATE.SUCCESS  STATE.REWARD  STATE.ITI];
        case 12 % Fixation with cue (no target selection, maintain fixation)
            task_states = [STATE.INI_TRI  STATE.FIX_ACQ STATE.CUE_ON_AUDITIV   STATE.SUCCESS   STATE.REWARD  STATE.ITI];
    end
    
    if success==1
        current_state_idx = find(current_state == task_states);
        new_state = task_states(current_state_idx + 1);
    elseif success==-1
        current_state_idx = find(current_state == task_states);
        new_state = task_states(current_state_idx -1);
    end
    
end

function [abort_code abort_message] = get_abort_code(dyn)
% Returns specific abort code based on combination of state in which abort occurred, and behavioral markers
% This function is called from acquire_state and hold_state
% dyn.time_spent_in_state - in case of abort, tells duration of state prior to abort

global STATE
% Behavioral markers: eye, hand, sen1, sen2, jaw, body
bm_eye = 1; bm_hnd = 2; bm_sen1 = 3; bm_sen2 = 4; bm_jaw = 5; bm_body = 6;
beh_markers = dyn.beh_markers;
abort_code = 'UNKNOWN ERROR CODE';
abort_message = '';


ABORT_JAW = 'ABORT_JAW';
ABORT_BODY = 'ABORT_BODY';

ABORT_USE_INCORRECT_HAND = 'ABORT_USE_INCORRECT_HAND'; % in the initial fixation acquisition

ABORT_DIRTY_SENSORS = 'ABORT_DIRTY_SENSORS';
ABORT_WRONG_TARGET_SELECTED  = 'ABORT_WRONG_TARGET_SELECTED';

ABORT_RELEASE_SENSOR_HOLD_STATE = 'ABORT_RELEASE_SENSOR_HOLD_STATE';

ABORT_EYE_FIX_ACQ_STATE = 'ABORT_EYE_FIX_ACQ_STATE';
ABORT_HND_FIX_ACQ_STATE = 'ABORT_HND_FIX_ACQ_STATE';

ABORT_EYE_FI2_ACQ_STATE = 'ABORT_EYE_FI2_ACQ_STATE';
ABORT_HND_FI2_ACQ_STATE = 'ABORT_HND_FI2_ACQ_STATE';

ABORT_EYE_FIX_HOLD_STATE = 'ABORT_EYE_FIX_HOLD_STATE';
ABORT_HND_FIX_HOLD_STATE = 'ABORT_HND_FIX_HOLD_STATE';

ABORT_EYE_FI2_HOLD_STATE = 'ABORT_EYE_FI2_HOLD_STATE';
ABORT_HND_FI2_HOLD_STATE = 'ABORT_HND_FI2_HOLD_STATE';

ABORT_EYE_TAR_ACQ_STATE = 'ABORT_EYE_TAR_ACQ_STATE';
ABORT_HND_TAR_ACQ_STATE = 'ABORT_HND_TAR_ACQ_STATE';

ABORT_EYE_TA2_ACQ_STATE = 'ABORT_EYE_TA2_ACQ_STATE';
ABORT_HND_TA2_ACQ_STATE = 'ABORT_HND_TA2_ACQ_STATE';

ABORT_EYE_TAR_HOLD_STATE = 'ABORT_EYE_TAR_HOLD_STATE';
ABORT_HND_TAR_HOLD_STATE = 'ABORT_HND_TAR_HOLD_STATE';

ABORT_EYE_TA2_HOLD_STATE = 'ABORT_EYE_TA2_HOLD_STATE';
ABORT_HND_TA2_HOLD_STATE = 'ABORT_HND_TA2_HOLD_STATE';

ABORT_EYE_TAR_ACQ_INV_STATE = 'ABORT_EYE_TAR_ACQ_INV_STATE'; %
ABORT_HND_TAR_ACQ_INV_STATE = 'ABORT_HND_TAR_ACQ_INV_STATE'; %

ABORT_EYE_TAR_HOLD_INV_STATE = 'ABORT_EYE_TAR_HOLD_INV_STATE'; %
ABORT_HND_TAR_HOLD_INV_STATE = 'ABORT_HND_TAR_HOLD_INV_STATE'; %

ABORT_EYE_CUE_ON_STATE = 'ABORT_EYE_CUE_ON_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset
ABORT_HND_CUE_ON_STATE = 'ABORT_HND_CUE_ON_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset

ABORT_EYE_CUE_ON_AUDITIV_STATE = 'ABORT_EYE_CUE_ON_AUDITIV_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset
ABORT_HND_CUE_ON_AUDITIV_STATE = 'ABORT_HND_CUE_ON_AUDITIV_STATE'; %% not just during CUE_ON, but also 200 ms after CUE offset

ABORT_EYE_MEM_PER_STATE = 'ABORT_EYE_MEM_PER_STATE'; %% if time spent in state < 200 ms, error is 'ABORT_EYE_CUE_ON_STATE', otherwise error is 'ABORT_EYE_MEM_PER_STATE'
ABORT_HND_MEM_PER_STATE = 'ABORT_HND_MEM_PER_STATE'; %% if time spent in state < 200 ms, error is 'ABORT_EYE_CUE_ON_STATE', otherwise error is 'ABORT_EYE_MEM_PER_STATE'

ABORT_EYE_DEL_PER_STATE = 'ABORT_EYE_DEL_PER_STATE';
ABORT_HND_DEL_PER_STATE = 'ABORT_HND_DEL_PER_STATE';

ABORT_EYE_MSK_HOLD_STATE = 'ABORT_EYE_MSK_HOLD_STATE';
ABORT_HND_MSK_HOLD_STATE = 'ABORT_HND_MSK_HOLD_STATE';

if dyn.state~=STATE.ABORT,
    abort_code = 'NO ABORT';
    abort_message = ''; % 'Trial successful!'
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
        abort_message = 'Wrong target selected!';
    else
        switch dyn.previousState % state in which abort occurred
            case STATE.FIX_ACQ
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FIX_ACQ_STATE;
                    abort_message = 'Eye fixation not acquired!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FIX_ACQ_STATE;
                    abort_message = 'Hand fixation not acquired!';
                end
                
            case STATE.FI2_ACQ
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FI2_ACQ_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FI2_ACQ_STATE;
                end
                
            case STATE.FIX_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FIX_HOLD_STATE;
                    abort_message = 'Broke eye fixation!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FIX_HOLD_STATE;
                    abort_message = 'Broke hand fixation!';
                end
                
            case STATE.FI2_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_FI2_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_FI2_HOLD_STATE;
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
                    abort_message = 'Broke target fixation!'; %meaningful for memory task only
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_ACQ_STATE;
                    abort_message = 'Broke target fixation!'; %meaningful for memory task only
                end
                
            case STATE.TA2_ACQ
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TA2_ACQ_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TA2_ACQ_STATE;
                end
                
            case STATE.TAR_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_HOLD_STATE;
                    abort_message = 'Broke target fixation!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_HOLD_STATE;
                    abort_message = 'Broke target fixation!';
                end
                
            case STATE.TA2_HOL
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TA2_HOLD_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TA2_HOLD_STATE;
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
                    abort_message = 'No eye target acquired!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_ACQ_INV_STATE;
                    abort_message = 'No hand target acquired!';
                end
                
            case STATE.TAR_HOL_INV
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_TAR_HOLD_INV_STATE;
                    abort_message = 'Broke target fixation!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_TAR_HOLD_INV_STATE;
                    abort_message = 'Broke target fixation!';
                end
                
            case STATE.CUE_ON
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_CUE_ON_STATE;
                    abort_message = 'Broke fixation!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_CUE_ON_STATE;
                    abort_message = 'Broke fixation!';
                end
                
            case STATE.CUE_ON_AUDITIV
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_CUE_ON_AUDITIV_STATE;
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_EYE_CUE_ON_AUDITIV_STATE;
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
                    abort_message = 'Broke fixation!';
                elseif ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_MEM_PER_STATE;
                    abort_message = 'Broke fixation!';
                elseif ~beh_markers(bm_hnd) && dyn.time_spent_in_state < 0.2,
                    abort_code = ABORT_HND_CUE_ON_STATE;
                    abort_message = 'Broke fixation!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_MEM_PER_STATE;
                    abort_message = 'Broke fixation!';
                end
                
            case STATE.DEL_PER
                if ~beh_markers(bm_eye),
                    abort_code = ABORT_EYE_DEL_PER_STATE;
                    abort_message = 'Broke fixation!';
                elseif ~beh_markers(bm_hnd),
                    abort_code = ABORT_HND_DEL_PER_STATE;
                    abort_message = 'Broke fixation!';
                end
        end
    end
end

function [success,dyn,task]  = acquisition_state(task,par_eye,par_hnd,dyn,trial,IO)
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
        case STATE.FI2_ACQ
            tag_visible='fi2'; %KK
            tag_invisible='tar';
        case STATE.TAR_ACQ
            tag_visible='tar';
            tag_invisible='fix';
        case STATE.TA2_ACQ
            tag_visible='ta2';
            tag_invisible='fi2';
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

displaybackground(SETTINGS,task,dyn)
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
    tSample         = GetSecs;
    eye_acq_current = 0;
    hnd_acq_current = 0;
    
    [x_eye y_eye x_hnd y_hnd touching sen1 sen2 sen3 sen4] = aux_GetCalibratedEyeHandPos(task); % in deg
    
    switch task.effector,
        case 0 % eye
            for obj = 1:n_obj_eye
                if aux_IsWithinRadius(x_eye, y_eye, par_eye(obj)),
                    success = true;
                    if isnan(dyn.target_selected(1)), dyn.target_selected(1) = obj; end
                    
                end
            end
            hnd_acq = 1;
            
        case {1,6} % hand
            for obj = 1:n_obj_hnd
                if aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                    success = true;
                    if isnan(dyn.target_selected(2)), dyn.target_selected(2) = obj; end
                end
            end
            eye_acq = 1;
            
        case 2 % both
            for obj = 1:n_obj_eye
                if aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
                    eye_acq_current = true;
                    if isnan(dyn.target_selected(1)), dyn.target_selected(1) = obj; end
                    if ~eye_acq, % eye acquired for the first time
                        eye_acq = 1;
                    end
                end
            end
            for obj = 1:n_obj_hnd
                if aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
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
                if aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
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
                if aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                    success = true;
                    if isnan(dyn.target_selected(2)),
                        dyn.target_selected(2)  = obj;
                        dyn.target_selected(1)  = 1; % dummy
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
            if ~aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                if ~tLeaveFixationHnd
                    tLeaveFixationHnd = GetSecs;    % if just got out of fixation, initiate timer
                elseif GetSecs - tLeaveFixationHnd > task.timing.grace_time_hand
                    hold_success = false; % if out for long time, abort trial
                    dyn.previousState = dyn.state;
                    % dyn.state   = STATE.ABORT;
                    dyn.aborted_effector = 1;
                    beh_markers(bm_hnd) = 0;
                end
            elseif aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                hnd_acq = 1;
                tLeaveFixationHnd = 0;  % if inside, reset timer
            end
        end
        if ~hold_success, break, end;
        
    elseif task.effector == 4 || task.effector == 5, % reach, check the eye hold
        for obj = 1:n_obj_eye
            if ~aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
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
            elseif aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
                tLeaveFixationEye = 0;  % if inside, reset timer
                eye_acq = 1;
            end
        end
        if ~hold_success, break, end;
    end
    
    if success,
        if  dyn.state~=STATE.FIX_ACQ && ~isnan(dyn.target_selected(dyn.tar_selected_ind)) && ...
                trial(dyn.trialNumber).task.(dyn.effector).(dyn.tar_struct)(dyn.target_selected(dyn.tar_selected_ind)).x ==  trial(dyn.trialNumber).task.(dyn.effector).(dyn.fix_struct).x && ...
                trial(dyn.trialNumber).task.(dyn.effector).(dyn.tar_struct)(dyn.target_selected(dyn.tar_selected_ind)).y == trial(dyn.trialNumber).task.(dyn.effector).(dyn.fix_struct).y && ...
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
end

dyn.time_spent_in_state = GetSecs - tEnterState;
dyn.beh_markers = beh_markers;

function [success,dyn,task]  = hold_state(task,par_eye,par_hnd,dyn,trial,IO)
global SETTINGS STATE

if trial(dyn.trialNumber).microstim && trial(dyn.trialNumber).microstim_state == dyn.state && trial(dyn.trialNumber).microstim_start < 0,
    % reference microstim to end of the state
    trial(dyn.trialNumber).microstim_start = dyn.duration + trial(dyn.trialNumber).microstim_start;
    trial(dyn.trialNumber).microstim_end = dyn.duration + trial(dyn.trialNumber).microstim_end;
    dyn.microstim_start = trial(dyn.trialNumber).microstim_start;
    dyn.microstim_end   = trial(dyn.trialNumber).microstim_end;
end

dyn.counterTimeSteps = 1;
success = true;
offset_updated  = false;
vpx_calibrated  = false;
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
    drawnow; %%hmmmm...
end

displaybackground(SETTINGS,task,dyn)
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
            if touching && trial(dyn.trialNumber).task.check_screen_touching
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
                if ~aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
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
                elseif aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
                    tLeaveFixationEye = 0;  % if inside, reset timer
                end
            end
            
        case {1} % hand
            for obj = start_obj_hnd:n_obj_hnd %obj = dyn.target_selected(2) % obj = 1:n_obj_hnd Change 20140519
                if ~aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                    if ~tLeaveFixationHnd
                        tLeaveFixationHnd = GetSecs;    % if just got out of fixation, initiate timer
                    elseif GetSecs - tLeaveFixationHnd > task.timing.grace_time_hand
                        success = false; % if out for long time, abort trial
                        dyn.previousState = dyn.state;
                        dyn.aborted_effector = 1;
                        beh_markers(bm_hnd) = 0;
                    end
                elseif aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                    tLeaveFixationHnd = 0;  % if inside, reset timer
                end
            end
            
        case {2,3,4,6} % both
            for obj = start_obj_eye:n_obj_eye
                if ~aux_IsWithinRadius(x_eye, y_eye, par_eye(obj)),
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
                elseif aux_IsWithinRadius(x_eye, y_eye, par_eye(obj))
                    tLeaveFixationEye = 0;  % if inside, reset timer
                end
            end
            
            for obj = start_obj_hnd:n_obj_hnd
                if ~aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
                    if ~tLeaveFixationHnd
                        tLeaveFixationHnd = GetSecs;    % if just got out of fixation, initiate timer
                    elseif GetSecs - tLeaveFixationHnd > task.timing.grace_time_hand
                        success = false; % if out for long time, abort trial
                        dyn.previousState = dyn.state;
                        dyn.aborted_effector = 1;
                        beh_markers(bm_hnd) = 0;
                        fprintf('hnd aborted HT=%4d',round((tLeaveFixationHnd-tEnterState)*1000));
                    end
                elseif aux_IsWithinRadius(x_hnd, y_hnd, par_hnd(obj))
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
            elseif any(find(keyCode)==115) && isfield(par_eye,'deg')% F4 KK
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

if SETTINGS.TextFeedback
    Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
    displaybackground(SETTINGS,task,dyn)
    Screen('DrawText',  SETTINGS.window, dyn.abort_message, SETTINGS.screen_w_pix/2-numel(dyn.abort_message)*9,SETTINGS.screen_h_pix/2, [255 255 255] ,SETTINGS.BG_COLOR); % text position
    Screen(SETTINGS.window,'Flip');
    tempdyn=dyn;
    tempdyn.duration=task.timing.text_feedback;
    [~,~,task]=wait_while_recording_state(task,tempdyn);
end

Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);
displaybackground(SETTINGS,task,dyn)
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
    %     if task.type == 10 && dyn.state == 21
    %         if any(any(task.PayoffMatrix <0)) == 1
    %             if dyn.duration >= -1*min(min(task.PayoffMatrix))%%
    %          Screen('FillRect', SETTINGS.window, [ 255 255 255])
    %          Screen(SETTINGS.window,'Flip');
    %          Screen('FillRect', SETTINGS.window, SETTINGS.BG_COLOR);               % fill whole screen black
    %          Screen(SETTINGS.window,'Flip');
    %             end
    %         end
    %     end
    WaitSecs('Untiltime',tSample+SETTINGS.timeStep); % maintain matlab sampling rate % TODO
    dyn.counterTimeSteps=dyn.counterTimeSteps+1;
    
    if GetSecs > tEnterState + dyn.duration    	% check time
        success = true;
        
        break;
    end
end

%% GUI functions
function aux_draw_GUI_targets(dyn,trial,eff,pha,ang)
%global STATE
if ~dyn.(['n_' eff '_' pha])==0
    for obj=1:numel(trial(dyn.trialNumber).(eff).(pha))
        if isempty(trial(dyn.trialNumber).(eff).(pha)(obj).x) % necessary, because the structure is there due to the reward modulation part (even if targets are not used).
            continue;
        end
        x=trial(dyn.trialNumber).(eff).(pha)(obj).x;  %xpos in deg
        y=trial(dyn.trialNumber).(eff).(pha)(obj).y;  %ypos in deg
        r1=trial(dyn.trialNumber).(eff).(pha)(obj).size; %size in deg
        r2=trial(dyn.trialNumber).(eff).(pha)(obj).radius; %radius in deg
        
        x1=r1*cos(ang);
        y1=r1*sin(ang);
        x2=r2*cos(ang);
        y2=r2*sin(ang);
        
        if isstruct(trial(dyn.trialNumber).(eff).(pha)(obj).shape)
            shape=trial(dyn.trialNumber).(eff).(pha)(obj).shape.mode;
        else
            shape=trial(dyn.trialNumber).(eff).(pha)(obj).shape;
        end
        
        switch shape
            case 'convex'
                obj_pointList=CalculateConvexPointList([0 0],r1,trial(dyn.trialNumber).(eff).(pha)(obj).shape.convexity,trial(dyn.trialNumber).(eff).(pha)(obj).shape.convex_side);
                pointList=[obj_pointList;obj_pointList(1,:)];
                x1=pointList(:,1)';
                y1=pointList(:,2)';
            case 'square'
                x1=[-1 -1 1 1 -1]*r1;
                y1=[-1 1 1 -1 -1]*r1;
        end
        if isfield(trial(dyn.trialNumber).(eff).(pha)(obj),'radiusShape')
            switch  trial(dyn.trialNumber).(eff).(pha)(obj).radiusShape
                case 'square'
                    x2=[-1 -1 1 1 -1]*r2;
                    y2=[-1 1 1 -1 -1]*r2;
            end
        end
        %% color!
        RGB_color=[255 0 0]/255;
        if strcmp(eff,'hnd')
            RGB_color=dyn.hnd_color/255;
        end
        if ismember(obj,dyn.correct_choice_target)
            plot(x,y,'*','color',[0 0 0],'Tag',[eff pha 'correct'],'Visible','off');
        end
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

%% Behavior related functions
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
[x_hnd y_hnd touching] = aux_GetCalibratedHndPos(data, task);

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
    [a,b]=GetMouse(SETTINGS.window,1);
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

function [x,y, touching] = aux_GetCalibratedHndPos(data, task)
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
    
elseif SETTINGS.UseMouseAsTouch  % use mouse input instead of touchscreen
    [a,b, button]=GetMouse(SETTINGS.window,1);
    mouseposition=[a -b];
    x_M=(mouseposition(1)-SETTINGS.screen_w_pix/2)*SETTINGS.screen_w_cm/SETTINGS.screen_w_pix;
    y_M=(mouseposition(2)+SETTINGS.screen_h_pix*(SETTINGS.screen_uh_cm)/SETTINGS.screen_h_cm)*SETTINGS.screen_h_cm/SETTINGS.screen_h_pix;
    %y_M=(mouseposition(2)-SETTINGS.screen_h_pix*(SETTINGS.screen_h_cm-SETTINGS.screen_uh_cm)/SETTINGS.screen_h_cm)*SETTINGS.screen_h_cm/SETTINGS.screen_h_pix;
    if button(1)
        x = atan(x_M/task.vd)*180/pi;
        y = atan(y_M/task.vd)*180/pi;
        touching = button(1);
        ShowCursor(2, SETTINGS.window, 1); % 1 - crosshair, 2 - index finger, 3 - four arrows, 4 - up/down arrow, 5 - left/right arrow, 6 - sand clock, 7 - stop sign, 8 - default arrow (from Windows)
    else
        x = nan;
        y = nan;
        touching = 0;
        %HideCursor(SETTINGS.window, 1);
    end
    
else
    x = NaN;
    y = NaN;
    touching = 0;
end

function is_within = aux_IsWithinRadius(x,y,par)
%% check if (x,y) is within radius r centered on (x0,y0)
x0=par.deg.x;
y0=par.deg.y;
r=par.deg.radius;
is_within = 0;
switch par.radiusShape
    case 'square'
        if x > (x0 - r) && x < (x0 + r) && y > (y0 - r) && y < (y0 + r)
            is_within = 1;
        end
    case 'circle'
        if sqrt(((x0 - x))^2 + (y0 - y)^2) < r
            is_within = 1;
        end
end

function is_down = aux_IsDisplacedDown(x,y,x0,y0,r)
%% check if (x,y) is within a rectangle of width 2*r, located below the point (x0,y0)
is_down = 0;
if abs(x0 - x) < r && y < y0
    is_down = 1;
end

function is_moving = aux_GetMonkeyMotion
% now only used for initiate trial...
global IO SETTINGS
if strcmp(SETTINGS.Motion_detection_interface,'DAQ')
    data = getsample(IO.ai);
    is_moving_jaw = data(IO.jaw) < 5;
    is_moving_body = data(IO.body) < 5;
    is_moving = [is_moving_jaw is_moving_body];
else
    if numel(SETTINGS.sensor_pins) > 4 % scanner DPZ with additional pin for scanner trigger
        sen = double(get_sensors_state(SETTINGS.pp,SETTINGS.sensor_pins));
        is_moving = [sen(3) ~sen(4)]; % sen(3) = 1 if jaw is moving, sen(3) = 0 if there is no jaw motion, sen(4) always 1 because no body motion detector connected
    else
        for n_samples = 1:10000
            sen(n_samples,:) = double(get_sensors_state(SETTINGS.pp,SETTINGS.sensor_pins));
        end
        is_moving = [max(~sen(:,3)) max(~sen(:,4))]; % setups
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

%% Stimulus related functions
function rect = aux_pr2rect(pos,rad)
%% Creates PTB rect coordinates (x1,y1,x2,y2) from one or several points and corresponding radii.
% pos ([x y]' x n) position in pixel
% rad (1 x n) , rad is the size in pixel

if isempty(pos) || isempty(rad)
    rect = [0 0 0 0];   % input check
    return
end
if numel(rad)==1
    rect = repmat(pos,2,1) + repmat([-1 -1 1 1]'*rad,1,size(pos,2));
else
    rect = repmat(pos,2,1) +  [-1 -1 1 1]'.*rad';
end

function par = aux_FillPar(par_temp)
% stim positioning info comes here in deg
%% clean up here
if ~isfield(par_temp,'ringColor')
    par_temp.ringColor = [];
end
if ~isfield(par_temp,'ringColor2')
    par_temp.ringColor2 = [0 0 0];
end
if ~isfield(par_temp,'rewardProb')
    par_temp.rewardProb = 1;
end

stim=[par_temp.x par_temp.y par_temp.size par_temp.radius];
%stim=par_temp.pos;

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
par.stimRect       = aux_pr2rect([stim(1)  stim(2)]', stim(3));
par.x              = stim(1);
par.y              = stim(2);
par.stimColor      = par_temp.color;
par.size           = stim(3);
par.ringColor      = par_temp.ringColor;
par.ringColor2     = par_temp.ringColor2; % complementary arc for gambles
% par.radius         = stim(3);
% par.radius         = stim(3)/(SETTINGS.screen_h_pix);%*0.9);
par.arcAngle       = 360 - par_temp.rewardProb*360;
par.shape          = par_temp.shape;
if isfield(par_temp, 'radiusShape')
    par.radiusShape          = par_temp.radiusShape;
else
    par.radiusShape          = 'circle';
end

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
        %Screen('FillOval', SETTINGS.window, par.stimColor, par.stimRect);
        img(:,:,1) = SETTINGS.BG_COLOR(1)*ones(20,100);
        img(:,:,2) = SETTINGS.BG_COLOR(2)*ones(20,100);
        img(:,:,3) = SETTINGS.BG_COLOR(3)*ones(20,100);
        texture = Screen('MakeTexture', SETTINGS.window, img);
        
        BarSizePix1= deg2pix_withOffset (par.shape.BarSize_L,par.offset_deg);
        BarSizePix2= deg2pix_withOffset (par.shape.BarSize_W,par.offset_deg);
        
        rectBar = [BarSizePix2 BarSizePix1 BarSizePix2 BarSizePix1];
        stimRect_Bar       = aux_pr2rect([par.x  par.y]', rectBar);
        %Screen('DrawTextures',SETTINGS.window, texture,[], stimRect_Bar,
        %par.shape.rotation); %the bar of the previously shown sample
        
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
        if isempty(par.ringColor)
            img = zeros(20,100);
        else
            img(:,:,1) = par.ringColor(1)*ones(20,100); % img = ones(20,100);
            img(:,:,2) = par.ringColor(2)*ones(20,100); % img = ones(20,100);
            img(:,:,3) = par.ringColor(3)*ones(20,100); % img = ones(20,100);
        end
        texture = Screen('MakeTexture', SETTINGS.window, img, par.shape.rotation);
        Screen('DrawTextures',SETTINGS.window, texture,[], stimRect_Bar, par.shape.rotation);
        % Screen('FrameOval', SETTINGS.window, SETTINGS.BG_COLOR, par.stimRect,7,7);
        
        
    case 'arrows'
        penWidth=4;
        symbol_distance=par.size;
        switch par.shape.option
            
            case 'LL'
                points=trianglePoints([par.x-symbol_distance par.y],par.size, 180);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(1,1),points(1,2),points(2,1),points(2,2),penWidth);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(3,1),points(3,2),points(2,1),points(2,2),penWidth);
                points=trianglePoints([par.x+symbol_distance par.y],par.size, 180);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(1,1),points(1,2),points(2,1),points(2,2),penWidth);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(3,1),points(3,2),points(2,1),points(2,2),penWidth);
            case 'RR'
                points=trianglePoints([par.x-symbol_distance par.y],par.size, 0);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(1,1),points(1,2),points(2,1),points(2,2),penWidth);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(3,1),points(3,2),points(2,1),points(2,2),penWidth);
                points=trianglePoints([par.x+symbol_distance par.y],par.size, 0);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(1,1),points(1,2),points(2,1),points(2,2),penWidth);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(3,1),points(3,2),points(2,1),points(2,2),penWidth);
            case 'LR'
                points=trianglePoints([par.x+symbol_distance par.y],par.size, 0);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(1,1),points(1,2),points(2,1),points(2,2),penWidth);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(3,1),points(3,2),points(2,1),points(2,2),penWidth);
                points=trianglePoints([par.x-symbol_distance par.y],par.size, 180);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(1,1),points(1,2),points(2,1),points(2,2),penWidth);
                Screen('DrawLine',SETTINGS.window,par.stimColor,points(3,1),points(3,2),points(2,1),points(2,2),penWidth);
        end
        
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
    case 'square_frame'
        Screen('FrameRect', SETTINGS.window, par.stimColor, par.stimRect,8); %%KK Rahmen
    case 'square'
        Screen('FillRect', SETTINGS.window, par.stimColor, par.stimRect);
    case 'triangle';
        pointList=CalculateTrianglePointList([par.x par.y],par.size);
        Screen('FillPoly', SETTINGS.window,par.stimColor, pointList);
end

if ~isempty(par.ringColor) && ~(strcmp(shape,'circle_withBar') || strcmp(shape,'bar_masked'))
    Screen('FrameOval', SETTINGS.window, par.ringColor, par.stimRect,7,7);
end

if par.arcAngle > 0,
    % cover part of the ring with black arc
    Screen('FrameArc', SETTINGS.window, par.ringColor2,par.stimRect,par.arcAngle,par.arcAngle,7,7);
    Screen('FrameArc', SETTINGS.window, [128 128 128],par.stimRect + [0;0;1;1],par.arcAngle,par.arcAngle,1,1);
end

function displaybackground(SETTINGS,task,dyn)
if strcmp(SETTINGS.background_image,'rectangles')
    rect=[];
    for t=1:numel(task.(dyn.effector).tar)
        x_rad = task.(dyn.effector).tar(t).x*pi/180;
        y_rad = task.(dyn.effector).tar(t).y*pi/180;
        offset_deg = atan(sqrt(tan(x_rad)^2 + tan(y_rad)^2));
        r= deg2pix_withOffset (task.(dyn.effector).tar(t).size,offset_deg)*2+2; %+2 because of the frame (1 pixel each direction
        baseRect = [0 0 r r];
        [x_px, y_px] = deg2pix_xy (task.(dyn.effector).tar(t).x, task.(dyn.effector).tar(t).y);
        centeredRect = CenterRectOnPointd(baseRect, x_px, y_px);
        rect = [rect centeredRect'];
    end
    
    Screen ('FrameRect', SETTINGS.window, [255 255 255], rect, 1);
end

function pointList=CalculateConvexPointList(center,a_ellipse,convexity,convex_sides)
convexity_sign=sign(convexity);
b_ellipse=abs(convexity)*a_ellipse;
b_ellipse_reference=0.2*a_ellipse;

steps_for_interpolation=100;
euclidian_distance  =(-a_ellipse):2*a_ellipse/steps_for_interpolation:(a_ellipse);
Half_circle_Area    =a_ellipse^2*pi/2;
rect_b              =(Half_circle_Area-a_ellipse*b_ellipse*pi*convexity_sign/2)/(2*a_ellipse);
rect_b_reference    =(Half_circle_Area-a_ellipse*b_ellipse_reference*pi*convexity_sign/2)/(2*a_ellipse);
tmp_bow_parameter   =sqrt((b_ellipse)^2.*(1-euclidian_distance'.^2/a_ellipse^2));
tmp_bow_reference   =sqrt((b_ellipse_reference)^2.*(1-euclidian_distance'.^2/a_ellipse^2));

bow_vector=[euclidian_distance',(tmp_bow_parameter.*convexity_sign.*-1-rect_b)];
bow_vector_reference=[euclidian_distance',(tmp_bow_reference.*convexity_sign.*-1-rect_b_reference)];

if strcmp(convex_sides,'LR')|| strcmp(convex_sides,'R') || strcmp(convex_sides,'L')
    bow_vector=[bow_vector(:,2)*-1,bow_vector(:,1)];
    bow_vector_reference=[bow_vector_reference(:,2)*-1,bow_vector_reference(:,1)];
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
pointList=pointList+repmat(center,size(pointList,1),1);

function pointList = trianglePoints(center,rad,dir)
% generates point list (<3 x [x y]> PTB coords) of an isoscele triangle
% facing direction dir (deg; 0 is right) and contained in radius rad.
theta = ( repmat(dir,1,3) + [-120 0 120] )*pi/180;
rad   = repmat(rad,1,3);
x     = rad .* cos(theta);
y     = -rad .* sin(theta); % negative because of PTB coordinate system
pointList = round([x(:) y(:)]) + repmat(center(:)',3,1); % offset for screen center

function pointList=CalculateTrianglePointList(center,side_length)
s=side_length*2;
h=sqrt(3)/2*s;
k=s.^2/(4*h)-h;
pointList(1,:) = center - [s/2 k];
pointList(2,:) = center - [-s/2 k];
pointList(3,:) = center - [0 k-h];

%% IO
function [success,dyn,task]=aux_DispenseReward(task,dyn)
%% Makes monkey happy
global SETTINGS
if SETTINGS.useParallel && dyn.duration>0
    pp=SETTINGS.pp;
    %io32(pp.ioObj,pp.address_out_reward,255);
    dyn.pp_reward_value=dyn.pp_reward_value+SETTINGS.pp.value_out_reward;
    io32(pp.ioObj,pp.address_out_reward,dyn.pp_reward_value); % open reward valve
    [success,dyn,task]=wait_while_recording_state(task,dyn);
    dyn.pp_reward_value=dyn.pp_reward_value-SETTINGS.pp.value_out_reward;
    io32(pp.ioObj,pp.address_out_reward,dyn.pp_reward_value);    % close reward valve
elseif SETTINGS.useSerial  && dyn.duration>0% use serial port instead of parallel port
    sp=SETTINGS.sp;
    set(sp,'DataTerminalReady','on');
    [success,dyn,task]=wait_while_recording_state(task,dyn);
    set(sp,'DataTerminalReady','off');
end

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
elseif strcmp(SETTINGS.microstim_interface,'Parallel') % microstim as digital output through parallel port
    dyn.pp_reward_value=dyn.pp_reward_value+SETTINGS.pp.value_out_microstim;
    io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_reward,dyn.pp_reward_value); % send microstim trigger/pulse
    tPulseDelivery = GetSecs;
    io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_reward,dyn.pp_reward_value-SETTINGS.pp.value_out_microstim); % stop microstim trigger/pulse
end

function send_to_TDT(IO,state)
global SETTINGS
if  SETTINGS.use_digital_to_TDT  %%% digital state information output to recording system for synchronization TDT
    if strcmp(SETTINGS.TDT_interface,'DAQ')
        putvalue(IO.do,state);
    elseif strcmp(SETTINGS.TDT_interface,'Parallel') && SETTINGS.useParallel
        io32(SETTINGS.pp.ioObj,SETTINGS.pp.address_out_TDT,state);
    end
end

function send_trialinfo_to_TDT(IO,dyn,fileNumber)
global SETTINGS
if  SETTINGS.use_digital_to_TDT  %%% digital state information output to recording system for synchronization TDT
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

function condition = aux_SelectCondtion(conditions)
n_condition = randperm(size(conditions,1));
condition = conditions(n_condition(1),:);

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
if ~isdir([SETTINGS.dag_drive folder(3:end)])
    mkdir([SETTINGS.dag_drive folder(3:end-8)],folder(end-7:end))
end
if exist('trial','var')
    save([SETTINGS.dag_drive folder(3:end) filesep subfolder],'SETTINGS','task','trial','sequence_indexes');
end

function autosave_changed_monkeypsych
global SETTINGS
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

