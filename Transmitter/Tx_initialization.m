% This script is inititialization script for transmitter. This has to be run before transmitter_script.m
% Script initializes hardware settings.
% Some of these settings you can change from transmitter_script.m in the section "Device parameters", 
% but it is easier for example to design custom filter only once, than every time you run transmitter_script.m
% If you wish to design your own custom filter, uncomment last line in this script and change
% 'UseCustomFilter' to true.
% WARNING: Designing custom filter could couse wrong demodulation

% Device parameters
device = 'AD936x';                              %device used for object initialization
ip = '192.168.3.2';                             %ip address of device
CenterFrequency = 2.4e9;                        %RF center frequency
RadioBasebandRate = 1e6;                        %RF bandwidth

tx_obj = sdrtx(device, ...
           'IPAddress',ip, ...
           'CenterFrequency',CenterFrequency, ...
           'BasebandSampleRate',RadioBasebandRate, ...
           'ChannelMapping', 1, ...
           'Gain', -20, ... 
           'ShowAdvancedProperties', true, ...
           'UseCustomFilter', false, ...
           'OutputDataType', 'double');
       
% tx_obj.designCustomFilter();