library(shiny)
library(nat)
library(nat.flybrains)
library(rgl)

options(rgl.useNULL=TRUE)


# Define a function for a frontal view of the brain
frontalView<-function(zoom=0.6){
	um=structure(c(1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1), .Dim = c(4L, 4L))
	rgl.viewpoint(userMatrix=um,zoom=zoom)
}

shinyServer(function(input, output) {

###########
# Tracing #
###########
tracing <- reactive({
	# input$bridge_button
	isolate(query_neuron <- input$file1)
	if(is.null(query_neuron) | "Choose a brain" %in% c(input$from, input$to)) return(NULL)
		if(!is.null(reader <- getformatreader(query_neuron$datapath, 'hxsurf')$read)) {
			tracing_neuron <- reader(query_neuron$datapath)
		} else if(grepl("\\.zip", query_neuron$name)) {
		neurons_dir <- file.path(tempdir(), "user_neurons")
		on.exit(unlink(neurons_dir, recursive=TRUE))
		unzip(query_neuron$datapath, exdir=neurons_dir)
		tracing_neuron <- read.neurons(dir(neurons_dir, full=TRUE))
	}
	else if(grepl("\\.swc", query_neuron$name)) tracing_neuron <- nat:::read.neuron.swc(query_neuron$datapath)
	else tracing_neuron <- read.neuron(query_neuron$datapath)
	tracing_neuron
})

transformed_tracing <- reactive({
	tracing_neuron <- tracing()
	if(is.null(tracing_neuron)) return(NULL)
	if(input$from != input$to) {
		if(input$mirror) {
			tryCatch({
				tracing_neuron <- mirror_brain(tracing_neuron, get(input$from))
				tracing_neuron <- xform_brain(tracing_neuron, sample=get(input$from), reference=get(input$to))
			}, error = function(e) {
				tryCatch({
					tracing_neuron <- xform_brain(tracing_neuron, sample=get(input$from), reference=get(input$to))
					tracing_neuron <- mirror_brain(tracing_neuron, get(input$to))
				}, error = function(e) {
					stop("Could not mirror neuron.")
				})
			})
		} else {
			tracing_neuron <- xform_brain(tracing_neuron, sample=get(input$from), reference=get(input$to))
		}
	}
	tracing_neuron
})

output$transformedPlot <- renderRglwidget({
	uploadedFile <- transformed_tracing()
	clear3d()
	if(is.null(uploadedFile)) {
		# Dummy plot
		spheres3d(5,5,5,0)
		spheres3d(-5,-5,-5,0)
		text3d(0,0,0,"Upload a neuron to transform!")
	} else {
		TransformStatus <<- "DONE"
		plot3d(uploadedFile)
		plot3d(get(paste0(input$to, ".surf")), col="grey", alpha=0.3)
		frontalView()
	}
	rglwidget()
})

output$originalPlot <- renderRglwidget({
	uploadedFile <- tracing()
	clear3d()
	if(is.null(uploadedFile)) {
		# Dummy plot
		spheres3d(5,5,5,0)
		spheres3d(-5,-5,-5,0)
		text3d(0,0,0,"Upload a neuron to transform!")
	} else {
		plot3d(uploadedFile)
		plot3d(get(paste0(input$from, ".surf")), col="grey", alpha=0.3)
		frontalView()
	}
	rglwidget()
})



##########
# Points #
##########
points <- reactive({
	pts <- read.table(text=input$input_points)
	if(ncol(pts)==4) pts <- pts[, 1:3]
	colnames(pts) <- c('X', 'Y', 'Z')
	pts
})

transformed_points <- reactive({
	pts <- points()
	if("Choose a brain" %in% c(input$fromPts, input$toPts)) return(NULL)
	if(input$fromPts != input$toPts) {
		if(input$mirror_points) {
			tryCatch({
				pts <- mirror_brain(pts, get(input$fromPts))
				pts <- xform_brain(pts, sample=get(input$fromPts), reference=get(input$toPts))
			}, error = function(e) {
				tryCatch({
					pts <- xform_brain(pts, sample=get(input$fromPts), reference=get(input$toPts))
					pts <- mirror_brain(pts, get(input$toPts))
				}, error = function(e) {
					stop("Could not mirror points")
				})
			})
		} else {
			pts <- xform_brain(pts, sample=get(input$fromPts), reference=get(input$toPts))
		}
	}
	pts
})

output$originalPtsPlot <- renderRglwidget({
	pts <- points()
	clear3d()
	if(is.null(pts) | "Choose a brain" %in% c(input$fromPts, input$toPts)) {
		# Dummy plot
		spheres3d(5,5,5,0)
		spheres3d(-5,-5,-5,0)
		text3d(0,0,0,"Enter coordinates in textbox")
		text3d(0,0.5,0,"and click bridge!")
	} else {
		# Dummy plot
		spheres3d(pts, radius=5, color=rainbow(length(points())))
		plot3d(get(paste0(input$fromPts, ".surf")), col="grey", alpha=0.3)
		frontalView()
	}
	rglwidget()
})

output$transformedPts <- renderTable({
	pts <- transformed_points()
	pts
})

output$transformedPtsPlot <- renderRglwidget({
	pts <- transformed_points()
	clear3d()
	if(is.null(pts) | "Choose a brain" %in% c(input$fromPts, input$toPts)) {
		# Dummy plot
		spheres3d(5,5,5,0)
		spheres3d(-5,-5,-5,0)
		text3d(0,0,0,"Enter coordinates in textbox")
		text3d(0,0.3,0,"and click bridge!")
	} else {
		# Dummy plot
		spheres3d(pts, radius=5, color=rainbow(length(pts)))
		plot3d(get(paste0(input$toPts, ".surf")), col="grey", alpha=0.3)
		frontalView()
	}
	rglwidget()
})

})
