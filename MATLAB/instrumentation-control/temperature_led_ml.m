%% EXPERIMENT: MACHINE LEARNING, LED, and TEMPERATURE
clear; close all; clc;

% Purpose: to generate a database of RGB, Thermal, and Multispectral images
% using a Peltier-enabled LED.
%
% Methodology: 100 images of each kind will be generated for temperatures
% ranging from 10 to 40 degrees approximately (depends on Peltier
% efficiency). A stop and wait mechanism will be performed. The thermal
% camera will monitor the Peltier temperature until it reaches steady-state
% regime. Then, a couple of minutes will be added to the waiting time for
% heat diffusion to the pn-junction.
%
% The LED will be driven at 10 mA in order to minimize the effect of Joule
% heat generation. In addition, since optical cameras are used to capture
% the signal, very reduced radiances are allowed (camera's high
% sensitivity).

%% VARIABLES AND OBJECTS

% The thermal camera will monitor Peltier temperature
thermal_camera = ThermalCamera('HERE GOES THE IP', 'HERE GOES THE PORT');

% The power supply will drive the LED (or LEDs)
power_supply = PowerSupply('HERE GOES THE IP', 'HERE GOES THE PORT');
peltier_channel = 2;
led_channel = 1;

% Multispectral camera
multispectral_camera = MultiSpectralCamera('HERE GOES IP', 'HERE GOES PORT');

% CMOS camera (is USB)
visible_camera = VisibleCamera('HERE GOES THE DEVICE NUMBER');

% Number of frames to capture per temperature
frames_to_capture = 100;

% Folder, image_prefixes, and more stuff
root_folder = 'Database/';
thermal_folder = 'thermal/';
multispectral_folder = 'multispectral/';
visible_folder = 'cmos/';

% Current range for the Peltier
peltier_Imin = -1;      % This corresponds to the lowest temperature
peltier_Imax = 1;       % This corresponds to the highest temperature
peltier_Istep = 10e-3;  % Current step (10 mA)

% Current range for the LED
led_current_list = [1 5 10 15]*1e-3;


%% SETTING THINGS UP

% We define the workflow for the measurement procedure:
%
% Initialization --> Set variable --> Wait condition --> Capture
%                         ^                                 |
%                         |_________________________________|

power_supply.set_as_current_source(peltier_channel);
power_supply.set_as_current_source(led_channel);

% We ask the thermal camera to provide us a photo to define the temperature
% test point
aux_img = thermal_camera.get_frame_in_degrees();
imshow(aux_img, []);
[test_point(2), test_point(1)] = ginput();

clear aux_img

% We iterate on all the led_current_list
for led_current = led_current_list
    
    fprintf('---------------------\n');
    fprintf('LED current: %1.2f', led_current);
    fprintf('---------------------\n');
    
    currI = peltier_Imin;
    
    while (currI < peltier_Imax)
        % First of all, we must update the power supply current
        power_supply.set_current(currI, peltier_channel);
        
        % We wait until the temperature is reached
        while (~thermal_camera.is_temperature_stable(test_point))
            pause(1);
        end
        
        % Once the condition is met, we must wait a little to ensure
        % temperature diffusion to the pn-junction
        pause(30);
        
        % Now we get several frames (frames_to_capture per camera)       
        for I = 1:frames_to_capture
            photo_name = sprintf('%1.3f_%1.3f_%03d', led_current, currI, I);
            thermal_camera.capture_and_store(I, photo_name, ...
                                    [root_folder, thermal_folder]);
            multispectral_camera.capture_and_store(I, photo_name, ...
                                    [root_folder, multispectral_folder]);
            visible_camera.capture_and_store(I, photo_name, ...
                                    [root_folder, visible_folder]);
        end
        
        % We update the current
        currI = currI + peltier_Istep;
        
    end
    
end