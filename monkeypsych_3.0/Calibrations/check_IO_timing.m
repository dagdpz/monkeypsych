function time=check_IO_timing(inputdevice,outputdevice)
global SETTINGS
get_setup_dev;
in=false;
out=false;
N_loops=10;
tStart=GetSecs;

if any(strcmp({inputdevice,outputdevice},'parallel'))
    clear io32;
    ppobj = io32;
    status=io32(ppobj);
    io32(ppobj,SETTINGS.pp.address_out_reward,0);
    
    pins = [11 10 12 13 15];
    bits = [8  7  6  5  4];
    n_bit = bits(arrayfun(@(x) find(pins==x),SETTINGS.sensor_pins));
end
if any(strcmp({inputdevice,outputdevice},'serial'))
    s=serial('com1');
    fopen(s);
    set(s,'DataTerminalReady', 'off')   %
end
if any(strcmp({inputdevice,outputdevice},'DAQ_digital'))
    do = digitalio(SETTINGS.DAQ_card,'Dev1');
    addline(do,0:7,SETTINGS.digital_output_port,'out');
    
end
if any(strcmp({inputdevice,outputdevice},'DAQ_analog'))
    if strcmp(SETTINGS.DAQ_card, 'nidaq')
        ai = analoginput('nidaq','Dev1');    % initialize analog input
    else
        ai = analoginput('mcc');    % initialize analogue input
    end
    if SETTINGS.DAQSingleEnded
        set(ai,'InputType','SingleEnded'); % for new NI card 6221
    end
    if strcmp(SETTINGS.DAQ_card, 'nidaq')
        ao = analogoutput('nidaq','Dev1');    % initialize analog input
    else
        ao = analogoutput('mcc');    % initialize analogue input
    end
    addchannel(ai,SETTINGS.AI_channels(1));
    addchannel(ai,SETTINGS.AI_channels(2));
    addchannel(ai,SETTINGS.AI_channels(3));
    addchannel(ai,SETTINGS.AI_channels(4));
    addchannel(ao, 0); % analog output for microstim
end

for N=1:N_loops
    out=~out;
    switch outputdevice
        case 'parallel'
            io32(ppobj,SETTINGS.pp.address_out_reward,255*out);    % open reward valve
        case 'serial'
            if out
                set(s,'DataTerminalReady', 'on')
            else
                set(s,'DataTerminalReady', 'out')
            end
        case 'DAQ_digital'
            putvalue(do,255*out);
        case 'DAQ_analog'
            putsample(ao,5*out);
    end
    
    
    if out
        t(ceil(N/2)).output_on = GetSecs-tStart;
        while true
            switch inputdevice
                case 'parallel'
                    data_tmp = io32(ppobj,SETTINGS.pp.address_inp);
                    data = bitget(uint8(data_tmp),n_bit);
                    idx_8 = find(n_bit == 8);
                    if ~isempty(idx_8), % 11 pin (bit 8) is inverted in software: when you connect low to it, it is reporting high (1) and vice versa
                        data(idx_8) = ~data(idx_8);
                    end
                case 'serial'
                case 'DAQ_digital'
                case 'DAQ_analog'
                    data = getsample(ai) > 3;   % get data
                    
            end
            in=data(1)==1;
            if in
                t(ceil(N/2)).input_on = GetSecs-tStart;
                in=false;
                break
            end
            
            if KbCheck                                  % check keyboard
                [~,~,keyCode,~] = KbCheck;
                if any(find(keyCode)==27) % Esc
                    if any(strcmp({inputdevice,outputdevice},'serial'))
                    fclose(s);
                    end
                    return;
                end
            end
        end
    else
        t(ceil(N/2)).output_off = GetSecs-tStart;
    end
end

to=[t(2:end).output_on];
tof=[t(2:end).output_off];
tin=[t(2:end).input_on];


time.input_delays=tin-to;
time.input_mean_delay=mean(time.input_delays);
time.input_std_delay=std(time.input_delays);

time.output_delays=tof-tin;
time.output_mean_delay=mean(time.output_delays);
time.output_std_delay=std(time.output_delays);

% if any(strcmp({inputdevice,outputdevice},'parallel'))
%
% end
if any(strcmp({inputdevice,outputdevice},'serial'))
    fclose(s);
end
% if any(strcmp({inputdevice,outputdevice},'DAQ_digital'))
% end
% if any(strcmp({inputdevice,outputdevice},'DAQ_analog'))
%
% stop(ai);
% end


end