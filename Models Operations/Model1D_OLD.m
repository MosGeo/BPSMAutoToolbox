classdef Model1D < handle
   
   properties
        modelName = '';
        modelFolder= '';
        dim = 1;
        tables = {};
        
        tableFileNames = {'in/in1d_hf',   'in/in1d_pwd',    'in/ggxy'   , 'in/in1d_swit', 'in/main1d', 'in/swio'     , 'in/tool' , 'in/mckenzie/riftphases', 'def/proj', 'def/mckenziehf_opts'}
        tableNames     = {'Heat Flow', 'Paleo Water', 'Coordinates' , 'SWIT'     , 'Main'  , 'Auto SWIT', 'Tools', 'Rifting'                         , 'Simulation', 'Mckenzie'}      
        tableTypes     = {'pmt'      , 'pmt'        , 'pmt'         , 'pmt'      , 'pmt'   , 'pmt'      , 'pmt'  , 'pmt'                             , 'pma'       , 'pma'}
        nTables = 0;
   end
   
   methods
       
        % =========================================================          
        function obj = Model1D(modelName, PMProjectDirectory)
            obj.modelName = modelName;
            obj.modelFolder = fullfile(PMProjectDirectory,['pm', num2str(obj.dim), 'd'], modelName);
            
            % Sorting for conveniance
            [obj.tableNames,I] = sort(obj.tableNames);
            obj.tableFileNames = obj.tableFileNames(I);
            obj.tableTypes     = obj.tableTypes(I);
            
            % Loading all model files
            obj.nTables = numel(obj.tableNames);

            for i = 1:obj.nTables
                tableType     = obj.tableTypes{i};
                tableFileName = obj.tableFileNames{i};
                switch tableType
                    case 'pmt'
                      obj.tables{i} = PMTTools.readFile(obj.getInputFileName(tableFileName, 'pmt'));               
                    case 'pma'
                      obj.tables{i} = PMATools.readFile(obj.getInputFileName(tableFileName, 'pma'));               
                    case 'pmdGroup'
                      obj.tables{i} = PMDTools.readFile(obj.getInputFileName(tableFileName, 'pmt'));
                end
            end
            
        end
        % =========================================================
        function inputFileName = getInputFileName(obj, title, ext)
           inputFileName = fullfile(obj.modelFolder, [title, '.', ext]); 
        end   
        % =========================================================  
        function [] = updateModel(obj)

           for i = 1:obj.nTables
                tableType     = obj.tableTypes{i};
                tableFileName = obj.tableFileNames{i};
                table         = obj.tables{i};
                switch tableType
                    case 'pmt'
                      PMTTools.writeFile(table, obj.getInputFileName(tableFileName, 'pmt'));               
                    case 'pma'
                      PMATools.writeFile(table, obj.getInputFileName(tableFileName, 'pma'));
                    case 'pmdGroup'
                      PMDGroupTools.writeFile(table, obj.getInputFileName(tableFileName, 'pmdGroup'));          
                end
            end
            
        end
        % =========================================================          
        function data = getData(obj, title)
           table = obj.getTable(title);
           switch table.type
               case 'pmt'
                   data = PMTTools.getData(table.data);
               case 'pma'
                   data = PMATools.getData(table.data);
               case 'pmdGroup'
                   data = PMDGroupTools.getData(table.data);
           end
        end
        % =========================================================          
        function [] = updateData(obj, title, data, key)
              
           % Defaults
           if ~exist('key', 'var'); key = []; end
           
           % Main
           table = obj.getTable(title);
           switch table.type
                case 'pmt'
                    obj.tables{table.index} = PMTTools.updateData(table.data, data, key);
                case 'pma'
                    obj.tables{table.index} = PMATools.updateData(table.data, data, key);
                case 'pmdGroup'
                    obj.tables{table.index} = PMDGroupTools.updateData(table.data, data);
           end
        end
        % =========================================================          
        function tableNames = getTableNames(obj)
           tableNames = obj.tableNames;
        end
         % =========================================================                 
        function [] = printTable(obj, title)
            table = obj.getTable(title);
            switch table.type
                case 'pmt'
                  PMTTools.print(table.data);              
                case 'pma'
                  PMATools.print(table.data);
                case 'pmdGroup'
                  PMDGroupTools.print(table.data);  
            end
        end
        
        % =========================================================                 
        function tableInfo = getTable(obj, title)
             [~,i]  = ismember(title, obj.tableNames);
             tableInfo.name = obj.tableNames{i};
             tableInfo.fileName = obj.tableFileNames{i};
             tableInfo.type = obj.tableTypes{i};
             tableInfo.data = obj.tables{i};
             tableInfo.index = i;
        end
        
   end
    
end