function signal_analog = DAC(signal_digital, Nd, Nz, interp_factor)
n = length(signal_digital);
N = Nd + Nz;
numOfZeros = Nd * (interp_factor-1);

signal_analog = [];
for i=1:n/N
    signal = signal_digital((i-1)*N+Nz+1:i*N);

    F = fftshift(fft(signal)) / Nd;
    F = [zeros(1, ceil(numOfZeros/2)), F, zeros(1, floor(numOfZeros/2))];

    symbol_analog = ifft(ifftshift(F)) * (interp_factor*Nd);

    symbol_analog = [symbol_analog(interp_factor*(Nd-Nz)+1 : interp_factor*Nd), symbol_analog];
    
    signal_analog = [signal_analog symbol_analog];
end

end

