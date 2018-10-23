classdef Model2D < handle
   
   properties
        modelName = '';
        modelFolder= '';
        dim = 2;
        tables = {};
        
        tableFileNames = {'swit', 'hflt', 'palg'}
        tableNames     = {'SWIT', 'Heat Flow', 'Paleo Water'}      
        tableTypes     = {'pmt', 'pmt', 'pmt'}
        nTables = 0;

   end
   
   
   methods
       
        % =========================================================          
        function obj = Model2D(modelName, PMProjectDirectory)
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
                      obj.tables{i} = PMTTools.readPMTFile(obj.getModelInputFileName(tableFileName));               
                    case 'pma'
                      obj.tables{i} = PMATools.readPMAFile(obj.getSimInputFileName(tableFileName));               
                end
            end
            
        end
        % =========================================================
        function inputFileName = getModelInputFileName(obj, title)
           inputFileName = fullfile(obj.modelFolder, 'in', [title '.pmt']); 
        end   
        % =========================================================
        function inputFileName = getSimInputFileName(obj, title)
           inputFileName = fullfile(obj.modelFolder, 'def', [title '.pma']); 
        end   
        % =========================================================  
        function [] = updateModel(obj)

           for i = 1:obj.nTables
                tableType     = obj.tableTypes{i};
                tableFileName = obj.tableFileNames{i};
                table         = obj.tables{i};
                switch tableType
                    case 'pmt'
                      PMTTools.writePMTFile(table, obj.getModelInputFileName(tableFileName));               
                    case 'pma'
                      PMATools.writePMAFile(table, obj.getSimInputFileName(tableFileName));               
                end
            end
            
        end
        % =========================================================          
        function data = getData(obj, title)
           table = obj.getTable(title);
           switch table.type
               case 'pmt'
                   data = PMTTools.extractMainData(table.data);
               case 'pma'
                   data = PMATools.extractMainData(table.data);
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
                  PMTTools.printPMT(table.data);              
                case 'pma'
                  PMATools.printPMA(table.data);              
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