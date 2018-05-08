classdef Meta
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
       
       % Retrieve the metaParameter
       function [info] = getMetaParameter(obj, groupId)
          selectedMeta = ismember(obj.meta(:,1), groupId);
          info.id = obj.meta(selectedMeta,3);
          info.name = obj.meta(selectedMeta,4);
          info.valueType = obj.meta(selectedMeta,5);
          info.defaultValue = obj.meta(selectedMeta,6);
          info.petrelTemplate = obj.meta(selectedMeta,7);
          info.petroModUnit = obj.meta(selectedMeta,8);
          info.readOnly =  obj.meta(selectedMeta,9);
          info.n = sum(selectedMeta);
       end
       
       % Retrieve the metaParameterGroups
       function [info] = getMetaParameterGroups(obj)
           [id, ia, ~]  = unique(obj.meta(:,1));
           info.id = id;
           info.name  = obj.meta(ia,2);
           info.n = numel(id);       
       end
       
   end
    
    
    
    
    
end
