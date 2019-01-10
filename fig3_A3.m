
% The parameters of the paper
D = 1;
H = 0.5;
r = 0.5;
k = 2.0;
epsilon = 2e-5;
delta = -4e-2;
m = r * k;

%Equilibrium values
uEq = (r * H)/(1 - r);
vEq = (1 - uEq)*(H + uEq);

% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(1,800);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(1800, 0, 2200, 1);

% Set the initial time and the time-step
eco.setTime(0, 0.1);

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
s1.setDensity(uEq)
s2.setDensity(vEq + eco.X * epsilon + delta);

% Prepare the matrices for the simulation
eco.startSimulation();

% Densities array
s1TimeSeries = [];
s2TimeSeries = [];

video = VideoWriter('fig3.avi');
video.Quality = 75;
video.FrameRate = 30;
open(video)

while (eco.t < 2000)
    
    % Evolve the system of 10 time-step 
    for i = 1:10
        eco.crankStep();
        % Save the position at every time step
        s1TimeSeries = [s1TimeSeries,s1.density(300)];
        s2TimeSeries = [s2TimeSeries,s2.density(300)];
    end
    
    % Densities plot
    plot(s1TimeSeries, s2TimeSeries);
    title(sprintf('Chaotic situation t=%.1f',eco.t));
    %ylim([0 1.2]);
    %xlim([0 0.9]);
    writeVideo(video, getframe(gcf));

end

close(video)



