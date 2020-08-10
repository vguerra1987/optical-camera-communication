%% AWG test
%
% Author: Victor Guerra, PhD
% Date: July 2020
% Instruments: Keysight 33600A and Oscilloscope for visual inspection
%
% Test description:
% This script will generate several waveforms that must be visually
% inspected. If the test passes, the user should indicate it.

awg = ArbitraryWaveformGenerator('192.168.10.10', 5025);

awg.select_awg();

% % awg.get_free_points()
% awg.auto_range(1);

awg.config(10e3);
awg.low(-0.025);
awg.high(2.5);

for I = 1:100
    
    awg.clear_waveform();
    awg.push_waveform(rand(1,40)-0.5);
    awg.load_awg_function();
    pause(2);
    
end

awg.output(1);