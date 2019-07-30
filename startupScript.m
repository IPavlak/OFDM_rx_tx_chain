close all;

Nd = 1024;
Np = 512;
Nz = 512;
refAmp = 3;
refPhase = linspace(0, 2*pi*100, Np).^2; %ph = rand(1, Np)*2*pi - pi;
%refPhase = 0;

mes = randi([0, 3], 1, Nd*2);
%%
cyclic_part = 50;
% uOFDMc = ofdm_tx_dsp_prbs(mes, Nd, Np, Nz, cyclic_part, refAmp, refPhase);
uOFDMc = ofdm_tx_dsp(mes, Nd, Np, Nz, refAmp, refPhase);

% uOFDMc_analog = DAC(uOFDMc);
%%
h_channel = [zeros(1, 200) 1];
uOFDMc = channel_effects(uOFDMc, 18, 20, h_channel);
% stem(abs(uOFDMc))

%%
% m = ofdm_rx_dsp_prbs(uOFDMc, Nd, Np, Nz, cyclic_part, refAmp, refPhase);
m = ofdm_rx_dsp(uOFDMc, Nd, Np, Nz, refAmp, refPhase);