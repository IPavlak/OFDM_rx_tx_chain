function signal_digital = ADC(signal_analog, decim_factor)
% Function decimates given signal
% 
% INPUTS:
%     signal_analog - signal to be decimated
%     decim_factor - factor of decimation
    
signal_digital = signal_analog(1:decim_factor:end);

end

