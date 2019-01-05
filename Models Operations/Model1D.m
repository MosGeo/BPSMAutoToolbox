classdef Model1D < Model
   
   properties


   end
   
   methods
       
        % =========================================================          
        function obj = Model1D(modelName, PMProjectDirectory)
            
            % Define the tables to search for
            tableFileNames = {'in/in1d_hf',   'in/in1d_pwd',    'in/ggxy'   , 'in/in1d_swit', 'in/main1d', 'in/swio'     , 'in/tool' , 'in/mckenzie/riftphases', 'def/proj', 'def/mckenziehf_opts'};
            tableNames     = {'Heat Flow', 'Paleo Water', 'Coordinates' , 'SWIT'     , 'Main'  , 'Auto SWIT', 'Tools', 'Rifting'                         , 'Simulation', 'Mckenzie'};
            tableTypes     = {'pmt'      , 'pmt'        , 'pmt'         , 'pmt'      , 'pmt'   , 'pmt'      , 'pmt'  , 'pmt'                             , 'pma'       , 'pma'};
        
            % Call general constructor
            obj = obj@Model(modelName, PMProjectDirectory, 1, tableFileNames, tableNames, tableTypes); 
        end
        % =========================================================          
        
   end
    
end