rm(list=ls())
## COMMON LIBRARIES AND FUNCTIONS
source("100.common-variables.r")
source("101.common-functions.r")



measures <- c("TotalGM", "TotalWM", "TotalsubGM","eTIV", "TCV","TotalSurfArea","TotalThickAvg","Vent_Volume","TotalFoldInd","Cerebellum","CerebellumGM","CerebellumWM")



for (i in 1:12) {

print(measures[i])
  

DATATAG <- paste0("Chinese_Global_", measures[i])
Indexflag <- paste0(measures[i])

source("300.variables.r")
source("301.functions.r")

source("500.plotting-variables.r")
source("501.plotting-functions.r")

library(ggplot2)

measure <- Indexflag


x_limit_left=280
if (measure %in% c("TotalFoldInd", "Cerebellum","CerebellumGM","CerebellumWM", "Vent_Volume", "Accumbens_area", "Left_Accumbens_area", "Left_Cerebellum_Cortex", "Right_Accumbens_area", "Right_Cerebellum_Cortex")) {
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


################################################################################################### PLOT m500 Curve
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
        axis.text.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks = element_line(size = 1.5), 
        axis.ticks.length = unit(0.3, "cm"), 
        axis.title = element_text(size = 35), 
        panel.grid = element_blank(),
        axis.line = element_line(size = 1, color = "black")) + 
  scale_x_continuous(breaks = age_transformed, labels = agesYear, 
                     limits = c(log(x_limit_left), log(280 + 100 * 365))) +
  scale_color_manual(values = c("Male" = "#1AA7B4", "Female" = "#F3993A")) +
  geom_vline(xintercept = log(18*365 + 280), linetype = "dashed", color = "grey", size = 2.5) 
p
ggsave(file.path(PATHS.LIST$PATH, sprintf("Growth_Curve.png")), width = 10, height = 5.5, plot = p, dpi = 300)


################################################################################################### PLOT m500 Rate
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
        axis.text.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks = element_line(size = 1.5), 
        axis.ticks.length = unit(0.3, "cm"), 
        axis.title = element_text(size = 35), 
        panel.grid = element_blank(), 
        axis.line = element_line(size = 1, color = "black")) + 
  scale_x_continuous(breaks = age_transformed, labels = agesYear,
                     limits = c(log(x_limit_left), log(280 + 100 * 365))) + 
  scale_color_manual(values = c("Male" = "#1AA7B4", "Female" = "#F3993A")) +  # 浅蓝 + 黄
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey", size = 2.5) 
p
ggsave(file.path(PATHS.LIST$PATH, sprintf("Growth_Rate.png")), width = 10, height = 5.5, plot = p, dpi = 300)