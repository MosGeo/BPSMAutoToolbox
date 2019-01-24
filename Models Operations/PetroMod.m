classdef PetroMod < handle
   
   properties
        PMDirectory = '';
        PMProjectDirectory = '';
        isReady = true;
        Litho = [];
   end
   
  methods
      
    % =====================================================
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
            else
                obj.isReady = false;
                warning('Cannot find PetroMod Project!');
            end  
    end
    % =====================================================
    function [] = loadLithology(obj)
    % Loads lithology file into the PM object.
          lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
          if exist(lithologyFileName, 'file') == 2
            obj.Litho = LithologyFile(lithologyFileName);
          else
             error('Cannot find lithology file');
          end
    end
       
    %=====================================================
    function [cmdout, status] = simModel (obj, modelName, dimension, isDisplayOutput, isSaveOutput)
    % simModel  Changes a parameter value giving a lithology name, the 
    % parameter name and its new value.
        
        % Defaults
        if ~exist('isDisplayOutput', 'var'); isDisplayOutput = false; end
        if ~exist('isSaveOutput', 'var'); isSaveOutput = true; end
    
        % Assertions
        assert(ischar(modelName), 'Model name needs to be a string')
        assert(isa(dimension, 'double') && ismember(dimension,1:3) , 'Dimensions need to be 1, 2, or 3')
        assert(isa(isDisplayOutput, 'logical') && isa(isSaveOutput, 'logical') , 'Display and save output need to be booleans')
           
        % Main
        if obj.isReady == 1

               hermesFileName  = fullfile(obj.PMDirectory, 'hermes.exe');
               modelFolder     = obj.getModelFolder(modelName, dimension);
                [cmdout, status] = PetroMod.runHermes (hermesFileName, modelFolder, isDisplayOutput);
                          
               if isSaveOutput == true
                   textFileName = fullfile(modelFolder, 'Output_Simulation.txt');
                   PetroMod.writeOutputFile(cmdout,textFileName); 
               end
               
           else
                 warning('PetroMod folder or Project folder are not defined. Existing.');  
           end
    end
    
    % =====================================================
    function [status,msg] = duplicateModel(obj, sourceModel, distModel, dimension, isOverwrite)
    % copyModel  Duplicate a model from source name to destination.
        
        % Defaults
        if ~exist('isOverwrite', 'var'); isOverwrite = true; end
               
       sourceFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], sourceModel);
       distFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], distModel);
       
      if isOverwrite == true && exist('distFolder', 'file') == 7
            [status, message, messageid] = rmdir(distFolder);
      end

       [status,msg] = copyfile(sourceFolder, distFolder);
    end
    
    % ===================================================== 
    function [cmdout, status] = runScript(obj, modelName, dimension, scriptName, scriptArg, isDisplayOutput, isSaveOutput, scriptFolder)
    % RUNSCRIPT runs a open simulator script
    
           % Defaults
           if ~exist('isDisplayOutput', 'var'); isDisplayOutput = false; end
           if ~exist('isSaveOutput', 'var'); isSaveOutput = true; end
           if ~exist('scriptFolder', 'var');  scriptFolder = fullfile(pwd, 'PMScripts'); end
           if ~exist('scriptArg', 'var');  scriptArg = ''; end

           % Assertions
           assert(ischar(modelName) && ischar(scriptName) && ischar(scriptArg) && ischar(scriptFolder), 'Model name, script name, script arguments, and script folder need to be strings')
           assert(isa(isDisplayOutput, 'logical') && isa(isSaveOutput, 'logical') , 'Display and save output need to be booleans')
           assert(isa(dimension, 'double') && ismember(dimension,1:3) , 'Dimensions need to be 1, 2, or 3')
            
           % Main
           scriptFileName  = fullfile(scriptFolder, [scriptName '.py']);
           PMmainDirectory = FileTools.getParentDirectory(obj.PMDirectory,2);
           pmpyFileName  = fullfile(obj.PMDirectory, 'runpmpy.exe');
           modelFolder = obj.getModelFolder(modelName, dimension);
           
           [cmdout, status] = PetroMod.runPmpy(PMmainDirectory, pmpyFileName, modelFolder, scriptFileName, scriptArg, isDisplayOutput);
           
           if isSaveOutput == true
               textFileName = fullfile(modelFolder, ['Output_' scriptName '.txt']);
               PetroMod.writeOutputFile(cmdout,textFileName); 
           end
    end
    % =====================================================
    function [status, message, messageid] = deleteModel(obj, modelName, dimension)
    % deleteModel  Deletes a model
        
        % Assertions
        assert(ischar(modelName), 'Model name needs to be a string')
        assert(isa(dimension, 'double') && ismember(dimension,1:3) , 'Dimensions need to be 1, 2, or 3')

        % Main
        modelFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], modelName); 
        [status, message, messageid] = rmdir(modelFolder, 's');
    end
    
    %=====================================================
    function modelFolder = getModelFolder(obj, modelName, dimension)
       
        % Assertions
        assert(ischar(modelName), 'Model name needs to be a string')
        assert(isa(dimension, 'double') && ismember(dimension,1:3) , 'Dimensions need to be 1, 2, or 3')

        % Main
        modelFolder   = fullfile(obj.PMProjectDirectory,['pm', num2str(dimension), 'd'], modelName);
    end
    
    function [] =  saveLithology(obj)
    % updateProject  updates the current project by writing the lithology file.
        lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
        obj.Litho.writeLithologyFile(lithologyFileName);
    end

    function [] =  updateProject(obj)
    % updateProject  updates the current project by writing the lithology file.
        obj.saveLithology();
    end
    %=====================================================
    function [] =  restoreProject(obj)
    % updateProject  updates the current project by writing the lithology file.
        lithologyFileName = fullfile(obj.PMProjectDirectory, 'geo', 'Lithologies.xml');
        obj.Litho.restoreBackupLithologyFile(lithologyFileName);
    end
    %=====================================================


  end
  %=====================================================

  
  methods(Static)
      
       %=====================================================       
       function isPMDirectory = isPetroModDirectory(PMDirectory)
           hermesFileName = fullfile(PMDirectory, 'hermes.exe');
           isPMDirectory = exist(hermesFileName, 'file') == 2;
       end
       
       %=====================================================
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
       
       %=====================================================
       function [cmdout, status] = runHermes (hermesFileName, modelFolder, isDisplayOutput)
            if exist('isDisplayOutput', 'var') == false; isDisplayOutput = false; end
            commandToRun    = ['"' hermesFileName '" -model "' modelFolder '"'];
            
            if isDisplayOutput == true
            [status,cmdout]  = system(commandToRun, '-echo');
            else
             [status,cmdout]  = system(commandToRun);
            end
       end
       
       %=====================================================
       function [] = writeOutputFile(output, fileName)
           FileTools.writeTextFile(output, fileName);
       end
       
       %=====================================================
       function [cmdout, status] = runPmpy(PMmainDirectory, pmpyFileName, modelFolder, scriptFileName, scriptArg, isDisplayOutput)
           
           % Defaults
           if ~exist('isDisplayOutput', 'var'); isDisplayOutput = false; end
           
           % Assertions
           assert(ischar(PMmainDirectory) && ischar(pmpyFileName) && ischar(modelFolder) && ischar(scriptFileName) && ischar(scriptArg), 'Inputs have to be strings');
           assert(isa(isDisplayOutput, 'logical'), 'Display output needs to be booleans')
           
           % Build the command
           scriptDir = 'none'; % 'pmhome' or 'none'
           commandToRun    = ['"' pmpyFileName '" -h "' PMmainDirectory '" -m "' modelFolder '" --scriptdir ' scriptDir ' --script "' scriptFileName '" ' scriptArg];        

           % Run the command
           if isDisplayOutput == true
               [status,cmdout]  = system(commandToRun, '-echo');
           else
               [status,cmdout]  = system(commandToRun);
           end

       end

  end

end