classdef PMDTools
    
    properties (Constant)
       machineFormat = 'ieee-be';
       precision     = 'float32';
       versions      = {'1.0'};
    end
    
    methods (Static)
        
         % =========================================================   
         function pmd = readPMDFile(pmdFileName)
            % Read PMD file
            fileID     = fopen(pmdFileName,'r');
            rawText = fscanf(fileID,'%s');
               
            % find the version number
            regExpPatter = 'Version=[0-9]\.[0-9]';
            [startIndex,endIndex] = regexp(rawText, regExpPatter);
            versionString = rawText(startIndex:endIndex);
            versionString = strsplit(versionString, '=');
            version  = versionString{2};

            % Make sure version is compatible
            assert(ismember(version, PMDTools.versions), 'PMD file version incompatible');
         
            % Extract header and data
            dataStartIndex = endIndex+1;

            % Convert data to decimal
            fseek(fileID, dataStartIndex, 'bof');
            data = fread(fileID, Inf, PMDTools.precision, 0, PMDTools.machineFormat);
            fclose (fileID);
            
            pmd.header = rawText(1:endIndex+1);
            pmd.data   = data;        
         end
        % =========================================================
         function status = writePMDFile(pmd, pmdFileName)
            % Write PMD file
            fileID = fopen(pmdFileName,'w');
            
            % Write header
            fprintf(fileID, pmd.header, '%s');
            
            % Write data
            fwrite(fileID, data, PMDTools.precision, 0, PMDTools.machineFormat);
            fclose(fileID);
            
            status = true;  
         end
        % =========================================================

    end
    
    
    
end