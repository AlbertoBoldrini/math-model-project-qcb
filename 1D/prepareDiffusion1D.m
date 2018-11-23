function [A,B] = prepareDiffusion1D(alpha, nx, domain)
    
    % Se alpha è maggiore di una certa soglia 
    % la soluzione può oscillare in modo brutto
    if max(alpha) >= 0.36
        error("Matrix diffusion can generate oscillations! Increase the points in time!")
    end

    % Se alpha è maggiore di una certa soglia 
    % una condizione iniziale positiva può diventare negativa!
    if max(alpha) >= 0.75
        error("Matrix diffusion can generate negative solutions! Increase the points in time!")
    end
        

    %% The differential equation is: 
    % u_t = D * u_xx + f(u,v)
    
    % (u_{x,t+1} - u_{x,t}) / dt = D/(2*dx^2) * [(u_{x+1,t+1} - 2*u_{x,t+1} + u_{x-1,t+1}) 
    %                                           +(u_{x+1,t}   - 2*u_{x,t}   + u_{x-1,t})]
    %                              + f(u_{x,t},v_{x,t})
    
    % (why not put f in the crank-nicholson scheme?)
     
    %
    % let a := D*dt/(2*dx^2)
    %
    % (u_{x,t+1} - u_{x,t}) = a * [(u_{x+1,t+1} - 2*u_{x,t+1} + u_{x-1,t+1}) 
    %                             +(u_{x+1,t}   - 2*u_{x,t}   + u_{x-1,t})] 
    
    %                         + dt * f(u_{x,t},v_{x,t})
    %
    % (1+2a)*u_{x,t+1} -a(u_{x+1,t+1} + u_{x-1,t+1}) = a * (u_{x+1,t} + u_{x-1,t}) + (1-2*a)*u_{x,t} 
    %                                                       
    %                                                  + dt * f(u_{x,t},v_{x,t})
    
    
    % I write the system in matrix form:
    % A_u * u_{t+1} = B_u * u_t + f{u_t, v_t}
    % A_v * u_{t+1} = B_v * u_t + f{u_t, v_t}

    %% Construction of the diagonals

    % Diagonals of the matrix A
    A_diags = [(-alpha).*ones(nx, 1)  (1 + 2*alpha).*ones(nx, 1)   (-alpha).*ones(nx, 1)];
    
    % Apply the boundary conditions to the matrix A
    for i = 1:length(domain)
        
        % If the u_domain has value 0 means that the flux at that point
        % must be zero, so it changes some values in the matrices
        if domain(i) == 1
            
            if i >= 1 && i <= nx
                A_diags(i,2) = 1 + alpha(i);
                A_diags(i,3) = 0;
            end
            
            if i-1 >= 1 && i-1 <= nx
                A_diags(i-1,2) = 1 + alpha(i-1);
                A_diags(i-1,1) = 0;
            end
        end
    end
    
    % Compute the B diagonals changing the sign...
    B_diags = -A_diags;
    
    % and adding 2 to the main diagonal
    B_diags(:,2) = B_diags(:,2) + 2;
    
    
    %% Construction of the A and B matrices
    A = spdiags(A_diags, [-1 0 +1], nx, nx);
    B = spdiags(B_diags, [-1 0 +1], nx, nx);
end

