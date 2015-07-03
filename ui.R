library(shiny)
library(nat)
library(nat.flybrains)
library(shinyRGL)

templateList <- list("Choose a brain" = "Choose a brain",
                     "T1 (Yu et al 2010, Dickson, IMP)" = "T1", 
                     "IS2 (Cachero, Ostrovsky et al 2010, Jefferis, MRC LMB)" = "IS2", 
                     "IBNWB (Insect Brain Name Working Group)" = "IBNWB",
                     "FCWB (Ostrovsky/Costa in prep, Jefferis, MRC LMB)" = "FCWB",
                     "JFRC2 (HHMI/VFB)" = "JFRC2")


shinyUI(fluidPage(
  HTML(
    '<nav class="navbar navbar-default navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <span class="navbar-brand">Bridging on-the-fly</span>
        </div>
        <ul class="nav navbar-nav">
          <li>
            <a href="#neurons">Bridge neurons</a>
          </li>
          <li>
            <a href="#coordinates">Bridge coordinates</a>
          </li>
          <li>
            <a href="#about">About</a>
          </li>
        </ul>
      </div>
    </nav>'
  ),
  
  HTML('<a name="neurons"></a>'),
  h1("Bridge neurons", style="padding-top: 70px;"),
  sidebarLayout(
    sidebarPanel(
      h2("Instructions"),
      "Select your source and target template brains and upload a tracing below. A zip archive of multiple neurons can also be uploaded. The original neuron(s) will be displayed in 3D below, with the bridged neurons to the right.",
      br(),
      br(),
      selectInput("from", "From:", templateList, selected="Choose a brain"),
      selectInput("to", "To:", templateList, selected="Choose a brain"),
      checkboxInput("mirror", "Mirror?", value=FALSE),
      fileInput('file1', 'Neuron/surface file:'),
      actionButton("bridge_button", "Bridge", class="btn btn-primary"),
      tags$button(type='submit', class='btn btn-primary', list(NULL, "Bridge"), id='bridge_submit', style="display: none;"),
      HTML('<script type="text/javascript">document.getElementById("bridge_button").onclick = function() { document.getElementById("bridge_button").click(); document.getElementById("bridge_submit").click(); }</script>'),
      h2("Original neuron(s)"),
      webGLOutput("originalPlot", width="400px", height="400px")
    ),
    mainPanel(
      h2("Transformed neuron(s)"),
      webGLOutput("transformedPlot", width="800px", height="800px")
      
    )
  ),
  
  div(style="height: 100vh;"),
  
  HTML('<a name="coordinates"></a>'),
  h1("Bridge coordinates", style="padding-top: 70px;"),
  sidebarLayout(
    sidebarPanel(
      h2("Instructions"),
      "Select your source and target template brains and enter 3D coordinates below. The original points will be displayed in 3D below, with the bridged points to the right.",
      br(),
      br(),
      selectInput("fromPts", "From:", templateList, selected="Choose a brain"),
      selectInput("toPts", "To:", templateList, selected="Choose a brain"),
      h2("Original points"),
      HTML('<textarea id="input_points" rows="8" cols=40>100 200 50
400 100 10</textarea>'),
      checkboxInput("mirror_points", "Mirror?", value=FALSE),
      submitButton("Bridge"),
      br(),
      h3("In 3D"),
      webGLOutput("originalPtsPlot", width="400px", height="400px")
    ),
    
    mainPanel(
      h2("Transformed points"),
      h3("In 3D"),
      webGLOutput("transformedPtsPlot", width="800px", height="800px"),
      tableOutput("transformedPts")
    )
  ),
  
  div(style="height: 100vh;"),
  
  HTML('<a name="about"></a>'),
  h1("About", style="padding-top: 70px;"),
  HTML("This web app accompanies <a href='http://dx.doi.org/10.1101/006353'>Manton et al. (2014) Combining genome-scale Drosophila 3D neuroanatomical data by bridging template brains</a> and acts as a demonstration of the bridging/mirroring approach for <i>Drosophila</i> brains (as implemented in the R package <a href='https://github.com/jefferislab/nat.flybrains'>nat.flybrains</a>), along with some features of the <a href='https://github.com/jefferis/nat'>NeuroAnatomy Toolbox</a>."),
  h2("Source code"),
  HTML("The full code for this web app can be downloaded from <a href='https://github.com/jefferislab/NBLAST_online'>GitHub</a>."),
  
  div(style="height: 100vh;")
  
))
