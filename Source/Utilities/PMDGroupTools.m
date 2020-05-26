classdef PMDGroupTools
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 
    
    methods (Static)
        
        % =========================================================
        function pmdGroup = readFile(pmdGroupFileName)
            
            [folderName] = fileparts(pmdGroupFileName);
            % Load the pmt file
            mainFile = PMTTools.readFile(pmdGroupFileName);
            pmtData = PMTTools.getData(mainFile);
            pmdFileNumbers = cell2mat(pmtData(:,1));

            pmdGroup.pmds = [];
            % Load all pmd files
            for i = 1:numel(pmdFileNumbers)
                pmdFileName = fullfile(folderName, [num2str(pmdFileNumbers(i)) '.pmd']);
                pmdGroup.pmds{i} = PMDTools.readFile(pmdFileName);
            end 
            
            pmdGroup.pmt  = mainFile;
            pmdGroup.Ids  = pmdFileNumbers;
            
        end
        % =========================================================
        function status = writeFile(pmdGroup, pmdGroupFileName)
            [folderName] = fileparts(pmdGroupFileName);
            % Write pmt file
            PMTTools.writeFile(pmdGroup.pmt, pmdGroupFileName);
            
            % Write pmd files
            for i = 1:numel(pmdGroup.Ids)
               pmdFileName = fullfile(folderName, [num2str(pmdGroup.Ids (i)) '.pmd']);
               PMDTools.writeFile(pmdGroup.pmds{i}, pmdFileName);
            end
            
            status = true;
        end
        % =========================================================
        function data = getData(pmdGroup)
            data = [];
            for i = 1:numel(pmdGroup.Ids)
                data = [data; pmdGroup.pmds{i}.data'];
            end
        end
        % =========================================================
        function pmdGroup = updateData(pmdGroup, data)
            for i = 1:numel(pmdGroup.Ids)
                pmdGroup.pmds{i}.data = data(i,:); 
            end
        end
        % =========================================================
        function [] = print(pmdGroup)
            PMTTools.print(pmdGroup.pmt);
        end
        

    end
    
    
end