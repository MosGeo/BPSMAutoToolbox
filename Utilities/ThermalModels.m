classdef ThermalModels
   
    methods (Static)
        
        % ==============================================
        function lambda = sekiguchi(lambda20, T, tempUnit)
        % SEKIGUCHI Calculates the thermal conductivity (lambda) at a
        % given temperature T. Based on: K., Sekiguchi, 1984, A method for
        % determining terrestrial heat flow in oil basinal areas, in
        % Cermak, V., Raybach, L., and Chapman, D. S. (eds), Terrestrial
        % heat flow studies and the structure of the lithosphere,
        % Tectonophysics, v. 103, p. 67-79.
            
            % Defaults
            if ~exist('tempUnit', 'var'); tempUnit = 'C'; end
        
            % Assertions
            assert(exist('lambda20', 'var') && exist('T', 'var'), 'lambda20 and T must be provided');
            assert(isnumeric(lambda20) && isnumeric(T), 'lambda20 and T must be numerics');
            assert(all(size(lambda20) == size(T)), 'Number of elements in lambda20 and T must be the same');
            assert(ismember(tempUnit, {'C', 'K'}), 'Temperature unit must be C or K');
            
            % Main
            if strcmp(tempUnit, 'C'); T = T + 273.15; end
            lambda = 1.84 + 358 *(1.0227 * lambda20 - 1.882) .* (1./T - 0.00068);
        end
        
        % ==============================================
        function lambda = multipoint(curve, T)
        % MULTIPOINT Calculates the thermal conductivity (lambda) at a
        % given temperature T. Interplation is constant outside the curve
        % range.
        
            % Assertions
            assert(exist('curve', 'var') && exist('T', 'var'), 'curve and T must be provided');
            assert(isnumeric(curve) && isnumeric(T), 'curve and T must be numerics');
            assert(size(curve, 2) == 2, 'curve must be a 2 column matrix');
            
            % Main
            Ts = curve(:,1);
            labmdas = curve(:,2);
            [minT,minIndex] = min(Ts);
            [maxT,maxIndex] = max(Ts);
            
            lambda = interp1(Ts, labmdas, T);
            lambda(T<minT) = labmdas(minIndex);
            lambda(T>maxT) = labmdas(maxIndex);
        end
       
        % ==============================================
        function lambda = felsic(T)
        % FELSIC A felsic model for thermal conductivity. Temperature is in
        % C. Function source: PetroMod help.
        
            % defaults
            if ~exist('T', 'var'); T = 20; end
            
            % Assertions
            assert(isnumeric(T), 'T must be numeric');
            
            % Main
            lambda = 0.64 + 807./(T+350);
        end
        
        % ==============================================
        function lambda = mafic(T)
        % MAFIC A mafic model for thermal conductivity. Temperature is in
        % C. Function source: PetroMod help.
        
            % defaults
            if ~exist('T', 'var'); T = 20; end
            
            % Assertions
            assert(isnumeric(T), 'T must be numeric');
            
            % Main
            lambda = 1.18 + 474./(T+350);   
        end
        
        % ==============================================
        function lambda = Olivine(T)
        % MAFIC An olivine model for thermal conductivity. Temperature is in
        % C. Function source: PetroMod help.
        
            % defaults
            if ~exist('T', 'var'); T = 20; end
            
            % Assertions
            assert(isnumeric(T), 'T must be numeric');
            
            % Main
            lambda = 0.0023 * (T - 226.84) + 1./(0.0005*T + 0.221);     
        end        
        % ==============================================    
        
    end
    
    
end