function sensor_state = get_sensors_state(pp, which_pins)
% Inputs:
% http://www.ustr.net/8051pc/parallel.shtml
% which_sensors - specific pins
% for example:
% pp = setup_pp;
% sensor_state = get_sensors_state(pp, [10 12], 2)


pins = [11 10 12 13 15];
bits = [8  7  6  5  4];

n_bit = bits(arrayfun(@(x) find(pins==x),which_pins));


%         which_sensors=[sen1 sen2 sen3 sen4];
%         which_sensors=[11 13 10 12];
%         7  6  5  4  3 [2 1 0] <- these are bits from MSB to LSB, n_bit is from MSB (7), to LSB (0) in address 379 we only have bits 7-3
%         11 10 12 13 15 _ _ _  <- these are pins
%         0  1  1  1  1         <- this is default reading when nothing is connected, 120 decimal
%         n_bit = bits(arrayfun(@(x) find(pins==x),which_sensors)); 
% 
% switch setup
%     
%     case 1
%         which_sensors=[11 13 10 12];
%         n_bit = bits(arrayfun(@(x) find(pins==x),which_sensors)); 
%         
%     case 2
%         which_sensors=[10 12 11 13];
%         n_bit = bits(arrayfun(@(x) find(pins==x),which_sensors)); 
%         
%     case 3
%         which_sensors=[10 12 11 13];
%         n_bit = bits(arrayfun(@(x) find(pins==x),which_sensors)); 
%         
%    case 4
%         which_sensors=[10 12 11 13];
%         n_bit = bits(arrayfun(@(x) find(pins==x),which_sensors));
%         
%     otherwise
%         check_sensors = 0;
% end



%if setup > 0
    datum = io32(pp.ioObj,pp.address_inp); % decimal value of the port
    sensor_state = get_parallel_port_bit(datum,n_bit);
% else 
%     sensor_state = [NaN NaN NaN NaN];
end

function bit_state = get_parallel_port_bit(datum,n_bit)
% datum - decimal reading of the port
% n_bit - which bit is inspected (1 - 8), can be vector of bits

% default conditions
% 8  7  6  5  4  [3 2 1] <- these are bits from MSB to LSB, n_bit is from MSB (7), to LSB (0) in address 379 we only have bits 7-3
% 11 10 12 13 15 _ _ _  <- these are pins

%% setup 2
% 0  1  1  1  1  [1  0  1]       <- this is default reading when nothing is connected, 120 decimal
% pin 10 - sensor 1
% pin 12 - sensor 2
% 0 [ 0  0 ]1  1 - no touch
% 0 [ 1  0 ]1  1 - touch 1
% 0 [ 0  1 ]1  1 - touch 2
% 0 [ 1  1 ]1  1 - touch 1&2



%% setup 1
% 0  0  1  0  1         <- this is default reading when nothing is connected, 40 decimal
% pin 10 is not working 

%%

bit_state = bitget(uint8(datum),n_bit);

idx_8 = find(n_bit == 8);
if ~isempty(idx_8), % 11 pin (bit 8) is inverted in software: when you connect low to it, it is reporting high (1) and vice versa
    bit_state(idx_8) = ~bit_state(idx_8);
end
end


