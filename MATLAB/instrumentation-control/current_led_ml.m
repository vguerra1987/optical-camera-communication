%% EXPERIMENT: MACHINE LEARNING, LED, and TEMPERATURE
clear; close all; clc;

% Purpose: to generate a database of RGB, Thermal, and Multispectral images
% using a Peltier-enabled LED.
%
% Methodology: 100 images of each kind will be generated for each current
% ranging from 0 to 100 mA. A stop and wait mechanism will be performed.
% A sufficiently high waiting time will be included to ensure temperature
% stabilization on the LED's pn-junction.

%% VARIABLES AND OBJECTS

% Number of frames to capture per temperature
% frames_to_capture = 100;

% The power supply will drive the LED (or LEDs)
power_supply = PowerSupply('192.168.10.60', 7655);
led_channel = 1;
fprintf('Power supply connected...\n');

% Multispectral camera
multispectral_camera = MultiSpectralCamera('192.168.10.4', 44100);
fprintf('Multispectral camera connected...\n');

% CMOS camera (is USB)
% An extensive description of the camera parameters is needed (exposure
% time, gamma, gain, etcetera).
% visible_camera = VisibleCamera(1);
% controller_params.FramesPerTrigger = frames_to_capture;
% % source_params.BacklightCompensation = 0;
% source_params.WhiteBalanceMode = 'manual';
% visible_camera.initialize(controller_params, source_params);


% Folder, image_prefixes, and more stuff
% root_folder = '/media/vguerra/Elements/DANIEL/CURRENT/Database/';
% visible_folder = 'visible/';

% Current range for the LED
led_current_list = linspace(0,100e-3,101);

%% SETTING THINGS UP

% We define the workflow for the measurement procedure:
%
% Initialization --> Set variable --> Wait condition --> Capture
%                         ^                                 |
%                         |_________________________________|

power_supply.setCurrent(led_channel,0);
power_supply.setMeasureType(led_channel,'v');
power_supply.channelOutput(led_channel,1);

% Waiting time
wait_time = 60;

% LED COLOR
color = 'GREEN';

% We iterate on all the led_current_list
for led_current = led_current_list
    
    fprintf('\n---------------------\n');
    fprintf('LED current: %1.3f\n', led_current);
    fprintf('---------------------\n');
    
    power_supply.setCurrent(led_channel, led_current);
    
    % We wait until the temperature is reached
    pause(wait_time);
    
    % We indicate the cameras to start the capture
%     visible_camera.start_capture();
    
    % The multispectral camera needs the number of captures to obtain
    multispectral_camera.start_capture();
    
    % We wait until the three cameras have finished
%     while ~visible_camera.has_finished()
%         fprintf('Visible camera is still capturing...\n');
%         pause(2); % This prevents CPU throttling
%     end
%     fprintf('Visible camera finished...\n');
    
    % Finally we store the thermal and visible images. Regarding the
    % multispectral images, the other computer must ensure proper image
    % IDs to organize the measurements.
    
%     photo_name = sprintf('%s_%1.3f_', color, led_current);
%     visible_camera.store_images(photo_name, ...
%         [root_folder, visible_folder]);
    
    % Finally, we check if the multispectral camera server finished
    while ~multispectral_camera.has_finished()
        fprintf('Multispectral camera is still capturing...\n');
        pause(5); % This prevents CPU throttling
    end
    fprintf('Multispectral camera finished...\n');
    multispectral_camera.move_files(sprintf('%1.3f', led_current));
    fprintf('Moving files...\n');
end