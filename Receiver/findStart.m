function start = findStart(ofdm_autocorr, Nd, Nz, n)
% INPUTS:
%     ofdm_autocorr - autocorrelation of input signal (array of doubles)
%     N - length of symbol with guard interval (integer)
%     Nd - length of symbol without guard interval (integer)
%     n - length of received message. Number of received samples (integer)
%
% Function returns start of each symbol in array form.
% Also voting algorithm is performed to get best estimation of a start of first symbol.
% Rest are calculated based on the first one.
% 
% ALGORITHM:
% 1. Find local maximums of autocorrelation - that is where symbol are starting based on autocorrelation alone
%    Maximums should be spaced roughly by N.
% 2. Perform voting algorithm. Starts of symbols should be equally spaced from each other, so that means if start of a n-th symbol is
%    at index m, first symbol should start at index m-n*N+1. Every maximum of autocorrelation now acts as a vote on
%    where the first symbol should start. We take the index with the most votes.


N = Nd + Nz;
start = zeros(1,floor(n/N)+1);
interval = Nz;
for i=1:floor(n/N)                                                                                              %Finding indexes of maximums of autocorrelation
    %start(i) = find(ofdm_autocorr(N*(i-1)+1:N*i) == max(ofdm_autocorr(N*(i-1)+1:N*i)),1) + N*(i-1);
        %catching different indexes of different spikes 
        %ie. getting 1 306 307
    if i == 1
        start(i) = find(ofdm_autocorr(N*(i-1)+1:N*i) == max(ofdm_autocorr(N*(i-1)+1:N*i)),1) + N*(i-1);
    else
        start_index = lastStart+N - interval + 1;
        stop_index = lastStart+N + interval;
        if (start_index > length(ofdm_autocorr)) || (stop_index > length(ofdm_autocorr))
            break
        end
        start(i) = find(ofdm_autocorr(start_index:stop_index) == max(ofdm_autocorr(start_index:stop_index)),1) + start_index-1;
    end
    lastStart = start(i);
end

start = voting(start, N);

end

%%
function start_array = voting(start, N)
m = []; start_array = [];
for i=1:length(start)-1                                                                                         %insert all indexes of maximums into array
    m = [m, start(i) - (i-1)*N];
end

[votes, indexes] = hist(m, unique(m));                                                                          %get the indexes and their number of occurence in
[M, I] = max(votes);                                                                                            %array (votes) and get the one with most votes

[b, i1] = unique(votes,'first');                                                                                %find elements that don't repeat
[b, i2] = unique(votes,'last');                                                                                 %(they occur only once)
b = b(i1==i2);
if ~ismember(M, b)                                                                                              %if more indexes with maximum number of votes
%     disp("Warning: Number of votes not unique, maybe error");
end

symbol_start = indexes(I);
if(symbol_start < 1)
    symbol_start = 1;
end

for i=1:length(start)
    start_array(i) = symbol_start + (i-1)*N;
end
end

