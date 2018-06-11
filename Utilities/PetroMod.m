classdef PetroMod < handle
   
   properties
        PMDirectory = '';
        PMProjectDirectory = '';
        isReady = true;
        Litho = [];
   end
   
  methods
      
    %=====================================================
    function obj = PetroMod(PMDirectory, PMProjectDirectory)
    % PetroMod  Constructor giving the petromod directory (bin directory
    % in the main petromod directory) and a project directory.

            if PetroMod.isPetroModDirectory(PMDirectory) == true
               obj.PMDirectory = PMDirectory;
            else
                obj.isReady = false;
                warning('Cannot find PetroMod!');
            end
            
            if PetroMod.isPetroModProject(PMProjectDirectory) == true
                obj.PMProjectDirectory = PMProjectDirectory;
                lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
                obj.Litho = LithologyFile(lithologyFileName);
            else
                obj.isReady = false;
                warning('Cannot find PetroMod Project!');
            end  
    end
       
    %=====================================================
    function [cmdout, status] = simModel (obj, modelName, dimension, isDisplayOutput, isSaveOutput)
    % simModel  Changes a parameter value giving a lithology name, the 
    % parameter name and its new value.
    
           if obj.isReady == 1
           
               if exist('isDisplayOutput', 'var') == false; isDisplayOutput = false; end
               if exist('isSaveOutput', 'var') == false; isSaveOutput = true; end

               hermesFileName  = fullfile(obj.PMDirectory, 'hermes.exe');
               modelFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], modelName);
               [cmdout, status] = PetroMod.runHermes (hermesFileName, modelFolder, isDisplayOutput);
               
               
               if isSaveOutput == true
                   textFileName = fullfile(modelFolder, 'Output.txt');
                   PetroMod.writeOutputFile(cmdout,textFileName); 
               end
               
           else
                 warning('PetroMod folder or Project folder are not defined. Existing.');  
           end
    end
    
    % =====================================================
    function [status,msg] = copyModel(obj, sourceModel, distModel, dimension, isOverwrite)
    % copyModel  Duplicate a model from source name to destination.

       if exist('isOverwrite', 'var') == false; isOverwrite = true; end
               
       sourceFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], sourceModel);
       distFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], distModel);
       
      if isOverwrite == true && exist('distFolder', 'file') == 7
            [status, message, messageid] = rmdir(distFolder);
      end

       [status,msg] = copyfile(sourceFolder, distFolder);
    end
    
    % =====================================================
    function [status, message, messageid] = deleteModel(obj, model, dimension)
    % deleteModel  Deletes a model

       modelFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], model); 
       [status, message, messageid] = rmdir(modelFolder, 's');
    end
    
    
    %=====================================================
    function [] =  updateProject(obj)
    % updateProject  updates the current project by writing the lithology 
    % file.
        lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
        obj.Litho.writeLithologyFile(lithologyFileName);
    end
    %=====================================================
    function [] =  restoreProject(obj)
    % updateProject  updates the current project by writing the lithology 
    % file.
        lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
        obj.Litho.restoreBackupLithologyFile(lithologyFileName);
    end
    %=====================================================


  end
  %=====================================================

  
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