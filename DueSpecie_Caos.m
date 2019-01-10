
% The parameters of the paper
D = 1;
H = 0.3;
r = 0.4;
k = 2.0;
epsilon = 2e-5;
delta = -4e-2;
m = r * k;

%Equilibrium values
uEq = (r * H)/(1 - r);
vEq = (1 - uEq)*(H + uEq);


% Get the size from the image
nY = 800;
nX = 800;

% Create a new ecosystem with a grid 1 x nX
eco = Ecosystem(nY,nX);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(-1000, -1000, 1000, 1000);

% Set the initial time and the time-step
eco.setTime(0, 0.2);

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
s1.density = ones(nY,nX) .* uEq;
s2.density = vEq + (5000.*sin(eco.X/400) + 6.*eco.Y)  * epsilon;

%% Start the simulation

% Prepare the matrices for the simulation
eco.startSimulation();

eco.initializePlot2D(zeros(nY,nX,3));
title(sprintf("t=%.1f", eco.t));


% Start a video and insert the frame with the initial condition
video = VideoWriter('Caos2D.avi');
video.Quality = 85;
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));


answer = 'Yes';
while answer == "Yes"

    for i = 1:5000
        tic

        for j = 1:1

            % Evolve the system of 1 time-step
            eco.multiEulerStep(1);
        end

 

        title(sprintf("t=%.1f", eco.t));


        % Update the image with the new 
        eco.plot2D();

        % Insert a frame
        writeVideo(video, getframe(gcf));
        
 
        toc
    end
    
    
    
    answer = questdlg('Continure?', 'Yes', 'No');
end

close(video)