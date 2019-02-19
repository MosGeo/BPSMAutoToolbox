classdef LithologyFile < handle
   
    properties
       meta
       curve
       lithology
       xmlnsXsd
       xmlnsXsi
       xmlDoc
       version
   end
   
   methods
       
     %=====================================================
       function obj = LithologyFile(fileName)
           % Asserttions 
           assert(ischar(fileName), 'File name should be a string');
           
           % Main
           [obj.meta, obj.curve, obj.lithology, obj.xmlnsXsd, obj.xmlnsXsi, obj.xmlDoc]  = obj.readLithologyFile(fileName);
       end
    %=====================================================
       function [meta, curve, lithology, xmlnsXsd, xmlnsXsi, xmlDoc]  = readLithologyFile(obj, lithoFileName)
            %READLITHOLOGYFILE Read lithology file
            %   read the lithology file and returns 

            % Default values
            if exist('lithoFileName','var')  == false; lithoFileName = 'Lithologies.xml'; end
            
            % Read the file
            [docNode, xmlDoc]  = XMLTools.readXML(lithoFileName);
            xmlnsXsd = docNode.getAttribute('xmlns:xsd');
            xmlnsXsi = docNode.getAttribute('xmlns:xsi');
            
            % Get file version
            obj.version = char(docNode.getElementsByTagName('Version').item(0).getFirstChild.getData);

            % META
            metaNode = XMLTools.getElementsByTagName(docNode, 'Meta', true);
            meta = Meta(metaNode);

            % CURVE GROUP
            curveGroupNodes = docNode.getElementsByTagName('CurveGroup');
            curve = Curve(curveGroupNodes);

            % LITHOLOGY GROUP
            lithologyGroupMainNodes = docNode.getElementsByTagName('LithologyGroup');
            lithology = Lithology(lithologyGroupMainNodes);
       end
   %=====================================================
       function [] = changeValue(obj, lithologyName, parameterName, value)
           if isscalar(value)==true || ischar(value)==true
               obj.changeScaler(lithologyName, parameterName, value);
           elseif ismatrix(value)==true
               obj.changeCurve(lithologyName, parameterName, value);
           end
       end
   %=====================================================
       function [] = changeScaler(obj, lithologyName, parameterName, scaler)
           % Asserttions 
           assert(ischar(lithologyName) && ischar(parameterName) , 'Lithology and parameter name should be strings');
           
           % Main
           [id, groupId] = obj.meta.getId(parameterName);
           obj.lithology.updateLithologyParametersValue(lithologyName, groupId, id, scaler);
       end
   %=====================================================
       function [] = changeCurve(obj, lithologyName, parameterName, matrix)
           id = obj.meta.getId(parameterName);
           curveId = obj.lithology.getParameterValue(lithologyName, id);
           obj.curve.updateCurve(curveId, matrix);
       end
   %=====================================================
