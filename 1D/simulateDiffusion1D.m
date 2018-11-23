
function simulateDiffusion1D(ti, tf, nt, xl, xr, ui, params, options)

    % Fetch the number of points in space from the initial conditions
    nx = size(ui,1);
    
    % Fetch the number of species
    ns = size(ui,2);

    % Compute the time-step from the number of points in time.
    % Initial and final time are included in n_t.
    dt = (tf - ti) / (nt - 1);
    
    % Compute the space betweeen two points in the mesh
    dx = (xr - xl) / (nx - 1);
    
    %% Check the parameters
    
    if ~isequal(size(params.diffusion), size(ui))
        error("The parameter diffusion must have the same dimension of u")
    end 
   

    %% Costruction the A and B matrices for each specie
    % I write the system in matrix form:
    % A * u_{t+1} = B * u_t + f{u_t}
    
    A = cell(ns, 1);
    B = cell(ns, 1);
    
    for i = 1:ns
       [A{i}, B{i}] = prepareDiffusion1D(params.diffusion(:,i) * dt / (dx*dx), nx, params.domain(:,i));
    end
    
    
    
    
    
    %% Initialize the vectors
    
    % Create the space vector
    x = xl:dx:xr;
    
    % Initialize the two variables with their initial values
    u = ui;
    
    %% Prepare the plot and the video
    
    if options.plot_flag
        figure(1)

        for i = 1:ns 
            plot(x, ui(:,i), options.plot_args{i}{:});
            hold on
        end

        xlabel('Position');
        ylabel('Population Density'); 

        hold off

        if options.video_flag
            
            video = VideoWriter('out.avi');
            video.FrameRate = 30;

            open(video)

            for i = 1:options.initial_condition_frames
                writeVideo(video, getframe(gcf));
            end
        end
    end
    
    %% Start the simulation
    for t=ti:dt:tf 
        
        h = params.f(t,x,u) * dt;     
        

        for i = 1:ns 
            u(:,i) = A{i} \ (B{i} * u(:,i) + h(:,i));
        end
        
        if options.plot_flag
            for i = 1:ns 
                plot(x, u(:,i), options.plot_args{i}{:});
                hold on
            end

            xlabel('Position');
            ylabel('Population Density'); 

            hold off
            
            if options.video_flag
                writeVideo(video, getframe(gcf));
            end
        end
        
 
        
        
        if options.plot_pause > 0
            pause(options.plot_pause)
        end
    end

    close(video)

    
    
    