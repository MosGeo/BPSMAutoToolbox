classdef LithoMixer < handle
   
   % =========================================================================
    properties
        mixerText = {'Arithmetic', 'Geometric', 'Harmonic'}
       % 1: arithmatic, 2: Geometric, 3: harmonic
       thermalCondictivity = [2, 2]
       permeability = [2, 2]
       capillaryPressure = [1, 1]
       
       % Defaults (Currently not used)
       compressibility = 1
       heatCapacity = 1
       rockDensity = 1
       radiogenicHeat = 1
       sealProperties = 1
       fracturing = 1
       rockStress = 1 
       mechanicalCompaction = 1
       chemicalCompaction = 1
       thermalExpansion = 1
       relativePermeability = 1
    end
    
   % =========================================================================
    methods
    function obj = LithoMixer(type)
            if exist('type','var')  == false; type = 'H'; end

            switch upper(type(1))
                case 'H'
                    obj.thermalCondictivity = [2, 2];
                    obj.permeability = [2, 2];
                    obj.capillaryPressure = [1, 1];
                case 'V'
                    obj.thermalCondictivity = [3, 1];
                    obj.permeability = [3, 1];
                    obj.capillaryPressure = [1, 2];
            end            
    end
    % =========================================================================
    function currentMixer = getMixerString(obj)
         currentMixer{1} = [obj.mixerText{obj.thermalCondictivity(1)} obj.mixerText{obj.thermalCondictivity(2)}];
         currentMixer{2} = [obj.mixerText{obj.permeability(1)} obj.mixerText{obj.permeability(2)}];
         currentMixer{3} = [obj.mixerText{obj.capillaryPressure(1)} obj.mixerText{obj.capillaryPressure(2)}];
    end
    % =========================================================================
   function [lithoFileObj, parameterIds] = mixLithologies(obj, lithoFileObj, sourceLithologies, fractions, distLithoName, mixer)

       % Get lithology information
       nLithos = numel(sourceLithologies);
       lithoInfos = cell(nLithos,1);
       parameterNames = []; 
       parameterTypes=[];
       parameterIds = [];
       for i = 1:nLithos
            lithoInfos{i} =  lithoFileObj.lithology.getLithologyParameters(sourceLithologies{i});
            [pn, pt] = lithoFileObj.meta.getParameterNames(lithoInfos{i}(:,end-1));
            parameterNames = [parameterNames; pn];
            parameterTypes = [parameterTypes; pt];
            parameterIds   = [parameterIds; lithoInfos{i}(:,1:2)];
       end
       
        [~, ib,~]        = unique(parameterIds(:,2));
        parameterNames   = parameterNames(ib,:);
        parameterTypes   = parameterTypes(ib,:);
        parameterIds     = parameterIds(ib,:);

       % Get the titles of the properties
       nParameters = size(parameterIds, 1);
       for i = 1:nParameters
           
           % Get parameter information
           parameterGroupName = parameterNames{i,1};
           parameterGroupId   = parameterIds{i,1};
           parameterName = parameterNames{i,2};
           parameterType = parameterTypes{i};
           parameterId   = parameterIds{i,2};

           parameterValues = {};
           curves = {};
           for j = 1:nLithos
               [~, paramInd] = (ismember(parameterId,lithoInfos{j}(:,end-1)));
               if any(paramInd)==true
                   parameterValue = lithoInfos{j}(paramInd,end);
               else
                   parameterValue = lithoFileObj.meta.getDefaultValue(parameterId);
               end              
               parameterValues = [parameterValues, parameterValue];
               if strcmp(parameterType, 'Reference')
                    curveValue = lithoFileObj.curve.getCurve(parameterValue);
                    curves{end+1} = lithoFileObj.strcell2array(curveValue);
               end
           end         
           
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
           
           % Decide on the mixing type
           switch parameterName   
               case 'Thermal Expansion Coefficient'
                   mixType = 1;
               case 'Anisotropy Factor Permeability'
                   mixType = 1;
               case 'Depositional Anisotropy'
                   mixType = mixer.thermalCondictivity(2);
               case 'Horizontal Upscaling Factor'
                   mixType = mixer.permeability(2);
               case 'Vertical Upscaling Factor'
                   mixType = mixer.permeability(2);
               case 'Maximum Permeability Shift'
                   mixType = 2;
               %case 'Anisotropy Factor Thermal Conduct.'
                   %mixType = 1;
           end
                
           % Mix
           if isempty(parameterValues)==false || isempty(curves)==false
           switch parameterType
               case 'Decimal'
                  parameterValues = lithoFileObj.strcell2array(parameterValues);
                  effectiveValue = MixerTools.mixScalers(parameterValues, fractions, mixType);
               case 'Reference'
                  effectiveValue = MixerTools.mixCurves(curves, fractions, mixType);
               case 'Integer'
                  parameterValues = lithoFileObj.strcell2array(parameterValues);
                  effectiveValue =  parameterValues(1);
               case 'Bool'
                  effectiveValue = MixerTools.mixBooleans(parameterValues, @any);
               case 'string'
                  effectiveValue =  parameterValues(1);
           end
           else
              effectiveValue = '';
           end
       
       % Update the lithology
       lithoFileObj.changeValue(distLithoName, parameterName, effectiveValue);

       end
       
       % Mixing Anisotropy Factor thermal conductivity
       parameterName = 'Anisotropy Factor Thermal Conduct.';
       
       condVert = zeros(1,nLithos);
       condHor  = zeros(1,nLithos);
       for i = 1:nLithos
            condVert20   = lithoFileObj.getValue(sourceLithologies{i}, 'Thermal Conduct. at 20°C');
            depAnisotropy= lithoFileObj.getValue(sourceLithologies{i}, 'Anisotropy Factor Thermal Conduct.');
            condVert100  = ThermalModels.sekiguchi(condVert20, 100, 'C');
            condVert(i)  = mean([condVert20, condVert100]);
            condHor(i)   = mean([condVert20, condVert100]*depAnisotropy);
       end

       effectiveVert = MixerTools.mixScalers(condVert, fractions, mixer.thermalCondictivity(1));
       effectivehor = MixerTools.mixScalers(condHor, fractions, mixer.thermalCondictivity(2));
       effectiveDepAnisotropy = effectivehor/effectiveVert;
       lithoFileObj.changeValue(distLithoName, parameterName, effectiveDepAnisotropy);
        
    end
    % =========================================================================
   
    end
    
end