%        function [] = addValue(obj, lithologyName, parameterName, value)
%          [parameterId, parameterGroupId] = obj.meta.getId(parameterName);     
%          if isscalar(value)==true || isstring(value)==true
%                obj.lithology.addParameter(distLithoName, parameterGroupId, parameterId, value);
%          elseif ismatrix(value)==true
%                allIds = obj.getIds();
%                hash = HashTools.getUniqueHash(allIds, [lithologyName num2str(rand(100,1))]);
%                obj.curve.duplicateCurve(curveId, hash, distLithoName);
%                obj.curve.updateCurve(hash, value);
%                obj.lithology.addParameter(distLithoName, parameterGroupId, parameterId, hash);
%          end
%        end
   %=====================================================
       function [] = addCurve (obj, curveName, curveType, matrix)
           allIds = obj.getIds();
           hash = HashTools.getUniqueHash(allIds, distLithoName);
           obj.curve.addCurve(curveName, curveType, matrix, hash)
       end
   %=====================================================
       function [parameterValues, defaults] = getValue(obj, lithologyName, parameterName)
           
           % Asserttions 
           assert(ischar(parameterName) , 'Lithology and parameter name should be strings');
           assert(ischar(lithologyName) || iscell(lithologyName) , 'Lithology and parameter name should be cell of strings or one string');

           % Main
           if ~iscell(lithologyName); lithologyName = {lithologyName}; end
           nLithologies = numel(lithologyName);
           id = obj.meta.getId(parameterName);
           
           parameterValues = cell(1, nLithologies);
           defaults = false(1, nLithologies);
           
           for i =  1:nLithologies
               parameterValue = obj.lithology.getParameterValue(lithologyName{i}, id);
               if HashTools.isHash(parameterValue)
                   parameterValue = obj.curve.getCurve(parameterValue);
               end
               parameterValue = cellfun(@str2num, parameterValue, 'UniformOutput', false);
               parameterValue = cell2mat(parameterValue);
               
               if isnan(parameterValue)
                   parameterValue = obj.meta.getDefaultValue(id);
                   default = true;
               else
                   default = false;
               end
               
               defaults(i) = default;
               parameterValues{i} = parameterValue;
           end
           
           if numel(parameterValues) == 1; parameterValues = parameterValues{1}; end
           
       end
   %=====================================================
       function obj = deleteLithology(obj, lithologyName)
           % Asserttions 
           assert(ischar(lithologyName) , 'Lithology name should be a string');
           
           % Main
           lithologyIndex = obj.lithology.getLithologyIndex(lithologyName);
           lithologyParameters = obj.lithology.getLithologyParameters(lithologyName);
           obj.lithology.lithology(lithologyIndex,:)=[];
          
           % Delete curves
           for i = 1:size(lithologyParameters,1)
                parameterValue = lithologyParameters(i,end);
                if HashTools.isHash(parameterValue) == true
                      obj.curve.deleteCurve(parameterValue);
                end
           end
       end
   %=====================================================    
       function lithologyInfo = getLithologyInfo(obj, lithologyName)
           % Assertions 
           assert(ischar(lithologyName) , 'Lithology name should be a string');

           % Main
           lithologyParameters = obj.lithology.getLithologyParameters(lithologyName);
           if isempty(lithologyParameters)==false
           [names] = obj.meta.getParameterNames(lithologyParameters(:,2));
           lithologyInfo = [names, lithologyParameters(:,end)];
           end
       end
   %=====================================================    
       function [PetroModId, id] = getLithologyId(obj, lithologyName)
          % Assertions 
          assert(ischar(lithologyName) , 'Lithology name should be a string');
          
          % Main
          [PetroModId, id] = obj.lithology.getLithologyId(lithologyName);
          PetroModId = eval(PetroModId);
       end
   %=====================================================
   function [] = writeLithologyFile(obj, fileName, isOverwrite, isCreateBackup)
        %WRITELITHOLOGYFILE Write lithology file
        %   write the lithology file

       % Defaults
       if exist('isOverwrite','var') == false; isOverwrite = true; end
       if exist('fileName','var')  == false; fileName = 'Output.xml'; end
       if exist('isCreateBackup','var')  == false; isCreateBackup = true; end
       
       % Assertions
       assert(ischar(fileName), 'File name should be a string');
       assert(isa(isOverwrite, 'logical') && isa(isCreateBackup, 'logical'), 'Overwrite and backup should be a boolean');

       % Main
       % Do not overwrite if there is a file and permission is not granted
       if exist(fileName,'file') == 2 && isOverwrite == false
         sprintf('Warning, did not update lithology, make sure to give permission to overwrite file');
         return;   
       end
       
       % Create backup if required
       if exist(fileName,'file') == 2 && isCreateBackup == true && exist([fileName '.bak'],'file') ~= 2
         [status,msg,msgID] = copyfile(fileName, [fileName '.bak']);
       end
       
       % Write the file
       [docNode, xmlDoc] = XMLTools.createXML('Catalogue');
       XMLTools.setAttribute(docNode, 'xmlns:xsd', obj.xmlnsXsd);
       XMLTools.setAttribute(docNode, 'xmlns:xsi', obj.xmlnsXsi);
       XMLTools.addElement(docNode, 'Name', 'Lithology catalog');
       XMLTools.addElement(docNode, 'Version', obj.version);
       XMLTools.addElement(docNode, 'ReadOnly', 'false');
       obj.meta.writeMetaNode( docNode);
       obj.curve.writeCurveNode(docNode);
       obj.lithology.writeLithologyNode(docNode);           
       XMLTools.saveXML(xmlDoc, fileName);     
   end
   
   %=====================================================
   function [] = restoreBackupLithologyFile(obj, fileName)
        if exist([fileName '.bak'],'file') ~= 2
           sprintf('Could not find backup!');
           return
        end
        
        delete(fileName)
        movefile([fileName '.bak'],fileName)
   end
   
   %=====================================================
   function allIds = getIds(obj)   
       allIds = [obj.meta.getIds(); obj.curve.getIds(); obj.lithology.getIds()];
   end
   %=====================================================
   function [] =  duplicateLithology(obj, sourceLithoName, distLithoName , mainGroupName, subGroupName, isOverwrite)
       
       % Defaults
       if ~exist('isOverwrite', 'var'); isOverwrite = true; end
       
       % Assertions
       assert(ischar(sourceLithoName) && ischar(distLithoName), 'Sournce and distination lithologies should be strings');
       
       % Main
       if obj.isLithologyExist(distLithoName) && ~isOverwrite
           disp('Lithology exist, give permission to overwrite to continue')
       end
       
       % Delete lithology if overwrite is turned on
       if obj.isLithologyExist(distLithoName) && isOverwrite
           obj.deleteLithology(distLithoName);
       end
       
       
        % Copy lithology
        allIds = obj.getIds();
        hash = HashTools.getUniqueHash(allIds, distLithoName);
        obj.lithology.duplicateLithology(sourceLithoName, distLithoName, hash);
        obj.lithology.updateReadOnly(distLithoName, false);
        obj.lithology.updateCreator(distLithoName, 'PetroMod');
        
        if exist('mainGroupName', 'var') && exist('subGroupName', 'var')
            obj.changeLithologyGroup(distLithoName, mainGroupName, subGroupName)
        end
        % Copy curves
        lithologyParameters = obj.lithology.getLithologyParameters(distLithoName);
        for i =1:size(lithologyParameters,1)
            curveId = lithologyParameters(i,end);
            if HashTools.isHash(curveId) == true
               allIds = obj.getIds();
               hash = HashTools.getUniqueHash(allIds, [distLithoName curveId]);
               obj.curve.duplicateCurve(curveId, hash, distLithoName);
               obj.lithology.updateLithologyParametersValue(distLithoName, lithologyParameters(i,1), lithologyParameters(i,end-1), hash);
            end
        end
   end
   %=====================================================
   function [] = changeLithologyGroup(obj, lithologyName, mainGroupName, subGroupName)
       
       % Assertions
       assert(exist('mainGroupName', 'var') && exist('subGroupName', 'var'), 'Provide all group names');
       assert(ischar(mainGroupName) && ischar(subGroupName), 'Group names have to be strings');
       assert(~isempty(mainGroupName) && ~isempty(mainGroupName), 'Group names have to contain a non-empty strings');

       % Main group
       [mainGroupId, mainGroupPetroModId] = obj.lithology.getGroupId(mainGroupName);
       if isempty(mainGroupId)
           mainGroupId = HashTools.getUniqueHash(obj.getIds(), mainGroupName);
           petroModIds = obj.lithology.getPetroModIds();
           mainGroupPetroModId = num2str(obj.lithology.getNewPetroModId(petroModIds));
       end
       obj.lithology.updateGroups(lithologyName, mainGroupId, mainGroupPetroModId, mainGroupName, 1)
       
       % Sub group
       [subGroupId, subGroupPetroModId] = obj.lithology.getGroupId(subGroupName,2);
       if isempty(subGroupId)
           subGroupId = HashTools.getUniqueHash(obj.getIds(), subGroupName); 
            petroModIds = obj.lithology.getPetroModIds();
           subGroupPetroModId = num2str(obj.lithology.getNewPetroModId(petroModIds));
       end
       obj.lithology.updateGroups(lithologyName, subGroupId, subGroupPetroModId, subGroupName, 2)


   end
   %=====================================================
   function isExist = isLithologyExist(obj, lithologyName)
      % Assertions
      assert(exist('lithologyName', 'var') == true , 'Lithology name must be provided');
      assert(ischar(lithologyName) , 'Lithology name should be a string');
      
      % Main
      lithologyIndex = obj.lithology.getLithologyIndex(lithologyName);
      isExist = any(lithologyIndex);
   end
   
   %=====================================================
   function [parameterIds] = mixLitholgies(obj, sourceLithologies, fractions, distLithoName, mixer, isOverwrite)
       
       % Defaults
       if ~exist('mixer','var'); mixer = LithoMixer('H'); end
       if ~exist('isOverwrite','var'); isOverwrite = true; end
       
       % Assertions
       assert(iscell(sourceLithologies), 'Source lithologies has to be a cell');
       assert(all(cellfun(@ischar, sourceLithologies)), 'Cell in source lithologies must contain strings');
       assert(isnumeric(fractions), 'Fractions must be a numeric vector');
       assert(sum(fractions)-1 <= .001, 'Fractions must add up to 1');
       assert(size(sourceLithologies,1) == 1 && size(fractions,1) == 1, 'Source lithologies and fractions should be rows');
       assert(size(sourceLithologies,2) ==  size(fractions,2) , 'Source lithologies and fractions should be the same size');
       assert(ischar(distLithoName) , 'Distination lithology should be a string');
       assert(isa(mixer, 'LithoMixer'), 'Mixer should be a LithoMixer class');
       assert(isa(isOverwrite, 'logical'), 'Overwrite should be a boolean');

       % Main
       if obj.isLithologyExist(distLithoName) && ~isOverwrite
           disp('Lithology exist, give permission to overwrite to continue')
       end
       
       % Delete lithology if overwrite is turned on
       if obj.isLithologyExist(distLithoName) && isOverwrite
           obj.deleteLithology(distLithoName);
       end
       
       % Dublicate lithology and insert mix information
       obj.duplicateLithology(sourceLithologies{1}, distLithoName);
       obj.lithology.updateMix(distLithoName, sourceLithologies, fractions, mixer)
       
       [this.obj, parameterIds] = mixer.mixLithologies(obj, sourceLithologies, fractions, distLithoName, mixer);

    end
   %=====================================================
   function outputArray = strcell2array(obj, strcell)
         outputArray = cellfun(@str2num, strcell, 'UniformOutput', false);
         outputArray = cell2mat(outputArray);
   end
    %=====================================================

    
   end

end
