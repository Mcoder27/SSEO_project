function s = kep2car( kep_i, mu, visualize)
% kep2car.m - Converts Keplerian elements into corresponding Cartesian
%             coordinates (ECI Reference frame)
%
% PROTOTYPE:
%   s = kep2car( kep_i, mu, visualize)
%
% DESCRIPTION:
%   Returns the state vector (position and velocity) corresponding
%   to a specific set of Keplerian parameters.
%
% INPUT:
%   kep_i      [1x6]     Keplerian elements vector [Km,~,rad,rad,rad,rad]
%   mu         [1x1]     Planetary constant [km^3/s^2]
%   visualize  [string]  Control results' display [string]
%
% OUTPUT:
%   s          [6x1]     State vector [km || km/s]
%
% EXAMPLE:
%
% CALLED FUNCTIONS:
%   none
%
% REFERENCES:
%
% CONTRIBUTORS:
%   Daniele Macchi
%
% CHANGELOG:
%   2024-10-30: First version
%
% ----------------------------------------------------------------------

% Control parameter
if nargin == 2
    visualize = "No" ; 
end

% Initialization of the keplerian parameters
[a, e, i, OM, om, th] = deal( kep_i(1), kep_i(2), kep_i(3), kep_i(4), kep_i(5), kep_i(6) );

% 1) Compute semi-latus rectum p and distance r
p = a *( 1-e^2 );
r = p / ( 1+e*cos(th) );

% 2) Position and velocity in Perifocal Reference Frame (e, p, h)
r_pf = r * [cos(th) sin(th) 0]';
v_pf = sqrt(mu/p) * [-sin(th) e+cos(th) 0]';

% 3) Matrix rotation
R3_OM= [cos(OM) sin(OM) 0; -sin(OM) cos(OM) 0; 0 0 1];
R1_i= [1 0 0; 0 cos(i) sin(i); 0 -sin(i) cos(i)];
R3_om= [cos(om) sin(om) 0; -sin(om) cos(om) 0; 0 0 1];

T_pf2eci= (R3_om*R1_i*R3_OM)';

% 4) Position and velocity in ECI Reference Frame
r = T_pf2eci * r_pf;
v = T_pf2eci * v_pf;

% Output
s = [r ; v] ;

% Summary display
if strcmp (visualize, "yes")
    % Summary
    fprintf("---DATAS INSERTED---");
    fprintf("\na  : %.2f Km", a);
    fprintf("\ne  : %.4f", e);
    fprintf("\ni  : %.2f°", rad2deg(i));
    fprintf("\nOM : %.2f°", rad2deg(OM));
    fprintf("\nom : %.2f°", rad2deg(om));
    fprintf("\nth : %.2f°\n", rad2deg(th));

    fprintf("\n---RESULTS---\n");
    fprintf("r: [%.2f %.2f %.2f] Km \n", r);
    fprintf("v: [%.4f %.4f %.4f] Km/s\n\n", v);
end

return

