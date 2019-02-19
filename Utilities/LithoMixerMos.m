% Custom mixer basd on Al Ibrahim et al., 2019
classdef LithoMixerMos < handle
   
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
   function [lithoFileObj, parameterIds] = mixLithology(obj, lithoFileObj, sourceLithologies, fractions, distLithoName, mixer, isOverwrite)

       
       
   end
   % =========================================================================

   end 
end
