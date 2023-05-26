function mp_Sounds(SoundCase)
global SETTINGS
switch SoundCase
    case 'Failure'
        [wavedata freq] = audioread([SETTINGS.MP_PATH filesep 'failure.wav']);
        % [wavedata freq  ] = wavread('D:\Sources\MATLAB\monkeypsych_3.0\failure.wav'); 
        wavedata = [wavedata,wavedata];
    case 'Reward'
        [wavedata freq  ] = audioread([SETTINGS.MP_PATH filesep 'reward.wav']); 
        % [wavedata freq  ] = wavread('D:\Sources\MATLAB\monkeypsych_3.0\reward.wav');
end

PsychPortAudio('FillBuffer', SETTINGS.audioPort, wavedata'); % loads data into buffer
PsychPortAudio('Start', SETTINGS.audioPort, 1,0); %starts sound immediatley
%PsychPortAudio('Close', SETTINGS.audioPort);% Close the audio device:
