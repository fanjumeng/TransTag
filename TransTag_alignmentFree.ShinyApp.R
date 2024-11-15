######################
#This is the R script to launch Shiny app to process the flanking sequence file, and output the top enriched k-mer sequences.
#The top enriched k-mer sequences represent genomic regions flanking the most possible insertion site(s). 
#You can search/blast the most enriched k-mer sequence(s) in the genome to find the possible location of insertion site(s).
#author: Xiaolu Wei (xiaolu.wei@unt.edu)
######################

# Load libraries ----
library(shiny)
library(tidyverse)
library(dplyr)

options(shiny.maxRequestSize = 100 * 1024^2)

remove_bold <-"#expr-container label {font-weight: 400;}"

# Define User Interface ----
ui <- fluidPage(
  titlePanel("TransTag"),
  
  sidebarLayout(
    ## Sidebar ----
    sidebarPanel(width = 4,
                 tags$style(remove_bold), 
                 tags$div(id = "expr-container", 
                   h4("Upload file"),
                   fileInput(inputId = "InputFile",
                             label = "'Sample.flankingSequences.txt': processed file from 'TransTag_alignmentFree.sh'",
                             accept = c(".txt"),
                             multiple = FALSE),
                   h6(br()),
                   h4("Parameter"),
                   sliderInput(inputId = "cutoff", 
                               label = "Read length cutoff quantile", 
                               min = 0.5, max = 0.9, step= 0.05, value = 0.75),
                   textOutput(outputId = "size"),
                   h4(br()),
                   ##textOutput(outputId = "percentage"),
                   htmlOutput(outputId = "percentage"),
                 ) ## Closes custom style
      ), ## Closes Sidebar Panel
    ## Main Panel ----
    mainPanel(width = 8,
              tabsetPanel(
                
                ### Tab 1: Data Tables ----
                tabPanel("Output Table",
                         #h3("Output Table"),
                         column(width = 12,
                                #h4("Output Table"),
                                h3("Top15 flanking genomic regions of insertion sites"),
                                tableOutput("out_simple_table"))
                ), ## Closes Tab 1
                
                ### Tab 2: Plots ----
                tabPanel("Summary Plot",
                         h3("Read size distribution after trimming"),
                         plotOutput("out_plot")
                ) ## Closes Tab 2) ## Closes Tabset Panel
                
              ) ## Closes Tabset Panel
              
              ## Closing Brackets ----
    ) ## Closes Main Panel
  ) ## Closes Sidebar Layout
  
) ## Closes UI


# Define Server Logic ----
server <- function(input, output) {
  
  # Function Initiation ----
  k_count <- function(reads, k) {
    #only keep reads with length greater than kmer size
    filter_reads <- subset(reads, nchar(reads$V1) >= k)
    #extract kmers from remaining reads
    kmers <- data.frame(kmers = strtrim(filter_reads[,], k))
    #total number of kmers
    totalKmer <- nrow(kmers)
    
    #backbone sequence
    bg_seq <- strtrim("TCAAGAACTCCTGGACAAACCTCTGACCTGTGTGGAACAGAGTGGATATGGGTGTCTGAACAGATATTCACGTCTTTTGCAGATCAGAGGGCATTTCTGGTG", k)
    #kmer sequences that match the backbone sequence (with up to 5 mismatches)
    removed <- data.frame(kmers = unique(kmers[agrep(bg_seq, kmers[,], fixed = TRUE, max.distance = (all = 5)), ]))
    
    #remove kmers that match backbone sequences
    if (nrow(removed) > 0) {
      for (i in 1:nrow(removed))
      { kmers <- kmers %>% filter(.data[["kmers"]] != removed[i,])
      }
    }
    
    #number of kmers that do not match backbone sequence
    noBgKmer <- nrow(kmers)
    #percentage of backbone sequences in all kmers
    percentage <- 100*(1-noBgKmer/totalKmer)
    #number of kmers with backbone sequences
    number <- totalKmer-noBgKmer
      
    out <- kmers %>% group_by(kmers) %>% summarize(count = n()) %>% arrange(desc(count)) %>% slice(1:15)
    return(list(out, percentage, number))
  }
  
  ## Reactive expression to load data
  data <- reactive({ 
    req(input$InputFile)
    read.table(input$InputFile$datapath, header = FALSE)
  })
  
  ## Reactive expression to calculate read size cutoff
  size <- reactive({
    k <- as.numeric(input$cutoff)
    k_length <- quantile(nchar(data()$V1), k)
    paste0("Read size cutoff: ", as.character(k_length))
  })
  
  ## Reactive expression to calculate count
  count <- reactive({
    k <- as.numeric(input$cutoff)
    k_length <- quantile(nchar(data()$V1), k)
    k_count(data(), k_length)[[1]]
  })

  ## Reactive expression to calculate percentage/number of backbone kmers
  percentage <- reactive({
    k <- as.numeric(input$cutoff)
    k_length <- quantile(nchar(data()$V1), k)
    pt <- k_count(data(), k_length)[[2]]
    nn <- k_count(data(), k_length)[[3]]
    ifelse(pt > 30 & nn > 100, 
          paste0(paste0("<B>Warning</B>: Percentage of kmers with Tol2 vector sequences is ", sprintf("%0.1f%%", pt)), ", there may be Tol2-independent integration event(s)"),
          '')
  })

  ## Render text/table/plot output
  ## Text Outputs
  output$size <- renderText(size())
  output$percentage <- renderText(percentage())

  ## Table Outputs
  output$out_simple_table <- renderTable(count())

  ## Plot Output
  output$out_plot <- renderPlot({
    x <- nchar(data()$V1)
    hist(x, xlab = "Read size", ylab = "Counts", main = "")
  })
  
} ## Closes Server

# Run the Application ----
shinyApp(ui = ui, server = server)
