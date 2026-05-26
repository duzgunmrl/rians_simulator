# PARAMÈTRES GÉNÉRAUX

T_half <- 24

d0 <- log(2) / T_half

A_star <- 200

lambda1 <- d0 * 300


# TEMPS DE SIMULATION

Tmax <- 500

times <- seq(0, Tmax, by = 0.1)


# PARAMÈTRES DU MODÈLE

params_default <- list(
  
  # Production / dégradation
  
  lambda1 = lambda1,
  lambda2 = 0.002 * A_star,
  
  d0 = d0,
  d1 = 3.5,
  d3 = 0.002,
  
  
  # Stress basal + irradiation
  
  stress_const = 0.08,
  
  irr_start = 100,
  irr_amp = 1.5,
  
  tau_rise = 0.2,
  tau_decay = 30,
  
  
  # Traitement
  
  t_traitement = 90,
  
  tau_traitement = 8,
  
  effet_antiox = 0.85,
  
  
  # Effet statine / traitement
  
  facteur_k4_traitement = 0.03,
  
  facteur_k5_traitement = 0.03,
  
  facteur_crown_traitement = 0.02,
  
  
  # Porosité nucléaire
  
  facteur_k3_traitement = 2.9,
  
  
  # Dispersion périnucléaire
  
  k6_traitement = 0.04,
  
  
  # Paramètres RIANS
  
  k1 = 0.001,
  k2 = 0.015,
  k3 = 0.03,
  k4 = 0.08,
  k5 = 0.01,
  k6 = 0,
  
  
  # Inhibition nucléaire
  
  PC_th = 200,
  nPC = 4,
  
  
  # Saturation couronne

  k_crown = 0.05,
  
  # ApoE basal
  
  A_star = A_star
)


# CONDITIONS INITIALES

state0_default <- c(
  
  DC = 320,
  
  MC = 1,
  
  MA = 0,
  
  MN = 0,
  
  A = A_star,
  
  CA = 0,
  
  DA = 0
)