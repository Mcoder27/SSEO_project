clear
clc

% ----- GENERAL DATA -----
mu_E = astroConstants(13); %[km^3/s^2] Planetary constants of the Earth
H = 320;                   %[km]  Altitude
R = astroConstants(23);    %[Km]  Mean Radius of Earth
inc = 96.97;               %[deg] Inclination
Omega = 214.9023;          %[deg] RAAN (data a caso)
eps_deg = 5;               %[deg] Μinimum elevation of s/c wrt ground station
eps_rad = deg2rad(5);      %[rad] Μinimum elevation of s/c wrt ground station

%--------- Instantaneous Orbit Pole --------------
% Ground Station
lat_gs = 67 + 51/60 + 25.92/3600;  % [deg] latitude of Kiruna groud station
lat_gs = deg2rad(lat_gs);          % [rad]
long_gs = 20 + 57/60 + 51.84/3600; % [deg] longitude of Kiruna groud station
long_gs = deg2rad(long_gs);        % [rad]

% Spacecraft
lat_pole = 90 - inc;              %[deg]
lat_pole_rad = deg2rad(lat_pole); %[rad]

% form here: worst-case scenario
L_node = long_gs - asin(tan(lat_gs)/tan(deg2rad(inc))); %[rad] longitude of the ascending node
long_pole_rad = L_node - pi*0.5; % [rad] 

%--------- Evaluation of the Arc Contact ---------

rho_rad = asin(R/(R+H));    %[rad]
rho_deg = rad2deg(rho_rad); %[deg]

% Orbit Period
T_sec = 2*pi*sqrt((R+H)^3/mu_E); %[s]

T_min = T_sec/60;

% Max Nadir angle
eta_max_rad = asin(sin(rho_rad)*cos(eps_rad));
eta_max_deg = deg2rad(eta_max_rad);

% Max Earth Central Angle
lam_max_rad = pi*0.5 - eps_rad -eta_max_rad;
lam_max_deg = deg2rad(lam_max_rad);

% Max Distance
D_max = R*(sin(lam_max_rad)/sin(eta_max_rad));

% Min Earth Central Angle 
lam_min_rad = asin(sin(lat_pole_rad)*sin(lat_gs) + cos(lat_pole_rad)*cos(lat_gs)*cos(long_pole_rad-long_gs));
lam_min_deg = rad2deg(lam_min_rad);

% Min Nadir Angle
eta_min_rad = atan((sin(rho_rad)*sin(lam_min_rad))/(1- sin(rho_rad)*cos(lam_min_rad)));

% Max Elevation
eps_max_rad = 0.5*pi -lam_min_rad - eta_min_rad;

% Min Distance 
D_min =R*(sin(lam_min_rad)/sin(eta_min_rad));

% Time in View
t_sec = T_sec/pi *acos(cos(lam_max_rad)/cos(lam_min_rad));
t_min = t_sec/60;
