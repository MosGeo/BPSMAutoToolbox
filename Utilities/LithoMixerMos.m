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

    
    
    % =========================================================================
    function [lithoFileObj, parameterIds] = mixLithologies(obj, lithoFileObj, sourceLithologies, fractions, distLithoName, mixer, isOverwrite)
        
       mixType = 'V';
       
       % Thermal conductivity
       lambdaV20C0 = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Thermal Conduct. at 20°C', true);
       alphaD = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Depositional Anisotropy', true);
       alpha0 = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Anisotropy Factor Thermal Conduct.', true);
       [effLambdaV20C0, effAlphaD, effAlpha0, effLambdaV100C0] = mixThermal(mixType, fractions, lambdaV20C0, alphaD, alpha0);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. at 20°C', effLambdaV20C0);
       lithoFileObj.changeValue(distLithoName,  'Depositional Anisotropy', effAlphaD);
       lithoFileObj.changeValue(distLithoName, 'Anisotropy Factor Thermal Conduct.', effAlpha0);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. at 100°C', effLambdaV100C0);
       lithoFileObj.changeValue(distLithoName, 'Depositional Anisotropy (On/Off)', 'true');
       
       % Thermal conductivity II
       lambdaMulti = MixerTools.getLithosCurves(lithoFileObj, sourceLithologies, 'Thermal Conduct. Multi-Point Model');
       effLambdaMulti = MixerTools.mixCurves(lambdaMulti, fractions, 3);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. Multi-Point Model', effLambdaMulti);

       % Thermal conductivity III
       expansionCoeff = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Thermal Expansion Coefficient', true);
       effExpansionCoeff  = MixerTools.mixScalers(expansionCoeff, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Thermal Expansion Coefficient', effExpansionCoeff);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. Model Key', 1);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. Max. Temperature', 593.15);
       
       % Heat capacity
       heatCapacity20C = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Heat Capacity at 20°C', true);
       heatCapacity100C = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Heat Capacity at 100°C', true);
       effHeatCapacity20C = MixerTools.mixScalers(heatCapacity20C, fractions, 1);
       effHeatCapacity100C = MixerTools.mixScalers(heatCapacity100C, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Heat Capacity at 20°C', effHeatCapacity20C);
       lithoFileObj.changeValue(distLithoName,  'Heat Capacity at 100°C', effHeatCapacity100C);
       lithoFileObj.changeValue(distLithoName,  'Heat Capacity Model', 4);
       lithoFileObj.changeValue(distLithoName, 'Heat Capacity Max. Temperature', 593.15);

       % Heat capacity II
       heatCapacityCurve = MixerTools.getLithosCurves(lithoFileObj, sourceLithologies, 'Heat Capacity Curve');
       effHeatCapacityCurve = MixerTools.mixCurves(heatCapacityCurve, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Heat Capacity Curve', effHeatCapacityCurve);
       
       % Radiogenic heat
       uranium = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Uranium', true);
       thorium = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Thorium', true);
       potassium = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Potassium', true);
       effUranium = MixerTools.mixScalers(uranium, fractions, 1);
       effThorium = MixerTools.mixScalers(thorium, fractions, 1);
       effPotassium = MixerTools.mixScalers(potassium, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Uranium', effUranium);
       lithoFileObj.changeValue(distLithoName, 'Thorium', effThorium);
       lithoFileObj.changeValue(distLithoName, 'Potassium', effPotassium);

       % Compaction
       density = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Density', true);
       effDensity = MixerTools.mixScalers(density, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Density', effDensity);
       
       % Compaction II
       stress = (0:2.5:75)' * 10^6;
       athyFactorDepth = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Athy''s Factor k (stress)', true);
       athyFactorDepth = athyFactorDepth*10^(6)
       minimumPorosity = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Minimum Porosity', true);
       initialPorosity = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Initial Porosity', true); 
       [effectivePorosity, stress] = mixAthyDepth(mixType, stress, initialPorosity, athyFactorDepth, minimumPorosity, fractions);
       lithoFileObj.changeValue(distLithoName, 'Compaction Model Key', 6);
       lithoFileObj.changeValue(distLithoName, 'Multipoint Curve', [effectivePorosity, stress], 'Mechanical compaction', 'Compaction curves');
       lithoFileObj.changeValue(distLithoName, 'Curve Flag' , 1);

       % Compaction II
       compressibilityMax = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Compressibility Max', true);
       compressibilityMin = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Compressibility Min', true);
       schneiderKa = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Schneider Factor ka', true);
       schneiderKb = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Schneider Factor kb', true);
       schneiderPhi = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Schneider Factor phi', true);
       athyFactorStress = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Athy''s Factor k (stress)', true);
 
       % Diagensis
       chemProps = {'Reference Viscosity';...
                    'Reference Temperature';...
                   'Schneider Activation Energy';....
                   'Quartz Grain Volume Fraction';....
                   'Quartz Grain Size';...
                   'Walderhaug Frequency Factor'};
      for i = 1:numel(chemProps)
           chemProp = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, chemProps{i}, true);
           effChemProp = MixerTools.mixScalers(chemProp, fractions, 1);
           lithoFileObj.changeValue(distLithoName, chemProps{i}, effChemProp);
       end            
       
       % Permeability
       upscalingH = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Horizontal Upscaling Factor', true);
       upscalingV = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Vertical Upscaling Factor', true);
       anisotropy = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Anisotropy Factor Permeability', true);
       ssa = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Specific Surface Area', true);
       [effUpscalingH, effUpscalingV, effAnistropy] = mixPermeabilityParam('V', upscalingH, upscalingV, anisotropy, fractions);
       effSsa = MixerTools.mixScalers(ssa, fractions, 1); 
       lithoFileObj.changeValue(distLithoName,  'Horizontal Upscaling Factor', effUpscalingH);
       lithoFileObj.changeValue(distLithoName, 'Vertical Upscaling Factor', effUpscalingV);
       lithoFileObj.changeValue(distLithoName, 'Anisotropy Factor Permeability', effAnistropy);
       lithoFileObj.changeValue(distLithoName, 'Specific Surface Area', effSsa);
       
       % Permeability
       pemeabilityMulti = MixerTools.getLithosCurves(lithoFileObj, sourceLithologies, 'Permeability Multi-Point Model Key');
       effHeatCapacityCurve = MixerTools.mixCurves(pemeabilityMulti, fractions, 3);
       lithoFileObj.changeValue(distLithoName, 'Permeability Multi-Point Model Key', effHeatCapacityCurve);

       % Relative Permeability
       criticalOilSat = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Critical oil saturation', true);
       effCreticalOilSat = MixerTools.mixScalers(criticalOilSat, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Critical oil saturation', effCreticalOilSat);
       
       % Seal Properties
       sealingProps = { 'CapillaryPressure (a*por+b) Parameter A';...
                       'CapillaryPressure (a*por+b) Parameter B';...
                       'CapillaryPressure (a*perm^b) Parameter A';...
                       'CapillaryPressure (a*perm^b) Parameter B';...
                       'Capillary Pressure a*10^(b*por) Parameter A';...
                       'Capillary Pressure a*10^(b*por) Parameter B'};
       for i = 1:numel(sealingProps)
           sealingProp = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, sealingProps{i}, true);
           effSealingProp = MixerTools.mixScalers(sealingProp, fractions, 1);
           lithoFileObj.changeValue(distLithoName, sealingProps{i}, effSealingProp);
       end
       
       
       % Rock stress
       {'Poisson''s Ratio';'Constant Value 1';...
           'Constant Value 2';...
           'Plastic Model';...
           'Friction Angle alpha';...
           'Poisson''s Ratio 2';...
           'Shear Modulus';...
           'Lateral Poisson''s Ratio Fraction';...
           'Lateral Elasticity Fraction';...
           'Modulus of Elasticity Rock Matrix';...
           'Cohesion';...
           'Constant Biot Factor'}
       
       
       
       % Miscllaneous
       
       % Mixing
       
       % Pattern Editor
       parameterIds = [];
       
   end
   % =========================================================================

   

   end 
end
