function ofdm_autocorr = OFDMautocorrelation_prbs(uOFDMc, PRBS_generator, PRBS_part)
% Function generates correlation of complex envelope with PRBS signal which was inserted in guard interval.
% 
% INPUTS:
%     uOFDMc - complex envelope (received complex signal in the receiver)
%     PRBS_generator - seed for generating PRBS signal
%     PRBS_part - number of samples in guard interval which belong to PRBS signal (size of PRBS part of guard interval)

prbs = nrPRBS(PRBS_generator, PRBS_part) - j*nrPRBS(PRBS_generator, PRBS_part);
prbs = prbs';

ofdm_autocorr = abs( conv( uOFDMc, conj(fliplr(prbs)) ) );
ofdm_autocorr = ofdm_autocorr(PRBS_part:end);
% same as
% ofdm_autocorr = abs(xcorr(uOFDMc, prbs));
% ofdm_autocorr = ofdm_autocorr(n-PRBS_part+1+PRBS_part-1:end);
end

