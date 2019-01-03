

% The parameters of the paper
D = 150;
H = 0.3;
m = 0.4;
k = 2.0;
eps = 0.03;

ratio = 1;


Tomo   = imread('img/Italy_Tomo.png');
Height = im2double(imread('img/Italy_Height.png'));
Area   = im2double(imread('img/Italy_Area.png'));

% Get the size from the image
[nY, nX] = size(Height);

if ratio < 1
   nY = double(int32(nY * ratio));
   nX = double(int32(nX * ratio));
   
   Tomo   = imresize(Tomo,   [nY nX]);
   Height = imresize(Height, [nY nX]);
   Area   = imresize(Area,   [nY+2 nX+2]);
end

% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(nY,nX);

kmHeight = 1300;

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, nX / nY * kmHeight, kmHeight); 

% Set the initial time and the time-step
eco.setTime(0, 0.0075);

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

s1.addNoFluxObstacle(Area);
s2.addNoFluxObstacle(Area);

% The initial condition
s1.density = 1.5 * max((exp(-((eco.X-700).^2 + (eco.Y-700).^2)/(40)^2) - eps), 0);
s2.density = 1.5 * max((exp(-((eco.X-600).^2 + (eco.Y-600).^2)/(40)^2) - eps), 0);

% Grow functions
s1.grow = @(eco, sp) (s1.density .* (1 - s1.density)) - s1.density ./ (H + s1.density) .* s2.density - 3 * s1.density .* Height;
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

for i = 1:1000
    

    for j = 1:30
    
        % Evolve the system of 1 time-step
        eco.eulerStep();
    end
    
    eco.extinguish(1e-5);
    
    title(sprintf("t = %d", eco.t));
    
    % Update the image with the new 
    eco.plot2D();
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
    %pause(0.01);
end

close(video)

