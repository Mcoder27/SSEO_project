%% ELECTRICAL POWER SYSTEM SIZING
clc
clear

%% SOLAR PANELS POWER SIZING
P_e = 1186 * 1.2; % Power requested during eclipse (value found)
P_s = 1168.7 * 1.2; % Power rquested during sunlight (value found)
T_e = 20 * 60; % Eclipse time (know I will find it)
T_s = (92.5-20) * 60; % Sunlight time (know I will find it)
X_e = 0.6; % Lines efficiency in eclipse (DET 0.65 MPPT 0.60)
X_s = 0.8; % Lines efficiency in sunlight (DET 0.85 MPPT 0.80)

P_sa = ((P_e*T_e)/X_e + (P_s*T_s)/X_s) / T_s;

%% SOLAR PANELS SIZING
epsilon = 0.27; % Solar cell efficiency (0.3)
P0 = 1367.5; % Solar radiation (value given)
I_d = 0.8; % inherent degradation factor (0.5-0.9)
theta = acos(0.88); % Sun incidence angle (know I will find it), (orientation factor 0.88)
dpy = 0.03; % yearly degradation factor (0.03)
years = 3.5; % Expected mission lifetime in years (value found)

A_cell_sa = 30.18*10^-4; % Area of one solar cell (Probabily assumed)
V_cell_sa = 2.67; % Voltage of one solar cell (probabily assumed)
V_sys_sa = 52.5; % System voltage (ASK)

P_bol = epsilon * P0 * I_d * cos(theta); % 253 W/m^2
P_eol = (1 - dpy)^years * P_bol; % should be 2238 W or 156.4 W/m^2

A_sa = P_sa / P_eol;
N_cell = A_sa / A_cell_sa;

N_series_sa = ceil(V_sys_sa / V_cell_sa);
N_parallel_sa = ceil(N_cell / N_series_sa) + 6;

N_cell_real = N_parallel_sa*N_series_sa + N_series_sa;
A_sa_real = N_cell_real * A_cell_sa;

%% MASS AND VOLUME OF SOLAR PANELS (PROBABILY NON REQUIRED)
P_specific = 80; % Specific power (should be 80-100)

M = P_bol / P_specific;

%% SECONDARY BATTERIES CAPACITY
N_batt = 1; % Number of batteries (2-5)
DoD = 0.3; % Depth of discharge (30%-50%) (30 for high number of cycles)
nu_eol = 0.8; % End of life efficiency (Probabily to assume)

E = ((P_e*(T_e/3600))/X_e) / (DoD*nu_eol*N_batt);

%% SECOND BATTERY SIZING
V_cell_batt = 2.6; % Voltage of one battery cell
V_sys_batt = 52.5; % System voltage
mu_batt = 0.8; % Pack efficiency (0.8-0.9)
C_cell = 1.5; % Cell electric charge
rho_energy = 250; % Energy density
J_specific = 150; % Specific energy

N_series_batt = ceil(V_sys_batt / V_cell_batt);
E_string = mu_batt * C_cell * (N_series_batt * V_cell_batt);
N_parallel_batt = ceil(E / E_string) + 1;

N_batt_real = N_parallel_batt*N_series_batt + N_series_batt;
E_real = E_string * N_parallel_batt;

V_batt = E_real / rho_energy;
M = E_real / J_specific;