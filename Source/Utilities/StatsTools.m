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
       function meanValue = genmean(x, f, p)
           if exist('f','var')  == false; f = ones(size(x)); end
           if sum(f)  ~= 1; f = f/sum(f); end
           meanValue = (1/sum(f) * sum(f.*x.^p)).^(1/p);
       end
       % =========================================================

       
       % MATH
       % =========================================================
        function out = logn (x, n)
        % Log of a number using base n
           out = log(x) / log(n); 
        end
       % ========================================================= 
       function order = getMagnitudeOrder(x)
          order = floor(log10(x));
       end
       % ========================================================= 

          
        
           
        
    end
    
end
