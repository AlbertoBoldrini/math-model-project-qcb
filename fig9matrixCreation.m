
% The parameters of the paper
D = 1;
H = 0.3;
r = 0.4;
k = 2.0;
A = 0.02;
S = 100;
x0 = 1500;
m = r * k;

%Equilibrium values
uEq = (r * H)/(1 - r);
vEq = (1 - uEq)*(H + uEq);


% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(1,5000);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, 5000, 1);

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
s1.setDensity(uEq);
densityS2 = vEq;
perturbativeDensityS2 = zeros(eco.nY, eco.nX);
perturbativeDensityS2(x0+1:x0+S) = A*sin(2*pi*(eco.X(x0+1:x0+S)-x0)/S);
s2.setDensity(densityS2 + perturbativeDensityS2);

% Prepare the matrices for the simulation
eco.startSimulation();

t1 = 6000;
t2 = 12000;


while eco.t < t1
    eco.crankStep();
end

s1TSeries = zeros(t2 - t1, eco.nX);
    
for t=1:(t2-t1)
    

    for j=1:10
        eco.crankStep();
    end
    s1TSeries(t,:) = s1.density;

    eco.t
end

