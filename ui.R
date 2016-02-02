library(shiny)
library(rglwidget)

templateList <- list("Choose a brain" = "Choose a brain", "T1 (Yu et al 2010, Dickson, IMP)" = "T1", "IS2 (Cachero, Ostrovsky et al 2010, Jefferis, MRC LMB)" = "IS2", "IBNWB (Insect Brain Name Working Group)" = "IBNWB", "FCWB (Ostrovsky/Costa in prep, Jefferis, MRC LMB)" = "FCWB", "JFRC2 (HHMI/VFB)" = "JFRC2")

shinyUI(navbarPage("Bridging on-the-fly",

tabPanel("Tracing",
sidebarLayout(
	sidebarPanel(
		h2("Instructions"),
		HTML("Select your source and target template brains and upload a tracing below. A zip archive of multiple neurons can also be uploaded. The original neuron(s) will be displayed in 3D below, with the bridged neurons to the right."),
		br(),
		br(),
		selectInput("from", "From:", templateList, selected="Choose a brain"),
		selectInput("to", "To:", templateList, selected="Choose a brain"),
		checkboxInput("mirror", "Mirror?", value=FALSE),
		fileInput('file1', 'Neuron/surface file:'),
		submitButton("Bridge"),
		HTML('<script type="text/javascript">document.getElementById("bridge_button").onclick = function() { document.getElementById("bridge_button").click(); document.getElementById("bridge_submit").click(); }</script>'),

		h2("Original neuron(s)"),
		rglwidgetOutput("originalPlot", width="400px", height="400px")
	),

	mainPanel(
		h2("Transformed neuron(s)"),
		rglwidgetOutput("transformedPlot", width="800px", height="800px")
	)
)),


tabPanel("Points",
sidebarLayout(
	sidebarPanel(
		h2("Instructions"),
		HTML("Select your source and target template brains and enter 3D coordinates below. The original points will be displayed in 3D below, with the bridged points to the right."),
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
		rglwidgetOutput("originalPtsPlot", width="400px", height="400px")
	),

	mainPanel(
		h2("Transformed points"),
		h3("In 3D"),
		rglwidgetOutput("transformedPtsPlot", width="800px", height="800px"),
		tableOutput("transformedPts")
	)
))

))
