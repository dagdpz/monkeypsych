function ppobj = setup_pp
%global SETTINGS
%get_setup
%create IO32 interface object
clear io32;
ppobj = io32;

%install the inpout32.dll driver
%status = 0 if installation successful
status = io32(ppobj);
if(status ~= 0);
    disp('inpout32 installation failed!')
else
    disp('inpout32 (re)installation successful.');
end

% if SETTINGS.setup==3
%     pp.address_inp = hex2dec('D051'); % e.g. sensors
%     pp.address_out_reward = hex2dec('D050'); % e.g. reward
%     %pp.address_out_reward = hex2dec('D052'); % e.g. reward ... this is in case we want to send state information via PP
% else
%     % % input signal
%     pp.address_inp = hex2dec('379'); % e.g. sensors
%     pp.address_out_reward = hex2dec('378'); % e.g. reward
% end
