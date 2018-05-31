classdef Model1D
   
   properties
        modelName = '';
        modelFolder= '';
        dim = 1;
   end
   
   
   methods
       
        % =========================================================          
        function obj = Model1D(modelName, PMProjectDirectory)
            obj.modelName = modelName;
            obj.modelFolder = fullfile(PMProjectDirectory,['pm', num2str(obj.dim), 'd'], modelName);
        end
        % =========================================================   
        function [] = updateMainTable()
            
        end
        % =========================================================

        
        
       
       
       
   end
    
end