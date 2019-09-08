% Making constellation graph and returning it as array.
% INPUT: string s - moulation method ie. QPSK, QAM16.
% First position in an array is position of binary coded number 0, second position of number 1 and so on
% For example:
%
%   QPSK constallation is:
%                   |
%               10  |   00
%                   |
%           --------|---------        -->   returns [ 1 + 1i  1 - 1i  -1 + 1i  -1 - 1i ]
%                   |
%               11  |   01
%                   |
%
% USAGE:
%     cons_array = constellation("QUAM16");
% 
% Currently implemented: QPSK, QAM16.
%
%

function cons_array = constellation(s)
% QAM16 constellation is:
%                     |
%       0000  0100    |  1100  1000
%                     |
%                     |
%       0001  0101    |  1101  1001
%                     |
%      ---------------|--------------
%                     |
%       0011  0111    |  1111  1011
%                     |
%                     |
%       0010  0110    |  1110  1010
%                     |

if s == "QAM16"
    cons_array = ...
    [   -1+ 1i,       -1 + 1i/3,     -1 - 1i,      -1 - 1i/3, ...
     -1/3 + 1i,     -1/3 + 1i/3,   -1/3 - 1i,    -1/3 - 1i/3, ...
        1 + 1i,        1 + 1i/3,      1 - 1i,       1 - 1i/3, ...
       1/3+ 1i,      1/3 + 1i/3,    1/3 - 1i,     1/3 - 1i/3 ];

%   QPSK constallation is:
%                   |
%               10  |   00
%                   |
%           --------|---------  
%                   |
%               11  |   01
%                   |
%  

elseif s == "QPSK"
    cons_array = [ 1 + 1i  1 - 1i  -1 + 1i  -1 - 1i ];
else
    disp("Constellation not recognized or not implemented");
end
end

