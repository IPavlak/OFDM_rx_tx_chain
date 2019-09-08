% This script has all function calls and parameters to successfully receive, demodulate and decode 
% OFDM signal. Signal is received from hardware supported by MATLAB sdrrx object. 
% 
% Script ALGORITHM:
%     1. Collect data from hardware (sdrrx object - built-in function *)
%     2. Decimate data by decim_factor (ADC.m *)
%     3. Perform autocorrelation (OFDMautocorrelation.m * or OFDMautocorrelation_prbs.m *)
%     4. Find start of each symbol (findStart.m *)
%     5. Demodulate each symbol (OFDMdemodulation.m *)
%     6. Decode demodulated data (OFDMdecoding.m *)
%     7. If there is a text message in there display it (findMessage.m *)
% Each of these steps is in its own function and explained in more detail there
% Other useful function :
%     - EVM.m
%     - constellation.m *
%     - fos.m
% IMPORTANT: (*) means function is required by this script
% 
% Script supports two kinds of symbol prefixes (guard intervals), one is cyclic prefix and the other
% is PRBS prefix. Cyclic prefix is end of the symbol copied to the front of symbol.
% PRBS prefix is PRBS signal put in the front of symbol. PRBS has better autocorrelation properties, 
% but the spectrum of PRBS is not finite.
% If you want to use only cyclic prefix, PRBS_prefix should be set to 0, if you want to use part
% PRBS prefix, part cyclic prefix, PRBS_prefix should be set to 1 and cyclic_part is size of cyclic 
% prefix. cyclic_part is integer in interval [0, Nz], 0 meaning only PRBS prefix, and Nz meaning only 
% cyclic prefix, but if you want only cyclic prefix you should use PRBS_prefix = 0.
% 
% You can choose wheather or not real time plots and GUI for LO frequency offset compansation should be
% enabled by setting control variables real_time_graphs_enable and gui_enable to 0 or 1.
% 
% IMPORTANT: The script runs indefinitely so when you interupt it (Ctrl+C), you need to call
%            release(rx_obj) if you want to run it again
% 
% IMPORTANT: Before running this script you need to run Rx_initialization.m

close all;

%Control variables
real_time_graphs_enable = 1;
gui_enable = 1;
PRBS_prefix = 0;      % 0 means only cyclic prefix, 1 means part PREBS prefix, part cyclic prefix

%% Basic parameters of OFDM signal
Nd = 128;           % size of OFDM symbol without guard interval
Np = 64;            % number of pilots in one OFDM symbol
Nz = 64;            % size of guard interval
N = Nd + Nz;        % size of OFDM symbol

modulation = "QPSK"; % modulation type

cons = constellation(modulation);       %defines constellation

refAmp = 3;                                          % Referent amplitude of pilot carriers
refPhase = linspace(0, 2*pi*100, Np).^2;             % Referent phases of pilot carriers      ->       they need to be randomly distributed
%refPhase = rand(1, Np)*2*pi - pi;                                                                   % It's easier to have some non linear function which 
                                                                                                          % produces the same result, but can be generated 
                                                                                                          % deterministically. For some reason linearly 
                                                                                                          % distributed phases don't work
cyclic_part = 20;     % number of samples in cyclic prefix (only for PRBS_prefix = 1)
PRBS_generator = 5;   % generator of pseudo random binary series (only for PRBS_prefix = 1)

window_shift = 10;    % shift into cyclic prefix to avoid ISI (check out help OFDMdemodulation.m)

decim_factor = 3;     % decimation factor

%% ========================================================================================================
% Device parameters
device = 'AD936x';                              %device used for object initialization
ip = '192.168.3.2';                             %ip address of device
CenterFrequency = 2.4e9 +9.2e3;                 %RF center frequency
RadioBasebandRate = 1e6;                        %RF bandwidth
RadioFrameLength = 900e3;                       %samples per frame (must be divideable by 60)

% Tuning device parameters
rx_obj.BasebandSampleRate = RadioBasebandRate;
rx_obj.CenterFrequency = CenterFrequency;
rx_obj.SamplesPerFrame = RadioFrameLength;
rx_obj.UseCustomFilter = false;

rx_obj.EnableBurstMode = false;
rx_obj.GainSource = 'Manual';


% To visualize the received signal in frequency and time domain use
% Spectrum Analyzer and Time Scope System objects. In addition, set up a
% Constellation Diagram System object for plotting signal as two
% dimensional scatter diagram in the complex plane.
if real_time_graphs_enable
    spectrumScope = dsp.SpectrumAnalyzer('SampleRate', RadioBasebandRate);
    cons_gui = comm.ConstellationDiagram('ShowReferenceConstellation', false);

    dataMaxLimit = 4.5;
    cons_gui.XLimits = [-dataMaxLimit, dataMaxLimit];
    cons_gui.YLimits = [-dataMaxLimit, dataMaxLimit];

    % Create a container for the three scopes
    scopesContainer = HelperCreateScopesContainer( ...
                            {spectrumScope,cons_gui}, ...
                            'Name', 'Zynq Radio Tone Receiver', ...
                            'Layout', [2 1], ...
                            'ExpandToolstrip', false);
    scopesContainer.setColumnSpan(1,1,1);
end


%% Start receiving data and start gui for LO frequency offset compensation
if gui_enable
    transciever_gui(rx_obj);
end
RadioFrameTime  = (RadioFrameLength / RadioBasebandRate);   %in seconds
stop_time = Inf;                                            %in seconds

data = []; t = []; rest = [];

count = 0;                                                  %time counter - in seconds
while count < stop_time
%   tic;
    [data,validData,overflow] = rx_obj();                                                             % receive data from anthenna

    if (overflow > 0)
        warning('### Samples from the radio have been lost.');
    else
        disp('ok')
    end
    if validData > 0
        % Visualize frequency spectrum
        if real_time_graphs_enable
            spectrumScope(data);
        end
        
        % decimation
        data = ADC(data.', decim_factor);
        
        % add data from the last batch that wasn't processed
        data = [rest data];
        
        % DSP
        sym_num = 40;                       % number of symbols in autocorrelation
        n = length(data(1:sym_num*N));      % number of samples in autocorrelation
        if PRBS_prefix
            ofdm_autocorr = OFDMautocorrelation_prbs(data(1:sym_num*N), PRBS_generator, Nz-cyclic_part);  % autocorrelation if PRBS prefix is used
        else
            ofdm_autocorr = OFDMautocorrelation(data(1:sym_num*N), Nd, Nz);                           % autocorrelation if only cyclic prefix is used
        end
        start = findStart(ofdm_autocorr, Nd, Nz, n);                                                  % finding start of the first symbol
        start_pos = [start(1):N:length(data)];                                                        % start indexes for every symbol
        demod_data = OFDMdemodulation(data, Nd, Np, Nz, start_pos, refAmp, refPhase, window_shift);   % demodulating signal - getting IQ data
        received_msg = OFDMdecoding(demod_data, cons);                                                % decoding data
        
        findMessage(received_msg);                                                                    % find text message if it exists and display it

        % Visualize the constellation
        if real_time_graphs_enable
            cons_gui(demod_data(1:62*498).');
        end

        if length(data) - start_pos(end) < N-1                                                        % if there is half of symbol at the end of
            rest = data(start_pos(end):end);                                                          % received data batch, save it for the next batch
        else
            rest = [];
        end
    end
    count = count + RadioFrameTime;
%   t_stop = toc        % measuring time from tic (beggining of while loop);
%   t = [t t_stop];     % saving all passes of the loop (stop_time cannot be inf)

end

release(rx_obj);
release(tx);
