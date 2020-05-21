classdef MultiSpectralCamera
    % The current version of this implementation will carry out a
    % workaround in order to capture images. The workaround is based on the
    % use of a Robot on a separate computer. This robot will be implemented
    % in Python and will open a TCP Socket Server. 
    
    properties (Access=private)
       socket; 
    end
    
    methods (Access=public)
       
        % Constructor
        function obj = MultiSpectralCamera(ip,port)
            obj.socket = tcpip(ip, port, 'NetworkRole','client');
            fopen(obj.socket);
        end
        
        % Start capture
        function start_capture(obj)
            fprintf(obj.socket, 'START');
        end
        
        % Check if capture has finished
        function [out, err] = has_finished(obj)
            err = 0; % No error detected
            
            % We ask the server if it has finished
            fprintf(obj.socket, 'FINISHED?');
            response = fgetl(obj.socket);
            
            % No error control implemented yet
            if response == 1
                out = 1;
            else
                out = 0;
            end
            
        end
        
        
        
    end
    
    
end