clear
clc

% ----- GENERAL DATA -----
c = astroConstants(5) * 1e3 ; % Speed of light in the vacuum (m/s)
k = 1.38e-23 ; % Boltzmann constant 

% ----- TELECOMMAND ------------------------------------------------------

% Frequency (Hz)
f_TC = 2030e6 ; 

% Wavelength (m)
lambda_TC = c / f_TC ;  

% GS ANTENNA DATA (KIRUNA) - TRANSMITTER
D_GS_S     = 13   ; % Diameter (m) 
eta_GS_S   = 0.55 ; % Efficiency (-)
e_GS_S     = 0.01 ; % Pointing accuracy (deg) 

% Beamwidth (deg)
theta_GS_S = 70 * lambda_TC / D_GS_S ; % Literature says around 0.76

KIRUNA = struct("D", D_GS_S, "eta", eta_GS_S, "e", e_GS_S, "theta", theta_GS_S) ;

% Antenna gain (dB)
KIRUNA.G_TX = 10 * log10( KIRUNA.eta * pi^2 * KIRUNA.D^2 / (lambda_TC)^2 ) ;  

% SC ANTENNA DATA (S-BAND) - RECEIVER
D_SC_S     = 10e-2 ; % Diameter (m) 
eta_SC_S   = 0.70  ; % Efficiency (-)
e_SC_S     = 20    ; % Pointing accuracy (deg) 

% Beamwidth (deg)
theta_SC_S =  70 * lambda_TC / D_SC_S ;

SC_S = struct("D", D_SC_S, "eta", eta_SC_S, "e", e_SC_S, "theta", theta_SC_S) ; 

% Antenna gain (dB)
SC_S.G_TX = 10 * log10( SC_S.eta * pi^2 * SC_S.D^2 / (lambda_TC)^2 ) ; 

% -----LOSSES-----

% Atmospheric losses (dB)
L_atm_graph = 3.8e-2 ;

% Elevation correction
phi = deg2rad(5) ;
L_atm = - 10 * log10( 10^(L_atm_graph/10) / sin(phi)) ;

% Cable losses (dB)
L_cable = -3 ;

% Free space losses
distance = 320e3 / sin(phi) ; % RX to TX antenna in the worst-case condition (at the moment I put it as the altitude but should be done maybe more precisely)
L_space_TC = - 20 * log10(4 * pi * distance / lambda_TC) ; 

% Pointing losses
L_point = - 12 * (e_SC_S / SC_S.theta)^2 ;

% ----- LINK BUDGET -----
% Effective data rate (bps)
Rnet_TC = 2e3 ;

% Modulation and encoding coefficients (-)
alphaEnc_TC = 2 ;
alphaMod_TC = 2 ;

% Gross data rate (bps)
RGross_TC   = Rnet_TC * alphaEnc_TC / alphaMod_TC ;

% Bit Error Rate (from literature)
BER_TC = 1e-7 ;  

% Minimum energy bit to noise spectral density ratio (dB) - graph
Eb2Noise_min_TC = 5; 

% Bandwidth (Hz)
B_TC = (1 + 0.5) * RGross_TC ;

% Minimum signal to noise ratio (dB)
SNR_min_TC = Eb2Noise_min_TC + 10*log10(RGross_TC) - 10*log10(B_TC);

% Margins
Eb2Noise_margin = 3 ;
SNR_margin      = 3 ;

% Update threshold
Eb2Noise_min_TC = Eb2Noise_min_TC + Eb2Noise_margin ;
SNR_min_TC = SNR_min_TC + SNR_margin ;

% ----- LINK BUDGET -----
% KIRUNA EIRP (dBW)
KIRUNA_EIRP = 63.7 ;

% Transmitted power (dBW)
P_tx_dB = KIRUNA_EIRP - KIRUNA.G_TX - L_cable ; 

% Conversion to W
P_tx = 10^(P_tx_dB/10) ; 

% Noise temperature
T = 290 ;

% Energy per bit to noise ratio
Eb2Noise = KIRUNA_EIRP + SC_S.G_TX + L_space_TC + L_atm + L_point - 10 * log10(k * T * RGross_TC) ; 

% Signal to noise ratio
SNR = KIRUNA_EIRP + SC_S.G_TX + L_space_TC + L_atm + L_point - 10 * log10(k * T * B_TC) ; 

fprintf("--- TELECOMMAND SUMMARY (S-BAND) ---\n")
fprintf(" - Frequency : %d [MHz] \n", f_TC*1e-6);
fprintf(" - Bandwidth : %d [KHz] \n\n", B_TC*1e-3);

fprintf("---------- TX : KIRUNA ---------- \n");
fprintf("Type : Parabolic \n")
fprintf(" - Diameter   : %.2f [m] \n", KIRUNA.D);
fprintf(" - Efficiency : %.2f  [-] \n", KIRUNA.eta);
fprintf(" - Pointing   : %.2f  [deg] \n", KIRUNA.e);
fprintf(" - Beamwidth  : %.2f  [deg] \n\n", KIRUNA.theta);

fprintf("-------- RX : SPACECRAFT -------- \n");
fprintf("Type : Quadrifilar helix \n")
fprintf(" - Diameter   : %.2f   [m] \n", SC_S.D);
fprintf(" - Efficiency : %.2f   [-] \n", SC_S.eta);
fprintf(" - Pointing   : %.2f  [deg] \n", SC_S.e);
fprintf(" - Beamwidth  : %.2f [deg] \n\n", SC_S.theta);

fprintf("------------ LOSSES ------------\n")
fprintf(" - Atmospheric : %.2f   [dB] \n", L_atm) ;
fprintf(" - Free space  : %.2f [dB] \n", L_space_TC) ;
fprintf(" - Pointing    : %.2f   [dB] \n", L_point) ;
fprintf(" - Cable       : %.2f   [dB] \n\n", L_cable) ;

% fprintf("------------ NOISE ------------\n")
% fprintf(" - Noise temperature : %.2f   [K] \n", T) ;
% fprintf(" - Noise  : %.2f [dB] \n", L_space_TC) ;

fprintf("------------ RESULTS ------------ \n");
fprintf(" - EIRP  : %.1f [dB] \n", P_tx_dB + KIRUNA.G_TX + L_cable) ;
fprintf(" - NOISE : %.1f [dB]\n", 10 * log10(k * T) )
fprintf(" - Eb_No : %.1f [dB] > %.1f [dB] \n", Eb2Noise, Eb2Noise_min_TC);
fprintf(" - SNR   : %.1f [dB] > %.1f [dB] \n\n", SNR, SNR_min_TC);