classdef MixerTools
    
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
                effectiveY(i) = MixerTools.mixVector(curvesMatrix(i,:),fractions,mixType);
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
            effectiveScaler = MixerTools.mixVector(scalers,fractions,mixType);
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
    function property = getLithosProperties(lithoFileObj, sourceLithologies, propertyName, isNumber)
       
       if ~exist('isNumber', 'var'); isNumber = false; end 
       
       nLithos = numel(sourceLithologies);
       for i = 1:nLithos
            property{i}   = lithoFileObj.getValue(sourceLithologies{i}, propertyName);
       end
       
       if isNumber; property = cell2mat(property); end

    end
    % =========================================================================
    function curves = getLithosCurves(lithoFileObj, sourceLithologies, curveName)
        curves = {};
        nLithos = numel(sourceLithologies);
        parameterId = lithoFileObj.meta.getId(curveName);

        for j = 1:nLithos
            curveId = lithoFileObj.lithology.getParameterValue(sourceLithologies{j}, parameterId);
            curveValue = lithoFileObj.curve.getCurve(curveId{1});
            curves{end+1} = lithoFileObj.strcell2array(curveValue);
        end
    end
    % =========================================================================

    end
        
end