classdef FileTools
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
            %GETPARENTDIRECTORY go up the in the directory using the
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


        
    end
    
    
end