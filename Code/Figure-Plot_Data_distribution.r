
rm(list=ls())

library(ggplot2)


Tag <- "Sub"
file_path <- "Phenotypes/Sub16.list"
measures <- scan(file_path, what = "", sep = "\n")



for (Measure in measures) {
  print(Measure)

  Flag <-  paste0(Tag, "_", Measure)
  
    modes <- c("Chinese","Western")


  
  for (Mode in modes) {
    Mode
    DATATAG <-  paste0(Mode, "_", Flag)
    dataPath <- paste0("Data/",Tag ,"/", Measure )
    OutPath <- paste0("Figure/",Tag)
    
    
    Datadir <- paste0(dataPath, "/", DATATAG, ".csv")
    Data <- read.csv(Datadir)
    
    Data$AgeTransformed <- log(Data$Age)
    cmd <- paste0("Data$Pho <- Data$", Measure)
    eval(parse(text = cmd))
    
    x_limit_left=280

    if (Measure %in% c("Vent_Volume", "Cerebellum","CerebellumGM","CerebellumWM", "TotalFoldInd")) {
        x_limit_left = 280 + 2*365
    }


    if (Measure %in% c("TotalSurfArea", "TotalFoldInd", "TotalCurvInd")) {
        Data$Pho <- Data$Pho*2
    }
    if (Measure %in% c("TotalThickAvg")) {
        Data$Pho <- Data$Pho
    } else {
        Data$Pho <- Data$Pho / 10000
    }
    if (Tag %in% c("Sub")) {
        Data$Pho <- Data$Pho*100
    }
    

    ages <- c(0*365+280, 1*365+280, 2*365+280, 18*365+280, 35*365+280, 80*365+280)
    agesYear <- c('0', '1', '2', '18', '35', '80 yr')
    age_transformed <- log(ages)
    
    p <- ggplot(Data, aes(x = AgeTransformed, y = Pho, color = as.factor(Sex))) +
      geom_point(shape = 16, size = 10, alpha = 0.75) +  
      labs(x = NULL, y = NULL) +
      ggtitle("  ") +  
      theme_minimal() +
      theme(legend.position = "none",  
            plot.title = element_text(size = 40, hjust = 0.5, face = "bold"),  
            axis.text = element_text(size = 38),  
            axis.ticks = element_line(size = 1.5), 
            axis.text.x = element_blank(), 
            axis.text.y = element_blank(), 
            axis.ticks.length = unit(0.3, "cm"), 
            axis.title = element_text(size = 35),
            panel.grid = element_blank(),
            axis.line = element_line(size = 1, color = "black")) + 
      scale_x_continuous(breaks = age_transformed, labels = agesYear, 
                     limits = c(log(x_limit_left), log(280 + 100 * 365))) +  
      scale_color_manual(values = c("1" = "#3BA997", "0" = "#B291B5")) +      
      geom_vline(xintercept = log(18*365 + 280), linetype = "dashed", color = "grey", size = 2.5) 

    
    ggsave( paste0(OutPath,"/",DATATAG,"_Data_distribution.png"), width = 10, height = 5.5, plot=p ,dpi = 300 )
    
    
  }
}

