classdef Model2D < Model
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 
   
   properties

   end
   
   methods
       
        % =========================================================          
        function obj = Model2D(modelName, PMProjectDirectory)
            
            % Define the tables to search
            tables = containers.Map;
            
            % Boundary
            tables('SWIT Table')        = {'in/swim', 'pmt'};
            tables('SWIT Group')        = {'in/switg', 'pmt'};
            tables('SWIT Trend')        = {'in/swit', 'pmt'};
            tables('SWIT Map')          = {'in/swi_m/cont', 'pmdGroup'};

            tables('Heat Flow Table')   = {'in/heat', 'pmt'};
            tables('Heat Flow Group')   = {'in/hfltg', 'pmt'};
            tables('Heat Flow Trend')   = {'in/hflt', 'pmt'};
            tables('Heat Flow Map')     = {'in/hf_m/cont', 'pmdGroup'};
            
            tables('Paleo Water Table') = {'in/palg', 'pmt'};
            tables('Paleo Water Group') = {'in/wattg', 'pmt'};
            tables('Paleo Water Trend') = {'in/watt', 'pmt'};
            tables('Paleo Water Map')   = {'in/pdp_m/cont', 'pmdGroup'};

            % Other
            tables('Fault')             = {'in/faultpropdef', 'pmt'};
            tables('Layers')            = {'in/layerdef', 'pmt'};
            tables('Facies')            = {'in/uni3', 'pmt'};
            tables('Grid')              = {'in/gref', 'pmt'};
            tables('Tools')             = {'in/tool', 'pmt'};
            tables('Rift')              = {'in/mckenzie/riftphases', 'pmt'};
            
            % Simulation
            tables('Simulation')        = {'sim_def/proj', 'pma'};
            tables('Mckenzie')          = {'def/mckenziehf_opts', 'pma'};

            % Model ts and blocks
            inDirectory = fullfile(PMProjectDirectory,['pm', num2str(2), 'd'], modelName, 'in');
            tsFolderNames = FileTools.getFolderNames(inDirectory, 'ts', true);
            for i = 1:numel(tsFolderNames)
                blDirectory   = fullfile(inDirectory, tsFolderNames{i});
                blFolderNames = FileTools.getFolderNames(blDirectory, 'bl', true);
                
                tsName = tsFolderNames{i};
                tsName = ['TS ' tsName(3:end)];
                
                for j = 1:numel(blFolderNames)
                   blockName = blFolderNames{j};
                   blockName = [tsName ' B ' blockName(3:end)];
                   
                   depthName = [blockName, ' Depth'];
                   depthFileName  = fullfile('in', tsFolderNames{i},  blFolderNames{j}, 'dpth_m', 'cont');
                   faciesName = [blockName, ' Facies'];
                   faciesFileName = fullfile('in', tsFolderNames{i},  blFolderNames{j}, 'faci_m', 'cont');
                   
                   tables(depthName) =  {depthFileName, 'pmdGroup'};
                   tables(faciesName)= {faciesFileName, 'pmdGroup'};       
                end
            end
            
            % Call general constructor
            obj = obj@Model(modelName, PMProjectDirectory, 2, tables); 
        end
        % =========================================================          

        
   end
    
end