classdef LithoMixer < handle
   
    properties
        % 1: arithmatic, 2: Geometric, 3: harmonic
       thermalCondictivity = [1, 1]
       permeability = [1, 1]
       capillaryPressure = [1, 1]
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
    
    methods (Static)
        
        function [] = mixLithology()
            
        end   
        
    end
    
end