library(dplyr)
library(mcmcse)
library(ggplot2)
library(stringr)

expt.dirs <- c("../../analyze/spark-eber-results/nltcs_6levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_5levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_4levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_3levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_2levels_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_1level_med-prior_collapsed",
               "../../analyze/spark-eber-results/nltcs_0levels_med-prior_collapsed")

save.fname <- "num-ent-plot-test-num-partitions"
plot.width <- 3.349263889
plot.height <- 2.82
end.time <- 1000
num.points <- 200

theme_set(theme_bw() + theme(text = element_text(size = 9)))

results <- lapply(expt.dirs, function(dir) {
  # Read diagnostic CSV files from experiment
  diagnostics <- read.csv(paste(dir,"diagnostics.csv", sep="/"))
  
  # Get number of partitions from the directory name of the experiment
  num.levels <- stringr::str_extract(dir, "\\d")
  num.partitions <- 2^as.integer(num.levels)
  
  # Select iterations within specified range
  # (Reason: some experiments have been run for more iterations than others.)
  start.time <- diagnostics$systemTime.ms[1]
  diagnostics %>% 
    mutate(time = (systemTime.ms - start.time) * 10^-3, 
           num.partitions = num.partitions) %>% 
    filter(time <= end.time) %>% 
    select(iteration, time, num.partitions, numObservedEntities)-> diagnostics
  
  return(diagnostics)
})

results.combined <- bind_rows(results)

pdf(paste0(save.fname, ".pdf"), height = plot.height, width = plot.width)
results.combined %>% 
  mutate(num.partitions = as.factor(num.partitions)) %>%
  ggplot(aes(x = time, y = numObservedEntities, col = num.partitions)) + 
  geom_point(aes(shape = num.partitions)) + 
  scale_shape_manual(values = seq(0,7)) +
  scale_x_continuous(limits = c(0, 600)) +
  coord_trans(y = "log10") +
  labs(x = "Time (s)", y = "# observed entities", col = "# partitions", shape = "# partitions") +
  theme(legend.position="bottom", legend.margin=margin(0,0,0,0), legend.key.height = unit(10,"points"))
dev.off()
