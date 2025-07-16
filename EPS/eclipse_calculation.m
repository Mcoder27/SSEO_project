clear
clc

addpath("time\")

% COMPUTATION OF ECLIPSE DURATION (Source: Leveque)

% Initial date
startDate = [2019 05 15 0 0 0] ;
stopDate  = [2019 07 15 0 0 0] ;

% Time conversion
startTime = date2mjd2000(startDate) ; % [day]
stopTime  = date2mjd2000(stopDate)  ; % [day]

% Import ephemerides
[r_sc , tspan] = importEphemeridesData("eclipse.txt");

% Define axial tilt and matrix rotation
eps_E = deg2rad(astroConstants(63)) ; % [rad]
DCM = [1 0 0; 0 cos(eps_E) sin(eps_E); 0 -sin(eps_E) cos(eps_E)] ;

% Earth radius
R_E   = astroConstants(23) ;

% Sun radius
R_sun = astroConstants(3) ;

% light/dark array (l=1, d=0, p=0.5)
light_dark = zeros(1, length(tspan)) ;

l_v = [] ;
l1_v = [] ;
l2_v = [] ;
for it = 1 : length(tspan)

    % --Define time--
    time = startTime + tspan(it)/(60*60*24) ; % [day]

    % --Recollect s/c position--
    r_sc_it_v = r_sc(it, 1:3) ; % [km]
    r_sc_it = norm(r_sc_it_v, 2);

    % --Recollect Sun position--
    [kep_sun_it, mu_sun] = uplanet(time, 3) ; 
    stateSun = kep2car( kep_sun_it, mu_sun) ; % [km]
    % Rotate in ECI from HECI
    r_sun_it_v = DCM * stateSun(1:3) ; % [km]
    r_sun_it = norm(r_sun_it_v, 2);

    % --Eclipse computation--
    % Distance between fundamental plane and Earth centre [km]
    s0 = dot(-r_sc_it_v, r_sun_it_v) / norm(r_sun_it_v, 2);

    if s0 < 0
        % Satellite in light
        light_dark(it) = 1 ;
    else
        % Distance between satellite and Sun-Earth axis
        l = sqrt( r_sc_it^2 - s0^2 ) ;

        % Parameters relative to the umbra
        sin_f2 = (R_sun - R_E) / r_sun_it ;
        c2     = R_E / sin_f2 - s0 ;
        l2     = c2 * tan( asin(sin_f2) ); 

        % Parameters relative to the penumbra
        sin_f1 = (R_sun + R_E) / r_sun_it ;
        c1     = s0 + R_E / sin_f1 ;
        l1     = c1 * tan( asin(sin_f1) ) ;

        l_v = [l_v l];
        l1_v = [l1_v l1];
        l2_v = [l2_v l2];

        if l > l1
            % Satellite in light
            light_dark(it) = 1 ;
        elseif l > l2
            % Satellite in penumbra
            light_dark(it) = 0.5 ;
        else
            % Satellite in dark
            light_dark(it) = 0 ;
        end 
    end

end

%%
figure()
plot(l_v(1:90), 'r')
hold on
plot(l1_v(1:90), 'g')
plot(l2_v(1:90), 'b')
%%
figure()
plot(tspan, light_dark)