N=10;
 n=0;
Screen('Preference', 'VisualDebugLevel', 1);
for k=1:N
try
Screen(2,'Openwindow',[],[],[],[],[],3)
Screen('CloseAll');
catch e
n=n+1;
end
end
n/N