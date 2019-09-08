function uOFDMc = OFDMgenerator(msg, cons, Nd, Np, Nz, cyclic_part, PRBS_generator, PRBS_scaler, refAmp, refPhase) 
% Generating OFDM signal composed of OFDM symbols.
% Each OFDM symbol has N samples, Nz of which is guard interval and Nd samples are data samples (with Np pilots).
% Message (msg) are integers from 0 to maximum number depending on constellation ie. for QPSK -> from 0 to 3, for QAM16 -> from 0 to 15.
% Every OFDM symbol has guard interval that has cyclic part and PRBS part, cyclic part is an integer indicationg number of samples 
% to be cyclicly repeated. Consequently number of samples belonging to PRBS part is the rest of guard interval (Nz - cyclic_part).
% 
% Result of a function is a complex envelope of all OFDM symbols.
% If message does not contain enough integers to fill all the data samples in last OFDM symbol, that OFDM symbol is discarded. 
% 
% INPUTS:
%     msg - message, integers to be mapped into given constellation, Constellations are defined in function constellation.m
%     cons - array which defines constellation
%     Nd - number of samples in OFDM symbol not including the guard interval (but including the pilots)
%     Nz - number of samples in guard interval
%     cyclic_part - number of samples of guard interval that belong to cyclic prefix which means that they are copied from the end of the OFDM symbol, 
%                   rest of guard interval is PRBS signal
%     PRBS_generator - seed for generating PRBS signal
%     PRBS_scaler - factor which multiplies generated PRBS signal (PRBS signal are 0s and 1s)
%     refAmp - referent amplitude for each of the pilots
%     refPhase - referent phase of each pilot

N = Nd + Nz;
n = length(msg);
PRBS_part = Nz - cyclic_part;
uOFDMc = [];

%msg without DC 
idx=[33:64:n];
c=false(1,n+length(idx));
c(idx)=true;
result=nan(size(c));
result(~c)=msg;
result(c)=0;
msg=result;


%% generating signal
pilots_pos = [1:ceil(Nd/Np):Nd];              
data_pos = setdiff([1:Nd], pilots_pos);                                                                        
                                                                                                               
Ndata = length(data_pos);                                                                                       
                                                                                                               
for k=1:floor(n/Ndata)                                                                                         %each iteration appends one OFDM symbol
    symbol = zeros(1, Nd);
    d = [];
    for i=(k-1)*Ndata+1 : k*Ndata                                                                              % mapping the message into constellation
        d = [ d, cons(msg(i)+1) ];
    end
    
    symbol(data_pos) = d;                                                                                      %insert message data into signal (freq. domain)
    symbol(pilots_pos) = refAmp .* exp(j*refPhase);                                                            %insert pilots into signal (freq. domain)
    
    signal = ifft(ifftshift(symbol)) * Nd;                                                                     %OFDM modulation (time domain)
    protectSignal = nrPRBS(PRBS_generator, PRBS_part) - j*nrPRBS(PRBS_generator, PRBS_part);                   %guard interval (PRBS + cyclic prefix)
    protectSignal = protectSignal' .* PRBS_scaler;
    protectSignal = [protectSignal, signal(Nd-cyclic_part+1:Nd)];
    signal = [protectSignal, signal];                                                                          %append symbol in time domain to the whole signal
    uOFDMc = [uOFDMc, signal];
end


end

