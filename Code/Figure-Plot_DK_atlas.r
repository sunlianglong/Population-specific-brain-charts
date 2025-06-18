library(ggseg)
library(ggplot2)
library(dplyr)
region_names <- c(
  paste0("lh_", c("bankssts", "caudalanteriorcingulate", "caudalmiddlefrontal", "cuneus",
                  "entorhinal_DELETE", "fusiform", "inferiorparietal", "inferiortemporal",
                  "isthmuscingulate", "lateraloccipital", "lateralorbitofrontal",
                  "lingual", "medialorbitofrontal", "middletemporal", "parahippocampal",
                  "paracentral", "parsopercularis", "parsorbitalis", "parstriangularis",
                  "pericalcarine", "postcentral", "posteriorcingulate", "precentral",
                  "precuneus", "rostralanteriorcingulate", "rostralmiddlefrontal",
                  "superiorfrontal", "superiorparietal", "superiortemporal",
                  "supramarginal", "frontalpole_DELETE", "temporalpole_DELETE", "transversetemporal",
                  "insula")),
  paste0("rh_", c("bankssts", "caudalanteriorcingulate", "caudalmiddlefrontal", "cuneus",
                  "entorhinal_DELETE", "fusiform", "inferiorparietal", "inferiortemporal",
                  "isthmuscingulate", "lateraloccipital", "lateralorbitofrontal",
                  "lingual", "medialorbitofrontal", "middletemporal", "parahippocampal",
                  "paracentral", "parsopercularis", "parsorbitalis", "parstriangularis",
                  "pericalcarine", "postcentral", "posteriorcingulate", "precentral",
                  "precuneus", "rostralanteriorcingulate", "rostralmiddlefrontal",
                  "superiorfrontal", "superiorparietal", "superiortemporal",
                  "supramarginal", "frontalpole_DELETE", "temporalpole_DELETE", "transversetemporal",
                  "insula"))
)


values <- values # put your data here, 68*1

brain_data <- data.frame(label = region_names, value = values)
brain_data <- brain_data %>%
  semi_join(ggseg::dk$data, by = "label") 
p <- ggplot() +
  geom_brain(data = brain_data, atlas = dk, mapping = aes(fill = value)) +
  scale_fill_gradient2(low = "darkblue", mid = "white", high = "red", midpoint = 0,limits = Range,
                       name = "Value") +  
  theme_void() + 
  labs(title = NULL)
p
ggsave(
  filename = "Figure.png",
  plot = p,
  width = 8, height = 8,
  dpi = 300  
)
