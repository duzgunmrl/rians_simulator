library(shiny)
library(plotly)
library(htmlwidgets)
library(webshot2)
library(magick)

source("parametres.R")
source("fonctions.R")

make_plot <- function(df, type, params = NULL) {
  if (type == "stress") {
    plot_ly(df, x = ~time) %>%
      add_lines(y = ~Irr, name = "Irr_N", line = list(color = "orange")) %>%
      add_lines(y = ~s, name = "Stress total", line = list(color = "black")) %>%
      add_lines(y = ~Trait, name = "Traitement", line = list(color = "green")) %>%
      add_lines(y = rep(params$stress_const, nrow(df)), name = "Stress basal",
                line = list(color = "gray", dash = "dash")) %>%
      layout(title = "IRRADIATION, TRAITEMENT ET STRESS TOTAL",
             xaxis = list(title = "TEMPS (H)"),
             yaxis = list(title = "INTENSITÉ RELATIVE"))
    
  } else if (type == "cyto") {
    plot_ly(df, x = ~time) %>%
      add_lines(y = ~DC, name = "Dimères cytoplasmiques", line = list(color = "blue")) %>%
      add_lines(y = ~MC, name = "Monomères cytoplasmiques", line = list(color = "green")) %>%
      layout(title = "CYTOPLASME",
             xaxis = list(title = "TEMPS (H)"),
             yaxis = list(title = "CONCENTRATION"))
    
  } else if (type == "crown") {
    plot_ly(df, x = ~time) %>%
      add_lines(y = ~MA, name = "Monomères zone perinucléaire", line = list(color = "purple")) %>%
      add_lines(y = ~CA, name = "Complexe ApoE-ATM monomérique", line = list(color = "red")) %>%
      add_lines(y = ~DA, name = "Diméres zone perinucléaire", line = list(color = "orange")) %>%
      add_lines(y = ~PC, name = "Perinuclear Crown", line = list(color = "green")) %>%

      layout(title = "COURONNE PÉRINUCLÉAIRE",
             xaxis = list(title = "TEMPS (H)"),
             yaxis = list(title = "CONCENTRATION"))
    
  } else if (type == "noyau") {
    plot_ly(df, x = ~time) %>%
      add_lines(y = ~MN, name = "Monomères nucléaires", line = list(color = "red")) %>%
      layout(title = "NOYAU",
             xaxis = list(title = "TEMPS (H)"),
             yaxis = list(title = "CONCENTRATION"))
    
  } else if (type == "apoe") {
    plot_ly(df, x = ~time) %>%
      add_lines(y = ~A, name = "A", line = list(color = "black")) %>%
      add_lines(y = rep(params$A_star, nrow(df)), name = "A*",
                line = list(color = "gray", dash = "dash")) %>%
      layout(title = "APOE LIBRE",
             xaxis = list(title = "TEMPS (H)"),
             yaxis = list(title = "CONCENTRATION"))
  }
}

server <- function(input, output, session) {
  
  resultat <- eventReactive(input$run, {
    
    params <- params_default
    
    noms <- c(
      "lambda1", "lambda2", "d0", "d1", "d3",
      "stress_const", "irr_start", "irr_amp", "tau_rise", "tau_decay",
      "t_traitement", "tau_traitement", "effet_antiox",
      "facteur_k4_traitement", "facteur_k5_traitement",
      "facteur_crown_traitement", "facteur_k3_traitement",
      "k6_traitement",
      "k1", "k2", "k3", "k4", "k5", "k6",
      "PC_th", "nPC", "k_crown"
    )
    
    for (n in noms) params[[n]] <- input[[n]]
    
    times_user <- seq(0, input$Tmax, by = input$dt)
    
    state0 <- c(
      DC = input$DC0,
      MC = input$MC0,
      MA = input$MA0,
      MN = input$MN0,
      A  = input$A0,
      CA = input$CA0,
      DA = input$DA0
    )
    
    out <- simulation_rians(params, state0, times_user)
    
    list(out = out, params = params)
  })
  
  output$plot_stress <- renderPlotly(make_plot(resultat()$out, "stress", resultat()$params))
  output$plot_cyto   <- renderPlotly(make_plot(resultat()$out, "cyto"))
  output$plot_crown  <- renderPlotly(make_plot(resultat()$out, "crown"))
  output$plot_noyau  <- renderPlotly(make_plot(resultat()$out, "noyau"))
  output$plot_apoe   <- renderPlotly(make_plot(resultat()$out, "apoe", resultat()$params))
  
  output$table_params <- renderTable({
    params <- resultat()$params
    data.frame(Parametre = names(params), Valeur = unlist(params))
  }, digits = 4)
  
  output$download_pdf <- downloadHandler(
    
    filename = function() {
      paste0("rapport_RIANS_", format(Sys.time(), "%Y-%m-%d_%H-%M"), ".pdf")
    },
    
    content = function(file) {
      
      req(resultat())
      
      df <- resultat()$out
      params <- resultat()$params
      
      tmp <- tempdir()
      types <- c("stress", "cyto", "crown", "noyau", "apoe")
      pngs <- file.path(tmp, paste0(types, ".png"))
      
      for (i in seq_along(types)) {
        p <- make_plot(df, types[i], params)
        html <- file.path(tmp, paste0(types[i], ".html"))
        saveWidget(p, html, selfcontained = FALSE)
        webshot(html, file = pngs[i], vwidth = 1200, vheight = 800, zoom = 1)
      }
      
      pdf(file, width = 14, height = 10)
      
      plot.new()
      title("PARAMÈTRES UTILISÉS")
      text(
        0, 1,
        paste(names(params), "=", round(unlist(params), 4), collapse = "\n"),
        adj = c(0, 1),
        cex = 0.8
      )
      
      for (img in pngs) {
        plot.new()
        rasterImage(as.raster(image_read(img)), 0, 0, 1, 1)
      }
      
      dev.off()
    }
  )
}