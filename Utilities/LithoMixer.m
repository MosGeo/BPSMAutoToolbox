classdef LithoMixer < handle
   
    properties
        
        
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
        function obj = LithoMixer(obj, type)
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
       
    end
    
    
    methods (Static)
       
      % =========================================================
        function effectiveCurve = mixCurves(curves, fractions, mixType)
            nPoints = size(curves,1);
            
            effectiveCurve = zeros(nPoints,1);
            for i = 1:nPoints
                effectiveCurve(i) = LithoMixer.mixVector(curves(i,:),fractions,mixType);
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
                    meanValue = StatsTools.harmman(x, fractions); 
            end
            
        end
      % =========================================================

    end
    
end