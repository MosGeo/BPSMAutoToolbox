classdef LithologyFile < handle
   
    properties
       meta
       curve
       lithology
       xmlnsXsd
       xmlnsXsi
       xmlDoc
   end
   
   methods
       
     %=====================================================
       function obj = LithologyFile(fileName)
            if exist('fileName','var') == true
               [obj.meta, obj.curve, obj.lithology, obj.xmlnsXsd, obj.xmlnsXsi, obj.xmlDoc]  = obj.readLithologyFile(fileName);
            end 
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
       if isscalar(value)==true
           obj.changeScaler(lithologyName, parameterName, value)
       elseif ismatrix(value)==true
           obj.changeCurve(lithologyName, parameterName, value)
       end
   end
   %=====================================================
       function [] = changeScaler(obj, lithologyName, parameterName, scaler)
           id = obj.meta.getId(parameterName);
           obj.lithology.updateLithologyParametersValue(lithologyName, id, scaler);
       end
   %=====================================================
       function [] = changeCurve (obj, lithologyName, parameterName, matrix)
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
       function parameterValue = getValue (obj, lithologyName, parameterName)
           id = obj.meta.getId(parameterName);
           parameterValue = obj.lithology.getParameterValue(lithologyName, id);
           if HashTools.isHash(parameterValue)
               parameterValue = obj.curve.getCurve(parameterValue);
           end
           parameterValue = cellfun(@str2num, parameterValue, 'UniformOutput', false);
           parameterValue = cell2mat(parameterValue);
       end
   %=====================================================
       function obj = deleteLithology(obj, lithologyName)
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
           lithologyParameters = obj.lithology.getLithologyParameters(lithologyName);
           if isempty(lithologyParameters)==false
           [names] = obj.meta.getParameterNames(lithologyParameters(:,2));
           lithologyInfo = [names, lithologyParameters(:,end)];
           end
       end
   %=====================================================
   function [] = writeLithologyFile(obj, fileName, isOverwrite, isCreateBackup)
        %WRITELITHOLOGYFILE Write lithology file
        %   write the lithology file

       % Default values:
       if exist('isOverwrite','var') == false; isOverwrite = true; end
       if exist('fileName','var')  == false; fileName = 'Output.xml'; end
       if exist('isCreateBackup','var')  == false; isCreateBackup = true; end

       % Create backup if required
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
       XMLTools.addElement(docNode, 'Version', '2.1');
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
   function [] = dublicateLithology(obj, sourceLithoName, distLithoName)
        
        % Copy lithology
        allIds = obj.getIds();
        hash = HashTools.getUniqueHash(allIds, distLithoName);
        obj.lithology.dublicateLithology(sourceLithoName, distLithoName, hash);
        obj.lithology.updateReadOnly(distLithoName, false);
        obj.lithology.updateCreator(distLithoName, 'PetroMod');
        
        
        % Copy curves
        lithologyParameters = obj.lithology.getLithologyParameters(distLithoName);
        for i =1:size(lithologyParameters,1)
            curveId = lithologyParameters(i,end);
            if HashTools.isHash(curveId) == true
               allIds = obj.getIds();
               hash = HashTools.getUniqueHash(allIds, [distLithoName curveId]);
               obj.curve.duplicateCurve(curveId, hash, distLithoName);
               obj.lithology.updateLithologyParametersValue(distLithoName, lithologyParameters(i,end-1), hash);
            end
        end
        
   end  
   %=====================================================
   function [parameterIds] = mixLitholgies(obj, sourceLithologies, fractions, distLithoName, mixer)
       
       % Defaults
       if exist('mixer','var')  == false; mixer = LithoMixer(); end
       
       % Dublicate lithology and insert mix information
       obj.dublicateLithology(sourceLithologies{1}, distLithoName);
       obj.lithology.updateMix(distLithoName, sourceLithologies, fractions, mixer)

       % Get lithology information
       nLithos = numel(sourceLithologies);
       lithoInfos = cell(nLithos,1);
       parameterNames = []; 
       parameterTypes=[];
       parameterIds = [];
       for i = 1:nLithos
            lithoInfos{i} =  obj.lithology.getLithologyParameters(sourceLithologies{i});
            [pn, pt] = obj.meta.getParameterNames(lithoInfos{i}(:,end-1));
            parameterNames = [parameterNames; pn];
            parameterTypes = [parameterTypes; pt];
            parameterIds   = [parameterIds; lithoInfos{i}(:,1:2)];
       end
       
        [~, ib,~]        = unique(parameterIds(:,2));
        parameterNames   = parameterNames(ib,:);
        parameterTypes   = parameterTypes(ib,:);
        parameterIds     = parameterIds(ib,:);

       
       % Get the titles of the properties

       nParameters = size(parameterIds, 1)
       newParameters = cell(nParameters,3);
       for i = 1:nParameters
           
           % Get parameter information
           parameterGroupName = parameterNames{i,1};
           parameterGroupId   = parameterIds{i,1};
           parameterName = parameterNames{i,2};
           parameterType = parameterTypes{i};
           parameterId   = parameterIds{i,2};

           parameterValues = {};
           for j = 1:nLithos
               [~, paramInd] = (ismember(parameterId,lithoInfos{j}(:,end-1)));
               if any(paramInd)==false;  continue; end
               parameterValue = lithoInfos{j}(paramInd,end);
               if strcmp(parameterType, 'Reference')
                    parameterValue = obj.curve.getCurve(parameterValue);
                    parameterValue = parameterValue(:,2);
                    xValues = obj.strcell2array(parameterValue(:,1));
               end
               parameterValues = [parameterValues, parameterValue];
           end
           parameterValues = obj.strcell2array(parameterValues);
           
           % Decide on the mixing type
           switch parameterGroupName      
               case 'Thermal conductivity'
                   mixType = mixer.thermalCondictivity(1);
               case 'Permeability'
                   mixType = mixer.permeability(1);
               case 'Seal properties'
                   mixType = mixer.capillaryPressure(1);
               otherwise
                   mixType = 1;
           end
           
           % Mix
           parameterValues
           if isempty(parameterValues)==false
           switch parameterType
               case 'Decimal'
                  effectiveValue = mixer.mixScalers(parameterValues, fractions, mixType);
               case 'Reference'
                  effectiveValue = mixer.mixCurves(parameterValues, fractions, mixType);
                  effectiveValue = [xValues, effectiveValue];
               case 'Integer'
                  effectiveValue =  parameterValues(1);
               case 'Bool'
                  effectiveValue =  max(parameterValues(1));
               case 'string'
                  effectiveValue =  parameterValues(1);
           end
           else
              effectiveValue = '';
           end
       
       % Update the lithology
       parameterName
       effectiveValue
       obj.changeValue(distLithoName, parameterName, effectiveValue);

       end
          

   end
   %=====================================================
   function outputArray = strcell2array(obj, strcell)
         outputArray = cellfun(@str2num, strcell, 'UniformOutput', false);
         outputArray = cell2mat(outputArray);
   end
 
    
   end

end
