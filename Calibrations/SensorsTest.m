function SensorsTest
whichScreen = 0;
% window = Screen('OpenWindow', whichScreen, [0 0 0], [100 100 500 500]);
% Screen(window, 'Flip');
config_io
Screen('CloseAll');

%% input function settings
function [byte] = inp(address)

global cogent;

byte = io32(cogent.io.ioObj,address);

%% output function settings
function outportb(address,byte)

global cogent;

io32(cogent.io.ioObj,address,byte);

function config_io

global cogent;

%create IO32 interface object
clear io32;
cogent.io.ioObj = io32;

%install the inpout32.dll driver
%status = 0 if installation successful
cogent.io.status = io32(cogent.io.ioObj);
if(cogent.io.status ~= 0);
    disp('inpout32 installation failed!')
else
    disp('inpout32 (re)installation successful.');
end


%%
% input signal
in.address = hex2dec('379');   % parallel port input address
in.address2 = hex2dec('37a');
% output signal
address = hex2dec('378');   % parallel port output address

%%

while 1
   datum=inp(in.address) % read back the value written to the printer port above
   % datum=inp(in.address2)
  % fprintf('%d %d %d %d %d \n', get_parallel_port_bit(datum,8), get_parallel_port_bit(datum,7),get_parallel_port_bit(datum,6),get_parallel_port_bit(datum,5),get_parallel_port_bit(datum,4));
%     datum=inp(in.address2)
%     if (datum==88)
%         fprintf('you pressed RIGHT sensor\n')
%         time_pressed=GetSecs;
%         while true
%             current_time  = GetSecs;
%             if inp(in.address)~=88;
%                 fprintf('you released RIGHT after %.3f s\n',current_time-time_pressed);
%                 break;
%             end            
%             if current_time > time_pressed+1
%                 fprintf('you held RIGHT sensor for 1 s\n')
%                 byte=2;
%                 outportb(address,byte); %send output signal to pin 3 (byte=2) of parallel port
%                 WaitSecs(2);
%                 byte=0;
%                 outportb(address,byte); %stop output signal to pin 3 (byte=0) of parallel port
%                 break
%             end
% 
%             
%         end
%         
%         %     elseif (datum==248) %Left Button
%         %
%         %     elseif (datum==120) %Both buttons
%         
%     end
%     
    
    if KbCheck
        [~,~,keyCode,~] = KbCheck;
        if find(keyCode)==27 % Esc
            break
        end
    end
    
    WaitSecs(0.1);
    
end


