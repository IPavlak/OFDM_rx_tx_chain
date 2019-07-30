function [ signal ] = channel_effects(tx_signal, SNR, G, h_channel)
% Funkcija za dodavanje efekata kanala. Dodaju se sum, gusenje i visestazno
% prostiranje. Visestazno prostiranje modeliramo pomocu FIR filtra.
%
% ulazni argumenti:
% tx_signal = signal iz odasiljaca na kojeg stavljamo efekte
% SNR = zeljeni SNR u sustavu u dB
% G = gusenje kanala u dB
% h_channel = impulsni odziv kanala
%
% povratna vrijednost:
% signal = signal s nadodanim efektima kanala

%---------------------------------------------------------------------------
% Gusenje - path loss
%---------------------------------------------------------------------------
L = 10^(-G/20);
signal = tx_signal * L;

%---------------------------------------------------------------------------
% Visestazno prostiranje - multi-path propagation
%---------------------------------------------------------------------------
% h_channel = [0 0 0 0 1];
signal = conv( h_channel, signal );

%---------------------------------------------------------------------------
% Dodavanje suma u signal
%---------------------------------------------------------------------------
signal = awgn( signal , SNR, 'measured' );


end

