classdef XMLTools
    properties
    end
    
    methods(Static)
        
        %% Read XML file
        function [docNode, xmlDoc] = readXML(filename)
            try
                xmlDoc = xmlread(filename);
                docNode = xmlDoc.getDocumentElement;
            catch
                error('Failed to read XML file %s.',filename);
            end
        end
        
        %% Create New XML file
        function [docNode, xmlDoc] = createXML(rootname)
            xmlDoc = com.mathworks.xml.XMLUtils.createDocument(rootname);
            docNode = xmlDoc.getDocumentElement;
        end

        %% Find elements by tag searching only the children if required
        function finalElements = getElementsByTagName(parentNode, tag, isChildOnly)
            
            % Default values:
            if exist('isChildOnly', 'var') == false; isChildOnly = false; end


            allElements  = parentNode.getElementsByTagName(tag);
            nAllElements = allElements.getLength();

            finalElements = {};
            for i = 1:nAllElements
                if isChildOnly == true
                    if allElements.item(i-1).getParentNode() == parentNode
                     finalElements = [finalElements, allElements.item(i-1)];
                    end
                else
                    finalElements = [finalElements, allElements.item(i-1)];  

                end
            end
        end
        
        
       %% 
       function nodeValue = anlyzeNodeValue(parentNode, tag)

           foundElements  = XMLTools.getElementsByTagName(parentNode, tag);
           if  length(foundElements) >= 1 && foundElements.hasChildNodes == true
                  nodeValue = char(foundElements.getFirstChild.getData);
              else
                  nodeValue ='';
           end
       end
        
        %% Set Attribute
        function [] = setAttribute(docNode, name, value)
            docNode.setAttribute(name,value);
        end
        
        %% Add Node
        function element = addElement(docNode, elementName, data)
             
             if exist('data', 'var') == true
                if length(data)==0
                    return;
                end
             end   
            
             xmlDoc = docNode.getOwnerDocument;
             element = xmlDoc.createElement(elementName);
             docNode.appendChild(element);
             
             if exist('data', 'var') == true
                if length(data)>0
                    element.appendChild(xmlDoc.createTextNode(data));
                end
             end       
        end
        
        %%
        function [] = saveXML(xmlDoc, filename)
            xmlwrite(filename,xmlDoc);
        end
            
    end
end
