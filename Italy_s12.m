
%% Loading of the images
gpuDevice(1);

Tomo   =           imread('img/Italy_Tomo.png');
Height = im2double(imread('img/Italy_Height.png'));
Area   = im2double(imread('img/Italy_Area.png'));

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

Tomo   = gpuArray(Tomo);
Height = gpuArray(Height);
Area   = gpuArray(Area);

sHeightToKm = 2054 / (226 / 255);

%% Definition of the parameters

% Prey
s1_diff  = 1; 
s1_grow  = 1;
s1_mort  = 3 * Height;

% Predator
s2_diff  = 1;  
s2_rate  = 1;
s2_hsat  = 0.3;
s2_mort  = 0.5;



%% Definition of the system

% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(nY,nX);

height = 1420;
width  = height * nX / nY;

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(0, 0, width, height); 

% Set the initial time and the time-step
eco.setTime(0, 0.02);

% Create two species in the ecosystem with name and color
s1 = eco.createSpecies("S1", [1,0,0]);
s2 = eco.createSpecies("S2", [0,0,1]);

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusion(s1_diff);
s2.setDiffusion(s2_diff)

% After the setting of the diffusion coefficent
% The fluxes must be initialized and then patched with
% other methods like addNoFluxBoundaries
s1.initializeFluxes();
s2.initializeFluxes();

% The species can not exit from the simulation area
s1.addNoFluxObstacle(Area);
s2.addNoFluxObstacle(Area);

% Grow functions
s1.grow = @(eco, sp) s1.density .* (s1_grow  .* (1 - s1.density) - s2_rate ./ (s1.density + s2_hsat) .* s2.density - s1_mort);
s2.grow = @(eco, sp) s2.density .* (s2_rate .* s1.density ./ (s2_hsat + s1.density) - s2_mort);




% The initial condition for s1
if 1
    s1.density = zeros(nY,nX);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-1100).^2 + (eco.Y-1100).^2)/(120)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-900).^2 + (eco.Y-900).^2)/(60)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-900).^2 + (eco.Y-800).^2)/(80)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-750).^2 + (eco.Y-700).^2)/(40)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-600).^2 + (eco.Y-600).^2)/(40)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-600).^2 + (eco.Y-500).^2)/(40)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-500).^2 + (eco.Y-500).^2)/(40)^2) - eps), 0); 
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-400).^2 + (eco.Y-400).^2)/(40)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-300).^2 + (eco.Y-300).^2)/(80)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-100).^2 + (eco.Y-100).^2)/(200)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-1000).^2 + (eco.Y-100).^2)/(170)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-500).^2 + (eco.Y-200).^2)/(80)^2) - eps), 0);
    s1.density = s1.density + 1.5 * max((exp(-((eco.X-960).^2 + (eco.Y-515).^2)/(5)^2) - eps), 0);
    
    
    s1.density = ones(nY,nX);
    eco.extinguish(1e-2);
    

    eco.startSimulation();

    for j = 1:150
        eco.multiEulerStep(1);
    end

    eco.t = 0;
else

    s1.density = 1.5 * max((exp(-((eco.X-700).^2 + (eco.Y-700).^2)/(40)^2) - eps), 0);
end

%s2.density = 1.5 * max((exp(-((eco.X-475).^2 + (eco.Y-475).^2)/(40)^2) - eps), 0);
s2.density = ones(nY,nX) .* 0.005;

%% Start the simulation

% disegna la linea della sezione
Tomo(170,:,:) = 255;

% Prepare the matrices for the simulation
eco.startSimulation();
close all
% Create the figure 1
figItaly = figure(1);
eco.initializePlot2D(Tomo);
axiItaly = gca;
hold on
% Con il tuo titolo
title(axiItaly, sprintf("%.1f years", 0.1 * eco.t));


% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(figItaly));

axi2 = axes(figItaly, 'Position',[0.104 0.066 0.49 0.4]);


axes(axi2);


answer = 'Yes';
while answer == "Yes"

    for i = 1:1000
        tic

        for j = 1:1

            % Evolve the system of 1 time-step
            eco.multiEulerStep(1);
        end

        title(axiItaly, sprintf("%.1f years", 0.1 * eco.t));


        % Update the image with the new 
        eco.plot2D();
        
        if 0
            plot(axi2, eco.X(170,:), s1.density(170,:), 'r');
            hold(axi2, 'on') 
            plot(axi2, eco.X(170,:), s2.density(170,:), 'b');
            hold(axi2, 'off')
            ylim(axi2, [0 1.4]);
            xlabel(axi2, 'Space [km]');
            ylabel(axi2, 'Density');
            set(axi2,'color',[1 1 1 0.7])
            title(axi2, "Densities on a section");
        end
        
        
        s1.boxPlotFeature(sHeightToKm .* Height, s1.density > 0);
        hold on
        s2.boxPlotFeature(sHeightToKm .* Height, s2.density > 0);
        hold off
        
        xlim([0,1000]);
        xlabel(axi2, 'Height [m]');
        ylabel(axi2, 'Density');
        ylim(axi2, [0 1]);
        set(axi2,'color',[0.9 0.9 0.8 0.6])
        %title(axi2, 'Density
        set(get(axi2,'title'),'Position',[600 1.3])

        % Insert a frame
        writeVideo(video, getframe(figItaly));
        toc
    end
    
    answer = questdlg('Continure?', 'Yes', 'No');
end

close(video)

