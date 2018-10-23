classdef PMDGroupTools
    
    methods (Static)
        
        % =========================================================
        function pmdGroup = readFile(pmdGroupFileName)
            
            [folderName] = fileparts(pmdGroupFileName);
            % Load the pmt file
            mainFile = PMTTools.readPMTFile(pmdGroupFileName);
            pmtData = PMTTools.extractMainData(mainFile);
            pmdFileNumbers = cell2mat(pmtData(:,1));

            pmdGroup.pmds = [];
            % Load all pmd files
            for i = 1:numel(pmdFileNumbers)
                pmdFileName = fullfile(folderName, [num2str(pmdFileNumbers(i)) '.pmd']);
                pmdGroup.pmds{i} = PMDTools.readPMDFile(pmdFileName);
            end 
            
            pmdGroup.pmt  = mainFile;
            pmdGroup.Ids  = pmdFileNumbers;
            
        end
        % =========================================================
        function status = writeFile(pmdGroup, pmdGroupFileName)
            [folderName] = fileparts(pmdGroupFileName);
            % Write pmt file
            PMTTools.writePMTFile(pmdGroup.pmt, pmdGroupFileName);
            
            % Write pmd files
            for i = 1:numel(pmdGroup.Ids)
               pmdFileName = fullfile(folderName, [num2str(pmdGroup.Ids (i)) '.pmd']);
               PMDTools.writePMDFile(pmdGroup.pmds{i}, pmdFileName);
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
        function [] = updateData(pmdGroup, data)
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