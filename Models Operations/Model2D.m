classdef Model2D < Model
   
   properties

   end
   
   methods
       
        % =========================================================          
        function obj = Model2D(modelName, PMProjectDirectory)
            
            % Define the tables to search
            tables = containers.Map;
            tables('SWIT')              = {'in/swit', 'pmt'};
            tables('Heat Flow Table')   = {'in/hflt', 'pmt'};
            tables('Paleo Water Table') = {'in/palg', 'pmt'};
            tables('Heat Flow Map')     = {'in/hf_m/cont', 'pmdGroup'};
            tables('Paleo Water Map')   = {'in/swi_m/cont', 'pmdGroup'};
            tables('Fault')             = {'in/faultpropdef', 'pmt'};
            tables('Layers')            = {'in/layerdef', 'pmt'};
            tables('Facies')            = {'in/uni3', 'pmt'};
            tables('Grid')              = {'in/gref', 'pmt'};
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