function signal_analog = DAC(signal_digital, Nd, Nz, cyclic_part, interp_factor)
n = length(signal_digital);
N = Nd + Nz;
numOfZeros = Nd * (interp_factor-1);

signal_analog = [];
for i=1:n/N
    signal = signal_digital((i-1)*N+Nz+1:i*N);

    F = fftshift(fft(signal)) / Nd;
    F = [zeros(1, ceil(numOfZeros/2)), F, zeros(1, floor(numOfZeros/2))];

    symbol_analog = ifft(ifftshift(F)) * (interp_factor*Nd);

    cyclic_analog = symbol_analog(interp_factor*(Nd-cyclic_part)+1 : interp_factor*Nd);
    prbs_analog = prbs_interpolate(signal_digital(1:Nz-cyclic_part), interp_factor);
    symbol_analog = [prbs_analog cyclic_analog symbol_analog];
    
    signal_analog = [signal_analog symbol_analog]; 
end

end


function prbs_analog = prbs_interpolate(signal, interp_factor)

prbs_analog = repelem(signal, interp_factor);

end