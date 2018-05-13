classdef PetroMod
   
   properties
        PMDirectory = '';
        PMProjectDirectory = '';
   end
   
  methods
       function obj = PetroMod(PMDirectory, PMProjectDirectory)
            if exist('fileName','var') == true
                if isPetroModDirectory(PMDirectory) == true
                   obj.PetroModDirectory = PMDirectory;
                else
                    warning('Cannot find PetroMod!');
                end
            end 
       end
       
       

  end
  
  methods(Static)
       function isPMDirectory = isPetroModDirectory(PMDirectory)
           hermesFileName = fullfile(PMDirectory, 'bin', 'hermes.exe');
           isPMDirectory = exist(hermesFileName, 'file') == 2;
       end
       
       function isPMProject = isPetroModProject(PMProjectDirectory)
           
       end
      
  end

   
end