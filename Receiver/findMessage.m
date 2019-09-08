% Function finds text message with predefined sequence of bits for start and end of message.
% Displays message
% 
% INPUTS:
%     msg - QPSK symbols representing string

function [] = findMessage(msg)
start = strfind(msg, repelem([0 3 1 2], 4));
stop = strfind(msg, repelem([2 1 3 0], 4));

str_msg = '';
for i = start+16:4:stop-4
    ascii_char = char(msg(i)*64 + msg(i+1)*16 + msg(i+2)*4 + msg(i+3));
    str_msg = [str_msg ascii_char];
end
disp(str_msg);
end

