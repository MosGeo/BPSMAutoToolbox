classdef Model2D < Model
   
   properties


   end
   
   methods
       
        % =========================================================          
        function obj = Model2D(modelName, PMProjectDirectory)
            
            % Define the tables to search for
            tableFileNames = {'in/swit', 'in/hflt', 'in/palg', 'in/hf_m/cont', 'in/swi_m/cont', 'in/faultpropdef'};
            tableNames     = {'SWIT', 'Heat Flow Table', 'Paleo Water Table', 'Heat Flow Map', 'Paleo Water Map', 'Fault'};    
            tableTypes     = {'pmt', 'pmt', 'pmt', 'pmdGroup', 'pmdGroup', 'pmt'};
            
            % Call general constructor
            obj = obj@Model(modelName, PMProjectDirectory, 2, tableFileNames, tableNames, tableTypes); 
        end
        % =========================================================          

        
   end
    
end