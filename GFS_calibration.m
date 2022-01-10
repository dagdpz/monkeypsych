function r = GFS_calibration(npoints)

%--------------------------------------------------------------------------
whichscreen=1;
[window,screensize]=Screen(whichscreen,'OpenWindow',0);
if(nargin==0)
    npoints=16;
end

nstartpoint = 1;
if(npoints < 0)
    npoints = abs(npoints);
    nstartpoint = npoints;
else
    strfinal=strcat(['calibration_points',blanks(1),num2str(npoints)]);
    vpx_SendCommandString(strfinal);
end

vpx_SendCommandString('calibration_snapMode ON');
vpx_SendCommandString('calibration_autoIncrement ON');

% You can adjust the calibration area within which the calibration stimulus
% points are presented.  See ViewPoint pdf manual chapter 16.9.26.
% vpx_SendCommandString('calibrationRealRect 0.2 0.2 0.8 0.8');
%vpx_SendCommandString('calibrationRealRect 0.2 0.2 0.8 0.8');

WaitSecs(1);

for i = nstartpoint : npoints
    strfinal1=strcat(['calibration_snap',blanks(1),num2str(i)]);
    [x,y]=vpx_GetCalibrationStimulusPoint(i);
    rectSmall=[(x*screensize(3))-(2.5),(y*screensize(4))-(2.5),(x*screensize(3))+(2.5),(y*screensize(4))+(2.5)];
    
    for j = 20 : -1 : 1
        rect=[(x*screensize(3))-(j*2.5),(y*screensize(4))-(j*2.5),(x*screensize(3))+(j*2.5),(y*screensize(4))+(j*2.5)];
        Screen(window,'FillRect',[0 255 0],rect);
        Screen(window,'FillRect',[255 255 255],rectSmall);
        Screen(window,'Flip');
        
        WaitSecs(0.05);
        
        Screen(window,'FillRect',[0 0 0]);
    end
    
    vpx_SendCommandString(strfinal1);
    
    for j = 2 : 20
        rect=[(x*screensize(3))-(j*2.5),(y*screensize(4))-(j*2.5),(x*screensize(3))+(j*2.5),(y*screensize(4))+(j*2.5)];
        Screen(window,'FillRect',[0 255 0],rect);
        Screen(window,'FillRect',[255 255 255],rectSmall);
        Screen(window,'Flip');
        
        WaitSecs(0.05);
    end
    
    WaitSecs(0.20);
    
    Screen(window,'FillRect',[0 0 0]);
    Screen(window,'Flip');
end
Screen(window,'Close');