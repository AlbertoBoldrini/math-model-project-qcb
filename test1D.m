
% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(1,100);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(-1,-1,+1,+1);

% Set the initial time and the time-step
eco.setTime(0, 0.03);

% Create two species in the ecosystem
s1 = eco.createSpecies();
s2 = eco.createSpecies();

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusionParameter(0.01);
s1.setNoFluxBoundaries();
s2.setDiffusionParameter(0.001);
s2.setNoFluxBoundaries();

% Set the grow rate function
s1.setGrowFunction(@(eco, sp) (0.3 * sp.density .* (1 - sp.density)) - 10 * s1.density .* s2.density);
s2.setGrowFunction(@(eco, sp) (-0.3 * sp.density));

% The initial condition
s1.density = 1.5 * exp(-eco.X.^2/(0.3)^2);
s2.density = 1.0 * exp(-(eco.X-0.2).^2/(0.1)^2);


% Prepare the matrices for the simulation
eco.prepareSystemMatrices();


% Plot the initial condition
plot(eco.X, s1.density);
hold on 
plot(eco.X, s2.density);
ylim([0 1.5]);
hold off


% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

for i = 1:1000
    
    % Evolve the system of 1 time-step
    eco.evolve();
    
    % Plot the density at this time step
    plot(eco.X, s1.density);
    hold on 
    plot(eco.X, s2.density);
    ylim([0 1.5]);
    hold off
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
end

close(video)

