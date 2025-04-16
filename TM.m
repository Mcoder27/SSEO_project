clear
clc

% ----- GENERAL DATA -----
c = astroConstants(5) * 1e3 ; % Speed of light in the vacuum (m/s)
k = 1.38e-23 ; % Boltzmann constant 

% ----- TELEMETRY ------------------------------------------------------

% Frequency (Hz)
f_TM = 2205e6 ; 

% Wavelength (m)
lambda_TM = c / f_TM ;  

% GS ANTENNA DATA (KIRUNA) - RECEIVER
D_GS_S     = 13   ; % Diameter (m) 
eta_GS_S   = 0.55 ; % Efficiency (-)
e_GS_S     = 0.01 ; % Pointing accuracy (deg) 

% Beamwidth (deg)
theta_GS_S = 70 * lambda_TM / D_GS_S ; % Literature says around 0.76

KIRUNA = struct("D", D_GS_S, "eta", eta_GS_S, "e", e_GS_S, "theta", theta_GS_S) ;

% Antenna gain (dB)
KIRUNA.G_RX = 10 * log10( KIRUNA.eta * pi^2 * KIRUNA.D^2 / (lambda_TM)^2 ) ;  

% SC ANTENNA DATA (S-BAND) - TRANSMITTER
D_SC_S     = 10e-2 ; % Diameter (m) 
eta_SC_S   = 0.70  ; % Efficiency (-)
e_SC_S     = 20    ; % Pointing accuracy (deg) 

% Beamwidth (deg)
theta_SC_S =  70 * lambda_TM / D_SC_S ;

SC_S = struct("D", D_SC_S, "eta", eta_SC_S, "e", e_SC_S, "theta", theta_SC_S) ; 

% Antenna gain (dB)
SC_S.G_TX = 10 * log10( SC_S.eta * pi^2 * SC_S.D^2 / (lambda_TM)^2 ) ; 

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
L_space_TM = - 20 * log10(4 * pi * distance / lambda_TM) ; 

% Pointing losses
L_point = - 12 * (e_SC_S / SC_S.theta)^2 ;

% ----- LINK BUDGET -----
% Effective data rate (bps)
Rnet_TM = 8e3 ;

% Modulation and encoding coefficients (-)
alphaEnc_TM = 2 ;
alphaMod_TM = 2 ;

% Gross data rate (bps)
RGross_TM   = Rnet_TM * alphaEnc_TM / alphaMod_TM ;

% Bit Error Rate (from literature)
BER_TM = 1e-5 ;  

% Minimum energy bit to noise spectral density ratio (dB) - graph
Eb2Noise_min_TM = 4.4; 

% Bandwidth (Hz)
B_TM = (1 + 0.5) * RGross_TM ;

% Minimum signal to noise ratio (dB)
SNR_min_TM = Eb2Noise_min_TM + 10*log10(RGross_TM) - 10*log10(B_TM);

% Margins
Eb2Noise_margin = 3 ;
SNR_margin      = 3 ;

% Update threshold
Eb2Noise_min_TM = Eb2Noise_min_TM + Eb2Noise_margin ;
SNR_min_TM = SNR_min_TM + SNR_margin ;

% ----- LINK BUDGET -----

% Transmitted power (W)
P_tx = 10 ;

% Conversion to dB
P_tx_dB = 10 * log10(P_tx) ;

% Noise temperature
T = 100 ;

% Energy per bit to noise ratio
Eb2Noise = P_tx_dB + SC_S.G_TX + KIRUNA.G_RX + L_cable + L_space_TM + L_atm + L_point - 10 * log10(k * T * RGross_TM) ; 

% Signal to noise ratio
SNR = P_tx_dB + SC_S.G_TX + KIRUNA.G_RX + L_cable + L_space_TM + L_atm + L_point - 10 * log10(k * T * B_TM) ;

fprintf("--- TELEMETRY SUMMARY (S-BAND) ---\n")
fprintf(" - Frequency : %d [MHz] \n", f_TM*1e-6);
fprintf(" - Bandwidth : %d [KHz] \n\n", B_TM*1e-3);

fprintf("---------- RX : KIRUNA ---------- \n");
fprintf("Type : Parabolic \n")
fprintf(" - Diameter   : %.2f [m] \n", KIRUNA.D);
fprintf(" - Efficiency : %.2f  [-] \n", KIRUNA.eta);
fprintf(" - Pointing   : %.2f  [deg] \n", KIRUNA.e);
fprintf(" - Beamwidth  : %.2f  [deg] \n\n", KIRUNA.theta);

fprintf("-------- TX : SPACECRAFT -------- \n");
fprintf("Type : Quadrifilar helix \n")
fprintf(" - Diameter   : %.2f   [m] \n", SC_S.D);
fprintf(" - Efficiency : %.2f   [-] \n", SC_S.eta);
fprintf(" - Pointing   : %.2f  [deg] \n", SC_S.e);
fprintf(" - Beamwidth  : %.2f [deg] \n\n", SC_S.theta);

fprintf("------------ LOSSES ------------\n")
fprintf(" - Atmospheric : %.2f   [dB] \n", L_atm) ;
fprintf(" - Free space  : %.2f [dB] \n", L_space_TM) ;
fprintf(" - Pointing    : %.2f   [dB] \n", L_point) ;
fprintf(" - Cable       : %.2f   [dB] \n\n", L_cable) ;

% fprintf("------------ NOISE ------------\n")
% fprintf(" - Noise temperature : %.2f   [K] \n", T) ;
% fprintf(" - Noise  : %.2f [dB] \n", L_space_TC) ;

fprintf("------------ RESULTS ------------ \n");
fprintf(" - EIRP  : %.1f [dB] \n", P_tx_dB + KIRUNA.G_RX + L_cable) ;
fprintf(" - NOISE : %.1f [dB]\n", 10 * log10(k * T) )
fprintf(" - Eb_No : %.1f [dB] > %.1f [dB] \n", Eb2Noise, Eb2Noise_min_TM);
fprintf(" - SNR   : %.1f [dB] > %.1f [dB] \n\n", SNR, SNR_min_TM);