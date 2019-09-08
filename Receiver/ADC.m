function signal_digital = ADC(signal_analog, decim_factor)
% Function decimates given signal
% 
% INPUTS:
%     signal_analog - signal to be decimated (array of complex numbers)
%     decim_factor - factor of decimation (integer)
    
signal_digital = signal_analog(1:decim_factor:end);

end

