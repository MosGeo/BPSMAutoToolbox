classdef Meta < handle
   properties
       metaParameterGroupTitles = {'Id', 'Name', 'ReadOnly'}
       metaParameterTitles = {'Id', 'Name', 'ValueType', 'DefaultValue', 'PetrelTemplate', 'PetroModUnit', 'ReadOnly'};
       meta = [];
   end
   
   
   %% Constructor and Analyzing XML
   methods
        
       function obj = Meta(metaNode)
            if exist('metaNode','var') == true
                obj.meta = obj.analyzeMetaNode(metaNode);  
            end
       end
        
       %% Main analyzer for meta node
       function meta =  analyzeMetaNode(obj, metaNode)
           
         metaParameterGroupNodes = XMLTools.getElementsByTagName(metaNode, 'MetaParameterGroup', true);
         nPrameterGroups = length(metaParameterGroupNodes);
         
         meta = {};
         for i = 1:nPrameterGroups
            metaParameterGroupNode = metaParameterGroupNodes(i);
            metaParameterGroup = obj.analyzeMetaParameterGroup(metaParameterGroupNode);
            meta = [meta; metaParameterGroup];
         end        
       end
       
       %% Analyze Meta Parameter Group - Maximum of Two levels
       function [metaParameterGroup] = analyzeMetaParameterGroup(obj, metaParameterGroupNode, groupRow1)
                     
          nMetaParameterGroupInfo = numel(obj.metaParameterGroupTitles);
          groupRow = cell(1,nMetaParameterGroupInfo);
          for i =1:nMetaParameterGroupInfo
              groupRow{i} = char(metaParameterGroupNode.getElementsByTagName(obj.metaParameterGroupTitles{i}).item(0).getFirstChild.getData);
          end
          
          if exist('groupRow1', 'var') == false 
              groupRow1 = groupRow;
              groupRow = cell(1,nMetaParameterGroupInfo);
          end
         
          metaParameterNodes = XMLTools.getElementsByTagName(metaParameterGroupNode, 'MetaParameter', true);
          nMetaPrameterGroups = length(metaParameterNodes);
          metaParameterGroup = {};
          
          for i = 1:nMetaPrameterGroups
             metaParameterNode =  metaParameterNodes(i);
             metaParameter = obj.analyzeMetaParameter(metaParameterNode);
             metaParameterGroupRow = [groupRow1, groupRow, metaParameter];
             metaParameterGroup = [metaParameterGroup; metaParameterGroupRow];
          end
          
       
       % Second Level
       metaParameterGroupNodes = XMLTools.getElementsByTagName(metaParameterGroupNode, 'MetaParameterGroup', true);
       nPrameterGroups = length(metaParameterGroupNodes);
         
         for i = 1:nPrameterGroups
           metaParameterGroupNode = metaParameterGroupNodes(i);
           metaParameterGroupInside = obj.analyzeMetaParameterGroup(metaParameterGroupNode, groupRow1);
           metaParameterGroup = [metaParameterGroup; metaParameterGroupInside];
         end              
       end
      
       
       %% Analyze Meta Parameter 
       function [metaParameter] = analyzeMetaParameter(obj, metaParameterNode)
          nMetaParameterInfo = numel(obj.metaParameterTitles);
          metaParameter = cell(1,nMetaParameterInfo);
          
          for i =1:nMetaParameterInfo
              metaParameter{i} = XMLTools.anlyzeNodeValue(metaParameterNode, obj.metaParameterTitles{i});
          end     
       end
       
   end
   
   %% These methods are used for analyzing the stored meta information
   methods
       
       function [docNode] = writeMetaNode(obj, docNode)
          metaElement = XMLTools.addElement(docNode, 'Meta');
          
          % First level Meta Group
          [infoMetaParameterGroup, nRecordsMetaParameterGroup] = getMetaParameterGroup(obj);
           for i=1:nRecordsMetaParameterGroup
               metaGroupElement = XMLTools.addElement(metaElement, 'MetaParameterGroup');
               for j=1:numel(obj.metaParameterGroupTitles)
                    XMLTools.addElement(metaGroupElement, obj.metaParameterGroupTitles{j}, infoMetaParameterGroup{i,j});
               end

               
               [infoMetaParameter, nRecordsMetaParameter] = getMetaParameter(obj, infoMetaParameterGroup{i,1});
               for m=1:nRecordsMetaParameter
               metaGroupParameterElement = XMLTools.addElement(metaGroupElement, 'MetaParameter');
               for n=1:numel(obj.metaParameterTitles)
                    XMLTools.addElement(metaGroupParameterElement, obj.metaParameterTitles{n}, infoMetaParameter{m,n});
               end
               end
               
               
               %Second level MetaParameterGroup
               [infoMetaParameterGroup2, nRecordsMetaParameterGroup2] = getMetaParameterGroup2(obj, infoMetaParameterGroup{i,1});
               if nRecordsMetaParameterGroup2> 0
               for k=1:nRecordsMetaParameterGroup2
                   metaGroupElement2 = XMLTools.addElement(metaGroupElement, 'MetaParameterGroup');
                   for l=1:numel(obj.metaParameterGroupTitles)
                    XMLTools.addElement(metaGroupElement2, obj.metaParameterGroupTitles{l}, infoMetaParameterGroup2{k,l});
                   end
                   
                   [infoMetaParameter2, nRecordsMetaParameter2] = getMetaParameter2(obj, infoMetaParameterGroup{i,1}, infoMetaParameterGroup2{k,1});
                   if nRecordsMetaParameterGroup2> 0
                   for o=1:nRecordsMetaParameter2
                   metaGroupParameterElement2 = XMLTools.addElement(metaGroupElement2, 'MetaParameter');
                       for p=1:numel(obj.metaParameterTitles)
                            XMLTools.addElement(metaGroupParameterElement2, obj.metaParameterTitles{p}, infoMetaParameter2{o,p});
                       end
                   end
                   end
                   
                   
               end
               
               
                             
               end

               
           end
           
           
           
       end
       

          
       % Retrieve the metaParameterGroups
       function [info, nRecords] = getMetaParameter(obj, metaParameterGroupId)
           % Index Meta Parameter Group
           startIndex = 1;
           endIndex   = numel(obj.metaParameterGroupTitles);
           indMember = ismember(obj.meta(:,1), metaParameterGroupId);
           meta = obj.meta(indMember,:);
           
           %Only Take Meta Parameter Group without SubGroup
           idMG2 = meta(:,numel(obj.metaParameterGroupTitles)+1);           
           idEmpty = cellfun('isempty',idMG2);
           meta = meta(idEmpty, :);
           
           nRecords = size(meta,1);

           % Get info
           startIndex = 2*numel(obj.metaParameterGroupTitles)+1;
           info =  meta(:,startIndex:end);
       end
       
              % Retrieve the metaParameterGroups
       function [info, nRecords] = getMetaParameter2(obj, metaParameterGroupId, metaParameterGroupId2)
           % Index Meta Parameter Group
           indMember = ismember(obj.meta(:,1), metaParameterGroupId);
           meta = obj.meta(indMember,:);
           
           %Only Take Meta Parameter Group without SubGroup
           idMG2 = meta(:,numel(obj.metaParameterGroupTitles)+1);           
           indMember = ismember(idMG2, metaParameterGroupId2);
           meta =  meta(indMember,:);
           
           nRecords = size(meta,1);

           % Get info
           startIndex = 2*numel(obj.metaParameterGroupTitles)+1;
           info =  meta(:,startIndex:end);
       end    

       
       
       % Retrieve the metaParameterGroups
       function [info, nRecords] = getMetaParameterGroup(obj)
           startIndex = 1;
           endIndex   = numel(obj.metaParameterGroupTitles);  
           id = obj.meta(:,startIndex);           
           [~,ia,~] = unique(id);
           nRecords = numel(ia);
           info =  obj.meta(ia,startIndex:endIndex);
       end
       
       function [info, nRecords] = getMetaParameterGroup2(obj, metaParameterGroupId)
           startIndex = numel(obj.metaParameterGroupTitles)+1;
           endIndex   = startIndex+numel(obj.metaParameterGroupTitles)-1;  
           indMember = ismember(obj.meta(:,1), metaParameterGroupId);
           meta = obj.meta(indMember,:);  
           id = meta(:,startIndex);           
           idNotEmpty = ~cellfun('isempty',id);
           meta = meta(idNotEmpty,:);
           [~, ia,~] = unique(meta(:,startIndex));
           nRecords = numel(ia);
           info =  meta(ia,startIndex:endIndex);
       end
       
       function [id] = getId(obj,parameterName)
            nameIndex  = 2*numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterTitles, 'Name'));
            idIndex  = 2*numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterTitles, 'Id'));
            ind = ismember(obj.meta(:,nameIndex), parameterName);
            id = obj.meta(ind,idIndex);
       end
       
       function [names, type] = getParameterNames(obj,ids)
          idIndex  = 2*numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterTitles, 'Id'));
          nameIndex  = 2*numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterTitles, 'Name'));
          typeIndex  = 2*numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterTitles, 'ValueType'));

          groupNameIndex  = ismember(obj.metaParameterGroupTitles, 'Name');
          [~,Locb] = ismember(ids,obj.meta(:,idIndex));
          names = [obj.meta(Locb,groupNameIndex), obj.meta(Locb,nameIndex)];
          type = obj.meta(Locb,typeIndex);
       end
       
       function ids = getIds(obj)
           idIndex1  = find(ismember(obj.metaParameterGroupTitles, 'Id'));
           idIndex2  = numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterGroupTitles, 'Id'));
           idIndex3  = 2*numel(obj.metaParameterGroupTitles) + find(ismember(obj.metaParameterTitles, 'Id'));         
           ids = [obj.meta(:,idIndex1); obj.meta(:,idIndex2); obj.meta(:,idIndex3)];
           keepInd = cellfun(@(x) ~isempty(x), ids);
           ids = ids(keepInd);
           ids = unique(cell2mat(ids),'rows');
           ids = cellstr(ids);
       end
       
   end
    
    
    
    
    
end
