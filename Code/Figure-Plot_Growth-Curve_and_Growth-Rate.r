rm(list=ls())

args <- commandArgs(TRUE)
DATATAG <- args[1] # "Chinese_AgeT_Global"
Indexflag <- args[2] # TotalGM

## COMMON LIBRARIES AND FUNCTIONS
source("100.common-variables.r")
source("101.common-functions.r")

source("300.variables.r")
source("301.functions.r")

source("500.plotting-variables.r")
source("501.plotting-functions.r")

library(ggplot2)

measures <- Indexflag
print(measures)


x_limit_left=280
if (measures %in% c("TotalFoldInd", "Cerebellum","CerebellumGM","CerebellumWM", "Vent_Volume")) {
    x_limit_left = 280 + 2*365
}



wTAG <- DERIVED.SET
cat( "=====", wTAG, "=====\n" )
PATHS.LIST <- Create.Folders( wTAG )

if( !file.exists( file.path( PATHS.LIST$PATH, "DERIVED.rds" ) ) ) {
  cat(sprintf("Warning: %s does not have a DERIVED.rds object, run 350.calc-derived script.",wTAG),"\n")
  next
}
PRIMARY <- readRDS( file=file.path( PATHS.LIST$PATH, "DERIVED.rds" ) )



ages <- c(0*365+280, 1*365+280, 2*365+280, 18*365+280, 35*365+280, 80*365+280)
agesYear <- c('0', '1', '2', '18', '35', '80 yr')
age_transformed <- log(ages)


################################################################################################### PLOT Growth Curve
lD <- ""
p <- ggplot(PRIMARY$POP.CURVE.PRED, aes_string(x = PRIMARY$MODEL$covariates$X, y = sprintf("PRED.m500.pop%s", lD), color = 'Sex')) +
  geom_line(size = 5) +  
  geom_line(aes_string(y = sprintf("PRED.l025.pop%s", lD)), linetype = 3, size = 3) +  
  geom_line(aes_string(y = sprintf("PRED.u975.pop%s", lD)), linetype = 3, size = 3) +  
  labs(x = NULL, y = NULL) +
  ggtitle("  ") +  
  theme_minimal() +
  theme(legend.position = "none",  
        plot.title = element_text(size = 40, hjust = 0.5, face = "bold"),  
        axis.text = element_text(size = 38),  
        axis.ticks = element_line(size = 1),  
        axis.ticks.length = unit(0.2, "cm"),  
        axis.title = element_text(size = 35),  
        panel.grid = element_blank(),
        axis.line = element_line(size = 1, color = "black")) +  
  scale_x_continuous(breaks = age_transformed, labels = agesYear, 
                     limits = c(log(x_limit_left), log(280 + 100 * 365))) + 
  # scale_y_continuous(limits = c(0, 20)) +
  scale_color_manual(values = c('#F3993A', '#1AA7B4')) + 
  geom_vline(xintercept = log(18*365 + 280), linetype = "dashed", color = "grey", size = 2)

p
ggsave(file.path(PATHS.LIST$PATH, sprintf("Growth_Curve.png")), width = 10, height = 5.5, plot = p, dpi = 300)



################################################################################################### PLOT Growth Rate
lD <- ".D"
p <- ggplot(PRIMARY$POP.CURVE.PRED, aes_string(x = PRIMARY$MODEL$covariates$X, y = sprintf("PRED.m500.pop%s", lD), color = 'Sex')) +
  geom_line(size = 2) + 
  geom_line(aes_string(y = sprintf("PRED.m500.pop%s.lower", lD)), linetype = 2, size = 1) +  
  geom_line(aes_string(y = sprintf("PRED.m500.pop%s.upper", lD)), linetype = 2, size = 1) +  
  labs(x = NULL, y = NULL) +
  ggtitle("  ") +  
  theme_minimal() +
  theme(legend.position = "none",  
        plot.title = element_text(size = 40, hjust = 0.5, face = "bold"),  
        axis.text = element_text(size = 38), 
        axis.ticks = element_line(size = 1),  
        axis.ticks.length = unit(0.2, "cm"),  
        axis.title = element_text(size = 35), 
        panel.grid = element_blank(),  
        axis.line = element_line(size = 1, color = "black")) +  
  scale_x_continuous(breaks = age_transformed, labels = agesYear,
                     limits = c(log(x_limit_left), log(280 + 100 * 365))) +  
  scale_color_manual(values = c('#F3993A', '#1AA7B4')) + 
  geom_vline(xintercept = log(18*365 + 280), linetype = "dashed", color = "grey", size = 2) 
p
ggsave(file.path(PATHS.LIST$PATH, sprintf("Growth_Rate.png")), width = 10, height = 5.5, plot = p, dpi = 300)
