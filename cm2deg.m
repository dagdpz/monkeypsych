function dist_deg = cm2deg(vd_cm,dist_cm)
% cm2minarc	- convert cm to degrees of visual angle
%--------------------------------------------------------------------------------
% Input(s): 	vd_cm	- viewing distance (cm)
%		dist_cm	- distance (cm)
% Output(s):	dist_deg - distance (deg)
% Usage:	dist_deg = cm2deg(vd_cm,dist_cm);
%
% Last modified 17.08.02
% Copyright (c) 2002 Igor Kagan					 
% kigor@tx.technion.ac.il
% http://igoresha.virtualave.net
%
% See also DEG2CM, VF.
%--------------------------------------------------------------------------------
 
% 57.3 cm - at this distance 1 cm is equal to one degree
dist_deg = 2*atan((dist_cm/2)/vd_cm)/(pi/180); 




 

