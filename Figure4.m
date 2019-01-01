
% The parameters of the paper
D = 1;
H = 0.3;
r = 0.4;
k = 2.0;
epsilon = 1.5e-5;
epsilon1 = 0.07;
delta = -3.6e-2;
m = r * k;
L = 4800;

%Equilibrium values
uEq = (r * H)/(1 - r);
vEq = (1 - uEq)*(H + uEq);


% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(1,10000);

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
% other methods like addNoFluxBoundaries
s1.initializeFluxes();
s2.initializeFluxes();

% The species can not exit from the simulation area
s1.addNoFluxBoundaries();
s2.addNoFluxBoundaries();


% Grow functions
s1.grow = @(eco, sp) (s1.density .* (1 - s1.density)) - s1.density ./ (H + s1.density) .* s2.density;
s2.grow = @(eco, sp) (k * s1.density ./ (H + s1.density) .* s2.density - m * s2.density);


% The initial condition
%s1.density = 1.0 * exp(-(eco.X-2500).^2/(200)^2);
%s2.density = 1.0 * exp(-(eco.X-2500).^2/(200)^2) + eco.X*epsilon + delta;
s1.setDensity(uEq);
s2.setDensity(vEq + eco.X * epsilon + delta + epsilon1 * cos(2*pi*eco.X / L));

% Prepare the matrices for the simulation
eco.startSimulation();

% Plot the initial condition
plot(eco.X, s1.density);
hold on 
plot(eco.X, s2.density);
ylim([0 1.2]);

legend('Prey', 'Predator')
hold off



% Start a video and insert the frame with the initial condition
video = VideoWriter('Figure4','MPEG-4');
video.Quality = 75;
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

while (eco.t < 800)
    
    % Evolve the system of 2 time-steps
    for i=1:100
        eco.crankStep();
    end
    
    % Plot the density at this time step
    plot(eco.X, s1.density);
    hold on 
    
    plot(eco.X, s2.density);
    ylim([0 1.2]);
    
    title(sprintf('Non monotonic initial conditions t=%.1f',eco.t));
    
    legend('Prey', 'Predator')
    hold off
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
end

close(video)
