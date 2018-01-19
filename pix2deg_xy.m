function  [deg_x, deg_y] = pix2deg_xy(pix_x, pix_y)

global SETTINGS

% center_x_pix = SETTINGS.screen_w_pix / 2;
% center_y_pix = SETTINGS.screen_h_pix / 2;
center_x_pix = SETTINGS.screen_w_pix / 2;
center_y_pix = SETTINGS.screen_h_pix*SETTINGS.screen_uh_cm/SETTINGS.screen_h_cm;

% distance to the center in pix
dist_pix_x = pix_x - center_x_pix; 
dist_pix_y = center_y_pix - pix_y; 

pixels_per_cm_x = SETTINGS.screen_w_pix / SETTINGS.screen_w_cm;
pixels_per_cm_y = SETTINGS.screen_h_pix / SETTINGS.screen_h_cm;

dist_cm_x = dist_pix_x/pixels_per_cm_x;
dist_cm_y = dist_pix_y/pixels_per_cm_y;

%deg_x = cm2deg(SETTINGS.vd, dist_cm_x);

deg_x       = 2*atan((dist_cm_x/2)/SETTINGS.vd)/(pi/180); 
deg_y       = 2*atan((dist_cm_y/2)/SETTINGS.vd)/(pi/180); 

% 
% deg_y = cm2deg(SETTINGS.vd, dist_cm_y); 
% 
% 
% SETTINGS.screen_uh_cm       = task.screen_uh_cm;
% SETTINGS.screen_lh_deg      = atan((SETTINGS.screen_h_cm - SETTINGS.screen_uh_cm)/SETTINGS.vd)/(pi/180);
% SETTINGS.screen_uh_deg      = atan(SETTINGS.screen_uh_cm/SETTINGS.vd)/(pi/180); 
% SETTINGS.screen_h_deg       = SETTINGS.screen_lh_deg + SETTINGS.screen_uh_deg;

% SETTINGS.screen_w_deg   = cm2deg(SETTINGS.vd,SETTINGS.screen_w_cm);
% SETTINGS.screen_h_deg   = cm2deg(SETTINGS.vd,SETTINGS.screen_h_cm);

