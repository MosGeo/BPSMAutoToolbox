classdef PMATools
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 
   
    methods (Static)
        
        % =========================================================          
        function pma = readFile(pmaFileName)   
            % Read PMT file
            fileID = fopen(pmaFileName,'r');
            rawText = textscan(fileID, '%s', 'Delimiter','\n');
            fclose(fileID);
            rawText = rawText{1};
            nLines = numel(rawText);
            indToRemove = false(nLines,1);
            
            for i = 1:nLines
               indToRemove(i) = isempty(rawText{i}); 
            end
            rawText(indToRemove) = [];
            pma = PMATools.deconstructfile(rawText);
        end
        % =========================================================
        function status = writeFile(pma, pmaFileName)
            % Write PMT file
            rawText = PMATools.reconstructfile(pma);
            fileID = fopen(pmaFileName,'w');
            for i = 1:numel(rawText)
                currentLine = rawText{i};
                currentLine = strrep(currentLine,'%','%%');
                fprintf(fileID, currentLine, '%s');
                fprintf(fileID, '\n');
            end
            fclose(fileID);
            status = true;
        end
        % =========================================================
        function pma = deconstructfile(rawText)
           nLines = numel(rawText);
           pma = [];
           pma.titles = [];
           pma.values = [];
           for lineNumber = 1:nLines
               splittedText = strsplit(rawText{lineNumber});
               if numel(splittedText) > 0
                 pma.titles{end+1} = splittedText{1};
                 pma.values{end+1} = strjoin(splittedText(2:end),' ');
               end
           end
        end
        % =========================================================
        function rawText = reconstructfile(pma)
           nLines = numel(pma.titles);
           rawText = cell(nLines,1);
           for i = 1:nLines
               rawText{i} = sprintf([pma.titles{i} '\t' pma.values{i}]);
           end
        end
        % =========================================================
        function data = extractMainData(pma)
          data  = [pma.titles',pma.values'];
          data(:,2) = cellfun(@(x) PMATools.attemptStr2double(strtrim(x)),data(:,2), 'UniformOutput', false); 
        end
        % =========================================================
       function [] = print(pma)
            T = table(pma.titles',pma.values', 'VariableNames', {'Title', 'Value'});
            disp(T)
       end 
        % =========================================================
  
       function [value, status] = attemptStr2double (value)
           [num, status] = str2num(value);
           if status == 1; value = num; end
       end
       
        % =========================================================
        function pma = updateDataWithKey(pma, data, key)
           
           if exist('key', 'var') && isempty(key) == false
                    oneValueData = data;
                    data = PMATools.extractMainData(pma);
                    [~,i] = ismember(key, data(:,1));
                    data{i,2} = oneValueData;
           end
           
           data(:,2) = arrayfun(@(x) num2str(x{1}) ,data(:,2),'UniformOutput',false);
           
           pma.titles = transpose(data(:,1));
           pma.values = transpose(data(:,2));
        end 
        % =========================================================
        function data = getData(pma)
          data  = [pma.titles',pma.values'];
          data(:,2) = cellfun(@(x) PMATools.attemptStr2double(strtrim(x)),data(:,2), 'UniformOutput', false); 
        end
        % =========================================================
        function pma = updateData(pma, data)
           pma.titles = transpose(data(:,1));
           pma.values = transpose(data(:,2));
        end
        % =========================================================

        
    end
    
    
end