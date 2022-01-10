function [x y touching] = get_touch(ai)
% inputs
%   ai: Analogue input object with at least two channels
%
% outputs
%   touching (1 or 0)
%   x,y     hand position in screen pixels (origin at upper left)
%
% Last modified: 20141218 Danial
global SETTINGS

data = getsample(ai);

x = round(data(1)*SETTINGS.touchscreen_calibration.x_gain + SETTINGS.touchscreen_calibration.x_offset);
y = round(data(2)*SETTINGS.touchscreen_calibration.y_gain + SETTINGS.touchscreen_calibration.y_offset);

% if data(3) < 6
if data(1) < SETTINGS.touchscreen_calibration.x_threshold || data(2) < SETTINGS.touchscreen_calibration.y_threshold
    touching = false;
    x = nan;
    y = nan;
else
    touching = true;
end
