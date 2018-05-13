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


        
    end
    
    
end