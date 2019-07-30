function uOFDMc = ofdm_tx_dsp(msg, Nd, Np, Nz, refAmp, refPhase) %msg (brojevi 0-15)

N = Nd + Nz;                                                                                                    %Nd - broj korisnih podataka ukljucujuci pilote
n = length(msg);                                                                                                %Np - broj pilota
uOFDMc = [];                                                                                                    %Ndata - broj korisnih podataka u simbolu (kasnije)

%% generating signal
konstalacija = constellation("QPSK");

pilots_pos = [1:ceil(Nd/Np):Nd]; %round( linspace(1, Nd, Np) );                                                %pozicije pilota krecu od 1 i uniformno se rasporede
data_pos = setdiff([1:Nd], pilots_pos);                                                                        %mozda nije optimalno (bolje bi bilo da ne krecu od
                                                                                            %!!!!!!!!          %prve pozicije
Ndata = length(data_pos);                                                                                      %Ndata - broj korisnih podataka u simbolu
for k=1:floor(n/Ndata)        %OFDM symbol
    symbol = zeros(1, Nd);
    d = [];                             %data
    for i=(k-1)*Ndata+1 : k*Ndata          %subchannels
        d = [ d, konstalacija(msg(i)+1) ];
    end
    
    symbol(data_pos) = d;                                                                                      %unesi podatke u simbol na prava mjesta
    symbol(pilots_pos) = refAmp * exp(j*refPhase);                                                             %unesi pilote u simbol na prava mjesta
    
    signal = ifft(ifftshift(symbol)) * Nd;                                                                     %prebaci simbol u vremensku domenu i 
    protectSignal = signal(Nd-Nz+1:Nd);                                                                        %appendaj sve simbole
    signal = [protectSignal, signal];
    uOFDMc = [uOFDMc, signal];
end


figure(); plot(abs(uOFDMc)); 
xlabel('time'); ylabel('absolute value');
title('Absolute values of complex envelope in time')

symbol = uOFDMc(Nz+1:Nz+Nd);
amp = fftshift(fft(symbol)) / Nd; amp = abs(amp);
figure(); stem(amp);
xlabel('f'); ylabel('Amplitude');
title('Amplitude characteristic of 1st symbol');


end

