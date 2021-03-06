classdef Ecosystem < handle

    properties
        
        % Coordinate of the rectangular boundaries
        x1 = 0, y1 = 0;
        x2 = 1, y2 = 1;
        
        % Number of points in space and the space-step
        nX = 0, nY = 0;
        dx = 0, dy = 0;
        
        % Current time and the time-step
        t = 0, dt = 0;
        
        % The mesh matrices
        X , Y;
        
        % The number of species 
        nS = 0;
        
        % List of the species
        species = cell(0);
        
        % 2D image of the system
        background = 0;
        image = 0;
    end
    
    methods
        function this = Ecosystem(nY, nX)
            
            this.nX = nX;
            this.nY = nY;
            
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
        
        function out = createSpecies(this, name, color)
            
            if this.dx == 0 || this.dy == 0 || this.dt == 0
                error("The time and space domain of the ecosystem must be specified before!");
            end
            
            % Increment the number of species
            this.nS = this.nS + 1;
            
            % Add a new species in the list
            this.species{this.nS} = Species(this, this.nS, name, color);
            
            % Return the created species
            out = this.species{this.nS};
            
        end
        
        function startSimulation(this)
            
            for i = 1:this.nS
                this.species{i}.startSimulation();
            end
            
        end
        
        function eulerStep(this)
            
            grow = cell(this.nS, 1);
            
            % Compute the grow rate for each species
            for i = 1:this.nS
                grow{i} = this.species{i}.grow(this, this.species{i});
            end
            
            % Evolve each species
            for i = 1:this.nS
                
                % Fetch the current species
                s = this.species{i};
                
                % Reshape the density and the grow rate
                u = reshape(s.density, this.nY * this.nX, 1);
                g = reshape(  grow{i}, this.nY * this.nX, 1);
                
                % Compute the density at the next step
                u = s.B * (s.B * (u + g * this.dt));
                
                % Reshape the result into a matrix form
                s.density = reshape(u, this.nY, this.nX);
            end
            
            % Increment the time of the simulation
            this.t = this.t + this.dt;
        end
        
        function multiEulerStep(this, nDiffusions)
            
            grow = cell(this.nS, 1);
            
            % Compute the grow rate for each species
            for i = 1:this.nS
                grow{i} = this.species{i}.grow(this, this.species{i});
            end

            % Evolve each species
            for i = 1:this.nS
                
                % Fetch the current species
                s = this.species{i};
                
                % Reshape the density and the grow rate
                u = reshape(s.density, this.nY * this.nX, 1);
                g = reshape(  grow{i}, this.nY * this.nX, 1);
                
                % Grow the species
                u = u + g * this.dt * nDiffusions;
                
                % Compute the density at the next step
                for j = 1:nDiffusions
                    u = s.B * (s.B * u);
                end
                    
                % Reshape the result into a matrix form
                s.density = reshape(u, this.nY, this.nX);
            end

            % Increment the time of the simulation
            this.t = this.t + this.dt * nDiffusions;
        end
        
        function crankStep(this)
            
            grow = cell(this.nS, 1);
            
            % Compute the grow rate for each species
            for i = 1:this.nS
                grow{i} = this.species{i}.grow(this, this.species{i});
            end
            
            % Evolve each species
            for i = 1:this.nS
                
                % Fetch the current species
                s = this.species{i};
                
                % Reshape the density and the grow rate
                u = reshape(s.density, this.nY * this.nX, 1);
                g = reshape(  grow{i}, this.nY * this.nX, 1);
                
                % Compute the density at the next step
                s.density = reshape(s.A \ (s.B * (u + g * this.dt)), this.nY, this.nX);
               
            end
            
            % Increment the time of the simulation
            this.t = this.t + this.dt;
        end
        
        function initializePlot2D(this, background) 
            
            hold off                 
            this.image = imshow(background);
            
            this.background = (im2double(background));
        end
        
        function plot2D(this) 
            
            
            r = zeros(this.nY, this.nX);
            g = zeros(this.nY, this.nX);
            b = zeros(this.nY, this.nX);
            
            weight = 1e-5 * ones(this.nY, this.nX);           
                        
            for i = 1:this.nS
                
                weight = weight + this.species{i}.density / this.species{i}.scale;                
                
                r = r + this.species{i}.density .* this.species{i}.color(1);
                g = g + this.species{i}.density .* this.species{i}.color(2);
                b = b + this.species{i}.density .* this.species{i}.color(3);
                
            end
            
            
            alpha = min(weight, 1);
            
            colors = cat(3, uint8(255 .* (this.background(:,:,1) + alpha .* (r ./weight - this.background(:,:,1)))), ...
                            uint8(255 .* (this.background(:,:,2) + alpha .* (g ./weight - this.background(:,:,2)))), ...
                            uint8(255 .* (this.background(:,:,3) + alpha .* (b ./weight - this.background(:,:,3)))));
            
            set(this.image,'CData', gather(colors)); 
        end
        
        function extinguish(this, treshold)
            
            for i = 1:this.nS
                this.species{i}.extinguish(treshold);
            end
        end
    end
end

