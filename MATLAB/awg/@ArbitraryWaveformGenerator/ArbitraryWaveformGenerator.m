classdef ArbitraryWaveformGenerator
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Public properties %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = public)
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Private properties %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (Access = private)
        
        % Communications socket
        socket = 0;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Public methods %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = public)
        
        % Constructor
        function obj = ArbitraryWaveformGenerator(IP, port)
            obj.socket = tcpip(IP,port);
            obj.socket.OutputBufferSize = 1024*16;
            obj.socket.Timeout = 2;
            fopen(obj.socket);
        end
        
        % Send waveform
        function push_waveform(obj, waveform)
            flushoutput(obj.socket);
            waveform_str = sprintf('%1.3e, ',waveform);
            waveform_str = waveform_str(1:end-2);
            word = sprintf('%s %s\n','DATA:ARB idetic,',waveform_str)
            fprintf(obj.socket, word);
        end
        
        % Clear Waveform
        function clear_waveform(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'DATA:VOL:CLE\n');
        end
        
        % Return free points
        function free_points = get_free_points(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'DATA:VOL:FREE?\n');
            free_points = fgetl(obj.socket);
        end
        
        % Select arbitrary function
        function select_awg(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'FUNCTION ARB\n');
        end
        
        % Select arbitrary function name
        function load_awg_function(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'FUNC:ARB idetic\n');
        end
        
        function apply(obj, srate, volt, off)
            flushoutput(obj.socket);
            str = sprintf('APPLY:ARBITRARY %1.3e, %1.3e, %1.3e\n', srate, volt, off);
            fprintf(obj.socket, '%s', str);
        end
        
        % Read errors
        function str = read_error(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'SYSTEM:ERROR?\n');
            str = fgetl(obj.socket);
            
            obj.clear_errors();
            
        end
        
        % Clear errors
        function clear_errors(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, '*CLS\n');
        end
        
        % Source offset
        function offset(obj, off)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'VOLTAGE:OFFSET %1.3e\n', off);
        end
        
        % Arbitratry waveform config
        function config(obj, freq)
            flushoutput(obj.socket);
            fprintf(obj.socket, sprintf('FUNC:ARB:SRATE %1.3e\n', freq));
            fprintf(obj.socket, 'FUNC:ARB:FILT NORM\n');
        end
        
        % SINE WAVE
        function sine(obj)
            flushoutput(obj.socket);
            fprintf(obj.socket, 'FUNC SIN\n');
        end

        % Auto range
        function auto_range(obj, state)
            flushoutput(obj.socket);
            if (state)
                fprintf(obj.socket, 'VOLTAGE:RANGE:AUTO ON\n');
            else
                fprintf(obj.socket, 'VOLTAGE:RANGE:AUTO OFF\n');
            end
        end
        
        % HIGH
        function high(obj, value)
            flushoutput(obj.socket);
            sprintf('VOLTAGE:HIGH %1.3e\n', value);
            fprintf(obj.socket, 'VOLTAGE:HIGH %1.3e\n', value);
        end
        
        % LOW
        function low(obj, value)
            flushoutput(obj.socket);
            sprintf('VOLTAGE:LOW %1.3e\n', value)
            fprintf(obj.socket, 'VOLTAGE:LOW %1.3e\n', value);
        end
        
        % Ouput signal
        function output(obj, state)
            flushoutput(obj.socket);
            if (state)
                fprintf(obj.socket, 'OUTPUT ON\n');
            else
                fprintf(obj.socket, 'OUTPUT OFF\n');
            end
        end
        
        % Query
        function res = query(obj, str)
            flushoutput(obj.socket);
            fprintf(obj.socket, str);
            res = fgetl(obj.socket);
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% Private methods %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
    end
    
end