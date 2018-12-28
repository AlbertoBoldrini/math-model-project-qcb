
% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(1,1000);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0,0,+3,+3);

% Set the initial time and the time-step
eco.setTime(0, 0.01);

% Create two species in the ecosystem
s1 = eco.createSpecies();

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusion(0.10, 0.100);
s1.setVelocity(0.3, 0.3);


% The initial condition
s1.density = 3.8 * exp(-(eco.X-1).^2 / (0.1)^2);

s1.generateCoefficients();
s1.setNoFluxBoundaries();

% Prepare the matrices for the simulation
eco.generateSystemMatrices();

% Plot the initial condition
plot(eco.X, s1.density);
ylim([0 2]);

% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

for i = 1:10000
    
    % Evolve the system of 1 time-step
    eco.evolve();
    
    % Plot the density at this time step
    plot(eco.X, s1.density);
    ylim([0 2]);
    
    title(sprintf('t=%f sum=%f max=%f',eco.t,sum(s1.density), max(s1.density)))
    
    %if max(s1.density) < 1
    %    break
    %end
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
end

close(video)

