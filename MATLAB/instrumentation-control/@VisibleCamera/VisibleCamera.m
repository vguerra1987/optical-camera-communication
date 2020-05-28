classdef VisibleCamera
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    %% PRIVATE PROPERTIES %%
    %%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access=public)
        controller;
        source;
    end
    
    %%%%%%%%%%%%%%%%%%%%
    %% PUBLIC METHODS %%
    %%%%%%%%%%%%%%%%%%%%
    methods (Access=public)
        % Constructor
        function obj = VisibleCamera(index)
            obj.controller = videoinput('linuxvideo',index);
            obj.source = obj.controller.source;
            set(obj.controller, 'ReturnedColorSpace', 'rgb');
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
                set(obj.controller,field{1},params.(field{1}));
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