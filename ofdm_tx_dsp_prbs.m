function uOFDMc = ofdm_tx_dsp_prbs(msg, Nd, Np, Nz, cyclic_part, refAmp, refPhase) 

N = Nd + Nz;                                                                                                    %Nd - broj korisnih podataka ukljucujuci pilote
n = length(msg);                                                                                                %Np - broj pilota
PRBS_part = Nz - cyclic_part;
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
    %protectSignal = signal(Nd-Nz+1:Nd);                                                                       %appendaj sve simbole
    protectSignal = nrPRBS(5, PRBS_part) - j*nrPRBS(5, PRBS_part); 
    protectSignal = protectSignal' .* 80;                                              % !!!
    protectSignal = [protectSignal, signal(Nd-cyclic_part+1:Nd)];
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

