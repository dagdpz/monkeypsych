function  [pixels_x, pixels_y] = deg2pix_xy (distance_deg_x, distance_deg_y)

global SETTINGS


center_x = SETTINGS.screen_w_pix / 2;
center_y = SETTINGS.screen_h_pix*SETTINGS.screen_uh_cm/SETTINGS.screen_h_cm;
%degrees to cm from the middle
% distance_cm_x = deg2cm(SETTINGS.vd, distance_deg_x);
% distance_cm_y = deg2cm(SETTINGS.vd, distance_deg_y); 

% distance_cm_x = 2*SETTINGS.vd*tan((0.5*distance_deg_x)*pi/180);
% distance_cm_y = 2*SETTINGS.vd*tan((0.5*distance_deg_y)*pi/180);

distance_cm_x = SETTINGS.vd*tan(distance_deg_x*pi/180); % this is a new formula !
distance_cm_y = SETTINGS.vd*tan(distance_deg_y*pi/180);


% cm to pixels
pixels_per_cm_x = SETTINGS.screen_w_pix / SETTINGS.screen_w_cm;
pixels_per_cm_y = SETTINGS.screen_h_pix / SETTINGS.screen_h_cm;

n_pixels_x  = distance_cm_x * pixels_per_cm_x;
n_pixels_y  = distance_cm_y * pixels_per_cm_y;

pixels_x = round(center_x + n_pixels_x);
pixels_y = round(center_y - n_pixels_y);
