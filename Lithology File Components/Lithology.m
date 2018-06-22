classdef Lithology < handle
   properties
       lithology
       lithologyGroupTitles = {'Id', 'Name', 'Creator', 'ReadOnly', 'PetroModId'}
       lithologyTitles = {'Id', 'Name', 'Creator', 'ReadOnly', 'PetroModId', 'Pattern' , 'Color' , 'Mixing'};
       parameterGroupTitles = {'MetaParameterGroupId'};
       parameterTitles = {'MetaParameterId', 'Value'};
       mixingTitles = {'LithologyComponent', 'ThermalConductivity', 'Permeability', 'CapillaryEntryPressure' ,'ReadOnly'}
       lithoCompTitles = {'LithologyId', 'Fraction'}
   end
   
   methods
       % =========================================================
       function obj = Lithology(lithologyGroupNodes)
            if exist('lithologyGroupNodes','var') == true
                obj.lithology = obj.analyzeLithologyGroupNodes(lithologyGroupNodes);  
            end 
       end
       
       % =========================================================
       function lithologyAll = analyzeLithologyGroupNodes(obj, lithologyGroupMainNodes)
           nLithologyGroupMainNodes = lithologyGroupMainNodes.getLength;
           lithologyAll = {};
           for i=0:nLithologyGroupMainNodes-1
               lithologyGroupNodeMain = lithologyGroupMainNodes.item(i);
               lithologyGroupMain = obj.analyzeLithologyGroupNodeMain(lithologyGroupNodeMain);
               lithologyAll = [lithologyAll; lithologyGroupMain];
           end
       end
       
       % =========================================================
       function lithologyGroupMain = analyzeLithologyGroupNodeMain(obj, lithologyGroupNodeMain)
          id   = char(lithologyGroupNodeMain.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(lithologyGroupNodeMain.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyGroupNodeMain.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId   = char(lithologyGroupNodeMain.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);
          
          try
              creator   = char(lithologyGroupNodeMain.getElementsByTagName('Creator').item(0).getFirstChild.getData);
          catch
              creator = '';
          end
          
          lithologyGroupSubNodes = lithologyGroupNodeMain.getElementsByTagName('LithologyGroup');
          nLithologyGroupSubNodes = lithologyGroupSubNodes.getLength;
          
          lithologyGroupMain = {};
          lithologyGroupSubRows = {};
          for i=0:nLithologyGroupSubNodes-1               
               lithologyGroupNodeSub = lithologyGroupSubNodes.item(i);
               lithologyGroupSub = obj.analyzeLithologyGroupNodeSub(lithologyGroupNodeSub);
               
               nRows = size(lithologyGroupSub,1);
               ids   = repmat({id},nRows,1);
               names = repmat({name}, nRows,1);
               readOnlys = repmat({readOnly}, nRows,1);
               petroModIds = repmat({petroModId}, nRows, 1);
               creators = repmat({creator}, nRows, 1);
               lithologyGroupSubMatrix = [ids, names, creators, readOnlys, petroModIds, lithologyGroupSub];
               lithologyGroupSubRows = [lithologyGroupSubRows; lithologyGroupSubMatrix];
          end
               lithologyGroupMain = [lithologyGroupMain; lithologyGroupSubRows];

       end
       
       % =========================================================
       function lithologyGroupSub = analyzeLithologyGroupNodeSub(obj, lithologyGroupNodeSub)
          id   = char(lithologyGroupNodeSub.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(lithologyGroupNodeSub.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(lithologyGroupNodeSub.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petroModId   = char(lithologyGroupNodeSub.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);
          try
          creator   = char(lithologyGroupNodeSub.getElementsByTagName('Creator').item(0).getFirstChild.getData);
          catch
              creator = {''};
          end
          lithologyNodes = lithologyGroupNodeSub.getElementsByTagName('Lithology');
          nLithologyGroupSubNodes = lithologyNodes.getLength;
          
          lithologyRow = {};
          lithologyGroupSub = {};
          for i=0:nLithologyGroupSubNodes-1
               lithologyNode = lithologyNodes.item(i);
               lithology = obj.analyzeLithologyNode(lithologyNode);
               lithologyRows(i+1,:) = [id, name, creator, readOnly, petroModId, lithology];
          end
          lithologyGroupSub = [lithologyGroupSub; lithologyRows];
       end
       
       
      % =========================================================
      function lithology = analyzeLithologyNode(obj, lithologyNode)
          lithology = {};
          for i = 1:numel(obj.lithologyTitles)-1
              try
                 lithology{i} = char(lithologyNode.getElementsByTagName(obj.lithologyTitles{i}).item(0).getFirstChild.getData);
              catch
                 lithology{i} = ''; 
              end
          end
          
          mixingNode = lithologyNode.getElementsByTagName(obj.lithologyTitles{end});
          if mixingNode.getLength==0
              lithology{end+1} = '';
          else
              mixingNode = mixingNode.item(0);
              lithology{end+1} = obj.analyzeMixingNode(mixingNode);
          end
          
         
          parameterGroupNodes = lithologyNode.getElementsByTagName('ParameterGroup');
          nPrameterGroups = parameterGroupNodes.getLength;
          parameterGroup = {};
          
          for i = 0:nPrameterGroups-1
             parameterGroupNode = parameterGroupNodes.item(i);
             parameterGroupRow  = obj.analyzeParameterGroup(parameterGroupNode);
             parameterGroup     = [parameterGroup; parameterGroupRow];
          end
          lithology{end+1} = parameterGroup;
      end 
      % =========================================================
      function mixing = analyzeMixingNode(obj, mixingNode)
          mixing = {};
          lithoCompNodes = mixingNode.getElementsByTagName(obj.mixingTitles{1});
          nLithoComp = lithoCompNodes.getLength; 
          
          lithoMatrix = {};
          for i=1:nLithoComp
              lithoCompNode = lithoCompNodes.item(i-1);
              for j=1:numel(obj.lithoCompTitles)
                  lithoMatrix{i,j} = char(lithoCompNode.getElementsByTagName(obj.lithoCompTitles{j}).item(0).getFirstChild.getData);
              end
          end
          mixing{1} = lithoMatrix;
          
          for i =2:numel(obj.mixingTitles)
              mixing{i} = char(mixingNode.getElementsByTagName(obj.mixingTitles{i}).item(0).getFirstChild.getData);
          end
          
      end
      % =========================================================
       function [parameterGroup] = analyzeParameterGroup(obj, parameterGroupNode)
          id = char(parameterGroupNode.getElementsByTagName('MetaParameterGroupId').item(0).getFirstChild.getData);

          parameterNodes = parameterGroupNode.getElementsByTagName('Parameter');
          nPrameters = parameterNodes.getLength;
         
          parameterGroup = {};   
          for i = 0:nPrameters-1
              parameterNode =  parameterNodes.item(i);
              parameter = obj.analyzeParameter(parameterNode);
              parameterGroupRow = {id, parameter{1}, parameter{2}};
              parameterGroup = [parameterGroup; parameterGroupRow];
          end
       end
       
       % =========================================================
       function [parameter] = analyzeParameter(obj, parameterNode)
           id = char(parameterNode.getElementsByTagName('MetaParameterId').item(0).getFirstChild.getData); 
           try
                value = char(parameterNode.getElementsByTagName('Value').item(0).getFirstChild.getData);
           catch
                value = '';
           end
           parameter = {id, value};
       end
       
   end

   methods
       
        % =========================================================
        function lithologyParameters =  getLithologyParameters(obj, lithologyName)
            lithologyIndex = obj.getLithologyIndex(lithologyName);
            if any(lithologyIndex) == false 
                disp('Could not find lithology!'); 
                lithologyParameters = '';
                return; 
            end
            lithologyParameters = obj.lithology{lithologyIndex, end};
        end
       
      % =========================================================   
       function [status] = updateLithologyParametersValue(obj, lithologyName, groupId, id, value)
        
           if isa(value, 'double') == true; value = num2str(value); end 
           if iscell(value) == false; value = cellstr(value); end
           if exist('isAdd','var') == true; isAdd = false;  end 
           
           % Indicies
           groupIdIndex    =   1;
           idIndex    =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'MetaParameterId'));
           valueIndex =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'Value'));
                   
            lithologyIndex = obj.getLithologyIndex(lithologyName);
            lithologyParameters = obj.lithology{lithologyIndex, end};
            lithologyParameters(:,idIndex);
            parameterIndex = ismember(lithologyParameters(:,idIndex),id);

            if any(parameterIndex) == true
                lithologyParameters(parameterIndex,valueIndex) =  value;
                status = true;
            elseif  any(parameterIndex) == false
                 lithologyParameters(end+1,groupIdIndex) =  groupId;
                 lithologyParameters(end,valueIndex) =  value;
                 lithologyParameters(end,idIndex) =  id;
                 status = true;
            end
              obj.lithology{lithologyIndex, end} = lithologyParameters;
       end
       % =========================================================   
       function [] = updateLithologyParamters(obj, lithologyName, parameters)
           lithologyIndex = obj.getLithologyIndex(lithologyName);
           obj.lithology{lithologyIndex, end} = parameters;
       end
       % =========================================================   
       function parameterValue = getParameterValue(obj, lithologyName, id)
            idIndex    =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'MetaParameterId'));
            valueIndex =   numel(obj.parameterGroupTitles)+find(ismember(obj.parameterTitles, 'Value'));
            lithologyIndex = obj.getLithologyIndex(lithologyName);
            lithologyParameters = obj.lithology{lithologyIndex, end};
            parameterIndex = ismember(lithologyParameters(:,idIndex),id);
            
            if any(parameterIndex) 
               parameterValue = lithologyParameters(parameterIndex,valueIndex);
            else
               parameterValue = nan;
            end   
       end
       % =========================================================   
       function lithologyIndex = getLithologyIndex(obj, lithologyName)
          nameIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Name'));
          lithologyIndex = ismember(obj.lithology(:,nameIndex), lithologyName);
       end
       % =========================================================   
       function ids = getIds(obj)
           idIndex1  = find(ismember(obj.lithologyGroupTitles, 'Id'));
           idIndex2  = numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyGroupTitles, 'Id'));
           idIndex3  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Id'));         
           ids = [obj.lithology(:,idIndex1); obj.lithology(:,idIndex2); obj.lithology(:,idIndex3)];
           keepInd = cellfun(@(x) ~isempty(x), ids);
           ids = ids(keepInd);
           ids = unique(cell2mat(ids),'rows');
           ids = cellstr(ids);
       end
       
       % =========================================================   
       function [] = dublicateLithology(obj, sourceLithoName, distLithoName, hash)
           
           % Indecies
           idIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Id'));         
           nameIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Name'));         
           petroModIdIndex   = 2*numel(obj.lithologyGroupTitles) +  find(ismember(obj.lithologyTitles, 'PetroModId'));

           % Find source lithology
           lithologyIndex = obj.getLithologyIndex(sourceLithoName);
           
           % Get new PetroModId
           petroModIds = obj.getPetroModId();
           NewPetroModId =  obj.getNewPetroModId(petroModIds);
           
           % Create new lithology
           newLithology = obj.lithology(lithologyIndex,:);
           newLithology{:,idIndex} = hash;
           newLithology{:,nameIndex} = distLithoName;
           newLithology{:,petroModIdIndex} = num2str(NewPetroModId);
           obj.lithology(end+1,:)= newLithology;
       end
       
       % =========================================================          
       function petroModIds = getPetroModId(obj)
           petroModIdIndex   = 2*numel(obj.lithologyGroupTitles) +  find(ismember(obj.lithologyTitles, 'PetroModId'));
           petroModIds = unique(obj.lithology(:,petroModIdIndex)); 
           petroModIds = cell2mat(cellfun(@str2num, petroModIds, 'UniformOutput', false));
       end
       
       % =========================================================          
       function NewPetroModId =  getNewPetroModId(obj, oldPetroModIds)
           sortedIds = sort(oldPetroModIds);
           NewPetroModId = sortedIds(find(diff(sortedIds)>1,1,'first'))+1;
       end
       % =========================================================          
       function [] = updateReadOnly(obj, lithologyName, trueFalseValue)
           readOnlyIndex   = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'ReadOnly'));
           lithologyIndex = obj.getLithologyIndex(lithologyName);
           
           switch trueFalseValue
               case true
                   value = 'true';
               case false
                   value = 'false';
           end
 
           obj.lithology{lithologyIndex, readOnlyIndex} = value;
       end
       % =========================================================          
       function [] = updateGroups(obj, lithologyName, groupId, groupName, level, isReadOnly)
          % Defaults
          if ~(exist('level', 'var')); level = 1; end
          if ~(exist('isReadOnly', 'var')); isReadOnly = false; end
          
          
          % Main
          groupIdIndex   = (level-1)*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles,'Id'));
          groupNameIndex = (level-1)*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles,'Name'));
          readOnlyIndex  = (level-1)*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles,'ReadOnly'));
          
          lithologyIndex = obj.getLithologyIndex(lithologyName);
          
          obj.lithology{lithologyIndex, groupIdIndex} = groupId;
          obj.lithology{lithologyIndex, groupNameIndex} = groupName;
          obj.lithology{lithologyIndex, groupIdIndex} = groupId;
          obj.lithology{lithologyIndex, readOnlyIndex} = obj.bool2string(isReadOnly);
       end
       % ========================================================= 
       function groupId = getGroupId(obj, groupName, level)
          
           % Defaults
          if ~(exist('level', 'var')); level = 1; end
          
          % Main
          groupIdIndex = (level-1)*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles,'Id'));
          groupNameIndex = (level-1)*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles,'Name'));

          groupIds = unique(obj.lithology(:,groupIdIndex));
          groupNames = unique(obj.lithology(:,groupNameIndex));

          [~, Locb] = ismember(groupName, groupNames);
          if Locb>0
            groupId   = groupIds{Locb};
          else
              groupId = '';
          end     
       end
       % =========================================================          
       function [] = updateCreator(obj, lithologyName, creatorName)
           creatorIndex   = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Creator'));
           lithologyIndex = obj.getLithologyIndex(lithologyName);
           obj.lithology{lithologyIndex, creatorIndex} = creatorName;
       end
       % =========================================================   
       function [] = updateMix(obj, lithologyName, sourceLithologies, fractions, mixer)
           mixIndex   = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Mixing'));
           idIndex  = 2*numel(obj.lithologyGroupTitles) + find(ismember(obj.lithologyTitles, 'Id'));         

           nSourceLitho = numel(sourceLithologies);
           mixerMatrix  = cell(nSourceLitho,2);
           for i = 1:nSourceLitho
                lithologyIndex = obj.getLithologyIndex(sourceLithologies{i});
                mixerMatrix{i,1} = obj.lithology{lithologyIndex, idIndex};
                mixerMatrix{i,2} = num2str(fractions(i));
           end
           
           lithologyIndex = obj.getLithologyIndex(lithologyName);
           mixString = mixer.getMixerString();
           
           mixValue = {mixerMatrix, mixString{1}, mixString{2}, mixString{3}, 'false'};
           obj.lithology{lithologyIndex, mixIndex}= mixValue;

       end
       % =========================================================   
       function boolString = bool2string(obj, bool)
           if bool == true
               boolString = 'true';
           else
               boolString = 'false';
           end
       end 
       
   end
    
 % Get methods for writing xml file
 methods
     
     function [docNode] = writeLithologyNode(obj, docNode)
        
        [infoLithologyGroup, nRecordsLithologyGroup] = getLithologyGroup(obj);
        for i=1:nRecordsLithologyGroup
            lithologyGroupElement = XMLTools.addElement(docNode, 'LithologyGroup');    
            for j=1:numel(obj.lithologyGroupTitles)
                    XMLTools.addElement(lithologyGroupElement, obj.lithologyGroupTitles{j}, infoLithologyGroup{i,j});
            end
            
               [infoLithologyGroup2, nRecordsLithologyGroup2] = getLithologyGroup2(obj, infoLithologyGroup{i,1});
               if nRecordsLithologyGroup2> 0
               for k=1:nRecordsLithologyGroup2
                   lithologyGroupElement2 = XMLTools.addElement(lithologyGroupElement, 'LithologyGroup');
                   for l=1:numel(obj.lithologyGroupTitles)
                    XMLTools.addElement(lithologyGroupElement2, obj.lithologyGroupTitles{l}, infoLithologyGroup2{k,l});
                   end
                   
                  
                   [infoLithology, nRecordsLithology] = getLithology(obj, infoLithologyGroup{i,1}, infoLithologyGroup2{k,1});
                   if nRecordsLithology> 0
                   for o=1:nRecordsLithology
                   lithologyElement = XMLTools.addElement(lithologyGroupElement2, 'Lithology');
                       for p=1:numel(obj.lithologyTitles)-1
                            XMLTools.addElement(lithologyElement, obj.lithologyTitles{p}, infoLithology{o,p});
                       end
                       
                       mixing = infoLithology{o,p+1}; 
                       if isempty(mixing) == false
                            mixingElement = XMLTools.addElement(lithologyElement, 'Mixing');
                            lithoComponents = mixing{1};
                            for t = 1:size(lithoComponents,1)
                                lithoCompElement = XMLTools.addElement(mixingElement, 'LithologyComponent');
                                XMLTools.addElement(lithoCompElement, 'LithologyId', lithoComponents{t,1});
                                XMLTools.addElement(lithoCompElement, 'Fraction', lithoComponents{t,2});
                            end
                            
                            
                            for t = 2:numel(obj.mixingTitles)
                                XMLTools.addElement(mixingElement, obj.mixingTitles{t}, mixing{t});
                            end

                       end
                   
                   parametersTable = infoLithology{o,end};
                   [~,ia,~] = unique(parametersTable(:,1));
                   metaParameterId = parametersTable(ia,1);
                   for q = 1:numel(ia)
                       parameterGroupElement = XMLTools.addElement(lithologyElement, 'ParameterGroup');
                       XMLTools.addElement(parameterGroupElement, 'MetaParameterGroupId', metaParameterId{q});

                       indToInclude = ismember(parametersTable(:,1), metaParameterId{q});
                       parameters = parametersTable(indToInclude, 2:3);
                       for r = 1:sum(indToInclude)
                            parameterElement = XMLTools.addElement(parameterGroupElement, 'Parameter');
                            XMLTools.addElement(parameterElement, 'MetaParameterId', parameters{r,1});
                            XMLTools.addElement(parameterElement, 'Value', parameters{r,2});
                       end
                   end
                   
                       
                   end
                   end
                   
                   
                   
                   
               end
               end
            
        end
         
         
     end
     
     
      function [info, nRecords] = getLithologyGroup(obj)
           startIndex = 1;
           endIndex   = numel(obj.lithologyGroupTitles);
           id = obj.lithology(:,startIndex);           
           [~,ia,~] = unique(id);
           nRecords = numel(ia);
           info =  obj.lithology(ia,startIndex:endIndex);
      end
       
      
       function [info, nRecords] = getLithologyGroup2(obj, lithologyGroupId)
           startIndex = numel(obj.lithologyGroupTitles)+1;
           endIndex   = startIndex+numel(obj.lithologyGroupTitles)-1;  
           indMember = ismember(obj.lithology(:,1), lithologyGroupId);
           lithology = obj.lithology(indMember,:);
           [~, ia,~] = unique(lithology(:,startIndex));
           nRecords = numel(ia);
           info =  lithology(ia,startIndex:endIndex);
       end
       
       
       
       function [info, nRecords] = getLithology(obj, lithologyGroupId, lithologyGroupId2)
           % Index Meta Parameter Group
           indMember = ismember(obj.lithology(:,1), lithologyGroupId);
           lithology = obj.lithology(indMember,:);
           
           %Only Take Meta Parameter Group without SubGroup
           idLith2 = lithology(:,numel(obj.lithologyGroupTitles)+1);           
           indMember = ismember(idLith2, lithologyGroupId2);
           lithology =  lithology(indMember,:);
           
           % Get info
           nRecords = size(lithology,1);
           startIndex = 2*numel(obj.lithologyGroupTitles)+1;
           info =  lithology(:,startIndex:end);
           
       end
      

 end
    
end