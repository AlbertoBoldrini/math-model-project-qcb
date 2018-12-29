
% The parameters of the paper
D = 1;
H = 0.3;
m = 0.4;
k = 2.0;


% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(1,3000);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, 5000, 1);

% Set the initial time and the time-step
eco.setTime(0, 0.05);

% Create two species in the ecosystem with name and color
s1 = eco.createSpecies("Prey",     [1,0,0]);
s2 = eco.createSpecies("Predator", [0,0,1]);

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusion(D);
s2.setDiffusion(D);

% After the setting of the diffusion coefficent
% The fluxes must be initialized and then patched with
% other methods as addNoFluxBoundaries
s1.initializeFluxes();
s2.initializeFluxes();

% The species can not exit from the simulation area
s1.addNoFluxBoundaries();
s2.addNoFluxBoundaries();


% Grow functions
s1.grow = @(eco, sp) (s1.density .* (1 - s1.density)) - s1.density ./ (H + s1.density) .* s2.density;
s2.grow = @(eco, sp) (k * s1.density ./ (H + s1.density) .* s2.density - m * s2.density);


% The initial condition
s1.density = 1.0 * exp(-(eco.X-2500).^2/(200)^2);
s2.density = 1.0 * exp(-(eco.X-2500).^2/(200)^2);



% Prepare the matrices for the simulation
eco.startSimulation();

% Plot the initial condition
plot(eco.X, s1.density);
hold on 
plot(eco.X, s2.density);
ylim([0 3]);

%legend('Prey', 'Predator')
hold off



% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

for i = 1:1000
    
    % Evolve the system of 1 time-step
    eco.crankStep();
    
    % Plot the density at this time step
    plot(eco.X, s1.density);
    hold on 
    plot(eco.X, s2.density);
    ylim([0 3]);
    
    %legend('Prey', 'Predator')
    hold off
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
end

close(video)
