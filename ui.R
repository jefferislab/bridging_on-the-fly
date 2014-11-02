library(shiny)
library(nat)
library(nat.flybrains)
library(shinyRGL)

templateList <- list("T1 (Yu et al 2010, Dickson, IMP)" = "T1", 
                     "IS2 (Cachero, Ostrovsky et al 2010, Jefferis, MRC LMB)" = "IS2", 
                     "Cell07 (Jefferis, Potter 2007, Jefferis/Luo, Cambridge/Stanford)" = "Cell07",
                     "FCWB (Ostrovsky/Costa in prep, Jefferis, MRC LMB)" = "FCWB",
                     "JFRC2 (HHMI/VFB)" = "JFRC2")

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Bridge neurons between Drosophila template brains"),
  
  sidebarPanel(
    selectInput("from", "From:", templateList, selected=names(which(templateList=="FCWB"))),
    selectInput("to", "To:", templateList, selected=names(which(templateList=="JFRC2"))),
    fileInput('file1', 'Neuron file:'),
    h2("Original neuron(s)"),
    webGLOutput("originalPlot")
  ),
  
  mainPanel(
    h2("Transformed neuron(s)"),
    webGLOutput("transformedPlot"),
    
    conditionalPanel(
      condition = "output.complete",
      h2("Download"),
      downloadButton('downloadResults', 'Download bridged SWC file')
    )
  )
))