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
        up     = 1;
        down   = 1;
        left   = 1;
        right  = 1;
        factor = 1;
        
        Dx = 1;
        Dy = 1;
        Vx = 0;
        Vy = 0;
        
        density = 0;
        
        grow = @(ecosystem, species) (0 * species.density)
        
        A = 1;
        B = 0;
    end
    
    methods
        function this = Species(ecosystem, index)
            
            this.ecosystem = ecosystem;
            this.index     = index;
            
            nX = ecosystem.nX;
            nY = ecosystem.nY;
            
            this.Dx      = zeros(nY, nX);
            this.Dy      = zeros(nY, nX);
            this.Vx      = zeros(nY, nX);
            this.Vy      = zeros(nY, nX);
            this.factor  = ones (nY, nX);
            this.density = zeros(nY, nX);
        end
        
        function setDensity(this, density)
           
            this.density = density;
            
        end
        
        function setGrowFunction(this, grow)
            
            this.grow = grow;
        
        end
        
        function setVelocity(this, Vy, Vx)
            
            nX = this.ecosystem.nX;
            nY = this.ecosystem.nY;
            
            this.Vx = ones(nY, nX) .* Vx;
            this.Vy = ones(nY, nX) .* Vy;
            
        end
        
        function setDiffusion(this, Dy, Dx)
           
            nX = this.ecosystem.nX;
            nY = this.ecosystem.nY;
            
            this.Dx = ones(nY, nX) .* Dx;
            this.Dy = ones(nY, nX) .* Dy;
            
        end
        
        function generateCoefficients(this)
        
            dt = this.ecosystem.dt;
            dx = this.ecosystem.dx;
            dy = this.ecosystem.dy;
            
            this.up    = (0.5 * this.Dy / dy - 0.25 * this.Vy) * dt / dy;
            this.down  = (0.5 * this.Dy / dy + 0.25 * this.Vy) * dt / dy;
            this.left  = (0.5 * this.Dx / dx - 0.25 * this.Vx) * dt / dx;
            this.right = (0.5 * this.Dx / dx + 0.25 * this.Vx) * dt / dx;
            
        end
        
        function setNoFluxObstacles(this, obstacles)
            
            pass = 1 - obstacles;
           
            this.up    = this.up    .* pass(1:this.nY  , 2:this.nX+1);
            this.down  = this.down  .* pass(3:this.nY+2, 2:this.nX+1);
            this.left  = this.left  .* pass(2:this.nY+1, 1:this.nX  );
            this.right = this.right .* pass(2:this.nY+1, 3:this.nX+2);
            
            this.factor = this.factor .* ceil(pass(2:this.nY+1, 2:this.nX+1));
        end
        
        function setNoFluxBoundariesX(this)
            
            this.left (:,                 1) = 0;
            this.right(:, this.ecosystem.nX) = 0;
            
        end
        
        function setNoFluxBoundariesY(this)
            
            this.up  (                1, :) = 0;
            this.down(this.ecosystem.nY, :) = 0;
            
        end
        
        function setNoFluxBoundaries(this)
            
            this.setNoFluxBoundariesX();
            this.setNoFluxBoundariesY();
            
        end
        
        % The result is the two matrices for the system:
        % A u_{t+1) = B u_t
        function generateSystemMatrices(this)
            
            nx = this.ecosystem.nX;
            ny = this.ecosystem.nY;
            

            u = this.factor .* this.up;
            d = this.factor .* this.down;
            l = this.factor .* this.left;
            r = this.factor .* this.right;
            
            
            %% Compute the tendency to still in the same position
            s = this.factor - u - d - l - r;
            
            % Check that the values are less than a treshold 
            % to ensure numerical stability
            %if min(s) < 0
            %    error("Numerical instability! Reduce the time-step, or increase the size of the cells!");
            %end

            %% Linearize the matrices
            u = reshape(u, nx*ny, 1);
            d = reshape(d, nx*ny, 1);
            l = reshape(l, nx*ny, 1);
            r = reshape(r, nx*ny, 1);
            s = reshape(s, nx*ny, 1);

            %% Detach the link between different columns in the matrix
            for x = 1:(nx-1)       
                d(x*ny + 0) = 0;
                u(x*ny + 1) = 0;
            end

            %% Construction of the A and B matrices
            if nx > 1 && ny > 1

                this.A = spdiags([-r -d 2-s -u -l], [-ny -1 0 +1 +ny], nx*ny, nx*ny);
                this.B = spdiags([ r  d   s  u  l], [-ny -1 0 +1 +ny], nx*ny, nx*ny);

            elseif nx > 1

                this.A = spdiags([-r 2-s -l], [-1 0 +1], nx, nx);
                this.B = spdiags([ r   s  l], [-1 0 +1], nx, nx);

            elseif ny > 1

                this.A = spdiags([-d 2-s -u], [-1 0 +1], ny, ny);
                this.B = spdiags([ d   s  u], [-1 0 +1], ny, ny);

            else

                this.A = spdiags(2-s, 0, 1, 1);
                this.B = spdiags(  s, 0, 1, 1);
            end
           
        end
        
        function C = computeConservationMatrix(this)
            
            % Time-evolution matrix
            U = full(this.A^-1) * this.B;
            
            % Sum the rows in the time-evolution matrix
            C = reshape(sum(U), this.ecosystem.nY, this.ecosystem.nX);
            
        end

    end
end

