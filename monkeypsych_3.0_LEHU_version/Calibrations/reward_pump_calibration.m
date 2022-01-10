function reward_pump_calibration(hits, open_time, close_time)
% LS 20151120
% OD 20120417
global SETTINGS
get_setup_dev;
pp.ioObj = setup_pp;
 
assert(io32(pp.ioObj)==0);
for n = 1 : hits
    io32(pp.ioObj,SETTINGS.pp.address_out_reward,1);    % open reward valve
    WaitSecs(open_time); % wait(open_time)
    %byte(n) = 0;
    io32(pp.ioObj,SETTINGS.pp.address_out_reward,0);    % close reward valve
    WaitSecs(close_time); % wait(open_time)
    sprintf('%d',n)
end
WaitSecs(0.5);
Beeper(800, [1], [.2]);WaitSecs(0.2);Beeper(800, [1], [.4]);

% new valve blue is (-)


%% It may be something like this for serial port


% function test_calibration(hits, open_time, close_time)
% 
% port = 'serial'; % 'parallel' or 'serial'
% 
% pp.ioObj = io32;             % handle to parallel port object
% 
% switch port
%     case 'parallel'
%         pp.address_out_reward = hex2dec('378');   % parallel port pp.address_out_reward
%     case 'serial'
%         pp.address_out_reward = serial('com9'); % scanner, use USB-serial port
%         fopen(pp.address_out_reward);
%         set(pp.address_out_reward,'DataTerminalReady','off');
% end
% 
% assert(io32(pp.ioObj)==0);
% for n = 1 : hits
%     io32(pp.ioObj,pp.address_out_reward,1);    % open reward valve
%     WaitSecs(open_time); % wait(open_time)
%     byte(n) = 0;
%     io32(pp.ioObj,pp.address_out_reward,0);    % close reward valve
%     WaitSecs(close_time); % wait(open_time)
%     sprintf('%d',n)
% end
% 
% WaitSecs(0.5);
% Beeper(800, [1], [.2]);WaitSecs(0.2);Beeper(800, [1], [.4]);
 

