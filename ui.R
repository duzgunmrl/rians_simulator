library(shiny)
library(bslib)
library(plotly)

ui <- page_fluid(
  
  theme = bs_theme(
    version = 5,
    bootswatch = "minty",
    primary = "#6C63FF",
    bg = "#F5F7FA",
    fg = "#1E1E1E"
  ),
  
  tags$head(
    tags$style(HTML("
      .sidebar {
        background-color: white;
        padding: 25px;
        border-radius: 20px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        height: 95vh;
        overflow-y: auto;
      }
      
      .card-custom {
        background-color: white;
        border-radius: 20px;
        padding: 20px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      }
      
      .btn-primary {
        border-radius: 12px;
        font-size: 18px;
        padding: 12px;
        width: 100%;
        background-color: #6C63FF;
        border: none;
      }
      
      h2 {
        font-weight: 700;
        margin-bottom: 20px;
      }
      
      .form-label {
        font-weight: 600;
      }
    "))
  ),
  
  h2("RIANS SIMULATOR"),
  
  layout_columns(
    
    col_widths = c(3, 9),
    
    div(
      class = "sidebar",
      
      h4("Stress et irradiation"),
      numericInput("stress_const", "Stress basal", 0.08),
      numericInput("irr_amp", "Amplitude irradiation", 0.15),
      numericInput("irr_start", "Temps irradiation", 100),
      numericInput("tau_rise", "Rise", 0.2),
      numericInput("tau_decay", "Decay", 30),
      
      hr(),
      
      h4("Traitement"),
      numericInput("t_traitement", "Temps traitement", 90),
      numericInput("tau_traitement", "Temps action traitement", 8),
      numericInput("effet_antiox", "Effet anti-oxydant", 0.85),
      numericInput("facteur_k3_traitement", "Effet porosité (k3)", 2.9),
      numericInput("facteur_k4_traitement", "Facteur k4", 0.03),
      numericInput("facteur_k5_traitement", "Facteur k5", 0.03),
      numericInput("facteur_crown_traitement", "Facteur crown", 0.02),
      numericInput("k6_traitement", "k6 traitement", 0.04),
      
      hr(),
      
      h4("Paramètres RIANS"),
      numericInput("k1", "k1", 0.001),
      numericInput("k2", "k2", 0.015),
      numericInput("k3", "k3", 0.03),
      numericInput("k4", "k4", 0.08),
      numericInput("k5", "k5", 0.01),
      numericInput("k6", "k6", 0),
      numericInput("k_crown", "k crown", 0.05),
      numericInput("PC_th", "Perinuclear Crown threshold", 200),
      numericInput("nPC", "nPC (Intensité de l’effet inhibiteur)", 4),
      
      hr(),
      
      h4("Production / dégradation"),
      numericInput("lambda1", "lambda1", 8.66),
      numericInput("lambda2", "lambda2", 0.4),
      numericInput("d0", "d0", 0.028),
      numericInput("d1", "d1", 2),
      numericInput("d3", "d3", 0.003),
      
      hr(),
      
      h4("Conditions initiales"),
      numericInput("DC0", "Dimères cytoplasmiques", 320),
      numericInput("MC0", "Monomères cytoplasmiques", 1),
      numericInput("MA0", "Monomères zone perinucléaire", 0),
      numericInput("MN0", "Monomères nucléaires", 0),
      numericInput("A0", "ApoE zone perinucléaire", 200),
      numericInput("CA0", "Complexe ApoE-ATM monomérique", 0),
      numericInput("DA0", "Diméres zone perinucléaire", 0),
      
      hr(),
      
      h4("Simulation"),
      numericInput("Tmax", "Temps max", 500),
      numericInput("dt", "Pas de temps", 0.1),
      
      actionButton(
        "run",
        "RUN SIMULATION",
        class = "btn-primary"
      ),
      
      br(),
      br(),
      
      downloadButton(
        "download_pdf",
        "Télécharger le rapport PDF",
        class = "btn-primary"
      )
    ),
    
    div(
      class = "card-custom",
      
      navset_tab(
        
        nav_panel(
          "Simulation",
          
          navset_tab(
            
            nav_panel(
              "Stress",
              plotlyOutput("plot_stress", height = "700px")
            ),
            
            nav_panel(
              "Cytoplasme",
              plotlyOutput("plot_cyto", height = "700px")
            ),
            
            nav_panel(
              "Couronne",
              plotlyOutput("plot_crown", height = "700px")
            ),
            
            nav_panel(
              "Noyau",
              plotlyOutput("plot_noyau", height = "700px")
            ),
            
            nav_panel(
              "ApoE",
              plotlyOutput("plot_apoe", height = "700px")
            ),
            
            nav_panel(
              "Paramètres",
              tableOutput("table_params")
            )
          )
        ),
        
        nav_panel(
          "Optimisation",
          
          h3("Optimisation irradiation / traitement"),
                    
          br(),
          
          actionButton(
            "run_optim",
            "Lancer optimisation",
            class = "btn-primary"
          ),
          
          br(),
          br(),
          
          plotlyOutput("plot_optim", height = "700px")
        )
      )
    )
  )
)