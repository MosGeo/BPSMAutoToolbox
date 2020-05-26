classdef FileTools
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 
    
    properties
    end
    
    methods(Static)
        
        
        %=====================================================
        function status = writeTextFile(textToWrite, fileName)
            %WRITETEXTFILE Write text file
            %   Write a text into a file
                try
                    fid = fopen(fileName,'wt');
                    fprintf(fid, textToWrite);
                    fclose(fid);
                    status = true;
                catch exc
                    status = false;
                end
        end
        %=====================================================
        function folderName = getParentDirectory(folderName, upLevels)
            % GETPARENTDIRECTORY go up the in the directory using the
            % predefined up levels
            
            % Defaults and assertions
            if ~exist('upLevels', 'var'); upLevels = 1; end
            assert(ischar(folderName), 'Folder name needs to be a string')
            assert(isa(upLevels,'double') && upLevels>0, 'Number of levels need to be an integer > 0')

            % Main
            for i =1:round(upLevels)
                [folderName,~,~] = fileparts(folderName); 
            end
        end
        %=====================================================
        function folderNames = getFolderNames(folderName, regularExpression, isDir)        
            
            dirResults  = struct2cell(dir(folderName));
            
            if isDir
                selectedDir = cell2mat(dirResults(5,:));
                dirResults = dirResults(1,selectedDir);
            end
            
            regExpResults = regexp(dirResults, regularExpression);
            f = cell2mat(cellfun(@(x) ~isempty(x), regExpResults, 'UniformOutput' , false));
            folderNames = dirResults(f);
            
        end


        
    end
    
    
end