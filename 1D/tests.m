
%% Condizioni della simulazione

% Intervallo nel tempo
ti = 0;
tf = 5;

% Intervallo di simulazione
xl = 0;
xr = 2;

% Punti nello spazio
nx = 70;

% Punti nel tempo
nt = 30000;

%% Condizioni iniziali

% Matrice nx
ui = zeros(nx, 2);

% Aggiunge qualche delta qui e là
ui(int32(nx/2) + 1, 1) = 1;
ui(int32(nx/4) + 1, 1) = 3;

ui(int32(3*nx/4) + 1, 2) = 3;

%% Parametri della simulazione
params = DiffusionParams1D;

% Diffusione uguale ovunque e per tutti
params.diffusion = ones(nx, 2);

% Uno zero nella matrice dominio significa che la specie 
% può passare tranquillamente
params.domain = zeros(size(ui));


% Aggiunge dei muri all'inizio e alla fine per la specie 1
params.domain(1,1) = 1;
params.domain(nx+1,1) = 1;

% Aggiunge dei muri all'inizio e alla fine per la specie 2
params.domain(1,2) = 1;
params.domain(nx+1,2) = 1;

% Aggiunge un muro in una posizione in mezzo per la specie 1
params.domain(int32(nx/3),1) = 1; 

% Funzione di crescita
params.f = @(t,x,u) (1*u);


%% Opzioni della simulazione
options = DiffusionOptions1D;

% Argomenti per il plot delle due specie
options.plot_args = {{'Color', 'blue', 'LineWidth', 2},{'Color', 'red', 'LineWidth', 2}}; 

%% Esegue la simulazione
simulateDiffusion1D(ti, tf, nt, xl, xr, ui, params, options);

