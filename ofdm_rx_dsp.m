function msg = ofdm_rx_dsp(uOFDMc, Nd, Np, Nz, refAmp, refPhase)

N = Nd + Nz;
n = length(uOFDMc);

%% autokorelacija apsolutne vrijednosti ofdm signala
ofdm_autocorr = OFDMautocorrelation(uOFDMc, Nd, Nz+10);

figure;
stem(ofdm_autocorr); title('Autocorrelation');

%% finding start of symbol
start = findStart(ofdm_autocorr, Nd, Nz, n);
start(1)

%% demodulacija and EVM
demod_data = OFDMdemodulation(uOFDMc, Nd, Np, Nz, start, refAmp, refPhase, 10);
cons = constellation("QPSK");

evm = EVM(demod_data, cons)

figure;
plot(real(demod_data),imag(demod_data),'.');
xlabel('real axes'); ylabel('imaginary axes');
title('Data after demodulation')

%% estimacija i dekodiranje

konstalacija = constellation("QPSK");
    
bin_code = [];

S = [];
for i=1:length(demod_data)
    d = abs(demod_data(i) - konstalacija);
    m = find(d == min(d), 1)-1;
    S = [S;m];
end

msg = reshape(S, 1, size(S, 1));

% BBS=log2(16);    % Broj bitova po simbolu 
% G=S; 
% msg=zeros(1,BBS*length(S)); 
% for k=1:BBS    
%     msg(BBS-k+1:BBS:end)=mod(G,2);    
%     G=floor(G/2);
% end
% 
% msg = reshape(msg, [16, length(msg)/16]);
% msg = 2.^(size(msg,1)-1:-1:0)*msg;
end

