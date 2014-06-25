library(shiny)
library(nat)
library(nat.flybrains)
library(shinyRGL)
options(nat.default.neuronlist='Cell07PNs')

shinyServer(function(input, output) {
   TransformStatus <- "PROCESSING"
  
  select_transform <- reactive({
    rval <- list(reg=NA,inverse=TRUE,exists=TRUE)
    RegDir <- file.path("~/projects",'BridgingRegistrations')
    rval$reg <- file.path(RegDir, paste(input$to, sep="", "_", input$from, ".list"))
    
    if(!file.exists(rval$reg)) {
      # try and look for inverse
      ireg <- file.path(RegDir, paste(input$from, sep="", "_", input$to, ".list"))
      if(file.exists(ireg)) {
        rval$reg <- ireg
        rval$inverse <- FALSE
      } else {
        rval$exists <- FALSE
      }
    }
    rval
  })
  
  getTransformation <- function() {
    rval <- select_transform()
    readLines(con=file.path(rval$reg, 'registration'))
  }
  
  # Details of transformation
  output$transformation <- renderText({
    paste("<b>Transformation:</b> ", input$from, " -> ", input$to)
  })

  # Path to registration
  output$regpath <- renderText({
    reglist <- select_transform()
    if(!reglist$exists){
      if(input$from == input$to)
        return("<span style='color: red; font-weight: bold;'>This is the identity transformation!</span>")
      return(paste("<span style='color: red; font-weight: bold;'>No direct transformation from ",input$from, " to ", input$to, " found.</span>"))
    } else paste("<b>Registration path:</b> ", reglist$reg)
  })

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
  
  output$downloadTransformation <- downloadHandler(
    filename <- function() { paste('transformation_', input$from, '_to_', input$to, '.txt', sep='') },
    content <- function(file) {
      writeLines(getTransformation(), file)
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
      myNeuron <- nat:::read.neuron.swc(uploadedFile$datapath)
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
      myNeuron <- nat:::read.neuron.swc(uploadedFile$datapath)
      plot3d(myNeuron)
      plot3d(get(paste0(input$from, ".surf")), col="grey", alpha=0.3)
      par3d('userMatrix'=structure(c(1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1), .Dim = c(4L, 4L)))
    }
  })

})