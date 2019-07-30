% Autocorrelation of a signal that is not strictly following definition of autocorrelation.
% ALGORITHM:
%     1. Copy original signal and move it left or right by Nd.
%     2. Multiply and add signal values of original signal and delayed signal that are on the same indexes
%     
%                               si+ws-1
%                                -----
%                                \       
%         autocorrelation(si) =  /      signal(i) * conj(signal(i - Nd))     ,   where  si = start index, 
%                                -----                                                  ws = window size
%                                 i=si
%         
%     3. Every number given by that algorithm is one value of autocorrelation
% 
% 
% SCHEME FOR SIGNAL WITH CYCLIC PREFIXES:
%                  -------------------------------------------------------------------------------
%     signal:      |garbage| prefix |      Nd - useful data     | prefix |       ... 
%                  -------------------------------------------------------------------------------
%                  -------------------------------------------------------------------------------
% delayed signal:  |          Nd zeros         |garbage| prefix |       Nd - useful data     | ...     
%                  -------------------------------------------------------------------------------
%                                                      | window |  --> window (size window_size) in which 
%                                                                      aligned elements of signal and delayed 
%                                                                      signal are multiplied and then added
%                                                      
%              
%          If prefix is CYCLIC prefix autocorrelation window should be the size of that prefix and 
%          autocorrelation should give the first maximum exactly at index (Nd + garbage) which is 
%          the start of first symbol and every other maximum should be the start of each symbol.
% 
% INPUTS:
%     signal - signal for autocorrelation
%     Nd - size of useful data (size of symbol without guard interval)
%     window_size - size of a window in which autocorrelation is performed - described in algorithm above

function ofdm_autocorr = OFDMautocorrelation(signal, Nd, window_size)
n = length(signal);
block = [signal(1:end), zeros(1, Nd) ];                                                                         %get original signal and delay it
block_lagged = [zeros(1, Nd), signal(1:end)];

ofdm_autocorr = [];
win = window_size;                                                                                              %window size for autocorrelation
for i=1:n+Nd-win+1
    ofdm_autocorr = [ofdm_autocorr, abs(block(i:i+win-1) * block_lagged(i:i+win-1)') ];                         %when complex array is transposed, it also gets
end                                                                                                             %conjugated

ofdm_autocorr = ofdm_autocorr(Nd+1:end) ./ window_size;                                                         %discard first Nd samples
ofdm_autocorr = [ofdm_autocorr, zeros(1, Nd)];                                                                  %so it doesn't get out of range in findStart function

end

