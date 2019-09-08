function signal_analog = DAC(signal_digital, Nd, Nz, cyclic_part, interp_factor)
% Function interpolates signal by interp_factor.
% It uses frequency characteristic of the OFDM signal and adds zeros to both sides of the characteristic.
% Then it uses IFFT algorithm to return interpolated time domain signal.
% PRBS is interpolated manually just by repeating every zero and one interp_factor times.
% 
% INPUTS:
%     signal_digital - signal to be interpolated (array of numbers)
%     Nd - number of samples in OFDM symbol not including the guard interval, but including the pilots (integer)
%     Nz - number of samples in guard interval (integer)
%     cyclic_part - number of samples of guard interval that belong to cyclic prefix which means that they are copied from the end of the OFDM symbol, 
%                   rest of guard interval is PRBS signal (integer)
%     interp_factor - factor of interpolation (integer)

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