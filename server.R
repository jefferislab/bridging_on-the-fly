library(shiny)
library(nat)
library(nat.flybrains)
library(shinyRGL)
options(nat.default.neuronlist='Cell07PNs')

shinyServer(function(input, output) {
   TransformStatus <- "PROCESSING"
   
   tracing <- reactive({          
     query_neuron <- input$file1
     if(is.null(query_neuron)) return(NULL)
     if(grepl("\\.swc", query_neuron$name)) tracing_neuron <- nat:::read.neuron.swc(query_neuron$datapath)
     else tracing_neuron <- read.neuron(query_neuron$datapath)
     
     if(input$from != input$to) {
       tracing_neuron <- xform_brain(tracing_neuron, sample=get(input$from), reference=get(input$to))
     }
     tracing_neuron
   })

  output$complete <- reactive({
    return(ifelse(TransformStatus=="DONE", TRUE, FALSE))
  })
  outputOptions(output, 'complete', suspendWhenHidden=FALSE)
  
  # Download points handler
  output$downloadResults <- downloadHandler(
    filename = function() {  paste0('transformed-', Sys.Date(), '.swc') },
    content = function(file) {
      write.neuron(tracing(), file, format="swc")
    }
  )
  
  output$transformedPlot <- renderWebGL({
    uploadedFile <- tracing()
    if(is.null(uploadedFile)) {
      # Dummy plot
      spheres3d(5,5,5,0)
      spheres3d(-5,-5,-5,0)
      text3d(0,0,0,"Upload a neuron to transform!")
    } else {
      TransformStatus <<- "DONE"
      plot3d(uploadedFile)
      plot3d(get(paste0(input$to, ".surf")), col="grey", alpha=0.3)
      par3d('userMatrix'=structure(c(1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1), .Dim = c(4L, 4L)))
    }
  })

  output$originalPlot <- renderWebGL({
    uploadedFile <- input$file1
    if(is.null(uploadedFile)) {
      # Dummy plot
      spheres3d(5,5,5,0)
      spheres3d(-5,-5,-5,0)
      text3d(0,0,0,"Upload a neuron to transform!")
    } else {
      myNeuron <- tryCatch({
        nat:::read.neuron(uploadedFile$datapath)
      }, error = function(e) {
        nat:::read.neuron.swc(uploadedFile$datapath)
      })
      plot3d(myNeuron)
      plot3d(get(paste0(input$from, ".surf")), col="grey", alpha=0.3)
      par3d('userMatrix'=structure(c(1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1), .Dim = c(4L, 4L)))
    }
  })

})