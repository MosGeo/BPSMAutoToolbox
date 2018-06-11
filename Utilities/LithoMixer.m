classdef LithoMixer < handle
   
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
    
    methods
        
        % =========================================================
        function obj = LithoMixer(type)
            % Constructor
            
            % Defaults
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
      % =========================================================
      function currentMixer = getMixerString(obj)
         currentMixer{1} = [obj.mixerText{obj.thermalCondictivity(1)} obj.mixerText{obj.thermalCondictivity(2)}];
         currentMixer{2} = [obj.mixerText{obj.permeability(1)} obj.mixerText{obj.permeability(2)}];
         currentMixer{3} = [obj.mixerText{obj.capillaryPressure(1)} obj.mixerText{obj.capillaryPressure(2)}];
      end
      
    end
    
    
    methods (Static)
       
      % =========================================================
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
      % =========================================================       
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
        
      % =========================================================       
        function effectiveScaler = mixScalers(scalers, fractions, mixType)
            effectiveScaler = LithoMixer.mixVector(scalers,fractions,mixType);
        end
      % =========================================================
        function meanValue = mixVector(x,fractions,mixType)
            % Defaults
            if exist('fractions','var')  == false; fractions = ones(size(x)); end
            if exist('mixType','var')  == false; mixTypeIndex = 1; end
          
            switch mixType
                case 1
                    meanValue = StatsTools.mean(x, fractions);
                case 2
                    meanValue = StatsTools.geomean(x, fractions);
                case 3
                    meanValue = StatsTools.harmmean(x, fractions); 
            end            
        end
        % =========================================================



    end
    
end