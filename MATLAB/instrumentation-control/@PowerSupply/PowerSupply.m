classdef PowerSupply
    
    properties (Access=private)
        socket = 0;
    end
    
    methods
        
        function obj = PowerSupply(ip, port)
            obj.socket = tcpip(ip,port);
            obj.socket.Terminator = 'CR/LF';
            fopen(obj.socket);
        end
        
        % Set Current
        function setCurrent(obj, channel, value)
            line = sprintf(':CHAN%d:SOUR:CURR:LEV %.3e', channel, value);
            fprintf(obj.socket, line);
        end
        
        % Set Voltage
        function setVoltage(obj, channel, value)
            line = sprintf(':CHAN%d:SOUR:VOLT:LEV %.3e', channel, value);
            fprintf(obj.socket, line);
        end
        
        % Set measure to current or voltage on specific channel
        function setMeasureType(obj, channel, type)
            
            if lower(type(1)) == 'v' % voltage
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:SENS:MODE FIX', channel));
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:SENS:FUNC VOLT', channel));
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:SENS:VOLT:RANG 18', channel));
            else % current
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:SENS:MODE FIX', channel));
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:SENS:FUNC CURR', channel));
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:SENS:VOLT:RANG 2', channel));
            end
            
        end
        
        % Measure channel
        function out = getMeasure(obj, channel)
            line = sprintf(':CHAN%d:MEAS?', channel);
            fprintf(obj.socket, line);
            out = str2double(fgetl(obj.socket));
        end
        
        % Close the socket
        function close(obj)
            fclose(obj.socket);
        end
        
        % Output ON/OFF control per channel
        function channelOutput(obj, channel, state)
            if (state)
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:OUTP:STAT ON', channel));
            else
                fprintf(obj.socket, ...
                    sprintf(':CHAN%d:OUTP:STAT OFF', channel));
            end
        end
        
        % Full Ouput control
        function output(obj, state)
            channelOutput(obj, 1, state);
            channelOutput(obj, 2, state);
        end
        
        
    end
    
    
end