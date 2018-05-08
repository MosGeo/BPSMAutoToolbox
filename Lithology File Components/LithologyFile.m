classdef LithologyFile
   
    properties
       meta
       curve
       lithology
       xmlnsXsd
       xmlnsXsi
       xmlDoc
   end
   
   methods
       function obj = LithologyFile(fileName)
            if exist('fileName','var') == true
               [obj.meta, obj.curve, obj.lithology, obj.xmlnsXsd, obj.xmlnsXsi, obj.xmlDoc]  = obj.readLithologyFile(fileName);
            end 
       end
             
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
       
       function [] = writeLithologyFile(obj, fileName, isOverwrite)
            %WRITELITHOLOGYFILE Write lithology file
            %   write the lithology file and returns 
            
           % Default values:
           if exist('isOverwrite','var') == false; isOverwrite = false; end
           if exist('fileName','var')  == false; fileName = 'Output.xml'; end
           
           % Catalogue
           [docNode, xmlDoc] = XMLTools.createXML('Catalogue');
           XMLTools.setAttribute(docNode, 'xmlns:xsd', obj.xmlnsXsd);
           XMLTools.setAttribute(docNode, 'xmlns:xsi', obj.xmlnsXsi);
           XMLTools.addElement(docNode, 'Name', 'Lithology catalog');
           XMLTools.addElement(docNode, 'Version', '2.1');
           XMLTools.addElement(docNode, 'ReadOnly', 'false');
           
           % Meta
           metaElement = XMLTools.addElement(docNode, 'Meta');
           [infoMetaParameterGroup] = obj.meta.getMetaParameterGroups();
           for i=1:infoMetaParameterGroup.n
              metaGroupElement = XMLTools.addElement(metaElement, 'MetaParameterGroup');
              XMLTools.addElement(metaGroupElement, 'Id', infoMetaParameterGroup.id{i});
              XMLTools.addElement(metaGroupElement, 'Name', infoMetaParameterGroup.name{i});
              
               [infoMetaParameter] = obj.meta.getMetaParameter(infoMetaParameterGroup.id{i});
%               for j = 1:infoMetaParameter.n
%                    metaParameterElement = XMLTools.addElement(metaGroupElement, 'MetaParameter');
%                    XMLTools.addElement(metaParameterElement, 'Id', infoMetaParameter.id{j});
%                    XMLTools.addElement(metaParameterElement, 'Name', infoMetaParameter.name{j});
%                    XMLTools.addElement(metaParameterElement, 'ValueType', infoMetaParameter.valueType{j});
%                    XMLTools.addElement(metaParameterElement, 'PetrelTemplate', infoMetaParameter.petrelTemplate{j});
%                    XMLTools.addElement(metaParameterElement, 'PetroModUnit', infoMetaParameter.petroModUnit{j});
%                    XMLTools.addElement(metaParameterElement, 'ReadOnly', infoMetaParameter.readOnly{j});
%               end
           end
           
%            % Curve
%            [infoCurveGroup] = obj.curve.getCurveGroups();
%            for i=1:infoCurveGroup.n
%               curveGroupElement = XMLTools.addElement(docNode, 'CurveGroup');
%               XMLTools.addElement(curveGroupElement, 'Id', infoCurveGroup.id{i});
%               XMLTools.addElement(curveGroupElement, 'Name', infoCurveGroup.name{i});
%               XMLTools.addElement(curveGroupElement, 'ReadOnly', infoCurveGroup.readOnly{i});
%               
%               [infoCurves] = obj.curve.getCurves(infoCurveGroup.id{i});
%               for j = 1:infoCurves.n
%                  curveElement = XMLTools.addElement(curveGroupElement, 'Curve');
%                  XMLTools.addElement(curveElement, 'Id', infoCurves.id{j});
%                  XMLTools.addElement(curveElement, 'Name', infoCurves.name{j});
%                  XMLTools.addElement(curveElement, 'ReadOnly', infoCurves.readOnly{j});
%                  XMLTools.addElement(curveElement, 'PetrelTemplateX', infoCurves.petrelTemplateX{j});
%                  XMLTools.addElement(curveElement, 'PetrelTemplateY', infoCurves.petrelTemplateY{j});
%                  XMLTools.addElement(curveElement, 'PetroModUnitX', infoCurves.petroModUnitX{j});
%                  XMLTools.addElement(curveElement, 'PetroModUnitY', infoCurves.petroModUnitY{j});
%                  XMLTools.addElement(curveElement, 'PetroModId', infoCurves.petroModId{j});
%                  nCurvePoints = size(infoCurves.curvePoints{j},1);
%                  for k = 1:nCurvePoints
%                    curvePointElement = XMLTools.addElement(curveElement, 'CurvePoint');
%                    XMLTools.addElement(curvePointElement, 'X', infoCurves.curvePoints{j}(k,1));
%                    XMLTools.addElement(curvePointElement, 'Y', infoCurves.curvePoints{j}(k,2));
%                  end
%               end
%            end
%            
%            % Lithology
%             [infoLithologyGroup1] = obj.curve.getCurveGroups();

           
           XMLTools.saveXML(xmlDoc, fileName);
        %%     
       end

   end
    
    
end