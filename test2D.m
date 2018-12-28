
% Create a new ecosystem with a grid nY x nX
eco = Ecosystem(150,150);

% Set the left-top and the right-bottom coordinate of the rectangle
% of the simulation.
eco.setSpace(-3,-3,+3,+3);

% Set the initial time and the time-step
eco.setTime(0, 0.03);

% Create one species in the ecosystem
s1 = eco.createSpecies();

% Set the diffusion parameter and the boundaries for this species
s1.setDiffusion(0.1, 0.1);

% Set the grow rate function
%s1.setGrowFunction(@(eco, sp) (0.3 * sp.density .* (1 - sp.density)));

% The initial condition
s1.density = exp(-(eco.X.^2 + eco.Y.^2));

s1.generateCoefficients();
s1.setNoFluxBoundaries();

% Prepare the matrices for the simulation
eco.generateSystemMatrices();

green = cat(3, zeros(size(s1.density)), ones(size(s1.density)), zeros(size(s1.density)));




% Plot the initial condition
%image([eco.X(1,1) eco.X(1,eco.nX)], [eco.Y(1,1) eco.Y(eco.nY,1)], s1.density * 255);
%colormap(gray)

h = imshow(green);
set(h, 'AlphaData', s1.density)

%zlim([0 1.5]);
%caxis([0 1]);
%shading flat

% Start a video and insert the frame with the initial condition
video = VideoWriter('out.avi');
video.FrameRate = 30;
open(video)
writeVideo(video, getframe(gcf));

for i = 1:1000
    
    % Evolve the system of 1 time-step
    eco.evolve();
    
    % Plot the density at this time step
    %image([eco.X(1,1) eco.X(1,eco.nX)], [eco.Y(1,1) eco.Y(eco.nY,1)], s1.density * 255);
    
    set(h, 'AlphaData', s1.density)
    %zlim([0 1.5]);
    %caxis([0 1]);
    %shading flat
    
    % Insert a frame
    writeVideo(video, getframe(gcf));
end

