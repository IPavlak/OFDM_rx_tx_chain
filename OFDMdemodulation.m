% Function performs demodulation of time signal and returns I and Q for every demodulated frequency
% Funcion is also performing a window shift on which FFT is done and compensating for the phase shift
% that is the result of such method. In that way ISI is avoided.
% 
% !!! Symbols in signal must have CYCLIC prefix due to window shift into guard interval !!!
% 
% ALGORITHM:
%     1. Get one symbol from signal without the guard interval.
%     2. Shift that window of data to the left into guard interval for window_shift samples
%     3. Perform FFT on that window
%     4. Compensate for phase shift
%     5. Get pilots and data frequences
%     6. Use pilots to compensate for the channel
%     7. Save data in array demod_data (output)
%     
% INPUTS:
%     signal - complex time signal that is to be demodulated
%     Nd - size of useful data (size of symbol without the guard interval)
%     Np - number of pilots
%     Nz - size of guard interval
%     start - array of start indexes for each symbol - indexes mark the start of guard interval
%     refAmp - referent amplitude (pilot amplitude)
%     refPhase - referent phase (pilot phase)
%     window_shift - number of samples to shift window for FFT to the left (into guard interval)

function demod_data = OFDMdemodulation(signal, Nd, Np, Nz, start, refAmp, refPhase, window_shift)
demod_data = [];
N = Nz + Nd;
ws = window_shift;                                                                                              %window shift - shifting window of symbol left 
                                                                                                                %(cyclic prefix - constallation will rotate)
                                                                                                                
freq_shift = exp(j*2*pi*ws/Nd .* linspace(0, Nd-1, Nd) );                                                       %rotating it back to get the right constellation
                                                                                                                %avoiding ISI

for i = 1:length(start)-1
    s = signal(start(i)+Nz-ws:start(i)+N-1-ws);
    ffts = fftshift(fft(s))/Nd;                                                                                 %FFT
    ffts = ffts .* freq_shift;                                                                                  %compensating phase shift due to window shifting
    
    pilots_pos = [1:ceil(Nd/Np):Nd]; %round( linspace(1, Nd, Np) );
    data_pos = setdiff([1:Nd], pilots_pos);
    
    ffts(pilots_pos) = ffts(pilots_pos) ./ (refAmp * exp(j*refPhase));                                          %channel effect on pilots
    ref_pilot = repelem(pilots_pos, ceil(Nd/Np)); ref_pilot = ref_pilot(1:Nd);                                  %each data bin has its own referent pilot bin
    ffts = ffts ./ ffts(ref_pilot);                                                                             %compensate for channel effects
    data = ffts(data_pos);
    demod_data = [demod_data, data];
    % plot(real(data),imag(data),'.');
    % pause;
   
end
end

