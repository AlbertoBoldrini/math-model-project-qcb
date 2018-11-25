
% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(25,25);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(-1,-1,+1,+1);

% Set the initial time and the time-step
eco.setTime(0, 0.03);

% Create one species in the ecosystem
s1 = eco.createSpecies();

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusionParameter(0.1);
s1.setNoFluxBoundaries();

% Set the grow rate function
s1.setGrowFunction(@(eco, sp) (0.3 * sp.density .* (1 - sp.density)));

% The initial condition
s1.density = exp(-(eco.X.^2 + eco.Y.^2));

% Prepare the matrices for the simulation
eco.prepareSystemMatrices();


% Plot the initial condition
surf(eco.X, eco.Y, s1.density);
zlim([0 1.5]);
caxis([0 1]);
shading flat

% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

for i = 1:160
    
    % Evolve the system of 1 time-step
    eco.evolve();
    
    % Plot the density at this time step
    surf(eco.X, eco.Y, s1.density);
    zlim([0 1.5]);
    caxis([0 1]);
    shading flat
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
end

