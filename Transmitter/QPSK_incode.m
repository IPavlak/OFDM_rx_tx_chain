function qpsk_msg = QPSK_incode(text)
%this function incodes input characters on constellation
%--------------------------------------------------------------------------
%Input argument is text (in this case from .txt file)
%Output is array of QPSK symbols ready for OFDMgenerator
%--------------------------------------------------------------------------
n = length(text);
ascii_numbers = uint8(text);                                        %ASCII characters to integers
bin_vector = decimalToBinaryVector(ascii_numbers, 8);               %integers to binary nubmers
bin_vector = reshape(bin_vector', 1, n*8);

qpsk_msg = zeros(1, length(bin_vector)/2);                          %initialization
for i = 1:2:length(bin_vector)
    qpsk_msg((i+1)/2) = bin_vector(i)*2 + bin_vector(i+1);          %grouping into numbers ranging from 0 to 3 (for QPSK)
end

qpsk_msg = [repelem([0 3 1 2], 4), qpsk_msg, repelem([2 1 3 0], 4)]; %transmitted message = [start sequence, message , stop sequence] 
end

