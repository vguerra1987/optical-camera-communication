classdef ThermalCamera
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %% PRIVATE PROPERTIES %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access=private)
        controller;
        source;
    end
    
    %%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS %%
    %%%%%%%%%%%%%%%%%%%%
    methods (Access=public)
        % Constructor
        function obj = VisibleCamera(index)
            obj.controller = videoinput('gige',index);
            obj.source = obj.controller.source;
            % Must check more things to initialize
        end
        
        % Initialization of both controller and source
        function initialize(obj, controller_params, source_params)
            obj.initialize_controller(controller_params);
            obj.initialize_source(source_params);
        end

        % Trigger function
        function start_capture(obj)
            start(obj.controller);
            tic;
        end
        
        % Check if capture has finished
        function [out, err] = has_finished(obj)
            err = 0; % No error detected
            out = obj.controller.FramesAvailable == ...
                obj.controller.FramesPerTrigger;
            if (toc > 1.5*obj.controller.FramesPerTrigger/...
                    str2double(obj.source.FrameRate))
                err = 1;
            end
            
        end
        
        % Stop and flush
        function stop_and_flush(obj)
           stop(obj.controller);
           getdata(obj.controller);
        end
        
        % Retrieve data and store it
        function store_images(obj, prefix, folder)
            mkdir(folder);
            images = getdata(obj.controller);
            
            for I = 1:size(images,4)
                imwrite(images(:,:,:,I), ...
                    sprintf('%s%s%03d', folder, prefix, I),'JPG',...
                            'Quality',100);
            end
        end
        
        % Get Frame in Degrees
        % This functions gets just one frame.
        function frame = get_frame_in_degrees(obj)
            % We must take into account the cam configuration.
            % Currently, it is hardcoded assuming that the camera is
            % configured to its maximum resolution. Kelvin to degree
            % conversion is also carried out.
            frame = double(getsnapshot(obj)/100) - 273;
        end
        
        % Is temperature stable?
        % This function monitors if temperature has stabilized.
        function stable = is_temperature_stable(obj, test_point, ...
                                                alpha)
            % We capture one batch of 100 frames and then process it
            obj.start_capture();
            while(~obj.has_finished())
                pause(5); % This prevents CPU throttling
            end
            frames = getdata(obj);
            frames = squeeze(frames(test_point(1), test_point(2), :));
            
            % Now we must analyze the derivative using a test
            frames = diff(frames);
            
            % We return the result of a Welch's t-test on the derivative.
            % We invert the result because the null hypothesis (0) implies
            % that has stabilized (true), and the alternative 
            % hypothesis (1), the opposite (false).
            stable = 1 - ttest(frames, 0, alpha);
            
            
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%
    %% PRIVATE METHODS %%
    %%%%%%%%%%%%%%%%%%%%%
    
    methods (Access=private)
        % Initialization of the controller
        function initialize_controller(obj, params)
            % We capture the fieldnames
            fields = fieldnames(params);
            
            % We iterate on them (note the transposition which is needed
            % due to the cell-array nature of "fields"
            for field = fields'
                obj.controller.(field{1}) = params.(field{1});
            end
            
        end
        
        % Initialization of the video source
        function initialize_source(obj, params)
            % We capture the fieldnames
            fields = fieldnames(params);
            
            % We iterate on them (note the transposition which is needed
            % due to the cell-array nature of "fields"
            for field = fields'
                set(obj.source,field{1}, params.(field{1}));
            end
            
        end
    end
    
end