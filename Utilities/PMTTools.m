classdef PMTTools
    
    % c       : comment
    % Head    : header
    % Key     : key
    % Stop    : stop
    % Format  : format
    % Data    : data
    
    methods (Static)
       
        % =========================================================          
        function pmt = readPMTFile(pmtFileName)   
            % Read PMT file
            fileID = fopen(pmtFileName,'r');
            rawText = textscan(fileID, '%s', 'Delimiter','\n');
            rawText = rawText{1};
            fclose(fileID);   
            pmt = PMTTools.deconstructPMTfile(rawText);
        end
        % =========================================================
        function status = writePMTFile(pmt, pmtFileName)
            % Write PMT file
            rawText = PMTTools.reconstructPMTfile(pmt);
            fileID = fopen(pmtFileName,'w');
            for i = 1:numel(rawText)
                currentLine = rawText{i};
                currentLine = strrep(currentLine,'%','%%')
                fprintf(fileID, currentLine, '%s');
                fprintf(fileID, '\n');
            end
            fclose(fileID);
            status = true;
        end
        % =========================================================
        function pmt = initializePMT()
            pmt.Comments.raw = []; pmt.Comments.line = [];
            pmt.Header.raw   = []; pmt.Header.line   = [];
            pmt.Key.raw      = []; pmt.Key.line      = [];
            pmt.Stop.raw     = []; pmt.Stop.line     = [];
            pmt.Format.raw   = []; pmt.Format.line   = [];
            pmt.Data.raw     = []; pmt.Data.line     = [];
        end   
        % =========================================================
        function pmt = deconstructPMTfile(rawText)
             % Scan and return data
            pmt = PMTTools.initializePMT();
            nLines = numel(rawText);
            for lineNumber = 1:nLines
                currentLine = strtrim(rawText{lineNumber});
                switch lower(currentLine(1))
                    case 'c'
                        pmt.Comments.raw{end+1} = currentLine;
                        pmt.Comments.line(end+1) = lineNumber;
                    case 'h'
                        pmt.Header.raw{end+1} = currentLine;
                        pmt.Header.line(end+1) = lineNumber;      
                    case 'k'
                        pmt.Key.raw{end+1} = currentLine;
                        pmt.Key.line(end+1) = lineNumber;   
                    case 's'
                        pmt.Stop.raw{end+1} = currentLine;
                        pmt.Stop.line(end+1) = lineNumber;   
                    case 'f'
                        pmt.Format.raw{end+1} = currentLine;
                        pmt.Format.line(end+1) = lineNumber;   
                    case 'd'
                        pmt.Data.raw{end+1} = currentLine;
                        pmt.Data.line(end+1) = lineNumber;
                end
            end  
        end
        % =========================================================
        function rawText = reconstructPMTfile(pmt)
            rawText = [pmt.Comments.raw,  pmt.Header.raw,  pmt.Key.raw...
                 pmt.Stop.raw, pmt.Format.raw, pmt.Data.raw]';
            
             % Reorder raw text correctly
             lineNumber = [pmt.Comments.line,  pmt.Header.line,  pmt.Key.line...
                 pmt.Stop.line, pmt.Format.line, pmt.Data.line];
            [lineNumber,I] = sort(lineNumber);
            rawText = rawText(I);   
        end
       % =========================================================
       function data = getData(pmt)
          data = [];
          for i = 1:numel(pmt.Data.raw)
             currentLine = pmt.Data.raw{i};
             currentLine = regexp(currentLine,'\|.*\|','match');
             currentLine = strtrim(currentLine{1});
             currentLine = currentLine(2:end-1);
             currentLine = strsplit(currentLine, '|');
             data(i,:) = cellfun(@eval,currentLine);  
          end
       end
       % =========================================================


        
        
    end
end