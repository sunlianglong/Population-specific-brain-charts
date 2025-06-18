library(ggseg)
library(ggplot2)
library(dplyr)
library(tidyr)
region_names <- c(
  paste0("Left-", c("Thalamus-Proper","Caudate","Putamen","Pallidum",
                    "Hippocampus","Amygdala")),
  paste0("Right-", c("Thalamus-Proper","Caudate","Putamen","Pallidum",
                     "Hippocampus","Amygdala"))
)
values <- values # put your data here, 12*1

region_data <- data.frame(label = region_names, value = values)
aseg_df <- unnest(as_tibble(aseg), cols = c(geometry))
brain_data <- aseg_df %>%
  left_join(region_data, by = "label")

p <- ggplot() +
  geom_brain(data = brain_data, atlas = aseg, mapping = aes(fill = value), color = "#C1C1C1") + 
  scale_fill_viridis_c(option = "plasma", na.value = "#E5E5E5") + 
  scale_fill_gradient2(low = "darkblue", mid = "white", high = "#E86A50", na.value = "#E5E5E5") +  
  
  theme_void() + 
  labs(title = NULL) +
  theme(legend.position = "right")
p
ggsave(
  filename = "Figure.png",
  plot = p,
  width = 8, height = 8, 
  dpi = 300  
  )
