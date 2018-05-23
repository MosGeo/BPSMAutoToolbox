classdef HashTools
    methods (Static)
        %=====================================================
        function hash = getUniqueHash(oldHashs, startingString)
            % Default values
            if exist('startingString','var') == false; startingString = ''; end
            
            isUnique = false;
            nTrys = 0;
            stringLength = 64;
            while(isUnique==false && nTrys<=100)
                randomString =  HashTools.getRandomString(stringLength);
                randomString = [startingString randomString];
                hash = HashTools.getHash(randomString);
                isUnique = ~ismember(hash, oldHashs);
                nTrys =  nTrys + 1;
                stringLength = stringLength + 1;
            end
        end
        %=====================================================
        function randomString =  getRandomString(stringLength)          
           % Default values
           if exist('stringLength','var') == false; stringLength = 54; end
  
           % Main code
           s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,;:{}[]*&%$#@!';
           numRands = length(s); %find number of random characters to choose from
           randomString = s(ceil(rand(1,stringLength)*numRands)); 
        end
        %=====================================================
        function hash = getHash(randomString)
           % Default values
           if exist('randomString','var') == false; randomString = HashTools.getRandomString(); end
            
           hash = DataHash(randomString);
           hash = [hash(1:8) '-' hash(9:12) '-' hash(13:16) '-' hash(17:20) '-' hash(21:32)];
        end
        %=====================================================
        function isUnique = isUniqueHash(hash, oldHashs)
            isUnique = ~ismember(hash, oldHashs);
        end
        %=====================================================
        function ishash = isHash(hash)
           % A very simple hash checker. Too simplistic but it will work
           % for our current needs.
           regExpString = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
           [match,noMatch]  = regexp(hash, regExpString, 'match','split');          
           ishash = numel(match)==1  && all(cellfun(@(x) isempty(x), noMatch{1}));
        end

        
    end
end