function msg = OFDMdecoding(IQ_data, cons)
% Function decodes IQ data. Decoded symbol is symbol of the point in the constellation that is the closest to
% the point of IQ_data. Data is decoded with respect to modulation type, constellations are defined in 
% function constellation.m
% 
% INPUTS:
%     IQ_data - complex numbers representing IQ data (array of complex numbers)
%     cons - array which defines constellation (array of complex numbers)
% 
% OUTPUTS:
%     msg - decoded QPSK message (array of integers from 0 to 3)

msg = zeros(1, length(IQ_data));

for i=1:length(IQ_data)
    d = abs(IQ_data(i) - cons);                                                                                 % distance of IQ point from each point in the constellation
    m = find(d == min(d), 1)-1;                                                                                 % find index of a point in constellation that has 
    msg(i) = m;                                                                                                 % minimum distance which 
end                                                                                                             % that index is at the same time decoded number of QPSK

end

