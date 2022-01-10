% Display visual feedback on touch

global SETTINGS
get_setup_dev;

rad = 5;
rads = 20;

[window screenSize] = Screen(SETTINGS.whichScreen, 'Openwindow');     % put 'window' on complete screen
Screen('FillRect', window, [0 0 0]);               % fill whole screen black
Screen('Flip',window);

if strcmp(SETTINGS.DAQ_card, 'nidaq')
    ai = analoginput('nidaq','Dev1');    % initialize analog input
    %set(ai,'InputType','SingleEnded'); % for new NI card 6221
else
    ai = analoginput('mcc');    % initialize analogue input
end

if SETTINGS.DAQSingleEnded
    set(ai,'InputType','SingleEnded'); % for new NI card 6221
end
addchannel(ai,SETTINGS.AI_channels(1));
addchannel(ai,SETTINGS.AI_channels(2));

start(ai);
WaitSecs(2);
timeBegin = GetSecs;
while true %GetSecs < timeBegin + 10
    
    xs1 = 300;
    ys1 = 200;
    xs2 = 1600;
    ys2 = 900;
    Screen('FillOval', window,[0 255 0], [951-rads 553.5-rads 951+rads 553.5+rads]);
    Screen('FillOval', window,[0 255 0], [xs1-rads ys1-rads xs1+rads ys1+rads]);
    Screen('FillOval', window,[0 255 0], [xs1-rads ys2-rads xs1+rads ys2+rads]);
    Screen('FillOval', window,[0 255 0], [xs2-rads ys1-rads xs2+rads ys1+rads]);
    Screen('FillOval', window,[0 255 0], [xs2-rads ys2-rads xs2+rads ys2+rads]);
    %[x y touching] = GetTouch(ai);
    [x y touching] = get_touch(ai);
    Screen('FillOval', window,[255 255 255], [x-rad y-rad x+rad y+rad]);
    Screen('Flip',window);
    if KbCheck                                  % check keyboard
        [~,~,keyCode,~] = KbCheck;
        if any(find(keyCode)==27) % Esc
            
            sca
            stop(ai);
            return;
        end
    end
end

sca
stop(ai);