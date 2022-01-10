function check_monitor_t=DAG_check_monitor_timing
%check_monitor_timing(1,2,2,10)

%-----------Input definitions
Monitor=1;
Par_port_out='D050';
triggio=2;


NStimuli=100;
pulse_duration =0.000;
Flip_Lag_Rate=1.2;
%General_Lag=0.0021;
General_Lag=0.000;
Onsetframes=1;
ISIframes=1;
wait_dur = 0.06;
%wait_dur_lag=0.0000;
NStimpercycle=2;
Ntrigpercycle=7;
Nwait=3;
Ntimespercycle=Ntrigpercycle*3+NStimpercycle*4+Nwait;


%-----------Initial values for variables
Lag_1 = 2*pulse_duration+General_Lag;
Lag_2 = 2*pulse_duration+General_Lag;
Lag_3 = 2*pulse_duration+General_Lag;

% Preparing variables
time_for_flipping_on=zeros(1,NStimuli);
time_for_flipping_off=zeros(1,NStimuli);
time_for_triggering_1=zeros(1,NStimuli);
time_for_triggering_2=zeros(1,NStimuli);
time_for_triggering_3=zeros(1,NStimuli);
Times=zeros(Ntimespercycle,1);

Triggerlatencies=zeros(NStimuli,3*Ntrigpercycle);
Fliplatencies=zeros(NStimuli,2*NStimpercycle);
Preplatencies=zeros(NStimuli,2*NStimpercycle);
Waitlatencies=zeros(NStimuli,Nwait);

Latencies=[];
screenSize=[];
Lagstracked=[];
m=1;

%--------- Get Refreshrate

[window screenSize]=Screen('OpenWindow',Monitor);% put 'window' on complete screen
format long
Refresh_duration=Screen('GetFlipInterval',window);
Refresh_rate=1/Refresh_duration
format short
%Screen('Close',window);

% USB trigger settings
if triggio==1
    ioObj=[];
    comport='com3';
    s = serial(comport);
    fopen(s);
    set(s,'DataTerminalReady','off');
elseif triggio==2    
    % % LPT trigger settings
    s=[];
    clear io32;
    ioObj = io32;
    iostatus = io32(ioObj);
    if(iostatus ~= 0)
        disp('inpout32 installation failed!')
    else
        disp('inpout32 (re)installation successful.')
    end
end



%----------Lag and onset durations dependent on ther Refresh Rate??
Lag_additional=Flip_Lag_Rate*Refresh_duration;
stim_dur = Refresh_duration*Onsetframes; 
stim_soa = Refresh_duration*ISIframes; 

%---------- fill whole window black
%[window screenSize]=Screen('OpenWindow',Monitor);% put 'window' on complete screen
Screen('FillRect', window, [0 0 0]);               
Screen(window,'Flip');

for k=1:NStimuli
    m=1;
    %WaitSecs(wait_dur-wait_dur_lag);
    WaitSecs(wait_dur);
    Times(m)=GetSecs;m=m+1;
    
    %%%%----------STIMPREP-ON-1---------
    Screen('FillRect', window, [255 255 255],[0 0 200 200]);
    Screen('FillRect', window, [255 255 255],[0 screenSize(4)-200 200 screenSize(4)]);
    Screen('FillRect', window, [255 255 255],[screenSize(3)-200 0 screenSize(3) 200]);
    Screen('FillRect', window, [255 255 255],[screenSize(3)-200 screenSize(4)-200 screenSize(3) screenSize(4)]);
    Times(m)=GetSecs;m=m+1;
    %%%%----------STIMPREP-ON-1---------
    
