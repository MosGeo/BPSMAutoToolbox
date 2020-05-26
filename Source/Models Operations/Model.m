classdef Model < handle
% Model A super class to all models (1D, 2D, and 3D). Provides interface with
% different file types
%
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 

    
   properties
        modelName 
        modelFolder
        dim
        tables
   end
   
   
   methods
       
       function obj = Model(modelName, PMProjectDirectory, nDim, tables)
           
            % Constructor
            obj.modelName = modelName;
            obj.modelFolder = fullfile(PMProjectDirectory,['pm', num2str(nDim), 'd'], modelName);
            obj.dim = nDim;
            obj.tables = containers.Map;
            
            tableNames = keys(tables);
            
            % Loading all model files
            nTables = numel(tableNames);

            readStatus = false(1,nTables);
            for i = 1:nTables
                try
                    tableName = tableNames{i};
                    tableInfo  = tables(tableName);
                    tableType     = tableInfo{2};
                    tableFileName = tableInfo{1};
                    switch tableType
                        case 'pmt'
                          table.data = PMTTools.readFile(obj.getInputFileName(tableFileName, 'pmt'));               
                        case 'pma'
                          table.data = PMATools.readFile(obj.getInputFileName(tableFileName, 'pma'));               
                        case 'pmdGroup'
                          table.data = PMDGroupTools.readFile(obj.getInputFileName(tableFileName, 'pmt'));
                    end
                    readStatus(i) = true;
                    table.fileName = tableFileName;
                    table.type = tableType;
                    table.name = tableName;
                    obj.tables(tableName) = table;
                catch
                    readStatus(i) = false;
                end       
            end
                                       
        end
        
        % =========================================================
        function inputFileName = getInputFileName(obj, title, ext)
           inputFileName = fullfile(obj.modelFolder, [title, '.', ext]); 
        end
        % =========================================================  
        function [] = updateModel(obj)
            % Writes the model data from matlab to the hard disk

           tableNames = keys(obj.tables);
           for i = tableNames
                table = obj.tables(i{1});
                tableType     = table.type;
                tableFileName = table.fileName;
                data          = table.data;
                switch tableType
                    case 'pmt'
                      PMTTools.writeFile(data, obj.getInputFileName(tableFileName, 'pmt'));               
                    case 'pma'
                      PMATools.writeFile(data, obj.getInputFileName(tableFileName, 'pma'));
                    case 'pmdGroup'
                      PMDGroupTools.writeFile(data, obj.getInputFileName(tableFileName, 'pmt'));          
                end
            end
            
        end
        % =========================================================          
        function data = getData(obj, title)
            % Retrieves data from the model
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
            % Updates 
              
           % Defaults
           if ~exist('key', 'var'); key = []; end
           
           % Main
           table = obj.getTable(title);
           switch table.type
                case 'pmt'
                    table.data = PMTTools.updateData(table.data, data, key);
                    obj.tables(table.name) =  table;
                case 'pma'
                    table.data = PMATools.updateData(table.data, data, key);
                    obj.tables(table.name) = table;
                case 'pmdGroup'
                    table.data = PMDGroupTools.updateData(table.data, data);
                    obj.tables(table.name) = table;
           end
        end
        % =========================================================          
        function tableNames = getTableNames(obj)
           tableNames = keys(obj.tables);
        end
         % =========================================================                 
        function [] = printTable(obj, title)
            table = obj.getTable(title)
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
        function table = getTable(obj, title)
            table = []; 
            isTable = isKey(obj.tables,title);
            if isTable
               table = obj.tables(title);
            end
        end
        % =========================================================              

          
    end
    
    
end