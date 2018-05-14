classdef PetroMod
   
   properties
        PMDirectory = '';
        PMProjectDirectory = '';
        isReady = true;
        Lithology = [];
   end
   
  methods
    %=====================================================
    function obj = PetroMod(PMDirectory, PMProjectDirectory)
            if PetroMod.isPetroModDirectory(PMDirectory) == true
               obj.PMDirectory = PMDirectory;
            else
                obj.isReady = false;
                warning('Cannot find PetroMod!');
            end
            
            if PetroMod.isPetroModProject(PMProjectDirectory) == true
                obj.PMProjectDirectory = PMProjectDirectory;
                lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
                obj.Lithology = LithologyFile(lithologyFileName);
            else
                obj.isReady = false;
                warning('Cannot find PetroMod Project!');
            end  
    end
       
    %=====================================================
    function [cmdout, status] = simModel (obj, modelName, dimesnion, isDisplayOutput, isSaveOutput)
           
           if obj.isReady == 1
           
               if exist('isDisplayOutput', 'var') == false; isDisplayOutput = false; end
               if exist('isSaveOutput', 'var') == false; isSaveOutput = true; end

               hermesFileName  = fullfile(obj.PMDirectory, 'hermes.exe');
               modelFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimesnion), 'd'], modelName);
               [cmdout, status] = PetroMod.runHermes (hermesFileName, modelFolder, isDisplayOutput);
               
               
               if isSaveOutput == true
                   textFileName = fullfile(modelFolder, 'Output.txt');
                   PetroMod.writeOutputFile(cmdout,textFileName); 
               end
               
           else
                 warning('PetroMod folder or Project folder are not defined. Existing.');  
           end

    end
    
    %=====================================================
    function obj = changeLithoValue(obj, lithologyName, parameterName, value)
       obj.Lithology = obj.Lithology.changeValue(lithologyName, parameterName, value);
    end
    
    function obj = changeLithoCurve(obj, lithologyName, parameterName, value)
       obj.Lithology = obj.Lithology.changeCurve(lithologyName, parameterName, value);
    end
    
    %=====================================================
    function [status,msg] = copyModel(obj, sourceModel, distModel, dimension, isOverwrite)
        
       if exist('isOverwrite', 'var') == false; isOverwrite = true; end
               
       sourceFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], sourceModel);
       distFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], distModel);
       
      if isOverwrite == true && exist('distFolder', 'file') == 7
            [status, message, messageid] = rmdir(distFolder);
      end

       [status,msg] = copyfile(sourceFolder, distFolder);
    end
    %=====================================================
    function [] =  updateProject(obj)
        lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
        obj.Lithology.writeLithologyFile(lithologyFileName);
    end

  end
  
  methods(Static)
      
      
       function isPMDirectory = isPetroModDirectory(PMDirectory)
           hermesFileName = fullfile(PMDirectory, 'hermes.exe');
           isPMDirectory = exist(hermesFileName, 'file') == 2;
       end
       
       function isPMProject = isPetroModProject(PMProjectDirectory)
           isPMProject = exist(fullfile(PMProjectDirectory, 'cult'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'data'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'def'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'geo'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'pm1d'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'pm2d'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'pm3d'), 'file') == 7;
           isPMProject = isPMProject & exist(fullfile(PMProjectDirectory, 'well'), 'file') == 7;
       end
       
       function [cmdout, status] = runHermes (hermesFileName, modelFolder, isDisplayOutput)
            if exist('isDisplayOutput', 'var') == false; isDisplayOutput = false; end
            commandToRun    = ['"' hermesFileName '" -model "' modelFolder '"'];
            
            if isDisplayOutput == true
            [status,cmdout]  = system(commandToRun, '-echo');
            else
             [status,cmdout]  = system(commandToRun);
            end
       end
              
       function [] = writeOutputFile(output, fileName)
           FileTools.writeTextFile(output, fileName);
       end
      
  end

   
end