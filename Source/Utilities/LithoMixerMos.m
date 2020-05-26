% Custom mixer basd on Al Ibrahim, 2019 PhD thesis
classdef LithoMixerMos < handle
% Mustafa Al Ibrahim @ 2018, Stanford BPSM
% Email:    Mustafa.Geoscientist@outlook.com
% Linkedin: https://www.linkedin.com/in/mosgeo/ 
   
    % =========================================================================
    properties
       mixerText = {'Arithmetic', 'Geometric', 'Harmonic'} % 1: arithmatic, 2: Geometric, 3: harmonic
       thermalCondictivity = [2, 2]
       permeability = [2, 2]
       capillaryPressure = [1, 1]      
       mixType
    end
    
    % =========================================================================
    methods  
        function obj = LithoMixerMos(type)
            if exist('type','var')  == false; type = 'H'; end
            obj.mixType = type;
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
    function [lithoFileObj] = mixLithologies(obj, lithoFileObj, sourceLithologies, fractions, distLithoName)
        
       % Thermal conductivity
       lambdaV20C0 = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Thermal Conduct. at 20°C', true);
       alphaD = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Depositional Anisotropy', true);
       alpha0 = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Anisotropy Factor Thermal Conduct.', true);
       [effLambdaV20C0, effAlphaD, effAlpha0, effLambdaV100C0] = mixThermal(obj.mixType, fractions, lambdaV20C0, alphaD, alpha0);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. at 20°C', effLambdaV20C0);
       lithoFileObj.changeValue(distLithoName,  'Depositional Anisotropy', effAlphaD);
       lithoFileObj.changeValue(distLithoName, 'Anisotropy Factor Thermal Conduct.', effAlpha0);
       lithoFileObj.changeValue(distLithoName, 'Thermal Conduct. at 100°C', effLambdaV100C0);
       lithoFileObj.changeValue(distLithoName, 'Depositional Anisotropy (On/Off)', 'true');
       
       % Thermal conductivity II
       if (obj.mixType=='V'); meanType = 3; else; meanType =1; end
       lambdaMulti = MixerTools.getLithosCurves(lithoFileObj, sourceLithologies, 'Thermal Conduct. Multi-Point Model');
       effLambdaMulti = MixerTools.mixCurves(lambdaMulti, fractions, meanType);
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
       
       % Compaction I
       if obj.mixType=='V'; porosityType = 'L'; else; porosityType = 'D'; end
       minimumPorosity = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Minimum Porosity', true);
       initialPorosity = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Initial Porosity', true); 
       effMinimumPorosity = thomasStieberPorosity(minimumPorosity, fractions, porosityType);
       effInitialPorosity = thomasStieberPorosity(initialPorosity, fractions, porosityType);
       lithoFileObj.changeValue(distLithoName, 'Minimum Porosity', effMinimumPorosity);
       lithoFileObj.changeValue(distLithoName, 'Initial Porosity', effInitialPorosity);
       
       % Compaction II (depth based)
       depth = (0:.25:7.5); %(To Pa from MPa)
       athyFactorDepth = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Athy''s Factor k (depth)', true); % Unit is Pa
       [effectivePorosity, depth, effAthyDepth] = mixAthyDepth(obj.mixType, depth, initialPorosity, athyFactorDepth, minimumPorosity, fractions, false, 1);
       lithoFileObj.changeValue(distLithoName, 'Athy''s Factor k (depth)', effAthyDepth);
       lithoFileObj.changeValue(distLithoName, 'Compaction Model Key' , 5);  % Use this model
       
       % Compaction II (Based on stress to a multipoint curve)
