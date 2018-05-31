classdef Model1D < handle
   
   properties
        modelName = '';
        modelFolder= '';
        dim = 1;
        pmts = [];
        pmtFileNames = {'in1d_hf',   'in1d_pwd',    'ggxy'        , 'in1d_swit', 'main1d', 'swio'     , 'tool' , fullfile('mckenzie', 'riftphases')       }
        pmtNames     = {'Heat Flow', 'Paleo Water', 'Coordinates' , 'SWIT'     , 'Main'  , 'Auto SWIT', 'Tools', 'Mckenzie'      }
        
   end
   
   
   methods
       
        % =========================================================          
        function obj = Model1D(modelName, PMProjectDirectory)
            obj.modelName = modelName;
            obj.modelFolder = fullfile(PMProjectDirectory,['pm', num2str(obj.dim), 'd'], modelName);
            
            % Sorting for conveniance
            [obj.pmtNames,I] = sort(obj.pmtNames);
            obj.pmtFileNames = obj.pmtFileNames(I);
            
            % Loading all files
            obj.pmts = containers.Map;
            for i = 1:numel(obj.pmtNames)
                obj.pmts(obj.pmtNames{i}) = PMTTools.readPMTFile(obj.getInputFileName(obj.pmtFileNames{i}));               
            end         
        end
        % =========================================================
        function inputFileName = getInputFileName(obj, title)
           inputFileName = fullfile(obj.modelFolder, 'in', [title '.pmt']); 
        end   
        % =========================================================          
        function [] = updateModel(obj)
            for i = 1:numel(obj.pmtNames)
                PMTTools.writePMTFile(obj.pmts(obj.pmtNames{i}), obj.getInputFileName(obj.pmtFileNames{i}));               
            end     
        end
        % =========================================================          
        function data = getData(obj, title)
           data = PMTTools.getData(obj.pmts(title)); 
        end
        % =========================================================          
        function [] = updateData(obj, title, data)
           obj.pmts(title) = PMTTools.updateData(obj.pmts(title), data); 
        end
        % =========================================================          
        function tableNames = getTableNames(obj)
           tableNames = obj.pmtNames;
        end
         % =========================================================                 
        function [] = printTable(obj, title)
           PMTTools.printPMT(obj.pmts(title));
        end
      
       
       
       
   end
    
end