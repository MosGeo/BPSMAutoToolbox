classdef Curve
   properties(SetAccess = public)
       curveGroupTitles = {'Id', 'Name', 'ReadOnly'}
       curveTitles = {'Id', 'Name', 'ReadOnly', 'PetrelTemplateX', 'PetrelTemplateY', 'PetroModUnitX', 'PetroModUnitY', 'PetroModId', 'CurvePoints'};
       curvePointTitles = {'X', 'Y'}
       curveGroups
   end
   
   methods
       function obj = Curve(curveGroupNodes)
            if exist('curveGroupNodes','var') == true
                obj.curveGroups = obj.analyzeCurveGroupNodes(curveGroupNodes);  
            end
       end
       
       %%
       function curveGroups = analyzeCurveGroupNodes(obj, curveGroupNodes)
           nCurveGroups = curveGroupNodes.getLength;
           curveGroups = {};
           for i=0:nCurveGroups-1
               curveGroupNode = curveGroupNodes.item(i);
               curveGroup = obj.analyzeCurveGroupNode(curveGroupNode);
               curveGroups = [curveGroups; curveGroup];
           end
       end
       
       %%
       function curveGroup = analyzeCurveGroupNode(obj, curveGroupNode)
          id   = char(curveGroupNode.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name   = char(curveGroupNode.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly   = char(curveGroupNode.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          
          curveNodes = curveGroupNode.getElementsByTagName('Curve');
          nCurveNodes = curveNodes.getLength;
          
          curveGroup = {};
          if nCurveNodes > 0
             for i = 0:nCurveNodes-1
                 curveNode     = curveNodes.item(i);
                 curve         = obj.analyzeCurve(curveNode);
                 curveGroupRow = [id, name, readOnly, curve];
                 curveGroup    = [curveGroup; curveGroupRow];
             end
          else
                curve = {'', '', '', '', '', '', '', '', ''};
                curveGroupRow = [id, name, readOnly, curve];
                curveGroup    = [curveGroup; curveGroupRow];
          end
       end
       
       %%
       function curve = analyzeCurve(obj, curveNode)
          id                = char(curveNode.getElementsByTagName('Id').item(0).getFirstChild.getData);
          name              = char(curveNode.getElementsByTagName('Name').item(0).getFirstChild.getData);
          readOnly          = char(curveNode.getElementsByTagName('ReadOnly').item(0).getFirstChild.getData);
          petrelTemplateX   = char(curveNode.getElementsByTagName('PetrelTemplateX').item(0).getFirstChild.getData);
          petrelTemplateY   = char(curveNode.getElementsByTagName('PetrelTemplateY').item(0).getFirstChild.getData);
          petroModUnitX     = char(curveNode.getElementsByTagName('PetroModUnitX').item(0).getFirstChild.getData);
          petroModUnitY     = char(curveNode.getElementsByTagName('PetroModUnitY').item(0).getFirstChild.getData);
          petroModId        = char(curveNode.getElementsByTagName('PetroModId').item(0).getFirstChild.getData);       
          curvePointNodes   = curveNode.getElementsByTagName('CurvePoint');
          nCurvePointNodes  = curvePointNodes.getLength;
          
          curvePoints = {};
          if nCurvePointNodes>0
             for i = 0:nCurvePointNodes-1
                 curvePointNode = curvePointNodes.item(i);
                 curvePoint = obj.analyzeCurvePoint(curvePointNode);
                 curvePoints = [curvePoints; curvePoint];
             end
          else
              curvePoints = '';
          end
          
          curve = {id, name, readOnly, petrelTemplateX, petrelTemplateY, petroModUnitX, petroModUnitY, petroModId, curvePoints};
           
       end
       
       %%
       function curvePoint = analyzeCurvePoint(obj, curvePointNode)
             x   = char(curvePointNode.getElementsByTagName('X').item(0).getFirstChild.getData);
             y   = char(curvePointNode.getElementsByTagName('Y').item(0).getFirstChild.getData);
             curvePoint = {x, y};
       end
   
   end
   
   %% Get Methods
   methods
       
       function [info] = getCurveGroups(obj)
           [id, ia, ~]  = unique(obj.curveGroups(:,1));
           info.id = id;
           info.name  = obj.curveGroups(ia,2);
           info.readOnly = obj.curveGroups(ia,3);
           info.n = numel(id);       
       end
       
       function [info] = getCurves(obj, groupId)
          selectedCurves = ismember(obj.curveGroups(:,1), groupId);
          info.id              = obj.curveGroups(selectedCurves, 4);
          info.name            = obj.curveGroups(selectedCurves, 5);
          info.readOnly        = obj.curveGroups(selectedCurves, 6);
          info.petrelTemplateX = obj.curveGroups(selectedCurves, 7);
          info.petrelTemplateY = obj.curveGroups(selectedCurves, 8);
          info.petroModUnitX   = obj.curveGroups(selectedCurves, 9);
          info.petroModUnitY   = obj.curveGroups(selectedCurves, 10);
          info.petroModId      = obj.curveGroups(selectedCurves, 11);
          info.curvePoints     = obj.curveGroups(selectedCurves, 12);
          info.n               = sum(selectedCurves);
       end
          
           
       
   end

end