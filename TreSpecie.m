gpuDevice(1);

Tomo   = gpuArray(          imread('img2/Italy_Tomo.png'));
Height = gpuArray(im2double(imread('img2/Italy_Height.png')));
Area   = gpuArray(im2double(imread('img2/Italy_Area.png')));

% Get the size from the image
[nY, nX] = size(Height);

if ratio < 1
   nY = double(int32(nY * ratio));
   nX = double(int32(nX * ratio));
   
   Tomo   = imresize(Tomo,   [nY nX]);
   Height = imresize(Height, [nY nX]);
   Area   = imresize(Area,   [nY+2 nX+2]);
end

% Species 1
s1_diff  = 100; 
s1_grow  = 1 - 2 * Height;
s1_carry = 1 * s1_grow;

% Species 2
s2_diff  = 150;
s2_mort  = 0.5 + 1 * Height;

% Species 3
s3_diff  = 150;
s3_mort  = 0.5 + 1 * Height;

% Interaction 1-2
s12_rate = 1;
s12_hsat = 1;
s12_grow = 2;

% Interaction 2-3
s23_rate = 1;
s23_hsat = 1;
s23_grow = 2;



% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(nY,nX);

kmHeight = 1300;

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, nX / nY * kmHeight, kmHeight); 

% Set the initial time and the time-step
eco.setTime(0, 0.0075);

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
s1.grow = @(eco, sp) s1.density .* (s1_grow  .* (1 - s1.density ./ s1_carry) - s12_rate ./ (s1.density + s12_hsat) .* s2.density);
s2.grow = @(eco, sp) s2.density .* (s12_rate .* s12_grow .* s1.density ./ (H + s1.density) - s2_mort - s23_rate ./ (s2.density + s23_hsat) .* s3.density);
s3.grow = @(eco, sp) s3.density .* (s23_rate .* s23_grow .* s2.density ./ (H + s2.density) - s3_mort);

% Prepare the matrices for the simulation
eco.startSimulation();

eco.initializePlot2D(Tomo);
title(sprintf("t = %d", 0));


% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

while eco.t < 3
    

    for j = 1:1
    
        % Evolve the system of 1 time-step
        eco.multiEulerStep(5);
    end
    
    eco.extinguish(1e-5);
    
    title(sprintf("t = %g", eco.t));
    
    % Update the image with the new 
    eco.plot2D();
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
    %pause(0.01);
end

close(video)

