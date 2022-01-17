function [DATA coords parameters] = CalibrateTouchScreen(nRepetitions)
%   Calibrate touch screen. Presents regular array of targets on screen and
%   measures analogue touch screen signal when targets are touched. Returns
%   coefficients for linear relation between voltage and screen pixels.
%
%
% Input:
%   nRepetitions specifies the number of points for callibration and should
%   be the square of an integer.
%
% Output:
%   DATA (nRepetitions x 3) For each calibration point contains time stamp,
%       and data from channel 1 (horizontal) and 2 (vertical)
%   coords (nRepetitions x 2) contains x and y coordinates in screen pixels
%       of every calibration point
%   parameters (2x2) contains slope coefficient and offset for horizontal
%       and vertical dimension. 
%       [hor_slope, vert_slope; 
%        hor_offset, vert_offset]
%
%   Example
%       [DATA coords parameters] = CalibrateTouchScreen(9)
%

% Initialize
global SETTINGS
get_setup_dev;
rad = 25;

if strcmp(SETTINGS.DAQ_card, 'nidaq')
    ai = analoginput('nidaq','Dev1');    % initialize analog input
else
    ai = analoginput('mcc');    % initialize analogue input
end

if SETTINGS.DAQSingleEnded
    set(ai,'InputType','SingleEnded'); % for new NI card 6221
end

addchannel(ai,SETTINGS.AI_channels(1));
addchannel(ai,SETTINGS.AI_channels(2));

DATA = nan(nRepetitions,3);


[window screenSize] = Screen(SETTINGS.whichScreen, 'Openwindow');     % put 'window' on complete screen

width = screenSize(3);
height = screenSize(4);
xcoords = (1:sqrt(nRepetitions)) * width/(sqrt(nRepetitions)+1);
ycoords = (1:sqrt(nRepetitions)) * height/(sqrt(nRepetitions)+1);
a = repmat(ycoords,sqrt(nRepetitions),1);
coords = [repmat(xcoords',sqrt(nRepetitions),1) a(:)];

Screen('FillRect', window, [0 0 0]);               % fill whole screen black
Screen('Flip',window);
Screen('DrawText',window, 'starting callibration...', width/2, height/2, [0 255 0]);
Screen('Flip',window);

start(ai)
WaitSecs(2)

% Do callibration
for n=1:nRepetitions;
    xy = coords(n,:);
    Screen('FillOval', window,[255 0 0], [xy xy+rad]);
    Screen('Flip',window);
    WaitSecs(2);
    DATA(n,:) = [GetSecs getsample(ai)];
end
stop(ai)
sca         % close psychtoolbox

% Plot
figure(1)
plot(DATA(:,2),coords(:,1),'o')
h=lsline; set(h,'Color','r')
xlabel('voltage [mV]');
ylabel('width [px]');
stats = regstats(coords(:,1),DATA(:,2),'linear');
title(['linear fit: slope=' num2str(stats.beta(2)) ', offset=' num2str(stats.beta(1)) ]);
parameters(1:2,1) = [stats.beta(2) stats.beta(1)]';

figure(2)
plot(DATA(:,3),coords(:,2),'o')
h=lsline; set(h,'Color','r')
xlabel('voltage [mV]');
ylabel('height [px]');
stats = regstats(coords(:,2),DATA(:,3),'linear');
title(['linear fit: slope=' num2str(stats.beta(2)) ', offset=' num2str(stats.beta(1)) ]);
parameters(1:2,2) = [stats.beta(2) stats.beta(1)]';

