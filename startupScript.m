close all;

Nd = 1024;
Np = 512;
Nz = 512;
refAmp = 3;
refPhase = linspace(0, 2*pi*100, Np).^2; %ph = rand(1, Np)*2*pi - pi;
%refPhase = 0;
cyclic_part = 50;
mes = randi([0, 3], 1, Nd*2);
interpolation_factor = 10;

%% transmitter (PC)
uOFDMc = ofdm_tx_dsp_prbs(mes, Nd, Np, Nz, cyclic_part, refAmp, refPhase);

%% channel
uOFDMc_analog = DAC(uOFDMc, Nd, Nz, cyclic_part, interpolation_factor);                                         %interpolation

h_channel = [zeros(1, 200) 1];
uOFDMc = channel_effects(uOFDMc, 18, 20, h_channel);
% stem(abs(uOFDMc_analog)); hold on;
% u = zeros(1, length(uOFDMc_analog)); u(1:interpolation_factor:end) = uOFDMc;
% stem(abs(u))
% figure(); stem(abs(u));
% stem(abs(uOFDMc))

uOFDMc_digital = ADC(uOFDMc_analog, interpolation_factor);                                                      %decimation

%% receiver (PC)
m = ofdm_rx_dsp_prbs(uOFDMc, Nd, Np, Nz, cyclic_part, refAmp, refPhase);