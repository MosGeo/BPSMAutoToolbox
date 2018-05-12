classdef Project
   properties
       directory = []
   end
   
   
      methods
        
       function obj = Project(directory)
            if exist('directory','var') == true
                obj.directory = directory;  
            end
       end
       
      end
   
   
end