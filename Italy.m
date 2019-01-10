gpuDevice(1);

ratio = 1.0;

Tomo   = gpuArray(          imread('img/Italy_Tomo.png'));
Height = gpuArray(im2double(imread('img/Italy_Height.png')));
Area   = gpuArray(im2double(imread('img/Italy_Area.png')));

% Get the size from the image
[nY, nX] = size(Height);

if ratio < 1
   nY = double(int32(nY * ratio));
   nX = double(int32(nX * ratio));
   
   Tomo   = imresize(Tomo,   [nY nX]);
   Height = imresize(Height, [nY nX]);
   Area   = imresize(Area,   [nY+2 nX+2]);
end


% Space in km
% Time in years
km = 1;
year = 1;
day = 1/365;
hour = day/24;


D1 = 0.9 * km*km/year;
D2 = 0.9 * km*km/year;

s1_grow = 1;

% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(nY,nX);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, nX / nY * 1420*km, 1420*km); 

% Set the initial time and the time-step
eco.setTime(0, 5*day);

% Create two species in the ecosystem with name and color
s1 = eco.createSpecies("Prey",     [1,0,0]);
s2 = eco.createSpecies("Predator", [0,0,1]);

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusion(D1);
s2.setDiffusion(D2);

% After the setting of the diffusion coefficent
% The fluxes must be initialized and then patched with
% other methods like addNoFluxBoundaries
s1.initializeFluxes();
s2.initializeFluxes();

% The species can not exit from the simulation area
s1.addNoFluxBoundaries();
s2.addNoFluxBoundaries();

s1.addNoFluxObstacle(Area);
s2.addNoFluxObstacle(Area);

% The initial condition
s1.density = 1.5 * max((exp(-((eco.X-700).^2 + (eco.Y-700).^2)/(40)^2) - eps), 0);
s2.density = 1.5 * max((exp(-((eco.X-650).^2 + (eco.Y-650).^2)/(40)^2) - eps), 0);

% Grow functions
s1.grow = @(eco, sp) (s1_grow * s1.density .* (1 - s1.density)) - s1.density ./ (H + s1.density) .* s2.density - 3 * s1.density .* Height;
s2.grow = @(eco, sp) (k * s1.density ./ (H + s1.density) .* s2.density - m * s2.density - 3 * s2.density .* Height);


% Prepare the matrices for the simulation
eco.startSimulation();

eco.initializePlot2D(Tomo);
title(sprintf("t = %d", 0));


% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

while eco.t < 400
    
    tic
    for j = 1:2
    
        % Evolve the system of 1 time-step
        eco.multiEulerStep(5);
    end
    
    
    eco.extinguish(1e-5);
    
    title(sprintf("%0.f years", eco.t));

    % Update the image with the new 
    eco.plot2D();

    % Insert a frame
    writeVideo(video, getframe(gcf));
    %pause(0.01);
    toc
end

close(video)

