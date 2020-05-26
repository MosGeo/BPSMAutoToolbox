classdef Model1D < Model
   
   properties


   end
   
   methods
       
        % =========================================================          
        function obj = Model1D(modelName, PMProjectDirectory)
            
            % Define the tables to search for
            tables = containers.Map;
            tables('Heat Flow')   = {'in/in1d_hf', 'pmt'};
            tables('Paleo Water') = {'in/in1d_pwd', 'pmt'};
            tables('Coordinates') = {'in/ggxy', 'pmt'};
            tables('SWIT')        = {'in/in1d_swit', 'pmt'};
            tables('Main')        = {'in/main1d', 'pmt'};
            tables('Auto SWIT')   = {'in/swio', 'pmt'};
            tables('Tools')       = {'in/tool', 'pmt'};
            tables('Rifting')     = {'in/mckenzie/riftphases', 'pmt'};
            tables('Simulation')  = {'def/proj', 'pma'};
            tables('Mckenzie')    = {'def/mckenziehf_opts', 'pma'};
            
            % Call general constructor
            obj = obj@Model(modelName, PMProjectDirectory, 1, tables); 
        end
        % =========================================================          
        
   end
    
end