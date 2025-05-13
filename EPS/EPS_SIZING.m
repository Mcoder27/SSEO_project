%% ELECTRICAL POWER SYSTEM SIZING
clc
clear

%% SOLAR PANELS POWER SIZING
P_e = 1; % Power requested during eclipse
P_s = 1; % Power rquested during sunlight
T_e = 1; % Eclipse time
T_s = 1; % Sunlight time
X_e = 1; % Lines efficiency in eclipse (DET 0.65 MPPT 0.60)
X_s = 1; % Lines efficiency in sunlight (DET 0.85 MPPT 0.80)

P_sa = ((P_e*T_e)/X_e + (P_s*T_s)/X_s) / T_s;

%% SOLAR PANELS SIZING
epsilon = 1; % Solar cell efficiency (0.3)
P0 = 1; % Solar radiation
I_d = 1; % inherent degradation factor (0.5-0.9)
theta = 1; % Sun incidence angle
dpy = 1; % yearly degradation factor (0.03)
years = 1; % Expected mission lifetime in years

A_cell_sa = 1; % Area of one solar cell
V_cell_sa = 1; % Volume of one solar cell
V_sys_sa = 1; % System voltage

P_bol = epsilon * P0 * I_d * cos(theta);
P_eol = (1 - dpy)^years * P_bol;

A_sa = P_sa / P_eol;
N_cell = A_sa / A_cell_sa;

N_series_sa = ceil(V_sys_sa / V_cell_sa);
N_parallel_sa = ceil(N_cell / N_series_sa) + 1;

N_cell_real = N_parallel_sa*N_series_sa + N_series_sa;
A_sa_real = N_cell_real * A_cell_sa;

%% MASS AND VOLUME OF SOLAR PANELS (PROBABILY NON REQUIRED)
P_specific = 1; % Specific power (should be 80-100)

M = P_bol / P_specific;

%% SECONDARY BATTERIES CAPACITY
N_batt = 1; % Number of batteries (2-5)
DoD = 1; % Depth of discharge (30%-50%)
nu_eol = 1; % End of life effciency

E = ((P_e*T_e)/X_e) / (DoD*nu_eol*N_batt);

%% SECOND BATTERY SIZING
A_cell_batt = 1; % Area of one battery cell
V_cell_batt = 1; % Volume of one battery cell
V_sys_batt = 1; % System voltage
mu_batt = 1; % Pack efficiency (0.8-0.9)
C_cell = 1; % Cell electric charge
rho_energy = 1; % Energy density
J_specific = 1; % Specific energy

N_series_batt = ceil(V_sys_batt / V_cell_batt);
E_string = mu_batt * C_cell * (N_series_batt * V_cell_batt);
N_parallel_batt = ceil(E / E_string) + 1;

N_batt_real = N_parallel_batt*N_series_batt + N_series_batt;
E_real = E_string * N_parallel_batt;

V_batt = E_real / rho_energy;
M = E_real / J_specific;