function signal_digital = ADC(signal_analog, decim_factor)

signal_digital = signal_analog(1:decim_factor:end);

end

