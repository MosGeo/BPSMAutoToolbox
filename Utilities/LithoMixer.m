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
    % =========================================================================
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
 
    % =========================================================================  

    end
    
    % =========================================================================  
    methods (Static)     
    % =========================================================================
        function effectiveCurve = mixCurves(curves, fractions, mixType)
            nCurves = numel(curves);
            
            xValues = [];
            for i = 1:nCurves
                xValues = [xValues; curves{i}(:,1)];
            end
            
            xFinal = unique(xValues);
            nPoints = numel(xFinal);

            curvesMatrix = zeros(nPoints, nCurves);
            for i = 1:nCurves
                x = curves{i}(:,1);
                y = curves{i}(:,2);
                newY = interp1(x,y, xFinal, 'linear', nan);
                newY(xFinal > max(x)) = max(y);
                newY(xFinal < min(x)) = min(y);
                curvesMatrix(:,i) = newY;
            end
            
            effectiveY= zeros(nPoints,1);
            for i = 1:nPoints
                effectiveY(i) = LithoMixer.mixVector(curvesMatrix(i,:),fractions,mixType);
            end
            effectiveCurve = [xFinal, effectiveY];
        end
    % =========================================================================
      function effectiveBool = mixBooleans(bools, mixFunc)
         
          if exist('mixFunc','var')  == false; mixFunc = @mode; end

          nPoints = numel(bools);
          boolsValues = zeros(nPoints, 1);
          for i = 1:nPoints
              boolText = lower(bools{i});
              boolsValues(i)= eval(boolText);
          end
          
          effectiveValue = mixFunc(boolsValues);
          switch effectiveValue
              case 1
                 effectiveBool = 'True';
              case 0
                effectiveBool = 'False';
          end
      end
        
    % =========================================================================
        function effectiveScaler = mixScalers(scalers, fractions, mixType)
            effectiveScaler = LithoMixer.mixVector(scalers,fractions,mixType);
        end
    % =========================================================================
        function meanValue = mixVector(x,fractions,mixType)
            % Defaults
            if ~exist('fractions','var'); fractions = ones(size(x)); end
            if ~exist('mixType','var'); mixType = 1; end
          
            switch mixType
                case 1
                    meanValue = StatsTools.mean(x, fractions);
                case 2
                    meanValue = StatsTools.geomean(x, fractions);
                case 3
                    meanValue = StatsTools.harmmean(x, fractions); 
            end            
        end
    % =========================================================================
   function [lithoFileObj, parameterIds] = mixLithology(lithoFileObj, sourceLithologies, fractions, distLithoName, mixer, isOverwrite)

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
       if lithoFileObj.isLithologyExist(distLithoName) && ~isOverwrite
           disp('Lithology exist, give permission to overwrite to continue')
       end
       
       % Delete lithology if overwrite is turned on
       if lithoFileObj.isLithologyExist(distLithoName) && isOverwrite
           lithoFileObj.deleteLithology(distLithoName);
       end
       
       % Dublicate lithology and insert mix information
       lithoFileObj.duplicateLithology(sourceLithologies{1}, distLithoName);
       lithoFileObj.lithology.updateMix(distLithoName, sourceLithologies, fractions, mixer)

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
                  effectiveValue = mixer.mixScalers(parameterValues, fractions, mixType);
               case 'Reference'
                  effectiveValue = mixer.mixCurves(curves, fractions, mixType);
               case 'Integer'
                  parameterValues = lithoFileObj.strcell2array(parameterValues);
                  effectiveValue =  parameterValues(1);
               case 'Bool'
                  effectiveValue = mixer.mixBooleans(parameterValues, @any);
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
        condVert(i)     = mean([condVert20, condVert100]);
        condHor(i)      = mean([condVert20, condVert100]*depAnisotropy);
       end

       effectiveVert = mixer.mixScalers(condVert, fractions, mixer.thermalCondictivity(1));
       effectivehor = mixer.mixScalers(condHor, fractions, mixer.thermalCondictivity(2));
       effectiveDepAnisotropy = effectivehor/effectiveVert;
       lithoFileObj.changeValue(distLithoName, parameterName, effectiveDepAnisotropy);
        
    end
    % =========================================================================
   
    end
    
end