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
           id = obj.meta.getId(parameterName);
           obj.lithology.updateLithologyParametersValue(lithologyName, id, value);
       end
   %=====================================================
      
       function [] = changeCurve (obj, lithologyName, parameterName, matrix)
           id = obj.meta.getId(parameterName);
           curveId = obj.lithology.getCurveId(lithologyName, id);
           obj.curve.updateCurve(curveId, matrix);
       end
   %=====================================================
       function obj = deleteLithology(obj, lithologyName)
           lithologyIndex = obj.lithology.getLithologyIndex(lithologyName);
           obj.lithology.lithology(lithologyIndex,:)=[];
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
   function [] = writeLithologyFile(obj, fileName, isOverwrite)
        %WRITELITHOLOGYFILE Write lithology file
        %   write the lithology file and returns 

       % Default values:
       if exist('isOverwrite','var') == false; isOverwrite = false; end
       if exist('fileName','var')  == false; fileName = 'Output.xml'; end

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
   function allIds = getIds(obj)   
       allIds = [obj.meta.getIds(); obj.curve.getIds(); obj.lithology.getIds()];
   end
   %=====================================================
   function [] = addLithology(obj, sourceLithoName, distLithoName)
        allIds = obj.getIds();
        hash = HashTools.getUniqueHash(allIds);
        lithologyIndex = obj.lithology.getLithologyIndex(sourceLithoName);
        oldLithology = obj.lithology.lithology(lithologyIndex,:);
        obj.changeValue(sourceLithoName, 'Id', hash)
        obj.changeValue(sourceLithoName, 'Name', distLithoName)
        obj.lithology.lithology(end+1,:)= oldLithology;
   end  
    
    
   end

end
