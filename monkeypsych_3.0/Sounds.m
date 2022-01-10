
function Sounds(SoundCase)
global SETTINGS
switch SoundCase
case 'Failure'
[wavedata freq  ] = wavread('D:\Sources\MATLAB\monkeypsych_3.0\failure.wav'); % load sound file (make sure that it is in the same folder as this script
wavedata = [wavedata,wavedata];
case 'Reward'
[wavedata freq  ] = wavread('D:\Sources\MATLAB\monkeypsych_3.0\reward.wav'); % load sound file (make sure that it is in the same folder as this script
end



PsychPortAudio('FillBuffer', SETTINGS.audioPort, wavedata'); % loads data into buffer
PsychPortAudio('Start', SETTINGS.audioPort, 1,0); %starts sound immediatley
%PsychPortAudio('Close', SETTINGS.audioPort);% Close the audio device:
