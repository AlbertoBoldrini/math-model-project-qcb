
%% Loading of the images
gpuDevice(1);

Tomo   = gpuArray(          imread('img/Italy_Tomo.png'));
Height = gpuArray(im2double(imread('img/Italy_Height.png')));
Area   = gpuArray(im2double(imread('img/Italy_Area.png')));

ratio = 1.0;

% Get the size from the image
[nY, nX] = size(Height);

if ratio < 1
   nY = double(int32(nY * ratio));
   nX = double(int32(nX * ratio));
   
   Tomo   = imresize(Tomo,   [nY nX]);
   Height = imresize(Height, [nY nX]);
   Area   = imresize(Area,   [nY+2 nX+2]);
end



%% Definition of the parameters

% Prey
s1_diff  = 10; 
s1_grow  = 20;
s1_mort  = 60 * Height;

% Predator 1
s2_diff  = 80; 
s2_rate  = 10;
s2_hsat  = 0.3;
s2_mort  = 2;

% Predator 2
s3_diff  = 10; 
s3_rate  = 20;
s3_hsat  = 0.3;
s3_mort  = 2;


%% Definition of the system

% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(nY,nX);

height = 1420;
width  = height * nX / nY;

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, width, height); 

% Set the initial time and the time-step
eco.setTime(0, 0.01);

% Create two species in the ecosystem with name and color
s1 = eco.createSpecies("S1", [1,0,0]);
s2 = eco.createSpecies("S2", [0,0,1]);
s3 = eco.createSpecies("S3", [1,1,0]);

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusion(s1_diff);
s2.setDiffusion(s2_diff);
s3.setDiffusion(s3_diff);

% After the setting of the diffusion coefficent
% The fluxes must be initialized and then patched with
% other methods like addNoFluxBoundaries
s1.initializeFluxes();
s2.initializeFluxes();
s3.initializeFluxes();

% The species can not exit from the simulation area
s1.addNoFluxObstacle(Area);
s2.addNoFluxObstacle(Area);
s3.addNoFluxObstacle(Area);

% The initial condition
s1.density = 1.5 * max((exp(-((eco.X-700).^2 + (eco.Y-700).^2)/(40)^2) - eps), 0);
s2.density = 1.5 * max((exp(-((eco.X-675).^2 + (eco.Y-675).^2)/(40)^2) - eps), 0);
s3.density = 1.5 * max((exp(-((eco.X-650).^2 + (eco.Y-650).^2)/(40)^2) - eps), 0);

% Grow functions
s1.grow = @(eco, sp) s1.density .* (s1_grow  .* (1 - s1.density) - s2_rate ./ (s1.density + s2_hsat) .* s2.density  - s3_rate ./ (s1.density + s3_hsat) .* s3.density - s1_mort);
s2.grow = @(eco, sp) s2.density .* (s2_rate .* s1.density ./ (s2_hsat + s1.density) - s2_mort);
s3.grow = @(eco, sp) s3.density .* (s3_rate .* s1.density ./ (s3_hsat + s1.density) - s3_mort);


eco.extinguish(1e-5);

%% Start the simulation

% Prepare the matrices for the simulation
eco.startSimulation();

eco.initializePlot2D(Tomo);
title(sprintf("%.0f years", eco.t));


% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

answer = 'Yes';
while answer == "Yes"

    for i = 1:500
        tic

        for j = 1:5

            % Evolve the system of 1 time-step
            eco.multiEulerStep(1);
        end

        title(sprintf("%.0f years s1=%.0f s3/s2=%.3f", eco.t, sum(sum(s1.density)), s3_rate / s2_rate * sum(sum(s3.density)) / sum(sum(s2.density))));

        % Update the image with the new 
        eco.plot2D();

        % Insert a frame
        writeVideo(video, getframe(gcf));
        toc
    end
    
    answer = questdlg('Continure?', 'Yes', 'No');
end

close(video)

