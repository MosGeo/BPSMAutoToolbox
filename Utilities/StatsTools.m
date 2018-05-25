classdef StatsTools
   
    methods (Static)
       
        
       % MEANS 
       % =========================================================                 
        function meanValue = mean(x, f)
           if exist('f','var')  == false; f = ones(size(x)); end
           if sum(f)  ~= 1; f = f/sum(f); end
           meanValue =  sum(x.*f);
        end
       % =========================================================                         
        function meanValue = geomean(x, f)
           if exist('f','var')  == false; f = ones(size(x)); end
           if sum(f)  ~= 1; f = f/sum(f); end
           meanValue =  prod(x.^f);
        end
       % =========================================================                 
        function meanValue = harmmean(x, f)
           if exist('f','var')  == false; f = ones(size(x)); end
           if sum(f)  ~= 1; f = f/sum(f); end
           meanValue =  1/sum(f./x);
        end 
       % =========================================================                 
  
        
           
        
    end
    
end