%        stress = (0:2.5:75)'*10^6; %(To Pa from MPa)
%        athyFactorStress = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Athy''s Factor k (stress)', true); % Unit is Pa
%        [effectivePorosity, stress, effAthy] = mixAthyDepth(mixType, stress, initialPorosity, athyFactorStress, minimumPorosity, fractions, false, 2);
%        lithoFileObj.changeValue(distLithoName, 'Compaction Model Key', 6);
%        lithoFileObj.changeValue(distLithoName, 'Multipoint Curve', [effectivePorosity, stress*10^-6], 'Mechanical compaction', 'Compaction curves');
%        lithoFileObj.changeValue(distLithoName, 'Curve Flag' , 1);

       % Compaction IV (Whatever is left)
       stress = (0:2.5:75)'*10^6; %(To Pa from MPa)
       athyFactorStress = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Athy''s Factor k (stress)', true);
      [effectivePorosity, stress, effAthyStress] = mixAthyDepth(obj.mixType, stress, initialPorosity, athyFactorStress, minimumPorosity, fractions, false, 2);
       lithoFileObj.changeValue(distLithoName, 'Athy''s Factor k (stress)', effAthyStress);
       %lithoFileObj.changeValue(distLithoName, 'Compaction Model Key' , 3);
       
       % Compaction III
       compacProps = {'Compressibility Max';'Compressibility Min';  'Schneider Factor ka';  'Schneider Factor kb'; 'Schneider Factor phi'};
       for i = 1:numel(compacProps)
           compacProp = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, compacProps{i}, true);
           effCompacProp = MixerTools.mixScalers(compacProp, fractions, 1);
           lithoFileObj.changeValue(distLithoName, compacProps{i}, effCompacProp);
       end     

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
       
       % Compaction
       density = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Density', true);
       effDensity = MixerTools.mixScalers(density, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Density', effDensity);
       
       % Rock stress
       nud = MixerTools.getLithosProperties(lithoFileObj,     sourceLithologies, 'Poisson''s Ratio' , true);
       nu0 = MixerTools.getLithosProperties(lithoFileObj,     sourceLithologies, 'Poisson''s Ratio 2' , true);
       kd = MixerTools.getLithosProperties(lithoFileObj,      sourceLithologies, 'Constant Value 1' , true);
       k0 = MixerTools.getLithosProperties(lithoFileObj,      sourceLithologies, 'Constant Value 2' , true);
       shear = MixerTools.getLithosProperties(lithoFileObj,   sourceLithologies, 'Shear Modulus' , true);
       alphanu = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Lateral Poisson''s Ratio Fraction' , true);
       alphaK  = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Lateral Elasticity Fraction' , true); 
       kGrain = MixerTools.getLithosProperties(lithoFileObj,  sourceLithologies, 'Modulus of Elasticity Rock Matrix' , true); 

       [effKd, effnud, effalphaKd, effalphaNud, effGd]   = mixElastic(obj.mixType, kd, nud, density, fractions);
       [effK0, effnu0, effalphaK0, effalphaNu0, effG0]   = mixElastic(obj.mixType, k0, nu0, density, fractions);
       lithoFileObj.changeValue(distLithoName, 'Poisson''s Ratio', effnud);
       lithoFileObj.changeValue(distLithoName, 'Poisson''s Ratio 2', effnu0);
       lithoFileObj.changeValue(distLithoName, 'Constant Value 1', effKd);
       lithoFileObj.changeValue(distLithoName, 'Constant Value 2', effK0);
       lithoFileObj.changeValue(distLithoName, 'Shear Modulus', (effGd+effG0)/2);
       lithoFileObj.changeValue(distLithoName, 'Lateral Poisson''s Ratio Fraction', (effalphaNud + effalphaNu0)/2);
       lithoFileObj.changeValue(distLithoName, 'Lateral Elasticity Fraction', (effalphaKd + effalphaK0)/2);
       lithoFileObj.changeValue(distLithoName, 'Modulus of Elasticity Rock Matrix', hill(kGrain, fractions));
       lithoFileObj.changeValue(distLithoName, 'Elastic Model', 2);
       lithoFileObj.changeValue(distLithoName, 'Poisson''s ratio Model', 1);
       lithoFileObj.changeValue(distLithoName, 'Constant Biot Factor', 'True');
       
       if (obj.mixType=='V'); plasticModel = 1; else; plasticModel = 0; end %anisotropic vs isotropic
       lithoFileObj.changeValue(distLithoName, 'Plastic Model', plasticModel);

       % Plastic
       frictionAngle = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Friction Angle alpha'  , true);
       cohesion = MixerTools.getLithosProperties(lithoFileObj, sourceLithologies, 'Cohesion'  , true);
       effFrictionAngle = MixerTools.mixScalers(frictionAngle, fractions, 1);
       effCohesion = MixerTools.mixScalers(cohesion, fractions, 1);
       lithoFileObj.changeValue(distLithoName, 'Friction Angle alpha', effFrictionAngle);
       lithoFileObj.changeValue(distLithoName, 'Cohesion' , effCohesion);
              
   end
   % =========================================================================

   

   end 
end
