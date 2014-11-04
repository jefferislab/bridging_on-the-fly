library(shiny)
library(nat)
library(nat.flybrains)
library(shinyRGL)

templateList <- list("T1 (Yu et al 2010, Dickson, IMP)" = "T1", 
                     "IS2 (Cachero, Ostrovsky et al 2010, Jefferis, MRC LMB)" = "IS2", 
                     "Cell07 (Jefferis, Potter 2007, Jefferis/Luo, Cambridge/Stanford)" = "Cell07",
                     "FCWB (Ostrovsky/Costa in prep, Jefferis, MRC LMB)" = "FCWB",
                     "JFRC2 (HHMI/VFB)" = "JFRC2")


shinyUI(navbarPage("Bridging on-the-fly",
tabPanel("User-uploaded tracing",
  sidebarLayout(
  
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
)),


tabPanel("Coordinates",
  sidebarLayout(
  
  sidebarPanel(
    selectInput("fromPts", "From:", templateList, selected=names(which(templateList=="FCWB"))),
    selectInput("toPts", "To:", templateList, selected=names(which(templateList=="JFRC2"))),
    h2("Original points"),
    HTML('<textarea id="input_points" rows="16" cols=60>100 200 50
400 100 10</textarea>'),
    submitButton("Bridge"),
    br(),
    h3("In 3D"),
    webGLOutput("originalPtsPlot")
  ),
  
  mainPanel(
    h2("Transformed points"),
    h3("In 3D"),
    webGLOutput("transformedPtsPlot"),
    tableOutput("transformedPts")
  )
)),


tabPanel("About",
  mainPanel(
    HTML("This web app accompanies <a href='http://dx.doi.org/10.1101/006353'>Manton et al. (2014) Combining genome-scale Drosophila 3D neuroanatomical data by bridging template brains</a> and acts as a demonstration of the bridging/mirroring approach for <i>Drosophila</i> brains (as implemented in the R package <a href='https://github.com/jefferislab/nat.flybrains'>nat.flybrains</a>), along with some features of the <a href='https://github.com/jefferis/nat'>NeuroAnatomy Toolbox</a>."),
    h2("Source code"),
    HTML("The full code for this web app can be downloaded from <a href='https://github.com/jefferislab/NBLAST_online'>GitHub</a>.")    
  )
)

))
