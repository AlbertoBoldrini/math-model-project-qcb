classdef Species < handle

    properties
        ecosystem, index;
        
        % The matrices must be imagined like this:
        % 
        %          1  ---> nX
        %     +------------------+
        %  1  |                  |
        %  |  |                  |
        %  |  |                  |
        %  v  |                  |
        %  nY |                  |
        %     |                  |
        %     +------------------+
        %
        % Matrices nY x nX where the value in position (y,x) 
        % describes the tendency of the particles in position (y,x)
        % to move in that direction.
        % The direction must be interpreted in the drawing above.
        up     = 0;
        down   = 0;
        left   = 0;
        right  = 0;
        factor = 1;
        
        name   = "Unnamed";
        color  = [0, 0, 0];
        image  = 0;
        
        Dx = 1;
        Dy = 1;
        Vx = 0;
        Vy = 0;
        
        A = 1;
        B = 0;
        
        density = 0;
        
        grow = @(ecosystem, species) (0 * species.density)
    end
    
    methods
        function this = Species(ecosystem, index, name, color)
            
            this.ecosystem = ecosystem;
            this.index     = index;
            this.name      = name;
            this.color     = color;
            
            nX = ecosystem.nX;
            nY = ecosystem.nY;
            
            this.Dx      = zeros(nY, nX);
            this.Dy      = zeros(nY, nX);
            this.Vx      = zeros(nY, nX);
            this.Vy      = zeros(nY, nX);
            this.density = zeros(nY, nX);
            this.factor  = ones(nY, nX);
        end
        
        function setDensity(this, density)
           
            this.density = density .* ones(this.ecosystem.nY, this.ecosystem.nX);
            
        end
        
        function setVelocity(this, Vx, Vy)
            
            nX = this.ecosystem.nX;
            nY = this.ecosystem.nY;
            
            this.Vx = ones(nY, nX) .* Vx;
            this.Vy = ones(nY, nX) .* Vy;
            
        end
        
        function setDiffusion(this, D)
           
            nX = this.ecosystem.nX;
            nY = this.ecosystem.nY;
            
            this.Dx = ones(nY, nX) .* D;
            this.Dy = ones(nY, nX) .* D;
            
        end
        
        function initializeFluxes(this)
        
            dt = this.ecosystem.dt;
            dx = this.ecosystem.dx;
            dy = this.ecosystem.dy;
            
            this.up    = this.Dy / dy - 0.5 * this.Vy;
            this.down  = this.Dy / dy + 0.5 * this.Vy;
            this.left  = this.Dx / dx - 0.5 * this.Vx;
            this.right = this.Dx / dx + 0.5 * this.Vx;
            
        end
        
        function addNoFluxObstacle(this, pass)
            
            nX = this.ecosystem.nX;
            nY = this.ecosystem.nY;
            
            this.up    = this.up    .* pass(1:nY  , 2:nX+1);
            this.down  = this.down  .* pass(3:nY+2, 2:nX+1);
            this.left  = this.left  .* pass(2:nY+1, 1:nX  );
            this.right = this.right .* pass(2:nY+1, 3:nX+2);
            
            this.factor = this.factor .* ceil(pass(2:nY+1, 2:nX+1));
        end
        
        function addNoFluxBoundariesX(this)
            
            this.left (:,                 1) = 0;
            this.right(:, this.ecosystem.nX) = 0;
            
        end
        
        function addNoFluxBoundariesY(this)
            
            this.up  (                1, :) = 0;
            this.down(this.ecosystem.nY, :) = 0;
            
        end
        
        function addNoFluxBoundaries(this)
            
            this.addNoFluxBoundariesX();
            this.addNoFluxBoundariesY();
            
        end
        
        function startSimulation(this)
            
            nX = this.ecosystem.nX;
            nY = this.ecosystem.nY;
            
            dt = this.ecosystem.dt;
            dx = this.ecosystem.dx;
            dy = this.ecosystem.dy;

            %% Linearize the matrices
            u = reshape((0.5 * dt / dy) * this.factor .* this.up   , nX*nY, 1);
            d = reshape((0.5 * dt / dy) * this.factor .* this.down , nX*nY, 1);
            l = reshape((0.5 * dt / dx) * this.factor .* this.left , nX*nY, 1);
            r = reshape((0.5 * dt / dx) * this.factor .* this.right, nX*nY, 1);
            c = u + d + l + r + 1 * reshape((1 - this.factor), nX*nY, 1);
            
            if max(c) > 1 
                warning("Time step too high! The system may be instable, suggested timestep = %g", dt / max(c));
            end

            %% Detach the link between different columns in the matrix
            for x = 1:(nX-1)       
                d(x*nY + 0) = 0;
                u(x*nY + 1) = 0;
            end

            %% Construction of the A and B matrices
            if nX > 1 && nY > 1

                this.A = spdiags([-r -d 1+c -u -l], [-nY -1 0 +1 +nY], nX*nY, nX*nY);
                this.B = spdiags([ r  d 1-c  u  l], [-nY -1 0 +1 +nY], nX*nY, nX*nY);

            elseif nX > 1

                this.A = spdiags([-r 1+c -l], [-1 0 +1], nX, nX);
                this.B = spdiags([ r 1-c  l], [-1 0 +1], nX, nX);

            elseif nY > 1

                this.A = spdiags([-d 1+c -u], [-1 0 +1], nY, nY);
                this.B = spdiags([ d 1-c  u], [-1 0 +1], nY, nY);

            else

                this.A = spdiags(1+c, 0, 1, 1);
                this.B = spdiags(1-c, 0, 1, 1);
            end
        end

        
        function initializeImage(this)
            
            imageData = cat(3, this.color(1) * ones(size(this.density)), ... 
                               this.color(2) * ones(size(this.density)), ...
                               this.color(3) * ones(size(this.density)));
           
            this.image = imshow(imageData);
            
            set(this.image, 'AlphaData', zeros(size(this.density)))
        end
        
        function updateImage(this)
            
            set(this.image, 'AlphaData', this.density)
        
        end
        
        function extinguish(this, treshold)
            
            this.density = max(0, this.density - treshold);
            
        end
    end
end

