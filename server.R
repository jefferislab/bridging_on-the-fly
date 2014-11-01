library(shiny)
library(nat)
library(nat.flybrains)
library(shinyRGL)
options(nat.default.neuronlist='Cell07PNs')

shinyServer(function(input, output) {
   TransformStatus <- "PROCESSING"

  output$complete <- reactive({
    return(ifelse(TransformStatus=="DONE", TRUE, FALSE))
  })
  outputOptions(output, 'complete', suspendWhenHidden=FALSE)
  
  # Download points handler
  output$downloadResults <- downloadHandler(
    filename = function() {  paste('transformed-', Sys.Date(), '.txt', sep='') },
    content = function(file) {
      write.table(xformPoints(), file, col.names=TRUE, row.names=FALSE)
    }
  )
  
  output$transformedPlot <- renderWebGL({
    uploadedFile <- input$file1
    if(is.null(uploadedFile)) {
      # Dummy plot
      spheres3d(5,5,5,0)
      spheres3d(-5,-5,-5,0)
      text3d(0,0,0,"Upload a neuron to transform!")
    } else {
      TransformStatus <<- "PROCESSING"
      myNeuron <- tryCatch({
        nat:::read.neuron(uploadedFile$datapath)
      }, error = function(e) {
        nat:::read.neuron.swc(uploadedFile$datapath)
      })
      myNeuron <- xform_brain(myNeuron, sample=get(input$from), reference=get(input$to))
      TransformStatus <<- "DONE"
      plot3d(myNeuron)
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