%     
%     %%%%----------TRIGGER-0----------
% [Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
%     %%%%----------TRIGGER-0----------
%    
%    WaitSecs(randi(floor(Refresh_duration*1000)-1)/1000);    
    
    %%%%----------TRIGGER-1----------
[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
    %%%%----------TRIGGER-1----------
    
    %%%%----------FLIP-ON-1---------
    Screen(window,'Flip');     % screen "on"
    Times(m)=GetSecs;m=m+1;
    %%%%----------FLIP-ON-1---------
    
    %%%%----------TRIGGER-2----------
[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
    %%%%----------TRIGGER-2----------
    
    %%%%----------WAIT-ON-Lag_1----------
    WaitSecs(stim_dur-Lag_1-Lag_additional);
    Times(m)=GetSecs;m=m+1;
    %%%%----------WAIT-ON-Lag_1----------
    
    %%%%----------STIMPREP-OFF-1---------
    Screen('FillRect', window, [0 0 0]);
    Times(m)=GetSecs;m=m+1;
    %%%%----------STIMPREP-OFF-1---------
    
    
    %%%%----------TRIGGER-3----------

%[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);


    %%%%----------TRIGGER-3----------
    
    %%%%----------FLIP-OFF-1---------
    Screen(window,'Flip');  % screen "off"
    Times(m)=GetSecs;m=m+1;
    %%%%----------FLIP-OFF-1---------
    
    %%%%----------TRIGGER-4----------
%[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
    %%%%----------TRIGGER-4----------
    
    %%%%----------WAIT-OFF-Lag_2----------
    WaitSecs(stim_soa-Lag_2-Lag_additional);
    Times(m)=GetSecs;m=m+1;
    %%%%----------WAIT-OFF-Lag_2----------
    
    %%%%----------STIMPREP-ON-2---------
    Screen('FillRect', window, [255 255 255],[0 0 200 200]);
    Screen('FillRect', window, [255 255 255],[0 screenSize(4)-200 200 screenSize(4)]);
    Screen('FillRect', window, [255 255 255],[screenSize(3)-200 0 screenSize(3) 200]);
    Screen('FillRect', window, [255 255 255],[screenSize(3)-200 screenSize(4)-200 screenSize(3) screenSize(4)]);
    Times(m)=GetSecs;m=m+1;
    %%%%----------STIMPREP-ON-2---------
    
    %%%%----------TRIGGER-5----------

%[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
    %%%%----------TRIGGER-5----------
    
    %%%%----------FLIP-ON-2---------
    Screen(window,'Flip');     % screen "on"
    Times(m)=GetSecs;m=m+1;
    %%%%----------FLIP-ON-2---------
    
    %%%%----------TRIGGER-6----------

%[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
    %%%%----------TRIGGER-6----------
    
    %%%%----------WAIT-ON-Lag_3----------
    WaitSecs(stim_dur-Lag_3-Lag_additional);
    Times(m)=GetSecs;m=m+1;
    %%%%----------WAIT-ON-Lag_3----------
    
    %%%%----------STIMPREP-OFF-2---------
    Screen('FillRect', window, [0 0 0]);
    Times(m)=GetSecs;m=m+1;
    %%%%----------STIMPREP-OFF-2---------
    
    %%%%----------TRIGGER-7----------

%[Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m);
    
    %%%%----------TRIGGER-7----------
    
    %%%%----------FLIP-OFF-2---------
    Screen(window,'Flip');% screen "off"
    Times(m)=GetSecs;m=m+1;
    %%%%----------FLIP-OFF-2---------
    
%     Latencies=diff(Times);
%     trigg_latencies_idx      =   logical([0 1 1 1 0 1 1 1 0 0 1 1 1 0 1 1 1 0 0 1 1 1 0 1 1 1 0 0 1 1 1 0]);
%     FlipL_idx                =   logical([0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1]);
%     prep_latencies_idx       =   logical([1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0]);
%     Wait_latencies_idx       =   logical([0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0]);
%     Lag_new_1_idx            =   logical([0 0 0 0 0 1 1 1 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]);
%     Lag_new_2_idx            =   logical([0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0]);
%     Lag_new_3_idx            =   logical([0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 1 1 1 1 0]);
%     
%     
%     Triggerlatencies(k,:)=Latencies(trigg_latencies_idx);
%     Fliplatencies(k,:)=Latencies(FlipL_idx);
%     Preplatencies(k,:)=Latencies(prep_latencies_idx);
%     Waitlatencies(k,:)=Latencies(Wait_latencies_idx);
%     Lag_new_1=sum(Latencies(Lag_new_1_idx));
%     Lag_new_2=sum(Latencies(Lag_new_2_idx));
%     Lag_new_3=sum(Latencies(Lag_new_3_idx));
%     Lagstracked=[Lagstracked; Lag_new_1 Lag_new_2 Lag_new_3];
%     
    %precise_loop_end=GetSecs;
    %wait_dur_lag=precise_loop_end-Times(end);
    
    
end
if triggio==1
fclose(s); %close trgger port
end
sca



LT_mean_each_loop=mean(Lagstracked(2:end,:),1);
LT_std_each_loop=std(Lagstracked(2:end,:),1);
PrepL_mean_each_loop=mean(Preplatencies(2:end,:),1);
PrepL_std_each_loop=std(Preplatencies(2:end,:),1);
FlipL_mean_each_loop=mean(Fliplatencies(2:end,2:end),1);
FlipL_std_each_loop=std(Fliplatencies(2:end,2:end),1);
TrigL_mean_each_loop=mean(Triggerlatencies(2:end,:),1);
TrigL_std_each_loop=std(Triggerlatencies(2:end,:),1);
index_t=1:(length(TrigL_mean_each_loop));
index_p=1:length(PrepL_mean_each_loop);

LT_mean=mean(LT_mean_each_loop);
LT_std=mean(LT_std_each_loop);
FlipL_mean=mean(FlipL_mean_each_loop);
FlipL_std=mean(FlipL_std_each_loop);
TrigL_change_mean=mean(TrigL_mean_each_loop((mod(index_t+1,3)~=0)));
TrigL_change_std=mean(TrigL_std_each_loop((mod(index_t+1,3)~=0)));
TrigL_on_mean=mean(TrigL_mean_each_loop(mod(index_t+1,3)==0));
TrigL_on_std=mean(TrigL_std_each_loop((mod(index_t+1,3)==0)));

PrepL_stim_mean=mean(PrepL_mean_each_loop((mod(index_p,2)==0)));
PrepL_stim_std=mean(PrepL_std_each_loop((mod(index_p,2)==0)));
PrepL_black_mean=mean(PrepL_mean_each_loop((mod(index_p,2)~=0)));
PrepL_black_std=mean(PrepL_std_each_loop((mod(index_p,2)~=0))); 

TL_change_1=Triggerlatencies (1,1);
TL_on_1=Triggerlatencies (1,2);
FL_1=Fliplatencies (1,2);
PL_stim_1=Preplatencies(1,1);
PL_black_1=Preplatencies(1,2);
WL_std=std(Waitlatencies);
% LT=Lagstracked (1:2,1);
% 
% 
% format shortE
% Fliplatencies (1:2,1)
% %Preplatencies
% Latency_results=[FlipL_mean FlipL_std FL_1; PrepL_stim_mean PrepL_stim_std PL_stim_1; PrepL_black_mean PrepL_black_std PL_black_1; TrigL_change_mean TrigL_change_std TL_change_1; TrigL_on_mean TrigL_on_std TL_on_1]
% format short

return
end

function [Times,m]=send_trigger(triggio, pulse_duration, s, ioObj,Par_port_out,Times,m)
if triggio==1
    set(s,'DataTerminalReady','on');
    Times(m)=GetSecs;m=m+1;
    WaitSecs(pulse_duration);
    Times(m)=GetSecs;m=m+1;
    set(s,'DataTerminalReady','off');
elseif triggio==2
    io32(ioObj, hex2dec(Par_port_out), 1);
    Times(m)=GetSecs;m=m+1;
    WaitSecs(pulse_duration);
    Times(m)=GetSecs;m=m+1;
    io32(ioObj, hex2dec(Par_port_out), 0);
end

    Times(m)=GetSecs;m=m+1;
end



