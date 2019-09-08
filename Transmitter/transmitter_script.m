% This script has all function calls and parameters to successfully generate and transmit 
% OFDM signal. Signal is transmitted through hardware supported by MATLAB sdrtx object. 
%--------------------------------------------------------------------------
%                           Transmitter script
%--------------------------------------------------------------------------
%This script generates OFDM signal
% Modulation used for modulating carriers is QPSK.
%**************************************************************************
%Transmitter script needs to pack original signal that has to be sent
%with certain rules which need to be known to receiver. Transmitter task
%is to incode message to be sent into constelation of chosen modulation
% (here QPSK is used). Not all carriers are used as data carriers, ones 
% that are not are pilots - referent carriers in OFDM signal which will be 
% used to estimate and compensate channel characteristic.
% After that, we need to generate modulated carriers in time domain using 
% IFFT (Inverse Fast Fourier Transform). 
%With default configuration transmitter generates referent carriers for
%every message carrier (there is same number of referent carriers as
%message carriers).Later measurments have shown that DC component should be
%removed so 1 data carrier is disguarded which means thatit does not carry 
% any usefull data
%**************************************************************************
% 
% Script ALGORITHM:
%     1. Modulate message using chosen constellation and generate OFDM signal (OFDMgenerator.m *)
%     2. Interpolate data by interp_factor (DAC.m *)
%     3. Send that OFDM signal to transmitter (sdrtx object - built-in function *)
% 
% Other useful function :
%     - QPSK_incode.m *
%     - constellation.m *
%     - fos.m
% IMPORTANT: (*) means function is required by this script
% **************************************************************************
% 
% Script supports two kinds of symbol prefixes (guard intervals), one is cyclic prefix and the other
% is PRBS prefix. Cyclic prefix is end of the symbol copied to the front of symbol.
% PRBS prefix is PRBS signal put in the front of symbol. PRBS has better autocorrelation properties, 
% but the spectrum of PRBS is not finite.
% cyclic_part is integer in interval [0, Nz], 0 meaning only PRBS prefix, and Nz meaning only cyclic 
% prefix. If you want to use only cyclic prefix, cyclic_part should be set to Nz, if you want to use
% only PRBSprefix, cyclic part should be set to 0, and if you want to use  part PRBS prefix, part 
% cyclic prefix, cyclic_part should be set to some integer between 0 and Nz.
% ****************************************************************************
% 
% Script can transmit OFDM signal and sine wave as a debugger tool.
% If you wish to send sine wave set control variable ofdm = 0.
% 
% Also you can send text messages while this script is running.
% Open .txt file specified by variable msg_file (notepad recommended),
% type some message (ASCII characters only) and save it.
% This script will automatically read and send your message.
% It will also delete the content of your file so you can type another message.
% 
% IMPORTANT: The script runs indefinitely so when you interupt it (Ctrl+C), you need to call
%            release(tx_obj) if you want to run it again
% 
% IMPORTANT: Before running this script you need to run Tx_initialization.m


close all

%Control variables
ofdm = 1;

%% Basic parameters of OFDM
Nd = 128;           % size of OFDM symbol without guard interval
Np = 64;            % number of pilots in one OFDM symbol
Nz = 64;            % size of guard interval
N = Nd + Nz;        % size of OFDM symbol

modulation = "QPSK"; % modulation type

cons = constellation(modulation); %defines constellation

refAmp = 3;                                       % Referent amplitude of pilot carriers
refPhase = linspace(0, 2*pi*100, Np).^2;          % Referent phases of pilot carriers       ->        they need to be randomly distributed
%refPhase = rand(1, Np)*2*pi - pi;                                                                  % It's easier to have some non linear function which 
                                                                                                    % produces the same result, but can be generated
                                                                                                    % deterministically. For some reason linearly 
                                                                                                    % distributed phases don't work
cyclic_part = Nz;               % number of samples of cyclic prefix in guard interval
PRBS_part = Nz - cyclic_part;   % the rest of the guard interval is PRBS signal
PRBS_generator = 5;             % seed for generating PRBS signal
PRBS_scaler = 50;               % factor which multiplies generated PRBS signal (PRBS signal consists only of 0s and 1s)

interp_factor = 3;              % interpolation factor

sym_num = 1740;                 %number of symbols in OFDM signal to be sent to transmitter in one batch

% Since we don't have real messages, we are generating random messages
msg_rand = randi([0, 3], 1, Nd/2*sym_num);  % message to be sent - random integers form 0 to 3

msg_file = 'C:\Users\esnjmtj\Desktop\datoteka.txt';

%% ========================================================================================================
% Device parameters
device = 'AD936x';                              %device used for object initialization
ip = '192.168.3.2';                             %ip address of device
CenterFrequency = 2.4e9;                        %RF center frequency
RadioBasebandRate = 1e6;                        %RF bandwidth

% Tuning device parameters
tx_obj.BasebandSampleRate = RadioBasebandRate;
tx_obj.CenterFrequency = CenterFrequency;
tx_obj.SamplesPerFrame = RadioFrameLength;
tx_obj.UseCustomFilter = false;

tx_obj.EnableBurstMode = false;
tx_obj.GainSource = 'Manual';

%%
% Generating sine wave (first step for lo frequency offset compensation)

sw = dsp.SineWave;
sw.Amplitude = 0.5;
sw.Frequency = 70e3;
sw.ComplexOutput = true;
sw.SampleRate = BasebandSampleRate;
sw.SamplesPerFrame = 1024*1536;
txWaveform = sw();


%% Start transmitting data

% counters
lost_cnt = 0;
ret_val = 0;
ispravno = 0;

while(1)
    if ofdm
%         tic;
        % Incoding text message in OFDM signal
        text=fileread (msg_file);                                     % read data from .txt file which will be sent 
        if ~isempty(text)                                                                            % via anthena
            fid=fopen(msg_file,'w');                                  %delete file content
            fclose(fid);
            msg=QPSK_incode(text);                                                                   % incode data string into constellation
            mess=[msg, msg_rand(1:end-length(msg))];                                                 % rest of the message is again radnom (garbage)
        else 
            mess=msg_rand;
        end
        
        % Generating signal
        uOFDMc = OFDMgenerator(mess, cons, Nd, Np, Nz, cyclic_part, PRBS_generator, PRBS_scaler, refAmp, refPhase);
        uOFDMc = uOFDMc / Nd;
        
        %interpolation
        uOFDMc = DAC(uOFDMc, Nd, Nz, cyclic_part, interp_factor);
        uOFDMc = uOFDMc.';
        
%       Scaling so signal would be from 0 to 1 (absolute values has to be in interval [0, 1].
        uOFDMc = uOFDMc * 0.9/0.52; 

        ret_val = tx_obj(uOFDMc);
%         stop = toc %time measurment, to make sure data is sent and received in real time
    else
        ret_val = tx_obj(txWaveform);
    end
    
    %check if data is sent successfuly
    if ret_val
        warning('Lost data!');
        lost_cnt = lost_cnt+1;
    else
        disp('ok')
        ispravno=ispravno+1;
        disp(ispravno)
    end
end

disp(lost_cnt);
release(tx_obj);