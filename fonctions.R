library(deSolve)

# MODÈLE RIANS : IRRADIATION + TRAITEMENT

rians_model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    
    # Irradiation

    Irr_raw <- function(t) {
      dt <- t - irr_start
      if (dt <= 0) return(0)
      
      (1 - exp(-dt / tau_rise)) * exp(-dt / tau_decay)
    }
    
    dt_star <- tau_rise * log(1 + tau_decay / tau_rise)
    
    Imax <- (1 - exp(-dt_star / tau_rise)) *
      exp(-dt_star / tau_decay)
    
    Irr <- ifelse(t <= irr_start, 0, Irr_raw(t) / Imax)
    
    # Traitement

    Trait <- ifelse(
      t < t_traitement,
      0,
      1 - exp(-(t - t_traitement) / tau_traitement)
    )
    
    # Stress effectif

    stress_basal_eff <- stress_const * (1 - effet_antiox * Trait)
    
    s <- stress_basal_eff + irr_amp * Irr
    
    # Paramètres modifiés par traitement

    k4_eff <- k4 * (1 - Trait + Trait * facteur_k4_traitement)
    k5_eff <- k5 * (1 - Trait + Trait * facteur_k5_traitement)
    k_crown_eff <- k_crown * (1 - Trait + Trait * facteur_crown_traitement)
    k3_base_eff <- k3 * (1 - Trait + Trait * facteur_k3_traitement)
    k6_eff <- k6 * (1 - Trait) + k6_traitement * Trait
    
    # Couronne périnucléaire

    PC <- CA + DA
    
    k3_eff <- k3_base_eff / (1 + (PC / PC_th)^nPC)
        
    formation_CA <- k4_eff * A * MA
    
    formation_DA <- 0.5 * k5_eff * MA^2 + k_crown_eff * CA
    
    # Équations différentielles

    dDC <- lambda1 - d0 * DC + 0.5 * k1 * MC^2 - s * DC
    
    dMC <- -k1 * MC^2 - k2 * MC + k6_eff * MA + 2 * s * DC
    
    dMA <- k2 * MC - k3_base_eff * MA - formation_CA - k5_eff * MA^2 - k6_eff * MA + 2 * s * DA + s * CA
    
    dMN <- k3_eff * MA - d1 * MN
    
    dA <- lambda2 - d3 * A - formation_CA + s * CA
    
    dCA <- formation_CA - s * CA
    
    dDA <- formation_DA - s * DA
    
    list(c(dDC, dMC, dMA, dMN, dA, dCA, dDA))
  })
}

# FONCTIONS POUR RECALCULER IRRADIATION / TRAITEMENT / STRESS

compute_irradiation <- function(t, params) {
  dt <- t - params$irr_start
  
  if (dt <= 0) return(0)
  
  Irr_raw <- (1 - exp(-dt / params$tau_rise)) *
    exp(-dt / params$tau_decay)
  
  dt_star <- params$tau_rise *
    log(1 + params$tau_decay / params$tau_rise)
  
  Imax <- (1 - exp(-dt_star / params$tau_rise)) *
    exp(-dt_star / params$tau_decay)
  
  Irr_raw / Imax
}


compute_traitement <- function(t, params) {
  if (t < params$t_traitement) return(0)
  
  1 - exp(-(t - params$t_traitement) / params$tau_traitement)
}


compute_stress <- function(t, params) {
  Irr <- compute_irradiation(t, params)
  Trait <- compute_traitement(t, params)
  
  stress_basal_eff <- params$stress_const *
    (1 - params$effet_antiox * Trait)
  
  stress_basal_eff + params$irr_amp * Irr
}

# FONCTION PRINCIPALE DE SIMULATION

simulation_rians <- function(params, state0, times) {
  
  out <- as.data.frame(
    ode(
      y = state0,
      times = times,
      func = rians_model,
      parms = params
    )
  )
  
  # Variables dérivées
  out$PC <- out$CA + out$DA
  
  out$Irr <- vapply(
    out$time,
    compute_irradiation,
    numeric(1),
    params = params
  )
  
  out$Trait <- vapply(
    out$time,
    compute_traitement,
    numeric(1),
    params = params
  )
  
  out$s <- vapply(
    out$time,
    compute_stress,
    numeric(1),
    params = params
  )
  
  return(out)
}
