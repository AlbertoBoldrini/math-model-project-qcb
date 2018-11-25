classdef Ecosystem < handle

    properties
        
        % Coordinate of the rectangular boundaries
        x1 = 0, y1 = 0;
        x2 = 1, y2 = 1;
        
        % Number of points in space and the space-step
        nX, nY;
        dx, dy;
        
        % Current time and the time-step
        t , dt;
        
        % The mesh matrices
        X , Y;
        
        % The number of species 
        nS = 0;
        
        % List of the species
        species = cell(0);
    end
    
    methods
        function this = Ecosystem(nY, nX)
            
            this.nX = nX;
            this.nY = nY;
            
        end
        
        function out = createSpecies(this)
            
            % Increment the number of species
            this.nS = this.nS + 1;
            
            % Add a new species in the list
            this.species{this.nS} = Species(this, this.nS);
            
            % Return the created species
            out = this.species{this.nS};
            
        end
        
        function setTime(this, t, dt)
            
            % Set the time and the time-step
            this.t  = t;
            this.dt = dt;
            
        end
        
        function setSpace(this, x1, y1, x2, y2)
            
            % Save the coordinates
            this.x1 = x1;
            this.y1 = y1;
            this.x2 = x2;
            this.y2 = y2;
            
            % Compute the space steps
            this.dx = (x2 - x1) / (this.nX - 1);
            this.dy = (y2 - y1) / (this.nY - 1);
            
            % Compute the mesh matrices
            [this.X, this.Y] = meshgrid(linspace(x1, x2, this.nX), ... 
                                        linspace(y1, y2, this.nY));
            
        end
        
        function setGrowFunction(this, growfunc)
            
            this.growfunc = growfunc;
        
        end
        
        function prepareSystemMatrices(this)
           
            for i = 1:this.nS
                this.species{i}.prepareSystemMatrices();
            end
            
        end

        function evolve(this)
            
            grow = cell(this.nS, 1);
            
            % Compute the grow rate for each species
            for i = 1:this.nS
                grow{i} = this.species{i}.grow(this, this.species{i});
            end
            
            % Evolve each species
            for i = 1:this.nS
                
                % Reshape the density and the grow rate
                u = reshape(this.species{i}.density, this.nY * this.nX, 1);
                g = reshape(        grow{i}, this.nY * this.nX, 1);
                
                % Compute the density at the next step
                this.species{i}.density = reshape(this.species{i}.A \ (this.species{i}.B * u + g * this.dt), this.nY, this.nX);
                
                % Increment the time of the simulation
                this.t = this.t + this.dt;
            end
        end
        
        
        
%         function plot(this)
%             
%             for i = 1:this.nS
%                
%                 plot(this.Y, this.species{i}.density);
%                 
%                 hold on
%                 
%             end
%             
%         end
    end
end

