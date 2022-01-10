function  [dist_pixel] = deg2pix_withOffset (distance_deg,offset_deg)

global SETTINGS

% degrees to cm
d_rad=distance_deg*pi/180;
o_rad=offset_deg*pi/180;


distance_cm = SETTINGS.vd*(1/2)*(tan(o_rad + d_rad) - tan(o_rad - d_rad));
% cm to pixels

pixels_per_cm = SETTINGS.screen_w_pix / SETTINGS.screen_w_cm;
dist_pixel  = round(distance_cm * pixels_per_cm);





