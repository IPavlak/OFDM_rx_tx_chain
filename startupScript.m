close all;

Nd = 1024;
Np = 512;
Nz = 512;
refAmp = 3;
refPhase = linspace(0, 2*pi*100, Np).^2; %ph = rand(1, Np)*2*pi - pi;
%refPhase = 0;
mes = randi([0, 3], 1, Nd*2);
interpolation_factor = 10;

%% transmitter (PC)
uOFDMc = ofdm_tx_dsp(mes, Nd, Np, Nz, refAmp, refPhase);

%% channel
uOFDMc_analog = DAC(uOFDMc, Nd, Nz, interpolation_factor);                                                          %interpolation

h_channel = [zeros(1, 200) 1];
uOFDMc_analog = channel_effects(uOFDMc_analog, 18, 20, h_channel);
% stem(abs(uOFDMc_analog)); hold on;
% u = zeros(1, length(uOFDMc_analog)); u(1:3:end) = uOFDMc;
% stem(abs(u))
% figure(); stem(abs(u));

uOFDMc_digital = ADC(uOFDMc_analog, interpolation_factor);                                                          %decimation

%% receiver (PC)
m = ofdm_rx_dsp(uOFDMc_digital, Nd, Np, Nz, refAmp, refPhase);